// Execute get_extension with real directory-page traversal and ASCII folding.
function extensionRegression(makeCpu,image,bios,S) {
 let checks=0,cases=0;
 const assert=(v,s)=>{if(!v)throw Error(s);checks++;};
 const word=(m,p)=>m[p]|m[p+1]<<8;
 const put=(m,p,n)=>{m[p]=n&255;m[p+1]=n>>8;};
 const types=['tap','z80','sna','tzx','scr','trd','scl','txt','pok','ay'];
 const reference=name=>{const dot=name.lastIndexOf('.');if(dot<0)return 10;const i=types.indexOf(name.slice(dot+1).replace(/[A-Z]/g,c=>c.toLowerCase()));return i<0?10:i;};
 function run(name,{start=23,initial=6,length=name.length,integration=false,nlst=true,kind='file',expected=reference(name)}={}) {
  cases++;let u,active=initial,maps=[];
  const banks=Array.from({length:8},(_,i)=>new Uint8Array(16384).fill(0x80+i));
  const pageNumbers=[0,1,3,7],prefix=integration?(nlst?'':(kind==='dir'?'D':' ')+' 123 Jan 01 12:34 '):'';
  const data=prefix+name,entryStart=start;
  const write=(offset,v)=>{const page=offset>>14;if(page>=4)throw Error('test data exceeds directory RAM');banks[pageNumbers[page]][offset&0x3fff]=v;};
  if(integration){const n=data.length+1;write(start++,n&255);write(start++,n>>8);write(start++,0);}
  const nameStart=start+prefix.length;
  for(let i=0;i<data.length;i++)write(start+i,data.charCodeAt(i)&255);
  const before=banks.map(b=>b.slice());
  u=makeCpu([],bios,S,{image,hook:(pc,r)=>{
   if(pc===S.PAGE128){banks[active].set(u.m.slice(0xc000));active=r.a&7;u.m.set(banks[active],0xc000);u.m[S.PAGE128_STATE]=16+active;maps.push(active);return {ret:true,a:16+active};}
  }});u.m.set(banks[active],0xc000);u.m[S.PAGE128_STATE]=16+initial;
  // Deliberately let the directory parser pointer differ from current mapping.
  const oldPointer=S.ftp_dir_page+3;
  put(u.m,S.fdp_pointer,oldPointer);put(u.m,S.item_name_page,S.ftp_dir_page+1+(nameStart>>14));
  let regs={hl:0xc000+(nameStart&0x3fff),bc:length,de:0x4567},parser;
  if(integration){put(u.m,S.cur_item_addr,0xc000+(entryStart&0x3fff));put(u.m,S.cur_item_addr_page,S.ftp_dir_page+1+(entryStart>>14));u.m[S.flag_dir]=nlst?8:0;parser=u.call(S.get_item_name);assert(parser.a===(nlst?2:kind==='dir'?0:1),'89 retains item-type contract');regs={hl:parser.hl,bc:parser.bc,de:parser.de};}
  const originalMap=active,originalPtr=word(u.m,S.fdp_pointer),originalNamePage=word(u.m,S.item_name_page);
  const result=u.call(S.get_extension,regs);
  assert(result.a===expected,'extension '+JSON.stringify(name.length<80?name:name.slice(0,25)+'...'+name.slice(-8))+' at '+nameStart+' returned '+result.a+' expected '+expected);
  assert(result.hl===regs.hl&&result.bc===regs.bc&&result.de===regs.de,'name/length/file size preserved');
  assert(result.ix===S.flag1&&result.iy===0,'index registers preserved');
  assert(active===originalMap&&u.m[S.PAGE128_STATE]===16+originalMap&&word(u.m,S.fdp_pointer)===originalPtr,'original bank and parser pointer restored');
  assert(word(u.m,S.item_name_page)===originalNamePage,'name page metadata unchanged');
  banks[active].set(u.m.slice(0xc000));
  assert(banks.every((b,j)=>b.every((v,i)=>v===before[j][i])),'no directory or unrelated bank writes');
 }
 for(const [i,ext] of types.entries())for(const spelling of [ext,ext.toUpperCase(),ext[0].toUpperCase()+ext.slice(1)])for(const start of [0,0x3ffc,0x3ffd,0x3ffe,0x3fff,0x4000,0x7ffe,0xbfff]) {
  run('name.'+spelling,{start,expected:i});
 }
 // Place every byte of each supported extension at each side of a bank boundary.
 for(const ext of types)for(let offset=0;offset<=ext.length+1;offset++)run('x.'+ext,{start:0x4000-2-offset});
 for(const name of ['', '.', '..', 'no-extension', 'tap', 'ay', 'file.', 'file.a','file.gz','file.jpeg','file.tapx','file.z800','file.aYz','file.pokx','file.tap.', 'foo.tap.gz','foo.gz.TAP','foo..aY','a.b.c.scr','.AY','.TaP', 'file.AY\0','file.\x1a80','file.z\x18\x10','file.TAP ','file. ay','file.äy','file.\xE1y','file..', 'file.txt\n']) {
  run(name);run(name,{start:0x3ffe});
 }
 for(const n of [256,257,16380,16384,32768,49152,65530])for(const ext of ['.tAp','.AY','.jpeg',''])run('a'.repeat(n-ext.length)+ext,{start:0,length:n});
 for(let p=0;p<4;p++)run('last.AY',{start:(p+1)*0x4000-7,initial:p+2});
 run('last.tap',{start:65536-8}); // ends exactly at final #FFFF
 run('abc',{start:65533,length:4,expected:10}); // inconsistent length must not read beyond RAM
 for(const name of ['game.TAP','music.Ay','long.name.with.dots.scr','noext'])for(const nlst of [false,true])for(const start of [9,0x3ffc,0x3fff])run(name,{integration:true,nlst,start});
 // The classifier is syntax-only; a known directory named *.tap is filtered by caller.
 run('directory.tap',{integration:true,nlst:false,kind:'dir'});
 assert(S.get_extension_len===S.get_extension_code_len+30,'size includes all ten three-byte table slots');
 return {checks,cases};
}
if(typeof require!=='undefined'&&typeof module!=='undefined') {
 const fs=require('fs'),vm=require('vm');vm.runInThisContext(fs.readFileSync('tests/z80-directory.js','utf8'));
 const S={};for(const l of fs.readFileSync('directory-test.sym','utf8').split(/\r?\n/)){const m=l.match(/^v0\.(\S+): EQU 0x([0-9A-F]+)/i);if(m)S[m[1]]=parseInt(m[2],16);}
 console.log(extensionRegression(makeCpu,fs.readFileSync('SARAH12BSDhgfx'),fs.readFileSync('WifiBios20_MB_EL.cod'),S));
}
