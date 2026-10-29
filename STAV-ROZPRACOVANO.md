# Predtestovy checkpoint Wi-Fi — 22. 10. 2026

## Aktualni navaznost — 29. 10. 2026: spousteni TAP

## ZAVERECNY CHECKPOINT PRED SPANIM — navazat zde

Dodatecne uzivatel pozadal o lokalni checkpoint commit a push na origin,
vetev fix-ftp-directory. Pred commitovanim znovu sestaveny BSDOS i ESXDOS
vcetne projektovych TAP/bin/symbolu/listingu: oba 0 chyb, 0 varovani.
Projektova SARA_LOADER.tap tedy jiz obsahuje posledni ulozene zmeny.
Nize uvedeny pokyn k novemu prekladu pred testem zustava vhodny pri dalsich
upravach; tvrzeni o starych projektovych binarkach je timto prekonane.
Checkpoint zahrnuje rozpracovane spousteni TAP a snapshotu, test v emulatoru
a na stroji je nadale odlozen na rano. Dokonceni commitu/pushe viz historie
Gitu a posledni zprava chatu, nikoli starsi zminky 'NEcommitovano' nize.

Uzivatel odklada emulatorovy/hardwarovy test na rano. Nasledujici krok:
1. Precist tento checkpoint a overit aktualni zmeny, neprepisovat praci uzivatele.
2. Pred testem aktualizovat projektove binarky pres assembly.bat: posledni
   kontroly noveho snapshot kodu sestavovaly pouze do TEMP. Projektova TAP
   tedy nemusi obsahovat posledni snapshot upravy.
3. Testovat SARA_LOADER.tap (hlavni kod + banka 6), nikoli stary jediny blok.
4. Overit ENTER na TAP: stahnout jedinou polozku pod kurzorem, rozbalit,
   opustit Saru a spustit program. Aktualne puvodni TAP NEMAZEME:
   flag2 db 0, bit 5 neni nastavovan. Mazani je implementovane, menu zatim ne.
5. Overit ENTER na Z80/SNA: download, predani do konkretniho NMI menu.
   Pri nepodporovanem menu text/klavesa/uklid a navrat do Sary s puvodni
   RAM bankou. NMI adresy jsou dodane uzivatelem, skutecny beh neoveren.
6. Po vysledcich testu vyresit chyby a pripravit commit; dosud NEcommitovano.

Posledni ulozeny stav: obe varianty BSDOS/ESXDOS se kontrolne prekladaji
bez chyb/varovani. Text nmi_not_found_txt je v bance 6; slb CALL pts a pak
JP snap_not_found pod #C000; tam port23=#40, POP AF, CALL PAGE128, XOR A, RET.
Spolecny enter_tap/enter_snap uklada puvodni PAGE128_STATE pres PUSH AF.
Dispatch CP 3 / JP C bere TAP=0,Z80=1,SNA=2. Banka 6 ma aktualne #0843=2115 B.
Hlavni kod s BIOSem konci #A785: volno do #BFE0 je #185B=6235 B,
do #C000 #187B=6267 B, poslednich 32 B rezervovano pro strankovaci rutinu.
Automaticke kontroly TAP pred snapshot zmenami: handoff 1063, pripony 2474,
download return 26. Snapshot vetve zatim pouze kontrola zdroje a preklad.
Nove low-level Wi-Fi stale vyzaduje realne overeni, upload zustava odlozen.

Tento soubor uchovava pracovni domluvu a dalsi kroky, NIKOLI uplny prepis
chatu. Ukladani/obnoveni historie konverzace ridi aplikace; Codex je nezarucuje.
AGENTS.md uklada pri dalsim zahajeni tento checkpoint precist.
Nize jsou prubezne a historicke zaznamy; prednost ma tento zaverecny stav.

Nejnovejsi SNAP kontrola: nmi_not_found_txt je nyni v bance 6, pred cfg_file_here.
Slb CALL pts tiskne/ceka/uklidi pri stale pripojene bance 6, pak JP
snap_not_found v hlavnim kodu. Ten obnovi port23=#40, POP AF puvodni banky,
CALL PAGE128, XOR A, RET. Umisteni textu i vyvazeni zasobniku sedi.
BSDOS a ESXDOS kontrolni preklady do TEMP: oba 0 chyb, 0 varovani.
ASM ani projektove binarky pri kontrole nemenene. Skutecny NMI vstup
a ROM zavislosti pri cekani s port23=#63 zustavaji neoverene behom.
Predchozi tvrzeni, ze port23 musi byt obnoven pred cekanim, bylo odvolano:
nutnost neni dolozena; soucasny kod jej obnovi az po pts pred navratem.

