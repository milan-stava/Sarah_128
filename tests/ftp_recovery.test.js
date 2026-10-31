// Real recovery/error handler, CIPSTATUS parser and stored-credential login flow.
function ftpRecoveryRegression(makeCpu,image,bios,S) {
 let checks=0;
 const assert=(ok,msg)=>{if(!ok)throw Error(msg);checks++;},stop={};
 const bytes=s=>Array.from(s,c=>c.charCodeAt(0)),text=(m,p)=>{let s='';while(m[p])s+=String.fromCharCode(m[p++]);return s;};
 const word=(m,p)=>m[p]|m[p+1]<<8,put=(m,p,v)=>{m[p]=v&255;m[p+1]=v>>8;};
 function run({entry='error_handler',error=36,close='OK',login=true,data=false,control=true,known=true}={}) {
  let u,closed=0,connects=0,refreshes=0,off=0,displays=[],commands=[],at=[],atCommand='',idle=false,quit=false,clears=0;
  let liveControl=control,liveData=data;
  const feed=s=>u.rx.push(...bytes(s).flatMap(v=>[null,null,v]));
  u=makeCpu([],bios,S,{image,hook(pc,r){
   if(pc===S.KEYSCAN||pc===S.key_loop){idle=true;throw stop;}
   if(pc===S.quit_keep_directory){quit=true;throw stop;}
   if(pc===S.set_3_5mhz||pc===S.wifi_unwait||pc===S.PRINTHL||pc===S.print_ftp_status||pc===S.clear_edit_zone)return {ret:true};
   if(pc===S.display_error){displays.push(r.bc&255);return {ret:true};}
   if(pc===S.cls_9){clears++;return {ret:true};}
   if(pc===S.print_title)return {ret:true};
   if(pc===S.ftp_upload_file||pc===S.ftp_upl_loop)throw Error('recovery replayed upload');
   if(pc===S.send_string){
    atCommand+=text(r.m,r.hl);
    if(atCommand.endsWith('\r\n')) {
     at.push(atCommand);
     if(atCommand==='AT+CIPSTATUS\r\n') {
      const status=liveControl||liveData?3:4;
      feed('STATUS:'+status+'\r\n'+(liveControl?'+CIPSTATUS:0,"TCP","127.0.0.1",21,1234,0\r\n':'')+(liveData?'+CIPSTATUS:1,"TCP","127.0.0.1",3210,1235,0\r\n':'')+'OK\r\n');
     } else if(atCommand==='AT+CIPCLOSE=5\r\n'){
      closed++;assert(r.m[S.error_recovering]===2,'close guarded against recursive recovery');
      assert(!(r.m[S.flag1]&32)&&!(r.m[S.flag_dir]&1),'invalidate connection/cache before network cleanup');
      if(close==='OK'||close==='queued'){
       liveControl=false;liveData=false;
       const old='226 Previous transfer\r\n';
       feed((close==='queued'?'+IPD,0,'+old.length+':'+old:'')+'1,CLOSED\r\n0,CLOSED\r\nOK\r\n');
      }
      else if(close==='already-closed'){liveControl=false;liveData=false;feed('ERROR\r\n');}
      else if(close==='timeout'){r.m.set([0x0e,48,0xc3,S.error_handler&255,S.error_handler>>8],S.at_next_event);}
      else feed(close+'\r\n');
     } else if(atCommand==='AT+CIPRECVMODE=0\r\n'){off++;feed('OK\r\n');}
     else throw Error('unexpected recovery AT '+atCommand);
     atCommand='';
    }
    return {ret:true,z:true};
   }
   if(pc===S.connect_to_ftp_server){
    connects++;assert(closed===1&&off===1,'close old connections and active receive before reconnect');
    assert(r.m[S.ftp_control_left]===0&&word(r.m,S.at_payload_left)===0,'old FTP payload cannot reach new login');
    assert(text(r.m,S.host_url)==='127.0.0.1','configured host retained');
    if(login==='silent-server'){r.m.set([0x0e,48,0xc3,S.error_handler&255,S.error_handler>>8],pc);return;}
    liveControl=true;r.m[S.at_closed]=2;return {ret:true};
   }
   if(pc===S.send_ftp_command){
    const verb=text(r.m,r.hl),param=text(r.m,S.INPBUFF).trimEnd();commands.push(verb);
    if(verb==='NOOP')return {ret:true,hl:200,carry:false};
    if(verb==='USER '){assert(param==='test-user','stored username reused');return {ret:true,hl:login?331:530,carry:!login,bc:4};}
    if(verb==='PASS '){assert(param==='test-pass','stored password reused');return {ret:true,hl:login==='bad-pass'?530:230,carry:login==='bad-pass',bc:4};}
    throw Error('unexpected recovery FTP '+verb);
   }
   if(pc===S.directory_retrieve){refreshes++;r.m[S.flag_dir]|=1;return {ret:true};}
  }});
  u.m[S.flag1]=16|32|(known?64:0);u.m[S.flag_dir]=1;
  for(const [name,value]of [['host_url','127.0.0.1'],['var_user','test-user'],['var_pasw','test-pass']])u.m.set(bytes(value+'\0'),S[name]);
  put(u.m,S.dir_list_pointer,S.dir_list_start+6);
  // Old queued FTP replies must not become replies to the new USER/PASS.
  if(entry==='error_handler')u.rx.push(...bytes('stale 226 Transfer OK\r\n'));
  try{u.call(S[entry],{bc:error});}catch(e){if(e!==stop)throw e;}
  return {u,closed,connects,refreshes,off,displays,commands,at,idle,quit,clears};
 }
 for(const error of [4,16,36,43,48,49]) {
  const r=run({error});
  assert(r.idle&&r.closed===1&&r.connects===1&&r.refreshes===1,'one reconnect after communication error '+error);
  assert(r.displays.length===0&&r.u.m[S.error_recovering]===0,'successful automatic recovery is silent and resets guard');
  assert(r.commands.includes('USER ')&&r.commands.includes('PASS '),'reauthenticate before directory');
  assert(word(r.u.m,S.dir_list_pointer)===S.dir_list_start,'new session resets history');
 }
 for(const control of [false,true]) {
  const r=run({entry:'get_status_ftp',data:true,control});
  assert(r.closed===1&&r.connects===1&&r.idle,'startup drops orphaned data socket');
  assert(r.at[0]==='AT+CIPSTATUS\r\n'&&r.at[1]==='AT+CIPCLOSE=5\r\n','close before NOOP/TYPE/PASV on old session');
 }
 {
  const r=run({entry:'get_status_ftp'});
  assert(!r.idle&&!r.closed&&!r.connects,'healthy control connection retained');
  assert(r.commands.join(',')==='NOOP','healthy startup probes existing login only');
 }
 for(const close of ['ERROR','busy p...','timeout']) {
  const r=run({close});
  assert(r.idle&&r.closed===1&&r.connects===0,'failed close never retries or loops '+close);
  assert(r.displays.length===1&&r.u.m[S.error_recovering]===0,'one final error after failed cleanup');
  assert(r.u.m[S.ftp_last_error]===36,'original failure retained across cleanup errors');
  assert(!(r.u.m[S.flag1]&32)&&!(r.u.m[S.flag_dir]&1),'offline keyboard after failed cleanup');
  assert(r.clears>0,'failed recovery removes stale directory display');
 }
 for(const close of ['already-closed','queued']) {
  const r=run({close});assert(r.idle&&r.connects===1&&r.refreshes===1&&!r.displays.length,'verified closed/pending old reply recovery '+close);
 }
 {
  const r=run({login:false});
  assert(r.closed===1&&r.connects===1&&r.refreshes===0&&r.idle,'failed USER does not restart reconnect');
  assert(r.commands.filter(v=>v==='USER ').length===1&&!r.commands.includes('PASS '),'no USER loop after failed retry');
  assert(r.displays.join(',')==='4','failed reauthentication shown once');
 }
 {
  const r=run({login:'bad-pass'});
  assert(r.closed===1&&r.connects===1&&!r.refreshes&&r.idle,'wrong stored password ends retry');
  assert(r.commands.filter(v=>v==='PASS ').length===1&&r.displays.join(',')==='4','no manual password prompt or retry loop');
 }
 {
  const r=run({login:'silent-server'});
  assert(r.closed===1&&r.connects===1&&!r.refreshes&&r.idle,'unresponsive server does not restart recovery');
  assert(r.displays.join(',')==='48','final connection timeout displayed once');
 }
 {
  const r=run({known:false});assert(r.quit&&r.at.length===0,'no recovery commands at unknown baud');
 }
 return {checks};
}
if(typeof require!=='undefined'&&typeof module!=='undefined') {
 const fs=require('fs'),vm=require('vm'),esx=process.argv[2]==='esx',S={};
 vm.runInThisContext(fs.readFileSync('tests/z80-directory.js','utf8'));
 for(const m of fs.readFileSync(esx?'directory-esx-test.sym':'directory-test.sym','utf8').matchAll(/^v[01]\.(\S+): EQU 0x([0-9A-F]+)/gmi))S[m[1]]=parseInt(m[2],16);
 const tape=fs.readFileSync(esx?'SARA_ESX_LOADER.tap':'SARA_LOADER.tap'),blocks=[];
 for(let p=0;p<tape.length;){const n=tape[p]|tape[p+1]<<8;p+=2;blocks.push(tape.subarray(p+1,p+n-1));p+=n;}
 console.log(ftpRecoveryRegression(makeCpu,blocks[3],fs.readFileSync('WifiBios20_MB_EL.cod'),S));
}
