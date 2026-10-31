# Stale FTP session recovery, 2026-10-30

User confirmed startup error 36 after restarting over an unfinished upload,
followed by repeated error 4. Server session 50 persisted across restart:
NOOP/200, TYPE A/200, PASV/227, no LIST. Subsequent recovery loop repeatedly
sent NOOP and USER with no PASS. The available UART capture has outgoing bytes
only; the exact ESP rejection behind 36 remains unknown.

Authorized behavior: Sarah should disconnect the frozen session itself and
log in again. This change implements one automatic recovery attempt:

- CIPSTATUS records channel 1 separately. If a data socket survives into
  get_status_ftp, close/reconnect occurs before NOOP, TYPE or PASV on that old
  session. A data socket without channel 0 is also handled.
- Errors 4/36/48/49 enter the same recovery. Other errors retain ordinary
  cleanup. Successful ordinary cleanup now returns to the keyboard instead
  of entering the automatic login loop again.
- Recovery invalidates connection/cache state, discards old buffered replies
  with bounded reads, closes all sockets, resets parser state and receive
  mode, then calls the existing stored-profile auto-login path.
- An ERROR from CIPCLOSE is accepted only after CIPSTATUS verifies that both
  managed sockets are already absent. Busy and failed verification stop.
- A guard spans cleanup, reconnect, USER/PASS and fresh directory retrieval.
  A second error ends the attempt, displays one final error and returns to
  the keyboard. Incorrect stored credentials cannot enter the manual login
  dialog loop during this automatic retry.
- No interrupted upload or original operation is replayed. Healthy control-only
  sessions and normal manual login keep their existing behavior.

Fixed-RAM implementation: ftp_recovery.asm, status parser additions in
wifi_protocol.asm, and call/guard changes in sarah_ftp_client.asm.
Tests: node tests/ftp_recovery.test.js [esx]. 121 assertions per build cover
communication errors, stale sockets, healthy reuse, queued old FTP replies,
already-closed sockets, busy/error/timeout cleanup, username/password rejection,
silent server, retained configuration, fresh history, and unknown baud.
They execute assembled recovery, status parsing and auto-login control flow;
network, connection establishment and FTP replies are modeled.

All related regressions pass (including upload waits, directory roundtrip,
Wi-Fi, download/screen, TXT/FIND, BSDOS CFG/help/profile and snapshot checks).
Both normal builds compile without errors/warnings; HGFX stays off.
Hardware confirmation of stale-session startup and the modified upload remains
pending. COM6 capture stays OFF as explicitly requested by the user.

Size versus the preceding upload-wait build:
BS-DOS bios_start #A681 -> #A769: +232 bytes below #C000.
BIOS ends #A989; free space to reserved #BFE0 is 5719 bytes.
Bank 6 remains #B8B bytes; ESXDOS fixed-RAM delta is also +232 bytes.
Loaders rebuilt; no new commit/push.

Hardware follow-up, 2026-10-31: user confirmed successful restart after NMI
interruption of upload. Capture shows CIPCLOSE=5, active receive reset, fresh
connection/login to the configured default server, LIST and PWD. Local server
records old interrupted session disconnect at 11:32:03. A subsequent local
login at 11:32:43 succeeds with 230, LIST/226 and PWD/257. Complete upload
remains unverified; this confirms the specific interrupted-session restart.
