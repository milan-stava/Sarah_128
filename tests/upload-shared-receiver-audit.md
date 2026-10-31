# Upload receiver and error-state follow-up, 2026-10-31

Observed in session 52 after successful interrupted-session recovery:
STOR GAUNT3.TAP at 11:35:07, 150, then 36 data blocks = 73728 bytes.
UART ends in another CIPSEND=0,6 before an ABOR payload. User reports error16,
intermittent waiting, then48. Later outgoing commands include CIPRECVMODE=0,
CIPSEND=0,8 and CIPCLOSE=5. No server-side upload226 is present.
Original SEND OK failure remains unproven without incoming UART data.

NMI flags D8/00 confirm that connection bit5 and directory-valid bit0 were
cleared. This explains disabled arrows over an old screen image; it is not
evidence that execution jumped into random memory. PC was not supplied.
The loader in D:/zx matched the workspace build at the time of this test.

Changes prepared for the next hardware test:
- Upload now selects the shared AT/active-FTP receiver (legacy mode0).
- Prompt and SEND OK waits run at20MHz; binary send_data remains at7MHz.
  AF and saved length/address survive clock changes. Normal UI returns3.5MHz.
- SEND OK wait recognizes complete AT events, preserves queued FTP replies,
  and reports explicit ERROR/SEND FAIL/busy or transport timeout. Missing
  confirmation goes through bounded communication recovery, not a guessed
  successful transfer.
- Normal completion closes channel1 through its AT terminal, then reads the
  actual FTP226. ABOR follow-up replies also use the shared active reader.
- Unconfirmed ABOR16 and close failure43 use the existing one-attempt recovery.
- Invalidating a session clears the old directory window, refreshes offline
  host/login markers and draws the local title, without PWD.
- upload_last_event retains0 if its wait did not return, otherwise the AT event
  (4=SEND OK,2=ERROR,5=SEND FAIL,6=busy). ftp_last_error retains the first fatal
  code across cleanup, for possible NMI diagnosis. Neither is new user UI.

Separately requested editor change: EDIT (CS+1, code7) replaces SS+Q(code199)
as clear-whole-field. BREAK cancellation is unchanged. sara.hlp updated;
other menus retain their existing EDIT handling. Code size delta for key swap0.

Validation: both normal assemblers0 errors/0 warnings, HGFX off. Regression
suite passes. Upload wait tests:1911 BSDOS/183 ESXDOS assertions, including
32768/307201-byte transfers, split ACKs, speed/clobbered-register checks,
and FTP226 before/after close OK. Recovery149 checks/build. Input436 and
FIND1386 checks/build. Related FTP, directory, download/screen, TXT, CFG/help,
profile and snapshot regressions pass. Hardware timing and complete uploads
remain unconfirmed; these simulations do not establish the original cause.

Size relative to the previously hardware-tested recovery build:
BSDOS bios_start A769 -> A794, +43 bytes below C000.
BIOS end A9B4; free space before reserved BFE0:5676 bytes (was5719).
Bank6 remains B8B=2955 bytes. ESXDOS delta also+43.
SARA_LOADER.tap remains27730 bytes because its fixed-RAM CODE block is padded.
Compare hashes rather than tape length when identifying the new build.
