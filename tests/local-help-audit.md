# Local help and profile confirmation

BS-DOS K opens the external ASCII file sara.hlp from the current disk,
using the same file/sector reader and free bank-6 workspace as CFG.
No extra help-length validation was added, at the user's explicit request;
the distributed file is assumed to fit that workspace. CFG validation is
unchanged. Missing help produces a message and a normal return.

The common text viewer reads help directly from bank 6 through a local
base pointer; it does not map the remote data banks or download anything.
FTP viewer entry resets the local base, preventing stale help mode when
subsequently opening TXT/POK/Z. Left/right/BREAK keep their usual behavior.
Local help restores layout and the cached directory without any FTP command,
even offline. The local help file is distributed beside sara.cfg, renamed
from the earlier SARA_HELP.TXT to the user-requested sara.hlp.

K dispatch and bank/return trampoline cost 30 bytes below #C000; all help
loading, messages, source selection and initial UI restoration live in bank 6.
The shared viewer's local-byte path and state add 22 bytes in bank 6 only.
The menu keeps all keys; P-pass/S-size/Q-end are shortened to fit K-Hlp.

G profile selection now returns a confirmation result from the bank-6 browser.
Only valid ENTER confirmation triggers auto_login (the exact SS+L action),
after restoring RAM mapping and the directory UI. BREAK, invalid ENTER and
missing CFG do not request login. The fixed trampoline preserves that result
across redraw, and consumes the key after login. This costs another 7 bytes
below #C000. Existing SS+L behavior, including any reconnection prompt when
already connected to another server, is retained.

Validation on assembled code with modeled ROM/disk/FTP endpoints:

- Local help: 45 checks, including real file/sector read calls, destination,
  actual length/content, missing file, offline entry, directory preservation,
  bank restoration and direct local-byte reads without any bank switches.
- CFG browser: 10217 checks; CFG exit/main loop: 164 checks. ENTER invokes
  SS+L exactly once with selected values; BREAK/missing do not.
- Other existing BS-DOS regressions: 5564 checks.
- Text viewer: 336684 checks in each BS-DOS/ESXDOS variant, including clearing
  the local-help source before the next FTP view.
- BS-DOS/ESXDOS builds: zero errors and warnings. HGFX remains disabled.

The user subsequently confirmed both K local-help loading/display and
G -> ENTER login working. This does not establish coverage of all physical
hardware or live-network edge cases.
Node entry points: tests/local_help.test.js, tests/cfg_profiles.test.js and
tests/cfg_exit.test.js. Here they ran with the same CPU model through V8,
because Node is not on PATH.
