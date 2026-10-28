# Current runtime profile selector

The current G selector, file-reader changes, byte counts and validation are
documented in [cfg-profiles-audit.md](cfg-profiles-audit.md). The following
sections describe historical loader versions.

# Historical compact loader checkpoint — 2026-10-27

The user manually shortened the bank-6 module and renamed it to
2nd_program_bank.asm. The current module occupies 444 bytes (81 fewer than
525). The current BSDOS build has zero errors/warnings and its complete
SARA_LOADER.tap has checked headers and checksums. The user reports successful
CFG operation in the emulator: the BSDOS version loads sara.cfg and applies
the profile selected by Default=1.

This loader reuses file_exist+3, load_init and load_file+4. Unlike the earlier
loader below, it does not check the 32-bit body length against bank capacity
before loading, and load_init uses disk_buf_len before its normal startup
initialization. These limitations were discussed; the user retained the compact
implementation. The former IX/IY preservation wrapper is also absent; startup
now runs the CFG load before the Wi-Fi BIOS and flag-pointer initialization.
The former 709-assertion loader regression suite assumes the previous service
sequence and register-preservation contract and needs adaptation to this version.
Its previous passing result does not validate the current compact disk loader.

The new low-level Wi-Fi routines remain UNTESTED ON REAL HARDWARE. Upload
remains a known broken/deferred issue. Emulator CFG success is separate from
Wi-Fi hardware validation.

The following audit describes the earlier 525-byte loader, not the current one.

# CFG in bank 6 — 2026-10-27

BSDOS startup maps bank 6, calls `load_cfg`, then maps bank 0. The bank-6
module is assembled at #C000 and packaged as SARA2 in SARA_LOADER.tap.
Use this complete tape for testing; the old main-only binary/tape does not
load the required bank 6.

`2nd_program_bank.asm` searches the current BS-DOS directory for the exact 10-byte
name `sara.cfg  `. It checks service results and the 32-bit body length from
GETSUB before issuing LOA1X. The buffer starts immediately after the module;
the last byte of the bank is reserved for its zero terminator. Runtime CFG
text is not part of the SARA2 tape block.

The first exact Default=1 is selected. Name, Host, Port, User, Pass, File and
Start must follow in the documented order. Names, lengths and decimal ranges
are validated in a first pass; a second pass applies the profile. Failure
leaves existing settings intact. Empty Pass clears the password; empty File
and Start retain their current values. CR/LF/CRLF, comments, leading whitespace
and a final line without an EOL are accepted. Values are not silently truncated.

All routines and profile storage in bank 6 occupy 525 bytes (original repaired
version: 581 bytes, saving 56 bytes). Maximum CFG body length is 15,858 bytes.
There are 6,695 bytes free before #BFE0 in fixed memory.

Validation uses the assembled instructions in `tests/cfg.test.js`, with only
the external BS-DOS service stubbed. The existing `sara.cfg.txt` is the sample.
Tests cover profile selection, empty values, field limits, malformed/truncated
profiles without partial writes, numeric overflow, disk-service failures,
every 1KB sector boundary, the bank limit, and preservation of IX/IY and code.
All 709 CFG assertions passed after optimization. The 1,979 existing regression
assertions also passed during this change; they do not exercise physical paging.
The actual BS-DOS firmware/disk and paging on hardware still need testing.

Reproduce with:

    D:\zx\Tools\SjasmPlus\sjasmplus.exe --sym=directory-test.sym assembly_mbbsd1.asm
    node tests/cfg.test.js

Node is unavailable in the current environment; the same regression function
was executed in the JavaScript tool runtime with the assembled image and TAP.
