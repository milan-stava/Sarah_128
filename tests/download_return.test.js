// Real snapshot/return assembly; network, disk and drawing are simulated.
function downloadReturnRegression(makeCpu,image,bios,S) {
 let checks=0;
 const assert=(v,s)=>{if(!v)throw Error(s);checks++;};
 const word=(m,p)=>m[p]|m[p+1]<<8;
 const put=(m,p,v)=>{m[p]=v&255;m[p+1]=v>>8;};
 const fields=['cur_item_addr','cur_item_addr_page','item_pg_start','item_pg_start_page','cursor_w_curad'];
 const values=[0xc321,S.ftp_dir_page+3,0xff80,S.ftp_dir_page+1,0x4900];
 for(const entry of ['ftp_download_file_dir','ftp_download_file_new','ftp_download_file_var']) {
  let rendered=false,reads=0,u;
  u=makeCpu([],bios,S,{image,hook:(pc,r)=>{
   if([S.send_type_command_i,S.set_3_5mhz,S.passive_receive_off,S.print_transfer_status,S.unmark_all,S.wifi_unwait,S.prn_mark_items,S.draw_cursor].includes(pc))return {ret:true};
   if([S.fdfd1,S.ftp_download_file_new1,S.ftp_download_file_var1].includes(pc)){
    fields.forEach(x=>put(r.m,S[x],0x5555));r.m[S.wind_curs_item]=0x55;return {ret:true};
   }
   if(pc===S.print_page){rendered=true;fields.forEach((x,i)=>assert(word(r.m,S[x])===values[i],'restored '+x+' via '+entry));assert(r.m[S.wind_curs_item]===5,'cursor row restored');return {ret:true};}
   if(pc===S.directory_retrieve){reads++;return {ret:true};}
  }});
  u.m[S.flag1]=32;u.m[S.flag_dir]=1;put(u.m,S.mark_counter,0);put(u.m,S.dir_list_pointer,S.dir_list_start+9);
  fields.forEach((x,i)=>put(u.m,S[x],values[i]));u.m[S.wind_curs_item]=5;
  u.call(S[entry]);assert(rendered&&reads===0,'cached view redrawn without directory transfer');
  assert(word(u.m,S.dir_list_pointer)===S.dir_list_start+9,'history untouched');
 }
 {
  const stop={},u=makeCpu([],bios,S,{image,hook:(pc,r)=>{
   if(pc===S.send_type_command_i)return {ret:true};
   if(pc===S.ldir_names)throw stop;
  }});u.m[S.flag1]=32;put(u.m,S.mark_counter,2);put(u.m,S.cur_item_addr,0xc456);
  try{u.call(S.ftp_download_file_dir);}catch(e){if(e!==stop)throw e;}
  assert(word(u.m,S.cur_item_adr_tmp)===0xc456,'bulk snapshot taken before directory scan');
 }
 {
  let reads=0;const u=makeCpu([],bios,S,{image,hook:(pc,r)=>{
   if(pc===S.print_transfer_status)return {ret:true};
   if(pc===S.directory_retrieve){reads++;return {ret:true};}
   if(pc===S.unmark_all||pc===S.dir_move5)throw Error('invalid view accessed');
  }});u.m[S.flag_dir]=0;u.call(S.fdfm4);assert(reads===1,'missing cached directory reloads instead of using invalid pointers');
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
 console.log(downloadReturnRegression(makeCpu,image,fs.readFileSync('WifiBios20_MB_EL.cod'),S));
}
