## ZAVER1.11.2026: zakladniuploadotestovan,commit+pushzadany

Uzivatel vyslovne: uploadtednechat,jakje, commitspoznamkouapushnaGit.
Zvolena konecnaprofil: normal3456000Bd, uploaddocasne2304000Bd,
DATA7MHz,prompty/ACK20MHz,~20mspauzapo>. SNA/Z80overene, TAPswitcheTODO.
UploadzakladneHWoveren(dvauplne344602B/hash/226/navratLIST/PWD).
Sirsierrorpodminkynepovazovatzaabsolutnevyresene;automatickeUARTrestore
ma46simulacnichregresi705102checks+1067TAPhandoff. Zdrojbezezmenynovehojednani.

NEWznovupotvrzen1.11session70 17:57:00Praha:
STOU GAUNT3.TAP ->500Syntaxerror,commandunrecognized; ABOR->226success.
COMnova session66185 READY2304000Bd8N1 od16:56:24UTC,
temp/sara-uart-20261101-165624/,limit1800s. ZachycenSTOU,ABOR a
AT+UART_CUR=3456000,8,1,0,0 (pozadaveknavratubaudu). PrijemCELEdalsikomunikace
na3456000fixed2304000captureuznezachyti. NevydavatpozadavekzaovereneACK.
PriprotoOLDserveruNEWnepodporovano. UzivatelvybralNEOPRAVOVATted.

Tento stav ukladan podcommitnazvem
"Keep basically tested upload settings and restore normal UART baud".
Pushcil origin/fix-ftp-directory. Presnycommithash/pushstavoveritgitlog/
gitstatusvsorigin (checkpointpripravenpredgitoperaci, netvrdiuspechpredem).
AktualniTAPhash03BE8B9A92D3FD7DD668D37BCB0207E479E76BCCB245FD2B7F7B58546A3180FF,
je shodnynalokalnimFTP. Volno5911BpredBFE0,HGFXOFF.
Dalsiprace: TAPdelete/run/stayswitche, pripadne NEWfallback aznovymzadanim.
## ZVOLENA KONECNA KONFIGURACE UPLOADU1.11.2026

Uzivatel sezeptal,zdaaktualniverzema20mspauzu,a vyslovne reklnechatjikonecnou.
OVERENOvezdroji a shodnouTAP ve workspaceiFTP:
- normalniprovoz3456000Bd(index16);
- jenuploaddocasne2304000Bd(index15), popotvrzenemuklidunavratvstupnibaudu;
- DATA7MHz,prompty/ACK20MHz;
- pauza~20ms po>predkazdymdatovymblokem,BC1500/5376iteraci pri7MHz.
Tato NASTAVENI UZ NEMENIT beznovehozadani. Neznamena dokoncenyTAPswitche
ani vsechnyerrorpodminky. SNA/Z80 uzivatelemoverene, TAPvolbystaleTODO.
Zdroj/binarnebezezmeny, pouzezapisrozhodnuti. Zadnynovycommit/push.
SARA_LOADER.tap obaSHAs:
03BE8B9A92D3FD7DD668D37BCB0207E479E76BCCB245FD2B7F7B58546A3180FF.
Posledniovereni46regresi705102assertions+1067TAPhandoff,free5911BpredBFE0.
Poslednicommit2589400je starsi1152000checkpoint;aktualnizmenyjsounecommitovane.
Dalsipripadnytestoveritbaudprepinani/abort/restore, ne honitrychlost.
## UPRESNENI MERENI1.11.2026: GAUNTcasoveodpovida STOR/upload

Uzivatel nazyva38sGAUNT3priindex12i15stahovanim, ale noveproctenylogsession70
ukazujeSTORGAUNT3 17:45:11->22617:45:50 (39s) a17:46:46->22617:47:23(37s).
Casoveodpovidaobema~38smereni; STORjeUPLOADnaFTP. Neukladat jakoovereny
benchmarkDOWNLOAD/RETR. Dosavadniodstavce nize zachovavajiuzivatelovopojmenovani.
V17:49:10->22617:49:34jedalsiSTOR24s; posledniSTOR17:49:49 pri kontrole bez226.
Nelze bezdalsichudaju priraditjednotlivympokusumpresnybaudneboverzi.
Zaverpro38spri12a15: vyssibaudsamvtestunepomohl; presnybottleneckneznamy.
Kodbezezmeny,novyFTPbuild03BE...jeporadaktualni.
## AKTUALNI1.11.2026: normal3456000, upload2304000,38sdownloadobaindexy

Uzivatel vyslovne zadal normalniprovoz3456000, jenuploadnizsi.
Dokonceno: defaultud_speed16=3456000, fuf2predTYPE/PASV/STORuloziverifbaud
a prepne2304000(index15). DATA7MHz,prompty/ACK20MHz,20mspauzavrácena.
Novyftp_upload_baud.asm sdili existujiciset_ud_speed_a+find_out_speed.
Normalnidokonceni po226 a potvrzeneABOR predLISTobnovivstupnibaud.
Komunikacniobnova nejprveuzavreoldsockety+active modepriuploadbaudu,
pakobnovibaudprednovymloginem. BeznachybaobnovipoUSPEsnemuklidu.
Neuspesny/neoverenyuklid dalsiATbaudnaslepoNEposila; vymazemarker.
Restoremarkermazepredzmenou, abysenezacyklil. ATdefaultneniprepsanna15.
Actualget_baudresiipolovicatouchybuswitchsezastaralymcachedflag7.

Obapreklady0errors/0warnings,HGFXOFF;46regresi705102assertions0failures,
navicTAPhandoff1067. Novetestupload_baud28checks/build.
+78B proti2304000/7MHzS20mspauzou: biosA6A9/konecA8C9,
volno5911BpredBFE0,banka6B8E2958Bbezezmeny. HWswitchingjesteCEKA.
Audit tests/upload-baud-switch-audit.md.
NovaTAPi D:/zx/SARA_LOADER.tap hash03BE8B9A92D3FD7DD668D37BCB0207E479E76BCCB245FD2B7F7B58546A3180FF.
ZalohaFTPC:/Users/milan/AppData/Local/Temp/SARA_LOADER-before-upload-baud-switch-20261101-164652.tap.
Beznovéhocommitu/pushe. Poslednicommit2589400(1152000baseline).
PozorCOMfixed2304000ctepouzeupload, obecnyprovoz3456000nutneprepnoutmonitor.
NoveCOMnynineotvirano; posledni80955uzskoncilcasovym limitem31.10.

Uzivatel38sekGAUNT3.TAPpriindex12 a index15, vyjasnilze jdeostahovani.
ZaznamenatjakoUZIVATELSKEdownloadmereni1152000i2304000stejne38s.
NEplestspredchozimilogovymiSTORcasystare61s/nove40,46,50s.
Toznamena,zevyssibaudvtomtokonkretnimdownloadtestunepomohl; presnou
brzduCPU/DOS/modul/WiFiztohoNEURCIME a neprokazujevsechnybaudyzbytecne.

Stary1152000downloadSARA_LOADER27733B: logsession64 RETR14:24:16/226
stejnasekunda(jenserverovycas). Capture131813nemačitelnýRETR,
nelzezetohopoctivedatcelkovyčasulozeniSary. Teduzivatelzmerilsam38sGAUNT3.
Dalsikrok: novouTAPnacist,overitgeneral3456000->upload2304000->3456000,
dokonceni iBcancel/komunikacnirecovery, pakazpripadneoptimalizace.
Zadnynovyzásah pro dalsirýchlost nanovelatestdiskusi.
## AKTUALNI1.11.2026: bezpauzy ted1upload50s a obsahOK, jenrozborrychlosti

Uzivatel zmerilstaraSara pri7MHz61s, potom nova2304000/7MHzBEZ20mspauzy50s.
Overenlogsession69: starymerenySTOR16:23:38->22616:24:38 (~60s),
novySTOR16:30:20->22616:31:10 (50s), nasledneLIST226/PWD257.
ServerGAUNT3.TAP344602B SHA256presneshodnyspredchozimoverenymCOMpayloadem.
Tedytentokonkretnibezpauzovypokus dokoncil aobsahOK. Predchozibezpauzovy
pokus31.10ovsemerror43aposkozenyposledniblok, neniobecnedeclaredstable.

Casyhistorie:2304000/7MHzS20mspauzou40s a46s (obaobsah/226overeny).
Drive3456000/7MHzBEZpauzyjednou35s, aleopakovanevytuhy.
20mspauzax169bloku=3.38s samotnacena; rozdily40-50snutneovlivnujeidalsirezie/
spojeni, nejsoucistymmeritkemvypnuti/zapnutipauzy.
KEYSCANbezstiskuklavesyreturndelabezcekani, takze nejdeovzdyvkladanydelay.
Mozne dalsi optimalizacezatimjenkrozboru: zmeritcasdisku, DATAaSENDOK;
rychlejsiperbyteTXmuzesimulovatproblemysrychlejsimCPU. Uzivatel sejenpta,
ZADNAnovauprava kodu/TAP/baudu/CPU. AktualniFTPporadBEZpauzyhashD9D860...
COMstary80955 automatickylimitupravdepodobneukoncen; nehlasitbezovereni.
## AKTUALNI31.10.2026: bez20ms error43 A POSKOZENY POSLEDNIBLOK

Uzivatel hlasi43; overenologsession67 STOR22:05:56/150, bez226.
COM205104:61uplnychbloku124928B, potomAT+CIPSEND0,6 (ABORrequest bezpayloadu),
AT+CIPCLOSE5.43 pravdepodobne azclose/recovery, prvniATevent neznamy.
NMI64E4/7F27nedodan (uzivateluznemelnovouSaruvpameti).

DULEZITY NOVY DUKAZ: serverpartial124928B NENI obsahoveshodny.
Prvnirozdil offset123229 od0 = blok61byte349, celkem1624rozdilnychbajtu.
Pritom aktualniodchozi124928B presne odpovidaji stejnemuprefixu predchoziho
uspesneho344602Bzaznamu! Servernesouhlasi sobema. Tedy odchozidatazCOMspravna,
rozdilvznika azpo odposlechnutemTX. Konkretni fyzickapricina NEPROKAZANA.
Vserverfile NENI textAT+CIPSEND0,6/CIPCLOSE5/UART_CUR; netvrditzeATvtelese.
Srovnani jsou nad presneSTORsegmentyCOM, nejdeopredchozistaryupload.
Audit tests/upload-no-delay-audit.md doplnen vysledek nahore.

