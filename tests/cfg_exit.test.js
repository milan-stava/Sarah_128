// Execute G through real text rendering, directory redraw and the next idle loop.
function cfgExitRegression(makeCpu,image,bios,S,bank6,sample) {
 let checks=0;
 const assert=(v,s)=>{if(!v)throw Error(s);checks++;};
 const bytes=s=>Array.from(s,c=>c.charCodeAt(0)&255);
 const str=(m,p)=>{let s='';while(m[p])s+=String.fromCharCode(m[p++]);return s;};
 const put=(m,p,n)=>{m[p]=n&255;m[p+1]=n>>8;};
 const word=(m,p)=>m[p]|m[p+1]<<8;
 const fields=['host_url','ftp_port','var_user','var_pasw','var_name','var_start'];
 const settings=m=>fields.map(n=>n==='var_start'?word(m,S[n]):str(m,S[n]));
 const config=Array.from({length:12},(_,i)=>`Name=Profile ${i}\nHost=host${i}\nPort=${21+i}\nUser=user${i}\nPass=\nFile=\nStart=\n`).join('');
 for(const exit of [13,1])for(const hasDirectory of [false,true])for(const movement of [[],Array(10).fill(10)]) {
  let u,active=0,started=false,returned=false,idle=false,draws=0,loads=0;
  const maps=[],stop={},keys=[...movement,exit];
  const banks=Array.from({length:8},()=>new Uint8Array(16384));banks[6].set(bank6);
  // Two valid abbreviated directory records plus a zero end marker.
  banks[0].set([3,0,0,46,46,8,0,0,...bytes('old.txt'),0,0]);
  const directory=banks[0].slice(),unrelated=banks[3].slice();
  const map=n=>{banks[active].set(u.m.slice(0xc000));active=n;u.m.set(banks[n],0xc000);u.m[S.PAGE128_STATE]=16+n;maps.push(n);};
  u=makeCpu([],bios,S,{image,hook:(pc,r)=>{
   if(pc>=0xc000&&pc<0xe000&&active!==6)throw Error('execution outside mapped bank 6');
   if([S.send_string,S.send_ftp_command,S.print_working_directory,S.get_status_ftp,S.directory_retrieve].includes(pc))throw Error('profile exit performed a network operation');
   if(pc===S.error_handler||pc===S.error_handler_loop||pc===S.quit_program)throw Error('profile exit entered error/quit handler');
   if(pc===S.PAGE128){map(r.a&7);return {ret:true,a:16+active};}
   if(pc===S.cfg_read_file){loads++;u.m.set(bytes(config+'\0'),S.cfg_file_here);return {ret:true,carry:false};}
   if(pc===S.print_page)draws++;
   if(pc===S.KEYSCAN){
    if(!started){started=true;return {ret:true,a:103};}
    if(!returned){assert(keys.length>0,'browser has no unexpected keyboard wait');return {ret:true,a:keys.shift()};}
    assert(idle&&r.ix===S.flag1&&r.stack.length===2,'main loop returns to keyboard with balanced stack and IX');throw stop;
   }
   if(pc===S.key_loop+8){assert(r.a===0&&r.ix===S.flag1&&r.stack.length===1,'G exit balances CALL and consumes exit key');returned=true;}
   // Only the external empty UART is substituted. All rendering runs normally.
   if(returned&&(pc===S.rece_byte||pc===0xe0d7)){assert(!r.carry,'idle UART performs a status check');idle=true;return {ret:true,z:true};}
  }});
  u.m.set(banks[0],0xc000);u.m[S.PAGE128_STATE]=16;
  u.m[S.flag1]=16;u.m[S.flag_dir]=hasDirectory?1:0;
  put(u.m,S.cur_item_addr,0xc005);put(u.m,S.item_pg_start,0xc000);
  put(u.m,S.cur_item_addr_page,S.ftp_dir_page+1);put(u.m,S.item_pg_start_page,S.ftp_dir_page+1);
  put(u.m,S.cursor_w_curad,0x5920);u.m[S.wind_curs_item]=2;
  put(u.m,S.mark_counter,0);put(u.m,S.noop_timer+1,100);
  u.m.fill(0xa5,0x5b00,0x6000);
  const original=settings(u.m),code=u.m.slice(0x6000,0xbfe0);
  map(3);
  let caught=false;try{u.call(S.key_loop);}catch(e){if(e!==stop)throw e;caught=true;}
  assert(caught&&returned&&idle&&loads===1&&!keys.length,'G completes and reaches next idle keyboard scan');
  const after=settings(u.m),selected=movement.length;
  assert(exit===1?JSON.stringify(after)===JSON.stringify(original):after[0]==='host'+selected&&after[1]===String(21+selected)&&after[2]==='user'+selected,'BREAK restores all settings; ENTER keeps selected settings');
  assert(draws===(hasDirectory?1:0),'cached directory is redrawn only if valid');
  assert(maps.slice(0,3).join(',')==='3,6,3','original bank restored before directory drawing');
  assert(active===(hasDirectory?0:3),'final bank follows directory drawing or original mapping');
  assert(word(u.m,S.cur_item_addr)===0xc005&&word(u.m,S.item_pg_start)===0xc000&&word(u.m,S.cursor_w_curad)===0x5920,'real directory drawing preserves position');
  assert(banks[0].every((v,i)=>v===directory[i])&&banks[3].every((v,i)=>v===unrelated[i]),'directory and original bank remain intact');
  assert(u.m.slice(0x5b00,0x6000).every(v=>v===0xa5),'real text drawing does not overwrite system/stack area');
  // Printing updates documented operands, but must not rewrite the G trampoline.
  assert(u.m.slice(S.cfg_choose_profile,S.cfg_choose_profile+26).every((v,i)=>v===code[S.cfg_choose_profile-0x6000+i]),'G trampoline code remains intact');
 }
 return {checks};
}
if(typeof require!=='undefined'&&typeof module!=='undefined') {
 const fs=require('fs'),vm=require('vm');vm.runInThisContext(fs.readFileSync('tests/z80-directory.js','utf8'));
 const S={};for(const l of fs.readFileSync('directory-test.sym','utf8').split(/\r?\n/)){const m=l.match(/^v0\.(\S+): EQU 0x([0-9A-F]+)/i);if(m)S[m[1]]=parseInt(m[2],16);}
 const tape=fs.readFileSync('SARA_LOADER.tap'),blocks=[];for(let p=0;p<tape.length;){const n=tape.readUInt16LE(p);blocks.push(tape.subarray(p+2,p+2+n));p+=n+2;}
 console.log(cfgExitRegression(makeCpu,fs.readFileSync('SARAH12BSDhgfx'),fs.readFileSync('WifiBios20_MB_EL.cod'),S,blocks[5].subarray(1,-1),fs.readFileSync('sara.cfg','utf8')));
}
