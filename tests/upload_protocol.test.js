// Regression tests for assembled upload code and the supplied WifiBios20 binary.
// This is a small instruction interpreter, NOT a hardware timing emulator.
// From repo root:
//   sjasmplus --sym=upload-test.sym assembly_mbbsd1.asm
//   node tests/upload_protocol.test.js
// UART ports are simulated; hardware timing/ESP firmware are not verified.
"use strict";
function makeCpu(code, bios, S, options={}) {
 const m=new Uint8Array(65536);if(options.image)m.set(options.image,0x6000);m.set(code,S.upl_send_data);m.set(bios,0xe000);
 let a=0,b=0,c=0,d=0,e=0,h=0,l=0,ix=S.flag1,z=false,cf=false,pc=0,stack=[],steps=0;
 let rx=[], sent=[], rxReads=0, polls=0, paceIterations=0, txBusy=options.txBusy||0, lastStatus=0;
 const hl=()=>h*256+l,de=()=>d*256+e,bc=()=>b*256+c;
 const word=()=>{let n=m[pc]|m[pc+1]<<8;pc+=2;return n;};
 const rel=take=>{let n=m[pc++];if(take)pc=(pc+(n<128?n:n-256))&65535;};
 const cp=v=>{z=a===v;cf=a<v;}, logic=()=>{z=a===0;cf=false;};
 function status(){polls++;if(options.onPoll)options.onPoll(polls,rx);if(rx[0]===null)rx.shift(); const busy=(txBusy>0||sent.length>=options.txStuckAt)?2:0;if(txBusy>0)txBusy--;lastStatus=(rx.length&&rx[0]!=null?1:0)|busy|(options.statusBits||0);return lastStatus;}
 function step(){
 if(options.hook){const result=options.hook(pc,{m,a,hl:hl(),de:de(),bc:bc(),ix});if(result){if(result.a!=null)a=result.a;if(result.hl!=null){h=result.hl>>8;l=result.hl&255;}if(result.ret){pc=stack.pop();return;}}}
 if(pc===S.upl_tx_pace_loop)paceIterations++;
 const at=pc,op=m[pc++];
 switch(op){
 case 0x32:m[word()]=a;break;case 0x3a:a=m[word()];break;
 case 0xaf:a=0;logic();break;case 0xa7:logic();break;
 case 0x21:{let n=word();h=n>>8;l=n&255;break;}
 case 0x2a:{let addr=word();l=m[addr];h=m[(addr+1)&65535];break;}
 case 0x22:{let addr=word();m[addr]=l;m[(addr+1)&65535]=h;break;}
 case 0x01:{let n=word();b=n>>8;c=n&255;break;}
 case 0x11:{let n=word();d=n>>8;e=n&255;break;}
 case 0x77:m[hl()]=a;break;case 0x73:m[hl()]=e;break;case 0x36:m[hl()]=m[pc++];break;
 case 0x12:m[de()]=a;break;
 case 0x37:cf=true;break;
 case 0xcd:{let addr=word();stack.push(pc);pc=addr===S.rece_byte?0xe0d7:addr===S.send_byte?0xe0ed:addr;break;}
 case 0xc3:{let addr=word();pc=addr===S.rece_byte?0xe0d7:addr;break;}
 case 0xca:{let addr=word();if(z)pc=addr;break;}
 case 0xc2:{let addr=word();if(!z)pc=addr;break;}
 case 0xda:{let addr=word();if(cf)pc=addr;break;}
 case 0xf5:stack.push((a<<8)|(z?64:0)|(cf?1:0));break;
 case 0xf1:{let n=stack.pop();a=n>>8;z=!!(n&64);cf=!!(n&1);break;}
 case 0xc5:stack.push(bc());break;case 0xd5:stack.push(de());break;case 0xe5:stack.push(hl());break;
 case 0xc1:{let n=stack.pop();b=n>>8;c=n&255;break;}
 case 0xd1:{let n=stack.pop();d=n>>8;e=n&255;break;}
 case 0xe1:{let n=stack.pop();h=n>>8;l=n&255;break;}
 case 0x1b:{let n=(de()-1)&65535;d=n>>8;e=n&255;break;}
 case 0x13:{let n=(de()+1)&65535;d=n>>8;e=n&255;break;}
 case 0x23:{let n=(hl()+1)&65535;h=n>>8;l=n&255;break;}
 case 0x0b:{let n=(bc()-1)&65535;b=n>>8;c=n&255;break;}
 case 0x03:{let n=(bc()+1)&65535;b=n>>8;c=n&255;break;}
 case 0x4f:c=a;break;case 0x06:b=m[pc++];break;
 case 0x7a:a=d;break;case 0x79:a=c;break;case 0x78:a=b;break;case 0x7b:a=e;break;case 0x7d:a=l;break;case 0x7e:a=m[hl()];break;case 0x1a:a=m[de()];break;
 case 0x5f:e=a;break;case 0x6f:l=a;break;case 0x46:b=m[hl()];break;
 case 0x26:h=m[pc++];break;case 0x16:d=m[pc++];break;
 case 0xb3:a|=e;logic();break;case 0xb7:logic();break;case 0xb1:a|=c;logic();break;
 case 0xe6:a&=m[pc++];logic();break;
 case 0xc6:{let n=a+m[pc++];a=n&255;z=a===0;cf=n>255;break;}
 case 0x09:{let n=hl()+bc();cf=n>65535;n&=65535;h=n>>8;l=n&255;break;}
 case 0x19:{let n=hl()+de();cf=n>65535;n&=65535;h=n>>8;l=n&255;break;}
 case 0x20:rel(!z);break;case 0x28:rel(z);break;case 0x30:rel(!cf);break;case 0x38:rel(cf);break;case 0x18:rel(true);break;
 case 0x10:b=(b-1)&255;rel(b!==0);break;
 case 0x3e:a=m[pc++];break;case 0x0e:c=m[pc++];break;
 case 0xfe:cp(m[pc++]);break;case 0xbe:cp(m[hl()]);break;case 0xbb:cp(e);break;
 case 0x0c:c=(c+1)&255;z=c===0;break;case 0x04:b=(b+1)&255;z=b===0;break;case 0x3c:a=(a+1)&255;z=a===0;break;
 case 0x0f:cf=!!(a&1);a=(a>>1)|(cf?128:0);break;
 case 0x1f:{const old=cf;cf=!!(a&1);a=(a>>1)|(old?128:0);break;}
 case 0xcb:{const op2=m[pc++];if(op2===0x79)z=!(c&128);else if(op2===0x47)z=!(a&1);else throw Error("CB "+op2);break;}
 case 0xdd:{const op2=m[pc++];if(op2===0x21){ix=word();break;}if(op2!==0xcb)throw Error("DD "+op2);const disp=m[pc++];const addr=(ix+(disp<128?disp:disp-256))&65535;const bitop=m[pc++],mask=1<<((bitop>>3)&7);if(bitop<0x80){z=!(m[addr]&mask);}else if(bitop<0xc0){m[addr]&=255^mask;}else{m[addr]|=mask;}break;}
 case 0xed:{
 const o=m[pc++];const port=bc();
 if(o===0x78){if(port!==0x793b&&port!==0x133b)throw Error("Unexpected status port");a=port===0x793b?(options.speed||0):status();z=a===0;}
 else if(o===0x58){if(port!==0x143b)throw Error("Unexpected RX port");e=rx.shift();if(e==null)throw Error("Read empty UART");rxReads++;z=e===0;}
 else if(o===0x59){if(port!==0x133b)throw Error("Unexpected TX port");if(options.checkTxReady&&(lastStatus&2))throw Error("Write while UART busy");sent.push(e);txBusy=options.txHoldPolls||0;if(options.onTx)options.onTx(sent.length,rx);}
 else if(o===0x79){if(port!==0x783b)throw Error("Unexpected OUT");}
 else if(o===0x42){let n=hl()-bc()-(cf?1:0);cf=n<0;n&=65535;h=n>>8;l=n&255;z=n===0;}
 else if(o===0x43){let addr=word();m[addr]=c;m[addr+1]=b;}
 else if(o===0x4b){let addr=word();c=m[addr];b=m[addr+1];}
 else if(o===0xb0){let count=bc(),src=hl(),dst=de();for(let i=0;i<count;i++)m[(dst+i)&65535]=m[(src+i)&65535];src=(src+count)&65535;dst=(dst+count)&65535;h=src>>8;l=src&255;d=dst>>8;e=dst&255;b=c=0;}
 else throw Error("ED "+o.toString(16));break;}
 case 0xc0:if(!z)pc=stack.pop();break;case 0xc8:if(z)pc=stack.pop();break;case 0xc9:pc=stack.pop();break;
 default:throw Error("Unsupported "+op.toString(16)+" at "+at.toString(16));
 }
 }
 return {m,rx,sent,call(entry,regs={}){
  if(stack.length)throw Error("Stack not empty");
  a=regs.a||0;if(regs.carry!=null)cf=regs.carry;if(regs.hl!=null){h=regs.hl>>8;l=regs.hl&255;}if(regs.bc!=null){b=regs.bc>>8;c=regs.bc&255;}
  stack=[65535];pc=entry;let startSteps=steps;
  while(pc!==65535){if(++steps-startSteps>300000000)throw Error("step limit");step();}
  if(stack.length)throw Error("Stack imbalance");
  return {a,z,carry:cf,bc:bc(),hl:hl(),status:m[S.upl_wait_status],polls,rxReads,paceIterations};
 }};
}