Uzivateljde sdetmispata vrati se, muzepakpridalsimpokusuopsatNMI.
Chce prehledzjisteni, asi vratit20mspauzu, takezjisti rychloststarehouploadu.
Zatim ZADNA dalsiuprava kodu/FTP: aktivniTAP2304000/7MHzBEZpauzy
hashD9D8602382793CC4DFCF4A03440A46C68B9DBD31CC5111F0CE980852CA024D6A.
Navrzeny dalsikrok: obnovitoverenou20mspauzu2304000/7MHz,2uploady+hash,
pripadnepriopakovanichyb zachytitPC/SP/ATevent predresetem. NMIadresyvzdyzeSYM.
OVERENYfallbackS20ms: temp/SARA_LOADER-before-2304000-14mhz-20261031-210034.tap,
hash5C0F15B0A42F1EDFCBF204E4D314DF7500B080E234DB59D48475C46BE238DD5C.
2predchoziHWuploadyspauzouobsahspravny344602B/226/LIST/PWD.
COM80955capture205104,2304000Bd, limit21:21:04UTC; po navratuoverit/restartovat.
Zadnynovycommit/push. Poslednicommit2589400 je1152000/7MHzSpauzou.
## AKTUALNI31.10.2026:2304000/7MHz BEZ20mspauzy, TAPnaFTP

14MHzpokus selhalprvniblok: session66 STOR22:01:59Praha/150, COM1x2048B
a potom ticho, server0B. Uzivatel vidi20MHzindikator = ACKcekani, DATAbylo14.
Uzivatel vyslovne zadal vratit7MHz a takeODSTRANIT20mspauzu.
Hotovo: DATA/setup/postACK7MHz, UART15=2304000 zustava, prompty/ACK20MHz.
Odstranena8Bpauza i uznepouzity4Bset_14mhzhelper. Ostatnibezemeny,HGFXOFF.
Obapreklady0errors/0warnings;44regresi704378assertions0failures,
navicTAPhandoff1067. BIOSA653/konecA873, volno5997BpredBFE0, bankaB8E2958B.
Audit tests/upload-no-delay-audit.md. Novecekame2HWuploady BEZpauzy.

FTP D:/zx/SARA_LOADER.tap SHA256overen:
D9D8602382793CC4DFCF4A03440A46C68B9DBD31CC5111F0CE980852CA024D6A.
Zaloha14MHz:
C:/Users/milan/AppData/Local/Temp/SARA_LOADER-before-2304000-7mhz-no-delay-20261031-210412.tap.
OVERENYfallback2304000/7MHzS20mspauzou (2uploady/hash/226/LIST/PWD)zustava:
C:/Users/milan/AppData/Local/Temp/SARA_LOADER-before-2304000-14mhz-20261031-210034.tap,
hash5C0F15B0A42F1EDFCBF204E4D314DF7500B080E234DB59D48475C46BE238DD5C.
COM80955overenobezicipoFTPkopii,2304000Bd8N1,capture205104,
limit21:21:04UTC/22:21:04Praha. Zadnynovycommit/push,baselinecommit2589400.
Dalsikrok: novouTAPnacist a2uploady, posouditvlivodstranene20mspauzy.
## AKTUALNI31.10.2026:2304000/7MHz2xHWOK, pripraveno14MHz

Uzivatel potvrdil2uploady2304000/7MHz. Navicovereno:
session66 STOR21:56:30->22621:57:16 a STOR21:57:41->22621:58:21Praha;
oba nasledovaneLIST226/PWD257. Capture205104 offsety13857/362854:
kazdy169bloku344602B, SHA256kazdehoshodny se serverGAUNT3.TAP344602B.
Tedy overenykompletniprenos i obsah a navratadresare protyto2pokusy.
Tuto verzi povazujeme za overenyfallback (ne vsechnyWifi/errorpodminky).

Uzivatel zadal pouzeDATAclock14MHzpri stejnem2304000baudu.
NovaTAPpripravena: set_14mhz selektor2 (+4B), DATA/setup/postACK14MHz.
Prompty/ACK20MHz aUI3.5MHz zustavaji; pauzapo>10752iteraci/#2A00
zachovava~20mspri14MHz. Jinak protokol/chunks/cekanicancelbezezmeny,HGFXOFF.
Obapreklady0errors/0warnings,44regresi705046assertions0failures,
navicTAPhandoff1067. BIOSA65F/konecA87F, volno5985BpredBFE0, bankB8E2958B.
Audit tests/upload-2304000-14mhz-audit.md. Cekaji2HWuploady14MHz.
Pokudneprojdou,uzivatelchcezustatuoverene2304000/7MHz.

Nova D:/zx/SARA_LOADER.tap SHA256overen:
403A43A6EBD5B6B05561F3B9B3996E266C8B9B2EC21E955B5C2608A3495E5A80.
FUNKCNI7MHzTAPzalohovana:
C:/Users/milan/AppData/Local/Temp/SARA_LOADER-before-2304000-14mhz-20261031-210034.tap
SHA2565C0F15B0A42F1EDFCBF204E4D314DF7500B080E234DB59D48475C46BE238DD5C.
COM80955overenobezici po kopii,2304000Bd8N1, capture205104,
limit21:21:04UTC/22:21:04Praha. Prednovymtvrzenimaktivituoverit.
Zadne dalsicommit/push. Predchozicheckpoint1152000/7MHzje2589400.
## AKTUALNI31.10.2026: NOVATAP2304000/7MHz naFTP, cekaHW

Po stallu prvniho2048Bbloku na2304000/20MHz uzivatel schvalil izolovany
pokus2304000/7MHz. PripravenoaFTPaktualizovano. Prompty/ACK20MHzzustavaji,
DATA a inicialniuploader7MHz. Pauzapo>zpet5376iteraci/#1500 (~20ms na7MHz).
Ud_speed15=2304000 zustava. Bloky/protokol/cekanicancel bezezmeny, HGFX OFF.
Oba preklady0errors/0warnings;44regresi705046assertions0failures.
Velikostbezezmenyvolno5989B/bankaB8E. Srovnani se1152000/7MHzbaseline:
jediny zmeneny mainbajt8E61 (12->15), banka6identicka.
Tedy proti uzivatelem overene baseline ted menime POUZEbaud.
ZatimNEovereno2uploady, zadnynovycommit/push. Baselinecommit2589400.

D:/zx/SARA_LOADER.tap SHA256shodny sworkspace:
5C0F15B0A42F1EDFCBF204E4D314DF7500B080E234DB59D48475C46BE238DD5C.
Zaloha predchozi20MHzFTPkopie:
C:/Users/milan/AppData/Local/Temp/SARA_LOADER-before-2304000-7mhz-20261031-205506.tap.
COM80955 overeno bezici po kopii,2304000Bd8N1,temp/sara-uart-20261031-205104/.
Limit21:21:04UTC (22:21:04Praha); azuzivatelzavola overitaktivitu.
Dalsikrok: nahratNOVOUtap, dvaGAUNT3uploady, posoudit226/hash/LIST/PWD.
## HWTEST2304000/20MHz: zastavil uz po prvnim bloku

Uzivatel nactenou novouTAP potvrzuje zamrznuti/cojeCOM.
Logsession65: RETR SARA_LOADER.tap21:52:04/226, startupLIST/PWD21:52:15.
STORGAUNT3.TAP21:52:46/150, bez226 pri21:53:14kontrole.
COM205104: pouze1 CIPSEND1,2048, presne2048payloadbajtu pote, celkem5870B.
Poslednidata20:52:46.475UTC, potezadnydalsiATprikaz. Serverfile0B.
Tedy stalli pri prvnim bloku na2304000/20MHz. Baud vsCPUzatimnerozliseno;
1152000/7MHz uzivatelemprochazel, tedzmenenyobeveliciny dlejeho zadani.
Mozny dalsi izolovanytest2304000/7MHz s~20mspauzou, ale zatimneproveden.
Zadne dalsizmeny kodu. COM80955 stale zaznamenava2304000,limit21:21:04UTC.
## AKTUALNI31.10.2026: pripraveno2304000baud/20MHz pro2uploady

Uzivatel POTVRDIL nizsi1152000/7MHzuploadprochazi (pocet neuvedl).
Drivezadany lokalnicommit dokonceny:2589400
"Checkpoint upload diagnostics at 1152000 baud". ObsahujeWIPupload,
SNA/Z80hardwareOK aTAPswitcheTODO. Zadnypush.
Aktualnipokus2304000/20MHz zatimNEcommitovan, baseline1152000 zachovana.

NovaTAP: ud_speed15=2304000, DATA i prompty/ACK20MHz. Po>15384iteraci
#3C18 misto5376/#1500, pauza zustava~20ms pri20MHz. UI3.5MHzbezezmeny.
HGFX OFF, zadnazmenaostatnichprotokolu/chunks/cekanicancel/obnovy.
Velikost+0B: biosA65B/konecA87B, volno5989B predBFE0, banka6B8E2958B.
Obapreklady0errors/0warnings,44regresi705046assertions0failures,
navic1067TAPhandoff. Audit tests/upload-2304000-20mhz-audit.md.
Zatim CEKA2realneuploady a jejich226/obsah/navratadresare.

TestTAPi D:/zx/SARA_LOADER.tap, shodaSHA256 overena:
D09FAF553AEC2BFCFC94E3103E52BAC41EA63AF57C5BA729908C253907D04B94.
ZalohaFTP1152000:
C:/Users/milan/AppData/Local/Temp/SARA_LOADER-before-2304000-20mhz-20261031-205102.tap.
COM6stara81387/capture131813 skoncila1053109B.
NOVYCOM6 READY2304000Bd8N1 receive-only,session80955.
Capture temp/sara-uart-20261031-205104/, limit1800s od20:51:04UTC
(21:51:04Praha),konci21:21:04UTC/22:21:04Praha. Stop souboremstop.
Odposlech spravny az novaSara prejde2304000; EL/stazeni muze bezet jinymbaud.
Dalsikrok: uzivatel nacteNOVOUtap, overi2304000+20MHz,2xGAUNT3,
potomoveritCOMaFTPlog226,celouvelikost/hash a LIST/PWD. Kodneni HWoveren.
## POTVRZENO UZIVATELEM:1152000baud/7MHz upload prochazi

Uzivatel po navratu potvrdil, ze nizsi1152000 pri7MHzupload prochazi.
Nyni pozaduje dalsitest2304000baud+20MHzCPU, dva uploady.
Nejprve ukladame drive zadany lokalni checkpointcommit overene1152000verze.
SNA/Z80 uzivatelem overeneOK, TAPdelete/run/stayswitche staleTODO.
Uploadpri vysokychrychlostech zustava rozpracovany. Push neni pozadovan.
Dalsikrok po tomto commitu: pripravit2304000/20MHz, pauzu>zachovat~20ms,
overit a datNOVOUtestTAP naFTP. NemenitHGFX.
## AKTUALNI31.10.2026: baud1152000, lokalni checkpointcommit

