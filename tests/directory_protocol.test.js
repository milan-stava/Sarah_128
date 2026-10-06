// Executes assembled Z80 code and the actual BIOS RX body; not an FPGA timing model.
// Build: sjasmplus --sym=directory-test.sym assembly_mbbsd1.asm
// Run: node tests/directory_protocol.test.js
function directoryRegression(makeCpu,image,bios,S) {
 let checks=0;
 const bytes=s=>Array.from(s,c=>c.charCodeAt(0));
 const assert=(v,why)=>{if(!v)throw Error(why);checks++;};
 const str=(m,p)=>{let s='';while(m[p])s+=String.fromCharCode(m[p++]);return s;};
 const putWord=(m,p,v)=>{m[p]=v&255;m[p+1]=v>>8;};
 const cpu=(extra={})=>makeCpu([],bios,S,{image,...extra});
 const gap=(text,n=2)=>bytes(text).flatMap(v=>[...Array(n).fill(null),v]);
 for(let value=0;value<256;value++) {
  let u=cpu();u.rx.push(...Array(9).fill(null),value);
  let r=u.call(S.ftp_read_byte,{bc:0x1234,de:0x5678,hl:0xabcd});
  assert(r.a===value&&r.z===false,'ready byte including NUL '+value);
  assert(r.bc===0x1234&&r.de===0x5678&&r.hl===0xabcd,'preserve parser registers');
 }
 // Partial match at timeout was incorrectly reported as success by look_on_fly.
 for(const text of ['O','OK','OK\r']) {
  let u=cpu();u.rx.push(...bytes(text));
  assert(!u.call(S.look_on_fly,{hl:S.ok}).z,'incomplete OK is not success: '+text);
 }
 for(let gapAt=0;gapAt<=4;gapAt++) {
  let u=cpu(),input=bytes('OK\r\nNEXT');input.splice(gapAt,0,...Array(1300).fill(null));u.rx.push(...input);
  assert(!u.call(S.check_module_answer,{hl:S.ok}).carry,'fragmented OK');
  assert(String.fromCharCode(...u.rx.filter(x=>x!==null))==='NEXT','do not discard next message');
 }
 for(const terminal of ['OK','ERROR','UNLINK   ERROR']) {
  let u=cpu();u.rx.push(...gap('\r\n1,CLOSED\r\n'+terminal+'\r\nNEXT'));
  assert(u.call(S.ftp_wait_terminal).carry===(terminal!=='OK'),'terminal '+terminal);
  assert(String.fromCharCode(...u.rx.filter(x=>x!==null))==='NEXT','consume exactly terminal');
 }
 {
  let u=cpu();u.m[S.TX_buf]=0xa5;u.rx.push(...gap('x'.repeat(400)+'\r\n'));
  u.call(S.ftp_read_line);
  assert(str(u.m,S.RX_buf).length===127&&u.m[S.TX_buf]===0xa5,'bounded line buffer');
 }
 for(const n of [1,10,128,2048,65535]) {
  let u=cpu();u.rx.push(...gap(n+':DATA',5));
  assert(u.call(S.ftp_read_length).hl===n,'fragmented decimal length '+n);
  assert(String.fromCharCode(...u.rx.filter(x=>x!==null))==='DATA','length leaves payload');
 }
 {
  let u=cpu();u.m.set(bytes('ERROR\r\n'),S.RX_buf+50);
  u.rx.push(...gap('1,CLOSED\r\nOK\r\n'));
  assert(!u.call(S.ftp_wait_terminal).carry,'ignore stale RX bytes beyond line end');
 }
 // Socket responses split at every offset, including inside the FTP numeric code/CRLF.
 for(const reply of ['150 Opening ASCII data connection\r\n226 Transfer complete\r\n',
                     '150 '+ 'x'.repeat(250)+'\r\n226 Transfer complete\r\n']) {
 for(const chunk of (reply.length<128?Array.from({length:reply.length},(_,i)=>i+1):[1,3,63,127,128])) {
  let pending=reply,u,queries=0;
  u=cpu({hook:(pc,r)=>{
   if(pc===S.error_handler)throw Error('Unexpected firmware error '+r.bc);
   if(pc===S.print_ftp_message)return {ret:true};
   if(pc===S.send_string){
    const cmd=str(r.m,r.hl);
    if(cmd==='AT+CIPRECVLEN?\r\n') {
     queries++;u.rx.push(...gap('\r\n+IPD,1,900\r\n+CIPRECVLEN:'+pending.length+',900,0,0,0\r\n\r\nOK\r\n'));
    } else if(cmd==='AT+CIPRECVDATA=0,128\r\n') {
     const data=pending.slice(0,chunk);pending=pending.slice(chunk);
     u.rx.push(...gap('\r\n+CIPRECVDATA,'+data.length+':'+data+'\r\nOK\r\n'));
    } else throw Error('Unexpected AT command '+cmd);
    return {ret:true,z:true};
   }
  }});
  assert(u.call(S.ask_for_reply_in_passive_mode).hl===150,'first reply split '+chunk);
  assert(u.call(S.ask_for_reply_in_passive_mode).hl===226,'second reply split '+chunk);
  assert(pending.length===0&&u.rx.length===0,'consume AT envelopes exactly '+chunk);
 }
 }
 // Execute the LIST parser with fake chunk fetches and normal unbanked RAM.
 {
  const reply='227 Entering Passive Mode (192,168,0,105,200,1)\r\n';
  const u=cpu({hook:(pc,r)=>{
   if(pc===S.error_handler)throw Error('Active reply error '+r.bc);
   if(pc===S.print_ftp_message)return {ret:true};
  }});
  u.m[S.TX_buf]=0xa5;
  u.rx.push(...gap('SEND OK\r\n\r\n+IPD,0,'+reply.length+':'+reply+'NEXT',5));
  const r=u.call(S.receive_ftp_answer_isolated,{de:227});
  assert(!r.carry&&r.hl===227&&r.de===0,'fragmented active PASV reply');
  assert(u.m[S.TX_buf]===0xa5,'active reply stays inside RX buffer');
  assert(String.fromCharCode(...u.rx.filter(x=>x!==null))==='NEXT','active reply exact length');
 }
 {
  let caught=false,u=cpu({hook:(pc,r)=>{if(pc===S.error_handler){caught=(r.bc&255)===49;throw 'expected-error';}}});
  u.rx.push(...bytes('SEND OK\r\n\r\n+IPD,0,128:'+'x'.repeat(128)));
  u.m[S.TX_buf]=0xa5;
  try{u.call(S.receive_ftp_answer_isolated,{de:227});}catch(e){if(e!=='expected-error')throw e;}
  assert(caught&&u.m[S.TX_buf]===0xa5,'oversized active response cannot corrupt TX buffer');
 }
 {
  const reply='227 Entering Passive Mode (192,168,0,105,200,1)\r\n';
  for(let split=1;split<reply.length;split++) {
   const u=cpu({hook:(pc,r)=>{
    if(pc===S.error_handler)throw Error('Split active reply error '+r.bc);
    if(pc===S.print_ftp_message)return {ret:true};
   }});
   u.rx.push(...gap('SEND OK\r\n\r\n+IPD,0,'+split+':'+reply.slice(0,split)+
    '\r\n+IPD,0,'+(reply.length-split)+':'+reply.slice(split)));
   const r=u.call(S.receive_ftp_answer_isolated,{de:227});
   assert(!r.carry&&r.hl===227,'FTP reply across IPD boundary '+split);
  }
 }
 // Temporary empty data channel must not deadlock waiting for 226 while data arrives.
 {
  let u,queries=0,emptyChecks=0;
  u=cpu({hook:(pc,r)=>{
   if(pc===S.error_handler)throw Error('EOF state error '+r.bc);
   if(pc===S.KEYSCAN)return {ret:true,a:0};
   if(pc===S.ftp_poll_delay)return {ret:true};
   if(pc===S.data_available_in_module_dir)return {ret:true,hl:emptyChecks++?5:0,z:emptyChecks===1};
   if(pc===S.ftp_query_lengths)return {ret:true,hl:++queries>=3?5:0,de:0};
   if(pc===S.ask_for_reply_in_passive_mode)throw Error('Waiting for 226 before draining new data');
   if(pc===S.ask_for_data_in_passive_mode){putWord(r.m,S.rest_chunk,5);return {ret:true};}
  }});
  u.m[S.flag1+23]=3;
  let r=u.call(S.dr_get_data,{hl:0xc123,bc:0x1234});
  assert(r.de===5&&r.hl===0xc123&&r.bc===0x1234,'resume late data and preserve parser state');
  assert(queries===3,'poll both channels until data arrives');
 }
 // 226 is not sufficient either: data arriving with the completion must still be read.
 {
  let u,queries=0,replies=0,avail=0;
  u=cpu({hook:(pc,r)=>{
   if(pc===S.error_handler)throw Error('completion error '+r.bc);
   if(pc===S.KEYSCAN)return {ret:true,a:0};
   if(pc===S.data_available_in_module_dir)return {ret:true,hl:avail++?9:0,z:avail===1};
   if(pc===S.ftp_query_lengths)return {ret:true,hl:++queries===1?0:9,de:queries===1?25:0};
   if(pc===S.ask_for_reply_in_passive_mode){replies++;return {ret:true,hl:226};}
   if(pc===S.ask_for_data_in_passive_mode){putWord(r.m,S.rest_chunk,9);return {ret:true};}
  }});
  u.m[S.flag1+23]=3;
  let r=u.call(S.dr_get_data,{hl:0xc123,bc:7});
  assert(r.de===9&&replies===1&&u.m[S.flag1+23]===0,'drain data after 226');
 }
 {
  let u,queries=0,finished=false;const stop={};
  u=cpu({hook:(pc,r)=>{
   if(pc===S.error_handler)throw Error('empty-directory error '+r.bc);
   if(pc===S.KEYSCAN)return {ret:true,a:0};
   if(pc===S.data_available_in_module_dir)return {ret:true,hl:0,z:true};
   if(pc===S.ftp_query_lengths){queries++;return {ret:true,hl:0,de:25};}
   if(pc===S.ask_for_reply_in_passive_mode)return {ret:true,hl:226};
   if(pc===S.dr_end_ok){finished=true;assert(r.stack.length===0,'EOF removes exactly dr_get_data return');throw stop;}
  }});
  u.m[S.flag1+23]=3;
  try{u.call(S.dr_get_data);}catch(e){if(e!==stop)throw e;}
  assert(finished&&queries===2,'empty directory waits for 226 then rechecks data');
 }
 const line='-rw-r--r-- 1 user group 123 Oct 06 12:00 one.txt\r\n';
 for(const heading of ['', 'total 1\r\n', 'Total 1\r\n']) {
  const listing=heading+line;
  for(let chunk=1;chunk<=listing.length;chunk++) {
   let u,loaded=Math.min(chunk,listing.length),endState;
   const stop={};
   u=cpu({hook:(pc,r)=>{
    if(pc===S.error_handler)throw Error('Parser error '+r.bc);
    if(pc===S.DIR128_INC_HL_PARSER)return {ret:true,hl:(r.hl+1)&65535};
    if(pc===S.DIR128_MAP_DE)return {ret:true};
    if(pc===S.dr_get_data){
     if(loaded===listing.length){endState=r;throw stop;}
     const n=Math.min(chunk,listing.length-loaded);
     u.rx.push(...gap(listing.slice(loaded,loaded+n),4));loaded+=n;
     return {ret:true,de:n};
    }
   }});
   u.m[S.flag_dir]=128;u.m[S.dir128_parser_status]=0;
   putWord(u.m,S.fdp_pointer,S.ftp_dir_page+1);
   u.rx.push(...gap(listing.slice(0,loaded),4));
   try{u.call(S.dr13,{hl:0xc007,de:loaded});throw Error('Unexpected parser return');}catch(e){if(e!==stop)throw e;}
   assert(endState.iy===1,'one complete LIST item, heading '+heading.length+', chunk '+chunk);
   assert(u.rx.filter(x=>x!==null).length===0,'all bytes accounted for');
  }
 }
 return {checks};
}
if(typeof require!=='undefined'&&typeof module!=='undefined') {
 const fs=require('fs'),vm=require('vm');
 vm.runInThisContext(fs.readFileSync('tests/z80-directory.js','utf8'));
 const esx=process.argv[2]==='esx';
 const S={};for(const line of fs.readFileSync(esx?'directory-esx-test.sym':'directory-test.sym','utf8').split(/\r?\n/)){
  const m=line.match(/^v[01]\.(\S+): EQU 0x([0-9A-F]+)/i);if(m)S[m[1]]=parseInt(m[2],16);
 }
 const image=esx?fs.readFileSync('SARAH12ESX.tap').subarray(24,-1):fs.readFileSync('SARAH12BSDhgfx');
 console.log(directoryRegression(makeCpu,image,fs.readFileSync('WifiBios20_MB_EL.cod'),S));
}
