// Executes assembled 16KB checksum; paging port is simulated, sum code is real.
function directoryChecksumRegression(makeCpu,image,bios,S) {
 let checks=0;
 const assert=(v,s)=>{if(!v)throw Error(s);checks++;};
 const word=(m,p)=>m[p]|m[p+1]<<8;
 let maps=[];
 const u=makeCpu([],bios,S,{image,hook:(pc,r)=>{
  if(pc===S.PAGE128){maps.push(r.a&7);r.m[S.PAGE128_STATE]=(r.a&7)|16;return {ret:true,a:(r.a&7)|16};}
 }});
 let sum=0;for(let i=0;i<0x4000;i++){const v=(i*37+(i>>8))&255;u.m[0xc000+i]=v;sum=(sum+v)&65535;}
 u.m[S.PAGE128_STATE]=19;u.m[S.fdp_pointer]=123;u.m[S.fdp_pointer+1]=45;
 const before=word(u.m,S.fdp_pointer);
 assert(u.call(S.dir_cache_checksum).de===sum,'sum matches JS across all 16384 bytes');
 assert(maps.join(',')==='0,3'&&u.m[S.PAGE128_STATE]===19,'original mapped bank restored');
 assert(word(u.m,S.fdp_pointer)===before,'directory bank pointer preserved');
 u.m[S.flag_dir]=1;u.call(S.save_dir_cache_checksum);
 assert(word(u.m,S.dir_cache_sum)===sum,'Q stores computed sum');
 u.call(S.check_dir_cache_checksum);assert(!!(u.m[S.flag_dir]&1),'unchanged cache stays valid');
 for(const address of [0xc000,0xd234,0xffff]) {
  const saved=u.m[address];u.m[address]^=1;u.m[S.flag_dir]=1;
  u.call(S.check_dir_cache_checksum);
  assert(!(u.m[S.flag_dir]&1),'changed byte invalidates cache at '+address.toString(16));
  assert(u.m[S.PAGE128_STATE]===19,'mapping restored on mismatch');u.m[address]=saved;
 }
 u.m[S.flag_dir]=1;u.call(S.check_dir_cache_checksum);assert(!!(u.m[S.flag_dir]&1),'restored bytes validate again');
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
 console.log(directoryChecksumRegression(makeCpu,image,fs.readFileSync('WifiBios20_MB_EL.cod'),S));
}