Pauza20msnepomohla: nova guardTAP stazena session63 14:13:08.
STORGAUNT3 session63 14:14:22/150, progress213530, bez226.
70bloku143360B ven, server141312B, SHA256prefixshodny. Poslednidata13:14:38.444UTC.
Uzivatel vyslovne zadal snizitbaud a commit s rozpracovanymuploadem,
SNA/Z80OK, TAPswitcheTODO. Push nyni nezadal.

Hotovo: ud_speed16->12, default1152000 misto3456000. Datazustava7MHz,
prompty/ACK20MHz. Sviceni20MHz pri cekani je zamerny stav, neni to DATAclock.
Pauza20ms i Bcancelzustaly. Zmena0B navic, volno predBFE0=5989B,
biosA65B/konecA87B, banka6B8E2958B. HGFX OFF.
Oba preklady0errors/0warnings,44regresi705008assertions0failures.
Startupregrese overilaAT+UART_CUR1152000 a nasledneAT pri novemUARTindexu.
Srovnani predchoziguardbinarky: jedina zmena mainbajt#8E61 16->12,
banka6identicka. Hardware novybaud jeste NEOVEREN.
SNA/Z80 uzivatelem potvrzenoOK. DokoncitTAPvolby smazat/spustit/zustat pozdeji.
STOU/N tento mistniFileZilla odmita500 unsupportedcommand (samostatny limit).
Audit tests/upload-baud-audit.md.

NovaTAP i D:/zx/SARA_LOADER.tap, shodaSHA256 overena:
A72E2D0FA35D53530D6FBE40ACE9F3A2B7A4276BA20767B1885F1403CA78EBC4.
Zaloha predchoziFTPkopie:
C:/Users/milan/AppData/Local/Temp/SARA_LOADER-before-baud-test-20261031-131806.tap.
COM6stara session63794/capture125050 zastavena581849B.
COM6NOVY READY1152000Bd8N1 receive-only, session81387, limit1800s od13:18:13UTC
(14:18:13Praha), temp/sara-uart-20261031-131813/. Stop souborem stop.
EL/stazeni mohou jestebezets puvodnimbaud, spravnyodposlech aznovaSara1152000.
Scriptcapture ma take1152000default.

Dalsi krok: uzivatel noveSare overi1152000 naobrazovce, dvaGAUNT3uploady,
226/celavelikost/obsah/navratadresare a pripadneB. ZatuhlyESPpredtestemobnovit.
Tento checkpoint ukladan lokalnimcommitem jakoROZPRACOVANE, uploadneni vyreseny.
## AKTUALNI31.10.2026: testovaci pauza po >, TAP uz na lokalnimFTP

Uzivatel upresnil: nezadaval menu ani baudvolbu; dokoncit rozboruploadu,
baud az kdyz dalsi pokus selze. Schvalil kratke cekani a vyslovne zadalFTPkopii.
Pridana pouze5376iteraci pauza poCIPSEND promptu pri7MHz predprvnimDATA
bajtem (~20ms, bezHALT/preruseni). Hypoteza casovani vstupuESPdoRX,
NENI prokazana pricina zavad ani povinna pauzaESPspecifikace.
UART index16/3456000, DATA7MHz, prompty/ACK20MHz, blok2048 BEZEZMENY.
Zadna dalsi zmena wait/recovery/menu/reset. Dalsi baudtest1152000 az potom.

44regresi705002assertions0failures, navicTAPhandoff1067.
Oba normalnipreklady0errors/0warnings, HGFX OFF.
Zmena+8BpodC000: biosA653->A65B, konecA87B, volno5997->5989B.
Banka6bezezmenyB8E2958B. TAP27733B. Audit tests/upload-prompt-guard-audit.md.
Aktualni NMIadresy proNOVOUtap: upload_last_event64EC, RX_buf8E8A.
Drive namereneNMI (64E4/8E82) patrilo predchoziHWverzi.

D:/zx/SARA_LOADER.tap aktualizovana, SHA256overen protiworkspace:
8B1FE9AE294075464F87E16BBC0E338359D27DB64565181A120489B52B287055.
Predchozikopie zaloha
C:/Users/milan/AppData/Local/Temp/SARA_LOADER-before-prompt-guard-20261031-131129.tap.
ZadnyCFGkopirovan. Zadnycommit/push.
Dalsikrok: uzivatel nacteNOVOUtap, funkcnimodulem dvaGAUNT3uploady,
overit226 a navratadresare; dalsi pripadnyvytuh diagnostikovat. Pakmoznybaudtest.
COM6session63794 capture125050, limit13:20:50UTC (14:20:50Praha);
pred dalsim tvrzenim oaktivite overit/obnovit.
## AKTUALNI31.10.2026: rychlosti NEMENIT, upresnit nastaveni

NMI doplneni uzivatele: #64E4=00, slova zasobniku oddrive SP5FE4:
8500,9E03,0FFF,7F20,A174 (uvedl jako SP=...; bereme jako obsah zasobniku).
9E03 je navrat z rece_byte do ftp_read_byte; A174 navrat do at_next_event.
0FFF a7F20 zapadaji do cekani parseru po mezere vyzvy. Posledni udalost0:
cekani na potvrzeni posledniho bloku se nevratilo. Neprokazuje pricinuUART/TCP.

Uzivatel navrhl pouze jako napad UART1152000 priCPU7MHz (nyniUART3456000,
DATA7MHz, cekani20MHz). Zatim zadna zmena. Nasledne vyslovne rekl
rychlost zatim nemenit a udelat nastaveni. Neni jasne ktere nastaveni:
polozena otazka baudvolba versusdrive odlozeneTAPvolby. CEKA se upresneni.
Neimplementovat snizeni rychlosti ani odhadovat jine nastaveni bez odpovedi.
## NMI31.10.2026 pro progress279066

Uzivatel dodalPC=A72B SP=5FE4, RX#8E82:
4F4B0044204F4B003820627974657300636365...
= OK\0 +stareD OK\0 +stare8 bytes\0. Odpovida postupnemu prepisu
Recv2048bytes -> SEND OK -> OK, neni to jeden aktualniFTPtext.
Bios_startA653, A72B=offsetD8 (PUSH DE v rece_byte, hned poPUSH BC).
Je tedy v BIOSUARTreceiveru; presneho volajiciho musi potvrditzasobnik.
#64E4 uzivatel dosud nedodal. Pozadan bajt#64E4 a6slovodSP5FE4.
NMI nedokazuje, zda ESP nedostalo celypayload, ztratila seUARTodpoved, nebo
stale cekaTCP; nedelat ztoho jistouWiFizavadu. Beznovychzasahu do kodu.
## HW31.10.2026: jeden GAUNT3 dokoncen, druhy stoji279066

Uzivatel hlasil New/STOU Transfer aborted, pak smazani stareho souboru proslo.
Vlogu stara session56 ukoncena Administrator13:52:13. Nasledny cistySTOR:
session61 13:52:42 GAUNT3.TAP150 ->13:53:17 skutecne226, TYPEA/PASV/LIST226,
PWD257 ve13:53:18. Capture125050 prvniSTOR offset2610:169CIPSEND1,
deklarovano344602B, uzavreni1, bezCIPCLOSE5. Jeden upload tedy dolozene
dokoncil server a dosel zpet k adresari. Neprokazuje vyreseni prerusovanehoWifi.

DruhySTOR stejnasession61 13:53:51/150, bez226 pri kontrole.
Uzivatel progress279066 a vytuh. Capture poslednidata12:53:58.393UTC,
36uplnychbloku=73728B, serverpartial71680B se shodnymSHA256prefixem.
Za poslednim blokem zadnyATprikaz, zadnyCIPCLOSE; cekani zustava aktivni.
Pozadan NMI PC/SP, bajt#64E4 a prvnich16B od#8E82 (aktualniTAP!).
Noveadresy: ftp_upload_wait#9E29, at_closed#A4D6, ftp_last_error#7F27.
Cekame naNMI; predtim nedavatB anireset, aby se stav neztratil.
COM6 session63794 capture125050, limit13:20:50UTC.
## COM6 ZNOVU READY31.10.2026

Predchozi session43581 skoncila limitem,335959B. Na dotazuzivatele znovu
zapnutCOM6 3456000Bd8N1 receive-only, READY, session63794.
Capture C:/Users/milan/AppData/Local/Temp/sara-uart-20261031-125050/.
Limit1800s od12:50:50UTC (13:50:50Praha). Stop souborem stop v tomtoadresari.

## HW TEST31.10.2026: tentokrat server odmitl cilovy soubor550

Uzivatel po uploaduGAUNT hlasi ze se nicnestalo. Logoveren:
session57 13:41:48 STOR GAUNT3.TAP ->150 a hned550 can't access file.
ABOR226, reconnectsession58 USER/PASS230, LIST226/PWD257.
Druhy pokus session58 13:42:06 stejnySTOR150/550, ABOR226,
reconnectsession59 USER/PASS230, LIST226/PWD257 ve13:42:08.
Toto neni potvrzeni uspechu velkehouploadu ani test dlouhe pauzy.
ServerpartialGAUNT3 stale309248B, atributArchive (neniReadOnly).
Stara session56 z minuleho zamrzleho uploadu vlogu dosud bezdisconnect/226;
mozny lock cilovesouboru, zatim neprokazany. Zadne odpojovani ani mazani.
COM6zachytil2 CIPSEND1,2048 (kratke pokusy),2CIPCLOSE5 a nasledne prikazy.
Dalsi krok zkouset jiny/unikatni cil (volbaN/STOU pri existujicim souboru),
pripadne uzivatel uvolni starouFTPsession56. Velkyprenos stale ceka overeni.
## NOVA TAP NA FTP31.10.2026: cekani bez pevneho limitu pri pauze

D:/zx/SARA_LOADER.tap aktualizovana, shodaSHA256 s workspace overena:
2AF5BDD1F443D6B3F890A774A8240A7FB7E7A5C2A6A5DCAEEC7E3ECB6B38A5EB
Zaloha predchozi testovane verze:
C:/Users/milan/AppData/Local/Temp/SARA_LOADER-before-cooperative-wait-20261031-123112.tap.
Na realnem stroji nove cekani jeste NEOVERENO. Predtestem musi byt modul
opet funkcni (uzivatel hlasil zatuhnuti a neuspesne hledani rychlosti).

## AKTUALNI31.10.2026: cekat a pokracovat bez odpojeni pri samotnem tichu

Uzivatel po dalsim48 rekl, ze novy startSary pomalu hledal rychlost a zadnou
nenasel, modul asi potrebuje reset. Pak vyslovne upresnil: idealne pockat a
pokracovat v prenosu jakoPC. Dokoncena tato politika cekani:
- Upload po plne odeslanem bloku ceka naSEND OK bez casoveho odpojeni.
  B pravidelne cte INKEY; nic znovu neposila, zadneATbehem cekani.
  PotvrzeneERROR/SEND FAIL/busy/CLOSED/WIFI DISCONNECT stale znamena chybu.
