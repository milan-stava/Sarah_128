// Executes assembled bank-6 code; only the external BS-DOS service is stubbed.
function cfgRegression(makeCpu,image,bios,S,bank6,sample) {
 let checks=0;
 const assert=(v,s)=>{if(!v)throw Error(s);checks++;};
 const bytes=s=>Array.from(s,c=>c.charCodeAt(0)&255);
 const str=(m,p)=>{let s='';while(m[p])s+=String.fromCharCode(m[p++]);return s;};
 const word=(m,p)=>m[p]|m[p+1]<<8;
 const targets=['host_url','ftp_port','var_user','var_pasw','var_name','var_start'];
 const snapshot=u=>targets.map((n,i)=>Array.from(u.m.slice(S[n],S[n]+[46,6,37,38,67,2][i])));
 const same=(a,b)=>JSON.stringify(a)===JSON.stringify(b);
 const profile=(overrides={})=>Object.entries({Default:'1',Name:'Home Lenovo',Host:'192.168.0.105',Port:'21',User:'hood',Pass:'',File:'SARAH12BSD',Start:'24576',...overrides}).map(([k,v])=>k+'='+v).join('\n');
 const make=hook=>{const u=makeCpu([],bios,S,{image,hook});u.m.set(bank6,0xc000);return u;};
 const run=(text,hook)=>{const u=make(hook);u.m.set(bytes(text),S.cfg_file_here);const before=snapshot(u);const r=u.call(S.parse_cfg,{hl:S.cfg_file_here,bc:text.length});return {u,r,before};};
 const unchanged=x=>assert(same(snapshot(x.u),x.before),'invalid CFG keeps all settings');
 function selected(x) {
  assert(!x.r.carry,'valid default accepted');
  for(const [n,v] of Object.entries({cfg_profile_name:'Home Lenovo',host_url:'192.168.0.105',ftp_port:'21',var_user:'hood',var_pasw:'',var_name:'SARAH12BSD'}))assert(str(x.u.m,S[n])===v,'selected '+n);
  assert(word(x.u.m,S.var_start)===24576,'selected Start=24576');
 }
 selected(run(sample));
 for(const eol of ['\n','\r','\r\n'])for(const finalEol of ['',eol]) {
  selected(run(('; comment\n \t; indented comment\n\n'+profile({Default:'0',Host:'ignored'})+'\n'+profile()+'\n'+profile({Host:'later'})).replace(/\n/g,eol)+finalEol));
 }
 for(const eof of ['', '\n'])for(const start of ['0','1','32768','65535']) {
  const x=run(profile({Start:start})+eof);assert(!x.r.carry&&word(x.u.m,S.var_start)===+start,'numeric Start '+start);
 }
 for(const port of ['1','65535']){const x=run(profile({Port:port}));assert(!x.r.carry&&str(x.u.m,S.ftp_port)===port,'numeric Port '+port);}
 for(const text of ['', '; no profiles',profile({Default:'0'}),profile({Default:'10'}),'Default=1\n']){const x=run(text);assert(x.r.carry,'no valid complete default');unchanged(x);}
 for(const [field,value] of [['Host',''],['Host','h'.repeat(46)],['Name','n'.repeat(32)],['User','u'.repeat(32)],['Pass','p'.repeat(32)],['File','f'.repeat(57)],['Port',''],['Port','0'],['Port','65536'],['Port','99999'],['Port','21x'],['Port','-1'],['Start','65536'],['Start','99999'],['Start','-1'],['Start','x'],['Start','24576x']]) {
  const x=run(profile({[field]:value}));assert(x.r.carry,'reject invalid '+field+'='+value);unchanged(x);
 }
 for(const text of [profile().replace('Host=','Wrong='),profile().replace('Pass=\n',''),profile().replace('File=SARAH12BSD\n',''),profile().replace(/Start=.*/,''),profile().replace('Port=21\nUser=hood','User=hood\nPort=21')]){const x=run(text);assert(x.r.carry,'reject missing/wrong/reordered key');unchanged(x);}
 for(const field of ['Name','Host','Port','User','Pass','File','Start']) {
  const complete=profile();const p=complete.indexOf(field+'=');const stop=p+field.length+1;
  for(let i=p;i<stop;i++){const x=run(complete.slice(0,i));assert(x.r.carry,'truncated key '+field);unchanged(x);}
 }
 const optional=run(profile({File:'',Start:''}));assert(!optional.r.carry,'empty optional fields accepted');
 assert(same(Array.from(optional.u.m.slice(S.var_name,S.var_name+67)),optional.before[4]),'empty File preserved');
 assert(same(Array.from(optional.u.m.slice(S.var_start,S.var_start+2)),optional.before[5]),'empty Start preserved');
 const limits=run(profile({Name:'n'.repeat(31),Host:'h'.repeat(45),User:'u'.repeat(31),Pass:'p'.repeat(31),File:'f'.repeat(56),Start:'65535',Port:'65535'}));
 assert(!limits.r.carry,'maximum field lengths fit');assert(str(limits.u.m,S.var_user)==='u'.repeat(31),'Host terminator does not damage User');
 for(const text of [profile(),profile({File:'name=with=equals',Pass:'a=b;c'})]){const x=run(text);assert(!x.r.carry,'equals inside values');}
 const sizes=[0,1,...Array.from({length:15},(_,i)=>[1024*(i+1)-1,1024*(i+1),1024*(i+1)+1]).flat(),S.cfg_capacity,S.cfg_capacity+1,65536,65537,0xffffffff];
 for(const len of sizes)for(const failure of ['none',...(len===1025?['missing','search-abort','position-abort','header','header-abort','load']:[])]) {
  let loads=0,services=[];const text=profile();let u;
  u=make((pc,r)=>{
   if(pc!==S.bsdos)return;
   services.push(r.a);
   if(r.a===S.seasx){assert(String.fromCharCode(...r.m.slice(r.hl,r.hl+10))==='sara.cfg  ','BS-DOS padded filename');return {ret:true,z:failure!=='missing',carry:failure!=='search-abort'};}
   if(r.a===S.getcst)return {ret:true,hl:7,carry:failure!=='position-abort'};
   if(r.a===S.getsub){assert(r.bc===7&&r.ix===S.header,'GETSUB file/header');for(let j=0;j<4;j++)r.m[S.blen+j]=(len/2**(8*j))&255;r.m[S.flen]=0xff;r.m[S.flen+1]=0xff;return {ret:true,z:failure==='header',carry:failure!=='header-abort',ix:0x7777,iy:0x8888};}
   if(r.a===S.loa1x){loads++;assert(r.hl===7&&r.bc===0&&r.ix===S.cfg_file_here&&(r.de&255)===Math.ceil(len/1024),'LOA1X correct file, destination, sectors');u.m.fill(32,S.cfg_file_here,S.cfg_file_here+len);u.m.set(bytes(text.slice(0,len)),S.cfg_file_here+Math.max(0,len-text.length));return {ret:true,carry:failure!=='load',ix:0x9999,iy:0xaaaa};}
   throw Error('unexpected BS-DOS service '+r.a);
  });
  const before=snapshot(u),beforeBank=Array.from(u.m.slice(0xc000,S.cfg_file_here));u.m[0xbfff]=0xa5;
  const r=u.call(S.load_cfg);
  assert(r.ix===S.flag1&&r.iy===0,'load_cfg preserves IX and IY');
  assert(u.m[0xbfff]===0xa5,'loading stays above fixed main code');
  assert(same(Array.from(u.m.slice(0xc000,S.cfg_next_line)),beforeBank.slice(0,S.cfg_next_line-0xc000)),'loading preserves bank-6 routines');
  const expected=len>0&&len<=S.cfg_capacity&&failure==='none';
  // One byte cannot hold a profile; a full profile padded with spaces is valid.
  if(expected&&len>=text.length){assert(!r.carry,'valid disk CFG loaded '+len);assert(u.m[S.cfg_file_here+len]===0,'sentinel at start+length');}
  else {assert(r.carry,'invalid disk CFG rejected '+len+'/'+failure);assert(same(snapshot(u),before),'failed disk CFG keeps settings');}
  assert(loads===(len>0&&len<=S.cfg_capacity&&!['missing','search-abort','position-abort','header','header-abort'].includes(failure)?1:0),'size/failure checked before data load');
 }
 // Pointer wrap must not write into ROM/low RAM.
 {const u=make(),before=u.m[0x10];const r=u.call(S.parse_cfg,{hl:0xfff0,bc:32});assert(r.carry&&u.m[0x10]===before,'reject wrapping buffer');}
 return {checks};
}
if(typeof require!=='undefined'&&typeof module!=='undefined') {
 const fs=require('fs'),vm=require('vm');vm.runInThisContext(fs.readFileSync('tests/z80-directory.js','utf8'));
 const S={};for(const l of fs.readFileSync('directory-test.sym','utf8').split(/\r?\n/)){const m=l.match(/^v0\.(\S+): EQU 0x([0-9A-F]+)/i);if(m)S[m[1]]=parseInt(m[2],16);}
 const tape=fs.readFileSync('SARA_LOADER.tap'),blocks=[];for(let p=0;p<tape.length;){const n=tape.readUInt16LE(p);blocks.push(tape.subarray(p+2,p+2+n));p+=n+2;}
 console.log(cfgRegression(makeCpu,fs.readFileSync('SARAH12BSDhgfx'),fs.readFileSync('WifiBios20_MB_EL.cod'),S,blocks[5].subarray(1,-1),fs.readFileSync('sara.cfg.txt','utf8')));
}
