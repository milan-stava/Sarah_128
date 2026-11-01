# BS-DOS TAP options, 2026-11-01

- SS+T (`>` from the unchanged INKEY table) toggles flag2/IX+3 bit 5:
  zero keeps the original TAP, one deletes it after extraction.
- CS+T (`T`) toggles bit 6: zero runs the extracted program, one stays in
  Sarah. The menu displays Run=Y for zero and Run=N for one.
- Plain T (`t`) still opens the start-address editor.
- User-selected BS-DOS default is flag2=#20: Delete=Y, Run=Y.
  ESXDOS keeps flag2=0. V saves flags with the application.
- Both flags are independent. Extraction is always performed first.
- This feature is BS-DOS only; ESXDOS's TAP is byte-for-byte unchanged
  relative to the immediately preceding aligned-extension build.

Menu and keyboard handling live in bank 6. The normal main keyboard call
uses a fixed-RAM paging wrapper, retaining `key_loop+3` for existing dispatch.
The idle second row from the bottom is `TAP: SS+T Delete=Y  CS+T Run=Y`.
Its two input/status rows are cleared before an action and before restoring
the idle menu, so prompts/progress never share residual text with the options.
Idle polling does not repeatedly repaint or clear. No new shortcuts are
inserted into the editor, viewer, CFG browser, or confirmation dialogs.

After successful extraction and optional original-TAP deletion, bit 6 is
checked before inspecting the launchable file or entering the BASIC loader.
The stay path restores normal ROM mapping/IX/3.5 MHz, rebuilds Sarah's root
stack/error return and repaints the screen. Directory bank 0 was used by
TAPmaster, so its cache flag is invalidated BEFORE the repaint/retrieval.
The saved item ordinal and cursor row are supplied to the normal retrieval
restoration. The old nested download/TAP stack is discarded.
Existing fatal TAPmaster errors retain their previous behavior; this change
does not introduce a new recovery path for disk errors or malformed TAPs.

Size relative to the aligned-extension build:

- Fixed RAM below #C000: +50 bytes; 6106 bytes free before #BFE0.
- Bank 6: +145 bytes; now 3532 bytes (#0DCC), 12852 bytes free.
- Total code/state increase: 195 bytes. TAPmaster itself: 985 bytes.
- BS-DOS SARA_LOADER.tap: 28307 bytes. HGFX remains off.

Both DOS builds compile with zero errors and warnings. Executed 50 assembled
Z80 regression runs: 747391 assertions passed, plus 1071 TAP relocation/handoff
assertions. Tests include all flag combinations, unrelated-bit preservation,
menu labels, key consumption/plain T, idle behavior, original-bank restoration,
deletion target, launch versus stay, return stack/cache/reload ordering and
pre-extraction cursor snapshot. Physical paging, disk, keyboard, ROM services
and drawing endpoints are modeled; real extraction/return still needs testing.

The test interpreter gained RST #20 and XOR (IX+d) for the actual instructions.
Dispatcher tests were adjusted to observe the outer keyboard call rather than
mistaking the new paging wrapper's internal call depth for an unbalanced stack.

Local FTP TAP updated with matching project/FTP SHA256:
C436E16753E51218446F70DCE55DB2865549865DCA64FBEE228AF1D13883CA37.
After the default change, both builds passed, the 277-assertion TAP options
regression passed, and only one main-code byte and one bank-6 byte changed.
The ESXDOS binaries are unchanged. No size increase from changing the default.
Previous TAP: TEMP/SARA_LOADER-before-tap-options-20261101-211016.tap.
Updated sara.hlp also copied to local FTP. No new commit or push.

Hardware test: all four Delete/Run combinations; confirm extracted files stay,
only the original TAP is optionally deleted, Run=N returns to the same FTP
directory/cursor, and navigation/download work afterward. Test new aligned
extension display too. Planned by the user for 2026-11-02.
