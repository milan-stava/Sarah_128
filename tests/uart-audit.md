# Kontrola UART uploadu

Pozorovani uzivatele: baud 3456000, FPGA core 20260617. Pri 3,5 MHz upload
funguje; pri 20 MHz varianta s prodlevou selhala uz na zacatku chybou 8.
Samotne zpomaleni proudu TX tedy zatim neni potvrzenym resenim.
Verze U2 pred resetem ukazuje na radcich 22/23 cislo chyby, TX, RX a ESP.
Pred tiskem sama obnovi IX a zapne bit 4 ve flag1. Puvodni diagnostika tento
predpoklad nesplnovala a volala PRINTHL pred zapnutim tisku v display_error.
U2 ma vlastni cekani na klavesu bez akey, aby se druha radka neprepisovala.
Pri startu uploadu je viditelny marker [U2]; chybi-li, bezi jina sestava.
TX pocita pouze uspesne zapisy BIOSu; RX bajty skutecne vybrane z UART.
Pocitadla se nuluji pred CIPSEND a znovu pred daty po vyzve >.
Posledni radek odpovedi je pro zobrazeni omezen na 48 tisknutelnych znaku.

Kontrolovaný soubor: `WifiBios20_MB_EL.cod`, 544 bajtů. Níže jsou offsety
v souboru, nikoli runtime adresy relokovaného BIOSu.

## Odesílání jednoho bajtu

Tělo služby na offsetu `0xED`:

```asm
push bc
push de
ld e,a
ld bc,#133B
in a,(c)
jr nc,write_byte    ; vstupní NC vypíná kontrolu připravenosti!
rra
rra                ; původní bit 1 stavového registru -> Carry
jr c,return_byte   ; busy: žádný zápis
write_byte:
out (c),e          ; TX je #133B, nikoli RX port #143B
ld de,#02E6        ; LD nemění Carry, výsledek úspěšného zápisu je NC
return_byte:
ld a,e
pop de
pop bc
ret
```

IN A,(C) zachovává Carry. Upload správně nastavuje SCF před každým voláním.
Při busy znovu načte tentýž bajt z (HL); ukazatel a počet posune pouze při NC.
Příjem mezi pokusy zachovává AF/BC/DE/HL. Čekání na trvalé busy má konečný limit.
Blokový vysílač BIOSu na offsetu 0x142 rovněž testuje masku 2 před zápisem;
upload jej nyní nepoužívá.

## Co tento audit potvrzuje a co ne

Software kontrolu busy neobchází. Bit 1 je stav, podle kterého se řídí
dodaný BIOS; přesné elektrické časování a okamžik jeho změny v konkrétním
FPGA core tím ověřeny nejsou. Nelze z toho prohlásit UART při 20 MHz za bezchybný.

RX FIFO může vyrovnat zpoždění CPU při čtení. Pokud TX nemá FIFO, musí CPU
čekat na volný vysílač před každým bajtem; právě k tomu slouží uvedený test.
Absence TX FIFO sama o sobě nevyžaduje CPU 3,5 MHz, pokud busy funguje správně.
Připravenost místního TX současně nepotvrzuje volné místo v přijímači ESP.
Případnou ztrátu bajtu během CIPSEND může následovat čekání ESP na chybějící
data a čekání aplikace na SEND OK. Je to hypotéza, nikoli zjištěná příčina.

Testy nyní prověřují skutečné instrukce BIOSu pro všech 256 hodnot statusu,
busy po každém bajtu i trvalé busy po sedmi bajtech. Kontrolují také správné
adresy I/O portů a zakazují zápis při signalizovaném busy. Model počítá kroky
instrukcí, nikoli elektrické časování, a nespouští instalaci/relokaci BIOSu.

Integrační test navíc spouští ftp_upl_send včetně skutečného sestavení příkazu
CIPSEND a převodu délky pro bloky 1, 255, 256 a 2048 bajtů. Test chybového
dialogu spouští i skutečný BIT/RET příznaku tisku v PRINTHL. Až za touto branou
nahrazuje grafické vykreslení sběrem textu; klávesnice je simulovaná.
Prověřuje zobrazení při původně vypnutém tisku a zachování obou řádků
až do potvrzení klávesou. Neověřuje elektrické chování HGFX ani UART.

Pro rozlišení UART/ESP je potřeba znát baud, verzi FPGA a výsledek poslední
varianty s prodlevou. Definitivní kontrola vyžaduje implementaci UART daného
core nebo měření: porovnat zápisy CPU, stav bitu 1 a skutečný proud TX do ESP
při stejné baudové rychlosti na 3,5 a 20 MHz. Shodné bajty na vodiči přesunou
podezření za místní UART; rozdíl mezi zápisy CPU a vodičem ukáže na TX cestu.

Externí kontext: autor staršího MB03+ ovladače popisuje absenci flow control
v tehdejší konfiguraci: https://github.com/nihirash/moon-rabbit-zx . Není to
specifikace aktuálního FPGA uživatele. Definice ostatních bitů z dokumentace
ZX Next se nesmí automaticky přenášet na MB03+ jen kvůli stejným číslům portů.
