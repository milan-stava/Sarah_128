# Cached FIND input, 2026-10-30

I edits the last confirmed query using the existing input_line_edit editor.
Bank-6 find_cache starts with 64 zero bytes. Cancel or empty ENTER leaves it
unchanged. Accepted text is copied before FIND lowercases INPBUFF, with a zero
terminator at the actual length. A shorter replacement therefore has no stale
suffix. The cache is outside CFG/help's reusable workspace.

The fixed-RAM find_input bridge maps bank 6 for the editor and cache update,
then restores the original directory bank. It retains the editor flags across
PAGE128 using AF'. No directory or network operation occurs while editing.

tests/find_input.test.js executes the real assembled editor and physical paging
for original pages 0, 1, 3, 4, 6 and 7: 1386 assertions per DOS variant. It tests
empty startup, acceptance/reuse, scratch-buffer overwrite, BREAK, empty ENTER,
short replacement, 63-character bounds, cursor position, untouched other banks,
and the full FIND entry through normalization and entry into the directory scan.
Run after assembly: node tests/find_input.test.js [esx].

Existing input, directory, download, text-viewer, FTP guard and Wi-Fi regressions
passed for both variants. BSDOS CFG/profile/help/upload and snapshot checks
passed as well. Hardware paging/timing remains for a user retest.

Compared with the immediately preceding FTP-guard build:
- Fixed RAM: +19 bytes, BSDOS bios_start #A696 -> #A6A9.
- Bank 6: +81 bytes = 17 bytes of code + 64 bytes of cache.
- BSDOS bank length #B3A -> #B8B, cfg_file_here moves to #CB8B.
- BSDOS BIOS ends at #A8C9; 5911 bytes remain before reserved #BFE0.
- ESXDOS bios_start #A6A2 -> #A6B5, bank length #282 -> #2D3.

Both normal loader TAPs rebuilt without errors/warnings. HGFX remains off.
