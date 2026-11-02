// Execute the real V controller and fixed-RAM ERR_SP cleanup. ROM tape I/O is
// modeled as TAP records, including checksum and terminal error/BREAK paths.
function saveAppRegression(makeCpu,image,bios,S,bank6) {
 let checks=0;
 const assert=(ok,msg)=>{if(!ok)throw Error(msg);checks++;};
 const put=(m,p,n)=>{m[p]=n&255;m[p+1]=n>>8;},word=(m,p)=>m[p]|m[p+1]<<8;
 const esx=S.save_app_filename!=null;
 const modes=['ok','return-error','rom-break',...(esx?['open-error','close-error']:[])];
 for(const mode of modes)for(const validDirectory of [false,true])for(const previous of [0,3]) {
  const banks=Array.from({length:8},()=>new Uint8Array(16384));banks[6].set(bank6);
  let active=previous,u,opened=0,closed=0,romCalls=0,reports=0;
  const blocks=[],order=[];
  u=makeCpu([],bios,S,{image,hook(pc,r){
   if(pc>=0xc000&&pc<0xe000)assert(active===6,'save code executes only in mapped program bank');
   if(pc===S.PAGE128){banks[active].set(r.m.slice(0xc000));active=r.a&7;r.m.set(banks[active],0xc000);r.m[S.PAGE128_STATE]=16+active;return {ret:true,a:16+active};}
   if(pc===S.set_3_5mhz){order.push('speed');return {ret:true};}
   if(pc===8){const service=r.m[r.stack[r.stack.length-1]++];assert(esx&&service===S.M_TAPEOUT,'save uses tape output API only');
    const b=r.bc>>8;assert(r.a===2,'default ESXDOS drive');
    let name='';for(let p=r.ix;r.m[p];p++)name+=String.fromCharCode(r.m[p]);assert(name==='SAR12SAV.tap','save retains existing output filename');
    if(b===3){opened++;order.push('open');return {ret:true,carry:mode==='open-error',ix:0x7777};}
    assert(b===1,'close redirected tape');closed++;order.push('close');return {ret:true,carry:mode==='close-error',ix:0x7777};
   }
   if(pc===0x04c2){
    romCalls++;assert(order[0]==='speed'&&active===6&&r.iy===0x5c3a,'normal CPU/IY and bank before ROM save');
    const errorSp=word(r.m,0x5c3d),trap=r.stack.lastIndexOf(S.save_app_rom_error);
    assert(trap>=0&&errorSp===0xf000-2*(trap+1),'ERR_SP points at installed fixed-RAM error return');
    if(romCalls===3&&mode==='rom-break'){r.m[0x5c3a]=12;r.stack.splice(trap+1);return {ret:true};}
    if(romCalls===3&&mode==='return-error')return {ret:true,carry:false};
    assert(r.a===0||r.a===255,'valid tape block flag');
    const payload=Array.from(r.m.slice(r.ix,r.ix+r.de)),n=payload.length+2;
    assert(payload.length===r.de,'block stays within address space');
    const crc=payload.reduce((x,b)=>x^b,r.a);blocks.push([n&255,n>>8,r.a,...payload,crc]);
    return {ret:true,carry:true,ix:(r.ix+r.de)&65535,iy:0x5c3a};
   }
   if(pc===S.display_error){reports++;assert(active===previous&&r.ix===S.flag1&&(r.bc&255)===15,'save failure returns to restored UI context');return {ret:true};}
  }});u.m.set(banks[previous],0xc000);u.m[S.PAGE128_STATE]=16+previous;u.m[S.DefaultDrive||0x5aff]=2;
  u.m[S.flag_dir]=validDirectory?0x19:0x18;u.m[S.flag1]=0x30;put(u.m,0x5c3d,0x5e00);
  const host='saved.example';u.m.set(Array.from(host,c=>c.charCodeAt(0)),S.host_url);u.m[S.host_url+host.length]=0;
  const result=u.call(S.save_app);
  assert(result.a===0&&result.ix===S.flag1&&active===previous,'save restores bank/IX and balances stack');
  assert(u.m[S.flag_dir]===(validDirectory?0x19:0x18)&&word(u.m,0x5c3d)===0x5e00,'runtime directory validity and ERR_SP restored');
  assert(u.m[0x5c3a]===255,'trapped ROM error is cleared before returning to the UI');
  assert(reports===(mode==='ok'?0:1),'failure reported exactly once');
  assert(opened===(esx?1:0)&&closed===(esx&&mode!=='open-error'?1:0),'tape redirect closed once after success/error/BREAK');
  if(mode==='open-error')assert(romCalls===0,'open failure writes no blocks');
  if(mode==='return-error'||mode==='rom-break')assert(romCalls===3,'failed block stops remaining output');
  if(mode==='ok'||mode==='close-error') {
   assert(blocks.length===6,'save includes BASIC and both CODE headers/bodies');
   const names=blocks.filter((b,i)=>!(i&1)).map(b=>String.fromCharCode(...b.slice(4,14)).trim());
   assert(names.join(',')==='SARA,SARA1,SARA2','standalone loader matches CODE block names');
   for(const b of blocks){assert((b[0]|b[1]<<8)===b.length-2&&b.slice(2).reduce((x,v)=>x^v,0)===0,'TAP record length/parity');}
   assert((blocks[0][14]|blocks[0][15]<<8)===blocks[1].length-4&&(blocks[0][16]|blocks[0][17]<<8)===10,'BASIC autostart and length');
   assert((blocks[2][14]|blocks[2][15]<<8)===0x6000&&(blocks[2][16]|blocks[2][17]<<8)===0x6000,'main CODE length/address');
   assert((blocks[4][14]|blocks[4][15]<<8)===S.program_page_len&&(blocks[4][16]|blocks[4][17]<<8)===0xc000,'bank CODE length/address');
   const main=blocks[3].slice(3,-1),savedBank=blocks[5].slice(3,-1);
   assert(!(main[S.flag_dir-0x6000]&1),'saved program does not reuse unsaved directory RAM');
   assert(String.fromCharCode(...main.slice(S.host_url-0x6000,S.host_url-0x6000+host.length))===host,'current settings included');
   assert(savedBank.length===S.program_page_len&&savedBank.every((v,i)=>v===banks[6][i]),'entire bank 6 saved without truncation');
   const basic=blocks[1].slice(3,-1),reference=bank6.slice(S['saved_loader.loader_start']-0xc000,S['saved_loader.loader_line_end']-0xc000);
   assert(basic.length===reference.length&&basic.every((v,i)=>v===reference[i]),'runtime saver shares assembled BASIC loader data');
  }
 }
 return {checks};
}
if(typeof require!=='undefined'&&typeof module!=='undefined') {
 const fs=require('fs'),vm=require('vm'),esx=process.argv[2]==='esx',S={};vm.runInThisContext(fs.readFileSync('tests/z80-directory.js','utf8'));
 for(const m of fs.readFileSync(esx?'directory-esx-test.sym':'directory-test.sym','utf8').matchAll(/^v[01]\.(\S+): EQU 0x([0-9A-F]+)/gmi))S[m[1]]=parseInt(m[2],16);
 const tape=fs.readFileSync(esx?'SARA_ESX_LOADER.tap':'SARA_LOADER.tap'),blocks=[];for(let p=0;p<tape.length;){const n=tape[p]|tape[p+1]<<8;p+=2;blocks.push(tape.subarray(p+1,p+n-1));p+=n;}
 console.log(saveAppRegression(makeCpu,blocks[3],fs.readFileSync('WifiBios20_MB_EL.cod'),S,blocks[5]));
}