- Download platnou prazdnou odpoved naCIPRECVLEN opakuje s pauzou az do dat,
  closed neboB. Bez poctoveho limitu2048, stale konecna kontrola fronty priCLOSED.
- BeznaATodpoved (take kazdyCIPRECVLEN dotaz) ma dal timeout; mlcici modul
  neni povazovan za platnou prazdnou odpoved.
- Nepridan nepodmineny reset, ten by zrusil relaci. Skutecne zatuhnutiESP
  neni timto prokazane vyreseno. Obnova po ztrateTCP neni resumeuploadu.

Oba preklady0chyb/varovani, HGFX OFF;44regresi704334assertions,0failures.
Upload1910BSD/181ESX, pause76/build. Test i celeho32768Buploadu s pauzou
2200000UARTpolls a pokracovanim bezreplay, download4096prazdnych dotazu.
Audit tests/transfer-pause-audit.md (nova sekce nahore).
Velikost podC000 dalsi-24B proti posledniHWverzi:
A66B->A653, konecBIOS A873, volno predBFE0=5997B (bylo5973).
Celkem-321B protiA794. Banka6 bezezmenyB8E=2958B. ESX take-24B.
NovaSARA_LOADER.tap zatim ve workspace; FTPkopii aktualizovat poovereniSHA.
Bezcommitu/pushe. Dalsikrok: nahrat novouTAP, modul predtestem uvest do
funkcniho stavu, zkouset kratky a pakGAUNT3 upload s pauzou, B, download.
COM6 session43581 limit1800s od12:19:52UTC; aktivitu predtestem overit.
## DOPLNENI HW TESTU: potvrzen timeout48

Uzivatel potvrdil48. Po CIPCLOSE5 capture daleobsahuje CIPSTATUS a AT,AT;
novy USER/PASS/LIST v tomto useku neni. LokalniFTPlog stale konci session56
STOR/150; nelze potvrdit uspesnou obnovu adresare. Zjistit aktualni stav UI.
Dalsi prodluzovani cekani neni dolozene reseni priciny.
Aktualni diagnostika v nove TAP: upload_last_event #64E4, ftp_last_error #7F27,
RX_buf #8E92, ftp_upload_wait #9E41 (starsi adresy z chatu NEPOUZIVAT).

## HW TEST 31. 10. 2026: upload opet zastavil, zbyva49690

Nova TAP stazena z FTP (session56 SIZE27733/RETR150/226 ve13:20:23-24).
UploadGAUNT3 session56 STOR13:20:44/150, bez226 pri kontrole.
Capture121952:152 uplnych2048B bloku=311296B; posledni data12:21:27.801UTC.
Serverpartial309248B, SHA256 shodny s odchozim prefixem teto delky.
Posledni jeden blok navic vUARTu nez vserverpartial; neni dokazano ztraceni.
V12:23:40.789UTC dalsich15B po132.988s, tj.prodlouzene cekani4x opravdu
probehlo, ale prenos neobnovilo. Overeny prikaz AT+CIPCLOSE=5 (obnova).
Uzivatel hlasi stejny vytuh/zbyva49690. Presnou ESP odpoved stale nemame,
jen odchozi smer. Uzivatel POTVRDIL chybu48 na konci. Zadna dalsi uprava kodu.
COM6 session43581 stale nahrava s limitem1800s od12:19:52UTC.
## COM6 ZAPNUT 31. 10. 2026 pro test nove TAP

Na pokyn uzivatele: COM6 3456000 Bd 8N1 receive-only, READY.
Exec session43581, limit1800s od12:19:52UTC (13:19:52 Praha).
Capture C:/Users/milan/AppData/Local/Temp/sara-uart-20261031-121952/.
Ukonceni souborem stop v tomto adresari. Uzivatel spousti EL a stahuje novou Saru.

## PREDANO K TESTU 31. 10. 2026: pauzy prenosu

Nova overena SARA_LOADER.tap je i na D:/zx/SARA_LOADER.tap.
SHA256 DAEBC52B13838B33D5866BE78E5E4E22B2B7C21D94DD1E8DF219B649D04BE39A
27733B, shoda s workspace overena. Predchozi kopie zalohovana:
C:/Users/milan/AppData/Local/Temp/SARA_LOADER-before-pause-fix-20261031-115423.tap.
Nahrat tuto novou verzi pred dalsim uploadem. Nekopirovan CFG ani jine soubory.
COM6 session96429 skoncila na automatickem limitu, STOPPED148934B.
COM6 je nyni OFF; pred dalsim testem znovu otevrit podle domluvy.
## AKTUALNI 31. 10. 2026: pauzy prenosu, hotovo pro novy HW test

Uzivatel zadal pokracovat, odolne cekani pri slabem spojeni i pro download,
sdilet co jde, minimalizovat bajty a odstranit nepouzite stare vetve.
Posledni HW test pred touto upravou: session53/STOR GAUNT3.TAP/150,
63 odchozich bloku=129024B; server v tu chvili126976B. Pak asi33.28s pauza,
CIPCLOSE5 a obnova. Uzivatel229914 zbyva, nakonec48. Bez226.
USB zachycuje jen odchozi smer; pricina prvniho chybejiciho ACK neprokazana.
Slabe spojeni bylo zamerne.

Hotovo: upload SEND OK ceka4x dele (jen tato faze), B muze cekani zrusit.
Zname CLOSED/WIFI DISCONNECT jej ukonci. Download prazdny buffer nepovazuje
za EOF: paced dotazy az2048, konec az prazdno+closed s posledni kontrolou.
B ma oddeleny navrat pro disk/screen/TXT; uklid pres existujici ABOR.
Timeout jde do existujici jednorazove obnovy. Zadny replay dat ani FTP resume.
Opraveny take dva32bit testy rest_len (65537/131074 nesmi byt nula).
Odstraneny ftp_upload_legacy.asm, prepinani jeho rezimu, stary parser,
look_for_ipd/look_on_fly, jejich decimalni helper a nepotrebne retezce.

Pri cisteni zachytil assembler prilis siroke odstraneni zdroje. Obnoveno,
vraceny i dosavadni guards/FIND/screen/recovery upravy. Zadne chybne
mezisestaveni nepredano naFTP. Znovu overeny vsechny regrese a chybejici
symboly proti predchozi dobre binarce (jen zamerny legacy ubytek).
Oba preklady0 chyb/varovani, HGFX OFF. 44 testbehu704319assertions,
navic TAP handoff1067. Nove pause69/build, upload1909BSD/181ESX.
Audit tests/transfer-pause-audit.md. Novy HW test stale CEKA.

Velikost oproti naposledy testovane TAP: podC000 -297B,
BSD bios_start A794->A66B, konecBIOS A88B, volno predBFE0 5676->5973B.
Banka6 B8B->B8E=2958B (+3B). SARA_LOADER.tap27733B.
ESX stejna uspora297B, banka+3B. Priorita stale BSDOS, pakESX, pakHGFX.

Uzivatel potvrdil SNA/Z80 na stroji. Pozdeji: nastaveni TAP spustit/smazat/
zustat v Sare; take precedence CFG cilove relace proti jiz existujici relaci.
Tyto dve veci nyni NEMENIT. Indikator poradi polozky stale odlozen.
Dalsi krok: nova TAP z FTP, kratky upload, GAUNT3, druhy upload;226, velikost,
obsah a navratadresare. Pak slaba sit/B a downloadpauza. Bezcommitu/pushe.
COM6 session96429 overena jako bezici pri dokoncovani; limit1800s od11:24UTC.
Capture temp/sara-uart-20261031-112400. Pred tvrzenim ze stale bezi overit.
FTPkopii aktualizovat az po testech, zaloha starekopie a shodaSHA256.
## Zivy COM6 capture31.10.2026 pro novou uploadovou verzi

Na vyslovny pokyn uzivatele znovuzapnutCOM6,3456000 Bd8N1, receive-only.
Exec session96429,READY,limit1800s od2026-10-31T11:24:00Z.
Zaznam C:/Users/milan/AppData/Local/Temp/sara-uart-20261031-112400/
rx.bin,chunks.jsonl,settings.json; stop pres soubor stop v adresari.
TestovatNOVOU TAP z FTPkopieD:/zx/SARA_LOADER.tap (spolecnyreceiver,
20MHzACK,7MHzDATA,EDIT), nepredchozi nactenou verzi. Predchozi8170skoncila.

## DOKONCENO31.10.2026: nova testovaci TAP i na lokalu FTP

Po vsech testech nahrana aktualni SARA_LOADER.tap take doD:/zx/SARA_LOADER.tap
(povolena eskalace pro zapis mimo workspace). SHA256 overeny se workspace:
6EE99D3AB8FF68B1946575DE924AE7FACD4A868D7B4B666713A703A803C6C02B.
Stara FTPkopie zalohovana do temp:
C:/Users/milan/AppData/Local/Temp/SARA_LOADER-before-upload-fix-20261031-112059.tap.
Ta nova kopie obsahuje spolecny upload receiver,20MHz ACK/7MHz DATA,
jasny offlineobraz po chybe, EDITclearing. +43B, volno5676 B.
Normalni callerFTPloader a testscripty jsou hotove; realny upload staleceka.
COM6 session8170 dosla na automaticky limit1800 s a je ukoncena; ulozeny
capture103104 obsahuje diagnostiku chyby16/48. Pred dalsim uzivatelskym
testem znovu otevritCOM6 dle navazujici domluvy; tedport neni drzen.
Bez noveho commitu/pushe.

## AKTUALNI 31. 10. 2026: nova uploadova vetev a EDIT, ceka realny test

Po potvrzenem navratu z preruseneho uploadu selhal prvni plny GAUNT3.TAP:
server session52 STOR11:35:07/150,36 bloku=73728 B, bez226. USB pak
CIPSEND0,6 bez ABOR, uzivatel16 a cekani, potom48. NMI flags D8/00 potvrzuji
neplatne spojeni/adresar; sipky blokuje flag, stary obraz zustal videt.
PC nedodan. Skutecny chybejici ESP vysledek stale nezname (USB jenven).

Uzivatel rekl pracovat dale a zadal EDIT mistoSS+Q, spocitat volne misto.
Hotovo: uploadmode0 sdili AT/activeFTP prijimac. Prompty/SEND OK na20MHz,
DATAzustava7MHz, UI3.5MHz. Potvrzeni/formalne chyby a fronta FTP jsou
cteny spolecnym parserem. CloseconsumeOK a pak skutecneFTP226; ABOR
pokracovani stejnym active-readerem. Chyby16/43 smeruji do jedne obnovy.
Pri zneplatneni spojeni se smaze stary adresar a vykresli offline stav,
takze nebudou videt nefunkcni sipky nad starou strankou. Stavove bajty
upload_last_event/ftp_last_error uchovaji prvni diagnostiku pres uklid.

