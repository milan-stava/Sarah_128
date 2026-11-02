// Real cursor/page traversal, position tracker and decimal formatter on both DOSs.
// Only physical paging, terminal row drawing and unrelated UI are modeled.
function itemPositionRegression(makeCpu,image,bios,S,bank6) {
 let checks=0,steps=0;
 const assert=(v,s)=>{if(!v)throw Error(s);checks++;};
 const word=(m,p)=>m[p]|m[p+1]<<8,put=(m,p,v)=>{m[p]=v&255;m[p+1]=v>>8;};
 const pages=[0,1,3,7];
 for(const count of [1,2,7,8,9,17,330,1000]) {
  const banks=Array.from({length:8},()=>new Uint8Array(16384));banks[6].set(bank6);
  const bytes=[],starts=[];
  for(let i=0;i<count;i++){
   starts.push(bytes.length);const text=i?'item'+i+'x'.repeat((i*13)%79):'..',n=text.length+1;
   bytes.push(n&255,n>>8,0,...Array.from(text,c=>c.charCodeAt(0)),n&255,n>>8);
  }
  bytes.push(0,0);assert(bytes.length<65536,'listing fits');
  for(let i=0;i<bytes.length;i++)banks[pages[i>>14]][i&16383]=bytes[i];
  let active=0,frame='',frames=0,walks=0,cpu,jumpInput=null,findQuery='';
  cpu=makeCpu([],bios,S,{image,hook(pc,r){
   if(pc===S.PAGE128){banks[active].set(r.m.slice(0xc000));active=r.a&7;r.m.set(banks[active],0xc000);r.m[S.PAGE128_STATE]=16+active;return {ret:true,a:16+active};}
   if(pc===S.item_position_step)walks++;
   if(pc===S.input_line_edit_limit){
    assert(r.bc%256===5,'jump editor limits input to five characters');
    r.m.fill(32,S.INPBUFF,S.INPBUFF+255);r.m.set(Array.from(jumpInput||'',c=>c.charCodeAt(0)),S.INPBUFF);
    return {ret:true,hl:S.INPBUFF,bc:(jumpInput||'').length,z:!jumpInput};
   }
   if(pc===S.find_input){r.m.fill(0,S.INPBUFF,S.INPBUFF+255);r.m.set(Array.from(findQuery,c=>c.charCodeAt(0)),S.INPBUFF);return {ret:true,hl:S.INPBUFF,bc:findQuery.length,z:false};}
   if(pc===S.PRINTHL){
    assert(active===6,'formatter executes in bank 6');assert(r.hl===S.txt_adr_file+S.line_length-5,'five rightmost File/Start columns');
    frame='';for(let p=r.de;r.m[p];p++)frame+=String.fromCharCode(r.m[p]);
    assert(frame.length===5,'fixed-width field clears old digits');frames++;return {ret:true};
   }
   if([S.wifi_unwait,S.cls_9,S.prn_mark_items,S.print_item,S.draw_cursor_row,S.print_ez1,S.clear_edit_zone].includes(pc))return {ret:true};
  }});
  cpu.m.set(banks[0],0xc000);cpu.m[S.PAGE128_STATE]=16;cpu.m[S.flag_dir]=1;
  const index=()=>starts.indexOf((word(cpu.m,S.cur_item_addr_page)-S.ftp_dir_page-1)*16384+word(cpu.m,S.cur_item_addr)-0xc000);
  const verify=()=>{
   const n=index();assert(n>=0,'cursor points at a real record');
   assert(word(cpu.m,S.item_counter)===n+1,'ordinal equals selected record, not last traversed record');
   assert(frame===String(n+1).padStart(5,' '),'right-aligned decimal '+(n+1));
   assert(active===pages[Math.floor(starts[n]/16384)],'cursor drawing restores selected directory bank');
  };
  cpu.call(S.dir_move1);verify();
  for(let i=0;i<count+2;i++){
   const n=index(),before=walks;cpu.call(S.key_down);verify();steps++;
   assert(index()===Math.min(n+1,count-1),'down clamps at end');
   assert(walks-before<2,'adjacent movement never rescans directory');
  }
  for(let i=0;i<count+2;i++){
   const n=index(),before=walks;cpu.call(S.key_up);verify();steps++;
   assert(index()===Math.max(n-1,0),'up clamps at start');
   assert(walks-before<2,'backward movement never rescans directory');
  }
  for(let i=0;i<50;i++){const before=walks;cpu.call(S.pg_up);verify();assert(walks-before<=8,'forward page walks at most a screen');steps++;}
  for(let i=0;i<50;i++){const before=walks;cpu.call(S.pg_down);verify();assert(walks-before<=8,'backward page walks at most a screen');steps++;}
  // History restoration, clamping after a shortened directory, FIND-style jumps.
  for(const n of [count-1,Math.floor(count/2),0]) {
   cpu.m[S.wind_curs_item]=6;cpu.call(S.restore_dir_view,{bc:n+1});verify();
   const off=starts[count-1-n];put(cpu.m,S.cur_item_addr,0xc000+(off&16383));put(cpu.m,S.cur_item_addr_page,S.ftp_dir_page+1+(off>>14));
   cpu.call(S.draw_cursor);verify();
  }
  cpu.m[S.wind_curs_item]=8;cpu.call(S.restore_dir_view,{bc:count+100});verify();assert(index()===count-1,'restore clamps at actual end');
  const before=walks;cpu.call(S.print_page);cpu.call(S.draw_cursor);verify();assert(walks===before,'temporary page traversal does not change tracker');
  // An invalid directory shows zero and invalidates the bank cache.
  cpu.m[S.flag_dir]=0;cpu.call(S.print_item_position);
  assert(frame==='    0'&&word(cpu.m,S.item_counter)===0,'no listing displays zero');
  assert(word(banks[6],S.item_position_count-0xc000)===0,'invalid listing clears cache');
  cpu.m[S.flag_dir]=1;cpu.call(S.dir_move1);verify();
  // Replacement listing can reuse the exact same addresses with different data.
  cpu.call(S.reset_item_position);assert(word(banks[6],S.item_position_count-0xc000)===0,'replacement resets tracker');
  cpu.call(S.draw_cursor);verify();assert(frames>0,'field was drawn');
  // J shares the ordinary restore/draw path; invalid input is a no-op.
  for(const nlst of [false,true]){
   cpu.m[S.flag_dir]=nlst?9:1;const dirs=nlst?999:Math.floor((count-1)/2);
   put(cpu.m,S.dir_counter,dirs);put(cpu.m,S.item_file_count,nlst?count-1:count-1-dirs);
   for(const input of [String(count),'1',null,'','0','00000','-1','abc','1x','65536','99999',String(count+1),'00001']){
    const original=index();jumpInput=input;const target=/^\d+$/.test(input||'')?Number(input):0,valid=target>=1&&target<=count;
    cpu.call(S.jump_to_item);verify();assert(index()===(valid?target-1:original),'jump target or unchanged position '+input);
    if(valid)assert(cpu.m[S.wind_curs_item]===1,'jump displays selected item on first row');
   }
  }
  // Real FIND scans temporary pointers; its final result updates the ordinal.
  if(count>1){
   cpu.m[S.flag_dir]=9;findQuery='item'+(count-1);cpu.call(S.find_items);verify();assert(index()===count-1,'FIND selects requested match');
   findQuery='no such item';cpu.call(S.find_items);verify();assert(index()===count-1,'failed FIND retains ordinal');
  }
 }
 // Public J without a cached directory must not access pointers or the editor.
 {const u=makeCpu([],bios,S,{image,hook(pc){if([S.PAGE128,S.input_line_edit_limit].includes(pc))throw Error('jump without directory touched UI');}});u.m[S.flag_dir]=0;u.call(S.jump_to_item);checks++;}
 // Decimal field covers the whole 16-bit range; shrinking values clear padding.
 {
  const banks=Array.from({length:8},()=>new Uint8Array(16384));banks[6].set(bank6);let active=3,frame='',u;
  u=makeCpu([],bios,S,{image,hook(pc,r){
   if(pc===S.PAGE128){banks[active].set(r.m.slice(0xc000));active=r.a&7;r.m.set(banks[active],0xc000);r.m[S.PAGE128_STATE]=16+active;return {ret:true,a:16+active};}
   if(pc===S.PRINTHL){frame='';for(let p=r.de;r.m[p];p++)frame+=String.fromCharCode(r.m[p]);return {ret:true};}
  }});u.m.set(banks[3],0xc000);u.m[S.PAGE128_STATE]=19;u.m[S.flag_dir]=1;
  put(u.m,S.cur_item_addr,0xc123);put(u.m,S.cur_item_addr_page,S.ftp_dir_page+2);
  for(const n of [65535,10000,1000,100,99,10,9,1]){
   put(banks[6],S.item_position_pointer-0xc000,0xc123);put(banks[6],S.item_position_pointer+2-0xc000,S.ftp_dir_page+2);put(banks[6],S.item_position_count-0xc000,n);
   u.call(S.print_item_position);assert(frame===String(n).padStart(5,' '),'16-bit formatting '+n);assert(active===3,'UI refresh preserves original page');
  }
 }
 return {checks,steps};
}
if(typeof require!=='undefined'&&typeof module!=='undefined') {
 const fs=require('fs'),vm=require('vm'),esx=process.argv[2]==='esx',S={};vm.runInThisContext(fs.readFileSync('tests/z80-directory.js','utf8'));
 for(const m of fs.readFileSync(esx?'directory-esx-test.sym':'directory-test.sym','utf8').matchAll(/^v[01]\.(\S+): EQU 0x([0-9A-F]+)/gmi))S[m[1]]=parseInt(m[2],16);
 const tape=fs.readFileSync(esx?'SARA_ESX_LOADER.tap':'SARA_LOADER.tap'),blocks=[];for(let p=0;p<tape.length;){const n=tape[p]|tape[p+1]<<8;p+=2;blocks.push(tape.subarray(p+1,p+n-1));p+=n;}
 console.log(itemPositionRegression(makeCpu,blocks[3],fs.readFileSync('WifiBios20_MB_EL.cod'),S,blocks[5]));
}
