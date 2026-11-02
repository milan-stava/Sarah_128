// Real ESXDOS disk driver and local CFG/help readers, with only RST 8 modeled.
function esxdosLocalIoRegression(makeCpu,image,bios,S,bank6) {
 let checks=0;
 const assert=(v,s)=>{if(!v)throw Error(s);checks++;},stop={};
 const put=(m,p,n)=>{m[p]=n&255;m[p+1]=n>>8;},word=(m,p)=>m[p]|m[p+1]<<8;
 const str=(m,p)=>{let s='';while(m[p])s+=String.fromCharCode(m[p++]);return s;};
 const bytes=s=>Array.from(s,c=>c.charCodeAt(0)&255);
 if(S.cfg_esx_open==null)return {checks};
 for(const size of [0,1,17,16383,16384,16385,32768,65535,65536,131073]) {
  let read=0,requests=[],u;
  u=makeCpu([],bios,S,{image,hook(pc,r){
   if(pc===8){const service=r.m[r.stack[r.stack.length-1]++];
    if(service===S.F_FSTAT){for(let j=0;j<4;j++)r.m[r.ix+7+j]=(size/2**(8*j))&255;return {ret:true,carry:false};}
    assert(service===S.F_READ,'upload issues stat/read only');
    const n=Math.min(size-read,16384);assert(r.ix===0xc000&&r.bc===n,'read into mapped bank with exact remaining length');
    requests.push(n);for(let i=0;i<n;i++)r.m[r.ix+i]=((read+i)*37+11)&255;read+=n;return {ret:true,carry:false,bc:n};
   }
   if(pc===S.error_handler)throw Error('unexpected disk error');
  }});
  u.m[S.file_handle]=1;put(u.m,S.disk_buf_len,16384);
  const main=u.m.slice(0x6000,0x8000);
  let init=u.call(S.load_init);assert(init.carry===(size<=16384),'initial carry means first read is last');
  let consumed=0;
  function part(){const r=u.call(S.load_file),n=word(u.m,S.portion_len);assert(n===requests.at(-1),'portion is current read, not next request');for(let i=0;i<n;i++)assert(u.m[0xc000+i]===((consumed+i)*37+11&255),'ordered file bytes');consumed+=n;assert(r.carry===(size-consumed<=16384),'carry describes next read for the common upload loop');return r;}
  if(!init.carry){let r;do{r=part();}while(!r.carry);}
  part();
  assert(read===size&&consumed===size&&requests.length===Math.max(1,Math.ceil(size/16384)),'file read once without overrun or extra chunk');
  assert(word(u.m,S.rest_len)===0&&word(u.m,S.rest_len+2)===0,'32-bit remainder ends at zero');
  assert(main.every((v,i)=>v===u.m[0x6000+i]),'read never overwrites main program');
 }
 for(const failure of ['read','short-read','write','short-write']) {
  let closed=0,caught=false;const u=makeCpu([],bios,S,{image,hook(pc,r){
   if(pc===8){const service=r.m[r.stack[r.stack.length-1]++];if(service===S.F_CLOSE){closed++;return {ret:true,carry:false};}return {ret:true,carry:failure==='read'||failure==='write',bc:15};}
   if(pc===S.error_handler){assert((r.bc&255)===15,'disk failures reach existing handler');caught=true;throw stop;}
  }});
  u.m[S.file_handle]=1;put(u.m,S.lf2+1,16);put(u.m,S.sif2+1,16);
  try{u.call(failure.includes('read')?S.load_file:S.save_into_file);}catch(e){if(e!==stop)throw e;}
  assert(caught&&closed===1,'failed or short transfer closes file once');
 }
 for(const size of [1,16384,16385,32769]) {
  let written=0,opened=0;const u=makeCpu([],bios,S,{image,hook(pc,r){
   if(pc===8){const service=r.m[r.stack[r.stack.length-1]++];
    if(service===S.F_OPEN){opened++;assert((r.bc>>8)===14,'create/truncate includes write permission');return {ret:true,a:1,carry:false};}
    assert(service===S.F_WRITE&&r.ix===0xc000,'write from mapped download bank');
    const n=Math.min(16384,size-written);assert(r.bc===n,'write exact current portion');written+=n;return {ret:true,carry:false,bc:n};
   }
  }});
  put(u.m,S.disk_buf_len,16384);put(u.m,S.rest_len,size&65535);put(u.m,S.rest_len+2,0);u.m[S.DefaultDrive]=2;
  u.call(S.sfh_cont);put(u.m,S.sif1+2,0xc000);
  while(written<size){const after=Math.max(0,size-written-Math.min(16384,size-written));put(u.m,S.rest_len,after);u.call(S.save_into_file);}
  assert(opened===1&&written===size,'download file created and fully written');
 }
 const profile='Default=1\nName=ESX\nHost=ftp.test\nPort=2121\nUser=user\nPass=\nFile=GAME.TAP\nStart=24576\n';
 for(const size of [0,1,profile.length,1023,1024,1025,S.cfg_capacity,S.cfg_capacity+1,65536])for(const fail of ['none',...(size===profile.length?['drive','open','stat','read','short','close']:[])]) {
  let closes=0,reads=0,u;const ubytes=bytes(profile);
  u=makeCpu([],bios,S,{image,hook(pc,r){
   if(pc===8){const service=r.m[r.stack[r.stack.length-1]++];
    if(service===S.M_GETSETDRV)return {ret:true,a:2,carry:fail==='drive'};
    if(service===S.F_OPEN){assert(str(r.m,r.ix)==='sara.cfg'&&(r.bc>>8)===1,'local ASCIIZ CFG opened for reading');return {ret:true,a:4,carry:fail==='open'};}
    if(service===S.F_FSTAT){for(let j=0;j<4;j++)r.m[r.ix+7+j]=(size/2**(8*j))&255;return {ret:true,carry:fail==='stat'};}
    if(service===S.F_READ){reads++;assert(r.ix===S.cfg_file_here&&r.bc===size,'CFG reads exact length into free bank-6 workspace');r.m.fill(32,r.ix,r.ix+size);r.m.set(ubytes.slice(0,size),r.ix);return {ret:true,carry:fail==='read',bc:fail==='short'?size-1:size};}
    assert(service===S.F_CLOSE,'only local filesystem services used');closes++;return {ret:true,carry:fail==='close'};
   }
   if(pc===S.error_handler||pc===S.send_string)throw Error('local CFG read must fail quietly without FTP');
  }});u.m.set(bank6,0xc000);
  const before=u.m.slice(0xc000,S.cfg_file_here),r=u.call(S.cfg_read_file);
  const valid=size>0&&size<=S.cfg_capacity&&fail==='none';
  assert(r.carry!==valid,'CFG capacity and failure status');
  assert(closes===(fail==='drive'||fail==='open'?0:1),'local handle closed on each acquired-file path');
  assert(reads===(size>0&&size<=S.cfg_capacity&&!['drive','open','stat'].includes(fail)?1:0),'invalid size never writes bank-6 code');
  assert(before.every((v,i)=>v===u.m[0xc000+i]),'local read preserves bank-6 code/state preceding workspace');
  if(valid)assert(r.hl===S.cfg_file_here&&r.bc===size&&u.m[r.hl+size]===0,'reader returns bounded zero-terminated data');
 }
 // Full startup parser uses the same real ESXDOS reader.
 {
  const u=makeCpu([],bios,S,{image,hook(pc,r){if(pc!==8)return;const service=r.m[r.stack[r.stack.length-1]++];
   if(service===S.M_GETSETDRV)return {ret:true,a:2,carry:false};
   if(service===S.F_OPEN)return {ret:true,a:4,carry:false};
   if(service===S.F_FSTAT){for(let j=0;j<4;j++)r.m[r.ix+7+j]=(profile.length/2**(8*j))&255;return {ret:true,carry:false};}
   if(service===S.F_READ){r.m.set(bytes(profile),r.ix);return {ret:true,bc:profile.length,carry:false};}
   return {ret:true,carry:false};
  }});u.m.set(bank6,0xc000);const r=u.call(S.load_cfg);assert(!r.carry&&str(u.m,S.host_url)==='ftp.test'&&str(u.m,S.ftp_port)==='2121','ESXDOS startup applies configured default profile');
 }
 // The public K entry loads a local help file and returns to the prior bank.
 for(const missing of [false,true])for(const cached of [false,true]) {
  const help=bytes('Local help\r\nSecond line'),banks=Array.from({length:8},()=>new Uint8Array(16384));banks[6].set(bank6);
  let active=3,u,reads=0,closes=0,views=0,messages=0,redraws=0;
  u=makeCpu([],bios,S,{image,hook(pc,r){
   if(pc===S.PAGE128){banks[active].set(r.m.slice(0xc000));active=r.a&7;r.m.set(banks[active],0xc000);r.m[S.PAGE128_STATE]=16+active;return {ret:true,a:16+active};}
   if(pc===8){const service=r.m[r.stack[r.stack.length-1]++];
    if(service===S.M_GETSETDRV)return {ret:true,a:2,carry:false};
    if(service===S.F_OPEN){assert(str(r.m,r.ix)==='sara.hlp','K opens local ASCIIZ help name');return {ret:true,a:4,carry:missing};}
    if(service===S.F_FSTAT){for(let j=0;j<4;j++)r.m[r.ix+7+j]=(help.length/2**(8*j))&255;return {ret:true,carry:false};}
    if(service===S.F_READ){reads++;r.m.set(help,r.ix);return {ret:true,bc:help.length,carry:false};}
    assert(service===S.F_CLOSE,'help only uses local file services');closes++;return {ret:true,carry:false};
   }
   if(pc===S.text_browse){views++;assert(active===6&&word(r.m,S.text_local_base)===S.cfg_file_here&&word(r.m,S.text_length)===help.length,'viewer receives direct local help in bank 6');return {ret:true};}
   if(pc===S.pts){messages++;assert(missing,'missing message only for absent help');return {ret:true};}
   if([S.cls_4000,S.print_screen_layout,S.print_title].includes(pc))return {ret:true};
   if(pc===S['resume_directory_screen.cached']){redraws++;assert(active===3,'directory redraw after original-bank restoration');return {ret:true};}
   if(pc===S.send_string||pc===S.directory_retrieve)throw Error('local help must not perform FTP');
  }});u.m.set(banks[3],0xc000);u.m[S.PAGE128_STATE]=19;u.m[S.flag_dir]=cached?1:0;
  const r=u.call(S.help_show);assert(r.a===0&&r.ix===S.flag1&&active===3,'K balances stack and restores context');
  assert(reads===(missing?0:1)&&closes===reads&&views===reads&&messages===(missing?1:0),'K loads/views/closes or reports missing help');
  assert(redraws===(cached?1:0),'cached view is redrawn only when valid');
 }
 return {checks};
}
if(typeof require!=='undefined'&&typeof module!=='undefined') {
 const fs=require('fs'),vm=require('vm'),esx=process.argv[2]==='esx',S={};vm.runInThisContext(fs.readFileSync('tests/z80-directory.js','utf8'));
 for(const m of fs.readFileSync(esx?'directory-esx-test.sym':'directory-test.sym','utf8').matchAll(/^v[01]\.(\S+): EQU 0x([0-9A-F]+)/gmi))S[m[1]]=parseInt(m[2],16);
 const tape=fs.readFileSync(esx?'SARA_ESX_LOADER.tap':'SARA_LOADER.tap'),blocks=[];for(let p=0;p<tape.length;){const n=tape[p]|tape[p+1]<<8;p+=2;blocks.push(tape.subarray(p+1,p+n-1));p+=n;}
 console.log(esxdosLocalIoRegression(makeCpu,blocks[3],fs.readFileSync('WifiBios20_MB_EL.cod'),S,blocks[5]));
}
