# Upload baud experiment and checkpoint, 2026-10-31

The 20ms post-prompt guard did not resolve the hardware stall. Session63
downloaded the guard TAP, then STOR GAUNT3.TAP/150 at14:14:22 Prague time.
User reported progress213530. Capture125050 ends at13:14:38.444UTC:
70 complete2048-byte payloads=143360 bytes. Server partial141312 bytes has
the same SHA256 as the outgoing prefix. No next AT command or upload226.
The user then explicitly requested lower baud and a local checkpoint commit.

Changed only the default ud_speed byte, index16 ->12, so startup negotiates
AT+UART_CUR=1152000,8,1,0,0 and verifies the host/modem at the new speed.
Data transmission remains7MHz; prompt and ACK reception remain20MHz.
Thus a20MHz indicator while stalled is expected in the ACK-wait phase.
The20ms post-prompt guard and cancellable pause policy remain enabled.
No new code/data space:5989 bytes free before reservedBFE0, bank6 B8E.
Both DOS builds use the new default; BS-DOS remains the hardware priority.

Both builds:0 errors/0 warnings, HGFX off.44 regressions705008 assertions
pass; startup test exercises negotiation from3456000 to1152000 followed by
an AT verification. Comparison with the guard build finds exactly one changed
main-image byte at8E61 (16->12), with bank6 identical. Hardware validation of
this baud is pending. SNA and Z80 launch were confirmed by the user earlier;
TAP delete/run/stay controls are still pending. Upload remains under diagnosis.

The local FileZilla server also rejects STOU with500 command unrecognized.
This explains N/New abort on this server; it is separate from the mid-upload
stall. Old sessions61/56 were kicked by the user; avoid attributing file locks
to the fresh baud experiment.

Local FTP D:/zx/SARA_LOADER.tap updated and SHA256 verified:
A72E2D0FA35D53530D6FBE40ACE9F3A2B7A4276BA20767B1885F1403CA78EBC4.
Backup of previous FTP loader:
C:/Users/milan/AppData/Local/Temp/SARA_LOADER-before-baud-test-20261031-131806.tap.
COM6 capture125050 stopped at581849 bytes. New read-only capture is1152000
8N1, session81387, directory temp/sara-uart-20261031-131813, limit1800s.
The loader/EL traffic may initially use the old baud; upload capture is valid
after the new Sarah finishes its speed negotiation. No modem bytes are sent
by the capture script.
