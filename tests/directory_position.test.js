// Runs assembled history/view code; item traversal and drawing are simulated.
function directoryPositionRegression(makeCpu,image,bios,S) {
 let checks=0;
 const assert=(v,s)=>{if(!v)throw Error(s);checks++;};
 const word=(m,p)=>m[p]|m[p+1]<<8;
 const put=(m,p,v)=>{m[p]=v&255;m[p+1]=v>>8;};
 let count=500,u,reply=200;
 const index=(m,p,page)=>((word(m,page)-(S.ftp_dir_page+1))/2)*100+(word(m,p)-0xc000)/16;
 const ptr=(m,p,page,n)=>{put(m,p,0xc000+(n%100)*16);put(m,page,S.ftp_dir_page+1+2*Math.floor(n/100));};
 u=makeCpu([],bios,S,{image,hook:(pc,r)=>{
  if(pc===S.send_ftp_command)return {ret:true,carry:reply!==200,hl:reply};
  if(pc===S.undraw_cursor||pc===S.directory_retrieve)return {ret:true};
  if(pc===S.DIR128_MAP_DE)return {ret:true};
  if(pc===S.DIR128_FIRST_PAGE){put(r.m,S.fdp_pointer,S.ftp_dir_page+1);return {ret:true};}
  if(pc===S.item_add||pc===S.item_sub){let n=index(r.m,r.bc,r.de),next=n+(pc===S.item_add?1:-1);if(next<0||next>=count)return {ret:true,z:true};ptr(r.m,r.bc,r.de,next);return {ret:true,z:false};}
  if(pc===S.dir_move_draw)return {ret:true};
 }});
 const m=u.m;put(m,S.dir_list_pointer,S.dir_list_start);m[S.AP_a_page]=8;put(m,S.cursor_w_stadr,0x5800);
 const save=(n,row)=>{ptr(m,S.cur_item_addr,S.cur_item_addr_page,n);m[S.wind_curs_item]=row;u.call(S.save_dir_position);};
 const restore=()=>{m[S.flag_dir]&=~64;u.call(S.ed3);u.call(S.dir_move);};
 save(234,6);save(112,3);
 const before=word(m,S.dir_list_pointer);
 u.call(S.dir_move);assert(word(m,S.dir_list_pointer)===before,'refresh never pops history');
 m[S.flag_dir]&=~64;reply=550;u.call(S.ed3);assert(word(m,S.dir_list_pointer)===before,'failed CDUP never pops');
 reply=200;restore();assert(index(m,S.cur_item_addr,S.cur_item_addr_page)===112,'nested child selected');assert(index(m,S.item_pg_start,S.item_pg_start_page)===110,'nested child page');
 restore();assert(index(m,S.cur_item_addr,S.cur_item_addr_page)===234,'parent across bank');assert(m[S.wind_curs_item]===6&&word(m,S.cursor_w_curad)===0x58a0,'cursor restored');assert(word(m,S.dir_list_pointer)===S.dir_list_start,'history popped');
 save(234,8);count=3;restore();assert(index(m,S.cur_item_addr,S.cur_item_addr_page)===2,'shorter listing clamps');assert(m[S.wind_curs_item]===3,'row clamps at directory start');
 const after=word(m,S.dir_list_pointer);u.call(S.dir_move);assert(word(m,S.dir_list_pointer)===after,'second refresh never pops');
 assert(word(m,S.dir_restore_item)===0,'prepared position consumed once');
 // CDUP succeeded, but the directory read was interrupted before dir_move.
 count=500;save(123,4);m[S.flag_dir]&=~64;reply=200;u.call(S.ed3);
 assert(word(m,S.dir_restore_item)===124,'CDUP prepares position before directory read');
 const depth=word(m,S.dir_list_pointer);
 m[S.flag_dir]|=64;reply=550;u.call(S.ed3);
 assert(word(m,S.dir_restore_item)===124&&word(m,S.dir_list_pointer)===depth,'failed CWD preserves pending position and history');
 ptr(m,S.cur_item_addr,S.cur_item_addr_page,2);m[S.wind_curs_item]=1;
 reply=250;u.call(S.ed3);
 assert(word(m,S.dir_restore_item)===0,'successful CWD cancels stale parent position');
 assert(word(m,S.dir_list_pointer)===depth+3,'successful CWD saves exactly one level');
 u.call(S.dir_move);
 assert(index(m,S.cur_item_addr,S.cur_item_addr_page)===0,'child opens at first item after interrupted parent read');
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
 console.log(directoryPositionRegression(makeCpu,image,fs.readFileSync('WifiBios20_MB_EL.cod'),S));
}
