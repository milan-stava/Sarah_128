# Oprava příjmu FTP adresáře D1

Větev `fix-ftp-directory`, základ `1ccdeb6` (doplněné komentáře).
Rozpracovaný upload je odložený ve stashi `Odlozeny upload pred opravou FTP adresare 2026-10-06`.
Testovací sestavení používá klasické zobrazení a v titulku má `SARAH 1.2 D1`.

## Nalezené chyby

- V `dr5_7`, `dr5_3`, `dr5_4` a při čtení LF nebyla ověřena připravenost UART.
  I prázdné čtení s příznakem Z tak posouvalo parser a snižovalo délku bloku.
- Úvodní řádek `total …` spotřebovával bajty bez odečítání z DE. Parser mohl
  následně interpretovat koncové AT `OK` jako část adresáře.
- `check_module_answer` posuzoval jednorázově načtený úsek jako celou odpověď
  a po shodě mazal další příchozí bajty. Rozdělená odpověď mohla selhat.
- `look_on_fly` vracel při timeoutu po částečné shodě chybně Z (úspěch).
- Po `CIPSTART` se čekalo jen na `CONNECT`, po `CIPCLOSE` se jen čistila fronta.
  Konečné potvrzení jednoho příkazu se mohlo zaměnit s odpovědí následujícího.
- Pasivní FTP odpovědi byly parsované z časově omezeného čtení 128 bajtů,
  bez respektování skutečné délky `CIPRECVDATA` a hranic FTP řádků.
- Opakovaně prázdný datový buffer byl považován za konec adresáře. To není
  totéž jako dokončený FTP přenos. Také po příjmu 226 mohou zbývat datové bajty.
- Aktivní řídicí odpověď se mohla rozdělit mezi více `+IPD` bloků; původní kód
  zpracoval jen první. Nebyl ani omezen zápis délkou RX bufferu.

Tyto chyby jsou doložené kódem a regresními testy. Bez testu na skutečném
eLeMeNtu nelze tvrdit, že vysvětlují všechny dosavadní výskyty chyb 36 a 39.
36 označuje nedohledané OK při příjmu FTP odpovědi, 39 selhání potvrzení
`AT+CIPRECVMODE`; obě mohou být následkem dřívější ztráty synchronizace.

## Oprava a omezení

Společné čtení čeká na skutečný bajt, zachovává registry parseru a má timeout.
AT odpovědi se dočítají až po terminátor. Pasivní řídicí stream uchovává
nevyužité bajty mezi odpověďmi 150/125 a 226, i při libovolném dělení TCP.
Při čekání na dokončení se kontrolují **oba** kanály, aby čekání na 226
neblokovalo odčerpávání nových dat. Aktivní řídicí odpověď se skládá do
ukončeného řádku přes hranice +IPD.

Kódy 48/49: 48 = timeout čtení nebo čekání na odpověď; 49 = neplatná či
neočekávaná odpověď/rámování. Aktivní odpověď delší než 127 bajtů nyní skončí
49 místo přepsání paměti. Dlouhé pasivní odpovědi se celé spotřebují,
zobrazuje se nejvýše 127 bajtů řádku. Nejde o kompletní implementaci všech
variant víceřádkových FTP odpovědí.

