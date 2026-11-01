# Aligned directory extensions, 2026-11-01

The last suffix of one to three printable, non-space characters is displayed
in the same three-column field at the right edge. The preceding column is a
blank separator. Case is retained. Multiple dots use the final dot; a name
consisting only of `.suffix` remains a dotfile. Trailing dots, missing suffixes,
and suffixes longer than three characters retain the old whole-row display and
scrolling. Known LIST directories and the synthetic `..` are never split.
NLST does not provide the item type; suffix handling is necessarily syntactic.
Full LIST remains unsplit because the existing parser does not extract its name.

For split rows, X/Z move the body while the suffix stays in its fixed column.
Two dots mark further text to the right and disappear at the final window.
For unsplit rows, normal truncation and whole-row scrolling are preserved.
LIST metadata remains part of the displayed body. No directory or filename
bytes are rewritten; download, rename, delete and extension classification use
the original data. The initial X movement and dispatch of the exit key remain.

`directory_display_bank.asm` holds formatting, scrolling and all display state
in bank 6, included for both DOS builds. Low-memory bridges perform directory
reads, restore bank 6 before returning, and restore directory mapping for row
attributes and after scrolling. Reads copy at most one visible row plus a
separate four-byte tail; long names do not require scanning their whole body.
The existing `dir_print_buf` is reused. No extra fixed-RAM buffer is allocated.

Relative to commit 03a1194 (same result for both DOS variants):

| Region | Change |
| --- | ---: |
| Used fixed RAM below #C000 | -245 bytes |
| Bank 6, code and state | +429 bytes |
| Combined used space | +184 bytes |

BS-DOS BIOS now starts at #A5B4 and ends at #A7D4, leaving 6156 bytes before
the paging code at #BFE0. Bank 6 is 3387 bytes (#0D3B), with 12997 bytes free.
The BS-DOS combined SARA_LOADER.tap is 28162 bytes; its main block is padded
to a fixed size, so the TAP grows by the bank-6 increase rather than by 184.

Both normal DOS builds compile without errors or warnings. HGFX remains off.
Executed assembled-Z80 regressions through the available JavaScript runtime:

- New display tests: 264 scenarios per build, 42014 assertions in total.
  Includes 1/2/3-character and longer suffixes, directories, dotfiles, blank
  names, LIST/NLST/full LIST, header/suffix/window bank crossings, >255-byte
  and >16K names, scrolling limits, initial movement, key dispatch, attribute
  bank restoration and unchanged directory contents.
- Existing 46 regression runs: 705099 assertions pass, including directory
  position/roundtrip, FIND, extension parsing, help/CFG, screen/text download,
  upload and Wi-Fi protocol handling.
- TAP relocation/handoff: 1067 assertions pass with the new bank layout.

Physical paging, keyboard and drawing endpoints are modeled. Real screen
rendering and keyboard behavior still need an eLeMeNt test with this new TAP.
Suggested hardware checks: short TAP/TXT/AY/one-character suffix; long TXT with
X/Z and the final window; long `.jpeg` with whole-name scrolling; a directory
containing dots; return to normal navigation and ENTER/download afterward.

On the user's request, copied the new TAP to D:/zx/SARA_LOADER.tap and verified
SHA256 against the project copy:
4F8131768933A8FCCBEE155503189789310B763B50E11377B226DDAF7FC4D966 (28162 bytes).
The previous FTP TAP was backed up to TEMP as
SARA_LOADER-before-aligned-extensions-20261101-205421.tap.
Hardware testing planned by the user for 2026-11-02. No commit or push yet.