function uploadRegression(makeCpu, code, bios, S) {
 const chars=s=>Array.from(s,c=>c.charCodeAt(0));let tests=0;
 function expect(cond,why){if(!cond)throw Error(why);tests++;}
 // Execute the real BIOS TX body for every possible status-register value.
 for(let status=0;status<256;status++){
  const uart=makeCpu(code,bios,S,{statusBits:status,checkTxReady:true});
  const result=uart.call(0xe0ed,{a:0xa5,bc:0x1234,hl:0xc000,carry:true});
  expect(result.carry===!!(status&2),"BIOS Carry reflects status bit 1: "+status);
  expect(uart.sent.length===((status&2)?0:1)&&(!uart.sent.length||uart.sent[0]===0xa5),"BIOS writes only when bit 1 clear: "+status);
  expect(result.bc===0x1234&&result.hl===0xc000,"BIOS preserves caller pointers: "+status);
 }
 for(const speed of [0,3]){
  const uart=makeCpu(code,bios,S,{speed,txHoldPolls:17,checkTxReady:true,statusBits:0xf0});
  for(let i=0;i<2048;i++)uart.m[0xc000+i]=i&255;
  const result=uart.call(S.upl_send_data,{hl:0xc000,bc:2048});
  expect(result.z&&uart.sent.length===2048&&uart.sent.every((v,i)=>v===(i&255)),"UART busy after EVERY byte, CPU mode "+speed);
  expect((uart.m[S.upl_tx_count]|uart.m[S.upl_tx_count+1]<<8)===2048,"TX diagnostic excludes busy retries "+speed);
  const stuck=makeCpu(code,bios,S,{speed,txStuckAt:7,checkTxReady:true});
  const timeout=stuck.call(S.upl_send_data,{hl:0xc000,bc:2048});
  expect(!timeout.z&&timeout.bc===2041&&timeout.hl===0xc007&&stuck.sent.length===7,"permanent TX busy returns timeout without extra writes, CPU mode "+speed);
  expect(stuck.m[S.upl_tx_count]===7&&stuck.m[S.upl_tx_count+1]===0,"TX diagnostic preserves partial block "+speed);
 }
 const reply=" busy s...\r\nRecv 2048 bytes\r\nSEND OK\r\n";
 for(let i=0;i<=reply.length;i++){
  const vm=makeCpu(code,bios,S);vm.rx.push(...chars(reply.slice(0,i)),null,null,null,...chars(reply.slice(i)));
  const r=vm.call(S.upl_wait_response,{a:1});expect(!r.carry&&r.status===0,"split "+i);
 }
 for(const [s,status] of [[" SEND OK\r\n",0],["SEND FAIL\r\n",2],["ERROR\r\n",3],["1,CLOSED\r\n",4],["CLOSED\r\n",4],["X".repeat(400)+"SEND OK\r\nERROR\r\n",3]]){
  const vm=makeCpu(code,bios,S);for(let i=0;i<s.length;i++){vm.rx.push(s.charCodeAt(i));if(i%64===63)vm.rx.push(null,null,null);}const r=vm.call(S.upl_wait_response,{a:1});
  expect(r.status===status&&r.carry===(status!==0),"response "+s.slice(0,20));
 }
 for(let speed=0;speed<4;speed++){
  const vm=makeCpu(code,bios,S,{speed});const r=vm.call(S.upl_wait_response,{a:1});
  expect(r.carry&&r.status===1,"timeout");
  expect(r.polls===[8,16,32,48][speed]*65536,"clock limit "+speed);
 }
 const vm=makeCpu(code,bios,S,{speed:3,txBusy:10,onTx:(n,rx)=>{
  if(n===1500)rx.push(...chars("Recv 2048 bytes\r\nbusy s...\r\n"));
  if(n===2048)rx.push(...chars("SEND OK\r\n"));
 }});
 vm.rx.push(...chars("OK\r\n> "));
 let r=vm.call(S.upl_wait_response,{a:0});expect(!r.carry,"prompt");
 for(let i=0;i<2048;i++)vm.m[0xc000+i]=i&255;
 r=vm.call(S.upl_send_data,{bc:2048,hl:0xc000});
 expect(r.z&&r.bc===0&&r.hl===0xc800,"send contract");
 expect(vm.sent.length===2048&&vm.sent.every((v,i)=>v===(i&255)),"exact binary payload, UART busy retries");
 expect(vm.m[S.upl_rx_len]>0,"response received during TX");
 r=vm.call(S.upl_wait_response,{a:1});expect(!r.carry,"prefetched SEND OK");
 const direct=makeCpu(code,bios,S,{onTx:(n,rx)=>{if(n===1)rx.push(...chars("SEND OK\r\n"));}});
 direct.rx.push(...chars("OK\r\n> "));
 expect(!direct.call(S.upl_wait_response,{a:0}).carry,"prompt with pending space");
 direct.call(S.upl_send_data,{bc:1,hl:0xc000});
 expect(!direct.call(S.upl_wait_response,{a:1}).carry,"space from prompt before immediate SEND OK");
 const nul=makeCpu(code,bios,S);nul.rx.push(0);nul.call(S.upl_capture_rx);
 r=nul.call(S.upl_read_byte);expect(r.a===0&&!r.z,"zero byte must still return NZ");
 const over=makeCpu(code,bios,S,{onTx:(n,rx)=>{if(n===1)rx.push(...Array(200).fill(65));}});
 const guard=S.upl_rx_buf+128;const original=over.m[guard];
 over.call(S.upl_send_data,{bc:256,hl:0xc000});
 expect(over.m[S.upl_rx_overflow]===1&&over.m[S.upl_rx_len]===128,"overflow signalled");
 expect(over.m[guard]===original,"queue does not overwrite following memory");
 expect(over.call(S.upl_wait_response,{a:1}).status===5,"overflow reported separately from timeout");
 let releaseAt=Infinity,nextEnd=0;
 const long=makeCpu(code,bios,S,{speed:3,onPoll:(n,rx)=>{if(n===releaseAt)rx.push(...chars("SEND OK\r\n"));},onTx:(n,rx)=>{if(n===nextEnd&&n!==86*1024)rx.push(...chars("Recv bytes\r\nSEND OK\r\n"));}});
 const size=355*1024;
 for(let offset=0;offset<size;offset+=2048){
  const count=Math.min(2048,size-offset);nextEnd=offset+count;
  for(const name of ["upl_rx_pos","upl_rx_len","upl_rx_overflow"])long.m[S[name]]=0;
  long.rx.push(...chars("OK\r\n> "));
  expect(!long.call(S.upl_wait_response,{a:0}).carry,"long upload prompt "+offset);
  for(let i=0;i<count;i++)long.m[0xc000+i]=(offset+i)&255;
  const sent=long.call(S.upl_send_data,{bc:count,hl:0xc000});
  if(nextEnd===86*1024)releaseAt=sent.polls+12*65536+100;
  expect(!long.call(S.upl_wait_response,{a:1}).carry,"long upload ACK "+offset);
 }
 expect(long.sent.length===size&&long.sent.every((v,i)=>v===(i&255)),"355 KiB sent exactly once at CPU mode 3 with delayed ACK near 270 KiB remaining");
 for(let speed=0;speed<4;speed++){
  const paced=makeCpu(code,bios,S,{speed,txBusy:10});
  const command="AT+CIPSEND=1,2048\r\n";
  paced.m.set([...chars(command),0],0xc000);
  const result=paced.call(S.upl_send_string,{hl:0xc000});
  expect(result.z&&result.hl===0xc000+command.length,"paced command contract "+speed);
  expect(String.fromCharCode(...paced.sent)===command,"paced command exact bytes "+speed);
  expect(result.paceIterations===command.length*[0,40,120,192][speed],"one pacing delay per accepted byte, no delay for busy retries "+speed);
 }
 const diagnostic=makeCpu(code,bios,S);diagnostic.rx.push(...chars("busy s...\r\n"));
 expect(diagnostic.call(S.upl_wait_response,{a:1}).status===1,"busy reply eventually times out");
 expect(String.fromCharCode(...diagnostic.m.slice(S.RX_buf,S.RX_buf+9))==="busy s...","last reply retained after timeout");
 expect(diagnostic.m[S.upl_rx_count]===11&&diagnostic.m[S.upl_rx_count+1]===0,"RX diagnostic counts actual UART reads, including CR/LF");
 diagnostic.call(S.upl_reset_counts,{hl:0xc123,bc:0x1234,a:0x56});
 expect(diagnostic.m[S.upl_rx_count]===0&&diagnostic.m[S.upl_tx_count]===0,"counters reset for new data phase");
 return tests;
}

