// Real assembled viewer code; physical RAM banks, FTP, BIOS and display are modeled.
// Reuse with: textViewerRegression(makeCpu, mainImage, bank6Image, bios, symbols).
function textViewerRegression(makeCpu, image, bank6, bios, S) {
 let checks=0,pageUpMaps=[];
 const assert=(ok,s)=>{if(!ok)throw Error(s);checks++;};
 const word=(m,p)=>m[p]|m[p+1]<<8;
 const put=(m,p,v)=>{m[p]=v&255;m[p+1]=v>>8;};
 const stop={};
 const bytes=s=>Uint8Array.from(s,c=>c.charCodeAt(0));
 function env(data=new Uint8Array(), hook=()=>{}) {
  let active=6,cpu,maps=0;
  const banks=Array.from({length:8},(_,i)=>new Uint8Array(16384).fill(0x80+i));
  banks[6].set(bank6);
  const pages=[4,0,1,3];
  for(let i=0;i<Math.min(data.length,65535);i++)banks[pages[i>>14]][i&16383]=data[i];
  cpu=makeCpu([],bios,S,{image,hook(pc,r){
   if(pc===S.PAGE128){banks[active].set(r.m.slice(0xc000));active=r.a&7;r.m.set(banks[active],0xc000);r.m[S.PAGE128_STATE]=16+active;maps++;return {ret:true,a:16+active};}
   const result=hook(pc,r,{active,banks,pages,cpu,maps});
   if(result)return result;
   if(pc===S.set_20mhz||pc===S.set_3_5mhz)return {ret:true};
   if(pc===S.inkey)return {ret:true,a:0};
  }});
  cpu.m.set(banks[6],0xc000);cpu.m[S.PAGE128_STATE]=22;cpu.m[S.flag1]=0x30;cpu.m[S.flag_dir]=1;
  return {cpu,banks,pages,active:()=>active,maps:()=>maps};
 }
 function reference(data,start) {
  let p=start,row=0,col=0,cells=[];
  while(p<data.length){let a=data[p++];
   if(a===13||a===10){if(a===13&&data[p]===10)p++;col=0;if(++row===S.text_rows)break;continue;}
   if(col===S.text_columns){col=0;if(++row===S.text_rows){p--;break;}}
   if(a===9)a=32;else if(a<32||a>=127)a=46;
   cells.push([row,col++,a]);
  }
  return {end:p,cells};
 }
 // Same layout rules in drawing and scan-only modes, all bank edges and binary bytes.
 {
  const data=Uint8Array.from({length:65535},(_,i)=>(i>>8)^(i&255)),e=env(data);
  put(e.cpu.m,S.text_length,data.length);
  for(const p of [0,1,255,256,257,16383,16384,65534]){
   put(e.cpu.m,S.text_pos,p);assert(e.cpu.call(S.text_get).a===data[p],'cached byte '+p);
  }
  assert(e.maps()===10,'five aligned cache windows need ten bank switches');
 }
 {
  let first=[],speed=3;
  const e=env(bytes('A'),(pc,r)=>{
   if(pc===S.set_20mhz){speed=20;return {ret:true};}
   if(pc===S.set_3_5mhz){speed=3;return {ret:true};}
   if(pc===S.cls_4000){assert(speed===20,'drawing uses fast CPU');return {ret:true};}
   if(pc===S.CHAR){first.push(r.a);return {ret:true};}
   if(pc===S.KEYSCAN){assert(speed===3,'keyboard runs at normal speed');return {ret:true,a:1};}
  });put(e.cpu.m,S.text_length,1);e.cpu.call(S.text_browse);
  e.banks[4][0]=66;e.cpu.call(S.text_browse);
  assert(first.join(',')==='65,66','new file invalidates reused INPBUFF cache');
 }
 const samples=[new Uint8Array(),bytes('abc\r\ndef\nghi\rj'),bytes('x'.repeat(64)+'\r\nY'),
  bytes('\r\n'.repeat(60)),Uint8Array.from({length:8193},(_,i)=>i&255),
  bytes('A'.repeat(16383)+'\r\n'+'B'.repeat(17000)),bytes('\n'.repeat(65535)),bytes('A'.repeat(65535))];
 for(const data of samples){let drawn=[];
  const e=env(data,(pc,r)=>{if(pc===S.CHAR){drawn.push([r.hl>>8,r.hl&255,r.a]);return {ret:true};}});
  put(e.cpu.m,S.text_length,data.length);
  const starts=[0,Math.min(data.length,16380),Math.max(0,data.length-1600)];
  for(const start of starts)for(const draw of [0,1]){
   drawn=[];put(e.cpu.m,S.text_pos,start);e.cpu.m[S.text_draw]=draw;
   const expected=reference(data,start);e.cpu.call(S.text_page);
   assert(word(e.cpu.m,S.text_pos)===expected.end,'page end at '+start+' length '+data.length);
   assert(JSON.stringify(drawn)===JSON.stringify(draw?expected.cells:[]),'ASCII layout / scan-only');
   assert(e.active()===6,'page walker restores its code bank');
  }
 }
 // Navigation recomputes earlier boundaries, no history and no phantom EOF page.
 {
  const data=bytes(('A'.repeat(64)+'\r\nshort\n\n').repeat(110)), starts=[],pages=[];
  for(let p=0;p<data.length;){starts.push(p);const page=reference(data,p);pages.push(page.cells);p=page.end;}
  const keys=[9,9,8,8,8,9,11,10,1],expected=[0,1,2,1,0,1];let screen=[],screens=[];
  const e=env(data,(pc,r)=>{
   if(pc===S.cls_4000){screen=[];screens.push(screen);return {ret:true};}
   if(pc===S.CHAR){screen.push([r.hl>>8,r.hl&255,r.a]);return {ret:true};}
   if(pc===S.KEYSCAN)return {ret:true,a:keys.shift()??1};
  });put(e.cpu.m,S.text_length,data.length);e.cpu.call(S.text_browse);
  assert(screens.length===expected.length,'left/right only; left at start does not redraw');
  screens.forEach((v,i)=>assert(JSON.stringify(v)===JSON.stringify(pages[expected[i]]),'history-free navigation '+i));
 }
 // Execute transfer orchestration and real fixed-RAM receiving bridge, never disk paths.
 for(const fill of [65,10]){
  const data=new Uint8Array(65535).fill(fill),starts=[];
  for(let p=0;p<data.length;){starts.push(p);p=reference(data,p).end;}
  const keys=[...new Array(starts.length).fill(9),8,1],drawnStarts=[];
  let scanStart=0,scanMaps=0,speed=3;
  const e=env(data,(pc,r,state)=>{
   if(pc===S.set_20mhz){speed=20;return {ret:true};}
   if(pc===S.set_3_5mhz){speed=3;return {ret:true};}
   if(pc===S.cls_4000){drawnStarts.push(word(r.m,S.text_start));return {ret:true};}
   if(pc===S.CHAR)return {ret:true};
   if(pc===S.KEYSCAN){assert(speed===3,'navigation restores normal speed');const key=keys.shift()??1;if(key===8)scanStart=state.maps;if(key===1)scanMaps=state.maps-scanStart;return {ret:true,a:key};}
  });put(e.cpu.m,S.text_length,data.length);e.cpu.call(S.text_browse);
  assert(drawnStarts.length===starts.length+1,'no phantom page at max length');
  assert(drawnStarts.at(-1)===starts.at(-2),'left from last page recomputes correct start');
  assert(scanMaps<=2*(256+8),'max-size Page Up uses cache, not per-byte bank switches');
  pageUpMaps.push({fill,maps:scanMaps});
 }
 function transfer(size,{partial=false,cancelAt=-1,failAt=-1,sizeError=false,emptyFrame=false}={}) {
  const source=Uint8Array.from({length:size},(_,i)=>(i*13+17)&255);
  let cursor=0,requests=[],aborts=0,closed=0,off=0,viewed=false,warnings=0,failed=0;
  const e=env(new Uint8Array(),(pc,r,state)=>{
   if([S.save_file_head,S.save_into_file,S.save_close,S.delete_file].includes(pc))throw Error('disk operation in memory viewer');
   if(pc===S.send_type_command_i||pc===S.set_20mhz||pc===S.set_3_5mhz||pc===S.enter_passive_mode||pc===S.passive_receive_on)return {ret:true};
   if(pc===S.send_ftp_command)return {ret:true,hl:sizeError?550:213,carry:sizeError};
   if(pc===S.ConvRStr32)return {ret:true,hl:size>>>16,de:size&65535};
   if(pc===S.KEYSCAN)return {ret:true,a:cancelAt>=0&&cursor>=cancelAt?98:0};
   if(pc===S.send_ftp_command_in_passive_mode){assert(r.hl===S.ftp_retr,'RETR uses prepared filename');r.m[S.transfer_flag]=2;return {ret:true};}
   if(pc===S.data_available_in_module_file)return {ret:true,hl:Math.min(2048,size-cursor),z:false};
   if(pc===S.ask_for_data_in_passive_mode){
    assert(r.bc>0&&r.bc<=2048,'bounded nonzero request');
    assert(cursor+r.bc<=Math.min(size,65535),'request stops at display limit');
    assert((cursor&16383)+r.bc<=16384,'request does not cross bank');
    const n=emptyFrame?0:partial?Math.min(r.bc,127):r.bc;put(r.m,S.rest_chunk,n);requests.push(n);return {ret:true};
   }
   if(pc===S.rece_block){
    const n=word(r.m,S.rest_chunk);
    assert(state.active===state.pages[cursor>>14],'correct destination bank');
    assert(r.hl===0xc000+(cursor&16383)&&r.hl+n<=65536,'correct destination address');
    if(cursor>=16384)assert(!(r.m[S.flag_dir]&1),'directory invalidated before overwrite');
    else assert(r.m[S.flag_dir]&1,'small files preserve cached directory');
    if(failAt>=0&&cursor>=failAt)return {ret:true,carry:false,bc:n};
    r.m.set(source.subarray(cursor,cursor+n),r.hl);cursor+=n;return {ret:true,carry:true,bc:0,hl:(r.hl+n)&65535};
   }
   if(pc===S.ftp_discard_payload)return {ret:true};
   if(pc===S.ftp_wait_terminal)return {ret:true,carry:false};
   if(pc===S.ask_for_reply_in_passive_mode)return {ret:true,hl:226};
   if(pc===S.ftp_close_data){closed++;return {ret:true};}
   if(pc===S.passive_receive_off){off++;return {ret:true};}
   if(pc===S.ftp_abort_transfer){aborts++;return {ret:true};}
   if(pc===S.pts){if(r.de===S.text_large)warnings++;else failed++;return {ret:true};}
   if(pc===S.text_browse){assert(word(r.m,S.text_local_base)===0,'FTP clears prior local-help source');viewed=true;throw stop;}
  });
  put(e.cpu.m,S.text_local_base,0xd000);
  try{e.cpu.call(S.text_viewer_control);}catch(x){if(x!==stop)throw x;}
  // Flush the currently mapped page for direct bank inspection.
  e.banks[e.active()].set(e.cpu.m.slice(0xc000));
  for(let i=0;i<cursor;i++)assert(e.banks[e.pages[i>>14]][i&16383]===source[i],'received byte '+i);
  assert(e.active()===6,'receive bridge always restores code bank');
  return {e,cursor,aborts,closed,off,viewed,warnings,failed};
 }
 for(const size of [0,1,16383,16384,16385,32768,65535,65536,702026]){
  const r=transfer(size);
  assert(r.cursor===Math.min(size,65535)&&r.viewed,'complete bounded RAM download '+size);
  assert(r.aborts===(size>65535?1:0),'ABOR only for truncated source');
  assert(r.warnings===(size>65535?1:0),'oversize warning');
  assert(r.closed===(size>0&&size<=65535?1:0),'normal transfer closed');
  assert(!!(r.e.cpu.m[S.flag_dir]&1)===(size<=16384),'directory reuse threshold');
 }
 assert(transfer(16385,{partial:true}).cursor===16385,'partial modem frames');
 for(const opts of [{cancelAt:0},{cancelAt:18000},{failAt:0},{failAt:18000}]){
  const r=transfer(40000,opts);assert(r.aborts===1&&!r.viewed,'abort/failure never opens viewer');
  assert(!!(r.e.cpu.m[S.flag_dir]&1)===(r.cursor<16384),'cache validity on interrupted transfer');
 }
 const missing=transfer(20,{sizeError:true});assert(!missing.viewed&&missing.failed===1&&!missing.cursor,'SIZE rejects unreadable NLST item');
 const empty=transfer(20,{emptyFrame:true});assert(!empty.viewed&&empty.aborts===1&&!empty.cursor,'zero-length modem frame does not spin');
 // Public entry refuses known directories, malformed/oversized names and offline calls.
 for(const entry of ['view_as_text','enter_directory']) {
  // Execute the actual TYPE helper, including its destructive use of INPBUFF.
  const name='readme.txt';let types=0,sizes=0;
  const e=env(new Uint8Array(),(pc,r)=>{
   if(pc===S.get_item_name){r.m.set(bytes(name),0xff00);put(r.m,S.item_name_page,S.PAGE128_STATE);return {ret:true,a:1,hl:0xff00,bc:name.length};}
   if(pc===S.send_ftp_command){
    if(r.hl===S.ftp_type){types++;assert(r.m[S.INPBUFF]===73,'actual TYPE I prepared');return {ret:true,hl:200,carry:false};}
    if(r.hl===S.ftp_size){sizes++;const buffer=r.m.slice(S.INPBUFF,S.INPBUFF+name.length+1);assert(buffer[name.length]===0&&Array.from(buffer.slice(0,-1)).every((v,i)=>v===name.charCodeAt(i)),'SIZE uses filename after TYPE I');throw stop;}
   }
  });
  try{e.cpu.call(S[entry]);}catch(x){if(x!==stop)throw x;}
  assert(types===1&&sizes===1,'one TYPE and one SIZE through '+entry);
 }
 for(const kind of [0,1,2,3,4])for(const nameLength of [0,8,255,256])for(const dirty of [false,true]){
  let control=0,redraw=0,reload=0;
  const e=env(new Uint8Array(),(pc,r)=>{
   if(pc===S.get_item_name){r.m.fill(65,0xff00,0xffff);put(r.m,S.item_name_page,S.PAGE128_STATE);return {ret:true,a:kind,hl:0xff00,bc:nameLength};}
   if(pc===S.send_type_command_i)return {ret:true};
   if(pc===S.text_viewer_control){control++;if(dirty)r.m[S.flag_dir]&=254;return {ret:true};}
   if(pc===S.print_whole_screen)return {ret:true};
   if(pc===S.resume_directory_screen){redraw++;return {ret:true};}
   if(pc===S.directory_retrieve){reload++;return {ret:true};}
  });const r=e.cpu.call(S.view_as_text),valid=(kind===1||kind===2)&&nameLength>0&&nameLength<256;
  assert(control===(valid?1:0),'entry validation '+kind+'/'+nameLength);
  assert(redraw===(valid&&!dirty?1:0)&&reload===(valid&&dirty?1:0),'restore cache or reload after overwritten directory');
  assert(r.a===0,'entry consumes navigation key');
 }
 {
  const e=env(new Uint8Array(),pc=>{if(pc===S.get_item_name)throw Error('offline entry parsed directory');});
  e.cpu.m[S.flag1]=0;assert(e.cpu.call(S.view_as_text).a===0,'offline view ignored');
 }
 return {checks,pageUpMaps};
}

if(typeof require!=='undefined'&&typeof module!=='undefined') {
 const fs=require('fs'),path=require('path'),vm=require('vm'),dir=process.argv[2]||'.';
 vm.runInThisContext(fs.readFileSync('tests/z80-directory.js','utf8'));
 const S={};for(const line of fs.readFileSync(path.join(dir,process.argv[4]||'directory-test.sym'),'utf8').split(/\r?\n/)){
  const m=line.match(/^v[01]\.(\S+): EQU 0x([0-9A-F]+)/i);if(m)S[m[1]]=parseInt(m[2],16);
 }
 const tap=fs.readFileSync(path.join(dir,process.argv[3]||'SARA_LOADER.tap')),blocks=[];
 for(let p=0;p<tap.length;){const n=tap.readUInt16LE(p);p+=2;blocks.push(tap.subarray(p,p+n));p+=n;}
 console.log(textViewerRegression(makeCpu,blocks[3].subarray(1,-1),blocks[5].subarray(1,-1),fs.readFileSync('WifiBios20_MB_EL.cod'),S));
}
