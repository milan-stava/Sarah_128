# Upload confirmation waits, 2026-10-30

Hardware evidence before this change:
- GAUNT3.TAP upload session 50 stopped after 139 x 2048 = 284672 bytes.
- Captured outgoing payload SHA256 matches the server's partial file exactly.
- Last outgoing command was AT+CIPSEND=0,6, without subsequent ABOR payload.
- NMI PC #79C5 and stack #A17E, #0080, #8F12, #8ABF, #7E80 identify
  receive_data_timeout inside upl_old_check_module_answer while waiting for
  the ABOR send prompt. Repeated empty reads had no overall bound.
- Available capture contains outgoing commands/data but no ESP responses;
  user cannot change the capture direction. The original hardware trigger
  for abort is not conclusively established.

The upload SEND OK loop cleared RX_buf on each short read and searched each
fragment separately. A confirmation split across reads could therefore be
lost, triggering abort despite delivery of its payload. Tests reproduced
this failure in the previous binary with an 1800-poll gap inside SEND OK.

Changes:
- Upload SEND OK uses existing bounded look_on_fly byte matching.
- Upload handshake uses the same matcher; prompt requests accept > without
  requiring an OK prefix or a trailing space. Generic OK/CONNECT callers
  still match their requested text.
- Successful handshake no longer drains subsequent UART bytes.
- Empty/partial/ERROR/busy responses eventually fail instead of restarting
  an unbounded empty-read loop. No command is automatically replayed.
- Disk loading, bank-4 data buffer, chunk sizes, FTP/IPD reply handling and
  the normal completion/abort flow retain their existing implementations.

tests/upload_wait.test.js: 515 BS-DOS checks, 152 ESXDOS checks. Coverage:
all split positions in SEND OK and prompt, delays exceeding the old read
budget, bare prompt, preservation of following bytes, bounded empty/partial/
negative responses, existing OK/CONNECT callers, and BS-DOS 32768/307201-byte
upload loops through CIPCLOSE/226 and directory refresh. Long-upload tests
simulate disk reads, outgoing bytes and the BIOS byte endpoint; standalone
wait tests execute real BIOS byte reads. They do not prove real UART timing.
Run after assembly: node tests/upload_wait.test.js [esx].

Existing upload-response, Wi-Fi, directory roundtrip/position/protocol,
downloads, screen, TXT, FIND, CFG/profile/help and snapshot regressions pass.
Both normal builds have zero errors/warnings; HGFX remains off.

Size against the prior screen-fixed build:
BS-DOS bios_start #A6B8 -> #A681, saving 55 bytes below #C000.
BIOS ends #A8A1; 5951 bytes remain before reserved #BFE0.
Bank 6 remains #B8B bytes. ESXDOS saves the same 55 fixed-RAM bytes.
The new SARA_LOADER.tap requires another real GAUNT3.TAP upload test.
