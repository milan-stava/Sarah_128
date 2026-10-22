// Build BSDOS with --sym=directory-test.sym, then: node tests/upload_response.test.js
function uploadResponseRegression(makeCpu,image,bios,S) {
 let checks=0;
 const assert=(v,s)=>{if(!v)throw Error(s);checks++;};
 const bytes=s=>Array.from(s,c=>c.charCodeAt(0));
 const cpu=hook=>makeCpu([],bios,S,{image,hook});
 //The original buffered handshake and original SEND OK wait are intentional.
 for(const text of ['\r\nOK\r\n> ','ERROR\r\n']) {
  let drained=0;const u=cpu((pc,r)=>{if(pc===S.clear_rece_buf){drained++;return {ret:true};}});
  u.m[S.upload_legacy_mode]=1;u.rx.push(...bytes(text));
  const r=u.call(S.check_module_answer,{hl:S.char_zob});
  assert(r.carry===(text[0]==='E'),'original buffered prompt result');
  assert(drained===(text[0]==='E'?0:1),'original UART drain after prompt');
 }
 for(const code of [150,226]) {
  const reply=code+' Transfer response\r\n';
  const u=cpu((pc,r)=>{if(pc===S.print_ftp_message)return {ret:true};if(pc===S.error_handler)throw Error('legacy reply error '+r.bc);});
  u.m[S.upload_legacy_mode]=1;
  u.rx.push(...bytes('SEND OK\r\n\r\n+IPD,0,'+reply.length+':'+reply));
  const r=u.call(S.receive_ftp_answer_isolated,{de:code});
  assert(!r.carry&&r.hl===code,'original FTP payload read '+code);
 }
 for(const length of [1,2047,2048,2049,8193,16384]) {
  let copied=0,blocks=0;
  const u=cpu((pc,r)=>{
   if(pc===S.cipsend_lod){blocks++;const n=r.m[S.ftp_upl_len]|r.m[S.ftp_upl_len+1]<<8;assert(n>0&&n<=2048,'original block bound');u.rx.push(...bytes('Recv '+n+' bytes\r\nSEND OK\r\n'));return {ret:true,carry:false};}
   if(pc===S.send_data){assert(r.hl===0xc000+copied,'data starts at bank-4 buffer');copied+=r.bc;return {ret:true,hl:(r.hl+r.bc)&65535,bc:0,z:true};}
   if(pc===S.KEYSCAN)return {ret:true,a:0};
   if(pc===S.ful_abort)throw Error('unexpected upload abort');
  });
  u.m[S.portion_len]=length&255;u.m[S.portion_len+1]=length>>8;
  u.call(S.ftp_send_loop);
  assert(copied===length&&blocks===Math.ceil(length/2048),'original splitting exact length '+length);
 }
 {
  let modeAtRefresh=-1;const u=cpu((pc,r)=>{
   if(pc===S.send_string)return {ret:true,z:true};
   if(pc===S.set_3_5mhz)return {ret:true};
   if(pc===S.receive_ftp_answer_isolated){assert(r.m[S.upload_legacy_mode]===1,'completion still uses original FTP reception');return {ret:true,carry:false};}
   if(pc===S.directory_retrieve){modeAtRefresh=r.m[S.upload_legacy_mode];return {ret:true};}
  });u.m[S.upload_legacy_mode]=1;u.call(S.ftp_upl_end);assert(modeAtRefresh===0,'refresh uses modern directory communication');
 }
 for(const failedCleanup of [false,true]) {
  let displays=0,cleanups=0,slow=false;const stop={};
  const u=cpu((pc,r)=>{
   if(pc===S.set_3_5mhz){slow=true;return {ret:true,bc:0x793b};}
   if(pc===S.display_error){assert(slow&&r.bc%256===16,'original error and safe clock');displays++;return {ret:true};}
   if(pc===S.wifi_unwait)return {ret:true};
   if(pc===S.passive_receive_off){cleanups++;if(!failedCleanup)return {ret:true};}
   if(pc===S.error_handler_exit+4){assert(r.m[S.error_recovering]===0&&r.m[S.upload_legacy_mode]===0,'recovery and upload modes reset');throw stop;}
  });
  u.m[S.flag1]|=64; // This test starts during an initialized FTP session.
  if(failedCleanup)u.m.set([0x0e,39,0xc3,S.error_handler&255,S.error_handler>>8],S.passive_receive_off);
  try{u.call(S.error_handler,{bc:16});throw Error('missing exit');}catch(e){if(e!==stop)throw e;}
  assert(displays===1&&cleanups===1,'cleanup attempted once, no recursive error loop');
 }
 return {checks};
}
if(typeof require!=='undefined'&&typeof module!=='undefined') {
 const fs=require('fs'),vm=require('vm');
 vm.runInThisContext(fs.readFileSync('tests/z80-directory.js','utf8'));
 const esx=process.argv[2]==='esx';
 const S={};for(const line of fs.readFileSync(esx?'directory-esx-test.sym':'directory-test.sym','utf8').split(/\r?\n/)){
  const m=line.match(/^v[01]\.(\S+): EQU 0x([0-9A-F]+)/i);if(m)S[m[1]]=parseInt(m[2],16);
 }
 const image=esx?fs.readFileSync('SARAH12ESX.tap').subarray(24,-1):fs.readFileSync('SARAH12BSDhgfx');
 console.log(uploadResponseRegression(makeCpu,image,fs.readFileSync('WifiBios20_MB_EL.cod'),S));
}
