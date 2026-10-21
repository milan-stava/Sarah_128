// Assembled BSDOS startup/quit control flow; network and drawing are stubbed.
function startupResumeRegression(makeCpuBase,image,bios,S) {
 const makeCpu=(code,bios,S,options)=>makeCpuBase(code,bios,S,{...options,hook:(pc,r)=>{
  if(pc===S.PAGE128){r.m[S.PAGE128_STATE]=(r.a&7)|16;return {ret:true,a:(r.a&7)|16};}
  return options.hook?.(pc,r);
 }});
 let checks=0;
 const assert=(v,s)=>{if(!v)throw Error(s);checks++;};
 const stop={},drawNames=['PRINTHL','prn_w_onoff','prn_alogin','prn_lst_nlst_abbr_ful','prn_file_start','prn_host_usr_psw','print_title','print_working_directory','print_dir_files_items','print_page','prn_mark_items','draw_cursor'];
 const ptrs=['cur_item_addr','cur_item_addr_page','item_pg_start','item_pg_start_page','cursor_w_curad','dir_list_pointer'];
 for(const valid of [false,true,'corrupt']) {
  let events=[],u;
  u=makeCpu([],bios,S,{image,hook:(pc,r)=>{
   if(pc===S.get_status_ftp){events.push('status');return {ret:true,z:true};}
   if(pc===S.directory_retrieve){events.push('retrieve');return {ret:true};}
   if(pc===S.key_loop)throw stop;
   const name=drawNames.find(x=>pc===S[x]);if(name){events.push(name);return {ret:true};}
  }});
  u.m[S.flag_dir]=valid?1:0;
  for(let i=0;i<ptrs.length;i++){u.m[S[ptrs[i]]]=i+10;u.m[S[ptrs[i]]+1]=0x80;}
  if(valid)u.call(S.save_dir_cache_checksum);
  if(valid==='corrupt')u.m[0xc000]^=1;
  const before=ptrs.map(x=>u.m[S[x]]|u.m[S[x]+1]<<8);
  u.call(S.print_start_screen);
  assert(!events.includes('print_working_directory'),'startup does not send premature PWD');
  events=[];
  try{u.call(S.kl5);}catch(e){if(e!==stop)throw e;}
  if(valid===true){
   assert(events[0]==='status'&&events.includes('print_working_directory'),'connection checked before PWD');
   assert(events.includes('print_page')&&events.includes('draw_cursor')&&events.includes('print_dir_files_items'),'cached items, cursor and counts redrawn');
   assert(!events.includes('retrieve'),'cached directory not reloaded');
   assert(ptrs.every((x,i)=>(u.m[S[x]]|u.m[S[x]+1]<<8)===before[i]),'view and history pointers preserved');
  }else assert(events.includes('retrieve')&&!events.includes('print_page'),'missing cache requests fresh listing');
 }
 for(const wifiOn of [false,true]) {
  let u=makeCpu([],bios,S,{image,hook:(pc,r)=>{
   if(pc===S.set_def_wifi_speed||pc===S.wifi_off)return {ret:true};
   if(pc===S.return_speed)throw stop;
  }});
  u.m[S.flag1]=wifiOn?8:0;u.m[S.flag_dir]=1;
  try{u.call(S.quit_program);}catch(e){if(e!==stop)throw e;}
  assert(!!(u.m[S.flag_dir]&1)===wifiOn,'Q cache validity follows Wi-Fi retention');
 }
 {
  const u=makeCpu([],bios,S,{image,hook:(pc,r)=>{
   if(pc===S.get_status_ftp)return {ret:true,z:false,a:52};
   if(pc===S.kl3)throw stop;
  }});u.m[S.flag_dir]=1;
  try{u.call(S.kl5);}catch(e){if(e!==stop)throw e;}
  assert(!(u.m[S.flag_dir]&1),'lost connection invalidates cache before reconnect');
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
 console.log(startupResumeRegression(makeCpu,image,fs.readFileSync('WifiBios20_MB_EL.cod'),S));
}
