# Follow-up: wait for the existing transfer, 2026-10-31

The four-window hardware build still failed: session56, 152 data blocks
(311296 outgoing bytes), 309248 bytes in the server file, matching SHA256
over that outgoing prefix. Last data12:21:27.801UTC; CIPCLOSE5 at12:23:40.789.
The user confirmed error48 and subsequently reported that a fresh Sarah start
could not discover the modem baud. Outgoing capture then shows CIPSTATUS
and AT probes, not a completed new login. Incoming replies remain unavailable.

User explicitly requested waiting and continuing as on a PC. New policy:
- While waiting for SEND OK after a fully submitted upload block, silence
  alone never expires the transfer. Read the existing reply, poll B, and do
  not send another AT command or repeat any payload during that pause.
- ERROR/SEND FAIL/busy and known CLOSED/WIFI DISCONNECT still return failure.
  B still performs the existing abort. This is not reconnect/resume support.
- File downloads likewise keep polling valid empty length responses until
  bytes reappear, a socket closes, or B is pressed. Final-close recheck remains.
- Ordinary AT command replies, including each length query, retain their
  bounded timeout. A silent modem is different from a valid empty response.
- Removed the four-times multiplier and the 2048-empty-query counter. No
  unconditional hardware reset was added: that would destroy the current TCP
  session. Actual modem lockup remains a distinct unresolved hardware concern.

Protocol reference (firmware version on this device is not yet established):
[Espressif ESP8266 CIPSEND documentation](https://docs.espressif.com/projects/esp-at/en/release-v2.2.0.0_esp8266/AT_Command_Set/TCP-IP_AT_Commands.html#at-cipsend-send-data-in-the-normal-transmission-mode-or-wi-fi-passthrough-mode).
The implementation keeps explicit acknowledgement/failure handling, rather than
assuming success after a delay.

Tests: 44 regression runs,704334 assertions,0 failures. New cases resume after
4096 empty queries and after2200000 UART polls (beyond the previous four-window
budget at the simulated base speed), including a full32768-byte upload that
continues from its next block and completes226 without replay. Partial/missing
ACK stays cancellable; an unanswered length query still times out48.
Both builds compile with0 errors/0 warnings, HGFX off.

Size versus immediately preceding hardware-tested build:
BSDOS bios_start A66B -> A653, another24 bytes saved belowC000.
BIOS ends A873, free beforeBFE0=5997 bytes. Bank6 unchanged B8E=2958 bytes.
Total saving versus the earlier A794 upload build is321 bytes.
ESXDOS also saves24 fixed-RAM bytes. New hardware test is still required.

The earlier four-window change and its evidence are retained below as history.
# Transfer pauses, 2026-10-31

Hardware baseline: local server session 53 accepted STOR GAUNT3.TAP/150.
The outgoing-only COM6 trace contains 63 complete 2048-byte payloads
(129024 bytes); the server partial file was 126976 bytes. These observations
do not establish lost bytes: server buffering and a pending send remain possible.
After the final payload, CIPCLOSE=5 appears about 33.28 seconds later.
User reported 229914 remaining and then error 48. No FTP 226 was recorded.
The user intentionally selected a weak connection. Incoming ESP replies are
not available in the capture, so the initiating fault is still unproven.

Changes:
- Only the upload SEND OK wait gets four times the ordinary UART idle budget.
  CPU-speed scaling remains; this is a polling budget, not a wall-clock timer.
  B is sampled during the wait with the existing raw INKEY routine.
- Explicit socket closure/Wi-Fi loss ends that wait rather than waiting out
  the larger budget. Normal ACK completion and errors reset the wait flag.
- File downloads retry empty CIPRECVLEN results with the existing poll delay,
  up to 2048 consecutive empty queries. Empty alone never means EOF.
  Known closure triggers a final length recheck so queued final data is drained.
  B returns a separate cancellation result to disk, screen and TXT callers.
  Directory listing retains its existing separate completion policy.
- Existing error recovery handles final timeouts. No payload or interrupted
  transfer is replayed automatically. The change does not implement FTP resume.
- Fixed both 32-bit remaining-length tests: equal nonzero high/low words
  (65537, 131074, etc.) are no longer mistaken for zero.
- Removed unused ftp_upload_legacy.asm, mode switches, old reply parser,
  look_for_ipd/look_on_fly adapters, decimal helper and their unused strings.

During dead-code removal an overly broad source range was caught by assembly
errors. The missing section was restored and its existing guards, FIND cache,
screen completion and recovery changes reinstated before rebuilding. Existing
regressions were rerun, and missing symbols against the previous good image
were reviewed: only the deliberately removed legacy symbols are absent.
No broken intermediate image was copied to the FTP loader location.

Validation: both normal builds have 0 errors/0 warnings, HGFX disabled.
44 regression runs pass, 704319 assertions, plus 1067 TAP handoff assertions.
These execute assembled Z80 with simulated I/O, not real Wi-Fi timing.
New pause tests cover late ACK beyond the ordinary budget, real B keyboard
matrix/register preservation, closure notices, cancellation cleanup in all
three file consumers, long empty queues followed by data, final queued bytes,
finite idle timeout and the 32-bit length boundaries. Long upload tests still
exercise 32768/307201 bytes and early/late FTP226 around close confirmation.
Screen test fixtures now explicitly return NC on successful availability,
matching the new cancellation contract.

Size versus the last hardware-tested loader (bios_start A794, bank6 B8B):
- BSDOS bios_start A66B, BIOS end A88B: saves 297 bytes below C000.
- Free before reserved BFE0: 5973 bytes, previously 5676.
- Bank6 B8E = 2958 bytes: +3 bytes for TXT cancellation.
- ESXDOS saves the same 297 fixed-RAM bytes; bank +3 as well.
- SARA_LOADER.tap is 27733 bytes; fixed-RAM TAP block is padded.

Next hardware test: short upload, full GAUNT3.TAP, second upload; verify
server 226, final file size/content and cached directory navigation. Repeat
under weak connectivity and test B cancellation. Also test a download pause.
Do not call the original intermittent upload failure conclusively solved yet.