// Full CIPSEND builder + data path, and error dialog control flow.
// Rendering/key hardware is stubbed AFTER the real PRINTHL print-enable gate.
function uploadIntegration(makeCpu,code,bios,S,image){
 const chars=s=>Array.from(s,c=>c.charCodeAt(0));let tests=0;
 const expect=(condition,message)=>{if(!condition)throw Error(message);tests++;};
 for(const speed of [0,3])for(const count of [1,255,256,2048]){
  let command="",payload=[],inData=false,vm;
  vm=makeCpu(code,bios,S,{image,speed,txHoldPolls:3,checkTxReady:true,
   hook:pc=>{if(pc===S.upl_transfer_error)throw Error("Unexpected upload error in full block");},
   onTx:(n,rx)=>{const byte=vm.sent[n-1];if(!inData){command+=String.fromCharCode(byte);if(command.endsWith("\r\n")){expect(command===`AT+CIPSEND=1,${count}\r\n`,"actual CIPSEND builder "+count);inData=true;rx.push(...chars("OK\r\n> "));}}else{payload.push(byte);if(payload.length===count)rx.push(...chars(`Recv ${count} bytes\r\nSEND OK\r\n`));}}
  });
  vm.m[S.ftp_upl_start]=0;vm.m[S.ftp_upl_start+1]=0xc0;
  for(let i=0;i<count;i++)vm.m[0xc000+i]=(i*37)&255;
  vm.call(S.ftp_upl_send,{bc:count});
  expect(payload.length===count&&payload.every((v,i)=>v===((i*37)&255)),"full block exact payload "+speed+"/"+count);
  expect((vm.m[S.ftp_upl_start]|vm.m[S.ftp_upl_start+1]<<8)===0xc000+count,"advance only after ACK");
  expect((vm.m[S.upl_tx_count]|vm.m[S.upl_tx_count+1]<<8)===count,"TX count excludes CIPSEND");
 }
 for(const [enabled,reply] of [[false,"busy s..."],[true,"busy s..."],[false,""]]){
  const rows={},events=[];let keys=0;
  const vm=makeCpu(code,bios,S,{image,hook:(pc,r)=>{
   if(pc===S.clear_edit_zone){events.push("clear");return {ret:true};}
   if(pc===S.inkey)return {ret:true,a:0};
   if(pc===S.KEYSCAN){events.push("key");return {ret:true,a:++keys===1?0:32};}
   if(pc===S.set_hgfx_ink_planar||pc===S.set_fdma_to_chars)return {ret:true};
   if(pc===S.PRINTHL+5){
    // The actual BIT 4,(IX+0) / RET Z has run. Collect visible text only.
    let text="",addr=r.de;while(r.m[addr]){text+=String.fromCharCode(r.m[addr++]);if(text.length>128)throw Error("unterminated dialog text");}
    const row=r.hl>>8,column=r.hl&255;const old=rows[row]||"";rows[row]=old.padEnd(column," ").slice(0,column)+text;
    const pos=(r.hl+text.length)&65535;r.m[S.HLKO+1]=pos&255;r.m[S.HLKO+2]=pos>>8;
    events.push("print");return {ret:true};
   }
  }});
  vm.m[S.flag1]=enabled?16:0;
  vm.m[S.upl_last_error]=8;vm.m[S.upl_tx_count]=0;vm.m[S.upl_tx_count+1]=8;
  vm.m[S.upl_rx_count]=11;vm.m[S.upl_rx_count+1]=0;
  vm.m.set([...chars(reply),0],S.upl_last_rx);
  vm.call(S.upl_error_dialog);
  expect(rows[22]==="U2 error=8 TX=2048 RX=11 [key: restart WiFi]","dialog visible even with print initially disabled: "+enabled);
  expect(rows[23]==="ESP: "+(reply||"(no text)"),"last ESP on persistent second line");
  expect(events[0]==="clear"&&events.at(-1)==="clear"&&events.filter(x=>x==="clear").length===2,"clear only before rendering and after key");
  expect(events.indexOf("key")>events.lastIndexOf("print"),"complete diagnostic shown before waiting");
 }
 return tests;
}

const fs=require("fs");
const symbols=fs.readFileSync(process.argv[3]||"upload-test.sym","utf8");
const S={};for(const line of symbols.split(/\r?\n/)){const m=line.match(/v0\.(\w+): EQU 0x([\da-f]+)/i);if(m)S[m[1]]=parseInt(m[2],16);}
const image=fs.readFileSync(process.argv[2]||"SARAH12BSDhgfx");
const code=image.subarray(S.upl_send_data-0x6000,S.ftp_upl_start+2-0x6000);
const bios=fs.readFileSync("WifiBios20_MB_EL.cod");
const source=fs.readFileSync("sarah_ftp_client.asm","utf8").replace(/\r\n/g,"\n");
const loop=source.slice(source.indexOf("\nftp_send_loop\n"),source.indexOf("\nftp_upl_send\n")).replace(/;[^\n]*/g,"");
if (/call\s+(s20|set_20mhz)|upload_cpu_mode/.test(loop))throw Error("Upload must not force CPU speed");
console.log((uploadRegression(makeCpu,code,bios,S)+uploadIntegration(makeCpu,code,bios,S,image))+" checks passed (simulated UART, real BIOS instructions; display/key hardware stubbed).");