INPUT: EDIT(CS+1,kod7) nyni vymaze radek; SS+Q uz ne. BREAK stale rusi.
Aktualizovan sara.hlp a regresni testy včetněskutecne klavesove matice.
Zmena klavesy sama o sobe0B. Cela nova uprava +43B pod C000, proti
predchozimu testovanemu sestaveni: bios_start A769->A794, konecA9B4,
volno predBFE0 5719->5676B. Banka6B8B=2955B beze zmeny.
Oba preklady0 chyb/varovani, HGFX OFF. Vsechny souvisejici regreseprosly:
upload1911/183,recovery149,input436,FIND1386 a dalsiFTP/TXT/CFG/screen.
Audit tests/upload-shared-receiver-audit.md. Hardware zatim NEovereno,
netvrdit ze upload je definitivne opraven ani ze prijem rychlosti byl pricina.

Aktualni SARA_LOADER.tap ve workspace sestaven. Kopie v D:/zx byla shodna
se STAROU testovanou verzi, nyni po kompilaci muze byt stara; aktualizaci
kopie na FTP provest az po testech/zalohovani a overit SHA256.
COM6 session8170 ma limit1800s od10:31:04UTC; zaznam103104 zustava ulozen.
Nespoustet nove uploady bez nahrani nove verze; po navratu uzivatele nejprve
kratky upload, pak GAUNT3 a druhy upload, overit226/velikost/navratadresare.
Bez commitu/pushe. Priorita BSDOS; indikator poradi stale pozastaven.

## POTVRZENO NA STROJI 31. 10. 2026: obnova po prerusenem uploadu

Uzivatel provedl upload ->NMI ->BS-DOS ->novy start bez Q/resetu Wi-Fi,
prihlaseni podle nej probehlo OK. Overen USB capture103104 a mistni FTP log.
Pred restartem35 bloku po2048 B (71680 B), STOR GAUNT3.TAP na lokalu,
server session51:11:31:43 150, bez226;11:32:03 disconnected.
USB v offsetu72565 zachytil skutecne AT+CIPCLOSE5, CIPRECVMODE0,
CIPSTATUS, nove CIPSTART0 na sarah.speccy.cz (vychozi CFG profil),
USER/PASS, NOOP, TYPE A, PASV, LIST a navrat PWD po docteni adresare.
Tim je konkretni automaticke odpojeni stare nedokoncene relace a nove
prihlaseni po restartu POTVRZENE hardwarem, vcetne funkcniho adresare.

Pozdeji capture ukazuje dalsi CIPCLOSE5 v offsetu73718 a nove pripojeni na
192.168.0.105; mistni server session52 11:32:43 USER/PASS230, LIST150/226,
PWD257 a nasledny NOOP200. Jde o nasledne dalsi pripojeni, nemichat ho
s prvnim automatickym obnovenim na vychozi server. Odpovedi ESP stale
nemame, ale serverovy log a uzivatelske potvrzeni souhlasi s prubehem.

Zbyva plny upload GAUNT3.TAP s novymi cekanimi (ukonceni226, velikost,
druhy upload, nasledny pruchod adresari). Test umele preruseneho uploadu
sam o sobe NEpotvrzuje kompletni upload ani vsechny varianty vypadku.
Kod ani TAPy ted nemenene. COM6 capture session8170 stale muze bezet,
limit1800s od10:31:04UTC; slozka sara-uart-20261031-103104. Raw obsahuje
prihlasovaci udaje, nevkladat jej do Gitu ani chatu. Bez commitu/pushe.

## Zivy odposlech 31. 10. 2026: test preruseneho uploadu a noveho startu

Na aktualni dotaz uzivatele zapnut COM6,3456000 Bd8N1 receive-only.
Exec session8170, READY, limit1800s od2026-10-31T10:31:04Z.
Vystup C:/Users/milan/AppData/Local/Temp/sara-uart-20261031-103104/
rx.bin,chunks.jsonl,settings.json; stop pres soubor stop v tomto adresari.
Plan testu: upload ->NMI ->BS-DOS bez Q a bez navratu do behu Sary,
pote znovu nacist aktualni SARA_LOADER.tap, Wi-Fi modul/server ponechat
bez resetu. Overit automaticke uzavreni stare relace a nove prihlaseni.
Aktualni test zatim bez vysledku. Predchozi capture9053 je ukonceny.

## AKTUALNI 30. 10. 2026: automaticke obnoveni zamrzle FTP relace hotovo

Uzivatel vyslovne zadal opravit36 pri startu nad zamrzlou relaci a aby Sara
sama odpojila starou relaci a znovu se nalogovala. Implementovano:
CIPSTATUS eviduje datovy socket1, jeho preziti pri kontrole spojeni vyvola
obnovu jeste pred NOOP/TYPE/PASV. Chyby4/36/48/49 pouziji stejnou obnovu.
Obnova invaliduje stav/cache, bounded vycisti stare odpovedi, CIPCLOSE5,
reset parseru a aktivni prijem, pak existujici auto_login s ulozenymi udaji.
CIPCLOSE ERROR se toleruje jen po overeni STATUSem, ze0/1 uz neexistuji.
Zdravou control-only relaci start zachova. Upload se sam neopakuje.

error_recovering:0 normal,1 plain cleanup,2 automatic reconnect. Jen JEDEN
pokus pres cleanup/prihlaseni/novy adresar. Druhe selhani zobrazi chybu a
vrati klavesnici; chybne USER/PASS ani uklid uz neroztoci login smycku.
Ostatni chyby take po uklidu vraci klavesnici, misto opakovani startovaciho
error_handler_loop. Novy fixed-RAM ftp_recovery.asm, status parser upraven.

Oba normalni loadery sestaveny bez chyb/varovani, HGFX stale OFF.
Test ftp_recovery 121 kontrol pro kazdou DOS variantu; vsechny souvisejici
regrese prosly. Podrobnosti tests/ftp-recovery-audit.md.
Naklad teto opravy +232 B pod C000: bios_start A681->A769,
konec BIOS A989, volno pred BFE0 5719 B. Banka6 stale B8B, stejna delka.
Novy SARA_LOADER.tap je pripraven na realny test.

Dalsi krok po navratu uzivatele: overit spusteni pri stare/nedokoncene FTP
relaci (automaticke odpojeni+login+adresar), pak upload GAUNT3.TAP.
Skutecny duvod ESP odpovedi pri drivejsi36 stale neni dokazany; netvrdit
hardware potvrzeni teto obnovy ani uploadove opravy bez dalsiho testu.
COM6 je NADaLE VYPNUT dle vyslovneho pozadavku, capture session9053 skoncil
441 B; nespoustet bez dalsi domluvy/testu. Zaznamy jsou ulozene v temp.
Bez commitu/pushe; posledni vzdaleny d8356dc. Indikator poradi pozastaven.

## AKTUALNI 30. 10. 2026: COM6 VYPNUT na zadost uzivatele; start chyba36/4

Uzivatel po nahrani nove TAP hlasi36 PRI STARTU, ne pri uploadu. Potom se
opakuje4. Musel odejit; zadal proverit a odposlech COM6 VYPNOUT. Splneno:
stopfile v sara-uart-20261030-192430, session9053 ukoncena (exit0),
STOPPED bytes=441. COM6 je uvolnen, zadny aktivni capture.
Ulozene rx.bin/chunks.jsonl zustavaji v temp slozce. NEznovuotevirat bez
navazujiciho testu po navratu uzivatele. Program/TAPy v tomto kroku NEMENENY.

Provereno USB a FTP log:
20:25:40 STALE session50 z nedokonceneho GAUNT3 uploadu. SARA po startu
odesila NOOP200, TYPE A200, PASV227. Potom uz zadny LIST ani CIPSTART1,
novy upload se vubec nerozbehl. Prvni USB cast ma109 B. Po potvrzovani chyb
UART pokazde CIPRECVMODE0, CIPSTATUS, CIPSEND0,6/NOOP, CIPSEND0,12/USER.
Server20:26:27 NOOP200/USER331; nasledne NOOP530/USER331 opakovane.
PASS se v novem pokusu NEODESLAL. Zadny novy STOR ani uploadovy blok.

Zdroj:36 je v receive_ftp_answer/rfa3 pri C z at_wait_send v moderni
(neuploadove) vetvi. C zde znamena explicitni AT_ERROR/SEND_FAIL/BUSY;
obycejny timeout moderniho cteni by skoncil48. Ktery z techto AT vysledku
nastal, NEVIME, dostupny USB proud odpovedi neobsahuje. Pri opakovane4
je sfcerr3 (neshoda ocekavaneho FTP kodu) a error_handler_loop automaticky
znovu get_status_ftp/NOOP, pak al_user_pass/USER. To vysvetluje opakovanou
pokusnou prihlasovaci smycku, ale presny chybne precteny kod nemame.

Nedokoncena predchozi FTP/datova relace je dolozena, zda prave ona zpusobila
36, je zatim HYPOTEZA. Neslibovat potvrzenou pricinu ani opravu36.
Dosavadni oprava55B usetreno v uploadovem cekani zatim na novem HW
uploadu NEBYLA overena; start selhal driv. Nasledujici test po navratu:
nejprve cisty stav ESP/FTP (po domluve restart Wi-Fi modulu / ukonceni stare
relace), overit start a adresar; pak teprve upload a novy COM6 capture.
Pokud36 zustane i pri cistem startu, nutno zachovat konkretni AT vysledek
pred potvrzenim chyby (NMI/RX_buf nebo cilena diagnostika), misto hadani.
Posledni build stale bios_start A681, banka6 B8B, volno5951 B, HGFX off.
Bez commitu/pushe. Indikator poradi stale pozastaven; dalsi prace BSDOS.

## Zivy odposlech pro test opraveneho uploadu

COM6 znovu OTEVREN,3456000 Bd8N1 receive-only, exec session9053,
limit1800s od2026-10-30T19:24:30Z. Novy vystup:
C:/Users/milan/AppData/Local/Temp/sara-uart-20261030-192430/
(rx.bin,chunks.jsonl,settings.json; stop vytvorenim souboru stop).
Uzivatel ma nahrat aktualni SARA_LOADER.tap s opravou uploadovych cekani.
Dalsi krok: precist posledni bajty tohoto NOVeho zaznamu a FTP log po
vysledku uzivatelskeho testu. Predchozi capture190332 uz neni aktivni.

## Aktualni checkpoint 30. 10. 2026: opravena uploadova cekani, ceka hardware

