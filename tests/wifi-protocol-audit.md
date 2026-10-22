# Wi-Fi protocol changes, 2026-10-22

Baseline: `5c865b3`. BSDOS only. Upload body and legacy upload parser remain
unchanged; a passing upload regression does not establish hardware upload works.

The new `wifi_protocol.asm` separates complete AT lines, prompts and length-framed
binary payload. It recognises exact OK/ERROR/SEND OK/SEND FAIL and busy s/r/p
messages. Busy returns failure without replaying the command. A control IPD that
arrives before SEND OK is retained in the existing 128-byte control buffer.
Overflow, unsupported active data-channel payload during an AT wait, malformed
lengths and exhausted budgets fail explicitly instead of overwriting memory.

FTP replies now share an active/passive stream reader. It retains subsequent
replies and ends multiline replies only at the original numeric code plus space.
Long text is drained with bounded storage and a bounded per-line byte budget.
Active replies are copied back to RX_buf for existing PASV/PWD consumers.
No additional 128-byte buffer was allocated.

CIPSTATUS reads through its final OK instead of interpreting a timed snapshot.
Normal command/data paths no longer discard the UART queue to skip AT envelopes.
Download consumes the terminal after its exact payload. Directory completion
requires 226, an empty data channel and its CLOSED notification; a temporary empty
query alone cannot truncate the listing. Control fetches tolerate an empty reply
with a bounded retry. Error recovery no longer recursively attempts a second
cleanup from cr_err; after draining UART it resets partial stream state.

Byte-read polling scales with the current CPU speed, preserving the previous
3.5 MHz polling budget. This is an approximation, not a hardware timer or UART
flow-control model. The BIOS itself is unchanged. The existing firmware dialect
`+CIPRECVDATA,<length>:` is intentionally retained.

Run after BSDOS assembly:

```
node tests/wifi_protocol.test.js
node tests/wifi_initialization.test.js
node tests/directory_protocol.test.js
node tests/directory_position.test.js
node tests/upload_response.test.js
node tests/startup_resume.test.js
node tests/directory_checksum.test.js
node tests/download_return.test.js
node tests/download_protocol.test.js
```

Tests execute the assembled Z80 code with simulated UART input. They cover
fragmentation, early IPD, binary OK, busy/errors, decimal overflow, multiline FTP,
multiple replies in one IPD, bounded long text, socket notices, status framing,
speed scaling and existing navigation/resume/download regressions. Network,
disk and drawing hooks do not model FPGA timing, FIFO overrun or real ESP firmware.

Hardware verification still needed: repeated LIST including large/empty listings,
login, nested CWD/CDUP with PWD display, download and return, Q/BASIC restart,
disconnect/reconnect and recovery from delayed/busy replies.

## Initialization follow-up

The initialization audit now covers AT probing, automatic baud selection,
AT+UART_CUR, ATE0, CWMODE, CIPMUX and the FTP server greeting. Baud probes use
bounded nonfatal reads and exact OK lines; echo/boot lines are tolerated,
incomplete responses and binary IPD are rejected. Drain is bounded and belongs
only to baud discovery. Busy terminates initialization with error 50 instead of
being mistaken for a baud mismatch. ATE0 must succeed before alignment is marked
valid (error 51 otherwise). Failed initialization returns to BASIC without
issuing cleanup AT commands at an unknown baud rate.

Automatic selection no longer loops for MB firmware maxima 7/12. Configured
preferences are limited by the hardware maximum. Explicit baud changes validate
both the host maximum and the actual speed_table range 0..16 before changing the
module. A rejected set_baud is not probed as though it succeeded. A failure of
fallback scanning is no longer treated as a valid speed.

UART_CUR handles an OK on the old baud and a missing old-baud acknowledgment:
an explicit ERROR/busy aborts; otherwise the host switches and confirms with AT
on the new baud. If confirmation fails, initialization fails rather than claiming
success. The module might already have changed baud; discovery on the next run
is necessary. The timing of physical UART reconfiguration still needs real-hardware
verification. Syntax/OK responses were checked against the official documentation:
https://docs.espressif.com/projects/esp-at/en/release-v2.1.0.0_esp8266/AT_Command_Set/Basic_AT_Commands.html#at-uart-cur-current-uart-configuration-not-saved-in-flash

The FTP greeting uses the common framed reader, including an early buffered
greeting, multiline 220 and optional preliminary 120. Idle socket notifications
also use the common parser. This removes two raw timed snapshots and prevents a
greeting buffered before CIPSTART's OK from disappearing before login.

AP selection/join commands are commented out and prn_ap_name_sig is excluded by
IFUSED in the current build. No AP selection code was activated or expanded.
Older raw readers remain in the deliberately unchanged upload. Download cleanup
was subsequently converted as described below. ESXDOS remains deferred.

Validation: BSDOS assembly has no errors or warnings; 1,534 automated assertions
pass across eight suites. Added initialization assertions cover probe boundaries,
noise/partial responses, bounded retries/drain, busy, hardware/version limits,
baud acceptance/rejection, both acknowledgment cases, complete greetings, idle
notifications and failed-initialization cleanup. The upload cleanup regression
now explicitly starts in the initialized state; the uninitialized case is
covered separately. Initialization added 195 bytes. The approved subsequent
removal of the empty print_bauds RET and its two calls saves exactly 7 bytes.
All 1,534 assertions still pass. Total change from 5c865b3: +1,247 bytes.
Free space before #BFE0 after BIOS: 6,871 bytes. The direct CPU-speed switch
and the supported module speed range were left unchanged in this size cleanup.

## Download completion and abort follow-up

The successful download no longer discards the UART queue after its final FTP
reply. A short BIOS block read preserves BC (unread bytes), consumes exactly that
binary tail and its AT terminal, then starts cleanup. A payload containing OK
therefore cannot be mistaken for an AT result. A timeout while draining remains
an explicit bounded error instead of treating an incomplete frame as complete.

Download abort now stays passive and uses the common parser rather than entering
the upload's legacy receiver. ABOR is sent once; 225/226 completes it, while 426
requires a later completion. After the first final reply, NOOP is sent once and
the remaining transfer/abort replies are drained up to its 200 response (maximum
four logical replies total). This also handles a completed transfer's 226 followed
by a separate ABOR acknowledgment. The data socket is closed before passive mode
is disabled. A close ERROR is tolerated only after a length query confirms no
pending data; busy is not treated as an already closed socket. The existing
abort status/refresh/stack exit is reused; the upload body is unchanged.

Protocol reference: https://www.rfc-editor.org/rfc/rfc959 (ABOR, NOOP and replies).
No new application error codes: 16 covers invalid/incomplete abort reply sequences,
23 the short block report, 43 rejected data close, 48/49 timeout/framing failures.

Latest validation: 1,630 assertions across nine suites pass; BSDOS assembly has
no errors/warnings. This follow-up adds 160 bytes, for +1,407 bytes from 5c865b3;
6,711 bytes remain before #BFE0. The raw build was copied to
D:\zx\SARAH12BSD.bin. This is a pretest checkpoint, unverified on hardware.
Real tests should include B during a large download, B near completion, repeated
downloads and a fresh LIST/NOOP after abort, in addition to normal navigation.
Capture raw UART with timestamps in both directions when possible, alongside
the FileZilla Server command/reply log, to correlate failures across both links.
