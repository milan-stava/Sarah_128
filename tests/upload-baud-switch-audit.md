Timing clarification: user calls the38-second GAUNT3 tests downloads, but
the subsequently read session70 log shows STOR17:45:11->22617:45:50 (39s)
and STOR17:46:46->22617:47:23 (37s), matching the reported approximate times.
These are uploads to FTP, not a verified RETR/download benchmark. Do not
claim a measured baud effect for downloads from these entries. Per-test
baud/version is not independently captured. Source behavior remains unchanged.
# General3456000, upload2304000, 2026-11-01

User requested normal operation at3456000 baud, temporarily lowering only
upload. Restored the20ms post-prompt guard and7MHz DATA first, then added
ftp_upload_baud.asm. Ordinary startup preference is index16; upload selects15.
The configured preference is not overwritten by an upload.

Save the last verified entry baud immediately before TYPE/PASV/STOR. The
existing baud negotiation changes ESP, changes host UART and verifies AT.
Actual get_baud/find_out_speed is used on each transition because a failed
partial change can leave the cached speed stale. Normal completion restores
the entry baud after226 and before refreshing the directory. Confirmed abort
does the same. Communication recovery closes the old sockets and returns to
active mode at the old baud, then restores before login. Ordinary successful
error cleanup also restores. Failed/unverified cleanup clears pending state
without sending further baud commands into a possibly busy/data-mode modem.
A successful restore consumes its saved byte first, preventing retry recursion.

Both normal builds0 errors/0 warnings, HGFX off.46 regressions705102 assertions
pass, plus1067 TAP handoff assertions. New baud tests cover actual command
order, restoration of the entry baud, no-op changes, explicit rejection,
stale cached speed, unknown alignment, completion, abort, recovery ordering
and failed cleanup. This feature still needs a hardware switching test.

Fixed RAM +78 bytes versus the2304000/7MHz guard baseline: BIOS A6A9/endA8C9,
free beforeBFE0=5911 bytes. Bank6 B8E=2958 unchanged. TAP27733 bytes.
FTP D:/zx/SARA_LOADER.tap updated and SHA256 verified:
03BE8B9A92D3FD7DD668D37BCB0207E479E76BCCB245FD2B7F7B58546A3180FF.
Previous FTP copy:
C:/Users/milan/AppData/Local/Temp/SARA_LOADER-before-upload-baud-switch-20261101-164652.tap.
No new commit/push. Serial capture must account for baud switching: the current
fixed2304000 capture default targets upload, not the general3456000 traffic.

Historical1152000 download timing: session64 records RETR SARA_LOADER.tap,
27733 bytes, with150 and226 within14:24:16 Prague time. That only times server
sending into the connection, not Sarah reading/saving it. The1152000 capture
131813 contains3 STORs and21 data-receive queries but no readable RETR, so it
does not provide a reliable complete download time for that request.

User subsequently measured GAUNT3.TAP download at38 seconds both at index12
(1152000) and15 (2304000). Keep this as user-reported download timing; do not
conflate it with earlier log-verified STOR/upload times. Equal timing suggests
no benefit from the higher baud in that specific test; it does not isolate
the exact bottleneck or establish identical behavior on other files/servers.
