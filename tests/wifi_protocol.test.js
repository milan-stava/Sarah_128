// Shared AT/FTP parser, executed from the assembled binary. No UART timing model.
function wifiProtocolRegression(makeCpu,image,bios,S) {
 let checks=0;
 const assert=(v,s)=>{if(!v)throw Error(s);checks++;};
 const bytes=s=>Array.from(s,c=>c.charCodeAt(0));
 const word=(m,p)=>m[p]|m[p+1]<<8;
 const cpu=()=>makeCpu([],bios,S,{image,hook:(pc,r)=>{
  if(pc===S.error_handler)throw Error('firmware error '+(r.bc&255));
 }});
 const ipd=s=>'+IPD,0,'+s.length+':'+s;
 for(const [speed,scale] of [[0,8],[1,16],[2,32],[3,46]]) {
  const u=makeCpu([],bios,S,{image,speed,hook:(pc,r)=>{
   if(pc===0xe0d7){assert(r.de===scale,'timeout scaling '+speed);return {ret:true,a:42,z:false};}
  }});
  const r=u.call(S.ftp_read_byte,{hl:0xabcd,bc:0x1234,de:0x5678});
  assert(r.a===42&&r.hl===0xabcd&&r.bc===0x1234&&r.de===0x5678,'speed-aware read preserves registers');
 }
 for(const terminal of ['OK','ERROR','SEND FAIL','busy s...','busy r...','busy p...']) {
  for(let split=0;split<=terminal.length;split++) {
   const u=cpu(),input=bytes(terminal+'\r\nNEXT');input.splice(split,0,null,null,null);
   u.rx.push(...input);
   const r=u.call(S.ftp_wait_terminal);
   assert(r.carry===(terminal!=='OK'),'exact result '+terminal);
   assert(String.fromCharCode(...u.rx)==='NEXT','terminal boundary '+terminal);
  }
 }
 {
  const u=cpu(),reply='220 Ready\r\n';
  u.rx.push(...bytes(ipd(reply)+'SEND OK\r\nNEXT'));
  assert(!u.call(S.at_wait_send).carry,'early IPD does not hide SEND OK');
  assert(word(u.m,S.ftp_control_next)===S.ftp_control_buffer,'FIFO starts at buffer');
  assert(u.call(S.ftp_active_reply).hl===220,'early reply retained');
  assert(u.m[S.ftp_control_left]===0&&word(u.m,S.ftp_control_next)===S.ftp_control_buffer,'FIFO resets after drain');
 }
 {
  const u=cpu();u.rx.push(...bytes(ipd('\r\nOK\r\n')+'ERROR\r\nNEXT'));
  assert(u.call(S.ftp_wait_terminal).carry,'OK in binary data is not AT success');
  assert(String.fromCharCode(...u.rx)==='NEXT','real ERROR consumed');
 }
 for(const body of ['220-first\r\ntext without code\r\n220 last\r\n',
                     '220-first\r\n221 different\r\n220 last\r\n']) {
  const u=cpu();u.rx.push(...bytes(ipd(body)));
  assert(u.call(S.ftp_active_reply).hl===220&&u.rx.length===0,'multiline matching final code');
 }
 {
  const u=cpu();u.rx.push(...bytes(ipd('150 begin\r\n226 done\r\n')));
  assert(u.call(S.ftp_active_reply).hl===150,'first reply in shared IPD');
  assert(u.call(S.ftp_active_reply).hl===226,'second reply in shared IPD');
 }
 {
  const u=cpu(),body='220 '+ 'x'.repeat(300)+'\r\n';u.m[S.TX_buf+128]=0xa5;
  u.rx.push(...bytes(ipd(body)));
  assert(u.call(S.ftp_active_reply).hl===220,'long legitimate text drained');
  assert(u.m[S.TX_buf+128]===0xa5&&u.rx.length===0,'long text bounded and fully read');
 }
 for(const n of [0,1,128,65535]) {
  const u=cpu();u.rx.push(...bytes('+CIPRECVDATA,'+n+':NEXT'));
  assert(u.call(S.at_wait_data).hl===n,'checked length '+n);
  assert(String.fromCharCode(...u.rx)==='NEXT','length leaves binary unread');
 }
 for(const n of ['', '65536','99999']) {
  const u=cpu();u.rx.push(...bytes('+CIPRECVDATA,'+n+':'));
  let caught=false;try{u.call(S.at_wait_data);}catch(e){caught=e.message==='firmware error 49';}
  assert(caught,'reject malformed/overflow length '+n);
 }
 {
  const u=cpu();u.m[S.flag1]|=32;
  u.rx.push(...bytes('1,CLOSED\r\n0,CLOSED\r\nOK\r\n'));
  assert(!u.call(S.ftp_wait_terminal).carry,'close notices before terminal');
  assert(u.m[S.at_closed]===3&&!(u.m[S.flag1]&32),'track socket closure');
 }
 for(const answer of ['STATUS:2\r\nOK\r\n',
                       'STATUS:3\r\n+CIPSTATUS:0,"TCP","192.168.0.2",21,1000,0\r\nOK\r\n']) {
  const u=cpu();u.rx.push(...bytes(answer));
  assert(!u.call(S.at_status_response).carry,'complete status response');
  assert(String.fromCharCode(...u.m.slice(S.RX_buf,S.RX_buf+7))==='STATUS:','status caller compatibility');
  assert(u.rx.length===0,'consume final status OK');
 }
 {
  const u=cpu();u.rx.push(...bytes('STATUS:3\r\nOK\r\n'));
  assert(u.call(S.at_status_response).carry,'status 3 requires control link description');
 }
 {
  let u,fetches=0;
  const text=(m,p)=>{let s='';while(m[p])s+=String.fromCharCode(m[p++]);return s;};
  u=makeCpu([],bios,S,{image,hook:(pc,r)=>{
   if(pc===S.error_handler)throw Error('control retry error '+(r.bc&255));
   if(pc===S.ftp_poll_delay)return {ret:true};
   if(pc===S.send_string){
    const command=text(r.m,r.hl);
    if(command==='AT+CIPRECVLEN?\r\n')u.rx.push(...bytes('+CIPRECVLEN:1,0,0,0,0\r\nOK\r\n'));
    else if(command==='AT+CIPRECVDATA=0,128\r\n')u.rx.push(...bytes(++fetches===1?'+CIPRECVDATA,0:\r\nOK\r\n':'+CIPRECVDATA,1:X\r\nOK\r\n'));
    else throw Error('unexpected command '+command);
    return {ret:true,z:true};
   }
  }});
  assert(u.call(S.ftp_control_byte).a===88&&fetches===2,'empty control fetch retries after terminal');
  assert(word(u.m,S.ftp_control_next)===S.ftp_control_buffer,'passive FIFO resets after drain');
 }
 return {checks};
}
if(typeof require!=='undefined'&&typeof module!=='undefined') {
 const fs=require('fs'),vm=require('vm');
 vm.runInThisContext(fs.readFileSync('tests/z80-directory.js','utf8'));
 const S={};for(const l of fs.readFileSync('directory-test.sym','utf8').split(/\r?\n/)) {
  const m=l.match(/^v[01]\.(\S+): EQU 0x([0-9A-F]+)/i);if(m)S[m[1]]=parseInt(m[2],16);
 }
 console.log(wifiProtocolRegression(makeCpu,fs.readFileSync('SARAH12BSDhgfx'),fs.readFileSync('WifiBios20_MB_EL.cod'),S));
}
