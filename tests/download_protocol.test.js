// Assembled download completion/abort; UART and FTP server are simulated.
function downloadProtocolRegression(makeCpu,image,bios,S) {
 let checks=0;
 const assert=(v,s)=>{if(!v)throw Error(s);checks++;};
 const bytes=s=>Array.from(s,c=>c.charCodeAt(0));
 const text=(m,p)=>{let s='';while(m[p])s+=String.fromCharCode(m[p++]);return s;};
 const replies=codes=>codes.map(c=>c+' reply\r\n').join('');
 const stop={};
 function session(codes,{chunk=128,close='OK',dataAfterError=0,entry='ftp_abort_download',completion=false,receiveFailure=false}={}) {
  let u,pending=completion?replies(codes):'',wire=[],closed=false,off=0,done=false,error=0,saved=0,deleted=0,sawFinal=false,displayed=[];
  function feed(s){u.rx.push(...bytes(s).flatMap(v=>[null,null,v]));}
  u=makeCpu([],bios,S,{image,hook:(pc,r)=>{
   if(pc===S.error_handler){error=r.bc&255;throw stop;}
   if(pc===S.ask_for_data_in_passive_mode){r.m[S.rest_chunk]=8;r.m[S.rest_chunk+1]=0;r.m[S.buff_add_float]=0;r.m[S.buff_add_float+1]=0xc0;return {ret:true};}
   if(pc===S.rece_block){feed((receiveFailure?'\r\nOK\r\nxx':'')+'\r\nOK\r\n');return {ret:true,carry:!receiveFailure,bc:receiveFailure?8:0,hl:receiveFailure?0xc000:0xc008};}
   if(pc===S.display_error){displayed.push(r.bc&255);return {ret:true};}
   if(pc===S.print_ftp_message){if(/^(225|226) /.test(text(r.m,r.hl)))sawFinal=true;return {ret:true};}
   if(pc===S.set_3_5mhz)return {ret:true};
   if(pc===S.delete_file){deleted++;return {ret:true};}
   if(pc===S.save_close){saved++;return {ret:true};}
   if(pc===S.clear_rece_buf||pc===S.upl_old_read_reply||pc===S.ful_abort||pc===S.send_abort)throw Error('old receive/abort path used');
   if(pc===S.passive_receive_off){assert(closed,'close data before changing receive mode');off++;return {ret:true};}
   if(pc===S.ful_abort_done){done=true;throw stop;}
   if(pc===S.send_string){const command=text(r.m,r.hl);wire.push(command);
    if(command==='AT+CIPSEND=0,6\r\n')feed('OK\r\n> ');
    else if(command==='ABOR\r\n'){pending+=replies(codes);feed('+IPD,0,'+pending.length+'\r\nSEND OK\r\n');}
    else if(command==='NOOP\r\n'){assert(sawFinal,'wait for ABOR completion before NOOP');pending+='200 NOOP\r\n';feed('SEND OK\r\n');}
    else if(command==='AT+CIPRECVLEN?\r\n')feed('+CIPRECVLEN:'+pending.length+','+(closed?dataAfterError:2048)+',0,0,0\r\nOK\r\n');
    else if(command==='AT+CIPRECVDATA=0,128\r\n'){
     const part=pending.slice(0,chunk);pending=pending.slice(chunk);
     feed('+CIPRECVDATA,'+part.length+':'+part+'\r\nOK\r\n');
    } else if(command==='AT+CIPCLOSE=1\r\n'){closed=true;feed(close==='OK'?'1,CLOSED\r\nOK\r\n':close+'\r\n');}
    else throw Error('unexpected wire command '+JSON.stringify(command));
    return {ret:true,z:true};
   }
  }});
  u.m[S.flag1]|=64;
  u.m[S.transfer_flag]=2;
  try{u.call(S[entry]);}catch(e){if(e!==stop)throw e;}
  return {u,pending,wire,closed,off,done,error,saved,deleted,displayed};
 }
 for(const codes of [[225],[226],[426,226],[226,225],[426,226,225]]) {
  for(const chunk of [1,3,128]) {
   const r=session(codes,{chunk});
   assert(r.done&&!r.error&&r.closed&&r.off===1,'abort completion '+codes+' split '+chunk);
   assert(r.pending===''&&r.u.m[S.ftp_control_left]===0,'NOOP barrier drains old replies');
   assert(r.wire.filter(x=>x==='ABOR\r\n').length===1&&r.wire.filter(x=>x==='NOOP\r\n').length===1,'no blind command retries');
  }
 }
 {
  const r=session([226],{close:'ERROR'});
  assert(r.done&&!r.error&&r.off===1,'already closed data socket with empty buffer');
 }
 for(const option of [{close:'ERROR',dataAfterError:9},{close:'busy p...'}]) {
  const r=session([226],option);
  assert(r.error===43&&!r.done&&!r.off,'do not release buffered data or ignore busy');
 }
 for(const codes of [[426,200],[500],[200],[226,226,226,226]]) {
  const r=session(codes);
  assert(r.error===16&&!r.closed&&!r.off,'reject incomplete/unexpected/excess abort replies '+codes);
 }
 {
  const r=session([426,226],{entry:'fdf_loop_err'});
  assert(r.deleted===1&&r.done,'download abort deletes partial file and avoids upload handler');
 }
 {
  const r=session([226],{entry:'fdfm2',completion:true,chunk:3});
  assert(!r.error&&r.saved===1&&r.pending===''&&r.u.m[S.transfer_flag]===0,'successful finish consumes 226 then saves file');
 }
 {
  const r=session([550],{entry:'fdfm2',completion:true});
  assert(r.saved===0&&r.deleted===1&&r.u.m[S.transfer_flag]===2,'failed completion deletes partial file');
 }
 {
  const r=session([426,226],{entry:'fdf_sub1',receiveFailure:true});
  assert(r.done&&r.deleted===1&&r.displayed.join(',')==='23','short block drains binary tail before abort');
 }
 {
  const r=session([],{entry:'fdf_sub1'});
  assert(!r.error&&r.u.rx.length===0&&r.wire.length===0,'complete block consumes exactly its AT terminal');
 }
 return {checks};
}
if(typeof require!=='undefined'&&typeof module!=='undefined') {
 const fs=require('fs'),vm=require('vm');
 vm.runInThisContext(fs.readFileSync('tests/z80-directory.js','utf8'));
 const S={};for(const l of fs.readFileSync('directory-test.sym','utf8').split(/\r?\n/)) {
  const m=l.match(/^v[01]\.(\S+): EQU 0x([0-9A-F]+)/i);if(m)S[m[1]]=parseInt(m[2],16);
 }
 console.log(downloadProtocolRegression(makeCpu,fs.readFileSync('SARAH12BSDhgfx'),fs.readFileSync('WifiBios20_MB_EL.cod'),S));
}
