// Real ESP/host baud negotiation and upload cleanup ordering, simulated modem.
function uploadBaudRegression(makeCpu,image,bios,S) {
 let checks=0;
 const assert=(ok,msg)=>{if(!ok)throw Error(msg);checks++;},stop={};
 const bytes=s=>Array.from(s,c=>c.charCodeAt(0));
 const text=(m,p)=>{let s='';while(m[p])s+=String.fromCharCode(m[p++]);return s;};
 function fixture({host=16,reject=false,extra=()=>{}}={}) {
  let u,current=host,commands=[],changes=[],caught=0,wire='';
  u=makeCpu([],bios,S,{image,hook(pc,r){
   const x=extra(pc,r,{host:()=>current,commands,changes});if(x)return x;
   if(pc===S.get_baud)return {ret:true,a:current,carry:false};
   if(pc===S.set_print_speed){current=r.a;changes.push(current);return {ret:true,carry:false,bc:0x793b,hl:0x1230};}
   if([S.wifi_wait,S.wifi_unwait,S.print_ftp_message,S.print_transfer_status].includes(pc))return {ret:true};
   if(pc===S.set_3_5mhz)return {ret:true,bc:0x793b,hl:0x1230};
   if(pc===S.send_string){
    wire+=text(r.m,r.hl);if(!wire.endsWith('\r\n'))return {ret:true,z:true};
    const cmd=wire;wire='';commands.push({cmd,host:current});
    if(cmd.startsWith('AT+UART_CUR='))u.rx.push(...bytes(reject?'ERROR\r\n':'OK\r\n'));
    else if(cmd==='AT\r\n')u.rx.push(...bytes('OK\r\n'));
    else if(cmd==='AT+CIPCLOSE=5\r\n'||cmd==='AT+CIPRECVMODE=0\r\n')u.rx.push(...bytes('OK\r\n'));
    else throw Error('unexpected baud test command '+cmd);
    return {ret:true,z:true};
   }
   if(pc===S.error_handler){caught=r.bc&255;throw stop;}
  }});u.m[S.flag1]|=64;u.m[S.flag1+7]=host;u.m[S.flag1+8]=23;
  return {u,commands,changes,host:()=>current,error:()=>caught};
 }
 {
  const f=fixture();f.u.call(S.ftp_upload_baud_begin);
  assert(f.host()===15&&f.u.m[S.flag1+7]===15,'upload lowers ESP and host to2304000');
  assert(f.u.m[S.ftp_upload_baud_saved]===16,'remember normal verified baud');
  f.u.call(S.ftp_upload_baud_restore);
  assert(f.host()===16&&f.u.m[S.flag1+7]===16,'restore normal3456000');
  assert(f.u.m[S.ftp_upload_baud_saved]===255,'restoration consumes saved state');
  assert(f.commands.map(x=>x.cmd).join('|')==='AT+UART_CUR=2304000,8,1,0,0\r\n|AT\r\n|AT+UART_CUR=3456000,8,1,0,0\r\n|AT\r\n','both changes positively verified');
  assert(f.commands.map(x=>x.host).join(',')==='16,15,15,16','command sent at old baud, probe at new baud');
  f.u.call(S.ftp_upload_baud_restore);assert(f.commands.length===4,'no repeated restore');
 }
 for(const original of [12,15]) {
  const f=fixture({host:original});f.u.call(S.ftp_upload_baud_begin);f.u.call(S.ftp_upload_baud_restore);
  assert(f.host()===original,'restore actual entry baud rather than hardcoded maximum');
  assert(f.commands.length===(original===15?0:4),'already-low UART needs no redundant commands');
 }
 {
  let prepared=false;
  const f=fixture({extra(pc,r,state){
   if(pc===S.send_type_command_i){prepared=true;assert(state.host()===15&&r.m[S.ftp_upload_baud_saved]===16,'lower baud before TYPE/PASV/STOR');throw stop;}
  }});
  try{f.u.call(S.fuf2,{hl:S.ftp_stor});}catch(e){if(e!==stop)throw e;}
  assert(prepared,'upload entry executes baud transition');
 }
 {
  const f=fixture({reject:true});
  try{f.u.call(S.ftp_upload_baud_begin);}catch(e){if(e!==stop)throw e;}
  assert(f.error()===31&&f.host()===16,'explicit rejection leaves original host baud');
  // Discard the interrupted test CPU stack; inspect recovery with a fresh one.
  const g=fixture();g.u.m[S.ftp_upload_baud_saved]=16;g.u.call(S.ftp_upload_baud_restore);
  assert(g.host()===16&&g.commands.length===0,'unchanged UART restoration is harmless');
 }
 {
  // Host switched but final AT failed: cached baud is stale. Use actual get_baud.
  const f=fixture({host:15});f.u.m[S.flag1+7]=16;f.u.m[S.ftp_upload_baud_saved]=16;
  f.u.call(S.ftp_upload_baud_restore);
  assert(f.host()===16&&f.changes.join(',')==='16','partial change recovery uses actual host baud');
 }
 {
  const f=fixture({host:15,reject:true});f.u.m[S.ftp_upload_baud_saved]=16;
  try{f.u.call(S.ftp_upload_baud_restore);}catch(e){if(e!==stop)throw e;}
  assert(f.error()===31&&f.u.m[S.ftp_upload_baud_saved]===255,'failed restore cannot repeat a pending change');
 }
 {
  const f=fixture();f.u.m[S.ftp_upload_baud_saved]=16;f.u.m[S.flag1]&=~64;
  f.u.call(S.ftp_upload_baud_restore);
  assert(!f.commands.length&&f.u.m[S.ftp_upload_baud_saved]===255,'unknown alignment never sends baud AT commands');
 }
 for(const entry of ['ftp_upl_end','ful_abort_done']) {
  let refreshed=false;
  const f=fixture({host:15,extra(pc,r,state){
   if(pc===S.ftp_close_data)return {ret:true};
   if(pc===S.ftp_active_reply)return {ret:true,hl:226};
   if(pc===S.fClose)return {ret:true};
   if(pc===S.set_20mhz)return {ret:true};
   if(pc===S.directory_retrieve){refreshed=true;assert(state.host()===16&&r.m[S.ftp_upload_baud_saved]===255,'restore before directory refresh '+entry);throw stop;}
  }});f.u.m[S.ftp_upload_baud_saved]=16;
  try{f.u.call(S[entry]);}catch(e){if(e!==stop)throw e;}
  assert(refreshed&&f.commands.length===2,'normal completion/cancel restores once');
 }
 {
  let login=false;
  const f=fixture({host:15,extra(pc,r,state){
   if(pc===S.ftp_mark_disconnected)return {ret:true};
   if(pc===S.auto_login){login=true;assert(state.host()===16,'reconnect login uses restored high baud');throw stop;}
  }});f.u.m[S.ftp_upload_baud_saved]=16;
  try{f.u.call(S.ftp_recovery_begin);}catch(e){if(e!==stop)throw e;}
  assert(login,'communication recovery reaches login');
  assert(f.commands[0].cmd==='AT+CIPCLOSE=5\r\n'&&f.commands[0].host===15,'close failed upload at its existing low baud');
  assert(f.commands[1].cmd==='AT+CIPRECVMODE=0\r\n'&&f.commands[1].host===15,'finish old session cleanup before baud change');
 }
 {
  const f=fixture({host:15,extra(pc,r){
   if(pc===S.initsp_keyloop){assert(r.m[S.ftp_upload_baud_saved]===255,'failed cleanup clears pending restore');throw stop;}
  }});f.u.m[S.ftp_upload_baud_saved]=16;
  try{f.u.call(S.error_handler_exit);}catch(e){if(e!==stop)throw e;}
  assert(!f.commands.length,'failed cleanup never sends another AT command blindly');
 }
 return {checks};
}
if(typeof require!=='undefined'&&typeof module!=='undefined') {
 const fs=require('fs'),vm=require('vm'),esx=process.argv[2]==='esx',S={};
 vm.runInThisContext(fs.readFileSync('tests/z80-directory.js','utf8'));
 for(const m of fs.readFileSync(esx?'directory-esx-test.sym':'directory-test.sym','utf8').matchAll(/^v[01]\.(\S+): EQU 0x([0-9A-F]+)/gmi))S[m[1]]=parseInt(m[2],16);
 const tape=fs.readFileSync(esx?'SARA_ESX_LOADER.tap':'SARA_LOADER.tap'),blocks=[];
 for(let p=0;p<tape.length;){const n=tape[p]|tape[p+1]<<8;p+=2;blocks.push(tape.subarray(p+1,p+n-1));p+=n;}
 console.log(uploadBaudRegression(makeCpu,blocks[3],fs.readFileSync('WifiBios20_MB_EL.cod'),S));
}
