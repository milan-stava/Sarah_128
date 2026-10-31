// Real screen receive loop, AT terminals, FTP completion and return sequencing.
function screenDownloadRegression(makeCpu,image,bios,S) {
 let checks=0;
 const assert=(ok,msg)=>{if(!ok)throw Error(msg);checks++;};
 const word=(m,p)=>m[p]|m[p+1]<<8,put=(m,p,v)=>{m[p]=v&255;m[p+1]=v>>8;};
 const text=(m,p)=>{let s='';while(m[p])s+=String.fromCharCode(m[p++]);return s;};
 const stop={};
 for(const size of [6144,6912])for(const chunk of [733,2048])for(const controlChunk of [1,128,'queued']) {
  let cpu,received=0,pending='226 Transfer OK\r\n',closed=false,off=false,keys=0,redrawn=0;
  const feed=s=>cpu.rx.push(...Array.from(s,c=>c.charCodeAt(0)).flatMap(v=>[null,v]));
  cpu=makeCpu([],bios,S,{image,hook(pc,r){
   if(pc===S.error_handler)throw Error('screen error '+(r.bc&255));
   if([S.display_error,S.fdf_loop_err].includes(pc))throw Error('screen entered disk/error path');
   if(pc===S.print_ftp_message){assert(!(r.m[S.flag1]&16),'completion reply must not overwrite image');return {ret:true};}
   if([S.enter_passive_mode,S.passive_receive_on,S.set_20mhz,S.set_3_5mhz,S.print_dir_files_items,S.PRINTHL,S.print_ftp_status].includes(pc))return {ret:true};
   if(pc===S.send_ftp_command_in_passive_mode){
    r.m[S.transfer_flag]=2;
    if(controlChunk==='queued'){
     r.m.set(Array.from(pending,c=>c.charCodeAt(0)),S.ftp_control_buffer);
     r.m[S.ftp_control_left]=pending.length;put(r.m,S.ftp_control_next,S.ftp_control_buffer);pending='';
    }
    return {ret:true};
   }
   if(pc===S.data_available_in_module_file)return {ret:true,hl:Math.min(chunk,size-received),z:received===size,carry:false};
   if(pc===S.ask_for_data_in_passive_mode){put(r.m,S.rest_chunk,r.bc);return {ret:true};}
   if(pc===S.rece_block){
    const count=r.bc;assert(r.hl===0x4000+received,'screen payload destination');
    for(let i=0;i<count;i++)r.m[r.hl+i]=(received+i)*37&255;
    received+=count;feed('\r\nOK\r\n');return {ret:true,hl:r.hl+count,bc:0,carry:true};
   }
   if(pc===S.ftp_query_lengths)return {ret:true,hl:0,de:pending.length,z:true};
   if(pc===S.send_string){
    const command=text(r.m,r.hl);
    if(command==='AT+CIPRECVDATA=0,128\r\n'){
     const part=pending.slice(0,controlChunk);pending=pending.slice(part.length);
     feed('+CIPRECVDATA,'+part.length+':'+part+'\r\nOK\r\n');
    }else if(command==='AT+CIPCLOSE=1\r\n'){
     assert(pending===''&&r.m[S.ftp_control_left]===0,'consume 226 before closing');closed=true;feed('1,CLOSED\r\nOK\r\n');
    }else throw Error('unexpected screen command '+JSON.stringify(command));
    return {ret:true,z:true};
   }
   if(pc===S.passive_receive_off){assert(closed&&cpu.rx.length===0,'drain FTP and AT before active receive');off=true;return {ret:true};}
   if(pc===S.akey1){assert(closed&&off&&received===size,'finish transfer before waiting on image');assert(!(r.m[S.flag1]&16),'image wait disables printing');keys++;return {ret:true};}
   if(pc===S.print_whole_screen||pc===S.get_status_ftp){assert(closed&&off&&pending===''&&r.m[S.ftp_control_left]===0,'PWD/status sees no stale 226');redrawn++;return {ret:true};}
   if(pc===S.dir_move4)return {ret:true};
  }});
  cpu.m[S.flag1]=16;cpu.m[S.flag_dir]=1;cpu.m[0x5b00]=0xa5;
  put(cpu.m,S.cur_item_addr,0xc123);put(cpu.m,S.cur_item_addr_page,S.ftp_dir_page+1);
  cpu.call(S.download_screen,{de:size});
  assert(received===size&&keys===1&&redrawn===2,'complete screen and UI return');
  assert(cpu.rx.length===0&&pending===''&&cpu.m[S.ftp_control_left]===0,'no pending transport bytes');
  assert(!!(cpu.m[S.flag1]&16),'printing restored');
  assert(word(cpu.m,S.cur_item_addr)===0xc123,'selection preserved');
  assert(cpu.m[0x5b00]===0xa5,'screen receive stays below #5B00');
 }
 return {checks};
}
if(typeof require!=='undefined'&&typeof module!=='undefined') {
 const fs=require('fs'),vm=require('vm'),esx=process.argv[2]==='esx',S={};
 vm.runInThisContext(fs.readFileSync('tests/z80-directory.js','utf8'));
 for(const m of fs.readFileSync(esx?'directory-esx-test.sym':'directory-test.sym','utf8').matchAll(/^v[01]\.(\S+): EQU 0x([0-9A-F]+)/gmi))S[m[1]]=parseInt(m[2],16);
 const tape=fs.readFileSync(esx?'SARA_ESX_LOADER.tap':'SARA_LOADER.tap'),blocks=[];
 for(let p=0;p<tape.length;){const n=tape[p]|tape[p+1]<<8;p+=2;blocks.push(tape.subarray(p+1,p+n-1));p+=n;}
 console.log(screenDownloadRegression(makeCpu,blocks[3],fs.readFileSync('WifiBios20_MB_EL.cod'),S));
}
