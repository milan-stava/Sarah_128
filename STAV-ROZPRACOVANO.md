# Zakonzervovany stav — 22. 10. 2026

Tento commit je pracovni checkpoint. **Upload neni funkcni a neni pripraven k vydani.**
Na zadost uzivatele je prace nyni zastavena; dalsi zmeny az po domluve.

## Overeno uzivatelem na stroji (BSDOS)

- Navraty z vice urovni adresaru s obnovenim pozice.
- Automaticke nacteni adresare po uspesnem loginu.
- Obnoveni vypisu po Q a novem spusteni pres RANDOMIZE USR.
- Download a navrat na vypis bez pruhu a zatuhnuti.

Prvni 16KB banka adresare se pri Q kontroluje 16bitovym souctem; pri startu se
pri neshode vyzada novy vypis. Nekontroluje dalsi banky ani aktualnost serveru.

## Nefunkcni upload — posledni konkretni pozorovani

Po navratu puvodni komunikace prvni upload souboru kolem 66 KB selhal.
Server prijal 12 288 B (sest bloku po 2 048 B). Hlaseni o prenosu zmizelo a
Sara zustala cekat pri naslednem pokusu o ABOR. Toto neni potvrzeni, ze selhal
prenos sesteho bloku; puvodni duvod vstupu do ful_abort se nezachoval.

NMI adresy plati pro BSDOS binarni sestaveni v tomto checkpointu:

- PC #9EEA: cteni UARTu ve Wi-Fi BIOSu, BC #133B, HL #8C15 (RX_buf).
- Zasobnik od SP: #011C, #0080, #77F8, #9D82, #0080, #8C15, #87C3,
  #7C9C, #01AA, #63D8, #642B, #1000.
- #9D82: puvodni cekani upl_old_check_module_answer.
- #87C3: ocekavany text OK/CR/LF/>/mezera.
- #7C9C: navrat do cipsend_request.
- #01AA = 426; #63D8: navrat ze send_abort do ful_abort.
- #642B: navrat z ftp_upl_send. Ulozena delka bloku uz na zasobniku nebyla;
  odpovida selhani odesilani (5) nebo cekani na SEND OK (8), nikoli vetvi 6.
- Stara cekaci rutina opakuje prazdny prijem bez celkoveho timeoutu.

Drive jiny pokus: prvni upload uspesny, druhy pod 16 KB selhal s chybou 48.
Drive se objevily take chyby 8, 16, 38 a opakovana 39. Ochrana proti rekurzi
chyboveho uklidu a navrat na 3,5 MHz jsou pridane; neresily pricinu uploadu.

## Domluveny dalsi krok

Vratit opravdu puvodni funkcni upload, bez dalsich experimentu a diagnostiky.
Ponechat jen nutne prizpusobeni Sare 128:

- datova banka 4, buffer #C000, velikost bufferu 16 KB;
- upload pri 7 MHz, po skonceni/chybe navrat na 3,5 MHz;
- spravny navrat obrazovky a refresh adresare po uspesnem uploadu;
- neporusit funkcni adresare, download ani historii navratu.

Puvodni referencni zdroj (pouze cteny, nezmeneny):

    D:\zx_original\1zx\projekty\wifi a veci okolo\Sarah-ftp client.ftp\12AI HGFX release_ jako_12 RELEASE, pridavam HGFX 64x24 znaku_verze oprimalozivana od AI co do delky\source\sarah_ftp_client.asm

WifiBios20_MB_EL.cod je v referenci i zde binarne shodny. Aktivni BSDOS diskove
rutiny se od reference lisily jen presunem adresy nacitani na ftp_dir_start.
send_data a send_string zustaly funkcne shodne. Momentalne ftp_upload_legacy.asm
a upload_legacy_mode prepinaji sdilene cekani/prijem na starou cestu behem
uploadu; toto reseni na stroji neproslo. Docasna diagnostika byla odstranena.

Pred kazdou dalsi upravou nejprve vysvetlit navrh uzivateli a domluvit postup.

## Sestaveni a meze overeni

- Aktualni BSDOS: SARAH12BSD.tap, surovy obraz SARAH12BSDhgfx, symboly
  directory-test.sym a listing sarah_ftp_client_bsd1.lst.
- Aktualni obsah programu byl zkopirovan do D:\zx\SARAH12BSD.bin.
  Pri dalsich domluvenych kompilacich kopirovat surovy obraz, nikoli TAP.
- BSDOS se naposledy sestavil bez chyb a varovani. Volno do #BFE0: 8 118 B.
- Posledni automaticke kontroly: 1 247. Sit, disk, kresleni a nektere BIOS/bankove
  cesty jsou simulovane; tyto testy neprokazuji funkcnost uploadu na stroji.
- ESXDOS je na pokyn uzivatele odlozeny, neni pripraven pro Saru 128.
  Jeho pritomne TAP/symboly jsou starsi mezivysledky, ne aktualni overeny build.

## Dalsi znama zavada a pozdejsi prace

Nekdy se adresar nenacte cely. Neni povazovano za vyresene.
Po stabilizaci uploadu je domluvena kontrola komunikace s Wi-Fi: AT odpovedi,
fragmentace, timeouty, +IPD, CLOSED a dokoncovani prenosu (vcetne 226 a zbytku
dat v modulu). Nyni tuto rozsahlejsi praci nezacinat.
