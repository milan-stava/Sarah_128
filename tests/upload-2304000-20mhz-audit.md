# Follow-up: isolate2304000 baud with7MHz DATA

The20MHz experiment stopped on its first block: session65 STOR/150 at
21:52:46 Prague time, capture205104 has one2048-byte payload and no later
AT command; server file was0 bytes when checked. This does not distinguish
the physical cause. User approved the proposed2304000/7MHz comparison.

Restored7MHz setup/DATA/post-ACK and5376 guard iterations (~20ms).
Prompts/ACK still run20MHz; UART stays2304000. Both builds compile cleanly.
44 regressions705046 assertions pass. No size growth:5989 bytes free.
Compared against the committed1152000/7MHz build, the entire main image
differs at exactly one byte:8E61,12->15. Bank6 is identical. Thus the next
hardware comparison changes only baud from the known working baseline.

Updated FTP SARA_LOADER.tap SHA256:
5C0F15B0A42F1EDFCBF204E4D314DF7500B080E234DB59D48475C46BE238DD5C.
Previous20MHz FTP copy saved to:
C:/Users/milan/AppData/Local/Temp/SARA_LOADER-before-2304000-7mhz-20261031-205506.tap.
COM6 session80955 remains running2304000, verified after the FTP copy.
Hardware verification is pending; no new commit/push for this experiment.

Previous experiment retained below.
# Next upload experiment: 2304000 baud and 20MHz, 2026-10-31

The user confirmed that uploads pass at1152000 baud with7MHz DATA. That
working checkpoint is committed locally as2589400, including the requested
notes: upload still under investigation, SNA/Z80 confirmed, TAP switches TODO.
No push was requested or performed.

New explicitly requested experiment:
- ud_speed index15 selects2304000 baud.
- Upload setup, binary DATA and prompt/ACK phases now select20MHz CPU.
- Post-prompt guard changed from5376 to15384 iterations, retaining about20ms:
  26*15384+5=399989 T-states, nominally19.99945ms at20MHz.
- UI/recovery still restores3.5MHz. Chunk sizes, protocol, cancellation and
  receive policy remain unchanged. HGFX remains disabled.

Both normal builds:0 errors/0 warnings.44 regressions705046 assertions pass,
plus1067 TAP handoff assertions. Tests check startup negotiation at2304000,
20MHz DATA, guard duration/count, full multi-bank uploads and exact payload
with actual BIOS byte sends under simulated UART backpressure. A stuck UART
must report an incomplete block, never success. These are not physical timing
or wireless tests. The user will test two real uploads next.

No code-size growth: BIOS startA65B/endA87B;5989 bytes free beforeBFE0.
Bank6 B8E=2958 bytes, loader27733 bytes. The new experiment is not committed;
2589400 retains the1152000/7MHz baseline.

Local FTP D:/zx/SARA_LOADER.tap updated and SHA256 verified:
D09FAF553AEC2BFCFC94E3103E52BAC41EA63AF57C5BA729908C253907D04B94.
Previous FTP loader backed up to:
C:/Users/milan/AppData/Local/Temp/SARA_LOADER-before-2304000-20mhz-20261031-205102.tap.
COM6 capture131813 ended1053109 bytes. New receive-only2304000/8N1 capture:
session80955, temp/sara-uart-20261031-205104,1800s from20:51:04UTC.
