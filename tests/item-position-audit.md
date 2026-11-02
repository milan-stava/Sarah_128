# Selected directory ordinal and J jump, 2026-11-02

Both DOS variants show the 1-based selected ordinal in the five rightmost
columns of the File/Start row. The synthetic parent '..' is item 1; no cached
listing displays zero. item_counter remains at IX+35. The field is overwritten
at full width, so changing 100 to 99 does not leave an obsolete digit.

Bank 6 tracks the last committed cursor pointer, page companion and ordinal.
draw_cursor refreshes the counter/display after all navigation paths, and
prn_file_start refreshes the field after clearing its row. Temporary traversal
for PRINT/FIND/marking does not change the cached selection. A low-RAM bridge
walks the difference using the existing bank-aware item_add/item_sub and always
returns to bank 6. Ordinary up/down therefore needs at most one record walk;
page movement needs at most one screen, including partial pages. Arbitrary FIND
or restored selections can need a longer walk once. Directory replacement
explicitly invalidates the cache after the FTP guard accepts the operation.

J is available whenever a cached directory exists, including offline. Its
five-character editor and checked conversion run in bank 6 and share the
existing CFG decimal parser. Blank/cancelled input, zero, nondigits, overflow
and ordinals above the current directory count leave the selection unchanged.
The upper bound uses the current listing format: NLST item count, or LIST
files + directories, plus the synthetic parent. A valid ordinal uses the
existing restore_dir_view path and starts on the first displayed row. No FTP
command, directory reread or mark changes are needed. J is in menu and help.

Relative to commit f50f154 (identical growth on both DOS variants):

| Component | Below #C000 | Bank 6 |
| --- | ---: | ---: |
| Counter/display | +47 B | +194 B |
| J input/jump, including menu | +28 B | +89 B |
| Total | +75 B | +283 B |

Free below #BFE0: BS-DOS 6205 B, ESXDOS 6090 B. Bank 6 used: 4339 B and
3341 B respectively. The fixed 24K main TAP block is padded, so its file size
does not show fixed-code growth.

Validation: both builds have zero errors/warnings. Existing 61 regression
executions pass 1,107,164 assertions, plus the two new position runs pass
33,685 each (3,580 navigation steps each), plus TAP handoff 1,071. Position
fixtures cover 1/2/7/8/9/17/330/1000 records, four data banks, real cursor/page
movement, real FIND matching and missing matches, history restoration,
temporary page traversal, invalidation, LIST/NLST jump bounds and 16-bit
decimal shrinking/padding. Physical paging, input endpoint and drawing are
modeled. Existing editor tests cover the real input implementation. The CPU
test model gained RL, CPI and its P/V-controlled JP PE/PO to run these paths.

Hardware check remains pending: watch the field during arrows/pages, FIND,
parent return, refresh, marking, text/screen/help/profile return; use J on
first/middle/last and across banks, then invalid/overflow/out-of-range input
and BREAK. No directory: J must be ignored. Original seven pending hardware
test groups remain pending as recorded in STAV-ROZPRACOVANO.md.
