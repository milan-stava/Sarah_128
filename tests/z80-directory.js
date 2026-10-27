function makeCpu(code, bios, S, options={}) {
 const m=new Uint8Array(65536);if(options.image)m.set(options.image,0x6000);m.set(bios,0xe000);
 let a=0,b=0,c=0,d=0,e=0,h=0,l=0,ix=S.flag1,z=false,cf=false,pc=0,stack=[],steps=0;
 let rx=[], sent=[], rxReads=0, polls=0, paceIterations=0, txBusy=options.txBusy||0, lastStatus=0;
 const hl=()=>h*256+l,de=()=>d*256+e,bc=()=>b*256+c;
 let alt=[0,0,0,0,0,0],aa=0,az=false,ac=false,iy=0;
 const get=i=>[b,c,d,e,h,l,m[hl()],a][i];
 const put=(i,v)=>{v&=255;switch(i){case 0:b=v;break;case 1:c=v;break;case 2:d=v;break;case 3:e=v;break;case 4:h=v;break;case 5:l=v;break;case 6:m[hl()]=v;break;case 7:a=v;}};
 const word=()=>{let n=m[pc]|m[pc+1]<<8;pc+=2;return n;};
 const rel=take=>{let n=m[pc++];if(take)pc=(pc+(n<128?n:n-256))&65535;};
 const cp=v=>{z=a===v;cf=a<v;}, logic=()=>{z=a===0;cf=false;};
 function status(){polls++;if(options.onPoll)options.onPoll(polls,rx);if(rx[0]===null)rx.shift(); const busy=(txBusy>0||sent.length>=options.txStuckAt)?2:0;if(txBusy>0)txBusy--;lastStatus=(rx.length&&rx[0]!=null?1:0)|busy|(options.statusBits||0);return lastStatus;}
 function step(){
 if(options.hook){const result=options.hook(pc,{m,a,z,carry:cf,hl:hl(),de:de(),bc:bc(),ix,iy,stack});if(result){if(result.a!=null)a=result.a;if(result.z!=null)z=result.z;if(result.carry!=null)cf=result.carry;if(result.hl!=null){h=result.hl>>8;l=result.hl&255;}if(result.de!=null){d=result.de>>8;e=result.de&255;}if(result.bc!=null){b=result.bc>>8;c=result.bc&255;}if(result.ix!=null)ix=result.ix;if(result.iy!=null)iy=result.iy;if(result.ret){pc=stack.pop();return;}}}
 if(pc===S.upl_tx_pace_loop)paceIterations++;
 const at=pc,op=m[pc++];
 switch(op){
 case 0x31:{const sp=word();stack.length=(0xf000-sp)/2;break;}
 case 0x00:break;
 case 0x08:[a,aa]=[aa,a];[z,az]=[az,z];[cf,ac]=[ac,cf];break;
 case 0xd9:{const old=[b,c,d,e,h,l];[b,c,d,e,h,l]=alt;alt=old;break;}
 case 0xeb:[d,h]=[h,d];[e,l]=[l,e];break;
 case 0x29:{let n=hl()*2;cf=n>65535;n&=65535;h=n>>8;l=n&255;break;}
 case 0x2b:{let n=(hl()-1)&65535;h=n>>8;l=n&255;break;}
 case 0xd6:{let v=m[pc++];cf=a<v;a=(a-v)&255;z=a===0;break;}
 case 0xd2:{let addr=word();if(!cf)pc=addr;break;}
 case 0xdc:case 0xd4:case 0xc4:case 0xcc:{let addr=word();if(op===0xdc?cf:op===0xd4?!cf:op===0xcc?z:!z){stack.push(pc);pc=addr;}break;}
 case 0xd0:if(!cf)pc=stack.pop();break;
 case 0xd8:if(cf)pc=stack.pop();break;
 case 0xfd:{let o=m[pc++];if(o===0x21)iy=word();else if(o===0x23)iy=(iy+1)&65535;else if(o===0xe5)stack.push(iy);else if(o===0xe1)iy=stack.pop();else throw Error('FD '+o);break;}
 case 0x32:m[word()]=a;break;case 0x3a:a=m[word()];break;
 case 0xaf:a=0;logic();break;case 0xa7:logic();break;
 case 0x21:{let n=word();h=n>>8;l=n&255;break;}
 case 0x2a:{let addr=word();l=m[addr];h=m[(addr+1)&65535];break;}
 case 0x22:{let addr=word();m[addr]=l;m[(addr+1)&65535]=h;break;}
 case 0x01:{let n=word();b=n>>8;c=n&255;break;}
 case 0x11:{let n=word();d=n>>8;e=n&255;break;}
 case 0x77:m[hl()]=a;break;case 0x73:m[hl()]=e;break;case 0x36:m[hl()]=m[pc++];break;
 case 0x12:m[de()]=a;break;
 case 0x37:cf=true;break;case 0x3f:cf=!cf;break;
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
 case 0xcb:{const op2=m[pc++];if(op2===0x79)z=!(c&128);else if(op2===0x47)z=!(a&1);else if(op2>=0x40&&op2<=0x7f)z=!(get(op2&7)&(1<<((op2>>3)&7)));else if(op2>=0x80){const mask=1<<((op2>>3)&7);put(op2&7,op2>=0xc0?get(op2&7)|mask:get(op2&7)&~mask);}else throw Error("CB "+op2);break;}
 case 0xdd:{const op2=m[pc++];if(op2===0x21){ix=word();break;}if(op2===0xe5){stack.push(ix);break;}if(op2===0xe1){ix=stack.pop();break;}if(op2===0x19){const n=ix+de();cf=n>65535;ix=n&65535;break;}const disp=m[pc++];const addr=(ix+(disp<128?disp:disp-256))&65535;if([0x46,0x4e,0x56,0x5e,0x66,0x6e,0x7e].includes(op2)){put((op2>>3)&7,m[addr]);break;}if(op2===0x77){m[addr]=a;break;}if(op2===0x36){m[addr]=m[pc++];break;}if(op2===0x34||op2===0x35){m[addr]=(m[addr]+(op2===0x34?1:-1))&255;z=m[addr]===0;break;}if(op2===0xbe){cp(m[addr]);break;}if(op2!==0xcb)throw Error('DD '+op2);const bitop=m[pc++],mask=1<<((bitop>>3)&7);if(bitop<0x80){z=!(m[addr]&mask);}else if(bitop<0xc0){m[addr]&=255^mask;}else{m[addr]|=mask;}break;}
 case 0xed:{
 const o=m[pc++];const port=bc();
 if(o===0x73){const addr=word(),sp=0xf000-2*stack.length;m[addr]=sp&255;m[addr+1]=sp>>8;}
 else if(o===0x78){if(port!==0x793b&&port!==0x133b)throw Error("Unexpected status port");a=port===0x793b?(options.speed||0):status();z=a===0;}
 else if(o===0x58){if(port!==0x143b)throw Error("Unexpected RX port");e=rx.shift();if(e==null)throw Error("Read empty UART");rxReads++;z=e===0;}
 else if(o===0x59){if(port!==0x133b)throw Error("Unexpected TX port");if(options.checkTxReady&&(lastStatus&2))throw Error("Write while UART busy");sent.push(e);txBusy=options.txHoldPolls||0;if(options.onTx)options.onTx(sent.length,rx);}
 else if(o===0x79){if(port!==0x783b)throw Error("Unexpected OUT");}
 else if(o===0x42){let n=hl()-bc()-(cf?1:0);cf=n<0;n&=65535;h=n>>8;l=n&255;z=n===0;}
 else if(o===0x43){let addr=word();m[addr]=c;m[addr+1]=b;}
 else if(o===0x4b){let addr=word();c=m[addr];b=m[addr+1];}
 else if(o===0x52){let n=hl()-de()-(cf?1:0);cf=n<0;n&=65535;h=n>>8;l=n&255;z=n===0;}
 else if(o===0x53){let addr=word();m[addr]=e;m[addr+1]=d;}
 else if(o===0x5b){let addr=word();e=m[addr];d=m[addr+1];}
 else if(o===0xb0){let count=bc(),src=hl(),dst=de();for(let i=0;i<count;i++)m[(dst+i)&65535]=m[(src+i)&65535];src=(src+count)&65535;dst=(dst+count)&65535;h=src>>8;l=src&255;d=dst>>8;e=dst&255;b=c=0;}
 else throw Error("ED "+o.toString(16));break;}
 case 0xc0:if(!z)pc=stack.pop();break;case 0xc8:if(z)pc=stack.pop();break;case 0xc9:pc=stack.pop();break;
 default:
 if((op&0xc7)===6){put((op>>3)&7,m[pc++]);break;}
 if(op>=0x40&&op<=0x7f&&op!==0x76){put((op>>3)&7,get(op&7));break;}
 if((op&0xc7)===4||(op&0xc7)===5){let i=(op>>3)&7,v=(get(i)+((op&1)?-1:1))&255;put(i,v);z=v===0;break;}
 if(op>=0xb8&&op<=0xbf){cp(get(op&7));break;}
 if(op>=0xb0&&op<=0xb7){a|=get(op&7);logic();break;}
 if(op>=0x80&&op<=0x87){let n=a+get(op&7);a=n&255;cf=n>255;z=a===0;break;}
 if(op>=0x90&&op<=0x97){let v=get(op&7);cf=a<v;a=(a-v)&255;z=a===0;break;}
 throw Error("Unsupported "+op.toString(16)+" at "+at.toString(16));
 }
 }
 return {m,rx,sent,call(entry,regs={}){
  if(stack.length)throw Error("Stack not empty");
  a=regs.a||0;if(regs.de!=null){d=regs.de>>8;e=regs.de&255;}if(regs.carry!=null)cf=regs.carry;if(regs.hl!=null){h=regs.hl>>8;l=regs.hl&255;}if(regs.bc!=null){b=regs.bc>>8;c=regs.bc&255;}
  stack=[65535];pc=entry;let startSteps=steps;
  while(pc!==65535){if(++steps-startSteps>300000000)throw Error("step limit");step();}
  if(stack.length)throw Error("Stack imbalance");
  return {a,z,carry:cf,bc:bc(),de:de(),hl:hl(),ix,iy,polls,rxReads};
 }};
}

