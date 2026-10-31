# Upload prompt guard, 2026-10-31

User clarified: finish the upload investigation, keep baud unchanged; try
1152000 only if the next test fails. Then explicitly requested this test TAP
on the local FTP server.

Hardware state before this change: one upload completed on session61 with
226 at13:53:17 Prague time and LIST/PWD afterward. The next stopped at
progress279066 after36 blocks. Capture has73728 outgoing payload bytes;
server71680 bytes match that outgoing prefix. No subsequent close command.
NMI PC A72B is BIOS UART receive; stack words8500,9E03,0FFF,7F20,A174
match the byte reader and AT line parser. upload_last_event=0. RX starts
OK/NUL, followed by stale suffixes of SEND OK and Recv2048bytes. That proves
neither a completed final-block receive notice nor the physical cause.

Change: after a successful CIPSEND prompt, switch to the existing7MHz data
clock and execute5376 iterations of DEC BC / LD A,B / OR C / JR NZ.
Including LD BC this is139781 T-states, about20ms at7MHz. Then restore the
saved block length and send the original binary bytes. No interrupt or HALT
is used. This delay is a diagnostic precaution, not an ESP-AT requirement
or a proven cure. The normal-mode protocol already permits data after >;
the20ms passthrough packet interval is a different mechanism.

Baud remains index16 (3456000), DATA7MHz and ACK/prompt20MHz, chunk2048.
No payload replay, injected byte, new menu, reset or resume feature.
The existing cancellable wait during silence remains unchanged.

Validation: BSDOS and ESXDOS compile0 errors/0 warnings, HGFX off.
44 regressions705002 assertions pass, plus1067 TAP handoff assertions.
Upload tests count the actual delay iterations before every block, verify
clock and saved length/address preservation, payload integrity across banks,
long pauses, cancellation and early/late226. They simulate peripherals;
the effect on this real ESP remains for the next hardware test.

Fixed RAM +8 bytes versus the immediately preceding build:
bios_start A653->A65B; BIOS end A87B; free beforeBFE0=5989 bytes.
Bank6 unchanged B8E=2958 bytes. SARA_LOADER.tap remains27733 bytes.
Current diagnostic addresses: upload_last_event64EC, RX_buf8E8A.
The NMI above was from the previous build and uses its old addresses.

FTP copy D:/zx/SARA_LOADER.tap verified by SHA256:
8B1FE9AE294075464F87E16BBC0E338359D27DB64565181A120489B52B287055.
Previous FTP copy backed up to:
C:/Users/milan/AppData/Local/Temp/SARA_LOADER-before-prompt-guard-20261031-131129.tap.
