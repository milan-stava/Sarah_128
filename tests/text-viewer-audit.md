# RAM-only ASCII viewer

ENTER on TXT/POK and Z on any readable file use the same viewer. Known
directories, synthetic parent items, malformed names, names over 255 bytes
and disconnected calls are rejected. NLST unknown items must pass FTP SIZE.
Transfers use TYPE I and never call file creation, disk write or deletion.

Logical data banks are 4,0,1,3. Up to 16384 bytes use only bank 4. The cached
FTP directory is invalidated before writing any subsequent bank, including
when the transfer subsequently fails or is cancelled. On return a valid
directory is redrawn from RAM; an invalid one is fetched again.

Files over 65535 bytes show a warning, then fetch only their initial 65535
bytes. The returning ABOR/NOOP barrier drains FTP control replies, closes
the data socket and exits passive receive mode. Legacy disk abort keeps its
original UI/stack-unwinding entry. Normal downloads confirm completion and
close the data socket before browsing. B cancels a RAM download.

Left selects the previous screen, right the next, BREAK exits. The page
walker is shared between drawing and scan-only modes. Previous-screen
lookup rescans from offset zero; there is no page history or frame buffer.
CRLF is one newline, including at a bank/page boundary. Lone CR/LF also
break lines. TAB occupies one column; other non-ASCII/control bytes become
dots. Delayed wrapping avoids a blank line after exactly 64 characters.
Drawing dimensions use existing HGFX max_chars/max_lines; ZX uses 64x24.

Most logic and all viewer state are in bank 6. A fixed-RAM bridge fills an
aligned 256-byte window in the existing INPBUFF, after FTP is finished and
the filename is no longer needed. A two-byte bank-6 tag tracks this cache;
opening another file invalidates it. A second bridge receives whole modem
blocks without crossing a bank boundary. No additional data buffer is allocated.
Drawing and backward scanning run at 20 MHz; keyboard polling resumes at
3.5 MHz. Timing on hardware remains unmeasured. For the actual assembled
scan near EOF of a 65535-byte dense text, the CPU model measured 506 bank
switches / 3113303 instructions versus 129108 / 4202370 before caching.

## Size (BS-DOS, compared with the user's entry stubs before implementation)

| Item | Before | After |
| --- | ---: | ---: |
| bios_start | #A574 | #A65F |
| first byte after BIOS | #A794 | #A87F |
| available before #BFE0 | 6220 B | 5985 B |
| program bank 6 | 2115 B | 2874 B (includes subsequent NMI/TAP/help/profile changes) |

Net fixed-RAM increase: **198 bytes**, including menu/abort, TYPE and cache fixes.
Local help adds another 30 fixed bytes, profile auto-login another 7;
the current combined increase is **235 bytes**. Fixed viewer bridges: 195 B;
bank-6 viewer/state/texts, including direct local-help reading: 642 B.
sara.hlp is external and consumes no assembled program memory.

TYPE/SIZE regression: TYPE I clears INPBUFF and must run before the viewer
copies the filename. Z sends TYPE first; ENTER TXT/POK uses the .ready entry
because enter_directory has already sent TYPE. The bank controller never
sends TYPE after name preparation. A regression executes the real destructive
TYPE helper for both entry paths, asserting one TYPE and the correct SIZE name.
It failed before the fix and passed after it; 333876 checks per BSDOS/ESXDOS
were rerun, excluding only the previously passed long navigation stress loops.

BS-DOS: boot SARA_LOADER.tap. ESXDOS now also needs its viewer bank;
boot the new SARA_ESX_LOADER.tap. SARAH12ESX.tap is the legacy main block
and is not a complete two-bank distribution. Ship the matching loader,
sara.cfg and sara.hlp together. BS-DOS K now reads the local help directly
into bank 6 without FTP; see local-help-audit.md. Generic local-disk file
browsing remains outside this viewer's FTP entry.

## Validation

After the cache optimization: 336674 viewer checks passed in each of the
BS-DOS and ESXDOS variants, plus 15903 existing BS-DOS regressions.
The full navigation stress loops were rerun. They require at most 520 bank
switches for Page Up plus redraw at maximum file size, including the
2700-screen all-newline case. Tests cover cache hits/misses, bank edges,
cache invalidation between files and CPU speed at draw/keyboard endpoints.

BS-DOS, ESXDOS and HGFX builds: zero errors/warnings. A menu-length ASSERT
guards the directory menu's 42 available columns.

tests/text_viewer.test.js executes actual assembled control, paging,
receiving and pagination instructions with eight modeled physical RAM banks.
FTP/BIOS/drawing endpoints are mocked. Each variant passed 333874 checks,
including byte preservation, partial/empty frames, cancellation and failure,
16384/16385 and 65535/65536 boundaries, 702026-byte advertised files, and
backward navigation after over 2700 screens without a history table.
Existing BS-DOS regression suites passed another 15903 checks (FTP, abort,
directory, INPUT, extensions, CFG parser/browser and browser exit).

Node CLI, after building symbols and a combined TAP:

    node tests/text_viewer.test.js . SARA_LOADER.tap directory-test.sym
    node tests/text_viewer.test.js . SARA_ESX_LOADER.tap directory-esx-test.sym

In this environment Node is absent from PATH; the same JavaScript CPU
model and test function were executed through the available V8 runtime.
Live Wi-Fi timing, display output and emulator/hardware integration remain
to be tested. Snapshot/TAP launch runtime testing also remains pending.
