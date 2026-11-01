// Execute public actions and the real keyboard dispatcher with stale/absent FTP state.
function actionGuardsRegression(makeCpu,image,bios,S) {
 let checks=0;
 const assert=(ok,s)=>{if(!ok)throw Error(s);checks++;},stop={};
 const word=(m,p,v)=>{m[p]=v&255;m[p+1]=v>>8;};
 const entries={
  ftp_upload_file:'ftp',ftp_quit_connection:'ftp',ftp_file_size:'ftp',
  ftp_download_file_var:'ftp',ftp_download_file_new:'ftp',
  directory_retrieve:'ftp',create_dir:'ftp',go_updir:'ftp',
  ftp_download_file_dir:'item',ftp_download_file_under_cursor:'item',
  enter_directory:'item',rename_item_file:'item',delete_item_file:'item',
  view_as_text:'item',enter_command:'control'
 };
 const effects=['print_ez1','clear_inp_buf','send_type_command_i','send_type_command_a',
  'send_ftp_command','send_string','input_line','get_item_name','DIR128_CUR_ATTR_HL',
  'cls_9','save_dir_position_snapshot','passive_receive_off','print_transfer_status'];
 for(const [entry,kind] of Object.entries(entries))for(const login of [false,true])for(const directory of [false,true])for(const closed of [0,1,2,3])for(const status of [51,52]) {
  const allowed=!(closed&1)&&(kind==='control'?status===51:login&&(kind!=='item'||directory));
  let reached=false;const cpu=makeCpu([],bios,S,{image,hook(pc){
   if(effects.some(n=>S[n]===pc)){reached=true;throw stop;}
   if(pc===S.error_handler||pc===S.error_handler_loop)throw Error('guard entered error handler');
  }});
  cpu.m[S.flag1]=login?32:0;cpu.m[S.flag_dir]=directory?1:0;cpu.m[S.at_closed]=closed;cpu.m[S.status_byte]=status;
  cpu.m.fill(0xa5,S.INPBUFF,S.INPBUFF+256);word(cpu.m,S.cur_item_addr,0x5555);word(cpu.m,S.cur_item_addr_page,0x5555);
  let result;try{result=cpu.call(S[entry],{a:122,bc:0x1234,de:0x4567,hl:0x5555});}catch(e){if(e!==stop)throw e;}
  assert(reached===allowed,entry+' permission '+[login,directory,closed,status]);
  if(!allowed){
   assert(result&&result.a===(entry==='ftp_download_file_under_cursor'?2:0),'rejected action consumes key / preserves transfer failure');
   assert(result.bc===0x1234&&result.de===0x4567&&result.hl===0x5555&&result.ix===S.flag1,'rejection preserves input registers');
   assert(cpu.m.slice(S.INPBUFF,S.INPBUFF+256).every(v=>v===0xa5),'rejection leaves filename/input intact');
  }
 }
 // No cached directory: cursor erasure must never dereference a poisoned pointer.
 {
  const cpu=makeCpu([],bios,S,{image,hook(pc){if(pc===S.DIR128_CUR_ATTR_HL)throw Error('invalid cursor pointer read');}});
  cpu.m[S.flag_dir]=0;word(cpu.m,S.cur_item_addr,0x5555);cpu.call(S.undraw_cursor);checks++;
 }
 // Rejected keys continue to idle with a balanced stack and without any command/UI.
 for(const key of [117,111,115,100,68,92,114,55,99,13,1,12,54,122])for(const directory of [false,true]) {
  let scans=0,cpu;
  cpu=makeCpu([],bios,S,{image,hook(pc,r){
   if(pc===S.KEYSCAN||pc===S.tap_options_keyboard){if(scans++){assert(r.stack.length===2&&r.ix===S.flag1,'rejected key returns to main keyboard');throw stop;}return {ret:true,a:key};}
   if(effects.some(n=>S[n]===pc)||pc===S.error_handler)throw Error('offline key produced an action '+key);
   if(pc===S.rece_byte||pc===0xe0d7)return {ret:true,z:true};
  }});cpu.m[S.flag1]=0;cpu.m[S.flag_dir]=directory?1:0;cpu.m[S.status_byte]=52;cpu.m[S.at_closed]=1;
  word(cpu.m,S.cur_item_addr,0x5555);word(cpu.m,S.cur_item_addr_page,0x5555);
  try{cpu.call(S.key_loop);}catch(e){if(e!==stop)throw e;}
  assert(scans===2,'offline key safely ignored '+key);
 }
 // New-directory dispatch is available before LIST; memory actions remain offline.
 for(const [key,target] of [[55,'create_dir'],[11,'key_up'],[10,'key_down'],[32,'mark_item'],[77,'mark_all'],[46,'unmark_all'],[105,'find_items'],[120,'roll_item']]) {
  let reached=false;const cpu=makeCpu([],bios,S,{image,hook(pc){
   if(pc===S.KEYSCAN||pc===S.tap_options_keyboard)return {ret:true,a:key};
   if(pc===S[target]){reached=true;throw stop;}
   if(pc===S.send_string)throw Error('unexpected FTP on cached operation');
  }});cpu.m[S.flag1]=key===55?32:0;cpu.m[S.flag_dir]=key===55?0:1;cpu.m[S.at_closed]=0;
  try{cpu.call(S.key_loop);}catch(e){if(e!==stop)throw e;}
  assert(reached,'keyboard dispatch '+target);
 }
 return {checks};
}
if(typeof require!=='undefined'&&typeof module!=='undefined') {
 const fs=require('fs'),vm=require('vm');
 vm.runInThisContext(fs.readFileSync('tests/z80-directory.js','utf8'));
 const esx=process.argv[2]==='esx',S={};
 for(const m of fs.readFileSync(esx?'directory-esx-test.sym':'directory-test.sym','utf8').matchAll(/^v[01]\.(\S+): EQU 0x([0-9A-F]+)/gmi))S[m[1]]=parseInt(m[2],16);
 const tape=fs.readFileSync(esx?'SARA_ESX_LOADER.tap':'SARA_LOADER.tap'),blocks=[];
 for(let p=0;p<tape.length;){const n=tape[p]|tape[p+1]<<8;p+=2;blocks.push(tape.subarray(p+1,p+n-1));p+=n;}
 console.log(actionGuardsRegression(makeCpu,blocks[3],fs.readFileSync('WifiBios20_MB_EL.cod'),S));
}
