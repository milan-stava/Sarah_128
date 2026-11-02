# Common 128K functionality, 2026-11-02

Both DOS builds now include local CFG profile selection (G), local sara.hlp
(K), and V saving the complete application, including bank 6. Most new code
and all main menu strings live in bank 6. HGFX remains disabled.

ESXDOS disk corrections: F_OPEN overwrite includes write permission (#0E),
upload reads target the download buffer at #C000 instead of live code at
#6000, 32-bit remaining sizes and exact-16K boundaries are handled, and
short reads/writes fail with the handle closed. Empty uploads avoid CIPSEND=0.
Local CFG/help use native file calls with close-on-error and quiet startup
failure. CFG bounds use the actual end of bank-6 code as their workspace.

V emits six TAP records: BASIC header/data, main header/data (#6000 bytes),
and bank-6 header/data. It shares the release BASIC loader data. BS-DOS
retains ROM tape output; ESXDOS redirects it to SAR12SAV.tap. Saved images
invalidate the directory cache. Normal completion, returned ROM failures,
ROM BREAK via ERR_SP, and ESXDOS open/close failures restore caller context.
The tests model ROM/filesystem endpoints; physical tape output and installed
ESXDOS ROM interception still require hardware testing.

Main-screen key descriptions were checked against dispatch. A third menu
row describes shifted download/list/mark/password keys and arrows; directory
hints retain their counter columns and BS-DOS TAP switches retain row 22.
Dynamic autologin/Wi-Fi columns are preserved. Contextual editor, transfer,
profile and confirmation keys remain described in prompts/help.

Removed proven unused code: DIR128_MAP_CURRENT and its error helper,
clear_buffers' unused prefix (retaining cb1/cb2 used by RX clearing),
clear_TX_buf, keywait, and the superseded Save/tapeout helpers and headers.
Fall-through entries and aliases were retained, including DIR128_FIRST_PAGE
and HL2ASCII_00000. This is a conservative reference/control-flow audit,
not a claim of formal whole-program reachability proof.

Compared with the pre-port baseline (already including ESXDOS launchers):

| Build | Fixed code delta | Free below #BFE0 | Bank 6 delta | Bank 6 used |
| --- | ---: | ---: | ---: | ---: |
| BS-DOS | -174 B | 6280 B | +524 B | 4056 B |
| ESXDOS | -163 B | 6165 B | +1839 B | 3058 B |

Both assemblies: zero errors/warnings. Final regression run: 61 executions,
1,107,151 assertions, plus TAP handoff 1,071 assertions. Tests execute the
assembled code with modeled device endpoints. New menu, Save, and native
ESXDOS local I/O cases are included. sara.hlp lines fit 64 columns.

Next hardware checks: both complete loader TAPs; G/K on ESXDOS; V then reload
on each DOS; empty, exact-16K and multi-bank transfers; ESXDOS launches and
error returns; aligned suffix/scrolling and all four BS-DOS TAP options.
No new commit/push or local FTP copy was made in this step.