Uzivatel nemuze prepojit odposlech a na navrh opravit cekani rekl 'ok,
pokracuj'. Opravena potvrzeni uploadu, nikoli diskova cast ani deleni dat.
SEND OK nyni cte existujici look_on_fly po bajtech s timeoutem; neztraci
cast shody pri prestavce mezi ctenimi. Prompt uploadu stejne bounded,
char_zob premapovan na samotne > (nevyzaduje OK ani koncovou mezeru).
Po uspechu se dalsi UART bajty nemazou. Prazdny prijem/busy uz nemuze
znovu a znovu restartovat nekonecne cekani. Original FTP/IPD parser zachovan.

Test prokazal ztratu rozdeleneho SEND OK ve starem binarnim prekladu;
novy prosel 515 kontrol BSDOS/152 ESXDOS, vcetne simulovaneho uploadu
32768 a307201 B pres16KB banky a CIPCLOSE/226/navrat do adresare.
Prosly vsechny souvisejici regrese; podrobnosti tests/upload-wait-audit.md.
Neni tim potvrzen puvodni HW duvod abortu, odpovedi ESP odposlech neukazuje.

Sestaveny aktualni oba normalni loadery, bez chyb/varovani, HGFX vypnuto.
Oprava USPORILA55 B pod #C000: bios_start A6B8->A681, konec BIOS A8A1,
volno pred BFE0=5951 B. Banka6 stale B8B. Zmeny bez commitu/pushe.
Dalsi krok: uzivatel nahraje NOVY SARA_LOADER.tap a opakuje GAUNT3.TAP,
vcetne druheho uploadu a nasledneho pruchodu adresari. Dostupny USB
odposlech COM6 3456000 Bd zachovat stejnym zpusobem. Novy capture oddelit
od ulozeneho sara-uart-20261030-190332 (291612 B, zastaveno).
Indikator poradi polozky zustava pozastaven. Priorita BSDOS ->ESXDOS ->HGFX.

## Aktualni checkpoint 30. 10. 2026: NMI presne potvrzuje cekani na ABOR prompt

Uzivatel opsal HEX PC79C5, SP5FE6, zasobnik A17E,0080,8F12,8ABF,7E80.
Adresy PRESNE odpovidaji aktualnimu BSDOS prekladu s opravou screenu:
79C5 = OR D v receive_data1 (casovac receive_data_timeout).
A17E = navrat po receive_data_timeout v upl_old_check_module_answer.
0080 = pozadovany pocet bajtu; 8F12 = RX_buf; 8ABF = char_zob
("OK" CRLF "> ");7E80 = navrat z check_module_answer v cipsend_request.
Spolu s poslednim UART AT+CIPSEND=0,6 bez ABOR je tim potvrzeno, ze Sara
zamrzla pri cekani na prompt pro ABOR. upl_old_check_module_answer pri
opakovanem prazdnem prijmu zacina znovu bez celkoveho limitu.

Puvodni pricina vstupu do ful_abort stale neni dokazana. Vsech139 datovych
bloku po2048 B proslo na server bitove shodne (SHA256 overeno). Mozna
ztrata/rozdelene SEND OK, ale odposlech neobsahuje smer ESP -> Sara.
Nutny dalsi zaznam TX ESP / RX Sary pro odliseni chybejici/nespravne nebo
predcasne spotrebovane odpovedi. Zatim zadny dalsi zasah do ASM/TAPu.

Dosavadni capture zastaven vytvorenim 'stop' v temp slozce
C:/Users/milan/AppData/Local/Temp/sara-uart-20261030-190332/; zkontrolovat
ukonceni exec session4920 pred dalsim otevrenim COM6. Uchovat rx.bin a
chunks.jsonl, NEcommitovat raw komunikaci. Dalsi capture zalozit oddelene
pri stejne3456000 Bd po prepojeni smeru ESP -> Sara.

## Aktualni checkpoint 30. 10. 2026: UART zachytil upload session50

Uzivatel: upload tentokrat dojel podle obrazovky, ale na konci zamrzl.
UART COM6 capture v sara-uart-20261030-190332/rx.bin ma aktualne291612 B;
metadata LastWriteTime/Length jsou pri otevrenem writeru ZAVADEJICI, cist
skutecnou delku pres FileStream.Length. Zaznam obsahuje pouze SARA -> ESP,
nikoli odpovedi ESP (zadne SEND OK/Recv/+IPD). 139 prikazu
AT+CIPSEND=1,2048 a plnych139 payloadu =284672 B. Extrahovany payload
SHA256 presne souhlasi se souborem D:/zx/GAUNT3.TAP (284672 B).

Posledni UART prikaz je AT+CIPSEND=0,6 CRLF v offsetu291596 (UTC19:06:53).
Za nim uz neni ABOR ani dalsi prikaz. To odpovida vstupu do ful_abort a
cekani na prompt pro odeslani ABOR; normalni uploadovy CIPCLOSE=1 se po
datech NEODESLAL. Server log session50 STOR19:06:15 UTC /20:06:15 mistni
->150, stale bez226/ABOR. Nelze zatim dolozit puvodni duvod abortu
(chyba SEND OK je moznost, ne potvrzeni).

Uzivateli poslana async otazka: NMI PC,SP,prvnich8 slov zasobniku v
zamrzlem stavu. Cekame na odpoved. Alternativne dalsi odposlech TX ESP
(smer modul -> Sara), aby bylo videt skutecne potvrzeni/prompty.
Program ani TAPy se v teto diagnosticke fazi nemenily. Capture session4920
stale otevrena, automaticky limit1800s od19:03:32 UTC; stop pres soubor stop.

## Zivy UART odposlech COM6 - 30. 10. 2026

Uzivatel pripojil USB odposlech COM6, rychlost3456000 Bd. CoolTerm musel
uvolnit port. Capture je nyni OPRAVDU spusteny: exec session4920,
COM6 3456000 8N1, receive-only, bez odesilani, DTR/RTS false.
Skript tests/capture_uart.ps1, limit1800 s. Data a casove znacky:
C:/Users/milan/AppData/Local/Temp/sara-uart-20261030-190332/
rx.bin, chunks.jsonl, settings.json. Stop pres vytvoreni souboru 'stop'
v tomto adresari. Zaznam je mimo Git; necommitovat zachycene prihlaseni.
Dalsi krok: uzivatel zopakuje upload GAUNT3.TAP, pri zamrznuti zkontrolovat
konec rx.bin a FTP log. Smer odposlechu zatim nebyl uzivatelem upresnen.
Program Sary se pri priprave odposlechu nemenil.

## Aktualni checkpoint 30. 10. 2026: upload GAUNT3.TAP zamrzl

Uzivatel POTVRDIL funkcni opravu navratu ze screenu na stroji ('uz to jede').
Pak testoval upload asi300 kB a pruchod adresari. Upload zamrzl, bez cisla
chyby; podle obrazovky cca po jedne16KB strance. Precten konec lokalniho
FileZilla logu: session49,19:57:54 SIZE GAUNT3.TAP ->550 (normalni test
neexistujiciho cile), TYPE I200, PASV227;19:57:55 STOR ->150.
Nasledne zadne226 ani ABOR. Cilovy soubor D:/zx/GAUNT3.TAP ma30720 B,
LastWriteTime19:58:01 (15 bloku2048 B); NEBYL menen ani mazan agentem.
Serverovy log neukazuje pricinu zamrznuti na strane Sary/ESP.

Stary upload pouziva upl_old_check_module_answer, kde opakovany prazdny
prijem nebo busy muze cekat bez celkoveho timeoutu. Bez UART/NMI zaznamu
nelze urcit, zda aktualni zamrznuti je zde, pri SEND OK, nebo v ABOR.
Podobny drivejsi problem a referencni zdroj jsou zdokumentovany nize.
V tomto kroku nebyl menen program ani TAPy. Dalsi diagnostika: slibeny USB
odposlech AT/UART komunikace, pripadne NMI PC/SP pri zamrznuti; pak urcit
posledni uspesny prikaz/blok. Indikator poradi nadale pozastaven.
Posledni sestaveni stale obsahuje opravu screenu +15B; bez commitu/pushe.

## Aktualni checkpoint 30. 10. 2026: oprava navratu ze screenu

Uzivatel hlasi po screenu error49 ->21 ->4 a zadal zkontrolovat log.
Precten C:/Program Files (x86)/FileZilla Server/Logs/FileZilla Server.log:
obsah ma dnesni zaznamy, ac soubor ukazuje stary LastWriteTime. Session47,
19:47:23: 2BRSHLP1.SCR SIZE6144, RETR150/226 Transfer OK; potom PWD/NOOP
server stale spravne odpovida. UART dukaz chyby49 zatim nemame.

Ve zdroji screen konec nedocetl226 pred pasivni->aktivni zmenou prijmu.
Oprava: vypnout tisk, docist a overit226, uzavrit datovy kanal1, vypnout
pasivni prijem, teprve pak cekat na klavesu nad obrazkem. UI navrat stejny.
Naklad +15 B pod #C000, banka6 beze zmeny. BSDOS bios_start #A6B8,
konec BIOS #A8D8, volno do #BFE0 5896 B. Oba loadery prelozeny bez
chyb/varovani, HGFX vypnuto. Test screenu 222 kontrol pro kazdou DOS
variantu, souvisejici regrese prosly. Audit tests/screen-download-audit.md.
Dalsi krok: uzivatel nahraje NOVY SARA_LOADER.tap a zopakuje SCR6144/6912,
navrat klavesou a dalsi FTP operaci; overit zmizeni49/21/4 na stroji.

INDIKATOR PORADI JE POZASTAVEN: uzivatel chtel najit stare prubezne
pocitani. Git6.rijna jej neobsahuje, item_counter pridan21.rijna pro
save_dir_position/restore_dir_view, ne pro kazdy pohyb. Rozpracovany
novy indikator odstranen ze zdroju i sestavenych TAPu (nebyl otestovan).
Pripadny dalsi navrh nejprve podle uzivatelova smerovani. Priorita BSDOS,
pak ESXDOS, nakonec HGFX. Bez noveho commitu/pushe; posledni d8356dc.

## Aktualni checkpoint 30. 10. 2026: opraven navrat do rodice (kurzor na konci)

Uzivatel pri testu BSDOS hlasi spatny navrat stranky/kurzoru, vzdy posledni
polozka. Nalezena konkretni pricina: natvrdo IX+41 pro priponu kolidovalo
s hornim bajtem dir_list_pointer (IX+40..41). item_extension je IX+42.
ENTER tak posilal historii z RAM #5F80 do ROM #0A80 u bezneho adresare;
vadne obnovene poradi se pri navratu omezilo na konec seznamu.

