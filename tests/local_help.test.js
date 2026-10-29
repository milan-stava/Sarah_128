// BS-DOS help uses the real file/sector loader; disk, keyboard and drawing endpoints modeled.
function localHelpRegression(makeCpu,image,bios,S,bank6,help) {
 let checks=0;
 const assert=(ok,s)=>{if(!ok)throw Error(s);checks++;},bytes=s=>Uint8Array.from(s,c=>c.charCodeAt(0)&255);
 const word=(m,p)=>m[p]|m[p+1]<<8,put=(m,p,v)=>{m[p]=v&255;m[p+1]=v>>8;};
 const text=bytes(help);
 for(const missing of [false,true])for(const hasDirectory of [false,true]) {
  let active=3,cpu,loads=0,views=0,messages=0,redraw=0;
  const banks=Array.from({length:8},(_,i)=>new Uint8Array(16384).fill(0x80+i));banks[6].set(bank6);
  const directory=banks[0].slice(),other=banks[3].slice();
  cpu=makeCpu([],bios,S,{image,hook(pc,r){
   if([S.send_string,S.send_ftp_command,S.send_type_command_i,S.print_working_directory,S.directory_retrieve,S.get_status_ftp,S.auto_login].includes(pc))throw Error('local help attempted FTP');
   if(pc===S.PAGE128){banks[active].set(r.m.slice(0xc000));active=r.a&7;r.m.set(banks[active],0xc000);r.m[S.PAGE128_STATE]=16+active;return {ret:true,a:16+active};}
   if(pc===S.bsdos){
    if(r.a===S.seasx){assert(String.fromCharCode(...r.m.slice(r.hl,r.hl+10))==='sara.hlp  ','padded BS-DOS help name');return {ret:true,z:!missing};}
    if(r.a===S.getcst)return {ret:true,hl:7};
    if(r.a===S.getsub){put(r.m,S.blen,text.length);put(r.m,S.blen+2,0);return {ret:true,z:false,carry:true};}
    if(r.a===S.howsec)return {ret:true,bc:Math.ceil(text.length/1024)};
    if(r.a===S.loa1x){loads++;assert(active===6&&r.ix===S.cfg_file_here,'help loaded into bank-6 CFG workspace');r.m.set(text,r.ix);return {ret:true,carry:true,ix:0x7777};}
    throw Error('unexpected disk service '+r.a);
   }
   if(pc===S.next_params)return {ret:true};
   if(pc===S.text_browse){views++;assert(r.ix===S.flag1,'restore IX after disk IO');assert(word(r.m,S.text_local_base)===S.cfg_file_here,'local source selected');assert(word(r.m,S.text_length)===text.length,'viewer gets actual file length');assert(text.every((v,i)=>r.m[S.cfg_file_here+i]===v),'help content intact');return {ret:true};}
   if(pc===S.pts){messages++;assert(missing&&r.de===S.help_missing,'missing help message');return {ret:true};}
   if([S.cls_4000,S.print_screen_layout,S.print_title].includes(pc))return {ret:true};
   if(pc===S['resume_directory_screen.cached']){redraw++;assert(active===3,'restore original RAM bank before directory redraw');return {ret:true};}
  }});
  cpu.m.set(banks[3],0xc000);cpu.m[S.PAGE128_STATE]=19;cpu.m[S.flag1]=16;cpu.m[S.flag_dir]=hasDirectory?1:0;
  put(cpu.m,S.disk_buf_len,16384);
  const result=cpu.call(S.help_show);
  assert(result.a===0&&result.ix===S.flag1,'help entry returns cleanly with balanced stack');
  assert(loads===(missing?0:1)&&views===(missing?0:1)&&messages===(missing?1:0),'load/view/missing paths');
  assert(redraw===(hasDirectory?1:0),'cached directory redraw only when present');
  assert(active===3&&banks[0].every((v,i)=>v===directory[i])&&banks[3].every((v,i)=>v===other[i]),'directory banks preserved');
 }
 // Direct bank-6 source bypasses the remote cache and never switches RAM banks.
 {
  const data=bytes('Help\r\nText');let maps=0,cpu;
  cpu=makeCpu([],bios,S,{image,hook(pc){if(pc===S.PAGE128){maps++;throw Error('local text switched data banks');}}});
  cpu.m.set(bank6,0xc000);cpu.m.set(data,S.cfg_file_here);put(cpu.m,S.text_local_base,S.cfg_file_here);put(cpu.m,S.text_length,data.length);
  for(let i=0;i<data.length;i++){put(cpu.m,S.text_pos,i);assert(cpu.call(S.text_get).a===data[i],'local byte '+i);}
  assert(maps===0,'local help has no data-bank switches');
 }
 return {checks};
}

if(typeof require!=='undefined'&&typeof module!=='undefined') {
 const fs=require('fs'),vm=require('vm');vm.runInThisContext(fs.readFileSync('tests/z80-directory.js','utf8'));
 const S={};for(const line of fs.readFileSync('directory-test.sym','utf8').split(/\r?\n/)){const m=line.match(/^v0\.(\S+): EQU 0x([0-9A-F]+)/i);if(m)S[m[1]]=parseInt(m[2],16);}
 const tape=fs.readFileSync('SARA_LOADER.tap'),blocks=[];for(let p=0;p<tape.length;){const n=tape.readUInt16LE(p);p+=2;blocks.push(tape.subarray(p,p+n));p+=n;}
 console.log(localHelpRegression(makeCpu,blocks[3].subarray(1,-1),fs.readFileSync('WifiBios20_MB_EL.cod'),S,blocks[5].subarray(1,-1),fs.readFileSync('sara.hlp','utf8')));
}
