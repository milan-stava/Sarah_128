// Execute the assembled bank-6 formatter, real parser, paging bridges and
// scrolling. Only physical paging, drawing and keyboard input are modeled.
function directoryDisplayRegression(makeCpu,image,bios,S,bank6) {
 let checks=0,cases=0;
 const assert=(v,msg)=>{if(!v)throw Error(msg);checks++;};
 const word=(m,p)=>m[p]|m[p+1]<<8,put=(m,p,n)=>{m[p]=n&255;m[p+1]=n>>8;};
 const pages=[0,1,3,7],width=S.line_length;
 function fixture(name,{start=11,mode='nlst',kind='file',keys=[]}={}) {
  cases++;
  const prefix=mode==='nlst'?'':mode==='full'?'-rw-r--r-- 1 user group 123 Jan 01 12:34 ':(kind==='dir'?'D':' ')+' 123 Jan 01 12:34 ';
  const raw=prefix+name,stored=raw.length+1;
  const banks=Array.from({length:8},()=>new Uint8Array(16384));
  banks[6].set(bank6);
  function write(i,v){if(i>=65536)throw Error('fixture exceeds directory');banks[pages[i>>14]][i&16383]=v;}
  const bytes=[stored&255,stored>>8,1,...Array.from(raw,c=>c.charCodeAt(0)),stored&255,stored>>8,0,0];
  bytes.forEach((v,i)=>write(start+i,v));
  const original=pages.map(p=>banks[p].slice());
  let active=4,cpu,frames=[],keyIndex=0,redraws=0,dispatched;
  const match=mode!=='full'&&(mode==='nlst'||kind==='file')&&start!==0?name.match(/^(.+)\.([^\s.]{1,3})$/):null;
  const ext=match?match[2]:null,base=ext?raw.slice(0,-ext.length-1):raw,w=ext?width-4:width;
  const expected=(pos,rolling)=>{
   let text=base.slice(pos,pos+w);
   if(base.length-pos>w&&(ext||!rolling))text=text.slice(0,w-2)+'..';
   return text.padEnd(w,' ')+(ext?' '+ext.padEnd(3,' '):'');
  };
  cpu=makeCpu([],bios,S,{image,hook(pc,r){
   if(pc===S.PAGE128){banks[active].set(r.m.slice(0xc000));active=r.a&7;r.m.set(banks[active],0xc000);r.m[S.PAGE128_STATE]=16+active;return {ret:true,a:16+active};}
   if(pc===S.PRINTHL){
    assert(active===6,'drawing returns in program bank');
    let text='';for(let p=r.de;r.m[p];p++){assert(text.length<=width,'bounded terminator');text+=String.fromCharCode(r.m[p]);}
    const pos=word(r.m,S.roll_pos),rolling=!!r.m[S.dir_display_rolling];
    assert(text===expected(pos,rolling),'row mismatch '+JSON.stringify({name:name.slice(0,50),mode,pos,text,expected:expected(pos,rolling)}));
    assert(r.hl===(rolling?S.txt_adr_mezera+0x300:0x1400),'correct row coordinates');
    frames.push({text,pos});return {ret:true};
   }
   if(pc===S.KEYSCAN){assert(keyIndex<keys.length,'keyboard does not hang');return {ret:true,a:keys[keyIndex++]};}
   if(pc===S.print_page){redraws++;return {ret:true};}
   if(pc===S.key_loop+3){dispatched=r.a;return {ret:true};}
  }});
  cpu.m.set(banks[active],0xc000);cpu.m[S.PAGE128_STATE]=16+active;
  put(cpu.m,S.cur_item_addr,0xc000+(start&16383));put(cpu.m,S.cur_item_addr_page,S.ftp_dir_page+1+(start>>14));
  put(cpu.m,S.cur_lin_prn_adr,0x1400);put(cpu.m,S.cursor_w_curad,0x5800);
  cpu.m[S.flag_dir]=mode==='nlst'?8:mode==='full'?2:0;cpu.m[S.wind_curs_item]=3;
  function unchanged(){banks[active].set(cpu.m.slice(0xc000));assert(pages.every((p,j)=>banks[p].every((v,i)=>v===original[j][i])),'directory bytes never modified');assert(word(cpu.m,S.cur_item_addr)===0xc000+(start&16383)&&word(cpu.m,S.cur_item_addr_page)===S.ftp_dir_page+1+(start>>14),'current item pointer preserved');}
  return {cpu,banks,frames,base,w,ext,unchanged,get active(){return active;},get keyIndex(){return keyIndex;},get redraws(){return redraws;},get dispatched(){return dispatched;}};
 }
 const names=['','a','x.a','x.AY','game.TAP','sara.CFG','short','file.','file.jpeg','.cfg','a.b.c.Z80','foo..AY','file.TAP ','dir.with.dots','a'.repeat(57)+'.txt','a'.repeat(60)+'.a','a'.repeat(61)+'.POK','x'.repeat(90)+'.jpeg','x'.repeat(90)+'.Z80'];
 for(const name of names)for(const mode of ['nlst','list','full'])for(const start of [9,0x3ffd,0x7fff,0xbffc]) {
  const f=fixture(name,{mode,start});f.cpu.call(S.print_item);
  assert(f.frames.length===1,'one normal row');
  assert(f.active===pages[(start+2)>>14],'attribute drawing remaps its directory bank');
  f.unchanged();
 }
 for(const name of ['x.a','x.AY','game.TAP','file.jpeg'])for(const delta of [-1,0,1,2,3]) {
  const f=fixture(name,{start:0x4000-3-name.length+delta});f.cpu.call(S.print_item);f.unchanged();
 }
 for(const name of ['folder.tap','folder.'+'x'.repeat(75)+'.txt']) {
  const f=fixture(name,{mode:'list',kind:'dir'});f.cpu.call(S.print_item);f.unchanged();
 }
 // The first synthetic .. item must remain a directory navigation entry.
 {const f=fixture('..',{start:0});f.cpu.call(S.print_item);f.unchanged();}
 for(const name of ['a'.repeat(70)+'.TXT','a'.repeat(70)+'.jpeg','a'.repeat(70),'a'.repeat(61)+'.a']) {
  const f=fixture(name,{start:0x3ffb,keys:[122,122,120,120,0,13]});
  f.cpu.call(S.roll_item);
  assert(f.keyIndex===6&&f.dispatched===13&&f.redraws===1,'scroll exits and dispatches next key once');
  assert(f.frames[0].pos===1&&f.frames[1].pos===0,'initial X and Z move by one');
  assert(f.frames.every(x=>!f.ext||x.text.slice(width-3)===f.ext.padEnd(3,' ')),'suffix stays fixed throughout scrolling');
  f.unchanged();
 }
 for(const name of ['small.TXT','noext','file.jpeg']) {
  const f=fixture(name);f.cpu.call(S.roll_item);assert(f.keyIndex===0&&f.redraws===0,'short row does not enter keyboard loop');f.unchanged();
 }
 // Move across directory banks with >255-byte and >16K-byte names, and verify
 // both limits and the final complete window without truncation dots.
 for(const [n,start] of [[300,0x3ffc],[17000,0x3ffa],[49000,5]])for(const suffix of ['.CFG','.jpeg']) {
  const f=fixture('q'.repeat(n)+suffix,{start});
  f.cpu.call(S.PAGE128,{a:6});f.cpu.call(S.dir_display_prepare);
  put(f.cpu.m,S.dir_display_screen,0x1400);f.cpu.m[S.dir_display_rolling]=0;
  const max=f.base.length-f.w;
  for(const pos of [0,1,16380,16384,max].filter(x=>x<=max)) {
   put(f.cpu.m,S.roll_pos,pos);f.cpu.call(S.print_item_roll);
  }
  f.cpu.m[S.dir_display_rolling]=1;put(f.cpu.m,S.dir_display_screen,S.txt_adr_mezera+0x300);
  put(f.cpu.m,S.roll_max,max);put(f.cpu.m,S.roll_pos,max);
  const before=f.frames.length;f.cpu.call(S.roll_item_inc);assert(f.frames.length===before,'right limit does not wrap');
  f.cpu.call(S.roll_item_dec);assert(f.frames[f.frames.length-1].pos===max-1,'left step after right limit');
  put(f.cpu.m,S.roll_pos,0);const beforeLeft=f.frames.length;f.cpu.call(S.roll_item_dec);assert(f.frames.length===beforeLeft,'left limit does not underflow');
  f.unchanged();
 }
 return {checks,cases};
}
if(typeof require!=='undefined'&&typeof module!=='undefined') {
 const fs=require('fs'),vm=require('vm'),esx=process.argv[2]==='esx',S={};
 vm.runInThisContext(fs.readFileSync('tests/z80-directory.js','utf8'));
 for(const m of fs.readFileSync(esx?'directory-esx-test.sym':'directory-test.sym','utf8').matchAll(/^v[01]\.(\S+): EQU 0x([0-9A-F]+)/gmi))S[m[1]]=parseInt(m[2],16);
 const tape=fs.readFileSync(esx?'SARA_ESX_LOADER.tap':'SARA_LOADER.tap'),blocks=[];
 for(let p=0;p<tape.length;){const n=tape[p]|tape[p+1]<<8;p+=2;blocks.push(tape.subarray(p+1,p+n-1));p+=n;}
 console.log(directoryDisplayRegression(makeCpu,blocks[3],fs.readFileSync('WifiBios20_MB_EL.cod'),S,blocks[5]));
}
