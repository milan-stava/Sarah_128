// Bank-6 profile browser and the real fixed-memory paging trampoline.
function cfgProfilesRegression(makeCpu,image,bios,S,bank6,sample) {
 let checks=0;
 const assert=(v,s)=>{if(!v)throw Error(s);checks++;};
 const bytes=s=>Array.from(s,c=>c.charCodeAt(0)&255);
 const str=(m,p)=>{let s='';while(m[p])s+=String.fromCharCode(m[p++]);return s;};
 const word=(m,p)=>m[p]|m[p+1]<<8;
 const state=m=>[str(m,S.host_url),str(m,S.ftp_port),str(m,S.var_user),str(m,S.var_pasw),str(m,S.var_name),word(m,S.var_start),str(m,S.cfg_profile_name)];
 const same=(a,b)=>JSON.stringify(a)===JSON.stringify(b);
 const profile=(name,host='host',extra='')=>'Name='+name+'\nHost='+host+'\nPort=21\nUser=user\nPass=\nFile=\nStart='+extra+'\n';
 function run(text,keys,{missing=false,trampoline=false,hasDirectory=true,dispatch=false}={}) {
  let active=3,u,loads=0,redraws=0,pendingCursor=false,dispatchStarted=false,dispatchReturned=false,scrolls=0;const pages=[],views=[],messages=[],maps=[],cursors=[],titles=[],screens=[],nameDraws=[],tokens=new Map();
  const paint=(row,value)=>{for(let stripe=0;stripe<8;stripe++)u.m.fill(value,0x4800+stripe*256+row*32,0x4820+stripe*256+row*32);};
  const checkScreen=()=>{const names=Array.from(text.matchAll(/^Name=(.*)$/gm),m=>m[1].trim()).slice(0,32),top=u.m[S.cfg_top];for(let row=0;row<8;row++){const expected=tokens.get(names[top+row])||0;for(let stripe=0;stripe<8;stripe++)assert(Array.from(u.m.slice(0x4800+stripe*256+row*32,0x4820+stripe*256+row*32)).every(v=>v===expected),'bitmap row survives scrolling in every ZX stripe');}screens.push({top,index:u.m[S.cfg_selected],names:names.slice(top,top+8)});};
  const banks=Array.from({length:8},(_,i)=>new Uint8Array(16384).fill(i+32));banks[6].fill(0);banks[6].set(bank6);
  const map=n=>{banks[active].set(u.m.slice(0xc000));active=n;u.m.set(banks[n],0xc000);u.m[S.PAGE128_STATE]=16+n;maps.push(n);};
  const stop={};
  u=makeCpu([],bios,S,{image,hook:(pc,r)=>{
   if(pc>=0xc000&&pc<0xe000&&active!==6)throw Error('bank-6 instruction fetched with wrong bank mapped');
   if([S.send_string,S.print_working_directory,S.get_status_ftp].includes(pc))throw Error('profile browser sent a network command');
   if(pc===S.PAGE128){map(r.a&7);return {ret:true,a:16+active};}
   if(pc===S.cfg_read_file){loads++;assert(active===6,'CFG read in bank 6');if(missing)return {ret:true,carry:true};assert(text.length<=S.cfg_capacity,'test CFG fits');u.m.set(bytes(text+'\0'),S.cfg_file_here);return {ret:true,carry:false,hl:S.cfg_file_here,bc:text.length};}
   if(pc===S.KEYSCAN){if(dispatch&&!dispatchStarted){dispatchStarted=true;return {ret:true,a:103};}if(pendingCursor){const row=u.m[S.cfg_selected]-u.m[S.cfg_top];assert(Array.from(u.m.slice(0x5900,0x5a00)).every((v,i)=>v===(Math.floor(i/32)===row?56:7)),'existing cursor paints exactly one full-width row');assert(u.m[0x58ff]===0xa5&&u.m[0x5a00]===0xb6,'cursor does not spill outside list');assert(u.m[0x47ff]===0xc7&&u.m[0x5000]===0xd8,'scroll does not spill outside bitmap window');checkScreen();pendingCursor=false;}if(!keys.length)throw Error('unexpected extra keyboard wait');return {ret:true,a:keys.shift()};}
   if(pc===S.akey1)return {ret:true,a:13};
   if(pc===S.cls_9){pages.push([]);for(let row=0;row<8;row++)paint(row,0);return {ret:true};}
   if(pc===S.cfg_scroll)scrolls++;
   if(pc===S.prn_file_start){views.push(state(r.m));return {ret:true};}
   if(pc===S.prn_host_usr_psw||pc===S.clear_edit_zone)return {ret:true};
   if(pc===S.print_ez1||pc===S.PRINT){messages.push(str(r.m,r.de));return {ret:true};}
   if(pc===S.PRINTHL){if((r.hl>>8)>=8&&(r.hl>>8)<16&&r.de===S.cfg_profile_name){const name=str(r.m,r.de);pages[pages.length-1].push(name);nameDraws.push({name,row:(r.hl>>8)-8});if(!tokens.has(name))tokens.set(name,tokens.size+1);paint((r.hl>>8)-8,tokens.get(name));}else messages.push(str(r.m,r.de));if(r.hl===S.txt_adr_mezera)titles.push(str(r.m,r.de));return {ret:true};}
   if(pc===S.draw_cursor_row){const row=u.m[S.cfg_selected]-u.m[S.cfg_top];assert(active===6&&r.hl===0x5900+32*row&&(r.a===56||r.a===7),'shared cursor entry uses visible row without paging');if(r.a===56){cursors.push({row,index:u.m[S.cfg_selected]});pendingCursor=true;}}
   if(pc===S.print_page){redraws++;map(0);return {ret:true};}
   if(pc===S.draw_cursor)return {ret:true};
   if(dispatch&&pc===S.key_loop+8){assert(r.a===0&&r.stack.length===1,'CALL Z returns to the following key test with balanced stack and A=0');dispatchReturned=true;throw stop;}
   if(trampoline&&pc===S.key_loop&&(!dispatch||dispatchStarted))throw Error('G handler must RET to its CALL, not jump to key loop');
  }});
  u.m.set(bank6,0xc000);active=6;
  const before=state(u.m),directory=banks[0].slice(),other=banks[3].slice();
  u.m[S.flag1]|=16;u.m[S.flag_dir]=hasDirectory?1:0;u.m.set(bytes('old-server\0'),S.current_host);
  u.m[0x58ff]=0xa5;u.m[0x5a00]=0xb6;
  u.m[0x47ff]=0xc7;u.m[0x5000]=0xd8;
  const pointers=['cur_item_addr','cur_item_addr_page','item_pg_start','item_pg_start_page','cursor_w_curad','dir_list_pointer'];
  const positions=pointers.map(n=>word(u.m,S[n]));
  if(trampoline)map(3);
  let result;try{result=u.call(dispatch?S.key_loop:trampoline?S.cfg_choose_profile:S.cfg_browser);}catch(e){if(e!==stop)throw e;result={a:0};}
  if(dispatch)assert(dispatchReturned,'actual G key dispatch uses CALL Z');
  assert(loads===1,'G reloads CFG exactly once');
  assert(pointers.every((n,i)=>word(u.m,S[n])===positions[i]),'directory position and history preserved');
  assert(str(u.m,S.current_host)==='old-server'&&u.m[S.flag_dir]===(hasDirectory?1:0),'existing connection and directory validity unchanged');
  assert(same(Array.from(banks[0]),Array.from(directory)),'directory bank unchanged');
  assert(same(Array.from(banks[3]),Array.from(other)),'previous mapped bank unchanged');
  assert(titles.at(-1).trim()==='','profile title removed on exit');
  assert(Array.from(u.m.slice(0x5900,0x5a00)).every(v=>v===7),'no profile cursor remains after exit');
  if(trampoline){assert(result.a===0,'G returns A=0 and balances its CALL stack');assert(redraws===(hasDirectory?1:0),'cached listing redraw follows directory validity');assert(maps.slice(0,3).join(',')==='3,6,3','restore original map before directory redraw');}
  const after=state(u.m);if(active!==6)after[6]=str(banks[6],S.cfg_profile_name-0xc000);
  return {u,before,after,pages:pages.filter(p=>p.length),views,messages,keys,redraws,cursors,titles,screens,nameDraws,scrolls,reload:(nextText,nextKeys)=>{text=nextText;keys.push(...nextKeys);return u.call(S.cfg_browser);},loads:()=>loads};
 }
 let x=run(sample,[10,13]);
 assert(x.pages[0].join('|')===Array.from(sample.matchAll(/^Name=(.*)$/gm),m=>m[1].trim()).slice(0,8).join('|'),'first eight sample names listed without arrow prefixes');
 assert(x.titles.includes('Your profiles:'),'profile heading displayed');
 assert(x.after[0]==='192.168.0.105'&&x.after[1]==='21'&&x.after[5]===24576,'cursor selects and Enter keeps second sample profile');
 assert(x.views[0][0]==='sarah.speccy.cz'&&x.views[1][0]==='192.168.0.105','columns change as cursor moves');
 x=run(sample,[10,10,13]);
 assert(x.after[0]==='192.168.0.100'&&x.after[1]==='2121','Port changes with third profile');
 assert(x.after[4]===x.before[4]&&x.after[5]===x.before[5],'empty File/Start use entry settings, not prior preview');
 x=run(sample,[10,1]);assert(same(x.after,x.before),'BREAK restores every original setting');
 x=run(profile('original','one'),[13]);x.reload(profile('changed','two'),[13]);
 assert(x.loads()===2&&str(x.u.m,S.host_url)==='two'&&str(x.u.m,S.cfg_profile_name)==='changed','next G reloads changed CFG from disk');
 x.reload(profile('cancelled','three'),[1]);assert(str(x.u.m,S.host_url)==='two'&&str(x.u.m,S.cfg_profile_name)==='changed','BREAK after reload restores last accepted profile');
 x=run(profile('only'),[11,11,10,13]);assert(x.after[6]==='only'&&!x.keys.length,'arrows stop at both ends');
 x=run(';Name=comment\n  ; Name=fake\n'+profile('same','one')+profile('same','two'),[10,13]);assert(x.after[0]==='two','duplicate names and comments handled independently');
 x=run(profile('first','one')+profile('bad','')+profile('last','three'),[10,13,10,13]);
 assert(x.after[0]==='three'&&x.messages.includes('Invalid CFG profile'),'invalid profile cannot be accepted with Enter');
 assert(same(x.views[1].slice(0,6),x.before.slice(0,6)),'invalid preview leaves original columns');
 for(const text of ['', '; no profiles', 'Default=1\n;Name=ignored']){x=run(text,[]);assert(same(x.after,x.before),'no-profile CFG preserves settings');}
 x=run('',[],{missing:true});assert(same(x.after,x.before),'missing CFG preserves settings');
 const many=Array.from({length:260},(_,i)=>'Name=P'+i+'\nHost=h\nPort=1\nUser=\nPass=\nFile=\nStart=\n').join('');
 x=run(many,[...Array(259).fill(10),13]);assert(x.after[6]==='P31','32-profile limit stops at P31 even with 260 records');
 assert(x.pages.length===1&&x.nameDraws.length===32&&x.scrolls===24,'initial eight names then only one new name per scroll, no full redraw');
 assert(x.screens.some(p=>p.top===1&&p.names[0]==='P1'&&p.names.at(-1)==='P8'),'ninth profile scrolls by one row');assert(x.screens.at(-1).top===24&&x.cursors.at(-1).row===7,'last profile stays at bottom');
 x=run(many,[...Array(31).fill(10),...Array(31).fill(11),11,13]);assert(x.after[6]==='P0'&&x.scrolls===48,'scrolls back to top, including LDDR overlap');assert(x.nameDraws.length===56&&x.titles.filter(t=>t==='Your profiles:').length===1,'one new name per edge movement, heading printed once');
 x=run(many,[...Array(8).fill(10),11,10,11,...Array(7).fill(11),13]);assert(x.after[6]==='P0'&&x.scrolls===2,'direction reversal inside viewport avoids scrolling');
 x=run(many,[10,10,11,10,11,11,13]);assert(x.nameDraws.length===8&&x.scrolls===0,'movement inside viewport never redraws any name');
 x=run(sample,[10,10,11,13],{trampoline:true});assert(x.after[0]==='192.168.0.105','real trampoline keeps selection');
 x=run(sample,[10,1],{trampoline:true,hasDirectory:false});assert(same(x.after,x.before),'cancel without a directory');
 x=run(sample,[10,13],{trampoline:true,dispatch:true});assert(x.after[0]==='192.168.0.105','actual G key dispatch keeps selected profile');
 // Run the actual masked-password renderer: empty passwords must not DJNZ 256 times.
 for(const password of ['', 'abc']) {
  let chars=0;const u=makeCpu([],bios,S,{image,hook:(pc,r)=>{
   if(pc===S.cls_9_lines||pc===S.PRINTHL||pc===S.PRINT||pc===S.clear_edit_zone)return {ret:true};
   if(pc===S.CHAR){chars++;return {ret:true};}
  }});u.m[S.flag1]|=20;u.m.set(bytes(password+'\0'),S.var_pasw);u.call(S.prn_host_usr_psw);assert(chars===password.length,'masked password character count '+password.length);
 }
 return {checks};
}
if(typeof require!=='undefined'&&typeof module!=='undefined') {
 const fs=require('fs'),vm=require('vm');vm.runInThisContext(fs.readFileSync('tests/z80-directory.js','utf8'));
 const S={};for(const l of fs.readFileSync('directory-test.sym','utf8').split(/\r?\n/)){const m=l.match(/^v0\.(\S+): EQU 0x([0-9A-F]+)/i);if(m)S[m[1]]=parseInt(m[2],16);}
 const tape=fs.readFileSync('SARA_LOADER.tap'),blocks=[];for(let p=0;p<tape.length;){const n=tape.readUInt16LE(p);blocks.push(tape.subarray(p+2,p+2+n));p+=n+2;}
 console.log(cfgProfilesRegression(makeCpu,fs.readFileSync('SARAH12BSDhgfx'),fs.readFileSync('WifiBios20_MB_EL.cod'),S,blocks[5].subarray(1,-1),fs.readFileSync('sara.cfg','utf8')));
}
