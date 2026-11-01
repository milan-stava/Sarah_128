// Shared pause policy: empty is not EOF; progress resumes without replaying data.
function transferPauseRegression(makeCpu,image,bios,S,bank6) {
 let checks=0;
 const assert=(ok,msg)=>{if(!ok)throw Error(msg);checks++;},stop={};
 const put=(m,p,v)=>{m[p]=v&255;m[p+1]=v>>8;};
 for(const pressed of [false,true]) {
  const u=makeCpu([],bios,S,{image,onIn:port=>pressed&&port===0x7ffe?0xef:0xff});
  const r=u.call(S.ftp_poll_cancel,{bc:0x1234,de:0x5678,hl:0x9abc});
  assert(r.carry===pressed,'real keyboard matrix cancels only on B');
  assert(r.bc===0x1234&&r.de===0x5678&&r.hl===0x9abc,'raw cancellation preserves parser registers');
 }
 for(const empty of [0,1,129,1024,4096])for(const size of [1,2048,4096]) {
  let polls=0,delays=0;
  const u=makeCpu([],bios,S,{image,hook(pc,r){
   if(pc===S.ftp_query_lengths){polls++;return {ret:true,hl:polls<=empty?0:size,de:17};}
   if(pc===S.ftp_poll_delay){delays++;return {ret:true};}
   if(pc===S.inkey)return {ret:true,a:0};
   if(pc===S.send_string)throw Error('paused download replayed a command');
  }});
  const result=u.call(S.data_available_in_module_file);
  assert(!result.z&&!result.carry&&result.hl===Math.min(size,S.download_length),'data reappears after pause '+empty);
  assert(polls===empty+1&&delays===empty,'polls are paced without premature EOF');
 }
 for(const pending of [0,27]) {
  const u=makeCpu([],bios,S,{image,hook(pc){if(pc===S.ftp_query_lengths)return {ret:true,hl:pending,de:0};}});
  u.m[S.at_closed]=2;const r=u.call(S.data_available_in_module_file);
  assert(pending?!r.z&&r.hl===pending:r.z,'drain pending bytes before recognizing closed data socket');
 }
 for(const cancel of [false,true]) {
  let polls=0,error=0;
  const u=makeCpu([],bios,S,{image,hook(pc,r){
   if(pc===S.ftp_query_lengths){polls++;return {ret:true,hl:!cancel&&polls===4097?1:0,de:0};}
   if(pc===S.ftp_poll_delay)return {ret:true};
   if(pc===S.inkey)return {ret:true,a:cancel&&polls===3?98:0};
   if(pc===S.error_handler){error=r.bc&255;throw stop;}
  }});
  let result;try{result=u.call(S.data_available_in_module_file);}catch(e){if(e!==stop)throw e;}
  assert(cancel?result.z&&result.carry&&polls===3:!result.z&&!result.carry&&!error&&polls===4097,'cancel or resume beyond previous idle limit');
 }
 {
  let queries=0,error=0;
  const u=makeCpu([],bios,S,{image,hook(pc,r){
   if(pc===S.send_string){queries++;return {ret:true,z:true};}
   if(pc===S.error_handler){error=r.bc&255;throw stop;}
  }});
  try{u.call(S.data_available_in_module_file);}catch(e){if(e!==stop)throw e;}
  assert(error===48&&queries===1,'unanswered AT length query remains bounded, unlike a valid empty reply');
 }
 // Same cancellation helper inside UART SEND OK waiting; no payload retransmission.
 {
  let abort=0;
  const u=makeCpu([],bios,S,{image,hook(pc,r){
   if(pc===S.inkey)return {ret:true,a:98};
   if(pc===S.ful_abort){abort=r.bc&255;throw stop;}
   if(pc===S.send_string||pc===S.send_data)throw Error('ACK wait replayed data');
  }});u.m[S.ftp_upload_wait]=1;
  try{u.call(S.ftp_read_byte);}catch(e){if(e!==stop)throw e;}
  assert(abort===20&&u.m[S.ftp_upload_wait]===0,'B cancels an upload ACK pause');
 }
 for(const [speed,scale]of [[0,8],[1,16],[2,32],[3,46]])for(const long of [false,true]) {
  const u=makeCpu([],bios,S,{image,speed,hook(pc,r){
   if(pc===0xe0d7){assert(r.de===scale,'ordinary CPU-scaled UART budget is retained');return {ret:true,z:false,a:42};}
  }});u.m[S.ftp_upload_wait]=long?1:0;
  assert(u.call(S.ftp_read_byte,{hl:0x1234,bc:0x4567,de:0x89ab}).a===42,'extended read retains byte contract');
 }
 // A reply beyond even the previous four-window budget must complete an upload.
 for(const extended of [false,true]) {
  let u,error=0,keyPolls=0;
  u=makeCpu([],bios,S,{image,onPoll(n,rx){if(n===2200000)rx.push(...Array.from('SEND OK\r\n',c=>c.charCodeAt(0)));if(n>2210000)throw Error('delayed ACK was not consumed');},hook(pc,r){
   if(pc===S.inkey){keyPolls++;return {ret:true,a:0};}
   if(pc===S.set_7mhz||pc===S.set_20mhz)return {ret:true};
   if(pc===S.error_handler){error=r.bc&255;throw stop;}
   if(pc===S.send_string||pc===S.send_data)throw Error('delayed ACK caused payload replay');
  }});
  try{u.call(extended?S.fus1:S.ftp_read_byte);}catch(e){if(e!==stop)throw e;}
  assert(extended?error===0&&u.m[S.upload_last_event]===4:error===48,'long ACK wait outlives normal timeout');
  if(extended)assert(keyPolls>0&&u.m[S.ftp_upload_wait]===0,'delayed ACK remains cancellable and restores normal timeout');
 }
 for(const notice of ['0,CLOSED','1,CLOSED','WIFI DISCONNECT']) {
  let aborted=0;
  const u=makeCpu([],bios,S,{image,hook(pc,r){
   if(pc===S.set_7mhz||pc===S.set_20mhz)return {ret:true};
   if(pc===S.ful_abort){aborted=r.bc&255;throw stop;}
   if(pc===S.error_handler)throw Error('known connection loss waited for UART timeout');
  }});u.m[S.at_closed]=0;u.rx.push(...Array.from(notice+'\r\n',c=>c.charCodeAt(0)));
  try{u.call(S.fus1);}catch(e){if(e!==stop)throw e;}
  assert(aborted===8&&u.m[S.upload_last_event]===5&&u.m[S.ftp_upload_wait]===0,'known closure ends extended wait: '+notice);
 }
 {
  // Empty length sampled before CLOSED can become nonempty by the final recheck.
  let polls=0;const u=makeCpu([],bios,S,{image,hook(pc){if(pc===S.ftp_query_lengths)return {ret:true,hl:++polls===1?0:42,de:0};}});
  u.m[S.at_closed]=2;assert(u.call(S.data_available_in_module_file).hl===42,'final queued bytes after close are preserved');
 }
 // 32-bit remaining length must not treat equal nonzero words as zero.
 for(const entry of ['fdf_main','fdf3'])for(const remaining of [0,65537,131074,1,65536]) {
  let receive=false,complete=false;
  const u=makeCpu([],bios,S,{image,hook(pc){
   if(pc===S.display_progress)return {ret:true};
   if(pc===S.fdf_loop||pc===S.data_available_in_module_file){receive=true;throw stop;}
   if(pc===S.fdfm2||pc===S.save_into_file){complete=true;throw stop;}
  }});put(u.m,S.rest_len,remaining&65535);put(u.m,S.rest_len+2,remaining>>>16);
  try{u.call(S[entry]);}catch(e){if(e!==stop)throw e;}
  assert(remaining?receive&&!complete:complete&&!receive,'32-bit remaining check '+entry+'/'+remaining);
 }
 // Cancelled waits must use each caller's cleanup, without drawing partial content.
 {
  let deleted=0,aborted=0;
  const u=makeCpu([],bios,S,{image,hook(pc){
   if(pc===S.data_available_in_module_file)return {ret:true,z:true,carry:true};
   if(pc===S.delete_file){deleted++;return {ret:true};}
   if(pc===S.ftp_abort_download){aborted++;throw stop;}
   if(pc===S.display_error)throw Error('B cancellation displayed a missing-data error');
  }});put(u.m,S.rest_len,1);put(u.m,S.rest_len+2,0);
  try{u.call(S.fdf3);}catch(e){if(e!==stop)throw e;}
  assert(deleted===1&&aborted===1,'disk download removes partial file and aborts');
 }
 {
  let aborted=0,restored=0;
  const u=makeCpu([],bios,S,{image,hook(pc){
   if(pc===S.data_available_in_module_file)return {ret:true,z:true,carry:true};
   if(pc===S.ftp_abort_transfer){aborted++;return {ret:true};}
   if(pc===S.akey1||pc===S.display_error)throw Error('cancelled image waits on partial content');
   if(pc===S.print_whole_screen){restored++;throw stop;}
  }});
  try{u.call(S.ds1);}catch(e){if(e!==stop)throw e;}
  assert(aborted===1&&restored===1,'screen download aborts before restoring its UI');
 }
 {
  let aborted=0;
  const u=makeCpu([],bios,S,{image,hook(pc){
   if(pc===S.KEYSCAN)return {ret:true,a:0};
   if(pc===S.data_available_in_module_file)return {ret:true,z:true,carry:true};
   if(pc===S.ftp_abort_transfer){aborted++;return {ret:true};}
   if(pc===S.text_browse||pc===S.pts)throw Error('cancelled text enters viewer/error prompt');
  }});u.m.set(bank6,0xc000);put(u.m,S.text_length,1);put(u.m,S.text_pos,0);
  u.call(S['text_viewer_control.read']);
  assert(aborted===1,'text download cancellation drains transfer without opening viewer');
 }
 return {checks};
}
if(typeof require!=='undefined'&&typeof module!=='undefined') {
 const fs=require('fs'),vm=require('vm'),esx=process.argv[2]==='esx',S={};
 vm.runInThisContext(fs.readFileSync('tests/z80-directory.js','utf8'));
 for(const m of fs.readFileSync(esx?'directory-esx-test.sym':'directory-test.sym','utf8').matchAll(/^v[01]\.(\S+): EQU 0x([0-9A-F]+)/gmi))S[m[1]]=parseInt(m[2],16);
 const tape=fs.readFileSync(esx?'SARA_ESX_LOADER.tap':'SARA_LOADER.tap'),blocks=[];
 for(let p=0;p<tape.length;){const n=tape[p]|tape[p+1]<<8;p+=2;blocks.push(tape.subarray(p+1,p+n-1));p+=n;}
 console.log(transferPauseRegression(makeCpu,blocks[3],fs.readFileSync('WifiBios20_MB_EL.cod'),S,blocks[5]));
}