Opraveny vsechny 3 pristupy k pripone na IX+item_extension-flag1; komentar
opraven a pridana kontrola rozsahu displacementu. Naklad PRESNE 0 bajtu.
BSDOS bios_start #A6A9, banka6 #B8B, volno pred #BFE0 stale 5911 B.
Oba loadery prelozeny bez chyb/varovani, HGFX vypnuto.

Novy tests/directory_roundtrip.test.js selhal na puvodnim prekladu pri
kontrole neporuseneho ukazatele historie, po oprave 140 kontrol pro kazdou
DOS variantu proslo. Realne ENTER/get_item_name/get_extension/save/pop,
item_add/sub/restore; simulovane FTP, obsah noveho adresare a vykresleni.
Pokryty BREAK i ENTER na '..', chybne CWD a prechod pametove banky.
Prosly i souvisejici regrese, podrobnosti tests/directory-roundtrip-audit.md.

Dalsi krok: uzivatel nahraje NOVY SARA_LOADER.tap a zopakuje pruchod
adresari v BSDOS. Priorita domluvena BSDOS -> ESXDOS -> nakonec HGFX.
Zmeny nadale bez noveho commitu/pushe, posledni vzdaleny d8356dc.

## Aktualni checkpoint 30. 10. 2026: posledni dotaz pro I/FIND

Hotovo na zadani uzivatele: klavesa I predvyplni posledni potvrzeny dotaz.
Prvni hledani je prazdne. Cache 64 B je v programove bance 6, mimo CFG/help
workspace; BREAK nebo prazdny ENTER ji nemeni. Uklada se puvodni velikost
pismen, samotny FIND nadale normalizuje jen INPBUFF. Kratsi novy dotaz ma
terminator na skutecnem konci. Pouziva se existujici input_line_edit.

find_input pod #C000 pristrankuje banku 6 po dobu editoru a ulozeni cache,
pote obnovi puvodni banku a Z/NZ. Nova bankova cast find_input_bank.asm.
Naklad teto zmeny: +19 B pod #C000, +81 B v bance 6 (17 kod, 64 cache).
BSDOS bios_start #A6A9, konec BIOS #A8C9, do #BFE0 volnych 5911 B.
Banka 6 #B8B B, cfg_file_here #CB8B. ESXDOS narust stejne +19/+81.

Oba normalni preklady bez chyb/varovani, HGFX vypnuto, aktualni oba loader
TAPy. Nove testy find_input: 1386 kontrol pro kazdou DOS variantu; prosly
navazujici regrese editoru, adresare, downloadu, FTP ochran, Wi-Fi, TXT,
a BSDOS CFG/profilu/helpu/uploadu/snapshotu. Audit tests/find-input-audit.md.
Dalsi krok: uzivatelsky test I -> dotaz -> I, editace a BREAK na stroji.
Zmeny nadale bez noveho commitu/pushe; posledni vzdaleny d8356dc.

## Aktualni checkpoint 30. 10. 2026: oprava ochran FTP klaves hotova

Uzivatel schvalil opravu s minimalnim narustem; predchozi help ponechat.
Hotovo: sdilene ftp_ready / ftp_item_ready / ftp_control_ready a ochrany
verejnych vstupu U/O/S/D/SS+D/CS+D/R/7/C/ENTER/BREAK/DELETE/6/Z.
Kontroluje se spojeni a CLOSED ridiciho socketu, u polozek platny adresar.
C dovoluje rucni FTP prikazy pri otevrenem TCP spojeni. Pametove operace
nad cachovanym adresarem zustavaji dostupne offline. Klavesa 7 je pred
branou platneho adresare. undraw_cursor bez adresare nesaha na ukazatel.
Podrobnosti a testy: tests/action-guards-audit.md, action_guards.test.js.