Novejsi kontrola SNAP: uzivatel opravil rozliseni na CP 3 / JP C,enter_tap
a presunul snap_not_found pod #C000. PUSH/POP AF i navrat banky nyni sedi.
Zbyva presunout OUT (23),#40 pred CALL pts (nyni je az po tisku/cekani)
a definovat nmi_not_found_txt. Kontrolni BSDOS preklad: 1 chyba prave na
chybejicim textu; ESXDOS 0 chyb/varovani. ASM pri teto kontrole nemeneno,
vystupy pouze TEMP. Dvoji tisk uz odstranen; slb pouze pripravi HL/DE a JP.

POSLEDNI KONTROLA SNAP: uzivatel doplnil work_snap (NMI menu pres port 23,
#63, kontrola #26D2 na #B536, fnum -> #5AA0, SP=#57E2, JP #11DD).
Vstup enter_tap/enter_snap je spolecny, po downloadu uklada PAGE128_STATE
pres PUSH AF, prepina banku 6 a rozlisuje item_extension. Toto ulozeni sedi.
Aktualni BSDOS kontrolni preklad do TEMP: 4 chyby (tri JR z enter_directory
na enter_tap/enter_snap mimo rozsah +137/+133/+129, chybi nmi_not_found_txt).
ESXDOS kontrolni preklad bez chyb/varovani. Projektove binarky neprepsany.
Navrat slb je chybny: vola PRINTHL a pak pts (druhy tisk se zmenenymi registry),
a po call PAGE128 pokracuje XOR/RET stale v odpojene bance 6.
Navrh v chatu: slb obnovi port23=#40, pripravi HL/DE a JP snap_not_found
v hlavnim kodu pod #C000; ten CALL pts, POP AF, CALL PAGE128, XOR A, RET.
Rozliseni typu lze zkratit na CP 3 / JP C,enter_tap (kody 0/1/2).
NMI adresy/ABI je nutno overit proti konkretni verzi NMI menu; komentar
1.64 nesouhlasi se signaturou textu "65". ASM pri kontrole nemeneno.

NOVY POZADAVEK: pridat ENTER spousteni snapshotu SNA a Z80. Rozpoznani
pripon (A=1 Z80, A=2 SNA) a download pod kurzorem jsou k dispozici.
V projektu ani prohledanych okolnich zdrojich nebyl nalezen BS-DOS loader
techto formatu. TAPmaster zpracovava TAP, neni to loader SNA/Z80.
Uzivateli polozena otazka na existujici loader nebo BS-DOS prikaz, ktery
pouziva. Cekame na odpoved pred zapojenim; zadna snapshot ASM vetev zatim
nepridana. Nezaměnovat start rozbaleneho BASICu pres NEW s podporou snapshotu.

AKTUALNI OPRAVA: nizsi hlaseni o nefunkcni relokaci je jiz historicke.
Na zadost uzivatele opravene DISP/ENT: blok loaderu #5B00 je oddelen od
bloku #4000 a fyzicka pozice banky 6 se obnovuje pres ENT, bez ORG.
Tapmaster ma 975 B, banka 6 2055 B; stpb=#5B00, rstpe=#5B6A.
Work_tap kopiruje pri DI; az START na #4000 pres PAGE128 pripoji RAM 0.
Bit 5 mazani se zachyti pred zmenou banky a IX. Bit 6 je stale pouze rezerva.
Buffer seq_buff=#C400, seq_buf_len=#3800 ma predni i zadni rezervu na
sektorove zaokrouhleni (puvodni #C000/#4000 mohlo pretekat nebo sahat pod banku).
Inicializace mazani obrazovky ma urcene cele BC=#1300.
Chybny XOR checksum nyni po hlaseni konci RST 0: zadne mazani/spusteni.
BS-DOS predani v enter_directory/enter_tap ohranicene IFDEF bs_dos.
BSDOS i ESXDOS sestaveni aktualizovana: 0 chyb, 0 varovani, symboly/listingy
a projektove vystupy obnoveny; SARA_LOADER.tap obsahuje i celou banku 6.
Nova tests/tap_handoff.test.js: 1063 kontrol baleni, realneho kopirovani,
predani na #4000, zachyceni volby mazani, prepnuti banky az po kopii,
predani loaderu na #5B00 a mezi sektorovych cteni. ROM/disk/paging simulovany.
Regrese 89a: 408 pripadu/2474 kontrol; download_return: 26 kontrol.
Node neni v PATH; JS testy vykonany dostupnym V8 runtime s timtez CPU modelem
a nacitenymi skutecnymi sestavenymi daty. Test handoff lze spustit take Node
s cestou k build slozce obsahujici bsd.sym a SARA_LOADER.tap.
STALE NEOVERENO: skutecne BS-DOS diskove operace, Wi-Fi prenos a start hry
pres ROM v emulatoru/na stroji. Dalsi krok je tento integracni test.

Kontrola cele cesty po uprave mazani: NYNI NEPOUZIVAT VYSLEDNY BUILD.
Kontrolni preklady do TEMP (projektove binarky neprepsany): BSDOS 0 chyb,
2 varovani, ESXDOS 1 chyba (work_tap neni pod IFDEF bs_dos).
Symboly BSDOS: tapmaster_start=#C437, tapmaster_len=#8800 (chybna delka!),
program_page_end=#4C37 a program_page_len=-#73C9, nikoli nula.
Podminka program_page_len>0 proto vynecha baleni banky 6.
Work_tap by kopiroval #8800 B na #4000 a prepsal i hlavni kod a fnum.
Vnoreny DISP #5B00 assembler ignoruje: stpb=#431D, SLAVE=#4380,
nret=#4351, rstpe=#4387, ackoli se loader kopiruje na #5B00.
Nejprve opravit oddelene relokacni bloky #4000 a #5B00 a obnovu fyzicke
pozice banky 6; pak znovu preklad a overeni velikosti/kopirovani/loaderu.
Kontrola neprovedla nove upravy ASM. Beh na emulatoru/hardwaru neoveren.

Posledni uprava Codexem: TAPmaster START zachyti flag2 bit 5 do del_tap+1
pred dalsimi volanimi a zmenami IX. del_tap nyni pri nule preskoci mazani,
pri #20 maze input_file. Odstranen stary test bitu 1 a neurceneho A.
V hlavnim ASM zdokumentovany bity 5 (mazani) a 6 (rezervovany navrat).
Kontrolni BSDOS preklad sjasmplus 1.20.3 s vystupy do TEMP: 0 chyb, 2 varovani:
vnoreny DISP v tapmaster.asm a preteceni ORG v 2nd_program_bank.asm.
Sestaveni hlasi program_page_len=0 a nevytvori uplnou dvoubankovou TAP.
Pred testem opravit relokaci DISP/ENT/ORG. Funkcnost mazani na stroji ani
emulatoru neoverena; checksum chyba nadale jen hlasi a pokracuje.
Projektove binarni vystupy nebyly timto kontrolnim prekladem prepsany.

Uzivatel implementuje ASM sam, Codex kontroluje a navrhuje kod v chatu.
Aktualne uz je zapojeno get_extension a item_extension na IX+41,
ftp_download_file_under_cursor a enter_tap s predanim do work_tap v bance 6.
Novy tapmaster.asm se kopiruje na #4000; vstupni cislo bere z fnum.
Zatim se implementuje natvrdo rozbaleni a spusteni, menu prijde pozdeji.
Kontrola zdroje nasla volne sousedni bity flag2 (IX+3): 5 a 6
(take 7 je volny). Navrh: bit 5=1 smazat puvodni TAP po uspesnem rozbaleni,
bit 6=1 zustat v Sare, 0 spustit rozbaleny program. Zatim pouze navrh,
ASM deklarace ani TAPmaster nebyly Codexem upraveny. Stary test bitu 1
v TAPmasteru koliduje s dokumentovanym AP CUR/DEF a musi byt nahrazen.
Setrvani v Sare zatim neni funkcni: TAPmaster meni SP a prepise banku 6;
navrat bude vyzadovat dalsi upravy. Posledni zmeny nebyly prelozeny/testovany.
Nize starsi domluva, aktualni stav vyse ma prednost.

Uzivatel chce pokracovat implementaci spousteni TAP souboru. Potvrzeny postup:
ENTER na polozce zjisti priponu; TAP se vzdy nejprve ulozi a rozbali.
Dve nezavisle volby musi byt trvale dostupne jako prepinace v menu:
spustit po rozbaleni ano/ne a smazat puvodni TAP po rozbaleni ano/ne.
Uzivatel vyslovne nechce dialog pri kazdem stazeni TAP. ENTER pouzije aktualni
nastaveni menu bez dalsiho dotazu. Konkretni klavesy, vychozi hodnoty,
trvale ulozeni nastaveni a mechanismus rozbaleni/spusteni zatim nejsou
potvrzeny. Dalsi krok: navrhnout zacleneni prepinacu do existujiciho menu
a proverit rozbaleni/predani BS-DOSu pred implementaci.
Nezaměnovat sara_tap.asm (baleni samotne Sary) za spousteni vybrane TAPky.

Dolozeny stav: 89a/get_extension je ve zdroji za 89), zatim bez volajicich.
ENTER obsluhuje enter_directory, ktere dosud rozlisuje adresare a obrazky
podle velikosti. Nova funkce spousteni TAP zatim nebyla pridana.
Existujici necommitnute zmeny vcetne 89a zachovat; v teto etape nebyl menen
assembler ani provaden novy preklad nebo test.

Domluva k navaznosti: Codex prubezne uklada stav a dalsi kroky sem; uzivatel
oznami zavreni VS Code, aby mohl vzniknout zaverecny checkpoint. AGENTS.md
uklada pri dalsim zahajeni tento stav precist. Historii chatu to nenahrazuje.

## Rutina 89a get_extension

Pridana samostatna rutina za 89), bez zmeny puvodniho get_item_name nebo
jeho volajicich. Vstup HL=platny nazev, BC=16bitova delka, item_name_page=banka
(vystup 89). A vraci TAP=0, Z80=1, SNA=2, TZX=3, SCR=4, TRD=5, SCL=6,
TXT=7, POK=8, AY=9, ostatni/chybejici/prazdna pripona=10. ASCII case insensitive.
Zachovava BC/DE/HL, IX/IY, alternativni registry, mapovani banky i fdp_pointer.
Jde pouze o priponu nazvu; typ soubor/adresar musi volajici vyhodnotit z 89).