Podklad k pasivnímu režimu: [dokumentace Espressif pro ESP8266](https://docs.espressif.com/projects/esp-at/en/release-v2.1.0.0_esp8266/AT_Command_Set/TCP-IP_AT_Commands.html).
Firmware řady 1.7 používá stávající syntaxi `+CIPRECVDATA,<délka>:`;
automatické rozpoznávání jiných syntaxí firmware nebylo přidáno.

## Velikost

Srovnání BSDOS, stejná klasická grafika, stejný font a assembler:

| Obsah před pevným stránkovacím kódem | Bajtů |
|---|---:|
| Základ 1ccdeb6 | 15 454 |
| Oprava D1 | 15 865 |
| Rozdíl včetně bufferů a označení D1 | **+411** |

Zbývá 8 679 bajtů do `#BFE0`. Sestavení kontroluje překrytí pomocí ASSERT.
TX buffer se znovu využívá pro řádek pasivní FTP odpovědi; samostatných
128 bajtů je potřeba jen pro dosud nespotřebovaná data řídicího streamu.
Celkový obraz má stále 24 568 bajtů kvůli pevné adrese stránkovacího kódu.
SAVETAP nyní před zápisem soubor vyprázdní: opakované sestavení již nepřidává
starší zaváděcí bloky před novou verzi.

## Automatické ověření

Obě varianty se sestaví bez chyb a varování. Každá prošla 1 125 kontrolami:
všech 256 hodnot bajtu, mezery v UART, neúplné OK, přesné dočítání AT,
přetečení řádku, fragmentace čísel, odpovědi 150/226 dělené do bloků,
dlouhé pasivní řádky, PASV dělené přes +IPD, příjem po 226 a LIST
s/bez `total` při každé možné velikosti bloku testovacího výpisu.

Testy vykonávají sestavený Z80 kód v malém interpretu a skutečné tělo BIOS
RX rutiny. UART, síť, tisk a části stránkování jsou simulované; testy
neověřují elektrické časování FPGA, skutečné ESP ani zátěž hardwarové FIFO.
V tomto prostředí byly spuštěné přes dostupný JavaScript runtime, nikoli Node.
Pro opakování s instalovaným Node.js:

```powershell
& 'D:/zx/Tools/SjasmPlus/sjasmplus.exe' --sym=directory-test.sym assembly_mbbsd1.asm
& 'D:/zx/Tools/SjasmPlus/sjasmplus.exe' --sym=directory-esx-test.sym assembly_mbesx2.asm
node tests/directory_protocol.test.js
node tests/directory_protocol.test.js esx
```

## Test na eLeMeNtu

1. Nahraj nově sestavený **kořenový** `SARAH12BSD.tap` nebo `SARAH12ESX.tap`.
   Verzi poznáš podle `D1` v titulku. Soubory v `runable` nebyly změněné.
2. V existující sdílené oblasti FileZilly vytvoř **novou** testovací složku:
   `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\New-DirectoryFixture.ps1 -Root 'D:\cesta-ke-sdileni\sarah-d1-test'`.
   Skript odmítne existující cílovou složku; nic nepřepisuje.
3. Očekávané obsahy (bez syntetického `..`): `empty` 0 položek,
   `small` 3 soubory + 2 adresáře, `large` 700 souborů
   (`item-0001.txt` až `item-0700.txt`).
4. Proveď nejméně 50 obnovení klávesou **R** v každé složce, několikrát
   přejdi dovnitř a zpět. Porovnej počty, první a poslední jméno. Nestačí
   pouze to, že nevyběhne chyba. Zopakuj pro LIST zkrácený, LIST plný a NLST.
5. Ponech nejprve dosavadní baud 3 456 000. Rutina adresáře už v základní
   verzi sama přepíná CPU na 20 MHz; samotné tlačítko před načítáním tedy
   není test na 3,5 MHz. Tato oprava přepínání nemění. Pro samostatné
   srovnání 3,5 MHz je nutné sestavit variantu bez tohoto volání.
6. Zapni ve FileZille ukládání logu. Při potíži zaznamenej čas, číslo chyby,
   režim LIST/NLST, počet položek a FTP zprávy na obrazovce. Uchovej log
   serveru kolem odpovídajícího LIST/NLST. UART TX odposlech je doplněk,
   odpovědi ESP pro něj potřebují také směr RX.

Za úspěšný test považujeme opakovaně správný obsah a počet položek bez
resetování Wi-Fi, následně běžné procházení a kontrolní download malého
souboru (sdílí část příjmových rutin). Výpis přesahující 64KB paměť adresáře
má být označený jako neúplný; tato kapacita se opravou nezvětšuje.
Na fyzickém zařízení tato verze zatím ověřena nebyla.
