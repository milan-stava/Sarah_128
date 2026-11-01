# Hardware result: no-delay test failed; final block differs

Session67 STOR GAUNT3.TAP22:05:56 Prague/150. COM205104 has61 complete
2048-byte DATA requests (124928 payload bytes), then CIPSEND0,6 (ABOR
request) and CIPCLOSE5; no ABOR payload was observed. User reports43.
The displayed43 can be a subsequent close/recovery error; the original
upload AT event is unknown. User has already left that memory state.

Server partial is124928 bytes. Crucially, this is the first comparison here
showing a content difference: first mismatch at zero-based offset123229
(block61, byte349),1624 differing bytes in the compared prefix.
The current outgoing124928-byte payload exactly matches the same prefix
of the earlier successful344602-byte capture. The server differs from both.
This excludes a wrong outgoing file prefix in this capture; it does not
identify where between the observed serial TX stream and server storage the
corruption occurred. No ABOR/CIPCLOSE/UART_CUR command text was found inside
the server file, so do not claim those commands were consumed as payload.

User is taking a break, will return and can provide NMI data on a further
attempt. Suggested next comparison is restoring the verified20ms guard at
2304000/7MHz, then two complete uploads and file hashes. No further source
or FTP change has been made after this failed no-delay test.
If a failure recurs in this exact no-delay build, diagnostics are
upload_last_event64E4, ftp_last_error7F27, RX_buf8E82, plusPC/SP.
Re-read symbols for any newer build. User will also compare old upload speed.

Previous preparation retained below.
# Isolated post-prompt delay test, 2026-10-31

The14MHz test stalled at its first block: session66 STOR22:01:59 Prague,
150, one2048-byte outgoing payload, no later AT command; server file0 bytes
at observation. A lit20MHz indicator is consistent with the ACK-wait clock,
not evidence that DATA was transmitted at20MHz.

User explicitly requested returning to2304000/7MHz and removing the20ms
post-prompt delay. Restored the three upload clock calls to set_7mhz,
removed the unused4-byte set_14mhz entry and the8-byte delay loop. Baud
remains index15; prompt/ACK20MHz and UI3.5MHz are unchanged. No protocol,
payload-size, cancellation or recovery changes. HGFX stays off.

Both normal builds0 errors/0 warnings.44 regressions704378 assertions pass,
plus1067 TAP handoff assertions. The delay-specific assertions were removed;
the actual payload/clock/backpressure, long-wait and completion tests remain.
BIOS A653/endA873,5997 bytes free beforeBFE0. Bank6 B8E=2958 bytes.
This is12 bytes smaller than the14MHz test,8 smaller than the verified7MHz
version with delay. Hardware results for this no-delay variant are pending.

FTP SARA_LOADER.tap updated, SHA256 verified:
D9D8602382793CC4DFCF4A03440A46C68B9DBD31CC5111F0CE980852CA024D6A.
Previous14MHz FTP copy saved in:
C:/Users/milan/AppData/Local/Temp/SARA_LOADER-before-2304000-7mhz-no-delay-20261031-210412.tap.
Known working2304000/7MHz WITH20ms delay remains preserved in
C:/Users/milan/AppData/Local/Temp/SARA_LOADER-before-2304000-14mhz-20261031-210034.tap,
SHA2565C0F15B0A42F1EDFCBF204E4D314DF7500B080E234DB59D48475C46BE238DD5C.
COM6 session80955 verified running at2304000 after the FTP copy.
