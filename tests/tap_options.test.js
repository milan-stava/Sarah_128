// Actual BS-DOS TAP menu, flag changes, post-extraction branching and return.
// Physical paging/keyboard/disk/drawing are modeled; no real files are deleted.
function tapOptionsRegression(makeCpu,image,bios,S,bank6) {
 let checks=0;
 const assert=(v,msg)=>{if(!v)throw Error(msg);checks++;},stop={};
 const word=(m,p)=>m[p]|m[p+1]<<8,put=(m,p,n)=>{m[p]=n&255;m[p+1]=n>>8;};
 if(S.tap_options_keyboard==null) {
  assert(S.tap_return==null&&S.tap_options_keyboard_bank==null,'ESXDOS has no TAP switches or deletion path');
  return {checks};
 }
 assert(image[S.key_loop-0x6000]===0xcd&&word(image,S.key_loop-0x6000+1)===S.tap_options_keyboard,'main keyboard calls the TAP wrapper');
 for(const flags of [0,0x20,0x40,0x60,0x9f,0xff]) {
  const banks=Array.from({length:8},()=>new Uint8Array(16384));banks[6].set(bank6);
  let active=3,key=0,cpu,draws=0,clears=0,lastText='';
  cpu=makeCpu([],bios,S,{image,hook(pc,r){
   if(pc===S.PAGE128){banks[active].set(r.m.slice(0xc000));active=r.a&7;r.m.set(banks[active],0xc000);r.m[S.PAGE128_STATE]=16+active;return {ret:true,a:16+active};}
   if(pc===S.KEYSCAN){assert(active===6,'keyboard code is in bank 6');return {ret:true,a:key};}
   if(pc===S.PRINTHL){
    assert(active===6&&r.hl===S.txt_adr_edit_zone1,'options use second row from bottom');
    lastText='';for(let p=r.de;r.m[p];p++)lastText+=String.fromCharCode(r.m[p]);
    assert(lastText.length<=64,'menu fits one row');draws++;return {ret:true};
   }
   if(pc===S.clear_edit_zone){assert(active===6,'clear returns safely to bank 6');clears++;return {ret:true};}
  }});
  cpu.m.set(banks[3],0xc000);cpu.m[S.PAGE128_STATE]=19;cpu.m[S.flag2]=flags;
  put(cpu.m,S.fdp_pointer,S.ftp_dir_page+2);
  function press(code){key=code;const r=cpu.call(S.tap_options_keyboard);assert(active===3&&word(cpu.m,S.fdp_pointer)===S.ftp_dir_page+2,'old bank and directory pointer preserved');return r;}
  press(0);assert(lastText==='TAP: SS+T Delete='+((flags&32)?'Y':'N')+'  CS+T Run='+((flags&64)?'N':'Y'),'default visible flags');
  press(0);assert(draws===1&&clears===1,'idle polling does not repaint continuously');
  assert(press(62).a===0&&cpu.m[S.flag2]===(flags^32),'SS+T changes only deletion and consumes key');
  press(0);assert(lastText.includes('Delete='+((flags&32)?'N':'Y')),'deletion label refreshed');
  assert(press(84).a===0&&cpu.m[S.flag2]===(flags^96),'CS+T changes only stay/run and consumes key');
  press(0);assert(lastText.endsWith('Run='+((flags&64)?'Y':'N')),'Run label is inverse of stay bit');
  assert(press(116).a===116&&cpu.m[S.flag2]===(flags^96),'plain T remains start-address key');
  assert(press(13).a===13,'ENTER remains an ordinary main-loop key');
  assert(clears===8,'actions release input rows and idle menu removes stale progress');
 }
 const source=bank6.slice(S.tapmaster_start-0xc000,S.tapmaster_start-0xc000+S.tapmaster_len);
 for(const flags of [0,32,64,96,0x9f,0xff]) {
  let deleted=0,launched=0,stayed=0,cpu;
  cpu=makeCpu([],bios,S,{image,hook(pc,r){
   if(pc===0x20){
    if(r.a===0x28){assert(r.bc===321,'delete targets original downloaded TAP');deleted++;return {ret:true};}
    assert(r.a===0x16,'only first extracted file is inspected before Run');
    r.m[S.seq_buff]=0x80;return {ret:true};
   }
   if(pc===S.run1){launched++;throw stop;}
   if(pc===S.tap_return){stayed++;throw stop;}
  }});
  cpu.m.set(source,0x4000);cpu.m[S.flag2]=flags;cpu.m[S.del_tap+1]=flags&32;
  put(cpu.m,S.input_file,321);put(cpu.m,S.first_free,400);
  try{cpu.call(S.del_tap);throw Error('no finish branch');}catch(e){if(e!==stop)throw e;}
  assert(deleted===((flags&32)?1:0),'deletion independent of Run');
  assert(launched===((flags&64)?0:1)&&stayed===((flags&64)?1:0),'stay and launch are mutually exclusive');
 }
 // Execute the real return even after directory bank 0 and the old stack have
 // been used by extraction. UI/retrieval endpoints validate ordering and IX.
 for(const connected of [false,true]) {
  const events=[];let cpu;
  cpu=makeCpu([],bios,S,{image,onOut(port,a){assert((port&255)===23&&a===0x40,'restore normal BS-DOS ROM mapping');events.push('rom');},hook(pc,r){
   if(pc===S.set_3_5mhz){events.push('speed');assert(r.ix===S.flag1,'restore IX before Sarah routines');return {ret:true};}
   if(pc===S.print_whole_screen){assert(!(r.m[S.flag_dir]&1),'invalidate overwritten directory before drawing');assert(r.stack[r.stack.length-2]===S.error_handler_loop,'restore main error return on rebuilt stack');events.push('ui');return {ret:true};}
   if(pc===S.directory_retrieve){assert(word(r.m,S.dir_restore_item)===73&&r.m[S.dir_restore_row]===5,'saved directory view remains available for reload');events.push('list');return {ret:true};}
   if(pc===S.initsp_keyloop){events.push('keys');throw stop;}
  }});
  cpu.m.fill(0xa5,0xc000);cpu.m[S.flag1]=connected?32:0;cpu.m[S.flag_dir]=0x19;
  put(cpu.m,S.dir_restore_item,73);cpu.m[S.dir_restore_row]=5;
  try{cpu.call(S.tap_return);throw Error('return did not reach keyboard');}catch(e){if(e!==stop)throw e;}
  assert(events.join(',')==='rom,speed,ui,list,keys','return restores environment before loading directory');
 }
 return {checks};
}
if(typeof require!=='undefined'&&typeof module!=='undefined') {
 const fs=require('fs'),vm=require('vm'),esx=process.argv[2]==='esx',S={};
 vm.runInThisContext(fs.readFileSync('tests/z80-directory.js','utf8'));
 for(const m of fs.readFileSync(esx?'directory-esx-test.sym':'directory-test.sym','utf8').matchAll(/^v[01]\.(\S+): EQU 0x([0-9A-F]+)/gmi))S[m[1]]=parseInt(m[2],16);
 const tape=fs.readFileSync(esx?'SARA_ESX_LOADER.tap':'SARA_LOADER.tap'),blocks=[];
 for(let p=0;p<tape.length;){const n=tape[p]|tape[p+1]<<8;p+=2;blocks.push(tape.subarray(p+1,p+n-1));p+=n;}
 console.log(tapOptionsRegression(makeCpu,blocks[3],fs.readFileSync('WifiBios20_MB_EL.cod'),S,blocks[5]));
}
