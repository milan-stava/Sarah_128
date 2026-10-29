// Execute NMI version parsing and handoff with the menu's VER bytes modeled.
function snapshotEntryRegression(makeCpu,image,bios,S,bank6) {
 let checks=0,cases=0;
 const assert=(ok,s)=>{if(!ok)throw Error(s);checks++;},stop={};
 function run(tens,units,accept) {
  cases++;let entered=false,rejected=false,ports=[];
  const cpu=makeCpu([],bios,S,{image,onOut:(port,a)=>ports.push([port&255,a]),hook(pc,r){
   if(pc===S.slb){rejected=true;throw stop;}
   if(pc===0x11dd){entered=true;assert((r.m[0x5aa0]|r.m[0x5aa1]<<8)===321,'downloaded file number handed to menu');assert(0xf000-2*r.stack.length===0x57e2,'menu stack installed');throw stop;}
  }});
  cpu.m.set(bank6,0xc000);cpu.m[0x26d2]=tens;cpu.m[0x26d3]=units;
  cpu.m[S.fnum]=321&255;cpu.m[S.fnum+1]=321>>8;
  cpu.m[0x5aa0]=0xa5;cpu.m[0x5aa1]=0xa5;
  try{cpu.call(S.work_snap);throw Error('unexpected normal return');}catch(e){if(e!==stop)throw e;}
  assert(entered===accept&&rejected!==accept,'version acceptance '+tens+'/'+units);
  assert(ports.length===1&&ports[0][0]===23&&ports[0][1]===0x63,'NMI page mapped before reading VER');
  if(!accept)assert(cpu.m[0x5aa0]===0xa5&&cpu.m[0x5aa1]===0xa5,'unsupported menu receives no file number');
 }
 for(let v=0;v<100;v++)for(const inverse of [0,128])run(48+Math.floor(v/10),(48+v%10)|inverse,v>=65);
 for(const bad of [0,32,47,58,65,127,255]){run(bad,0xb7,false);run(54,bad,false);}
 return {checks,cases};
}
