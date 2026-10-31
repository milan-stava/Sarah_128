# FTP action guards, 2026-10-30

Public FTP actions now reject missing connections before prompts, TYPE commands,
directory snapshots or cursor dereferences. Shared checks use flag1 bit 5 and
the control-socket CLOSED bit (at_closed bit 0). Data-socket closure alone does
not reject an action. Item actions also require flag_dir bit 0.

Raw C commands require status_byte="3" and an open control socket, preserving
manual USER/PASS command access. Cached directory movement, selection and
marking remain available offline. Key 7 is dispatched without requiring a
previous directory listing. undraw_cursor ignores an absent directory.

action_guards.test.js executes assembled BSDOS and ESXDOS entry points and
the keyboard loop: 1697 assertions each. It covers stale connection flags,
closed control/data sockets, absent/valid directory state, protected buffers,
balanced keyboard returns and offline memory operations.

Run after assembly: node tests/action_guards.test.js [esx].
download_return.test.js now explicitly supplies a valid directory for its bulk
download fixture, as required by the public entry contract.

Regression checks passed for extensions, downloads and cached return, directory
protocol/position/cleanup/checksum, Wi-Fi protocol/initialization, startup,
input and text viewer in both builds. BSDOS-only upload disk path, CFG,
profile selection, local help and snapshot checks also passed. Tests execute
assembled Z80 with simulated hardware; intermittent real-machine freezing
still requires a user retest.

Size measured against the same sources with only the menu correction:
BSDOS bios_start #A65C -> #A696: +58 bytes below #C000.
Menu removal saves 3 bytes: net +55 versus the previous commit.
BIOS length #220, end #A8B6; 5930 bytes remain before reserved #BFE0,
plus 32 bytes reserved up to #C000. Bank 6 remains #B3A bytes.
Both normal builds: zero errors/warnings, HGFX remains disabled.
