// Execute actual LIST cleanup and CIPRECVMODE switch, including split terminals.
function directoryCleanupRegression(makeCpu,image,bios,S) {
 let checks=0;
 const assert=(v,s)=>{if(!v)throw Error(s);checks++;};
 const bytes=s=>Array.from(s,c=>c.charCodeAt(0));
 const str=(m,p)=>{let s='';while(m[p])s+=String.fromCharCode(m[p++]);return s;};
 const run=(close,{data=0,split=-1}={})=>{
  let u,commands=[],outgoing='',displayed=false,error=0;
  const stop={};
  u=makeCpu([],bios,S,{image,hook:(pc,r)=>{
   if(pc===S.set_3_5mhz)return {ret:true};
   if(pc===S.error_handler){error=r.bc&255;throw stop;}
   if(pc===S.dr6){displayed=true;throw stop;}
   if(pc===S.clear_rece_buf)throw Error('blind UART flush');
   if(pc===S.send_string){outgoing+=str(r.m,r.hl);
    if(outgoing.endsWith('\r\n')){
     const command=outgoing;commands.push(command);outgoing='';
     let answer;
     if(command==='AT+CIPCLOSE=1\r\n')answer=close;
     else if(command==='AT+CIPRECVLEN?\r\n')answer='+CIPRECVLEN:0,'+data+',0,0,0\r\nOK\r\n';
     else if(command==='AT+CIPRECVMODE=0\r\n')answer='OK\r\n';
     else throw Error('unexpected command '+JSON.stringify(command));
     const input=bytes(answer);if(split>=0&&command==='AT+CIPCLOSE=1\r\n')input.splice(split,0,...Array(1300).fill(null));
     u.rx.push(...input);
    }
    return {ret:true,z:true};
   }
  }});
  u.m[S.flag1]|=64;u.m[S.recvmode]=49;u.m[S.at_closed]=2;
  try{u.call(S.dr_end);}catch(e){if(e!==stop)throw e;}
  return {u,commands,displayed,error,outgoing};
 };
 for(const reply of ['1,CLOSED\r\nOK\r\n','UNLINK\r\nOK\r\n','UNLINK\r\nERROR\r\n',
                      'UNLINK\r\n\r\nERROR\r\n','UNLINK   ERROR\r\n','link is not valid\r\nERROR\r\n','ERROR\r\n']) {
  for(let split=0;split<=reply.length;split++) {
   const r=run(reply,{split});
   assert(r.displayed&&!r.error,'LIST cleanup reaches display: '+JSON.stringify(reply)+' split '+split+' error '+r.error);
   assert(r.u.rx.length===0&&r.outgoing==='','consume each command terminal before next command');
   assert(r.commands.at(-1)==='AT+CIPRECVMODE=0\r\n','switch back to active mode');
  }
 }
 for(const reply of ['busy s...\r\n','busy p...\r\n','SEND FAIL\r\n']) {
  const r=run(reply);
  assert(r.error===43&&!r.displayed,'close rejection reported at close');
  assert(r.commands.length===1,'do not send next command after rejected close');
 }
 {
  const r=run('UNLINK\r\nERROR\r\n',{data:7});
  assert(r.error===43&&!r.displayed,'do not switch mode with unread data after rejected close');
 }
 return {checks};
}
if(typeof require!=='undefined'&&typeof module!=='undefined') {
 const fs=require('fs'),vm=require('vm');
 vm.runInThisContext(fs.readFileSync('tests/z80-directory.js','utf8'));
 const S={};for(const l of fs.readFileSync('directory-test.sym','utf8').split(/\r?\n/)) {
  const m=l.match(/^v[01]\.(\S+): EQU 0x([0-9A-F]+)/i);if(m)S[m[1]]=parseInt(m[2],16);
 }
 console.log(directoryCleanupRegression(makeCpu,fs.readFileSync('SARAH12BSDhgfx'),fs.readFileSync('WifiBios20_MB_EL.cod'),S));
}
