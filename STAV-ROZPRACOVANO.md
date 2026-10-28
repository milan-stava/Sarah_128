# Predtestovy checkpoint Wi-Fi — 22. 10. 2026

## Aktualni INPUT: predvyplneni hodnot a prazdne heslo

Proti commitu 4603dbd hlavni kod narostl o 143 B. bios_start #A44E,
bios_len 544 B, volno pred #BFE0 nyni 6514 B. Banka 6 stale 1066 B,
CFG limit 15317 B. TAP stale 25841 B (SARA1 ma pevnou velikost 24576 B).

Spolecny editor nabizi aktualni server, uzivatele, heslo, nazev souboru,
desetinnou pocatecni adresu a pri RNTO soucasny nazev polozky. Kurzor zacina
na konci, SS+Q skutecne vycisti radek. Novy adresar, vlastni FTP prikaz
a hledany vyraz nemaji ulozenou vychozi hodnotu a zacinaji prazdne.
Editor ma 63 textovych sloupcu a jeden pro kurzor, limity poli respektuji
CFG (host 45, user/pass 31, file 56, start 5; upload lokalni jmeno 10/12).
ENTER potvrzuje obsah nezavisle na poloze kurzoru. BREAK (CS+SPACE) rusi vstup;
zachovano je take stare ruseni kodem 4 (CS+3), nikoli standardni EDIT (CS+1).

Prazdne heslo potvrzene ENTER se ulozi/odesle jako prazdne; zruseni ponecha
puvodni hodnotu. Maskovani plati pro puvodni i nove znaky a po navratu se
vypne. Automaticky login pripravuje USER a PASS oddelene, vcetne prazdneho
hesla; nehrozi LDIR s BC=0 ani zbytek uzivatelskeho jmena za kratsim heslem.
Posuny jsou ohranicene uvnitr INPBUFF; plne pole pri vlozeni neztraci konec.

BSDOS, HGFX a ESXDOS prelozeny bez chyb/varovani. Nova sada input_editor
prosla: 341 kontrol BSDOS, 329 HGFX, 341 ESXDOS. Spolecne s predchozimi
regresemi 13344 kontrol hlavni BSDOS sestavy. Testy vykonavaji skutecny
editor, maskovani, editaci, mazani, settery, prevod adresy a sestaveni
USER/PASS vcetne celeho automatickeho/manualniho loginu se simulovanou siti.
Ve dvou ZX pripadech bezi i skutecny CHAR; HGFX VRAM a realne Wi-Fi casovani
se netestuji. Uzivatel 28. 10. 2026 potvrdil funkcnost noveho INPUT v emulatoru.
STALE JE POTREBA OVERENI NA REALNEM STROJI, vcetne Wi-Fi/FTP a prazdneho hesla.
Podrobnosti v tests/input-editor-audit.md.

Nize jsou historicke checkpointy pred upravou INPUT.

## Aktualni vyber profilu: posun po jednom radku

Sipky uvnitr okna meni pouze sdileny kurzor a hodnoty vybraneho profilu.
Na dolnim/hornim okraji se obraz posune o jeden textovy radek a vytiskne
se pouze novy nazev. Nadpis se kresli jednou pri vstupu, limit je 32 profilu.
Kopie obrazu respektuje prekryv v obou smerech (LDIR/LDDR); kurzor se pred
posunem odstrani. ZX i HGFX maji vlastni rozlozeni obrazu v bance 6.

Proti predchozi 962B verzi banka 6 +104 B, nyni 1066 B. Hlavni kod beze zmeny.
Proti commitu 19f060d celkem +660 B (banka +622, hlavni +38).
Volno do #BFE0 stale 6657 B, CFG nejvyse 15317 B, SARA_LOADER.tap 25841 B.
BSDOS, HGFX a ESXDOS preklad bez chyb/varovani. Proslo 13003 kontrol:
685 CFG, 10195 vyberu/bitmapoveho posunu, 144 navratu ENTER/BREAK a 1979 ostatnich.
Testy spousteji skutecnou kopii ZX obrazu, kontroluji vsech osm pixelovych
pruhu, pohyb obema smery, krajni polohy, zmenu smeru i absenci prekreslovani
nazvu uvnitr okna. HGFX zatim pouze prelozen, overit vzhled v emulatoru.
Nove low-level Wi-Fi rutiny stale cekaji na realny hardware; upload odlozen.

Kontrola hlaseneho padu po ENTER: v kodu navratu nebyla nalezena chyba.
Novy cfg_exit.test.js spousti skutecny tisk, obnovu dvoupolozkoveho adresare
a celou hlavni klavesovou smycku az po dalsi klavesnicovy dotaz, s prazdnym UART.
ENTER/BREAK overeny s adresarem i bez nej, po rolovani i bez pohybu, vratane
obnovy nastaveni, IX, vyvazeni volani, bank a hlidani pameti pod kodem.
Program/TAP beze zmeny (+0 B). Uzivatel pri opakovani pad nereprodukoval;
nasleduje overeni na realnem stroji, pricina puvodniho padu nepotvrzena.

