// Execute ENTER classification, download handoff, bank-6 command construction
// and fixed-RAM ESXDOS calls. Physical disk/ROM/keyboard endpoints are modeled.
function esxdosLaunchRegression(makeCpu,image,bios,S,bank6) {
 let checks=0,cases=0;
 const assert=(ok,msg)=>{if(!ok)throw Error(msg);checks++;},stop={};
 const put=(m,p,n)=>{m[p]=n&255;m[p+1]=n>>8;},word=(m,p)=>m[p]|m[p+1]<<8;
 const str=(m,p)=>{let s='';while(m[p]){s+=String.fromCharCode(m[p++]);if(s.length>256)throw Error('unterminated command');}return s;};
 if(S.esx_launch_bank==null){assert(S.esx_load_tap==null&&S.esx_load_snap==null&&S.esx_load_trdscl==null,'BS-DOS has no ESXDOS launcher');return {checks,cases};}
 const types=[['tap',0],['z80',1],['sna',2],['trd',5],['scl',6]],pages=[0,1,3,7];
 for(const [ext,type]of types)for(const mode of ['list','nlst'])for(const outcome of ['ok','download-fail','loader-fail',...(type<5?['returned']:[]),...(type===0?['attach-fail']:type>=5?['eject-fail']:[])]) {
  cases++;let cpu,active=3,downloads=0,reports=0,takeover=false;
  const events=[],banks=Array.from({length:8},()=>new Uint8Array(16384));banks[6].set(bank6);
  const remote='a_long_remote_name.'+ext.toUpperCase(),local='LOCAL123.'+ext.toUpperCase();
  const raw=(mode==='list'?' 123 Jan 01 12:34 ':'')+remote,start=0x3ffd,n=raw.length+1;
  [n&255,n>>8,0,...Array.from(raw,c=>c.charCodeAt(0)),n&255,n>>8,0,0].forEach((v,i)=>{const offset=start+i;banks[pages[offset>>14]][offset&16383]=v;});
  const directory=pages.map(p=>banks[p].slice());
  function map(r,page){banks[active].set(r.m.slice(0xc000));active=page;r.m.set(banks[page],0xc000);r.m[S.PAGE128_STATE]=16+page;}
  cpu=makeCpu([],bios,S,{image,hook(pc,r){
   if(pc>=0xc000&&pc<0xe000)assert(active===6,'bank-6 code executes only while bank 6 is mapped');
   if(pc===S.PAGE128){map(r,r.a&7);return {ret:true,a:16+active};}
   if(pc===S.send_type_command_i){events.push('TYPE');return {ret:true};}
   if(pc===S.ftp_download_file_under_cursor){
    downloads++;events.push('download');assert(r.m[S.item_extension]===type,'extension survives at its symbolic offset');
    assert(str(r.m,S.INPBUFF)===remote,'download gets complete remote name');
    map(r,3);r.m.fill(0,S.exp_name,S.exp_name+13);r.m.set(Array.from(local,c=>c.charCodeAt(0)),S.exp_name);
    return {ret:true,a:outcome==='download-fail'?1:0,z:outcome!=='download-fail'};
   }
   if(pc===S.set_3_5mhz){events.push('speed');return {ret:true};}
   if(pc===0x08){
    // esxDOS consumes the service byte following RST #08.
    const service=r.m[r.stack[r.stack.length-1]++];
    assert(pc<0xc000&&r.stack[r.stack.length-1]-1<0xc000,'terminal API call stays below paged RAM');
    if(service===S.M_TAPEIN){
     events.push('tapein');assert(type===0&&r.a===2&&(r.bc>>8)===0,'TAPEIN gets drive and open mode');
     assert(r.ix===S.exp_name&&str(r.m,r.ix)===local,'TAPEIN uses actual saved local filename');
     return {ret:true,a:5,carry:outcome==='attach-fail',ix:0x7777,hl:0x8888,bc:0xaaaa};
    }
    if(service===S.M_AUTOLOAD){
     events.push('autoload');assert(type===0&&r.a===0,'autoload uses the attached TAP');
     if(outcome==='ok'){takeover=true;throw stop;}
     return {ret:true,a:outcome==='returned'?0:5,carry:outcome!=='returned',ix:0x7777};
    }
    assert(service===S.M_EXECCMD,'no ESXDOS delete/unexpected service');
    assert(r.ix===S.INPBUFF,'command line is in bounded fixed RAM');
    const command=str(r.m,r.ix);
    if(type<5){
     events.push('snapload');assert(command==='snapload '+local,'snapshot command contains actual local filename');
     if(outcome==='ok'){takeover=true;throw stop;}
     return {ret:true,a:outcome==='returned'?0:5,carry:outcome!=='returned',ix:0x7777};
    }
    if(command==='vdisk 0'){
     events.push('eject');assert(!events.includes('mount'),'eject precedes mounting');
     return {ret:true,a:5,carry:outcome==='eject-fail',ix:0x7777,hl:0x8888,bc:0xaaaa};
    }
    events.push('mount');assert(command==='vdisk 0 '+local,'disk mount command contains actual local filename');
    return {ret:true,a:5,carry:outcome!=='ok',ix:0x7777};
   }
   if(pc===S.esx_trdos_stack){
    assert(type>=5&&outcome==='ok'&&active===0,'only a successful disk mount enters TR-DOS in bank 0');
    assert(r.iy===0x5c3a,'TR-DOS gets normal IY');
    assert(r.m[pc]===0x31&&word(r.m,pc+1)===65000&&r.m[pc+3]===0xfb&&r.m[pc+4]===0xc3&&word(r.m,pc+5)===15616,'stack, interrupt enable and TR-DOS jump encoded in order');
    events.push('TRDOS');takeover=true;throw stop;
   }
   if(pc===S.display_error){
    reports++;assert(r.ix===S.flag1&&(r.bc&255)===15&&active===3,'failure restores IX, RAM and disk error context');
    assert(r.m[S.esx_last_error]===(outcome==='returned'?0:5),'native ESXDOS error is retained');
    return {ret:true};
   }
   if(pc===S.error_handler||pc===S.send_string)throw Error('loader failure must not start FTP cleanup');
   // IM 1 affects interrupt delivery only; this interpreter does not model it.
   if(r.m[pc]===0xed&&r.m[pc+1]===0x56){r.m[pc]=r.m[pc+1]=0;}
  }});
  cpu.m.set(banks[3],0xc000);cpu.m[S.PAGE128_STATE]=19;
  cpu.m[S.flag1]=32;cpu.m[S.flag_dir]=mode==='list'?1:9;cpu.m[S.at_closed]=0;cpu.m[S.DefaultDrive]=2;
  put(cpu.m,S.cur_item_addr,0xc000+(start&16383));put(cpu.m,S.cur_item_addr_page,S.ftp_dir_page+1);
  put(cpu.m,S.dir_list_pointer,0xa55a);
  const guards=cpu.m.slice(S.exp_name-12,S.exp_name);
  let result;try{result=cpu.call(S.enter_directory);}catch(e){if(e!==stop)throw e;}
  assert(downloads===1&&events[0]==='TYPE'&&events[1]==='download','each supported type is downloaded once before launch');
  assert(takeover===(outcome==='ok'),'success takes over, failure returns to Sarah');
  assert(reports===(outcome==='ok'||outcome==='download-fail'?0:1),'download failure prevents loader/error duplication');
  if(!takeover)assert(result.a===(outcome==='download-fail'?1:0)&&result.ix===S.flag1&&active===3,'return stack balanced and bank restored');
  if(outcome==='download-fail')assert(events.length===2,'failed download makes no ESXDOS call');
  if(outcome==='attach-fail')assert(!events.includes('autoload'),'failed attachment cannot start a stale TAP');
  if(outcome==='eject-fail')assert(!events.includes('mount'),'failed eject cannot continue to mount');
  if(type<5)assert(!events.includes('TRDOS'),'snapshot/TAP never fall through into TR-DOS');
  assert(word(cpu.m,S.dir_list_pointer)===0xa55a,'symbolic extension offset does not corrupt history pointer');
  assert(guards.every((v,i)=>v===cpu.m[S.exp_name-12+i]),'no command prefixes written before exp_name');
  banks[active].set(cpu.m.slice(0xc000));assert(pages.every((p,j)=>banks[p].every((v,i)=>v===directory[j][i])),'launcher does not overwrite cached directory before takeover');
 }
 return {checks,cases};
}
if(typeof require!=='undefined'&&typeof module!=='undefined') {
 const fs=require('fs'),vm=require('vm'),esx=process.argv[2]==='esx',S={};
 vm.runInThisContext(fs.readFileSync('tests/z80-directory.js','utf8'));
 for(const m of fs.readFileSync(esx?'directory-esx-test.sym':'directory-test.sym','utf8').matchAll(/^v[01]\.(\S+): EQU 0x([0-9A-F]+)/gmi))S[m[1]]=parseInt(m[2],16);
 const tape=fs.readFileSync(esx?'SARA_ESX_LOADER.tap':'SARA_LOADER.tap'),blocks=[];
 for(let p=0;p<tape.length;){const n=tape[p]|tape[p+1]<<8;p+=2;blocks.push(tape.subarray(p+1,p+n-1));p+=n;}
 console.log(esxdosLaunchRegression(makeCpu,blocks[3],fs.readFileSync('WifiBios20_MB_EL.cod'),S,blocks[5]));
}
