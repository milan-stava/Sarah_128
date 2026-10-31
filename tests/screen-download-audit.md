# Screen download completion, 2026-10-30

User reports errors 49, then 21 and 4 after leaving a screen preview.
Read the actual local log:
C:\Program Files (x86)\FileZilla Server\Logs\FileZilla Server.log
Despite stale filesystem timestamps, its content includes today's session.
At 19:47:23 session 47 receives SIZE 2BRSHLP1.SCR / 213 6144,
RETR / 150 / 226 Transfer OK. The server then accepts PWD and NOOP.
This establishes successful server-side transfer and subsequent connectivity,
but does not show the ESP/UART framing which caused client error 49.

Source defect: download_screen stopped after the last payload and changed
receive mode without consuming the pending FTP completion. A pending 226 can
then arrive as active +IPD and interfere with subsequent AT/PWD handling.

download_screen_end now consumes and validates 226, closes data channel 1,
and disables passive receive before the image key wait. Printing is disabled
before reading 226, so completion messages cannot draw over the image.
The original UI/status and cached-directory return are preserved.

tests/screen_download.test.js executes assembled receive/completion code:
6144 and 6912 bytes, 733/2048-byte payload chunks, one-byte/full control
fragments and 226 already buffered after 150. AT terminals and close handling
are real; keyboard, payload delivery and the server are simulated.
222 assertions passed per DOS variant. The previous binary fails the test
at the requirement to finish transfer before the key wait. Directory roundtrip,
position/protocol, download completion/return, extension, guards, text viewer
and FIND regressions also pass. Real-machine confirmation remains pending.

Both normal builds pass without errors/warnings; HGFX stays disabled.
Fixed RAM cost +15 bytes: BS-DOS bios_start #A6A9 -> #A6B8,
BIOS ends #A8D8, 5896 bytes free before reserved #BFE0. Bank 6 unchanged.
The untested ordinal-indicator draft was removed from sources and outputs;
that feature is paused while the user investigates prior counter behavior.
