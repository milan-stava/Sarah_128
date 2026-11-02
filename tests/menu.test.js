// Actual banked menu rendering and mapping; terminal drawing is modeled.
function menuRegression(makeCpu,image,bios,S,bank6) {
 let checks=0;
 const assert=(v,s)=>{if(!v)throw Error(s);checks++;};
 for(const original of [0,3,6])for(const directory of [false,true]) {
  let active=original,u;const draws=[],banks=Array.from({length:8},()=>new Uint8Array(16384));banks[6].set(bank6);
  u=makeCpu([],bios,S,{image,hook(pc,r){
   if(pc===S.PAGE128){banks[active].set(r.m.slice(0xc000));active=r.a&7;r.m.set(banks[active],0xc000);r.m[S.PAGE128_STATE]=16+active;return {ret:true,a:16+active};}
   if(pc===S.PRINTHL){let text='';for(let p=r.de;r.m[p];p++)text+=String.fromCharCode(r.m[p]);assert(active===6,'menu text and formatter are in bank 6');assert(text.length+(r.hl&255)<=64,'menu never spills across screen rows');draws.push({text,at:r.hl});return {ret:true};}
  }});u.m.set(banks[original],0xc000);u.m[S.PAGE128_STATE]=16+original;
  u.m[S.fdp_pointer]=0x34;u.m[S.fdp_pointer+1]=0x12;
  u.call(directory?S.print_dir_menu:S.print_menu);
  assert(active===original&&u.m[S.fdp_pointer]===0x34&&u.m[S.fdp_pointer+1]===0x12,'menu restores mapping without disturbing directory paging');
  if(directory){assert(draws.length===1&&draws[0].at===S.txt_adr_dir_info+22,'directory hints preserve left-side counters');for(const key of ['I-find','Sp-M','ZX-roll','6-','7-','Del','Br-U','Ent'])assert(draws[0].text.includes(key),'directory shortcut '+key);}
  else {
   assert(draws.length===3&&draws.map(x=>x.at).join(',')===[S.txt_adr_menu1,S.txt_adr_menu2,S.txt_adr_meziradek].join(','),'three menu rows in the intended positions');
   assert(draws[0].text.slice(17,20)==='YES'&&draws[1].text.slice(7,10)==='OFF','dynamic autologin/Wi-Fi columns retained');
   const text=draws.map(x=>x.text).join(' ');
   for(const key of ['F-','T-','A-','H-','E-','P-','U-','S-','Q-','G-','K-','W-','L/ssL','O-','V-','D-','C-','R-','Z-','ssP-','CS/ssD-','N/ssN-','CS/ssM-','Arrows-'])assert(text.includes(key),'main shortcut '+key);
  }
 }
 return {checks};
}
if(typeof require!=='undefined'&&typeof module!=='undefined') {
 const fs=require('fs'),vm=require('vm'),esx=process.argv[2]==='esx',S={};vm.runInThisContext(fs.readFileSync('tests/z80-directory.js','utf8'));
 for(const m of fs.readFileSync(esx?'directory-esx-test.sym':'directory-test.sym','utf8').matchAll(/^v[01]\.(\S+): EQU 0x([0-9A-F]+)/gmi))S[m[1]]=parseInt(m[2],16);
 const tape=fs.readFileSync(esx?'SARA_ESX_LOADER.tap':'SARA_LOADER.tap'),blocks=[];for(let p=0;p<tape.length;){const n=tape[p]|tape[p+1]<<8;p+=2;blocks.push(tape.subarray(p+1,p+n-1));p+=n;}
 console.log(menuRegression(makeCpu,blocks[3],fs.readFileSync('WifiBios20_MB_EL.cod'),S,blocks[5]));
}
