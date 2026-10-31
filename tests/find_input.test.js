// Execute the real editor/cache with physical RAM banks and external keyboard/display.
function findInputRegression(makeCpu,image,bios,S,bank6) {
 let checks=0;
 const assert=(ok,msg)=>{if(!ok)throw Error(msg);checks++;};
 const str=(m,p)=>{let s='';while(m[p])s+=String.fromCharCode(m[p++]);return s;};
 for(const page of [0,1,3,4,6,7]) {
  let active=page,queue=[],frames=[],key=0,cpu,searching=false,reached=false;
  const stop={};
  const banks=Array.from({length:8},(_,i)=>new Uint8Array(16384).fill(0x80+i));
  banks[6].fill(0);banks[6].set(bank6);
  const original=banks.map(b=>b.slice());
  cpu=makeCpu([],bios,S,{image,onIn:()=>key===1?0xfe:0xff,hook(pc,r){
   if(pc===S.PAGE128){banks[active].set(r.m.slice(0xc000));active=r.a&7;r.m.set(banks[active],0xc000);r.m[S.PAGE128_STATE]=16+active;return {ret:true,a:16+active};}
   if(pc===S.WTKY||pc===S.print_ez1||pc===S.clear_edit_zone)return {ret:true};
   if(pc===S.CHAR)return {ret:true,hl:(r.hl&0xff00)|((r.hl+1)&255)};
   if(pc===S.KEYSCAN){assert(active===6,'editor runs with cache mapped');frames.push({text:str(r.m,S.INPBUFF).trimEnd(),cursor:r.m[S.CURSOR+1]});if(!queue.length)throw Error('unexpected key wait');key=queue.shift();return {ret:true,a:key,bc:0x1c55};}
   if(pc===S.DIR128_CUR_ATTR_HL&&searching){
    reached=true;assert(active===page,'directory bank restored before search');
    assert(str(r.m,S.INPBUFF).trimEnd()==='abc','actual FIND normalizes working pattern');
    assert(cache()==='AbC','normalization preserves the typed cache');throw stop;
   }
   if([S.send_string,S.send_ftp_command,S.directory_retrieve,S.DIR128_CUR_ATTR_HL].includes(pc))throw Error('FIND input touched network/directory');
  }});
  cpu.m.set(banks[page],0xc000);cpu.m[S.PAGE128_STATE]=16+page;cpu.m[S.flag1]=16;
  const cache=()=>str(active===6?cpu.m:banks[6],active===6?S.find_cache:S.find_cache-0xc000);
  function run(keys,expectedInitial,expectedCache,cancel=false) {
   queue=keys.slice();frames=[];key=0;
   const r=cpu.call(S.find_input);
   assert(frames[0].text===expectedInitial,'previous query prefilled');
   assert(frames[0].cursor===expectedInitial.length,'cursor at actual query end');
   assert(cache()===expectedCache,'only confirmed query stored');
   assert(r.z===cancel,'editor result survives bank restoration');
   assert(active===page&&cpu.m[S.PAGE128_STATE]===16+page,'original directory bank restored');
   assert(r.ix===S.flag1,'IX preserved');
   if(!cancel)assert(r.bc===expectedCache.length&&r.hl===S.INPBUFF,'accepted length and pointer preserved');
   banks[active].set(cpu.m.slice(0xc000));
   for(let i=0;i<8;i++)if(i!==6)assert(banks[i].every((v,j)=>v===original[i][j]),'directory/data bank untouched');
   assert(banks[6].every((v,j)=>(j>=S.find_cache-0xc000&&j<S.find_cache-0xc000+64)||v===original[6][j]),'cache write bounded to 64 bytes');
  }
  run([13],'','',true); // first use is empty, no unbounded LDIR BC=0
  run([65,98,67,13],'','AbC');
  run([13],'AbC','AbC');
  cpu.m.fill(88,S.INPBUFF,S.INPBUFF+64); // unrelated operation overwrites scratch
  run([7,120,1],'AbC','AbC',true);
  run([7,13],'AbC','AbC',true);
  run([7,120,13],'AbC','x');
  run([7,...Array(70).fill(81),13],'x','Q'.repeat(63));
  run([13],'Q'.repeat(63),'Q'.repeat(63));
  run([7,97,13],'Q'.repeat(63),'a');
  searching=true;queue=[7,65,98,67,13];
  try{cpu.call(S.find_items);}catch(e){if(e!==stop)throw e;}
  assert(reached,'full FIND enters its directory scan');
 }
 return {checks};
}
if(typeof require!=='undefined'&&typeof module!=='undefined') {
 const fs=require('fs'),vm=require('vm'),esx=process.argv[2]==='esx',S={};
 vm.runInThisContext(fs.readFileSync('tests/z80-directory.js','utf8'));
 for(const m of fs.readFileSync(esx?'directory-esx-test.sym':'directory-test.sym','utf8').matchAll(/^v[01]\.(\S+): EQU 0x([0-9A-F]+)/gmi))S[m[1]]=parseInt(m[2],16);
 const tape=fs.readFileSync(esx?'SARA_ESX_LOADER.tap':'SARA_LOADER.tap'),blocks=[];
 for(let p=0;p<tape.length;){const n=tape[p]|tape[p+1]<<8;p+=2;blocks.push(tape.subarray(p+1,p+n-1));p+=n;}
 console.log(findInputRegression(makeCpu,blocks[3],fs.readFileSync('WifiBios20_MB_EL.cod'),S,blocks[5]));
}
