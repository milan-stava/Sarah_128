# Runtime CFG profiles (G)

BS-DOS G reloads sara.cfg and shows the first 32 Name= records in the directory
window, eight visible rows. Your profiles: is shown above the list. Up/Down moves the full-width directory
cursor and immediately previews the
profile in the existing File/Start and Host/User/Pass rows; Port appears in the
selector prompt. Enter keeps the selected values. BREAK restores the values
from before G. A malformed profile cannot be confirmed and leaves the entry
settings visible. Changing selection sends no FTP commands and does not change
the existing server connection.

Movement within the viewport only removes and redraws the shared cursor and
updates the settings fields. At either edge, the viewport moves by one row:
seven existing rows are copied in the safe overlap direction, the exposed row
is cleared, and only its new name is printed. The heading is printed once.
ZX bitmap copies handle all eight interleaved pixel stripes; the HGFX variant
uses its linear COPY aperture with explicit source/destination offsets. There
are no page keys or repeated full list redraws while navigating.

Implementation is in 2nd_program_bank.asm (RAM bank 6). The ordinary key loop
has a conditional CALL for G and a short fixed-memory paging trampoline. The
handler returns A=0 through RET to the next key test. The trampoline
restores mapping before redrawing the cached FTP directory, because directory
printing can itself map banks. Profile highlighting calls the shared
draw_cursor_row entry after the directory lookup/paging prelude. The actual
row renderer is reused, with the directory cursor variables left untouched.
The heading and profile highlight are cleared on all normal exit paths. The original directory contents, cursor, page,
markings and navigation history are retained. No directory reread or PWD is
issued by the selector.

There is no profile index table or extra backup allocation. Profile lookup
rescans the bounded CFG, with single-byte indexes capped at 32. INPBUFF stores
the entry settings and is not used for input editing while the modal selector
is open. Each preview starts from the same entry snapshot, so empty File/Start
do not inherit a previous preview. The existing two-pass profile parser and
printing routines are reused. The file reader now rejects an empty or oversized
body before loading it into the remaining bank space. Empty masked passwords
also no longer run a 256-character DJNZ loop.

Compared with commit 19f060d:

| Region | Previous | Current | Added |
| --- | ---: | ---: | ---: |
| Program bank 6 | 444 B | 1066 B | 622 B |
| Fixed-memory code/data before the paging routine | — | — | 38 B |
| Total | | | 660 B |

There are 6,657 bytes free before #BFE0 in fixed memory. Maximum CFG body length
is 15,317 bytes, including room for a separate zero terminator at the bank end.
SARA_LOADER.tap contains BASIC, SARA1 (24,576 bytes at #6000), and SARA2 (1066
bytes at #C000 in bank 6); total tape size is 25,841 bytes. Scrolling adds 104 B
versus the previous 962 B version, entirely in bank 6. A temporary limit-64
variant had the same code size as the original limit-32 variant (927 B). Both saved 9 bytes
against the original selector with 16-bit indexes. Another 6 bytes were removed
from the paging trampoline. The subsequent shared-cursor/heading/CALL revision
adds 31 B total versus that version: bank 6 +35 B, fixed memory -4 B.

Validation: BSDOS, HGFX and ESXDOS builds have no errors/warnings (selector is BSDOS
only); TAP block checksums, sizes and load addresses checked. The assembled
regressions include 685 CFG checks, 10,195 browser/bitmap checks, 144 exit checks,
and 1,979 existing checks (13,003 total).
The browser tests cover live previews, changed CFG on a subsequent G, cancel,
optional empty fields, malformed/missing files, duplicate names, scrolling through 32 records,
the 32-profile cap with 260 input records, preservation of directory state,
the actual bank-switch trampoline, no network requests, and masked passwords. Full-width cursor tests execute the actual row renderer,
verify its 32 attribute bytes and surrounding memory, and exercise the actual
G CALL dispatch through its return address and stack.
The real assembled ZX LDIR/LDDR and exposed-row clear code execute in the CPU
model. All eight stripes are checked after each movement, including scrolling
back from the last profile, direction reversals, blocked end movements, and
guards outside the window. Name-print counts verify that ordinary movement
prints nothing and each edge scroll prints exactly one new name.

cfg_exit.test.js follows the real G CALL through ENTER/BREAK, real text/field
rendering, the full cached two-record directory redraw, remaining key dispatch,
an empty UART check, and the next keyboard poll. It covers both exit keys with
and without a directory and before/after scrolling. It checks retained/restored
settings, IX, balanced calls, bank restoration, directory positions/data, and
guards in the system/stack memory area. Disk reading, keyboard input, physical
paging and idle UART input are substituted; drawing is not stubbed in this test.
The reported intermittent ENTER crash was not reproduced by these checks or by
the user's next emulator attempt. No program bytes were changed for this audit;
the original cause remains unconfirmed and real-hardware testing is pending.

The JavaScript CPU model substitutes BS-DOS disk I/O, keyboard input, and drawing
for browser tests; bitmap copying and ZX cursor writes execute directly. HGFX
was compiled but its hardware COPY aperture has not been emulated or tested.
The real hardware, Wi-Fi timing, and the new visual selector
in an emulator still need user validation. The low-level Wi-Fi changes remain
untested on real hardware; upload remains a separate known broken issue.

Reproduce after the BSDOS build with Node:

    node tests/cfg.test.js
    node tests/cfg_profiles.test.js
    node tests/cfg_exit.test.js

Node is unavailable in the current workspace; these same regression functions
were executed in the JavaScript tool runtime using the assembled image and TAP.
