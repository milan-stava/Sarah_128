// Execute assembled initialization routines with simulated baud/modem state.
function wifiInitializationRegression(makeCpu,image,bios,S) {
 let checks=0;
 const assert=(v,s)=>{if(!v)throw Error(s);checks++;};
 const bytes=s=>Array.from(s,c=>c.charCodeAt(0));
 const str=(m,p)=>{let s='';while(m[p])s+=String.fromCharCode(m[p++]);return s;};
 const fail={};
 function cpu(extra={}) {
  let caught=0;
  const u=makeCpu([],bios,S,{image,hook:(pc,r)=>{
   if(pc===S.error_handler){caught=r.bc&255;throw fail;}
   if(pc===S.wifi_wait||pc===S.wifi_unwait||pc===S.print_ftp_message)return {ret:true};
   return extra.hook&&extra.hook(pc,r);
  }});
  return Object.assign(u,{error:()=>caught});
 }
 for(const reply of ['OK\r\n','\r\nAT\r\nOK\r\n','ready\r\nOK\r\n']) {
  for(let split=0;split<=reply.length;split++) {
   const u=cpu(),input=bytes(reply+'NEXT');input.splice(split,0,...Array(30).fill(null));u.rx.push(...input);
   assert(u.call(S.at_probe_ok).z,'fragmented probe '+split);
   assert(String.fromCharCode(...u.rx.filter(x=>x!==null))==='NEXT','probe exact terminal boundary');
  }
 }
 for(const reply of ['', 'O','OK','OK\r','NOT OK\r\n','XOK\r\n','x'.repeat(500),
                     '+IPD,0,6:\r\nOK\r\n']) {
  const u=cpu();u.rx.push(...bytes(reply));
  assert(!u.call(S.at_probe_ok).z,'reject incomplete/noisy/binary probe '+reply.slice(0,20));
 }
 for(const [reply,event] of [['ERROR\r\n',2],['busy s...\r\n',6],['busy r...\r\n',6],['busy p...\r\n',6]]) {
  const u=cpu();u.rx.push(...bytes(reply));const r=u.call(S.at_probe_ok);
  assert(!r.z&&r.carry&&r.a===event,'explicit probe rejection '+reply);
 }
 for(const tries of [0,1,3]) {
  let u,sent=0;
  u=cpu({hook:(pc,r)=>{
   if(pc===S.send_string){sent++;assert(str(r.m,r.hl)==='AT\r\n','probe command');return {ret:true,z:true};}
  }});
  u.m[S.flag1+6]=tries;
  assert(!u.call(S.send_at_check_ok).z,'probe timeout is nonfatal');
  assert(sent===Math.max(tries,1),'bounded probe count '+tries);
 }
 {
  let u,sent=0;
  u=cpu({hook:(pc,r)=>{
   if(pc===S.send_string){if(++sent===2)u.rx.push(...bytes('AT\r\nOK\r\n'));return {ret:true,z:true};}
  }});
  u.m[S.flag1+6]=2;
  assert(u.call(S.send_at_check_ok).z&&sent===2,'safe AT retry succeeds');
 }
 {
  let u,sent=0;
  u=cpu({hook:(pc,r)=>{if(pc===S.send_string){sent++;u.rx.push(...bytes('busy p...\r\n'));return {ret:true,z:true};}}});
  u.m[S.flag1+6]=3;
  try{u.call(S.send_at_check_ok);}catch(e){if(e!==fail)throw e;}
  assert(u.error()===50&&sent===1,'busy does not start scanning other speeds');
 }
 {
  const u=cpu();u.rx.push(...bytes('x'.repeat(5000)));
  assert(u.call(S.at_probe_drain).carry&&u.rx.length===904,'drain budget');
 }
 for(const [maximum,target] of [[7,7],[12,12],[23,16]]) {
  let visited=0;
  const u=cpu({hook:(pc,r)=>{if(pc===S.set_ud_speed_a){visited++;assert(r.a===target,'automatic target '+maximum);}}});
  u.m[S.flag1+2]=255;u.m[S.flag1+8]=maximum;
  u.call(S.set_ud_speed,{de:target<<8});
  assert(visited===1,'automatic selection terminates '+maximum);
 }
 for(const [maximum,target] of [[7,7],[12,12],[23,16]]) {
  let visited=0;
  const u=cpu({hook:(pc,r)=>{if(pc===S.set_ud_speed_a){visited++;assert(r.a===target,'configured preference clamped '+maximum);}}});
  u.m[S.flag1+2]=16;u.m[S.flag1+8]=maximum;
  u.call(S.set_ud_speed,{de:target<<8});
  assert(visited===1,'configured preference terminates '+maximum);
 }
 for(const index of [17,23,24,255]) {
  const u=cpu();try{u.call(S.set_ud_speed_a,{a:index});}catch(e){if(e!==fail)throw e;}
  assert(u.error()===33,'no speed table overrun '+index);
 }
 {
  let sent=0;
  const u=cpu({hook:(pc,r)=>{if(pc===S.send_string){sent++;return {ret:true,z:true};}}});
  u.m[S.flag1+8]=7;
  try{u.call(S.set_ud_speed_a,{a:12});}catch(e){if(e!==fail)throw e;}
  assert(u.error()===32&&sent===0,'reject unsupported host baud before changing modem');
 }
 for(const known of [0,7,12,23]) {
  const u=cpu({hook:(pc,r)=>{if(pc===S.get_baud)return {ret:true,a:known,carry:false};}});
  const r=u.call(S.find_out_speed);
  assert(!r.carry&&(r.de>>8)===known,'read known baud '+known);
 }
 for(const accepted of [false,true]) {
  const u=cpu({hook:(pc,r)=>{
   if(pc===S.set_baud)return {ret:true,carry:!accepted};
   if(pc===S.print_speed)return {ret:true};
  }});
  assert(u.call(S.set_print_speed,{a:7}).carry===!accepted,'set_baud result survives printing');
 }
 {
  let u,selected=-1,requested=[],probed=[];
  u=cpu({hook:(pc,r)=>{
   if(pc===S.set_print_speed){requested.push(r.a);if(r.a!==2)selected=r.a;return {ret:true,carry:r.a===2};}
   if(pc===S.send_string){probed.push(selected);if(selected===1)u.rx.push(...bytes('OK\r\n'));return {ret:true,z:true};}
  }});
  u.m[S.flag1+8]=3;
  const r=u.call(S.switch_speed);
  assert(r.z&&(r.de>>8)===1,'scan finds a responding supported speed');
  assert(requested.join(',')==='3,2,1'&&probed.join(',')==='3,1','unsupported UART index is not probed');
 }
 {
  let requested=[];
  const u=cpu({hook:(pc,r)=>{
   if(pc===S.set_print_speed){requested.push(r.a);return {ret:true,carry:false};}
   if(pc===S.send_string)return {ret:true,z:true};
  }});
  u.m[S.flag1+8]=1;
  assert(!u.call(S.switch_speed).z&&requested.join(',')==='1,0','failed scan tests zero then terminates');
 }
 {
  const u=cpu({hook:(pc,r)=>{
   if(pc===S.get_baud)return {ret:true,carry:true};
   if(pc===S.switch_speed)return {ret:true,z:false,de:0};
  }});
  assert(u.call(S.find_out_speed).carry,'failed fallback is not a valid speed');
 }
 for(const [oldReply,newReply,error] of [['OK\r\n','OK\r\n',0],['','OK\r\n',0],
              ['ERROR\r\n','',31],['busy s...\r\n','',31],['OK\r\n','',31]]) {
  let u,changed=0,commands=[];
  u=cpu({hook:(pc,r)=>{
   if(pc===S.set_print_speed){changed++;assert(r.a===7,'install requested baud');return {ret:true,carry:false};}
   if(pc===S.send_string){const command=str(r.m,r.hl);commands.push(command);
    u.rx.push(...bytes(command.startsWith('AT+UART_CUR=')?oldReply:newReply));return {ret:true,z:true};}
  }});
  try{const r=u.call(S.set_ud_speed_a,{a:7,de:255<<8});assert(!r.carry,'verified baud change');}catch(e){if(e!==fail)throw e;}
  assert(u.error()===error,'baud result '+JSON.stringify([oldReply,newReply]));
  assert(commands[0]==='AT+UART_CUR=115200,8,1,0,0\r\n','UART command syntax');
  assert(changed===(oldReply.startsWith('ERROR')||oldReply.startsWith('busy')?0:1),'reject before changing UART');
  if(!error)assert(commands[1]==='AT\r\n','new baud positively verified');
 }
 for(const early of [false,true]) {
  for(const greeting of ['220 Ready\r\n','120 Later\r\n220 Ready\r\n',
                         '220-first\r\nintermediate\r\n220 Ready\r\n']) {
   let u,sent=0;
   const framed='+IPD,0,'+greeting.length+':'+greeting;
   u=cpu({hook:(pc,r)=>{
    if(pc===S.send_string){if(++sent===2)u.rx.push(...bytes('0,CONNECT\r\n'+(early?framed+'OK\r\n':'OK\r\n'+framed)));return {ret:true,z:true};}
   }});
   u.m.set(bytes('0,"TCP","192.168.0.2",21\r\n\0'),S.TX_buf);
   assert(!u.call(S.cipstart_connect).carry,'connection accepted');
   u.call(S.fl2);
   assert(u.rx.length===0&&u.m[S.ftp_control_left]===0,'complete greeting '+early+' '+greeting.slice(0,9));
  }
 }
 for(const [reply,expected] of [['1,CLOSED\r\n',S.key_loop],['+IPD,0,14:421 Shutdown\r\n',S.error_handler_loop]]) {
  const stop={};let reached=false;
  const u=cpu({hook:(pc,r)=>{if(pc===expected){reached=true;throw stop;}}});
  u.rx.push(...bytes(reply));
  try{u.call(S.kl8);}catch(e){if(e!==stop)throw e;}
  assert(reached&&u.rx.length===0,'idle protocol notification '+reply.slice(0,10));
  if(reply.startsWith('1,CLOSED'))assert(u.m[S.at_closed]&2,'idle close tracked');
 }
 {
  const stop={};let exited=false,cleanup=0;
  const u=makeCpu([],bios,S,{image,hook:(pc,r)=>{
   if(pc===S.set_3_5mhz||pc===S.display_error||pc===S.wifi_unwait)return {ret:true};
   if(pc===S.passive_receive_off){cleanup++;throw Error('cleanup at unknown baud');}
   if(pc===S.quit_keep_directory){exited=true;throw stop;}
  }});
  u.m[S.flag1]&=~64;
  try{u.call(S.error_handler,{bc:50});}catch(e){if(e!==stop)throw e;}
  assert(exited&&cleanup===0&&u.m[S.error_recovering]===0,'uninitialized error exits without UART cleanup');
 }
 return {checks};
}
if(typeof require!=='undefined'&&typeof module!=='undefined') {
 const fs=require('fs'),vm=require('vm');
 vm.runInThisContext(fs.readFileSync('tests/z80-directory.js','utf8'));
 const S={};for(const line of fs.readFileSync('directory-test.sym','utf8').split(/\r?\n/)) {
  const m=line.match(/^v[01]\.(\S+): EQU 0x([0-9A-F]+)/i);if(m)S[m[1]]=parseInt(m[2],16);
 }
 console.log(wifiInitializationRegression(makeCpu,fs.readFileSync('SARAH12BSDhgfx'),fs.readFileSync('WifiBios20_MB_EL.cod'),S));
}
