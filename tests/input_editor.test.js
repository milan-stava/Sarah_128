// Real assembled INPUT, insertion/deletion and setters; keyboard/CHAR are external.
function inputEditorRegression(makeCpu,image,bios,S) {
 let checks=0;
 const assert=(v,s)=>{if(!v)throw Error(s);checks++;};
 const bytes=s=>Array.from(s,c=>c.charCodeAt(0));
 const put=(m,p,s)=>m.set(bytes(s+'\0'),p);
 const str=(m,p,n=256)=>{let s='';while(m[p]&&n--)s+=String.fromCharCode(m[p++]);return s;};
 const text=m=>str(m,S.INPBUFF).trimEnd();
 function run({initial='',keys=[13],entry='input_line_edit',mask=false,limit=63,setup,regs={},realDraw=false}={}) {
  let u,chars=[],frames=[],snapshots=[],cancelled=false,done=false;const stop={};
  const queue=keys.slice();
  u=makeCpu([],bios,S,{image,hook:(pc,r)=>{
   if(pc===S.WTKY)return {ret:true};
   if(pc===S.CHAR){chars.push(r.a);if(!realDraw)return {ret:true,hl:(r.hl&0xff00)|((r.hl+1)&255)};}
   if(pc===S.KEYSCAN){frames.push(chars);chars=[];snapshots.push({text:text(r.m),raw:Array.from(r.m.slice(S.INPBUFF,S.INPBUFF+64)),cursor:r.m[S.CURSOR+1]});if(!queue.length)throw Error('unexpected keyboard wait');return {ret:true,a:queue.shift(),bc:0x1c55};}
   if([S.print_ez1,S.prn_host_usr_psw,S.prn_file_start].includes(pc))return {ret:true};
   if(pc===S.clear_ini_keyl){cancelled=true;throw stop;}
   if([S.send_string,S.directory_retrieve].includes(pc))throw Error('input setter performs network operation');
  }});
  u.m[S.flag1]=16|(mask?4:0);put(u.m,0xb000,initial);
  u.m[S.INPBUFF-1]=0xa5;u.m[S.INPBUFF+256]=0xb6;
  // Dirty tail catches scans accidentally returning old CFG/profile data.
  u.m.fill(0x7a,S.INPBUFF,S.INPBUFF+256);
  if(setup)setup(u.m);
  let result;try{result=u.call(S[entry],{de:0xb000,bc:limit,...regs});done=true;}catch(e){if(e!==stop)throw e;}
  assert(done||cancelled,'editor returns or takes explicit cancel path');
  assert(u.m[S.INPBUFF-1]===0xa5&&u.m[S.INPBUFF+256]===0xb6,'editor writes stay inside input buffer');
  assert(!queue.length,'all requested keys consumed');
  assert(u.m[S.INPBUFF+63]===0&&u.m[S.INPBUFF+255]===0,'fixed terminators survive edits');
  if(result)assert(result.ix===S.flag1,'IX restored after editor');
  return {u,result,frames,snapshots,cancelled,text:text(u.m)};
 }
 let x=run({initial:'server.example'});assert(x.text==='server.example'&&!x.result.z&&x.result.bc===14,'unchanged prefilled value accepted');assert(x.snapshots[0].cursor===14,'cursor starts at end');
 x=run({initial:'abcd',keys:[8,8,88,13]});assert(x.text==='abXcd'&&x.result.bc===5,'inserts into middle without overwriting suffix');
 x=run({initial:'abcd',keys:[8,12,13]});assert(x.text==='abd','backspace removes character before cursor');
 x=run({initial:'abcd',keys:[8,8,15,13]});assert(x.text==='abd','forward delete removes character under cursor');
 x=run({initial:'abcd',keys:[8,8,8,8,12,13]});assert(x.text==='abcd'&&!x.result.z&&x.result.bc===4,'ENTER at column zero keeps nonempty value; backspace at start is safe');
 x=run({initial:'old',keys:[199,110,101,119,13]});assert(x.text==='new'&&x.snapshots[1].cursor===0,'SS+Q clears value instead of reloading it');
 x=run({initial:'ignored',entry:'input_line'});assert(x.text===''&&x.result.z,'new-value entry starts empty');
 x=run({initial:'old',keys:[199,13]});assert(x.text===''&&x.result.z&&x.result.bc===0,'empty ordinary field is not applied');
 x=run({initial:'x'.repeat(80),entry:'input_line_edit_limit',limit:5,keys:[89,13]});assert(x.text==='xxxxx'&&x.result.bc===5,'field-specific limit bounds initial value and typing');
 x=run({initial:'abcde',entry:'input_line_edit_limit',limit:5,keys:[8,8,90,13]});assert(x.text==='abcde','insertion in a full field preserves its suffix');
 x=run({initial:'abcde',entry:'input_line_edit_limit',limit:5,keys:[8,8,15,90,13]});assert(x.text==='abcZe','delete frees space for insertion inside a full field');
 x=run({initial:'a'.repeat(63),keys:[90,...Array(63).fill(8),...Array(64).fill(15),13]});assert(x.text===''&&x.result.bc===0,'full-buffer insertion/deletion stays bounded');
 x=run({keys:[...Array(70).fill(65),13]});assert(x.text==='A'.repeat(63)&&x.result.bc===63,'63 visible characters plus cursor, no overflow');
 for(const key of [1,4]){x=run({initial:'old',keys:[199,120,key]});assert(x.result.z&&x.result.a===4,'BREAK/legacy code 4 cancels '+key);}
 for(const mask of [false,true])for(const keys of [[13],[199,13],[199,110,101,119,13],[199,1],[199,4]]) {
  x=run({entry:'set_pass',mask,keys,setup:m=>put(m,S.var_pasw,'Secret')});
  const cancel=keys.at(-1)!==13,expected=cancel?'Secret':keys.length===1?'Secret':keys.length===2?'':'new';
  assert(str(x.u.m,S.var_pasw)===expected&&x.cancelled===cancel,'password confirmed/empty/cancelled '+mask+'/'+keys);
  assert(x.u.m[S.INX_HS+1]===0,'password masking restored before subsequent inputs');
  if(mask){assert(x.snapshots[0].raw.slice(0,6).every(v=>v&128),'prefilled password masked in editor');assert(!x.frames.flat().some(v=>v===83||v===101||v===99||v===114||v===116),'password letters never sent to CHAR');}
  assert(x.u.m.slice(S.var_pasw,S.var_pasw+32).every(v=>v<128),'stored password has no display-mask bits');
 }
 x=run({entry:'set_pass',mask:true,keys:[8,8,90,13],setup:m=>put(m,S.var_pasw,'Secret')});assert(str(x.u.m,S.var_pasw)==='SecrZet','masked original and newly inserted characters retain their real values');
 // ZX CHAR also runs directly in these cases; HGFX needs actual hardware VRAM.
 if(!S.set_hgfx_ink_planar)for(const mask of [false,true]) {
  x=run({entry:'set_pass',mask,realDraw:true,keys:[8,12,90,13],setup:m=>put(m,S.var_pasw,'Secret')});assert(str(x.u.m,S.var_pasw)==='SecrZt','real ZX character renderer preserves editor registers and masking');
 }
 for(const [entry,field,value] of [['change_host','host_url','old.host'],['set_user','var_user','old-user'],['set_filename','var_name','file.bin']])for(const keys of [[13],[199,110,13],[199,1],[199,13]]) {
  x=run({entry,keys,setup:m=>put(m,S[field],value)});
  const cancel=keys.at(-1)!==13||keys.length===2;
  assert(str(x.u.m,S[field])===(cancel||keys.length===1?value:'n'),'setter preserves/changes current value '+entry+'/'+keys);
  assert(x.snapshots[0].text===value,'setter prefilled '+entry);
 }
 for(const value of [0,1,24576,65535]){x=run({entry:'set_start',setup:m=>{m[S.var_start]=value&255;m[S.var_start+1]=value>>8;}});assert(x.snapshots[0].text===String(value)&&(x.u.m[S.var_start]|x.u.m[S.var_start+1]<<8)===value,'numeric address roundtrip '+value);}
 for(const [command,expected] of [['SIZE ','remote.bin'],['USER ','name'],['PASS ','secret'],['RNTO ','old-name'],['MKD ','']]) {
  x=run({entry:'input_ftp_parameter',keys:[13],setup:m=>{put(m,S.TX_buf,command);put(m,S.var_name,'remote.bin');put(m,S.var_user,'name');put(m,S.var_pasw,'secret');put(m,S.INPBUFF,'old-name');}});
  assert(x.snapshots[0].text===expected,'FTP command selects correct initial value '+command);
 }
 // The actual command builder must send an empty PASS without a 65536-byte LDIR.
 for(const mask of [false,true])for(const mode of [1,2]) {
  let u,wire,keys=[199,13];const stop={};
  u=makeCpu([],bios,S,{image,hook:(pc,r)=>{
   if(pc===S.WTKY)return {ret:true};
   if(pc===S.CHAR)return {ret:true,hl:(r.hl&0xff00)|((r.hl+1)&255)};
   if(pc===S.KEYSCAN)return {ret:true,a:keys.shift()};
   if(pc===S.clear_edit_zone)return {ret:true};
   if(pc===S.cipsend_request){wire=str(r.m,S.TX_buf);throw stop;}
  }});u.m[S.flag1]=16|(mask?4:0);put(u.m,S.var_pasw,'Secret');u.call(S.clear_inp_buf);
  try{u.call(S.send_ftp_command,{a:mode,hl:S.ftp_pass,de:230});}catch(e){if(e!==stop)throw e;}
  assert(wire==='PASS \r\n','manual/automatic empty PASS has correct wire framing '+mode+'/'+mask);
 }
 // Empty/short automatic password must not inherit username or old buffer tail.
 for(const password of ['', 'x', 'much-longer-password']) {
  const u=makeCpu([],bios,S,{image});put(u.m,S.var_pasw,password);u.m.fill(0x61,S.INPBUFF,S.INPBUFF+256);u.call(S.prepare_ftp_value,{hl:S.var_pasw});const result=u.call(S.input_l_count);assert(result.bc===password.length&&str(u.m,S.INPBUFF)===password,'automatic password prepared with exact length '+password.length);
 }
 // Exercise the actual automatic/manual login path, not only separate helpers.
 for(const manual of [false,true]) {
  let u;const wires=[],queue=[13,199,13],stop={};
  u=makeCpu([],bios,S,{image,hook:(pc,r)=>{
   if(pc===S.WTKY||pc===S.print_ez1||pc===S.clear_edit_zone)return {ret:true};
   if(pc===S.CHAR)return {ret:true,hl:(r.hl&0xff00)|((r.hl+1)&255)};
   if(pc===S.KEYSCAN){assert(manual&&queue.length>0,'manual login consumes only requested keys');return {ret:true,a:queue.shift()};}
   if(pc===S.cipsend_request){wires.push(str(r.m,S.TX_buf));const expected=r.stack.pop();return {ret:true,carry:false,hl:expected};}
   if(pc===S.get_status_ftp)return {ret:true,z:true};
   if(pc===S.directory_retrieve)throw stop;
   if(pc===S.error_handler)throw Error('login unexpectedly failed');
  }});u.m[S.flag1]=20;put(u.m,S.var_user,'username');put(u.m,S.var_pasw,manual?'old-secret':'');
  try{u.call(manual?S.fl_usr_psw:S.al_user_pass);}catch(e){if(e!==stop)throw e;}
  assert(JSON.stringify(wires)===JSON.stringify(['USER username\r\n','PASS \r\n']),'complete login sends username then empty password '+manual);
  assert(u.m[S.INX_HS+1]===0,'complete login restores ordinary input mask');
 }
 return {checks};
}
if(typeof require!=='undefined'&&typeof module!=='undefined') {
 const fs=require('fs'),vm=require('vm');vm.runInThisContext(fs.readFileSync('tests/z80-directory.js','utf8'));
 const S={};for(const l of fs.readFileSync('directory-test.sym','utf8').split(/\r?\n/)){const m=l.match(/^v0\.(\S+): EQU 0x([0-9A-F]+)/i);if(m)S[m[1]]=parseInt(m[2],16);}
 console.log(inputEditorRegression(makeCpu,fs.readFileSync('SARAH12BSDhgfx'),fs.readFileSync('WifiBios20_MB_EL.cod'),S));
}