Proti c2d9dbc +165 B v hlavnim kodu: kod 135 B, tabulka 30 B, bez noveho
pracovniho bufferu. bios_start #A501, volno pred #BFE0 6335 B. Banka 6 stale
1066 B, SARA_LOADER.tap stale 25841 B. Symboly get_extension_code_len a
get_extension_len vyjadruji presnou velikost kodu a celeho bloku.

BSDOS/HGFX/ESXDOS preklady bez chyb/varovani; nova sada 408 pripadu a 2474
kontrol pro kazdou variantu, vcetne skutecneho volani puvodniho 89), vsech
hranic bank, jmen nad 255 B a az 65530 B, chybejicich a ruzne dlouhych pripon,
obnovy libovolne puvodni banky a ochrany dat. Hlavni BSDOS regrese celkem 15906
kontrol. Rutina zatim neni zapojena do uzivatelske funkce. Bez noveho commitu.
Podrobnosti viz tests/extension-audit.md. Nize je stav pred jejim pridanim.

## Aktualni oprava INPUT: soubeh dvou klaves nerusi editaci

Proti a6958e3 +14 B v hlavnim kodu, bios_start #A45C. Volno pred #BFE0
6500 B. Banka 6 stale 1066 B, SARA_LOADER.tap stale 25841 B. Celkem INPUT
proti 4603dbd +157 B. KEYSCAN, INKEY, opakovani klaves ani prodlevy beze zmen.

