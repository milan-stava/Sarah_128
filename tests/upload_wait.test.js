// Execute upload waits with real byte reads and gaps longer than legacy buffer reads.
function uploadWaitRegression(makeCpu,image,bios,S) {
 let checks=0;
 const assert=(ok,msg)=>{if(!ok)throw Error(msg);checks++;};
 const bytes=s=>Array.from(s,c=>c.charCodeAt(0)),stop={};
 function run({prompt=false,reply='',gap=0,split=0,failure=false}={}) {
  let abort=0,drains=0,error=0,polls=0;
  const u=makeCpu([],bios,S,{image,onPoll(n){polls=n;if(n>3000000)throw Error('wait ignored cancellation/terminal');},hook(pc,r){
   if(pc===S.clear_rece_buf){drains++;return {ret:true};}
   if(pc===S.inkey)return {ret:true,a:failure==='cancel'&&polls>=600000?98:0};
   if(pc===S.set_7mhz||pc===S.set_20mhz)return {ret:true,a:3,z:false,carry:true,bc:0x793b,hl:(r.hl&0xff00)|0x30};
   if(pc===S.error_handler){error=r.bc&255;throw stop;}
   if(pc===S.ful_abort){abort=r.bc&255;throw stop;}
  }});

  const input=bytes(reply);input.splice(split,0,...Array(gap).fill(null));
  u.rx.push(...input,...bytes(failure?'':'NEXT'));
  let result;
  try{result=u.call(prompt?S.check_module_answer:S.fus1,{hl:S.char_zob});}catch(e){if(e!==stop)throw e;}
  if(failure==='cancel')assert(abort===20&&error===0,'missing/partial ACK waits until B');
  else if(failure==='timeout')assert(error===48,'missing command prompt has bounded transport timeout');
  else if(prompt)assert(!!result.carry===!!failure,'prompt accepts or rejects complete AT event');
  else assert(abort===(failure?8:0),'SEND OK success or explicit rejection');
  assert(drains===0,'never drain following UART bytes');
  if(!failure)assert(String.fromCharCode(...u.rx.filter(x=>x!==null)).endsWith('NEXT'),'next message stays unread');
  if(!prompt)assert(u.m[S.upload_last_event]===(failure==='cancel'?0:failure==='fail'?5:failure==='busy'?6:4),'last AT event retained');
  return u;
 }
 const response='Recv 2048 bytes\r\nSEND OK\r\n';
 for(let split=0;split<=response.length;split++)run({reply:response,split,gap:1800});
 for(const response of ['\r\nOK\r\n> ','>','OK\r\n>'])for(let split=0;split<=response.length;split++)run({prompt:true,reply:response,split,gap:1800});
 for(const reply of ['', 'SEND O'])run({reply,failure:'cancel'});
 run({reply:'SEND FAIL\r\n',failure:'fail'});run({reply:'busy s...\r\n',failure:'busy'});
 for(const reply of ['', 'OK\r\n'])run({prompt:true,reply,failure:'timeout'});
 for(const reply of ['ERROR\r\n', 'busy s...\r\n'])run({prompt:true,reply,failure:'reject'});
 // Generic command callers still require a complete OK event.
 for(const [name,reply]of [['ok','OK\r\n']]) {
  const u=makeCpu([],bios,S,{image});u.rx.push(...bytes(reply+'NEXT'));
  assert(!u.call(S.check_module_answer,{hl:S[name]}).carry,'requested terminal '+name);
  assert(String.fromCharCode(...u.rx)==='NEXT','no flush after '+name);
 }
 // Actual BIOS byte sends: preserve payload and honor UART backpressure.
 for(const length of [0,1,2048])for(const hold of [0,4,64]) {
  const payload=Array.from({length},(_,i)=>i*37&255);
  const u=makeCpu([],bios,S,{image,speed:1,txHoldPolls:hold,checkTxReady:true});
  u.m.set(payload,0x5000);
  const r=u.call(S.send_data,{hl:0x5000,bc:length});
  assert(r.z&&r.bc===0&&r.hl===0x5000+length,'all bytes handed to UART in order');
  assert(u.sent.length===length&&u.sent.every((v,i)=>v===payload[i]),'binary bytes survive UART busy intervals');
 }
 {
  const u=makeCpu([],bios,S,{image,speed:1,txStuckAt:4,checkTxReady:true});
  u.m.set(Array.from({length:16},(_,i)=>i),0x5000);
  const r=u.call(S.send_data,{hl:0x5000,bc:16});
  assert(!r.z&&r.bc===12&&r.hl===0x5004&&u.sent.length===4,'stuck UART never reports a partial block as complete');
 }
 // BS-DOS multi-bank loop through normal CIPCLOSE/226 and directory refresh.
 if(S.cfg_read_file!==undefined)for(const total of [32768,307201])for(const early226 of [false,true]) {
  let u,loaded=0,sent=0,portionStart=0,closed=false,refreshed=false,command='',blocks=0,speed=7,delayedAck=0,pausedReads=0,guardLoops=0;
  const str=(m,p)=>{let s='';while(m[p])s+=String.fromCharCode(m[p++]);return s;};
  const put=(m,p,v)=>{m[p]=v&255;m[p+1]=v>>8;};
  u=makeCpu([],bios,S,{image,hook(pc,r){
   // The CPU model's BIOS mirror is at #E000, inside the simulated 16KB data
   // buffer. Model its byte endpoint here; standalone cases above run real BIOS.
   if(pc===0xe0d7){
    if(delayedAck){delayedAck--;pausedReads++;return {ret:true,z:true};}
    const next=u.rx.shift();return next==null?{ret:true,z:true}:{ret:true,z:false,a:next};
   }
   if(pc===S.set_20mhz||pc===S.set_7mhz||pc===S.set_3_5mhz){speed=pc===S.set_20mhz?20:pc===S.set_7mhz?7:3.5;return {ret:true,a:3,z:false,carry:true,bc:0x793b,hl:(r.hl&0xff00)|0x30};}
   if([S.ful_abort,S.error_handler].includes(pc))throw Error('long upload error '+(r.bc&255));
   if(pc===S.display_progress||pc===S.print_ftp_message)return {ret:true};
   if(pc===S.at_wait_send||pc===S.check_module_answer)assert(speed===20,'AT confirmations read at 20 MHz');
   if(pc===S.upl_tx_start_wait){if(!guardLoops)assert(speed===7,'post-prompt guard runs at 7 MHz');guardLoops++;}

   if(pc===S.load_file){
    const n=Math.min(16384,total-loaded);assert(n>0,'no extra disk read');portionStart=loaded;loaded+=n;
    put(r.m,S.portion_len,n);for(let i=0;i<n;i++)r.m[0xc000+i]=(portionStart+i)*37&255;
    return {ret:true,carry:total-loaded<=16384};
   }
   if(pc===S.send_string){
    command+=str(r.m,r.hl);
    if(command.endsWith('\r\n')) {
     if(/^AT\+CIPSEND=1,[0-9]+\r\n$/.test(command)) {
      blocks++;u.rx.push(...bytes('\r\nOK'),...Array(1800).fill(null),...bytes('\r\n> '));
     } else if(command==='AT+CIPCLOSE=1\r\n') {
      assert(sent===total,'close only after complete file');closed=true;
      const reply='226 Transfer OK\r\n',frame='+IPD,0,'+reply.length+':'+reply;
      u.rx.push(...bytes(early226?frame+'1,CLOSED\r\nOK\r\n':'1,CLOSED\r\nOK\r\n'+frame));
     } else throw Error('unexpected long-upload command '+command);
     command='';
    }
    return {ret:true,z:true};
   }
   if(pc===S.send_data){
    assert(speed===7,'binary transmission runs at 7 MHz');
    assert(guardLoops===0x1500,'every block retains about 20 ms after its prompt');guardLoops=0;
    assert(r.hl===0xc000+sent-portionStart,'buffer pointer across 16KB portions');
    assert(r.bc>0&&r.bc<=2048,'bounded data chunk');
    for(let i=0;i<r.bc;i++)if(r.m[r.hl+i]!==((sent+i)*37&255))throw Error('wrong disk payload');
    sent+=r.bc;u.rx.push(...bytes('Recv '+r.bc+' bytes\r\nSEND O'),...Array(1800).fill(null),...bytes('K\r\n'));
    if(total===32768&&!early226&&blocks===5)delayedAck=2200000;
    return {ret:true,z:true,bc:0,hl:(r.hl+r.bc)&65535};
   }
   if(pc===S.KEYSCAN||pc===S.inkey)return {ret:true,a:0};
   if(pc===S.directory_retrieve){assert(closed&&speed===3.5,'refresh after confirmed close at normal speed');refreshed=true;return {ret:true};}
  }});
  u.call(S.ftp_upl_loop);
  assert(sent===total&&loaded===total&&refreshed,'entire long upload reaches directory refresh');
  assert(blocks===Math.ceil(total/2048)&&u.rx.length===0,'all data confirmations and final 226 consumed');
  if(total===32768&&!early226)assert(pausedReads===2200000,'whole upload resumes after a long pause without replay');
 }
 return {checks};
}
if(typeof require!=='undefined'&&typeof module!=='undefined') {
 const fs=require('fs'),vm=require('vm'),esx=process.argv[2]==='esx',S={};
 vm.runInThisContext(fs.readFileSync('tests/z80-directory.js','utf8'));
 for(const m of fs.readFileSync(esx?'directory-esx-test.sym':'directory-test.sym','utf8').matchAll(/^v[01]\.(\S+): EQU 0x([0-9A-F]+)/gmi))S[m[1]]=parseInt(m[2],16);
 const tape=fs.readFileSync(esx?'SARA_ESX_LOADER.tap':'SARA_LOADER.tap'),blocks=[];
 for(let p=0;p<tape.length;){const n=tape[p]|tape[p+1]<<8;p+=2;blocks.push(tape.subarray(p+1,p+n-1));p+=n;}
 console.log(uploadWaitRegression(makeCpu,blocks[3],fs.readFileSync('WifiBios20_MB_EL.cod'),S));
}
