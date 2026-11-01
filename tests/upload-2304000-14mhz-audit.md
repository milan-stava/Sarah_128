# Upload clock experiment:2304000 baud/14MHz, 2026-10-31

Known working fallback:2304000 baud/7MHz. User confirmed two consecutive
uploads. Server session66 records STOR21:56:30 ->226 at21:57:16 and
STOR21:57:41 ->226 at21:58:21 Prague time, each followed by LIST226/PWD257.
COM205104 segments starting13857 and362854 each contain169 DATA requests,
344602 payload bytes. SHA256 of each payload equals the server's344602-byte
GAUNT3.TAP. Thus full content and post-transfer directory commands are verified.
This is evidence for these two runs, not every wireless/error condition.

User requested changing only the DATA clock to14MHz. Baud remains2304000,
prompt/ACK20MHz and UI3.5MHz. Added set_14mhz with selector2 and changed
upload setup/DATA/post-ACK to it. Post-prompt loop doubled from5376 to10752
iterations so nominal guard duration stays about20ms (279557 T-states at14MHz).
Chunks, cancellation, recovery and protocol remain unchanged. HGFX is off.

Both builds compile0 errors/0 warnings.44 regressions705046 assertions pass,
plus1067 TAP handoff assertions. Actual radio/CPU timing still needs hardware
testing; next step is two uploads. If unsuccessful, return to verified7MHz.

New shared clock entry costs4 bytes: BIOS A65B->A65F, endA87F, free before
BFE0=5985 bytes. Bank6 remains B8E=2958; loader27733 bytes.
FTP D:/zx/SARA_LOADER.tap SHA256 verified:
403A43A6EBD5B6B05561F3B9B3996E266C8B9B2EC21E955B5C2608A3495E5A80.
Verified7MHz fallback preserved in:
C:/Users/milan/AppData/Local/Temp/SARA_LOADER-before-2304000-14mhz-20261031-210034.tap
with SHA2565C0F15B0A42F1EDFCBF204E4D314DF7500B080E234DB59D48475C46BE238DD5C.
COM6 session80955 verified running at2304000 after FTP copy.
No new commit/push;2589400 still holds the earlier1152000/7MHz checkpoint.