Oba normalni preklady bez chyb/varovani, HGFX vypnuto. Regresni testy
sestaveneho Z80 prosly, nove ochrany 1697 kontrol pro kazdou DOS variantu.
Naklad opravy +58 B pod #C000; odstraneni CS+L popisku -3 B, celkem
+55 B proti poslednimu commitu. BSDOS konec BIOS #A8B6, do #BFE0 volnych
5930 B (navic 32 B rezervovano do #C000). Banka 6 stale #B3A B.
Sestaveny SARA_LOADER.tap a SARA_ESX_LOADER.tap jsou aktualni.

Dalsi krok: uzivatel otestuje odpojene/pripojene ovladani na stroji,
zejmena R, downloady, ENTER a mazani. Nelze zatim tvrdit, ze vsechna
pozorovana zamrznuti zmizela. Zmeny jsou BEZ noveho commitu/pushe;
posledni vzdaleny commit d8356dc. Nize je historicky checkpoint auditu.

# Predtestovy checkpoint Wi-Fi — 22. 10. 2026

## Aktualni rozpracovano — 30. 10. 2026: audit klaves a podoba helpu

Uzivatel chce zkontrolovat klavesy a doplnit sara.hlp, radky nejvyse64.
Prohledany key_loop, INKEY tabulky, INPUT, roll, marking, FIND a dialogy.
CS+L nema login akci: INKEY vraci 76 (velke L), main reaguje pouze na
108 (l manualni login) a61 (=, SS+L automaticky). Overeno vykonanim skutecne
INKЕY s modelovanou matici i pro CS+M77, SS+M46, CS+D68.
Opraven zavadejici menu2 popisek Cs/ss+/L-login na ss+/L-login (jen text).
Rozsireny pracovni sara.hlp: samostatne oznacovani/odoznacovani (SPACE
posouva dolu, CS+M vse, SS+M odznacit), FIND nahradi oznaceni shodami,
hromadne D/DELETE, X/Z pro dlouha jmena, INPUT klavesy, CFG a dialogy.
Help ma121 radku, nejdelsi61 znaku, pouze ASCII. ASM funkce se nemenily;
preklad po zmene menu zatim neproveden, dnesni upravy bez commitu/pushe.

POSLEDNI STEERING: uzivatel chce nejprve ukazat podobu sve napovedy na
strance, libi se mu oddeleni ovladani s/bez pripojeni. Cekame na ukazku,
pak podle ni upravit strukturu helpu. Pri deleni respektovat take dostupnost
nacteneho adresare: nektere operace nad nim jsou pouze pametove.
Posledni zaloha dne29 je d8356dc na origin/fix-ftp-directory.

## POTVRZENO UZIVATELEM A PRIPRAVENO KE COMMITU — 29. 10. 2026

Uzivatel vyslovne potvrdil obe posledni funkce: K nacita a zobrazuje mistni
sara.hlp a G -> ENTER provadi pripojeni akci SS+L. Drive potvrdil funkcni
TXT, prijatelnou rychlost po cache optimalizaci a uspesne spusteni TAP.
Skutecny start snapshotu s NMI 1.67 zustava bez vyslovneho potvrzeni.
Potvrzeni funkci samo o sobe neznamena overeni vseho na realnem hardwaru;
realne Wi-Fi casovani a odlozeny upload maji stale drivejsi omezeni.

Na aktualni pokyn se dnesni zdroje, testy, audity, sara.hlp a sestavene
BSDOS/ESXDOS artefakty commituji a pushuji na origin/fix-ftp-directory,
https://github.com/milan-stava/Sarah_128.git. Posledni preklady jsou
bez chyb a varovani, HGFX je vypnute. Presny commit a vysledek pushe
overit v historii Gitu/posledni zprave; starsi zminky 'bez commitu' nize
jsou historicke. Dalsi prace podle novych testu/pozadavku uzivatele;
neopakovat uz potvrzene implementace.

## AKTUALNI: lokalni sara.hlp a SS+L po potvrzeni profilu

Uzivatel potvrdil zrychleni prohlizece jako snesitelne rychle. Dale zadal
mistni napovedu podobne CFG, vse pokud mozno do banky 6; VYSLOVNE nechce
pridavat kontroly delky help souboru a urcil nazev sara.hlp (ne sara.txt).
SARA_HELP.TXT proto prejmenovan na sara.hlp, distribuovat vedle sara.cfg.

Hotovo pro BSDOS: K-Hlp funguje nezavisle na FTP/adresari. Pomoci existujiciho
file_exist/load_init a cfg_read_file.load_body se soubor nacte do cfg_file_here
v bance 6 bez novych kontrol delky. Sdileny prohlizec ma text_local_base;
lokalni text cte primo z banky 6, bez datove cache/prepinani bank. FTP vstup
vzdy resetuje lokalni zdroj, aby dalsi TXT/POK/Z cetlo spravna data.
Pri chybejici napovede hlaska, pak normalni navrat. Help obnovuje rozlozeni
a cachovany adresar bez jakehokoli FTP prikazu i offline. Aktualni FTP cesta
se nevyzaduje pres PWD, misto ni se obnovi nadpis Sary.
Menu ma K-Hlp pri zachovani ostatnich klaves, zkraceno P-pw/S-sz/Q-q.
Napoveda 2220 B, aktualni volna oblast banky 6 zacina #CB3A.

Dalsi potvrzeny pozadavek: po ENTER ve vyberu CFG provest akci SS+L.
Cfg_browser vraci cfg_accepted: 1 jen pro platny ENTER, 0 pro BREAK/missing.
Pevny cfg_choose_profile zachova vysledek pres obnovu banky/UI a pak
CALL NZ,auto_login. Tim se zachovava cele puvodni chovani SS+L vcetne
pripadneho dotazu pri spojeni na jiny server. BREAK nepripojuje.
Vysledna klavesa je spotrebovana, navrat A=0, zasobnik vyvazeny.

Naklad pod #C000: help +30 B vcetne K dispatch/trampoliny, profil SS+L +7 B.
Posledni bios_start #A65F, konec BIOSu #A87F, volno pred #BFE0=5985 B.
Cela banka 6 2874 B; spolecny textovy prohlizec v ni 642 B.
Oproti zacatku dnesni implementace textu je nyni hlavni kod celkem +235 B.
BSDOS/ESXDOS binarky/TAP/symboly/listingy obnoveny: 0 chyb/varovani.
HGFX zustava vypnute.

Testy: lokalni help45 kontrol vcetne offline a skutecnych volani diskoveho
loaderu s modelovanym diskem; cfg_profiles10217, cfg_exit164 (ENTER vola
SS+L jednou, BREAK/missing ne); ostatni BSDOS regrese5564. Textovy prohlizec
336684 kontrol pro BSDOS i ESXDOS, vcetne navratu z lokalniho zdroje na FTP.
Viz tests/local-help-audit.md a tests/text-viewer-audit.md.
Dalsi krok: uzivatel testuje novou SARA_LOADER.tap + mistni sara.hlp (K),
a G/ENTER pripojeni. Fyzicke diskove cteni napovedy a tento novy loginflow
zatim bez uzivatelskeho potvrzeni. Dnesni zmeny stale bez commitu/pushe.

## Posledni zmena: rychlejsi Page Up; TAP start potvrzen uzivatelem

Uzivatel potvrdil TXT funkcni, Page Up ale trval asi sekundu; pozadal
o zrychleni. Behem prace take potvrdil, ze TAP uz se spustila.
Snapshot/NMI start 1.67 zatim v teto casti znovu nepotvrzen.

Novy text_fill nahradil pevny text_byte: nacita zarovnanych 256 B do
existujiciho INPBUFF, ktery po FTP uz nepotrebujeme pro nazev. Dalsi
buffer RAM nepridan; text_get ma 2B tag v bance 6 a cte cache. Pri novem
otevreni souboru se cache zneplatni. Podporuje CRLF/hranice bank/EOF.
Kresleni a zpetny scan bezi na 20 MHz, pred KEYSCAN zpet 3.5 MHz.
Historie stranek stale neni. HGFX se nezapinal.

Mereni sestaveneho Z80 kodu modelem, Page Up u konce 65535B textu:
drive 129108 prepnuti bank/4202370 instrukci, nyni 506/3113303.
Skutecne casovani na stroji nezmereno. Stress test vcetne dokresleni
predchozi obrazovky: 520 prepnuti dlouhe radky, 512 samotne LF.
Testy text_viewer: 336674 kontrol pro BSDOS i ESXDOS, vcetne cache,
zmeny souboru, CPU rychlosti a navigace pres 2700+ obrazovek.
Dalsich 15903 dosavadnich BSDOS regresnich kontrol proslo.
Obe projektove sestavy/TAP/symboly/listingy obnoveny: 0 chyb/varovani.
Pod #C000 za zrychleni +5 B: pevne mosty 195 B, celkovy prirustek
prohlizece proti zacatku implementace 198 B, bios_start #A63A,
volno pred #BFE0 6022 B. Bankovy prohlizec 620 B, cela banka 6 2759 B.
Dalsi krok: uzivatelsky test rychlosti Page Up v SARA_LOADER.tap.
Dnesni zmeny stale bez commitu/pushe, vcerejsi zaloha je 7818893.

## Posledni oprava z testu TXT: TYPE I prepisoval nazev pred SIZE

Uzivatel hlasil 2x 200 switching to binary a pak 550 could not get file size.
Pricina prokazana regresnim testem: send_type_command_i vola clear_inp_buf
a zapisuje "I" do INPBUFF, takze pri volani z text_viewer_control uz zrusil
pripraveny nazev. Server dostaval SIZE I (buffer nasledne trimovan prikazem).
Oprava: Z vstup view_as_text posila TYPE I PRED ziskanim/kopii nazvu;
ENTER TXT/POK jde na view_as_text.ready, protoze enter_directory uz TYPE I
poslal. V bankove text_viewer_control uz TYPE I neni. Kazdy vstup tak
posila TYPE jen jednou a SIZE dostane puvodni jmeno.
Novy regresni test pousti skutecnou rutinu TYPE (vcetne clear_inp_buf)
a zachytava nazev pri SIZE pro ENTER i Z. Pred opravou test selhal,
po oprave proslo 333876 kontrol pro BSDOS i ESXDOS (drivejsi dve dlouhe
navigacni stress smycky nebyly opakovany, ostatni sada ano).
BSDOS a ESXDOS projektove TAP/bin/symboly/listingy obnoveny bez chyb/varovani.
Pod #C000 +3 B za opravu: nyni celkem +193 B proti zacatku implementace,
bios_start=#A635, konec BIOSu=#A855, volno pred #BFE0=6027 B.
HGFX zustava vypnute. Dalsi krok: znovu testovat ENTER na TXT/POK a Z na CFG.

## Posledni opravy: NMI >=1.65 a rychlost extrakce TAP

Uzivatel testuje NMI 1.67; puvodni kontrola vyzadovala presne slovo #B536
(text 65 s inverznim poslednim znakem), proto 67 odmitla.
Work_snap nyni u obou cislic VER na #26D2/#26D3 odmaskuje bit 7,
overi ASCII cislice, spocita desitky*10+jednotky a prijme hodnotu >=65.
Podporovany rozsah teto dvouciselne kontroly je 1.65..1.99, ne obecne major2.
Vstupni adresy do NMI zustaly podle uzivatelova kodu #5AA0/#57E2/#11DD.
Nova tests/snapshot_entry.test.js: 214 pripadu, 712 kontrol (00..99,
normalni/inverzni posledni cifra, neplatne znaky, predani cisla a SP).

TAPmaster START jiz nastavoval 20 MHz. Na zadost uzivatele explicitne
pridan CALL set_3_5mhz do run1 pred predanim do ROM/loaderu. Nret navic
ponechava sve drivejsi nastaveni 3.5 MHz. Checksum varovani stale pokracuje.
Test tap_handoff nyni 1071 kontrol vcetne 20MHz startu a poradi navratu na
3.5 MHz pred ROM/loaderem. Tapmaster 977 B, banka 6 2716 B.
Aktualni BSDOS binarky/TAP/symboly/listing obnoveny: 0 chyb a varovani.
Hlavni kod pod #C000 beze zmeny, HGFX v beznem sestaveni vypnute.
Dalsi krok: znovu testovat SARA_LOADER.tap na uzivatelove NMI 1.67,
a rozbaleni TAP s checksum varovanim a naslednym startem na 3.5 MHz.

## Posledni oprava po uzivatelskem testu: checksum TAP je pouze varovani

Uzivatel upresnil, ze pri 'Checksum error' se MA pokracovat v extrakci.
Predchozi Codexem vlozeny RST 0 zpusoboval odchod (na stroji do NMI menu).
Evaluate_crc nyni po priprave hlasky konci JP bsdos_tm: zprava a navrat
volajicimu, bez resetu; dale se rozbaluje a normalne spousti podle toku kodu.
Sestaveni BSDOS vcetne SARA_LOADER.tap, binarky, symbolu/listingu obnoveno:
0 chyb/varovani. Test tap_handoff ma nyni 1070 kontrol vcetne shodneho
i neshodneho checksumu, navratu a vyvazeneho zasobniku. Tapmaster 974 B,
banka 6 2691 B; prostor pod #C000 beze zmeny (prirustek vieweru stale190 B).
HGFX se nezapina; bezna projektova TAP je klasicka ZX verze.
Starsim tvrzenim o fatalni chybe checksumu nize predchazi tato domluva.

## AKTUALNI: RAM prohlizec TXT/POK a libovolnych souboru

Uzivatel autorizoval implementaci s prioritou co nejmensiho kodu pod #C000.
Hotovo: ENTER na TXT/POK a klavesa Z pouzivaji view_as_text. V zustava save_app
(uzivatel vyslovne opravil docasny navrh V-Txt; zadne premapovani neprobehlo).
Menu je zkracene na 42 znaku vcetne Z-Txt, pridany ASSERT proti preteceni.
Ovladani prohlizece: vlevo predchozi obrazovka, vpravo dalsi, BREAK navrat;
pri odchodu ceka na uvolneni BREAK, aby se neprovedl nasledny parent dir.

text_viewer_bank.asm ma vetsinu kodu a vsechen stav v bance 6 (577 B).
text_viewer_io.asm ma mosty ve stabilni RAM (187 B): validace/kopie nazvu,
navrat do UI, mapovani dat, cteni bajtu a blokovy prijem bez disku.
Kazdy bajt pro scanner prepne datovou banku a zpet na 6; uzivatel to prijal.
Prijem pouziva cele bloky, omezene hranici banky. Zadne ukladani na disk,
buffer cele obrazovky ani historie stranek. Page Up pocita od zacatku
stejnym pruchodem bez kresleni. CRLF/CR/LF, TAB=mezera, ostatni netisknutelne
bajty=tecka. Aktualni ZX/HGFX rozmery jsou 64x24, HGFX bere max_chars/max_lines.
Budouci HGFX 512x384 vyzaduje upravu celkoveho GUI; zatim se nezavadelo.

Data jsou v bankach 4,0,1,3. Do #4000 vcetne zustane cely adresar zachovan;
pred prvnim zapisem do dalsi banky se zrusi validita adresare. Po navratu
se zachovany adresar prekresli z RAM, jinak znovu stahne. Plati i pro abort.
Velke soubory maji varovani a limit #FFFF bajtu, pak vracejici ABOR/NOOP
barieru (nova sdilena ftp_abort_transfer) pro korektni dokonceni protokolu.
Stary ftp_abort_download nadale provadi sve puvodni UI a reset zasobniku.
Mazani souboru a jinych diskovych rutin se prohlizec nedotyka.

Presne mereni proti stavu uzivatelovych vstupu pred implementaci:
bios_start #A574 -> #A632, cisty prirustek POD #C000 = 190 B.
Konec BIOSu #A852, volno pred #BFE0 = 6030 B; cela banka 6 = 2692 B.
Proti vcerejsimu commitu 7818893 je prirustek hlavniho kodu 205 B,
protoze uzivatelovy dnesni vstupy uz pred implementaci pridaly 15 B.

BS-DOS/ESXDOS/HGFX sestaveni 0 chyb a 0 varovani. Aktualni projektove
BSDOS/ESXDOS binarky/TAP/listingy/symboly obnoveny, HGFX kontrola pouze TEMP.
Pro BS-DOS testovat SARA_LOADER.tap. ESXDOS novy kod take potrebuje banku 6:
pridan kombinovany SARA_ESX_LOADER.tap. Stary SARAH12ESX.tap je pouze hlavni
blok a sam neni kompletnim dvoubankovym sestavenim.
Pridan ASCII SARA_HELP.TXT vedle sara.cfg, oba distribuovat se Sarou 128.
Nahrat TXT na FTP pro zobrazeni ENTER/Z; lokalni diskove cteni TXT neni.

Testy sestaveneho kodu: tests/text_viewer.test.js 333874 kontrol pro KAZDOU
ze tri variant, vcetne 65535 LF (>2700 obrazovek), dlouhych radku, hranic
bank, zkraceni 702026B souboru, castecnych/prazdnych ramcu a navratu pri
abortu/chybe. Dalsich 15903 dosavadnich BSDOS regresnich kontrol proslo.
Testy bezi CPU modelem ve V8 (Node neni v PATH), FTP/BIOS/kresleni simulovane.
Podrobnosti a Node prikazy viz tests/text-viewer-audit.md.
STALE CHYBI realne Wi-Fi, emulatorovy/hardwarovy vzhled a rychlost Page Up,
a drive odlozene skutecne spousteni TAP/snapshotu. Dalsi krok: uzivatelsky
test nove SARA_LOADER.tap. Dnesni zmeny zatim NEcommitovany ani pushnuty.
Vcerejsi checkpoint 7818893 je lokalne i na origin/fix-ftp-directory.
Starsim protichudnym checkpointum nize predchazi tento aktualni stav.

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