INKEY vraci kod 1 jak pro BREAK, tak pro dve bezne soucasne stisknute klavesy.
Nova interpretace kodu 1 jako zruseni INPUT v a6958e3 proto zpusobovala
vypadnuti z editoru pri rychlem psani, bez ulozeni. INPUT nyni pri kodu 1
overi skutecne stisknuty SPACE (#7FFE, bit 0) i CAPS SHIFT (#FEFE, bit 0).
Pri jinem soubehu pokracuje v cekani na klavesu a zachova obsah i kurzor.

Preklady BSDOS/HGFX/ESXDOS bez chyb a varovani. Vsech 13432 hlavnich BSDOS
kontrol proslo; INPUT sam 429 BSDOS, 417 HGFX, 429 ESXDOS. Testy vykonavaji
i skutecny INKEY s matici klaves (A+S, Q+W, BREAK, SPACE+A, CS+A a SS+Q),
overuji ignorovani soubehu a pokracovani editace/potvrzeni uzivatele i hesla.
Vypnuti nove fyzicke kontroly zamerne zpusobi selhani regresniho testu.
Uzivatel 28. 10. 2026 potvrdil opravu v emulatoru. Realny hardware a Wi-Fi/FTP
nadale cekaji na overeni. Nize je stav pred touto opravou.

## INPUT v a6958e3: predvyplneni hodnot a prazdne heslo

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
