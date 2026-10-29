// node tests/tap_handoff.test.js <build directory containing bsd.sym and SARA_LOADER.tap>
// Execute actual relocation copies; ROM, disk and physical paging are simulated.
const fs = require('fs'), path = require('path'), vm = require('vm');
vm.runInThisContext(fs.readFileSync('tests/z80-directory.js', 'utf8'));
const root = process.argv[2], S = {};
for (const line of fs.readFileSync(path.join(root, 'bsd.sym'), 'utf8').split(/\r?\n/)) {
 const m = line.match(/^v0\.(\S+): EQU 0x([0-9A-F]+)/i);
 if (m) S[m[1]] = parseInt(m[2], 16);
}
const tape = fs.readFileSync(path.join(root, 'SARA_LOADER.tap'));
const blocks = [];
for (let p = 0; p < tape.length;) {
 const n = tape.readUInt16LE(p); p += 2;
 const block = tape.subarray(p, p + n); p += n;
 if (block.length !== n) throw Error('truncated tape');
 if (block.reduce((a, b) => a ^ b, 0)) throw Error('TAP checksum');
 blocks.push(block);
}
let checks = 0;
const assert = (ok, msg) => { if (!ok) throw Error(msg); checks++; };
const codeBlock = name => {
 const i = blocks.findIndex(b => b[0] === 0 && b.length === 19 && b.subarray(2, 12).toString('ascii').trim() === name);
 assert(i >= 0, name + ' header exists');
 const body = blocks[i + 1].subarray(1, -1);
 assert(body.length === blocks[i].readUInt16LE(12), name + ' length');
 return body;
};
const image = codeBlock('SARA1'), bank6 = codeBlock('SARA2');
assert(bank6.length === S.program_page_len, 'bank 6 packaged completely');
assert(S.stpb === 0x5b00 && S.rstpe + 0x8e <= 0x5c00, 'loader and ROM-init scratch fit');
assert(0x4000 + S.tapmaster_len <= S.SPCKO - 64, 'code below stack reserve');
const source = bank6.subarray(S.tapmaster_start - 0xc000, S.tapmaster_start - 0xc000 + S.tapmaster_len);
assert(source.length === S.tapmaster_len, 'complete relocation source');
const stop = {};
for (const flags of [0, 0x20, 0x40, 0x60, 0xdf, 0xff]) {
 let paged = false, copied = false, cpu;
 cpu = makeCpu([], new Uint8Array(), S, {image, hook(pc, r) {
  if (pc === S.START) {
   assert(Buffer.from(r.m.slice(0x4000, 0x4000 + source.length)).equals(source), 'actual work_tap copy');
   assert((r.m[S.fnum] | r.m[S.fnum + 1] << 8) === 321, 'input file number preserved');
   copied = true;
  }
  if (pc === S.PAGE128) {
   assert(copied && r.a === 0, 'bank 0 selected only after relocation');
   assert(r.m[S.del_tap + 1] === (flags & 0x20), 'delete flag captured independently');
   r.m.fill(0xa5, 0xc000); paged = true;
   return {ret: true, a: 0x10};
  }
  if (pc === S.set_20mhz) { assert(paged, 'TAPmaster continues after unmapping source'); throw stop; }
  // This CPU model has no interrupts; DI has no effect in this simulation.
  if (r.m[pc] === 0xf3) r.m[pc] = 0;
 }});
 cpu.m.set(bank6, 0xc000); cpu.m[S.flag2] = flags;
 cpu.m[S.fnum] = 321 & 255; cpu.m[S.fnum + 1] = 321 >> 8;
 try { cpu.call(S.work_tap); throw Error('handoff did not reach START'); } catch (e) { if (e !== stop) throw e; }
}
{
 let cpu, normalSpeed = 0;
 cpu = makeCpu([], new Uint8Array(), S, {image, hook(pc, r) {
  if (pc === S.set_3_5mhz) { normalSpeed++; return {ret: true}; }
  if (pc === 0x3c98) { assert(normalSpeed === 1, '3.5 MHz before ROM/loader handoff'); return {ret: true}; }
  if (pc === S.stpb) {
   const n = S.move_len1 + S.move_len2;
   assert(Buffer.from(r.m.slice(0x5b00, 0x5b00 + n)).equals(Buffer.from(r.m.slice(S.odkud, S.odkud + n))), 'actual loader copy and jump to #5B00');
   throw stop;
  }
 }});
 cpu.m.set(source, 0x4000);
 try { cpu.call(S.run1); throw Error('loader not reached'); } catch (e) { if (e !== stop) throw e; }
}
// All 1024 sector offsets must keep rounded reads inside bank 0.
for (let offset = 0; offset < 1024; offset++) {
 const start = S.seq_buff - offset, bytes = Math.ceil((S.seq_buf_len + offset) / 1024) * 1024;
 assert(start >= 0xc000 && start + bytes <= 0x10000, 'sector read stays in bank');
}
// A checksum mismatch is advisory: report it and return to extraction.
for (const parity of [0x23, 0x24]) {
 let reports = 0;
 const cpu = makeCpu([], new Uint8Array(), S, {image, hook(pc, r) {
  if (pc === S.load_block_no_save_len_in_HL) {
   assert(r.hl === 1, 'CRC reads one parity byte');
   r.m[S.seq_buff] = parity;
   return {ret: true};
  }
  if (pc === S.bsdos_tm) {
   assert(r.a === 0x34 && r.hl === S.xor_err, 'checksum warning service');
   reports++;
   return {ret: true};
  }
 }});
 cpu.m.set(source, 0x4000); cpu.m[S.xor_start + 1] = 0x23;
 cpu.call(S.evaluate_crc); // must return with a balanced stack, including mismatch
 assert(reports === (parity === 0x23 ? 0 : 1), 'warning only on CRC mismatch');
 assert(cpu.m[S.xor_yes_no] === 1, 'CRC checking remains enabled for next block');
}
console.log({checks, tapmasterBytes: S.tapmaster_len, bank6Bytes: bank6.length});
