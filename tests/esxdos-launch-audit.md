# ESXDOS launch routines merged onto f1badad, 2026-11-02

The user's saved main source unintentionally reverted many earlier changes.
Both DOS review builds failed with 21 errors each (missing legacy upload
include/symbols, missing TAP return/guards, and incomplete ESXDOS dispatch).
Per the user's explicit instruction, restored sarah_ftp_client.asm and
2nd_program_bank.asm from HEAD f1badad, then transferred only the new ESXDOS
TAP/snapshot/disk launch functionality. Original files and full diff are backed
up in TEMP/sara-user-esx-edits-20261102-111803/ (user-edits.patch included).

Implementation retains the user's API calls and commands:

- TAP: M_TAPEIN (B=0, IX=actual local filename, A=DefaultDrive), then
  M_AUTOLOAD with A=0. No deletion is performed in ESXDOS.
- SNA/Z80: M_EXECCMD with `snapload <actual local filename>`.
- TRD/SCL: download first, `vdisk 0` to eject, then
  `vdisk 0 <actual local filename>`; only successful mounting enters TR-DOS
  at #3D00 with IY=#5C3A, IM 1, RAM page 0, SP=65000 and interrupts enabled.

All five types share the existing single-file download/error check. The
symbolic item_extension-flag1 offset is retained (#2A/42, not literal 41).
Only correctly defined `bs_dos` conditionals are used. ESXDOS code is separate
from BS-DOS in esxdos_launch_bank.asm and esxdos_launch_io.asm.

Bank 6 builds the bounded command in existing fixed-RAM INPBUFF; no bytes are
written before exp_name. Terminal ESXDOS calls execute below #C000 because
snapshot/autoload can change the upper mapping. The return page is saved by
the common entry. Failures restore that mapping and IX=flag1, retain the native
error byte in esx_last_error, show the existing disk error 15 and return to
Sarah without FTP cleanup. A returning snapshot command never enters TR-DOS;
a returning TAP autoload never falls into HALT/string data. Successful loaders
take over. Corrupt snapshots that already overwrite caller memory are outside
what a caller-side return handler can recover.

API cross-checks (not a substitute for testing the installed ESXDOS version):
- https://board.esxdos.org/viewtopic.php?id=298 (M_EXECCMD IX and carry result).
- https://sarah.speccy.cz/sarah/nextzxos_api.pdf (compatible M_TAPEIN interface).
Actual SCL mounting depends on the installed VDISK implementation.

Validation:
- Both normal builds: zero errors, zero warnings.
- BS-DOS SARA_LOADER.tap is byte-for-byte equal to HEAD f1badad
  (Git blob b4e2af15546224f42e0b8f620532f4b84b1a834d); same for main/bank usage.
- 52 assembled-Z80 regression runs: 749874 assertions pass.
- BS-DOS TAP relocation/handoff: 1071 assertions pass.
- New ESXDOS tests: 42 scenarios / 2482 assertions, exercising ENTER and real
  classification/paging/command construction for all five types, LIST/NLST,
  crossing-bank names, actual saved 8.3 name differing from remote name,
  failed download/attachment/eject/mount/load, unexpected loader returns,
  command order, no deletion, native error and RAM/IX/stack restoration.
- Test interpreter adds RST #08; the service endpoint consumes its following
  byte as ESXDOS does. Real ROM/disk/interrupt behavior is modeled, not tested
  on hardware. TR-DOS final stack/EI/jump bytes are inspected before takeover.

ESXDOS growth versus f1badad: +142 bytes below #C000, +64 bytes in bank 6.
Free before #BFE0: 6002 bytes; bank 6 now 1219 bytes. BS-DOS usage unchanged.

Next: user hardware test with installed SNAPLOAD/VDISK, including SCL support,
failure return, and preserved existing directory scrolling/TAP controls.
No new commit, push, or local-FTP copy performed for this merge.
