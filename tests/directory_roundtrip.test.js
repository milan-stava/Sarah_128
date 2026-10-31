// Real ENTER/name parsing/extension/history/item traversal and CDUP restoration.
// Only server responses, listing replacement, physical paging and drawing are modeled.
function directoryRoundtripRegression(makeCpu,image,bios,S) {
 let checks=0;
 const assert=(ok,msg)=>{if(!ok)throw Error(msg);checks++;};
 const word=(m,p)=>m[p]|m[p+1]<<8,put=(m,p,v)=>{m[p]=v&255;m[p+1]=v>>8;};
 const pageNumbers=[0,1,3,7];
 function listing(count,salt) {
  const bytes=[],starts=[];
  for(let i=0;i<count;i++) {
   starts.push(bytes.length);
   const text=i===0?'..':'D 0 Jan 01 12:34 '+salt+i+'x'.repeat((i*17)%90);
   const n=text.length+1;
   bytes.push(n&255,n>>8,0,...Array.from(text,c=>c.charCodeAt(0)),n&255,n>>8);
  }
  bytes.push(0,0);assert(bytes.length<65536,'listing fits four banks');
  return {bytes,starts};
 }
 for(const type of ['break','enter-dotdot'])for(const selected of [1,7,23,151,290]) {
  const lists=[listing(330,'parent'),listing(55,'child')];
  const banks=Array.from({length:8},()=>new Uint8Array(16384));
  let active=0,level=0,cpu,draws=0,cwd=0,cdup=0,reply=250;
  function loadList(r) {
   for(const page of pageNumbers)banks[page].fill(0);
   lists[level].bytes.forEach((v,i)=>banks[pageNumbers[i>>14]][i&16383]=v);
   r.m.set(banks[active],0xc000);r.m[S.flag_dir]=1;
  }
  cpu=makeCpu([],bios,S,{image,hook(pc,r){
   if(pc===S.PAGE128){banks[active].set(r.m.slice(0xc000));active=r.a&7;r.m.set(banks[active],0xc000);r.m[S.PAGE128_STATE]=16+active;return {ret:true,a:16+active};}
   if(pc===S.send_type_command_i)return {ret:true};
   if(pc===S.send_ftp_command){
    if(reply===550)return {ret:true,carry:true,hl:550};
    if(r.hl===S.ftp_cwd){level++;cwd++;return {ret:true,hl:250};}
    if(r.hl===S.ftp_cdup){level--;cdup++;return {ret:true,hl:200};}
    throw Error('unexpected command');
   }
   if(pc===S.directory_retrieve){loadList(r);return;}
   if(pc===S.undraw_cursor||pc===S.wifi_unwait||pc===S.prn_mark_items||pc===S.draw_cursor)return {ret:true};
   if(pc===S.print_page){draws++;return {ret:true};}
  }});
  // At the retrieval endpoint, load the modeled listing and run real dir_move.
  cpu.m[S.directory_retrieve]=0xc3;put(cpu.m,S.directory_retrieve+1,S.dir_move);
  cpu.m[S.flag1]=32;cpu.m[S.at_closed]=0;cpu.m[S.PAGE128_STATE]=16;
  put(cpu.m,S.dir_list_pointer,S.dir_list_start);loadList({m:cpu.m});
  const row=Math.min(6,selected+1),pageStart=selected-row+1;
  function setPointer(name,n){const off=lists[level].starts[n];put(cpu.m,S[name],0xc000+(off&16383));put(cpu.m,S[name==='cur_item_addr'?'cur_item_addr_page':'item_pg_start_page'],S.ftp_dir_page+1+(off>>14));}
  function currentIndex(name){const companion=name==='cur_item_addr'?'cur_item_addr_page':'item_pg_start_page';const offset=(word(cpu.m,S[companion])-S.ftp_dir_page-1)*16384+word(cpu.m,S[name])-0xc000;return lists[level].starts.indexOf(offset);}
  setPointer('cur_item_addr',selected);setPointer('item_pg_start',pageStart);
  cpu.m[S.wind_curs_item]=row;put(cpu.m,S.cursor_w_curad,word(cpu.m,S.cursor_w_stadr)+32*(row-1));
  // Failed CWD must not change history, including its pointer's high byte.
  reply=550;cpu.call(S.enter_directory);
  assert(word(cpu.m,S.dir_list_pointer)===S.dir_list_start,'failed ENTER preserves history pointer');
  assert(level===0,'failed CWD stays in parent');
  reply=250;cpu.call(S.enter_directory);
  assert(level===1&&cwd===1,'ENTER changes directory');
  assert(word(cpu.m,S.dir_list_pointer)===S.dir_list_start+3,'ENTER pushes history in correct RAM');
  assert(word(cpu.m,S.dir_list_start)===selected+1&&cpu.m[S.dir_list_start+2]===row,'saved ordinal and cursor row');
  assert(currentIndex('cur_item_addr')===0,'child opens at first item');
  cpu.call(type==='break'?S.go_updir:S.enter_directory);
  assert(level===0&&cdup===1,'return reaches parent');
  assert(currentIndex('cur_item_addr')===selected,'return restores selected directory, not last item');
  assert(currentIndex('item_pg_start')===pageStart,'return restores visible page');
  assert(cpu.m[S.wind_curs_item]===row,'return restores cursor row');
  assert(word(cpu.m,S.dir_list_pointer)===S.dir_list_start,'history level popped once');
  assert(draws===2,'child and restored parent drawn');
 }
 return {checks};
}
if(typeof require!=='undefined'&&typeof module!=='undefined') {
 const fs=require('fs'),vm=require('vm'),esx=process.argv[2]==='esx',S={};
 vm.runInThisContext(fs.readFileSync('tests/z80-directory.js','utf8'));
 for(const m of fs.readFileSync(esx?'directory-esx-test.sym':'directory-test.sym','utf8').matchAll(/^v[01]\.(\S+): EQU 0x([0-9A-F]+)/gmi))S[m[1]]=parseInt(m[2],16);
 const tape=fs.readFileSync(esx?'SARA_ESX_LOADER.tap':'SARA_LOADER.tap'),blocks=[];
 for(let p=0;p<tape.length;){const n=tape[p]|tape[p+1]<<8;p+=2;blocks.push(tape.subarray(p+1,p+n-1));p+=n;}
 console.log(directoryRoundtripRegression(makeCpu,blocks[3],fs.readFileSync('WifiBios20_MB_EL.cod'),S));
}
