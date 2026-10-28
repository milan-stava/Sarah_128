# Prefilled INPUT and empty passwords

Compared with commit 4603dbd, the BSDOS fixed-memory code grows by 143 bytes:
bios_start moves from #A3BF to #A44E; bios_len stays 544 bytes. There are
6,514 bytes free before #BFE0. Program bank 6 stays 1,066 bytes and its CFG
capacity stays 15,317 bytes. SARA_LOADER.tap stays 25,841 bytes because its
SARA1 block always spans #6000..#BFFF (24,576 bytes).

The common INPUT_VALUE editor accepts a zero-terminated initial value in DE.
input_line remains an empty-entry wrapper; input_line_edit uses 63 columns,
and input_line_edit_limit takes the field limit in C. IX and the initial DE
are restored by the wrapper. Sources may alias INPBUFF for rename. Text is
copied before the remaining buffer is padded, and the cursor starts at its end.
SS+Q enters the empty initializer rather than restoring the initial value.
BREAK (CAPS SHIFT+SPACE, code 1) and the legacy code 4 (CAPS SHIFT+3) cancel;
standard EDIT (CAPS SHIFT+1, code 7) does not exit INPUT. ENTER confirms the whole trimmed value
regardless of cursor position. The existing insert/backspace/delete paths and
full line renderer remain in use. There are 63 text columns plus the cursor.

The common mask OR operand is applied both to initial and newly typed password
characters. INPUT strips these display bits before return. The source password
stays untouched until confirmation; password entry always restores the plain
mask afterward. input_password distinguishes cancellation from confirmed empty
input, while other entries retain the existing empty-means-no-change behavior.

Fields prefill host, username, password, default filename, and decimal start
address. FTP parameter entry chooses current USER/PASS, the default filename
for SIZE/download, the already copied current name for RNTO, or empty for MKD.
Upload filename entry uses the default filename with the local disk limit;
upload transfer code was not changed. New arbitrary FTP commands and FIND
remain empty because neither has a persistent current value.

Limits match the CFG parser (Host 45, User/Pass 31, File 56, Start 5), with
10/12 characters for BSDOS/ESXDOS local upload names and 63 for generic input.
Input shifts stop at the fixed zero at INPBUFF+63. Length scans are bounded
and return zero for an empty buffer. A full field refuses an insertion even
when the cursor is in its middle. Local filename copies after SIZE also respect
the smaller disk-name buffer.

Manual and automatic empty PASS are built without LDIR with BC=0. Automatic
USER/PASS prepare the buffer independently, including its terminator, so a
short or empty password cannot inherit the previous username or buffer tail.

Validation: BSDOS, HGFX and ESXDOS builds have no errors/warnings. All TAP block
checksums checked. The assembled INPUT regressions pass 341 checks for BSDOS,
329 for HGFX, and 341 for ESXDOS. BSDOS plus existing regressions totals 13,344
checks. Tests cover prefilling, cursor placement, middle insert/delete,
full-field handling, SS+Q, limits and buffer guards, masks, blank confirmation,
both cancel keys, setters, numeric round trips, per-command parameter defaults,
empty PASS framing, and actual manual/automatic login control flow. Two ZX
cases execute the actual CHAR renderer as well. Keyboard, key wait, network
and higher-level field display calls are substituted; HGFX VRAM is not modeled.
The user confirmed that the new input behavior works in the emulator on
2026-10-28. Validation on real hardware is still required, including Wi-Fi/FTP
and empty-password login; automated checks do not validate physical timing.

Run after the BSDOS build:

    node tests/input_editor.test.js

Node is unavailable here; the same regression function was executed in the
JavaScript tool runtime with the assembled images for all three variants.
