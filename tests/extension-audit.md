# Routine 89a: get_extension

Added after routine 89 without modifying get_item_name or its callers.
Input: a valid name in HL, its 16-bit byte count in BC, and its directory
page-table pointer in item_name_page, as returned by get_item_name.
Names are bounded by BC; a zero terminator is not required.

| A | Extension |
| ---: | --- |
| 0 | .TAP |
| 1 | .Z80 |
| 2 | .SNA |
| 3 | .TZX |
| 4 | .SCR |
| 5 | .TRD |
| 6 | .SCL |
| 7 | .TXT |
| 8 | .POK |
| 9 | .AY |
| 10 | other, missing, empty or unsupported extension |

ASCII case-insensitive matching uses the existing convert routine. Only an
exact final extension is classified: x.tapx is other, x.tar.TAP is TAP,
x..AY is AY, and x.tap. is other. Unsupported lengths (e.g. .a/.gz/.jpeg)
return 10. Leading-dot names such as .AY classify by the same suffix rule.
This is syntax classification only; callers must check routine 89's A before
calling it if they need to exclude directories, synthetic '..', or bad/full
LIST entries. NLST does not establish whether a matching name is a file.

BC, DE, HL, IX/IY and alternate registers are preserved. Original PAGE128_STATE
and fdp_pointer are saved and restored independently, even when the initially
mapped bank differs from the name bank. AF is modified; no flags contract.
The routine reuses DIR128_MAP_DE/DIR128_INC_HL and adds no work buffer. The
prefix is traversed to position within the final four bytes, respecting bank
boundaries; only a final .xxx or .ay candidate is compared with the table.

Exact size: get_extension_code_len=135 bytes of code, plus 30 bytes of fixed
three-byte table slots (AY is zero-padded), get_extension_len=165 bytes total.
This is also the total fixed-memory increase versus c2d9dbc. bios_start now
#A501, bios_len 544 bytes, free space before #BFE0 6,335 bytes. Bank 6 stays
1,066 bytes. The full SARA_LOADER.tap stays 25,841 bytes because SARA1 spans
the fixed 24,576-byte window.

Validation: BSDOS, HGFX and ESXDOS builds have no errors/warnings. Assembled
regressions run 408 name/layout cases and 2,474 checks in each variant. They
cover all mappings, upper/lower/mixed case, unsupported/empty suffixes,
multiple dots, control/non-ASCII bytes, every suffix byte around bank edges,
long 16-bit names, a name ending at the final #FFFF, size/pointer restoration,
bank data preservation and actual get_item_name results for LIST/NLST.
Existing BSDOS regressions plus this suite total 15,906 checks. CPU execution
is real assembled code; physical page switching is modeled using 8 RAM banks.
No user-facing caller was added; emulator/hardware integration is still pending.

Reproduce after building BSDOS:

    node tests/extension.test.js

Node is unavailable here, so the same function was executed in the JavaScript
tool runtime using each assembled image and its symbols.