Nize je historicky stav pred doplnenim posunu obrazu.

## Vyber profilu: sdileny kurzor a CALL G

Seznam ma nadpis Your profiles: a stejny kurzor pres cely radek jako adresar.
Vstup draw_cursor_row sdili skutecny vykreslovaci kod, preskakuje pouze
adresarove mapovani banky. Pri kresleni profilu zustava pripojena banka 6.
Nadpis a zvyrazneni se pri navratu uklizi; pozice adresare se nemeni.
G je obsluhovane CALL Z, navrat RET s A=0. Limit stale 32 profilu.

Banka 6 nyni 962 B, hlavni kod proti 19f060d +38 B: celkem +556 B.
Proti predchozi variante G je to celkem +31 B (banka +35, hlavni kod -4).
SARA_LOADER.tap 25 737 B, SARA2 962 B, CFG nejvyse 15 421 B.
Volno do #BFE0 6 657 B. Preklad bez chyb/varovani. Proslo 3 009 kontrol:
688 CFG, 342 profiloveho vyberu a 1 979 ostatnich regresnich kontrol.
Testy kontroluji i skutecny zapis celeho radku a zasobnik pri CALL klavesy G.
Ukazkovy soubor uzivatel prejmenoval ze sara.cfg.txt na sara.cfg; testy jej
ctou pod novym nazvem. Podrobnosti viz tests/cfg-profiles-audit.md.
Nove low-level Wi-Fi rutiny stale nejsou overene na realnem hardwaru.
Novy vyber a vzhled jeste overit v emulatoru, upload zustava nefunkcni.

Nize je historicky stav prvni varianty vyberu G pred sdilenym kurzorem.

## Vyber CFG profilu za chodu — klavesa G

Implementovan vyber prvnich 32 profilu podle Name=, po 8 na stranku.
G vzdy znovu nacte sara.cfg. Sipky meni hodnoty v kolonkach, Enter ponecha
vybrany profil, BREAK vrati nastaveni pred vstupem. Port je ve vyzve vyberu.
FTP spojeni se samotnym vyberem nemeni. Navrat obnovi cachovany adresar
vcetne puvodni pozice, bez PWD, noveho LISTu nebo zasahu do historie.

Kod je ve 2nd_program_bank.asm, banka 6. Zaloha vyuziva existujici INPBUFF,
neni pridana dalsi zalozni pamet ani tabulka vsech profilu. Opet pouzit CFG
parser a tiskove rutiny. Doplnena kontrola delky CFG pred nactenim tela
souboru a oprava tisku prazdneho maskovaneho hesla.

Proti 19f060d celkem +525 B: banka 6 z 444 na 927 B (+483), hlavni kod +42 B.
Volno do #BFE0 6 653 B. SARA_LOADER.tap 25 702 B; SARA1 24 576 B, SARA2 927 B.
Limit 32 i 64 zabira stejne; zvoleno 32 podle uzivatele. Proti prvni variante
vyberu se 16bitovymi indexy usetreno 9 B v bance 6 a dalsich 6 B v trampoline.
Preklad bez chyb/varovani, 688 CFG a 132 browser kontrol, drivejsi regrese 1979.
Podrobnosti a meze overeni viz tests/cfg-profiles-audit.md. Novy vizualni vyber
jeste vyzkouset v emulatoru. Nove low-level Wi-Fi rutiny nadale cekaji na realny
hardware; upload zustava odlozeny nefunkcni problem. Zatim bez noveho commitu.

Nize jsou historicke checkpointy pred pridanim vyberu G.

## Aktualni checkpoint CFG — 27. 10. 2026

