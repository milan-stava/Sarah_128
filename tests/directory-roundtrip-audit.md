# Directory return corruption, 2026-10-30

Reported on BS-DOS: returning up the tree selects the last directory item
instead of restoring the previous screen page and cursor row.

Root cause: enter_directory and TAP/snapshot dispatch used literal IX+41 for
the extension byte. Current flags layout places dir_list_pointer at IX+40..41
and item_extension at IX+42. Each ENTER overwrote the history pointer's high
byte. For a normal directory (extension 10), #5F80 became #0A80, pointing into
ROM. History could not be written correctly on hardware; a bogus saved ordinal
is clamped to the last listing item by restore_dir_view.

All three extension references now use IX+item_extension-flag1. The label
comment is corrected and an assembly assertion checks displacement range.
Instruction sizes are unchanged: +0 bytes in fixed RAM and bank 6.

The new directory_roundtrip.test.js fails on the previous binary at
"failed ENTER preserves history pointer". With the fix it passes 140 checks
per DOS build. It executes real ENTER, parsing, extension classification,
history save/pop, item_add/item_sub and position restoration. Server responses,
new listings, paging and drawing are simulated. It covers failed CWD, ENTER,
BREAK and ENTER on '..', rows/pages, variable-length entries and bank crossing.
Existing position, directory protocol, extension, download return, text-viewer,
FIND cache, action guard and snapshot tests also passed.

Run after assembly: node tests/directory_roundtrip.test.js [esx].
Both loader TAPs rebuilt, zero assembly errors/warnings, HGFX off.
BS-DOS bios_start remains #A6A9; free space before #BFE0 stays 5911 bytes.
User should load the new SARA_LOADER.tap and repeat directory traversal.