BS-DOS verze umi nacist soubor sara.cfg a prevzit z nej vychozi profil
s Default=1. Zdroj druhe programove banky je 2nd_program_bank.asm;
banka je nyni fyzicky RAM 6 a pozdeji bude obsahovat i dalsi rutiny.
Uzivatel overil aktualni sestaveni v emulatoru a potvrdil funkcnost CFG.
Posledni BSDOS preklad: 0 chyb, 0 varovani. SARA_LOADER.tap obsahuje BASIC,
SARA1 (#6000, 24 576 B) a SARA2 (#C000 v bance 6, 444 B).
Uspora proti predchozi 525B verzi je 81 B.

Nove low-level komunikacni rutiny Wi-Fi (AT/FTP, cekani a prijem odpovedi)
STALE NEJSOU OVERENE NA REALNEM HARDWARU. Emulatorovy test CFG nenahrazuje
realny test Wi-Fi. Ten zustava naplanovan s UART zaznamem a logem FileZilly.
Upload zustava znamy nefunkcni/odlozeny problem.

Aktualni zkraceny CFG loader je rucni uprava uzivatele, pouziva load_init
a load_file+4. Predchozich 709 CFG kontrol overovalo drivejsi 525B loader;
testy loaderu vyzaduji prizpusobeni soucasne variante. Detaily a omezeni
viz tests/cfg-audit.md. Zmeny kodu pri tomto commitovani nebyly provadeny.

Nasledujici oddil popisuje historickou 525B variantu pred rucnim zkracenim.

## CFG v bance 6 — 27. 10. 2026

load_cfg a parser jsou opravene v 2nd_program_bank.asm. Start mapuje banku 6,
nacte sara.cfg, overi cely vybrany Default=1 profil a prevezme hodnoty,
pak vrati banku 0. Chybny/chybejici CFG ponecha nastaveni; IX/IY zustavaji
zachovane. Overena skutecna 32bitova delka tela, meze banky a navraty DOSu.
Pouzit kompletni SARA_LOADER.tap s BASICem, SARA1 a SARA2. Samotny stary
hlavni blok banku 6 neobsahuje. program_page_len je nyni 525 B, po optimalizaci
z 581 B (uspora 56 B). CFG muze mit nejvyse 15 858 B. Volno do #BFE0 6 695 B.
Ukazka sara.cfg.txt; 709 CFG kontrol proslo, take 1 979 dosavadnich regresnich kontrol.
Podrobnosti a meze overeni viz tests/cfg-audit.md.
BS-DOS sestaveni bez chyb/varovani, ESXDOS kontrolni preklad bez CFG take.
Realne nacteni z disku a strankovani zatim cekaji na test.

Nize je historicky mezistav pripravy TAP a Wi-Fi checkpointu.

## Priprava CFG a dvoublokove TAP — 25. 10. 2026

Realne testovani Wi-Fi je na pokyn uzivatele odlozene. Novy BASIC loader je
v sara_loader.asm / SARA_LOADER.tap a automaticky startuje na radku 10.
BSDOS sestaveni doplni do SARA_LOADER.tap za BASIC bloky SARA1 (#6000, #6000
bajtu, tedy #6000..#BFFF) a SARA2 (banka 6, #C000, program_page_len bajtu).
Zdroj baleni je sara_tap.asm. program_page_len je zatim EQU 0, protoze data
banky 6/CFG jeste nejsou definovana; pro tuto hodnotu se obnovi pouze BASIC
loader a assembler vypise, ze CODE bloky cekaji na skutecny obsah. Po doplneni
banky nastavit delku podle skutecneho konce dat. Uplna TAP vyzaduje 1..16384 B.
Puvodni BSDOS raw obraz i jednosouborova SARAH12BSD.tap zustavaji dostupne.
Baleni overeno testovacimi daty odlisnymi v bance 0 a 6, delky 4 a 16384 B,
hlavickami, kontrolnimi soucty a odmitnutim delky 0/16385. Spustitelny obraz
Sary se touto pripravou nezmenil. ESXDOS zustava odlozeny.

## Dosavadni stav oprav Wi-Fi

Aktualizace po checkpointu `5c865b3`: uzivatel povolil opravy sdileneho Wi-Fi
protokolu. Sdileny parser a nasledne opravy inicializace jsou implementovane;
podrobnosti a meze jsou v `tests/wifi-protocol-audit.md`. BSDOS sestaveni bez
chyb/varovani, 1 979 automatickych kontrol proslo. Proti checkpointu +1 398 B,
volno do #BFE0 6 720 B. Etapa inicializace pridala 195 B; nasledne odstraneni
dvou volani prazdneho print_bauds a jeho RET usetrilo 7 B. Dokonceni/preruseni
downloadu bylo prevedeno na spolecny parser (+160 B).
Tento predtestovy checkpoint uchovava zmeny pred overenim na skutecnem stroji.

Po checkpointu 22305ba uzivatel na stroji nacetl adresar, ale nasledovala chyba
39. Simulace celeho dr_end presne reprodukovala chybu pri UNLINK + ERROR:
parser vracel chybu uz na UNLINK a priradil zbyvajici ERROR prepnuti rezimu.
Oprava rozlisuje oznameni UNLINK od skutecneho terminalu a sdili kontrolovane
zavreni datoveho kanalu s abortem downloadu. Oprava usetrila 9 B a zatim neni
commitnuta ani overena na stroji. FTP log potvrzuje LIST/226; UART sled zatim
neni zachycen, proto skutecnou posloupnost odpovedi modulu jeste overit.
Upload zustava nefunkcni a jeho telo/legacy parser nebyly prepsany.
Nize je historicky zaznam checkpointu; puvodni pozastaveni Wi-Fi auditu uz
neplati. Inicializace rychlosti byla proverena a opravena; vyber/pripojeni AP
neni v tomto sestaveni aktivni. Download uz pri abortu nepouziva stary prijem
uploadu; ceka na kompletni ABOR a NOOP, pak zavre data a opusti pasivni rezim.
Zbyva overeni na stroji a odlozeny upload. Neni tvrzeno, ze je kompletni
komunikace overena na hardwaru.

Pri realnych testech zachytit surove UART bajty pokud mozno v obou smerech
vcetne casovych znacek a soucasne log FileZilla Serveru. Overit start/login,
LIST a vnorovani, download, B behem downloadu i tesne pred dokoncenim,
nasledny LIST/dalsi download a Q/RANDOMIZE USR.

## Historicky stav checkpointu 5c865b3

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
