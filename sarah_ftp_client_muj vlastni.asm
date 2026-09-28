;jako 1.2, ale pridavame HGFX 512x192, vydavam jen pro BSDOS. Dalsi verze budou muset byt pro 128K, protoze uz neni misto.

;kde se co maze pomoci HL?
;DONE	CLS_4000 je v print whole screen
;DONE	WIND_CLS je jen ve speed_management
;DONE	CLEAR_EDIT_ZONE 16x
;DONE	CLS_9 vícekrát
;DONE	CLS_9_lines



;verze 1.2 stejna jako 1.1, ale davame novy wifi bios 2.0, a budou jen 2 verze:
;pro BSDOS a pro ESXDOS. Pokud je MB wifi, pusti se ta, pokud ne, pak el wifi
;opravy:
;DONE- bugfix: ESXDOS- interpretace nazvu souboru pro esxdos vylepsena. Drive byly problemy s priponou mensi nez 3 znaky, nebo s teckami v nazvu, nyni opraveno
;DONE- bugfix: BSDOS- upload souboru s 10 znakovym nazvem selhal
;DONE- funguje i s ftp servery vyzadujici presnou delku ftp prikazu
;DONE- new: hides password during typing


;verze 1.1 je stejná jako 1.0, jen vkladame novy bios 1.9 a budou celkem 4 verze:
;1) MB03+ BSDOS (MBBSD)		... pro wifi modul v MB03+
;2) MB03+ ESXDOS (MBESX)	... pro wifi modul v MB03+
;3) EL+ BSDOS (ELBSD)		... pro wifi modul v el
;4) EL+ ESXDOS (ELESX)		... pro wifi modul v el
;bugfix: speed managemenet call earlier (caused endless loop if wifi was off)


;jako 0.99, ale ošetøení stavu rutin?
;koncept, kdy se vracim na misto odkus jsem vysel relizovan jen pri vyskoku z adresare na 1 urovni. Ostatni navraty (jako pri downloadu, uploadu, apod.) udelat v pristi verzi, pripadne
;99-8-pridavame vyskok do nadadresare na stejnou polozku, jako byla pri vnoreni do podadresare
;err34- se take vraci, pokud po dr end ok, kdyz cteme zda byl transfer uplny. Proste na sluzbe askfor replyinpassive mode jsem vzdy moc brzo a ona nestaci nacist obsah
;na sarah, pismeno games-wos/c je problem, prepisuje kod!!! presneji receno, pokud je transfer incomplete- vyreseno, musi se udelat vzdy cipclose kanalu 1
;chyba 34- v odpovedi na LIST casto jsme tam moc dopredu, musime si pockat az modul vrati vsechny picoviny typu IPD a teprve pote nam vrati hledany retezec CIPRECVDATA:. Zkusit zvetsit timeout ze 4 na vic
;err34-opravit check module answer, cte uz moc dopredu a pri LISTu nacita adresar!!!
;upravujeme check_module_answer
;chyba 35= nejsme prepnuti v ciprecmodu 0!!!!, na ciprecvmode=0 je odpoved OK, tu musime mit abychom jeli dal
;na cIPRECVDATA=0,128 odpovi #D#AOK#D#A pokud nejsou zadna data k dispozici
;do send ftp status dopsat detekci pripojeni ke kanalu 1?? zatim asi ne.
;oprava INPUTU pøi deletu to padá
;DONE zobrazeni screenu
;DONE cost only 8 bytes!!, pocet adresaru 16 bitove
;DONE toto bohuzel nejde. Server neposila zadne ukonceni adresare. Za posledni polozkou je #D#A jako z akazdou jinou. Ukonceni cteni adresare, pokud prijdou 2xDA za sebou (problem, pokud je adresar prazdny, tak i prichozi adredarova data jsou nulova/zadna!!)

;send_ftp_command
;DONE...adding TYPE command (A for directory), I for file transfer.
;DONE...adding un/mark all (SS/CS+M)
;in process adding Esxdos disk operation

;v0.99
;cleaning up the code
;adding: variable ftp port, eg. for mobile ftp servers (eg. 192.168.0.200:31456)

;v0.98
;multiple download

;v0.97
;DONE...	delete marked

;v0.96		adding:
;DONE...	file mark	
;DONE...	file search
;in097		delete marked
;DONE...	opravit-neumi hledat jediny znak (viz rutina 12, vysvetleno)

;v0.95		see ASM in 0.95
;v0.94
;opraveno	sif.speccy.cz. sinclair pismeno W, spatne pocita zarazku
;opraveno	pg_updown, a nacitani zkracenych polozek a NLST sif.specc.cz, wos/sinclair/games/s
;opraveno	pri LIST abbr se naktere polozky adresare spatne zobrazovaly, nyni ok
;v0.93		u stazeni adresare kontrolujeme odezvu modulu po prijeti dat (tzn. OK, IPD atd.)
;v0.92		hodne vyladeno chyb v nove napsanem kodu

;v0.91
todo:
;DONE...	proverit: podle me by pri abortu melo být 1x POP, download file i callujeme!!!
;DONE...	opravit: page up/down, kdyz dojedu na konec stranky, kurzor ma zmatek
;DONE...	opravit: nacitani zkracenych polozek!!! nacte blbosti mezi polozkami (resil jsem na Schlimeischi 2022)
;opravit: chyby 26 pri downloadu obcas
;DONE...	opravit: sif.speccy.cz, wos/sinclair/games/s... tuhne.......
;DONE...  	opravit pri NLST se spatne uzavre posledni polozka
;DONE...	proverit. testovat: operace, kdyz stojim na polozce ".." v adresari
;DONE...	pridat: dopsat do obrazovky nové klavesy
;DONE... 	hromadne oznacovani souboru a jejich download (zatim bez adresaru). Pridano na pul, ale se spolecnou pameti pro stahovani dat a adresar nelze dost dobre realizovat
;DONE...	pridat: abort pri stazeni adresare (pokracuju normalne, pokud mam v pameti aspon jednu polozku)
;DONE...	pridat: roll item >64 chars
;DONE...	pridat: moznost zadavat prikazy rucne
;DONE...	udelat Reread adresare
;DONE...	(viz0.96)pridat: pres klavesu Ext: hledat dle zadani klaves (pr. zmacknu "s" a najde to prvni polozku zacinajici na "s")
;pridat: nacitat nejdriv adresare a ve druhem cteni pak soubory




;DONE... make dir/ delete dir
;DONE... delete file
;DONE... rename file
;DONE... adding file and dir/ items counting
;DONE... get_file_name- to return also file length
;opraveno: po ABORTu transferu mazou klavesy nahoru dolu obrazovku a neco je asi se zasobnikem, proverit: opravil jsem. 


;v0.9
;speeding up directory read
;further keys:
;N=	toggle LIST/NLST
;SS+N=	toggle full/abbr
;BREAK	go to updir
;"7"	create dir
;delete	delete dir/file/item
;"6"	rename
;
;CS+D
;C	enter command

;OK... added STOU pri uploadu
;OK... oprava key down- print page nulujeA= zadny nechteny stisk klavesy



;v0.8
;adding dir browsing support. Buffer for dir will be from basic_end (#6000) till start_address (#C7FF)= #6800=26624 bytes for first version. In next versions I will start using MB03+ SRAM pages for better comfort.
;odpovida take kodem 150 a 226
;stahnout data jen velikosgti 2048 a vzdy jen na zacatku


;v0.7 release

;v0.6
;done...ABORT pri username a password znamena, vyskok do key_loop? Mel by, protoze pri blbem pass, nebo jak ho neznam, tak to chce porad heslo nebo usera, nejde z toho vyskocit. (change_host, ftp_upload_file, set_filename, set_start, set_user, send_ftp_command))
;done...zobrazit heslo jako XXXXX, kdyz bude uzivatel chtit
;done...zablokovat vsechny pokusy o posilani prikazu serveru, pokud nejsme pripojeni (size, logoff, upload, 2x download)
;done...kazdou minut poslat NOOP cist primo z RTC?

;nemuzu upload dostat na vic nez 3,5Mhz, proc?????? viz rutina pro ftp_upload. I po vyzkouseni send_block se jednak rychlost nezvedla, ale prenos byl nespolehlivy


;done...u loginu a auto loginu zjistit na zacatku, zda jsme pripojeni ke stejne URL, pokud se lisi, pak pokracovat, pokud jsou stejne, pak key_loop
;done...misto c. chyby vypsat hlaseni, ze nenasel url
;done...zprovoznit na rychlosti 16, a taky 7, 14 a 20 MHz!!! (pouze download, upload proste nejede na >3,5Mhz)
;done...pri opusteni programu prepnout na rychlost 7?
;done...pri uploadu, downloadu, stazeni adresare vykotlit rychlost


;dodelat volbu:
;done...F
;done...T
;done...A
;done...R
;done...P
;done...ss+L
;done...ss+D
;done...vypsat øádky 17 a 18

;done...turnoff printing of sending AT commands to module
;done...save application with its settings
;done...when entering empty input line, the program crashes
;at new URL login, ask message if current connection should be turned down
;done...known bugs: pri chybe 425 Can't open data connection pri downloadu zustane program v CIPRECVMODE=1;do downloadu doplnit pri chybach vypnuti passive modu


;done...ftp messages scroll up (in v 0.5. were down)
;done...ACTFORCE2_KM_48_128.TAP se spatne stahuje
;done....pri abortu se nevypisuje 226 ABOR command sucessful
;done...asci okpri uploadu. error 12!!!
;done...pri uploadu a abortu to vypisuje, ze prikaz abort nebyl uspesny, chyba 16



;todo:
;done...cykleni pri loginu odstraneno
;done...*v tiskove rutine premenit kody #D,#A na odradkovani
;done...*tisknout jen hlaseni FTP (nikoliv cely obsah RXbufferu)
;*udelat do dalsi verze-v uploadu- zkusit vynechat cekani na odpovedi,treba se upload dat zrychli


;otestovat ABORT pri uploadu i downloadu
;kod 226 po downloadu i uploadu??? otazka jako to otestovat, když vždy to dopadlo dobøe....

/*pokud selže login.....
(000005)14.9.2022 3:16:50 - (not logged in) (192.168.0.110)> USER hoodjkjk
(000005)14.9.2022 3:16:50 - (not logged in) (192.168.0.110)> 331 Password required for hoodjkjk
(000005)14.9.2022 3:16:59 - (not logged in) (192.168.0.110)> PASS *******
(000005)14.9.2022 3:16:59 - (not logged in) (192.168.0.110)> 530 Login or password incorrect!
(000005)14.9.2022 3:17:00 - (not logged in) (192.168.0.110)> NOOP 
(000005)14.9.2022 3:17:00 - (not logged in) (192.168.0.110)> 530 Please log in with USER and PASS first.
(000005)14.9.2022 3:17:28 - (not logged in) (192.168.0.110)> 421 Login time exceeded. Closing control connection.
(000005)14.9.2022 3:17:28 - (not logged in) (192.168.0.110)> disconnected.*/

;v0.5.
;opravujeme chybu 0.4 v downloadu, kdy se nekdy neplni buffer do plna.

;v0.4.
;precizujeme download, stale pouzivame passivni mod prenosu (AT+CIPRECVMODE=1), ale necekame, az bude alespon 2048 bajtu,
;ale bereme cokoliv. Pouze, pokud je bajtu 0, cekame, az se nejake do bufferu modulu nactou. Snad se cely proces ;downloadu zrychli.
;super, funguje to. Rychlosti downloadu:
;pri 7= 	6,8 kb/sec	1x
;pri 12=	14,1 kb/sec	10x
;pri 16=	15,2 kb/sec	30x



;v0.3
;new concept of download: using passive transfer mode
;the principle: AT+CIPRECVMODE=1 enables to wait for incoming data and ask for them whenever we like.
;response to AT commands works normally
;8:04 12.08.2022 we leave this one. Problem: this ver is waiting until at least 2048 bytes is in module memory. But if ;this condition should be met, then it lasts forever. 16kb transfer lasts 18 secs!!!!
;ver0.4. will use passive receibe mode too, but will fetch any data immediatelly. Hopefully, this will speed up whole ;download.

;v0.2- working on download
;closed for now: continuous flow of data is quite hard to handle
;going to ver0.3: I will realise passive transfer mode during download


;v0.1-closed
;otestovat doma:
;done	udelat moznost ABORT v prubehu uploadu
;done, ale vyprecizovat!!!!!!	pred AT+CIPMUX se podivat, jestli uz neni vykonano, jinak haze error 3
;pokud je pripojeno k ftp, pak na dotaz AT+CIPSTATUS vraci: "STATUS:3<cr>+CIPSTATUS:0,"TCP","192.168.0.113",21,port, atd" a soucasne na dotaz AT+CIPMUX=1 vraci "link is builded"..>tzn jsme jiz pripojeni k FTP serveru
;tzn. ukol= prepracovat rutinu get_status, aby zjistila, zda jsem pripojen k ftp (musí být status 3, url adresa a port 21). Pokud ano, pak vypsat URL serveru a zkusit NOOP. Pokud ne, pak jet pres CIPMUX=1 klasicky.
;statusy 2,4 a 5 znamenaji zadne pøipojení k ftp. Pouze status 3= pripojeno.
;done	proc se pri erroru vraci error handler na zacatek (na adresu #C800)???- u/opraveno, error handler se vraci na adresu error_handler_loop
;done	rychlost 12 opravit, aby jel pri ni i HTTP downloader- problem nalezen. FTP nastavuje CIPMUX=1, kdezto downloader ma CIPMUX=0. Proto haze error. Pri vyskoku z ftp nelze nastavit CIPMUX na 0, protoze jsme pripojeni k serveru. Cili, toto si musi osetrit kazda aplikace.


;done	quit- do BASICu, prace se zasobnikem
;done	implementovat prikaz ABOR, pokud upload, download selze, abychom se mohli vratit (server vraci:
	;(000019)18.7.2022 5:34:35 - hood (192.168.0.113)> ABOR
	;(000019)18.7.2022 5:34:35 - hood (192.168.0.113)> 426 Connection closed; transfer aborted.
	;(000019)18.7.2022 5:34:35 - hood (192.168.0.113)> 226 ABOR command successful
;done	prepsani souboru pri uploadu- prikaz APPE (reseni: pred uploadem hodit dotaz SIZE a pokud server vrati: 550 File not found, pak
	;muzeme uploadovat. Pokud vrati 213, soubor existuje. 150 conneection accepted, 
	;uspech uploadu:
	;(000010)16.7.2022 5:37:54 - hood (192.168.0.110)> 150 Connection accepted
	;(000010)16.7.2022 5:38:07 - hood (192.168.0.110)> 226 Transfer OK


	;(000021)18.7.2022 5:44:41 - hood (192.168.0.113)> 227 Entering Passive Mode (192,168,0,103,213,139)
	;(000021)18.7.2022 5:44:44 - hood (192.168.0.113)> APPE 16kb
	;(000021)18.7.2022 5:44:44 - hood (192.168.0.113)> 150 Connection accepted, restarting at offset 16384
;done	do uploadu dát kontrolu odpovìdí FTPka
;done	pridat volbu URL!!!

;info- test rychlosti uploadu: prakticky totozneho casu bylo dosazeno pri zakladni rychlosti CPU 3,5MHz a 4x nasobne rychlosti 14MHz. Server je nastaven na max. Takze to brzdi modul. Mohli bychom zkusit jiny mod prenosu pomoci AT prikazu, ale az nakonec, az bude i download pripadne prace s adresarem.



;ZX FTP client for MB03+
;Hood

;- ver 0.1	- login to ftp server (login+ pasword), done
;		- find out file size, done
;		- quit ftp connection, done
;		- download file, in process
;		- upload file, done

;	output "zx_ftp_client"

;set C=		SCF
;set NC=	AND A, if Z needs to be preserved, then SCF:CCF



;FTP commands of interest:
;done	USER		username
;done	PASS		password
;done	PASV		enter passive mode
;done	QUIT		quit ftp connection
;done	STOR		upload file		;max transfer block allowed by ESP modele= 2048 bytes, top speed is 2,53 kb/sec
;done	RETR		download file
;done	SIZE		return file size
;done	ABOR		abort command		;in case we got stuck, ABOR will return us
;done	APPE		append file		;if uploaded file exist, you may choose to overwrite it or append
;done	NOOP					;check if ftp connection is alive (ver 0.7.)
;done	STOU					;new from 0.8 up
;done	LIST
;done	NLST
;done	PWD
;done	CWD
;done	CDUP
;done	DELE
;done	MKD
;done	RMD
;done	RNFR+RNTO

;the following need passive mode:
;	RETR		download file
;	STOR		upload file
;	STOU		like STOR, but a new file is set
;	LIST		download directory list
;	NLST argument	list of directory "argument" and file names (without attributes)

;the following do not need passive mode:
;	MKD argument	make new directory called "argument"
;	RMD argument	remove directory called "argument"
;	RNFR+RNTO	rename file
;	SIZE		find out file length
;	QUIT		quits ftp connection
;	PWD		returns current directory name
;	CWD argument	go to directory "argument"
;	CDUP		go to up directory
;	DELE argument	delete file "argument"

;overview:
;LOW LEVEL- SENDING
;1) send_string:	mainly to send direct AT commands
;2) send_data:		to send any type of data
;LOW LEVEL- RECEIVING
;7) receive_data_timeout receive data with timeout.IN=BC=max.length of data to receive, HL=sata start, OUT Z= ok, received
;LOW LEVEL- PARSING
;10) look_for_string:	seeks certain string in memory
;11) look_on_fly:	seeks certain string in the incoming flow of bytes
;12) search_by_Busy	seeks string in memory, according to Busy (in BSDOS)
;13) search_until_zero

;OTHERS
;15) count_com_len	counts command length
;16) ConvRStr16		converts ASCII to HL (16 bit)
;17) HL2ASCII		converts HL to ASCII (16 bit)
;18) wait routines	wait certain amount of time (user definable)
;19) print_title	printle initial title
;20) save_dir_position	saves dir position so that you can return to where you have been
;22) ConvrStr32		converts ASCII to HLDE (32 bit)
;28) HL2ASCII32		converts HL to ASCII (32 bit)
;29) send_at_check_ok	sends AT command and checks for answer OK
;40) set_print_speed	sets speed on MB UART and print it
;48) convASCII2hex	convert eg. "14" to #14
;49) cls_4000		clear screen
;50) cls_9		clear 9 lines
;;;;51) prn_ap_name_sig	print AP name and signal strength, not used!!!!!

;53) set_def_wifi_speed	sets both speeds to default wifi speed
;54) clear_edit_zone	clears 2 bottom lines
;55) akey		waits for key press
;56) wifi_wait/unwait	signals, that we wait for wifi
;57) set_ud_speed	sets user defined speed (0-23 from IX+2), mainly for SM2.0


;FTP RELATED
;52) get_status_ftp	gets status, if connected to ftp server or not
;58) send_abort		sends ABORt command
;58) send_ftp_command	sends any ftp command placed in HL
;59) cipsend_request	sends data to server, command eg. "AT+CIPSEND=0,6"
;60) check_module_answercheck if module answers string in DE
;61) receive_ftp_answer
;65) enter_pasive_mode
;73) print_ftp_status	prints status of URL and login
;74) send_noop		send "noop" command
;75) print_url		prints selected url
;76) print_transfer_status print Transfer OK, or error, or aborted
;77) passive_receive_offturn off passive recieve mode
;78) print_ftp_message	prints ftp message on the screen
;79) connect_to_ftp_server
;80) test_ftp_connectionfor login and auto login purposes



;62) clears RX and TX buffers, or only one of them
;63) error_handler	universal routine to deal with errors
;64) cipstart_connect	sends command like: "AT+CIPSTART=1,"TCP","h1,h2,h3,h4",port"
;66) input_line		inputs line for user to enter anything
;68) cipsend_lod	sends purely AT+CIPSEND=1,data length
;69) display_progress	prints length of file each time file is loaded/saved
;70) look_for_ipd	looks for IPDs in the incoming bytes
;81) set_3_5mhz
;82) set_23:16 25.09.2026
;83) send_ftp_command_in_pasive_mode	used in download file and retrieve dir list
;84) data_available_in_module			;find out, if module has available data,
;85) ask_for_data_in_passive_mode		;send "AT+CIPRECVDATA=1,2048" in passive receive mode
;86) ask_for_reply_in_passive_mode		;send "AT+CIPRECVDATA=1,128" in pasive receive mode
;87) passive_receive_on	;trun on passive receive mode
;88) print_working_directory
;89) get_item_name	;get item name under cursor
;90) print_dir_files_items; prints number of files and dirs
;91) search_marked_items;go through directory and search for marked items
;92) un_mark_all	;mark or unmark all items
;93) send_type_command
;94) print_whole_screen	;prints screen at the start or after .screen files displayed
;95) set_fdma_to_chars	;sets fdma, so that it can print chars
;96) set_fdma_to_fill	;

;	DEFINE border_colour	;0=no colours,1=show border colours, yellow for disk operations,
				;violet= communication with module

;	DEFINE hgfx64x24	;nejprve klasickou verzi

/*podoba screenu
0	nadpis
1	nadpis
2	Speed: max   Logged in: ok  Status: 3
3	Host: hood.speccy.cz123456789012345678901234567890123456789012	
4	\
5	> navratove zpravy z ftp serveru
6	/
7
8
9
10
11
12
13
14
15
16
17	file:0123456789                         start: 49152
18	host: 192.168.0.103        user: hood     pass: test
19	F-file T-start A-YES H-host R-usr ss+/P-pass U-upl S-size Q-quit 
20	W-wifi OFF ss+/L-auto/login O-logoff V-save app ss+/D-dwnld/file 
22	input txt/action (napø. Downloading file)......     Progress: xy
23	input					  error= ..press a key..	
*/

;text address on the screen
txt_adr_cwd		equ #0000
txt_adr_header		equ #0005
txt_adr_header_line	equ #0105
txt_adr_speed_login	equ #0200
txt_adr_host		equ #0300
txt_adr_ftp_reports_trg_hgfx	equ #0020	;HGFX values, line 4= #0400, hgfx64x24, target ftp report line for scroll/ldir
txt_adr_ftp_reports_src_hgfx	equ #0028	;HGFX values, line 5= #0500, hgfx64x24, source ftp report line for scroll/ldir
txt_adr_ftp_reports	equ #0600
txt_adr_mezera		equ #0700
txt_adr_dir_display	equ #0800
txt_adr_dir_display_vram	equ #4800	;for purposes of ldiring ftp files to download list
txt_adr_module_send	equ #0800	;exist in code but disabled
txt_adr_dir_info	equ #1000
txt_adr_file		equ #1100
txt_adr_hostvar		equ #1200
txt_adr_menu1		equ #1300
txt_adr_menu2		equ #1400
txt_adr_meziradek	equ #1500
txt_adr_edit_zone1	equ #1600
txt_adr_progress	equ txt_adr_edit_zone1+40
txt_adr_edit_zone2	equ #1700


	
main_port	equ #203B
wifi_port	equ #213b
basic_end	equ #6000
terminal_start	equ 30000
start_address	equ #6000
stack		equ start_address
;AP_list_start	equ terminal_start+terminal_len	;start of AP list in the memory goes right after terminal
upload_length	equ #800	;serves for upload routine (#800 is max, #400 work also)
download_length	equ #800
line_length	equ #40		;length of line (for standart ZX=#40, for hires= different)
ftp_dir_start	equ #C000

	IFDEF hgfx64x24
;HGFX pro zapis FDMA
mark_cursor	equ	#FFC0
unmark_cursor	equ	#FF80
mark_no_cursor	equ	#0071
unmark_no_curs	equ	#00c0
mark_item_i	equ	#FF47
unmark_item_i	equ	#0046

;HGFX values.....pro zapis pres charout
;definuje se jen znak a barva (planar bude zvlast)
;mark_cursor	equ	#80C0
;unmark_cursor	equ	#8080
;mark_no_cursor	equ	#2071
;unmark_no_curs	equ	#20c0
;mark_item_i	equ	#8071
;unmark_item_i	equ	#2070
	ELSE
;standart ZX VRAM
mark_cursor	equ 58		;marked item with cursor
mark_no_cursor	equ 2		;marked item without cursor
unmark_cursor	equ 56		;not marked item with cursor
unmark_no_curs	equ 7		;not marked item without cursor
	ENDIF

;bios		equ	#FD00
bios		equ	bios_start
gver_inst	equ	bios+0
wifi_on		equ	bios+4
wifi_off	equ	bios+6
set_baud	equ	bios+8
get_baud	equ	bios+10
clear_rece_buf	equ	bios+12
rece_byte	equ	bios+16
send_byte	equ	bios+18
rece_block	equ	bios+20
send_block	equ	bios+22


port_select	equ	#703B

;bs_dos		equ	0	;1=compile for BS DOS, 0= compile for Esxdos<--- defined in upper .ASM file


;Error reports
	;1=sending string error (cipsend_request routine)			...OK
	;2=error sending CWMODE AT commad					...OK
	;3=error sending CIPMUX AT command					...OK
	;7=error sending CIPCLOSE AT command (ftp upload)			...OK


	;8= module did not return SEND OK after data block sending (ftp_upl_send)..OK
	;9= error in entering passive mode (enter_passive_mode)			...OK
	;14=file not exist							...OK
	;15=disk error								...OK
	;25= module not connected to AP, the user has to set his module externally.OK

;ftp	;4= ftp answer, requested ftp code not found				...OK
	;old,not valid;4= check_module_answer routine did not found the answer from DE	...OK
	;5= uploaded data not sent correctly (ftp_upl_send)			...OK
	;6= cipsend_lod routine error. Module not ready to send data for upload	...OK
	;10= error in connecting to ftp server (ftp_login)(probably wrong URL)	...OK
	;11= error in receiving ftp answer to AT+CIPSEND "<" (receive_ftp_answer)..OK
	;12= "+IPD," string not found in the incoming bytes (look_for_ipd)	...OK
	;13= FTP server did not confirm answer 225 on download attempt (ftp_download_file, or retrieve directory...OK
	;16= ABOR command not successful					...OK
	;17= upload: connection not accepted (code 150 not received)		...OK
	;18= upload: transfer not ok (code 226 not accepted)			...OK
	;19= initial check. Connected to server, not good answer to NOOP cmnd	...OK
	;20= ABOR command initiated by the user					...OK
	;21= download: files does not exist					...OK
	;22= file does not exist on ftp server					...OK
	;23= download: block of data receive error				...OK
	;24= server did not respond with "226 Transfer OK"			...OK
	;26= no data available in passive receive mode (routine 84)		...OK
	;27= command for create dir not accepted (create dir)

	;28=speed management: AT command not accepted						... present in the code but not used
	;29=speed management: all speeds tested, timeout, fix it in terminal-add it in the next ver... present in the code but not used
	;30=speed management: failed, probably Wifi module wrongly set,fix in terminal-add it in the next ver... present in the code but not used
	;31=user defined speed_ AT+UART_CUR command not sent			...???
	;32=user defined routine_ speed in UART not set				...???
	;33=user defined speed_ you try to set nonsence speed (ie. > 23)	...???
	;34= dir retrieve error
	;35= (look_for_ipd) 2nd error
	;36= error in receive_ftp_answer
	;37= send_ftp_command_in_passive_mode
	;38= error sending TYPE command
	;39= error in sending AT+CIPRECVMODE=0(1), (passive_receive_switch)	...OK
	;40= error in sending command in ftp_quit_connectio			...OK
	;41= error in sending command in enter_passive_mode			...OK
	;42= error in sending command in send_noop				...OK
	;43= channel to sclosed sucessfully					...OK

		org start_address

start_ldir	di

		ld	sp,basic_end
		ld	hl,error_handler_loop	;HL= address, where error handler jumps after an error occurs
		push	hl

code_		call	bios			;BIOS already in place (bios == bios_start)

	IFDEF hgfx64x24
	include	"hgfx.asm"
	include "regs_hgfx.asm"
hgfx_continue	call	fDMA.Init
	endif

;hgfx_continue
		ld	ix,flag1

		ld	a,e			;find out which wifi is running and write it to the headings
		or	a
		ld	a,"M"
		set	2,(ix+3)		;set flag, we are on MB wifi
       		jr	nz,s_ldir

		res	2,(ix+3)		;res flag, we are on el wifi
		ld	a,"E"
s_ldir		ld	(wifi_type),a

		xor	a
		out	(254),a

		ld	bc,#783B		;read out CPU speed and save it later
		ld	a,#30
		out	(c),a
		inc	b
		in	a,(c)			;speed is 0-3
		ld	(return_speed+1),a
		ld	a,0			;speed will be 3,5 MHz
		out	(c),a
;		ld 	a,1			;activate conevnient 7 Mhz, but not at the moment, we need test
;		out	(c),a			;at normal speed

;		bit	2,(ix+0)		;test which wifi is running. MB or el?... not needed, the below should work by itself

	
		and	a			;test if Wifi is on/off
		call	wifi_on
		set	3,(ix+0)
		jr	nz,st1			;Z=off, NZ=on
		res	3,(ix+0)
;		ld	(ix+2),#FF		;#FF=initial speed will be set to max, SM2.0


;flag1 (IX+0),bit 7=used in "HL2ASCII"
;bit 0=used in "look_for_string"
;bit 1=login to server,0=automatic, 1=manual
;bit 2=hide ftp password,0= no, 1=yes
;bit 3=wifi on exit, 0=off,1=on
;bit 4=print info in speed management? 0=no, 1=yes
;bit 5=ftp login status, 0= not connected to host, 1= connected to host
;bit 6=speed correctly set (module and UART), 0= no, 1= yes
;bit 7=AP list, 0=not complete, 1= complete
;(IX+1)= counter of AP in memory
;flag2 (IX+3).bit 0=print send command,0=NO, 1=YES
;bit 1=AP connection CURrent or DEFault (1=current, 0=default)
;bit 2=we use mb wifi or not? 0=no, 1=yes
;bit 3=window for AP list or speed list? (1=AP list, 0= speed list)
;bit 4=session ID,0=ID 0, 1=ID 1
						

st1
main		bit	0,(ix+3)
		ld	hl,send_string+1
		ld	a,18			;jr ss5= do not print what you send to module
		jr	z,printyesno1		;Z=do not print
		xor	a			;jr ss2= print it
printyesno1	ld	(hl),a

	IFNDEF	hgfx64x24
		call	cls_4000
	ENDIF

		set	4,(ix+0)		;set flag to print info in speed management
		call	speed_management
		call	print_whole_screen+3	;bez CLS (aby se nesmazalo info o Speed)


;	IF bs_dos=0
	IFNDEF bs_dos
		call	GetSetDrive
	ENDIF

	IFDEF	hgfx64x24
	IFDEF bs_dos
		call	getversion		;BSDOS si bere adresu bufferu kvuli presmerovani chybovych hlaseni
	ENDIF
	ENDIF


		ld	hl,start_address	;0.22,count buffer length in bytes. Flexible.
		ld	de,basic_end		;do not have to care about buffer length anymore
		or	a
		sbc	hl,de
		ld	a,h
		and	%11111100		;to obtain *2048
		ld	h,a
		ld	l,0			;HL=maximum length of disk buffer in bytes
		ld	(disk_buf_len),hl	;DE=disk buffer start, "end"

		xor	a
		ld	(item_checksum),hl	;signal dir start from begining

		ld	hl,at_cwmode
		call	send_string		;set module to station mode (CWMODE=1)
		ld	hl,ok
		call	look_on_fly
		jr	z,error_handler_loop
		ld	c,2
		jp	error_handler

error_handler_loop				;this is starting point, where routine jumps after error occurs
		ld	sp,basic_end-2
		set	4,(ix+0)		;print info in speed management= YES
		ld	(ix+6),8		;timeout for module check
kl5		call	get_status_ftp		;find out if already connected to ftp server
		jr	nz,kl10
;		jr	z,key_loop		;Z=connected+ logged in
		bit	0,(ix+1)		;dir already read in?
		jp	z,directory_retrieve
		jr	key_loop

kl10		cp	"5"
		jr	nz,kl3			;NZ=status "2" or "4" or "3"
;		jr	nz,kl4
		dec	(ix+6)			;status= "5" module not connected to AP, try it out 20x
		jr	nz,kl5
		ld	c,25			;error 25 module not connected to AP, the user has to set his module externally
		jp	error_handler

kl3		cp	"3"
;		jr	z,kl_connected		;Z=status 3 (connected to server but not logged in)
		jp	z,al_user_pass		;make auto login with USER and PASS

						;NZ=status "2" or "4"- continue to CIPMUX
kl4		ld	hl,at_cipmux		;!!!!!!!!we re not connected to ftp server
		call	send_string
		ld	hl,ok
		call	look_on_fly
;		jr	z,key_loop
		ld	c,3
		jp	nz,error_handler

kl_alogin	bit	1,(ix+0)		;carry out autologin? ;bit 1=login to server,0=automatic, 1=manual
		jp	z,auto_login
		jp	ftp_login


key_loop	call	KEYSCAN
		cp	"u"
		call	z,ftp_upload_file
		cp	"o"
		call	z,ftp_quit_connection
		cp	"l"
kl2		call	z,ftp_login
		cp	"s"
		call	z,ftp_file_size
		cp	"d"
		call	z,ftp_download_file_dir
		cp	"D"
		call	z,ftp_download_file_new
		cp	#5C
;		cp	"\"			;SS+D
		call	z,ftp_download_file_var
		cp	"w"
		call	z,set_onoff
		cp	"q"
		jp	z,quit_program
		cp	"h"
		call	z,change_host
		cp	"v"
		call	z,save_app
		cp	"a"
		call	z,set_alogin
		cp	"f"
		call	z,set_filename
		cp	"t"
		call	z,set_start
		cp	"e"
		call	z,set_user
		cp	"p"
		call	z,set_pass
		cp	"="			;SS+L
		call	z,auto_login
		cp	#22			;SS+P
		call	z,set_hide_pass
		cp	"n"
		call	z,set_list_nlst
		cp	","			;SS+n
		call	z,set_full_abbr
		cp	"r"
		call	z,directory_retrieve

		bit	0,(ix+1)		;dir already read?
		jr	z,kl11
;;;vratit		jr	z,kl11			;Z=not read, skip some keys

		cp	#B			;up. Move through directory
		call	z,key_up
		cp	#A			;down
		call	z,key_down
		cp	#9
		call	z,pg_up			;page up
		cp	#8
		call	z,pg_down		;page down
		cp	#D
		call	z,enter_directory
		cp	1			;BREAK to go to updir directly
		call	z,go_updir
		cp	"7"
		call	z,create_dir
		cp	#C			;DELETE key
		call	z,delete_item_file
		cp	"6"
		call	z,rename_item_file
		cp	"x"
		call	z,roll_item
		cp	#20			;SPACE key
		call	z,mark_item
		cp	"M"			;CS+M=mark all
		call	z,mark_all
		cp	"."
		call	z,unmark_all		;SS+M=unmark all
		cp	"i"
		jp	z,find_items
;		call	z,find_items

kl11		cp	"c"
		call	z,enter_command
		bit	5,(ix+0)
		jr	z,kl6			;Z=not logged in, do not send NOOP command


noop_timer	ld	hl,0			;send NOOP command every 1 minute, read it from MBC RTC chip
nt_loop		dec	hl			;read RTC only every 65535th cycle
		ld	(noop_timer+1),hl
		ld	a,h
		or	l
		jr	nz,kl6

		ld a,1
		ld bc,#703B			;ZXi_port0
		out (c),a
		ld bc,#773B			;ZXi_port7
		in a,(c)
;		push af			
;		and #0F
;		or 48

		cp	(ix+24)			//1min
		jr	z,kl6
		ld	(ix+24),a
		call	send_noop
		ld	hl,0
		ld	(noop_timer+1),hl



kl6		and	a			;check module, if it brings any data. Yes? Print them for the moment.
		call	rece_byte
		jp	z,key_loop

kl8		ld	hl,RX_buf		;data avialable, accept them
		ld	bc,buffers_len/2
		push	hl
		call	receive_data_timeout
		pop	hl			;omit IPDs....etc
		ld	de,dvojt		;if code 421 returned check connection
		call	look_for_string
		jr	nz,kl9
;		jp	nz,key_loop

		push	de
		ld	h,d
		ld	l,e
		call	print_ftp_message

		pop	de
		call	ConvRStr16
		ld	de,421
		or	a
		sbc	hl,de
		jp	z,error_handler_loop	;code is 421, check connection
kl9		xor	a			;A=0 to return to key_loop
		jp	key_loop







;speed management 2.0. starts here. Enables to set user_defined speed. Works with every MBFW.
;the principle:
;are you aligned?
;NO: try to align, if not success->error. If sucess, you have AKT (=current alligned speed is ;known). Is user defined speed definied? (IX+2=255 for no user defined speed) yes, END. NO. set ;speed according to ix+2 (max up to MBFW), end
;
;YES:
;is user defined speed set? (ix+2=255 or other?) NO=check if FW is 7/12? YES, align at speed
;ix+2, end. FW is higher then 7/12, then check if AKT=IX+2? YES, end, NO, align at ix+2, END.
;ix+2 was not 255, is FW 7/12? YES, then set FWmax, end. NO the is AKT=MBFW max? YES, then END
;NO, then align at FW max speed, end
;output: ix+7= 0-23 if speed set, or 255 if not set

;SM20 uses:
;bit 4,(ix+0)	PRINT or not to PRINT
;(ix+8)		contains maximum speed by detected MBFW (7, 12 or 23)
;(ix+6)		timeout value
;bit 6,(ix+0)	state of speed alignment between uart& module, 0 not aligned
;bit 5,(ix+0)	state of module connection to AP, 0 not connected to AP

;internal subroutines: switch_speed, print_bauds, find_out_speed
;external subroutines: send_at:check_ok, set_ud_speed, set_print_speed, print_speed

speed_management
		ld	(ix+7),#FF		;reset currently set speed status
		res	6,(ix+0)		;set signal UART and module speed not aligned

;;		ld	hl,#4300
;;		ld	de,wifi_on_off
;;		call	PRINTHL

		scf				;power on wifi
		call	wifi_on


		ld	hl,txt_adr_speed_login	;print "Speed" text
		ld	de,speed
		call	PRINTHL

		ld	bc,#783B		;set CPU to 3,5 MHz
		ld	a,#30
		out	(c),a
		inc	b
		xor	a
		out	(c),a

		push	ix
		call	gver_inst
		pop	ix			;A= max MBFW speed= 7 or 12 or 23
		ld	(ix+8),a		;save max possible speed for given FW

		ld	(ix+6),1		;timeout for quick AT check, 1 should be ok.
		call	send_at_check_ok
		jr	z,speed_aligned		;Z= speed aligned (UART<-> module)

						;speed not aligned
		call	switch_speed		;try to find out aligned speed
		jr	z,align_success
;		pop	hl
		ld	bc,29			;solve in next versions
;		jr	nz,speed_uart_err

speed_uart_err	call	print_bauds		;print speed in bauds even if speed no communicate

		ld	de,module_no_aswer
		call	print_ez1
;		ld	bc,30
	
speed_m_error	res	5,(ix+0)		;set signal wifi not connected to AP
;		jp	error	
sme1		call	akey
		call	undraw_cursor		;return from AP selection
		call	wind_cls
		call	clear_edit_zone
		ret
;zde konci vetev, kdy na pocatku SM2.0 nebylo nalezeno slazeni rychlosti

;zde jsme ze zacatku rychlost nasli a zkoumame, zda je to ta, kterou chceme, pokud ne, tak ji nastav
speed_aligned	call	find_out_speed		;output: D= currently aligned speed
align_success	call	set_ud_speed

;ve speed_we_want vyhodnotit, zda je odezva na AT prikaz. Pokud ne, neznamená to, že
;rychlosti nebyly slazeny, ale ze nektere z rychlosti 0-23 nekomunikuji s modulem.
speed_we_want	ld	(ix+6),#A
		call	send_at_check_ok
		jr	nz,speed_uart_err

wifi_cont					;we are at speed we want. Final steps... print UART speed+ Baud speed
		set	6,(ix+0)		;signal, that uart and module speed is aligned

;		call	get_baud
		call	find_out_speed
		ld	a,d			;A=aligned speed we ended with
		ld	(ix+7),a		;save it
		call	print_speed
		call	print_bauds

		ld	hl,ate0
		call	send_string
		ld	hl,ok
		jp	look_on_fly
;		call	look_on_fly
		;test for answer should be here?
;		ret		

;SM2.0 subroutines
find_out_speed					;subroutine is able to find out current speed for all MBFW, output in D
		call	get_baud		;we are at aligned speed, is the one we want?
		jr	nc,fos1			;C=speed reading not supported by given MBFW
		call	switch_speed		;in case of MBFW 7, 12-> find out currently aligned speed
		ld	a,d
fos1		ld	d,a			;D=curently aligned speed
		ret

						;tests speeds <7-0>, then <max-8>
;switch_speed	ld	a,7			;start with speeds 7-0 (quicker finds the speed)
;		call	sws2
;		ret	z			;Z= speed <0,7> found

switch_speed	ld	a,(ix+8)		;try out every speed if you find connection UART+Wifi
						;start with max speed, end with 0
sws2		push	af
		call	set_print_speed

		call	clear_rece_buf		;very important to clear receive buffer!!!

		pop	af			;we need to inrease timeout for speeds <3
		push	af
		cp	3
		ld	(ix+6),1		;set timeout for 1 for speeds >3
		jr	nc,sws1
		ld	(ix+6),#A		;set tieout for #A for speeds <2

sws1		call	send_at_check_ok
		pop	de
		ret	z			;Z=answer found, D= speed set in HW
		ld	a,d
		dec	a
		cp	255			;test for 255, so that also speed 0 is tested
		jr	nz,sws2
		dec	a			;NZ=not successfull
		ret

print_bauds	ret
/*
print_bauds	call	get_baud		;print speed in Bauds...solved in bios 1.8
		push	de			;E=number of zeros. If MBFW=7 or 12, zeros speed in Bd is printed
		ld	de,block_asci
		ld	a,"="
		ld	(de),a
		push	de			;DE=start of speed to print
		inc	de
		ld	a,32
		ld	(de),a
		inc	de
		ld	h,b
		ld	l,c
		call	HL2ASCII
		pop	hl			;HL=start of speed to print
		pop	bc			;C=number of zeros
		ld	b,c
		ld	a,"0"
prbloop		ld	(de),a
		inc	de
		djnz	prbloop
		xor	a
 		ld	(de),a
		ld	d,h
		ld	e,l
		ld	hl,#4400+9+8
		call	PRINTHL
		ld	de,Bd
		call	PRINT

		ld	de,mbfw			;print max UART speed supported by found MB FW
		call	PRINT
		ld	l,(ix+8)
		ld	h,0
		ld	de,block_asci
		push	de
		call	HL2ASCII
		ld	a,h
		ld	(de),a
		pop	de
		call	PRINT
		ld	de,spaces+27
		jp	PRINT
*/
;end of speed management 2.0 here


		



;save application with its settings


save_app	
;	IF bs_dos=0
	IFNDEF bs_dos
		call	tapeout_open
       ld      hl,prikaz	;BASIC save according to Busy
        ld      (#5C5D),hl
	ld	iy,#5C3A
	ld	(iy+#7C),#6F	;disable tape message+ key waiting
	ld	(iy+#7E),#14
	ei
        xor     a
        call      #60B

	ENDIF

;Pokial chces autostart iny ako riadok 10, tak namiesto 10 napis potrebne cislo. Pokial nechces autostart vobec, tak cely ten jeden riadok kde je 10 jednoducho zmaz.
;Jaj, este som zabudol. Namiesto toho DS #10 mozes samozrejme dat akykolvek svoj kod. Tam ide len o to, aby nasledujuce kody CA,B0,.... boli vzdialene presne 16 bajtov od posledneho #0D za menom. Vyzaduje to tak romka.
		xor	a
		ld	de,17
		ld	ix,save_app_head
		ld	hl,total_len
;		ld	hl,total_len+8
		ld	(save_app_len),hl
		push	hl
		call	#4C2
		pop	de		;DE=total_len+8
		ld	a,#FF
		ld	ix,start_address
		call	#4C2
;	IF bs_dos=0
	IFNDEF bs_dos
		call	tapeout_close
	ENDIF
sa1		jp	fdfm3		;set iX to flag1 and RET

;	IF bs_dos=0
	IFNDEF bs_dos
prikaz  db      '"Meno"',#0D
        ds      #10
        db      #CA,#B0,'"10"'  ;; LINE VAL "10"
        db      #0D
	ENDIF


/*old working, but long
save_app	ld	hl,zxftpcl
		ld	de,exp_name
		ld	bc,10
		ldir
		ld	hl,0
		ld	(blen+2),hl
		ld	hl,total_len+8		;???? have to add 8 bytes to reach the same length as original, why?
		ld	(blen),hl
		ld	(flen),hl
		ld	hl,start_address
		ld	(sfh+1),hl
		ld	(sif1+2),hl
		call	save_file_head
		call	save_into_file
		ld	hl,basic_end
		ld	(sif1+2),hl
		jp	save_close
*/
;change URL
change_host	ld	de,enter_url
		call	print_ez1

		call	input_line
		jp	z,clear_ini_keyl	;Z=abort pressed during input, carry out clear_edit_line+jp to key_loop
		ld	de,host_url
		ldir
		xor	a
		ld	(de),a
		jp	prn_host_usr_psw
;		jp	print_url


;upload file
ftp_upload_file	bit	5,(ix+0)
		ret	z			;if no connection, return

		ld	de,enter_fil_nam
		call	print_ez1

		call	clear_exp_name		;clear file name

		call	input_line
;		ret	z			;Z=abort pressed during input
		jp	z,clear_ini_keyl	;Z=abort pressed during input, carry out clear_edit_line+jp to key_loop
		ld	de,exp_name
		ld	(fuf6+1),bc
		ldir
;	IF bs_dos=0
	IFNDEF bs_dos
		xor	a
		ld	(de),a
	ENDIF
		call	file_exist		;find out if file exists
		ld	ix,flag1
		ld	c,14
;		jr	nz,ful_abort
		jp	nz,error_handler	;file not exist

		ld	a,1
		ld	de,550			;550 File not found
		ld	hl,ftp_size
		call	send_ftp_command
		jr	c,fuf1			;C=file exists (550 code not found)
		xor	a			;set Z
		jr	fuf5


						;NZ=file exist, use STOR or APPE, user will choose
fuf1		ld	de,file_exist_txt
		call	print_ez1

fuf3		call	KEYSCAN
		cp	"o"			;OVERWRITE existing file
fuf5		ld	hl,ftp_stor
		jr	z,fuf2
		ld	hl,ftp_appe
		cp	"a"			;APPEND existing file
		jr	z,fuf2
		cp	7			;EDIT=cancel
fuf4		jp	z,clear_edit_zone
		cp	"b"			;ABBORT upload process
		jp	z,ful_abort
		cp	"n"			;NEW file- use command STOU
		ld	hl,ftp_stou
		jr	z,fuf2
;		jr	z,fuf4
		jr	fuf3			;endless loop!!!!

fuf2		push	hl

		call	send_type_command_i	;switch to TYPE I (binary)
		call	enter_passive_mode

		ld	hl,exp_name		;renew uplad file name
		ld	de,INPBUFF
fuf6		ld	bc,#5555
;		inc	bc			;this caused Transfer error in BSDOS (11th byte did not belonged to file name)
		ldir

		pop	hl

		ld	a,1			;A=1= send command+ prepared name
		ld	de,150
		call	send_ftp_command	;sends STOR or APPE+ file name
		ld	c,17
		jr	c,ful_abort

;;		call	set_20mhz		;nemuzu upload dostat na vic nez 3,5Mhz, proc??????

		ld	de,uploading_file		;for test purposes only
		call	print_ez1
		ld	de,press_b
		call	PRINT
		ld	hl,txt_adr_progress
		ld	de,progress
		call	PRINTHL

;		call	save_dir_position	;realise in next version

;princip je jasný. Tady musím do pamìti nahrát soubor, napø. o délce 32000
;buffer=16kb, takže z disku nahraju na 32768 èást 16kb
;pak:
;1) pošlu pøíkaz AT+CIPSEND=1,2048 (2048 je pro náš modul maximum:(((((()
;2) pošlu 2048 bajtù
;3) pošlu pøíkaz AT+CIPSEND=1,2048
;4) pošlu 2048 bajtù, a poøád dokola. Až je vše posláno, pak pošlu....
;5) pošlu AT+CIPCLOSE=1
						;ftp prepared to accept data
		call	load_init
		ld	ix,flag1
;	IF bs_dos=0
	IFNDEF bs_dos
		jr	c,ftp_upl_last		;C=file<buffer. load only 1x
	ELSE
		jr	nc,ftp_upl_last		;NC=file<buffer. load only 1x. BSDOS version uses carry flag differently!!!	
	ENDIF

ftp_upl_loop	call	display_progress	;upload loop. File in buffer
		push	ix
		call	load_file
		pop	ix
		push	af			;preserve flags
		call	ftp_send_loop		;send data from buffer, cut to #400
		pop	af			;check if it was last part
		jr	nc,ftp_upl_loop		

ftp_upl_last	call	display_progress	;C= will be last load
		push	ix
		call	load_file
		pop	ix
		call	ftp_send_loop

ftp_upl_end	
;	IF bs_dos=0
	IFNDEF bs_dos
		push	ix
		call	fClose			;in Esxdos, the file must be closed, even if reading
		pop	ix
	ENDIF
		ld	hl,at_cipclose1		;close data channel to complete upload
		call	send_string
		ld	c,7
		jr	nz,ful_abort
		call	set_3_5mhz
		ld	de,226
		call	receive_ftp_answer_isolated
		ld	c,18
		ld	(ix+23),0		;0= Transfer OK	
		jp	nc,fdfm4		;print_transfer_status+undraw_cursor+directory_retrieve
;		jp	nc,print_transfer_status
;		jp	nc,clear_edit_zone	;successful end	


ful_abort;	push	bc			;in case of error, not only print code, but also send ABOR command to return
		res	4,(ix+3)
		ld	de,426
		call	send_abort
;		ld	c,16			;426 Connection closed
;		jp	c,error_handler		;neni osetreno, ale melo by, zde muze byt i kod 226, pak se to tvari,ze
;		jr	nc,fua1			;prikaz ABOR nebyl uspesne prijat
;		pop	bc



		ld	(ix+23),1		;set flag to print "Transfer aborted"	
		call	print_transfer_status
		call	directory_retrieve
;		call	set_3_5mhz
		pop	hl			;new!!! since we call routines, pop should be here
		jp	kl8			;receive ftp answer (226 ABOR command successful), and print it

;subroutine, which sends to ftp server whole buffer blocks by blocks. Max length of block that ESP can send is #800:((
ftp_send_loop	ld	hl,basic_end
		ld	(ftp_upl_start),hl
		ld	hl,(portion_len)	;send whole buffer, part by part
		push	hl


fsl1;		ld	bc,#400			;!!!!!IMPORTANT, we can put #800 here, and will send twice as much data in one go!!
;		ld	bc,#800
		ld	bc,upload_length		;#800 is here, #400 works too but is slower
		pop	hl
		or	a
		sbc	hl,bc
		jr	z,ftp_upl_send		;file is round of #800 (#400)
		jr	c,ftp_send_lastc
		push	hl
		call	ftp_upl_send
		call	KEYSCAN			;user can ABBORT upload with "B" key ("A" already reserved for APPEND selection)
		cp	"b"
		ld	c,20
		jr	z,ful_abort
		jr	fsl1

ftp_send_lastc	add	hl,bc
		ld	b,h
		ld	c,l

ftp_upl_send	ld	(ftp_upl_len),bc
		push	bc
		call	cipsend_lod		;send AT+CIPSEND=1,length_of_data
		ld	c,6
		jr	c,ful_abort
;		jp	c,error_handler
		pop	bc
		push	bc
		ld	hl,(ftp_upl_start)	;IN=BC=lenght of data (#400 bytes or lower)
		push	hl

;		ei				;should be there according to manual, but works without the 20 ms pause
;		halt
;		halt
;		nop
;		di				;wait 20 ms (one interrupt) as AT+CIPSEND command requires in the manual

;		ld	de,0
;		call	send_block

		call	send_data

		pop	hl			;HL=ftp_upl_start
		pop	bc			;BC=length of data
		add	hl,bc			;increase next start position by data length
		ld	(ftp_upl_start),hl

		ld	c,5
		jr	nz,ful_abort
;		jp	nz,error_handler


		ld	(ix+6),#30		;48 attempts to check if data were sent ok
fus1		call	clear_RX_buf
		ld	hl,RX_buf		;find out, if data were sent ok
		push	hl
		ld	bc,#20
		push	bc
		call	receive_data_timeout
		pop	bc
		pop	hl

		ld	de,sendok
		call	look_for_string
		jr	z,fus2
		dec	(ix+6)
		jr	nz,fus1
		ld	c,8			;if error 8, we could start to reupload the packet
		jp	ful_abort
;		jp	error_handler



fus2		ret				;upload of packets works without 20 ms pause
;		ei				;should be there according to manual, but works without the 20 ms pause
;		halt
;		di				;wait 20 ms (one interrupt) as AT+CIPSEND command requires in the manual
;		ret
ftp_upl_len	dw	#5555			
ftp_upl_start	dw	#5555


;log off ftp
ftp_quit_connection
		bit	5,(ix+0)
		ret	z			;if no connection, return

		ld	de,ftp_quit+3
		call	print_ez1

		ld	hl,ftp_quit
		xor	a
		ld	de,221
		call	send_ftp_command
		ld	c,40
		jp	c,error_handler
		res	0,(ix+1)		;indicate, that no dir is retrieved
		call	cls_9
		call	cls_dir_files
		call	undraw_cursor
		call	print_title
		jp	get_status_ftp
;		jp	error_handler1		;back to error_handler_loop

		

ftp_download_file_var
		call	send_type_command_i	;switch to TYPE I (binary)
		call	ftp_download_file_var1
		jr	tn2
ftp_download_file_new
		call	send_type_command_i	;switch to TYPE I (binary)
		call	ftp_download_file_new1
		jr	tn2
;priprava na hromadný download souboru
ftp_download_file_dir
		bit	5,(ix+0)
		ret	z			;if no connection, return

		call	send_type_command_i	;switch to TYPE I (binary)
		ld	hl,(mark_counter)
		ld	a,h
		or	l
		jr	nz,ldir_names
;		jr	z,fdfd1			;Z=download only file under cursor
		call	fdfd1
;end of download
tn2		call	prn_mark_items	;print zero marked items
		call	set_3_5mhz		
		call	passive_receive_off	;turn off passive transfer mode
fdfm4		call	print_transfer_status	;end of download
;		call	undraw_cursor		;dir retrieve not needed
		jp	directory_retrieve	;after download or upload, dir list corrupted!!!

;		jp	directory_retrieve


;projdi adresar a oznacene soubory mrdni od #4800 (delka bufferu= #800 bajtu)
ldir_names	ld	hl,basic_end+fi_len-2	;delete multiple files
		ld	(cur_item_addr),hl
 
		ld	de,txt_adr_dir_display_vram	;hl=start of buffer for names
		push	de				;DE=start addr to put new name

ln_loop		call	search_marked_items
		jr	z,ln1			;end of dir, go no..


		push	de
		scf
		call	get_item_name
		pop	de
		cp	3
		jr	c,ln2
		pop	hl			;get rid off call
		ret
;		ret	nc			;NC= item either LIST+full (not suported at the moment), or ".."
						;HL= marked item, BC= its length
ln2		ex	de,hl
		push	hl			;DE= marked item
		add	hl,bc			;HL= start addr of new name
		ld	a,h
		pop	hl			;HL=start addr of new name
		cp	high txt_adr_dir_info	;test for buffer end
		ld	a,0
		ex	de,hl
		jr	z,ln1			;DE= start addr of new name, HL=marked item

		ldir				;name on its place
		ld	(de),a			;0 as name end mark
		inc	de

		push	de			;DE= start addr for next name
		ld	bc,cur_item_addr
		call	item_add
		pop	de
		jr	nz,ln_loop		;Z=was last item
;		jr	ln_loop

ln1		ld	(de),a			;place 0 to signal buffer end (buffer ends with 2x 0)
;		ret
		

;take names and download them
take_names	;ld	hl,txt_adr_dir_display
		pop	hl		;HL=txt_adr_dir_display= addr of first name
tn_loop		ld	a,(hl)
		or	a
		jr	z,tn2

;		ld	(ix+23),a	;initialise transfer flag

;		jp	z,directory_retrieve
;		ret	z		;no more names

		xor	a		;we look for 0
		ld	de,#FFFF	;DE=#FFFF, counter
		push	hl		;HL=name start for download

tn1		cpi
		inc	de
		jr	nz,tn1		;look for 0

		ld	b,d
		ld	c,e
		pop	de		;DE=name start for download, BC=name length
		push	hl		;HL=next name start
		ex	de,hl
		call	fdfd2		;HL=name start for download, download file

;		halt			;jen pro testy

		call	passive_receive_off	;necessary to accept data correctly

		ld	hl,(mark_counter)
		dec	hl
		ld	(mark_counter),hl
		call	prn_mark_items
		pop	hl
		jr	tn_loop


;download file from ftp server
;ftp_download_file_dir
;		bit	5,(ix+0)
;		ret	z			;if no connection, return

fdfd1		scf
		call	get_item_name
		cp	3
		ret	nc			;NC= item either LIST+full (not suported at the moment), or ".."
;		ret	z			;Z= item=LIST+full- not supported at the moment

fdfd2		exx
		call	clear_inp_buf		;HL=start of file name,BC=name length
		exx

		ld	de,INPBUFF
		ldir
		xor	a
		ld	(de),a
		jr	fdfv1


ftp_download_file_var1				;download file from variable
		bit	5,(ix+0)
		ret	z			;if no connection, return
	
		call	clear_inp_buf
		ld	hl,var_name
		ld	de,INPBUFF
		push	hl
		call	count_com_len
		pop	hl
		ldir				;ldir variable name into file header

fdfv1		ld	a,1
		ld	hl,ftp_size
		ld	de,213
		call	send_ftp_command	;send command SIZE+ file name take from vars
		jr	nc,fdf_cont

;		halt				;jen test

		ld	de,226
		or	a
		sbc	hl,de
;		jr	c,fdf_err		;C=file not found
		jr	z,fdf_cont
		jp	ffs1_fnf


ftp_download_file_new1				;download file from input
		bit	5,(ix+0)
		ret	z			;if no connection, return

		ld	de,enter_fil_nam
		call	print_ez1

		ld	hl,ftp_size		;find out file size
		ld	a,2			;A=2=command+new input
		ld	de,213
		call	send_ftp_command
fdf_err		jp	c,ffs1_fnf		;C=file not found

fdf_cont	;call	save_dir_position	;realise in next version
	IFDEF	bs_dos
		ld	hl,exp_name		;BSDOS: blank name buffer to 10 spaces
		ld	de,exp_name+1
		ld	bc,9
		ld	(hl),32
		ldir
	ENDIF

;new routines to get file name to bsdos and esxdos from INPBUFF to exp_name
;vytvor hlavicku, a uloz
		ld	hl,INPBUFF		;prepare name for save
		ld	de,exp_name		;file nam from INPBUFF to exp_name
	IFDEF	bs_dos
		ld	b,10
aft2		ld	a,(hl)
		or	a
		jr	z,aft1
		ld	(de),a
		inc	hl
		inc	de
		djnz	aft2
		jr	aft3

aft1		ld	a,32
		ld	(de),a
		inc	de
		djnz	aft1
	ENDIF

	IFNDEF	bs_dos
		ld	b,8			;HL=INPBUFF, DE=exp_name
aft2_esx	ld	a,(hl)
		or	a
		inc	hl
		jr	z,aft3e			;end of name parsing
		cp	"."
		jr	z,aft3_esx		;zapis tecku
		cp	#20			;mezera? nahraï podtrzitkem
		jr	nz,aft1_esx
		ld	a,"_"
aft1_esx	ld	(de),a
		inc	de
		djnz	aft2_esx

aft4_esx	ld	a,(hl)			;hledej tecku
		or	a
		inc	hl
		jr	z,aft3e			;Z=name has no extension
		cp	"."
		jr	nz,aft4_esx

aft3_esx	ld	(de),a			;uloz tecku
		inc	de
						;nyni jed na konec nazvu za priponu
		call	count_com_len		;find name end (count_com_len leaves HL at the 0)
aft7_esx	dec	hl
		ld	a,(hl)
		cp	"."
		jr	nz,aft7_esx
		inc	hl

		ld	b,3			;a uloz priponu, (resi pripady i typu: saboteur2_128k_mod_by_thealfest_v1.0.4.tap, nebo pripona <3 napr. GAUNTLET.AY)
aft5_esx	ld	a,(hl)
		inc	hl
		or	a
		jr	z,aft3e
		ld	(de),a
		inc	de
		djnz	aft5_esx
aft3e		xor	a			;0-terminate the 8.3 name (buffer no longer pre-cleared)
		ld	(de),a
	ENDIF




/*old, problematic
	IFNDEF bs_dos
;		halt		;jen test, proc nejdou mezery, pro esxdos, pak smazat
		pop	hl			;HL=exp name (only to get rid off previous push)
		ld	hl,INPBUFF		;prepare name 8.3 for Esxdos
		push	hl
		ld	bc,254
		ld	a,"."
fdf_esx1	cpi
		jp	po,fdf_esx2		;dot not found
		jr	nz,fdf_esx1
		dec	hl
		ex	de,hl			;dot starts on address HL
		pop	hl			;HL=IPNBUFF, DE=dot
		push	de			;DE=dot
		ld	de,exp_name

		ld	b,8
fdf_esx3	ld	a,(hl)
		cp	#20
		jr	z,fdf_esx7
		cp	"."
		jr	nz,fdf_esx6
fdf_esx7	ld	a,"_"			;replace spaces with "_"
fdf_esx6	cp	"."			;esxdos won't accept: space, dot
		jr	z,fdf_esx4		;accepts: ',+,#,!,dollar,&,%
		ld	(de),a
		inc	hl
		inc	de
		djnz	fdf_esx3

fdf_esx4	ld	bc,4
		ld	h,d
		ld	l,e
		jr	fdf_esx5		;HL=end of file name

fdf_esx2	ld	b,8			;dot not found, find end of name or 8x max
		pop	hl			;HL=INPBUFF
		push	hl
		push	hl
fdf_esx21	ld	a,(hl)
		inc	hl
		cp	#20
		jr	z,fdf_esx24
/*
		jr	z,fdf_esx22
fdf_esx23	djnz	fdf_esx21
		jr	fdf_esx24

fdf_esx22	ld	(hl),"_"
		inc	hl			;eliminate spaces also with files without extension
		ld	a,(hl)
		cp	#20
		jr	nz,fdf_esx23
*/		
fdf_esx24	dec	hl	
		pop	de
		or	a
		sbc	hl,de
		ld	b,c			;B=0
		ld	c,l

;		ld	bc,8
		ld	de,exp_name
		push	de
		ex	de,hl			;now find out last position for use in esx disk operations
		add	hl,bc			;HL= end of file name
		pop	de
fdf_esx5	ld	(fopen_adr+1),hl
		pop	hl			;HL=INPBUFF
		ldir
		xor	a
		ld	(de),a	

	ELSE
		call	input_l_count
		pop	de			;DE=exp_name
		ld	a,c
		cp	11			;limit name to 10 chars max
		jr	c,fd1
		ld	c,10
fd1		ldir

	ENDIF
*/; old problematic, coud not cope with eg. name.AY, or more dots inside name

aft3		ld	bc,RX_buf+4		;length of file
		call	ConvRStr32
		ld	(blen),de		;32 bit length in its place
		ld	(blen+2),hl

		call	set_20mhz		;set CPU to 20MHz

		call	enter_passive_mode	;pokud nebude fungovat, pak dát zpìt na zaèátek

		ld	de,loading_file
		call	print_ez1
		ld	de,press_b
		call	PRINT
		ld	hl,txt_adr_progress
		ld	de,progress
		call	PRINTHL

		ld	hl,(var_start)
		ld	(sfh+1),hl		;start address from variable to the saved file
		ld	hl,basic_end		;set start address of download buffer
		ld	(sif1+2),hl


		push	ix
		call	save_file_head		;open file for save
		pop	ix			;NC=file is lower than buffer

		call	passive_receive_on

		ld	hl,ftp_retr
		scf
		call	send_ftp_command_in_passive_mode

						;answer ok, now retrieve file

fdf_main	ld	ix,flag1
		call	display_progress
		ld	hl,(rest_len)		;main loop taking buffer by buffer
		ld	de,(rest_len+2)
		or	a
		sbc	hl,de			;is rest_len=0?
		jr	z,fdfm2			;Z=no more download
		call	fdf_loop
		jr	fdf_main


fdfm2		ld	a,(transfer_flag)
		or	a
		jr	z,fdfm1			;Z=transfer OK, skip code 226 check


		call	ask_for_reply_in_passive_mode
		ld	de,226
		or	a
		sbc	hl,de
		ld	hl,transfer_flag
		ld	(hl),0
		jr	z,fdfm1

		ld	(hl),2
		call	delete_file
		jr	fdfm3

fdfm1		call	save_close		;successful end, file downloaded completely
		call	clear_rece_buf
fdfm3		ld	ix,flag1
		ret

;dali jsme vyse, aby se mohl download opakovat
;		call	passive_receive_off	;turn off passive transfer mode
;		call	set_3_5mhz
;fdfm4		call	print_transfer_status	;end of download
;;		call	undraw_cursor		;dir retrieve not needed
;		jp	directory_retrieve	;after download or upload, dir list corrupted!!!


fdf_loop	call	KEYSCAN
		cp	"b"			;B=ABBORT process
		jr	nz,fdf6
fdf_loop_err	call	delete_file		;in case of abbort, delete the file from MB disk.
		ld	ix,flag1
;		ld	c,20
fdfm7		call	passive_receive_off
		ld	hl,at_cipclose1		;close data channel
		call	send_string
		ld	hl,RX_buf
		ld	bc,#80
		push	hl
		push	bc
		call	receive_data_timeout
		pop	bc
		pop	hl
		ld	de,dvojt
		call	look_for_string
		ex	de,hl
		call	print_ftp_message
		ld	c,20
		jp	ful_abort		

fdf6		ld	hl,basic_end		;loop, that downloads and saves 1x buffer, or less
		ld	(buff_add_float),hl
		ld	hl,(disk_buf_len)
		ld	(portion_len),hl	;buffer counter
		
fdf3		ld	hl,(rest_len)
		ld	de,(rest_len+2)
		or	a
		sbc	hl,de
		jp	z,save_into_file	;Z=file completed


		call	data_available_in_module_file
		ld	c,26
		jr	nz,fdf5

;		halt				;testovaci, zastavi se pri vyskytu chyby 26

		call	display_error
		jr	fdf_loop_err


fdf5		ld	(rest_chunk),hl		;HL=length of data ZX can download
		ld	b,h
		ld	c,l
		ld	hl,(portion_len)	;file not complete, yet
		or	a
		sbc	hl,bc
		jr	c,fdf4

		call	fdf_sub1		;enough space in buffer, download chunk

		ld	bc,(rest_chunk)
		push	bc
		ld	hl,(rest_len)
		ld	de,(rest_len+2)
		ld	a,sub32			;rest_len=rest_len-rest_chunk
		call	bsdos
		ld	(rest_len+2),de
		ld	(rest_len),hl

		pop	bc			;BC=rest_chunk
		ld	hl,(portion_len)
		or	a
		sbc	hl,bc
		ld	(portion_len),hl
		jr	fdf3


fdf4		add	hl,bc			;not enough space in buffer, download only data for rest of buffer
		ld	(rest_chunk),hl
		ld	b,h
		ld	c,l

		call	fdf_sub1
		ld	bc,(rest_chunk)
		ld	hl,(rest_len)
		ld	de,(rest_len+2)
		ld	a,sub32			;rest_len=rest_len-rest_chunk
		call	bsdos
		ld	(rest_len+2),de
		ld	(rest_len),hl

		jp	save_into_file		;buffer full

;input: BC=length of data for download
fdf_sub1	call	ask_for_data_in_passive_mode
		ld	bc,(rest_chunk)
		ld	hl,(buff_add_float)	;HL=buffer start
		ld	de,#FFFF
		call	rece_block		;receive bytes
		ld	c,23
		jr	c,fdf_sub11

		call	display_error
		jp	fdf_loop_err
;		jp	nc,error_handler
fdf_sub11	ld	(buff_add_float),hl

		jp	clear_rece_buf

;clearni_RXko	call	clear_RX_buf		;tato rutina zpomalovala download souboru z 60 na 33 kb/sec
;		ld	bc,#80
;		ld	hl,RX_buf
;		jp	receive_data_timeout	;get rid of any incoming OKs, or
						;incoming IPDs



;		ei
;		ld	b,50
;ffff		halt				;wait 20 ms
;		djnz	ffff
;		di
;;		ret



;promenne pro download. Muzeme pak umistit jinam:
rest_chunk	dw	#5555			;in bytes, 0=budeme stahovat cele IPD (chunk), jinak stahujeme jen velikost v rest_chunk
buff_add_float	dw	#5555			;in bytes, moving address throughout the buffer, where download should start
;portion_len=rest_buf_len	již máme v disk operations

;enter any command to ftp server
enter_command
		ld	de,enter_comm
		call	print_ez1

		call	input_line
		ret	z		;input aborted
		ld	b,0
		ld	de,TX_buf
		ldir
		ex	de,hl
		ld	(hl),#D
		inc	hl
		ld	(hl),#A
		inc	hl
		ld	(hl),0


		push	de		;any value, normally we enter ftp_send_command with return code in DE, but must be here to correctly return from cipsend_request
		call	clear_edit_zone
		jp	cipsend_request	;here the return code can be any

		
;rename item/file
rename_item_file
		scf
		call	get_item_name
		cp	3
		ret	nc			;NC= item either LIST+full (not suported at the moment), or ".."
;		ret	z			;Z= item=LIST+full- not supported at the moment


		exx
		call	clear_inp_buf
		exx

		ld	de,INPBUFF
		ldir
		ld	hl,ftp_rnfr

		ld	a,1
		ld	de,350
		call	send_ftp_command
		jp	c,error_handler

		ld	de,enter_name
		call	print_ez1

		ld	a,2
		ld	de,250
		ld	hl,ftp_rnto
		call	send_ftp_command
		jp	c,error_handler
		jp	directory_retrieve
		


;find out file size
ftp_file_size	bit	5,(ix+0)
		ret	z			;if no connection, return


		ld	de,enter_fil_nam
		call	print_ez1

		call	send_type_command_i	;needed for rigid servers

		ld	a,2
		ld	de,213
		ld	hl,ftp_size
		call	send_ftp_command
ffs1_fnf	ld	c,22
		jr	nc,ffc1			;NC=OK, file found
		ld	de,226			;bylo ;;;koko
		or	a			;bylo ;;;koko
		sbc	hl,de			;bylo ;;;koko
		jr	z,ffc1			;bylo ;;;koko
ffs1_fnf1	call	display_error
		xor	a			;A=0, for return to key_loop
		ret
;		ret	nc			
;		jp	error_handler

ffc1		ld	hl,exp_name
		push	hl
		call	clear_exp_name		;clear file name

		call	input_l_count
		pop	de
;		ld	b,0
		ldir
		xor	a			;A=0, for return to key_loop
		ret

;		jp	send_command_and_string
;		jp	enter_usr_psw		;print it only


;delete item/file
delete_item_file
		ld	de,yesno
		call	print_ez1

dif1		call	KEYSCAN
		cp	"y"
		jr	z,dif2
		cp	"n"
		jp	z,clear_edit_zone
		jr	dif1

dif2		call	clear_edit_zone
		ld	hl,(mark_counter)
		ld	a,h
		or	l
		jr	nz,dif3			;Z=delet file under cursor
		call	dif_sub
		call	c,akey			;for user to read ftp error return code
		jr	cd1			;jp directory_retrieve

dif3		ld	hl,basic_end+fi_len-2	;delete multiple files
		ld	(cur_item_addr),hl
dif_loop	call	search_marked_items
		jp	z,tn2			;prn_mark_items, directory retrieve
;		jr	z,cd1			;Z=last item, jp directory_retrieve

		call	dif_sub
		jr	nc,dif5
		call	akey			;for user to read ftp error return code
		jr	dif4

dif5		ld	hl,(mark_counter)
		dec	hl			;decrease counter
		ld	(mark_counter),hl

		ld	hl,(cur_item_addr)
		inc	hl
		inc	hl
		res	0,(hl)			;unmark item

dif4		ld	bc,cur_item_addr
		call	item_add

		call	prn_mark_items
		jr	dif_loop	


;puvodni
;OUT=NC,item deleted, C=item not deleted
dif_sub		scf
		call	get_item_name
		cp	3
		ret	nc			;NC= item either LIST+full (not suported at the moment), or ".."
;		ret	z			;Z= item=LIST+full- not supported at the moment

		ex	af,af'

		exx
		call	clear_inp_buf
		exx

		ld	de,INPBUFF
		ldir
		
		ex	af,af'
;		ld	c,a			;A= item status (0,1,2,3)
;		push	bc			;0=dir, 1=file, 2=dir or file
		or	a			;Z=directory
remove1		ld	hl,ftp_rmd
		jr	z,remove
;		cp	1
		ld	hl,ftp_dele
		
remove		ex	af,af'
		ld	de,250			;remove. With item 2 try delete file first...
		ld	a,1
		call	send_ftp_command
;		pop	bc			;C=item status (0,1,2,3)
		ret	nc			;NC=item deleted

;		or	a
;		ld	de,550			;550 Directory not empty
;		sbc	hl,de			;special case. Non empty dir have to be deleted file after file.
;		jr	nz,remove2

;		jr	nc,cd1			;NC=all ok
;		jr	c,fdf_err
;		ld	a,c
;		push	bc
remove2		ex	af,af'
		cp	2
;		ld	hl,ftp_rmd		;...if file delete not sucessful, delete dir.
;		push	bc			;because of "pop bc" in "remove" routine
		ld	a,3			;A can be any number from 2, it signals routine end
		jr	z,remove1
		scf				;C=item not deleted
		ret


;enter new directory
create_dir	ld	de,enter_dir
		call	print_ez1

		ld	a,2
		ld	de,257
		ld	hl,ftp_mkd
		call	send_ftp_command
		ld	c,27
		jp	c,ffs1_fnf1		;C=command not successful

cd1;		call	undraw_cursor
		jp	directory_retrieve



;automatic login to FTP server. If connection exists, it will ask if should be kept or proceed to new one.
auto_login	call	get_status_ftp		;find out if already connected to ftp server
		jr	nz,al1			;NZ= proceed to login

		call	test_ftp_connection
		ret	z			;Z=already connected

al1		call	connect_to_ftp_server	;connect to new server

al_user_pass	call	clear_inp_buf
		ld	hl,var_user
		push	hl
		call	count_com_len
		ld	de,INPBUFF
		pop	hl
		push	de			;DE=INPBUFF
		ldir

		ld	a,1			;enter username
		ld	de,331
		ld	hl,ftp_user
		call	send_ftp_command
		jp	c,error_handler

		ld	hl,var_pasw
		push	hl
		call	count_com_len
		pop	hl
		pop	de			;DE=INPBUF
		ldir

		ld	a,1			;enter password
		ld	de,230
		ld	hl,ftp_pass
		call	send_ftp_command
		jr	c,fl_usr_psw		;C=login not sucessful, another automatic try makes no sense, try manual login
;		jp	error_handler1		;error handler without printing error= test connection
		jr	fl3			;continue with directory retrieve






;login to ftp server. 1. make TCP connection at port 21, 2. input user+ password
;manual login
ftp_login	call	get_status_ftp		;find out if already connected to ftp server
		jr	nz,fl5			;NZ= proceed to login

		call	test_ftp_connection
		ret	z			;Z=already connected

;		ld	a,(ix+22)		;ix+22= status "2" to "5"
;		cp	"3"
;		jr	z,fl5
;		ld	hl,#4000+(32*4)		;if new connection, clear ftp message zone
;		ld	b,8*3
;		call	cls_9_lines

fl5		call	connect_to_ftp_server	;connect to new server

fl_usr_psw	res	4,(ix+3)		;ID=0
		ld	de,enter_usr		;enter& send username
		call	print_ez1

		ld	de,331			;331=password required for user
		ld	hl,ftp_user
		ld	a,2
		call	send_ftp_command	;zde by mìlo být vyhodnocení chyby!!!!
		jp	c,error_handler		;if error, than c=1, or 11 or 25

fl4		ld	de,psw			;enter& send password
		call	print_ez1

		ld	de,230			;230= logged on
		ld	hl,ftp_pass
		ld	a,2
		call	send_ftp_command
		jr	c,fl_usr_psw		;bad password, enter it again
;		jr	c,fl4			;if error, than c=1, or 11 or 25, if wrong password, retry it (530= login incorrect)
;		jr	nc,fl3			;NC=login successful

fl3		call	clear_edit_zone
;		jp	error_handler1		;error handler without printing error= test connection
		call	get_status_ftp
;		jp	nz,kl10
		jr	nz,fl_usr_psw		;not connected, retry


directory_retrieve				;retrieve directory list
		call	cls_9			;clear screen from previous directory
		call	cls_dir_files
		call	undraw_cursor
		call	wifi_wait

		call	send_type_command_a	;switch to TYPE A (ASCII)
		call	enter_passive_mode
		call	passive_receive_on
		call	set_20mhz		;pridame, jakmile to bude odladeno

		ld	hl,ftp_dir_page+1	;nastrankuj si prvni stranku ftp adresare
		ld	(fdp_pointer),hl
		dec	hl
		ld	a,(hl)
		call	PAGE128

		ld	hl,flag_dir
		set	7,(hl)		;set flag, that we are about to test first item for "Total XY"
		bit	4,(hl)
		jr	z,dr2		;Z=LIST= do not change bit 2

		set	3,(hl)		;NZ=NLST=change bit 2 to 1=full
		ld	hl,ftp_nlst	
					;set retrieve (abbreviated/full)
dr1_1		xor	a		;"call"= full list
		ld	b,a
		ld	c,a
		set	1,(ix+1)	;set flag as full
		jr	dr1


dr2		res	3,(hl)		;LIST set, set current command type to LIST also
		bit	2,(hl)		;user wish abbreviated(0) or full(1)?
		res	1,(hl)		;set flag as abbreviated 
		ld	hl,ftp_list
		jr	nz,dr1_1	;NZ=LIST+full


		ld	a,#C3		;"jp"= abbreviated
		ld	bc,dr5_skip
dr1		ld	de,dr_switch
		ld	(de),a
		inc	de
		ld	a,c
		ld	(de),a
		inc	de
		ld	a,b
		ld	(de),a

		and 	a
		call	send_ftp_command_in_passive_mode
					;answer ok, now you may retrieve directory data
		or	a		;if return code= 226= transfer ok, mark it in transfer_flag
		ld	hl,226
		sbc	hl,de
		ld	hl,transfer_flag
		ld	a,3		;3=incomplete
		jr	nz,dr12
		xor	a
dr12		ld	(hl),a

		ld	iy,0		;reset file/item counter. if LIST, then iy= file counter, ix+32=dir counter
					;if NLST, then only iy= item counter
;		ld	(ix+32),0	;reset also dir counter
		ld	hl,dir_counter
		xor	a
		ld	(hl),a
		inc	hl
		ld	(hl),a		
		res	5,(ix+1)	;set flag for files, the routine is able to change it later, if needed		


		ld	hl,first_item
		ld	de,ftp_dir_start
		ld	bc,9
		ldir
		ld	(dr10+1),de
;		push	de

		call	dr_get_data

dr10		ld	hl,#5555	;pop	hl
		dec	hl
		dec	hl		;HL=floating address for dir saving into buffer, first item
		ld	(item_addr),hl
	
		ld	a,(flag_dir)		;"Total XY" get rid off only in LISTabbr mode. Test which mode we are in.
		and	%00010100
		jr	nz,dr_item_loop		;NZ different mode than LISTabbr, proceed normaly
	
dr13		scf				;new in 1.01. Some servers start with string "Total xx" where xx= number" This we need to get rid off
		call	rece_byte
		jr	z,dr13
		cp	"t"
		push	af
		jr	nz,dr_item_loop		;if NZ then A=either "-" or "d"
						;word "Total xx" at the begining of dir, get rid off it...
dr14		scf
		call	rece_byte
		jr	z,dr14
		cp	#A
		jr 	nz,dr14
		pop	af
		res	7,(ix+1)		;we got rid off very first "Total XY", set flag accordingly



dr_item_loop	ld	bc,0			;BC=item length counter
		ld	(hl),c			;put 2x 0 at the item start, if next item will not be completed, 2x0= end of list

		inc	hl			;1x inc_pos
		ld	a,h
		or	a
;		cp	high start_address
		call	z,dr_end_err
		ld	(hl),c			;put 2x 0 at the item start, if next item will not be completed, 2x0= end of list

		inc	hl			;2x inc_pos
		ld	a,h
		or	a			;ve 128k verzi testujeme 0
;		cp	high start_address
		call	z,dr_end_err
		ld	(hl),c

		inc	hl			;3x inc_pos
;		ld	(hl),c			;1 st item byte (flags), needs to be zero at initial phase
		inc	bc			;1x inc item length counter
		ld	a,h
		or	a
;		cp	high start_address
		call	z,dr_end_err


dr_switch	jp	dr5_skip		;"jp dr5_skip" or 4xNOP
						;we dowload full dir
;		bit	7,(ix+1)		;checking "Total XY" first item?
;		jr	z,dr4			;Z=no

;		pop	af			;new in 1.01, A= either "-" or "d"
;		jr	dr4_1

dr4		scf
		call	rece_byte		;neposkozuje zadny registr
		jr	z,dr4			;timeout!!!

dr4_1;		res	7,(ix+1)		;very first item checked
		cp	#D
;		jr	nz,dr7			;better way, to add also test for #A
;		jr	nz,dr5_all		;potential place for bug, if here ends flow of data
		jp	nz,dr5_all

;		call	dr_dec_chunk

		dec	de			;1x dec rest_chunk
		ld	a,d			;;(ale musi!!) toto tu nemusi vubec byt, byte #D neni nikdy posledni
		or	e
		call	z,dr_get_data
;		jr	z,dr1			;Z=no more bytes available in module, ask for another

		scf
		call	rece_byte		;timeout, get rid off byte #A

		dec	de	;2x dec rest_chunk;!!!!DEC DE, but test it lower, see 0.94
;;		ld	a,d			;testing data was too early, item not closed
;;		or	e
;;		call	z,dr_get_data

		inc	hl			;4x dr_inc_pos
		ld	a,h
		or	a
;		cp	high start_address
		call	z,open_item_invalid

		inc	hl			;5x dr_inc_pos
		ld	a,h
		or	a
;		cp	high start_address
		call	z,open_item_invalid

			;item completed, close it with length bytes at its start and end

		push	hl			;next position address start
		push	de			;DE=rest_chunk
		dec	hl
;		ld	bc,(item_count_len)	;set item length at the item start and end
		ld	(hl),b
		dec	hl
		ld	(hl),c
		ld	de,item_addr
		ld	a,(de)
		ld	l,a
		inc	de
		ld	a,(de)
		ld	h,a

		ld	(hl),c
		inc	hl
		ld	(hl),b
		pop	de			;DE=rest_chunk		
					;test if 2 bytes after current item available
		pop	hl		;HL=new item start address

;		inc	hl			;dr_inc_pos
;		ld	a,h
;		cp	high start_address
;		jr	z,open_item_invalid_1

		inc	hl			;dr_inc_pos
		ld	a,h
		or	a
;		cp	high start_address
		call	z,open_item_invalid_1

		xor	a			;fill 0s as a dir end signal/
		ld	(hl),a
		dec	hl
		ld	(hl),a


		ld	(item_addr),hl		;HL=position of new item in the buffer

		bit	4,(ix+1)		;muzu pouzit BC a IX, IY
		jr	nz,dr8			;Z=LIST, NZ=NLST
		bit	5,(ix+1)		;current item file or dir?
		jr	z,dr8			;Z=current item= file
;		inc	(ix+32)
		ld	bc,(dir_counter)
		inc	bc
		ld	(dir_counter),bc
		jr	dr9
dr8		inc	iy			;increase file/item counter

/*
		push	hl			;zjistujeme problem s nacitanim metadat +IPD
		push	de			;for testing purposes, can halt reading on any item
		push	iy
		pop	hl
		or	a
		ld	de,519
		sbc	hl,de
		pop	de
		pop	hl
		jr	nz,dr9
		halt				;halt on item number 635
*/

dr9
;;		dec	hl
;		dec	hl			;to go back to the start of the next item

		ld	a,d			;0.94, testing data was too early, item not closed
		or	e			;tady teprve testujeme bajt #D!!
		call	z,dr_get_data


;		dec	de			;dec rest_chunk, byte #A
;		ld	a,d			;only after item has been saved, test
;		or	e			;data availability
;		call	z,dr_get_data		;item is now fully closed, see previous lines

		jp	dr_item_loop

open_item_invalid_1
		pop	hl
open_item_invalid
		jp	dr_end_err
;;		xor	a
;;		ld	(item_addr),a		;limit the last valid item
;;
;;dir_continues	call	data_available_in_module
;;		jp	z,dr_end_ok		;Z=directory completed
;;		jr	dr5_all

;we leave unwanted bytes from the item
;eg. "-rw-r--r--    1 529      529          5460 Oct 21 19:57 PsychoSoldier.txt"
dr5_skip	bit	7,(ix+1)		;checking "Total XY" first item?
		res	7,(ix+1)		;very first item checked	
		jr	z,dr5s			;Z=no
		pop	af			;new in 1.01
		jr	dr5s1

dr5s		scf
		call	rece_byte
		jr	z,dr5_skip
;						;pokud naèteš #D, jde o konec adresáøe, zkusme ètení ukonèit a bude to super rychlé a spolehlivé
;		cp	#D
;		jp	z,dr_end_ok		;zkusíme, co to udìlá


dr5s1		cp	"d"
		res	5,(ix+1)		;set flag to indicate item is a file
		jr	nz,dr5_1		;NZ= není to adresáø, jde o soubor
		sub	#20			;make "d"->"D"
		set	5,(ix+1)		;set flag to indicate item was a dir
		jr	dr5_2


dr5_1		ld	a,#20
dr5_2		inc	bc
		ld	(dr5_6+1),bc		;BC=item counter
		ld	(hl),a
		dec	de
		ld	a,d
		or	e
		call	z,dr_get_data
		inc	hl
		ld	a,h
		or	a
;		cp	high start_address
		call	z,open_item_invalid

;new concept of skipping first item part- the attributes
;skip, until you meet byte #20
dr5_7		scf
		call	rece_byte
		ex	af,af'
		dec	de
		ld	a,d
		or	e
		call	z,dr_get_data
		ex	af,af'
		cp	#20
		jr	nz,dr5_7



		ld	b,3			;left: "    1 529      529          5460 Oct 21 19:57 PsychoSoldier.txt"
dr5_3		scf
		call	rece_byte
		ex	af,af'
		dec	de			;2x dec rest_chunk, prior to reading byte!!!! (other dec rest_chunk are after byte reading!!)
		ld	a,d
		or	e			;leave out all attributes
		call	z,dr_get_data

		ex	af,af
		cp	#20
		jr	z,dr5_3
dr5_4		scf
		call	rece_byte
		ex	af,af'
		dec	de			;2x dec rest_chunk, prior to reading byte!!!! (other dec rest_chunk are after byte reading!!)
		ld	a,d
		or	e			;leave out all attributes
		call	z,dr_get_data

		ex	af,af
		cp	#20
		jr	nz,dr5_4
		djnz	dr5_3

						;now we should have: "          5460 Oct 21 19:57 PsychoSoldier.txt"
;and here is problem. We cannot remove spaces until 1st char, because, later items do not have to have spaces here, but start with characters. And we do not want to loose the characters. These characters are length of file.

;		ld	b,1			;remove 1x space!!! cannot do more. Otherwise items would be unaligned in a list.
;;dr5_5		scf
;;		call	rece_byte
;		ex	af,af'
;;		dec	de			;2x dec rest_chunk, prior to reading byte!!!! (other dec rest_chunk are after byte reading!!)
;;		ld	a,d
;;		or	e			;leave out all attributes
;;		call	z,dr_get_data

;		ex	af,af'
;		cp	#20
;		jr	z,dr5_5
;		jr	nz,dr5_6		;new in 1.01_if not space char, continue, otherwise loop 4x
;		djnz	dr5_5			;finished: this is waiting:"      5460 Oct 21 19:57 PsychoSoldier.txt"

;		ld	a,#CD		;"call"= full list
;		ld	bc,rece_byte
;		push	hl
;		ld	hl,dr_switch
;		ld	(hl),a
;		inc	hl
;		ld	(hl),c
;		inc	hl
;		ld	(hl),b
;		pop	hl			;HL= floating address
dr5_6		ld	bc,#5555		;BC= item counter
;		jp	dr4_1			;in A already first non #20 byte
		jp	dr4			;no need start from dr3
;		jr	dr3			;accept rest of item, all bytes, now


dr5_all		ld	(hl),a			;save one byte of dir to buffer and continue
;		call	dr_item_len_count
		inc	bc			;2x inc item_len_counter
		inc	hl			;6x dr_inc_pos
		ld	a,h
		or	a
;		cp	high start_address
		call	z,dr_end_err
;		jr	nc,dr_end_err
		dec	de			;3x dec rest_chunk
		ld	a,d
		or	e
		call	z,dr_get_data
;		call	dr_dec_chunk
;		jr	c,dr3			;????
;		jp	dr3
		jp	dr4



dr_end_ok	;ld	(ix+23),0		;0=transfer ok, was assigned earlier
		ld	a,(ix+23)		;if transfer was ok, do not test 226 reply
		or	a
		jr	z,dr_end_ok1
		call	ask_for_reply_in_passive_mode	;look for code 226
		ld	de,226
		or	a
		sbc	hl,de
		ld	a,2
		jr	nz,dr_end_ok1		;2=code 226 not obtained, seems like error
		xor	a
dr_end_ok1	ld	hl,transfer_flag
		ld	(hl),a
		jr	dr_end

dr_end_err	ld	hl,(fdp_pointer)	;posuzujeme, zda uz jsme na konci bufferru pro ftp dir
		ld	a,(hl)
		inc	hl
		ld	(fdp_pointer),hl	;posun na dalsi pozici
		cp	#FF			;ending byte
		jr	z,dee1			;Z=ano, neni se kam posunovat, koncime s nacitanim

		call	PAGE128			;naber dalsi stranku
		ld	hl,ftp_dir_start
		ret				;vrat se a pokracuj v nacitani ftp adresare do nove stranky

dee1		pop	hl			;zbavme se RETu
		ld	(ix+23),3		;3=transfer of dir incomplete (not enough memory)
		ld	hl,(item_addr)		;cancel item being uploaded
		xor	a
		ld	(hl),a
		inc	hl
		ld	(hl),a

dr_end		call	set_3_5mhz
		ld	hl,at_cipclose1		;close data channel-not needed, will be closed automatically
		call	send_string		;but if Transfer incomplete, the channel have to be closed
;		ld	hl,closed		;if already closed, the answer will be "UNLINK   ERROR"
;		call	check_module_answer
;		ld	c,43
;		jp	c,error_handler
		call	clear_rece_buf

		call	passive_receive_off
		push	iy
		pop	hl
		ld	(item_file_count),hl	;save number of items/files

;		call	set_3_5mhz		;seem to make problems, put it later
;		ld	hl,at_cipclose1		;close data channel. Needed, if channel not closed with directory retrieve completion
;		call	send_string
;		ld	hl,closed
;		call	check_module_answer
;		ld	c,43			;anser will be either CLOSED, or UNLINK ERROR (in case chanel had been closed)
;		jp	c,error_handler

		jr	dr6			;continue to directory display


						;nová rutina, musíme ji callovat
dr_get_data	ld	(drgd2+1),bc
		exx

		call	KEYSCAN
		cp	01			;test BREAK key
		jr	nz,drdg6
;		jr	nz,drdg3
		ld	hl,basic_end
		ld	d,0
		ld	a,fi_len
		dec	a
		dec	a
		ld	e,a
		add	hl,de
		ld	a,(hl)
		jr	z,drg1			;Z=no items read yet
;		set	1,(ix+1)		;directory retrieve user aborted, but some items were read
		ld	(ix+23),1		;transfer aborted
		pop	hl			;to get rid off previous call
		jr	dr_end

drg1		res	0,(ix+1)		;set flag dir has not been read		
		jp	fdfm7			;same routines as file download abort


drdg6		call	data_available_in_module_dir
		jr	z,drgd1
		ld	b,h
		ld	c,l
		call	ask_for_data_in_passive_mode
		exx
		ld	de,(rest_chunk)
drgd2		ld	bc,#5555		;nutnost zachovat BC
		ret
drgd1		pop	hl			;do not return, jump directly to end
		jp	z,dr_end_ok



dr6		call	print_working_directory
		call	print_dir_files_items	;prints number of items/dirs/files
		ld	de,menu_dir
		ld	hl,txt_adr_dir_info+22
		call	PRINTHL
;		ld	hl,ftp_path		;toto asi netøeba se piplat s pointerem
;		ld	(ftp_path_pointr),hl	;after dir reading, set path to its very start
		set	0,(ix+1)		;indicate that dir has been retrieved
;		ld	a,3
;		cp	(ix+23)
		ld	a,(ix+23)
		cp	3
		jr	z,dr11
		cp	1
		jr	nz,dir_move		;NZ=print status only in case of out of memory
		
dr11		call	print_transfer_status

;moving through items in directory, OUT=NZ=move was ok, Z=start or end of dir reached
;item= byte 0,1=length of the item, 2=info byte, iteme data, last 2 bytes=length of the item

;up/down, move through dir, initialisation	
dir_move	ld	hl,0
		ld	(mark_counter),hl	;marked items
		bit	6,(ix+1)
		jr	nz,dir_move1		;NZ=we go updir, set directory from 1st pos
		
		ld	de,(item_checksum)
		ld	a,d
		or	e
		jr	z,dir_move1


		ld	hl,(cur_item_adr_tmp)	;check the checksum
;		ld	de,(item_checksum)
		ld	a,d
		or	e
		jr	z,dir_move1
		ld	a,(hl)
		cp	e
		jr	nz,dir_move1		;first byte not match, display from start
		dec	hl
		dec	hl
		ld	a,(hl)
		cp	d
		jr	nz,dir_move1		;second byte not match, display from start
		
		ld	hl,0
		ld	(item_checksum),hl	;signal, next reading go from start

		ld	de,(cur_item_adr_tmp)	;DE=cur_item_adr_tmp
		ld	hl,(item_pg_start_tmp)
		ld	a,(wind_curs_item_tmp)	;now, load parameters from previous updir
		ld	bc,(cursor_w_curad_tmp)
		jr	dir_move2
						;BC=cursor_w_curad
						;DE=cur_item_adr
						;HL=item_pg_start
						;A=wind_curs_item
dir_move1	xor	a
		call	PAGE128			;first page must be paged in
		ld	hl,ftp_dir_start
dir_move3	ld	d,h			;here jumps find function with HL
		ld	e,l
		ld	a,1
		ld	bc,(cursor_w_stadr)

;dir_move1	ld	hl,basic_end		;start of the buffer= first item
dir_move2	ld	(cur_item_addr),de	;start dir from item in HL
		ld	(item_pg_start),hl
;		call	prn_mark_items
;		ld	a,1
		ld	(wind_curs_item),a
;		ld	hl,(cursor_w_stadr)	;starting position of window
		ld	(cursor_w_curad),bc	;and make it current add
		call	wifi_unwait
dir_move4	call	print_page		;print without settings parameters
		call	prn_mark_items
		jp	draw_cursor
;;	call	print_page	;;;vyhodit pak	
;;	call	draw_cursor
;;	jp	key_loop	;;;vyhodit pak	

item_addr	dw	#5555			;starting address of dir item
;item_count_len	dw	#5555			;temporary length of dir item being downloaded

go_updir;	call	check_updir
		res	6,(ix+1)		;signal, you go updir
		bit	0,(ix+1)
		jp	nz,go_updir1
		jp	directory_retrieve	;if dir not read, read it new with BREAK key


;check_updir	ld	hl,(item_checksum)
;		ld	a,h
;		or	l
;		ld	hl,flag_dir
;		res	6,(hl)
;		ret	nz
;		set	6,(hl)
;		ret

download_screen	ld	(blen),de		;length of screen= counter (6144 or 6912)
;		ld	de,INPBUFF
;		ldir
;		call	send_type_command_i	;for rigid servers needed

	IFDEF hgfx64x24
		call	hgfx_off
	ENDIF
		call	set_20mhz
		call	enter_passive_mode
		call	passive_receive_on

		ld	hl,ftp_retr
		scf
		call	send_ftp_command_in_passive_mode

		ld	hl,#4000
		ld	(buff_add_float),hl

ds1		call	data_available_in_module_file
		jr	nz,ds2

;	IFDEF hgfx64x24
;		call hgfx_on			;vyresit
;	ENDIF

		ld	c,44
		call	display_error
download_screen_end

		call	set_3_5mhz
		res	4,(ix+0)		
		call	akey1
		set	4,(ix+0)

		call	passive_receive_off

	IFDEF hgfx64x24

		call hgfx_init

	ENDIF

		call	print_whole_screen
		call	print_dir_files_items
		ld	de,menu_dir
		ld	hl,txt_adr_dir_info+22
		call	PRINTHL
		call	print_ftp_status
		call	get_status_ftp
		jp	dir_move4		;start dir from where you ended

ds2		ld	b,h
		ld	c,l
		call	fdf_sub1
		ld	hl,(blen)
		ld	bc,(rest_chunk)
		or	a
		sbc	hl,bc
		jr	z,download_screen_end
		ld	(blen),hl
		jr	ds1



enter_directory	;and	a
;		call	get_item_name
;		ld	a,e
;		or	a
;		jr	nz,ed5			;NZ=file length not 6144 nor 6912
;		ld	a,h
;		cp	#18
;		jr	nz,ed5			;NZ=file length not 6144 nor 6912
;		cp	#1B
;		jr	z,download_screen
;
		call	send_type_command_i	;for rigid servers needed
		call	clear_inp_buf

		scf
		call	get_item_name
		ld	de,INPBUFF
		ldir

		or	a
		jr	z,ed1			;Z=item is a directory
		cp	4
		jr	z,go_updir1		;Z=item is ".."		
						;if A=2, item is NLST mode and could be file or dir


		ld	a,1
		ld	hl,ftp_size
		ld	de,213
		call	send_ftp_command	;ošetøit chybu!!! pro pøípad špatné odpovìdi, nebo NLST
;		jp	c,chyba
		ld	de,226
		or	a
		sbc	hl,de
;		jp	nz,chyba

		ld	bc,RX_buf+4
		call	ConvRStr32
		ld	a,l
		or	h
		jr	nz,ed1


		ld	a,e
		or	a
		jr	nz,ed1			;NZ=file length not 6144 nor 6912
		ld	a,d
		cp	#18
ed5		jp	z,download_screen	;NZ=file length not 6144 nor 6912
		cp	#1B
		jr	z,ed5


;ed5		ex	af,af'
;		or	a			;Z=item is a directory
;		jr	z,ed1
;;		cp	2
;;		jr	z,ed1			;Z=NLST, item could be a directory, but this is not sure
;		cp	4
;		jr	z,go_updir1		;Z=item is ".."
;		ret	nz			;Z=item is ".."

;;ed1		exx				;HL=dir start, BC=dir length
;;		call	clear_inp_buf
;;		exx

ed1		scf
		call	get_item_name
		ld	a,(hl)
		cp	"."
		jr	nz,ed2			;not ".."item to direct updir
		inc	hl
		cp	"."
		dec	hl
		jr	nz,ed2

go_updir1	res	6,(ix+1)		;signal, we go updir
;		call	check_updir
		xor	a			;we want to go updir
		ld	hl,ftp_cdup
		ld	de,200
		jr	ed3

ed2	;	ld	de,INPBUFF
	;	ldir

		call	save_dir_position	
;		set	6,(ix+6)

ed6		ld	a,1
		ld	hl,ftp_cwd
		ld	de,250
ed3		call	send_ftp_command
		jr	nc,ed4
;		push	bc			;preserve carry
		ld	de,200
		or	a
		sbc	hl,de
;		pop	bc
		jr	z,ed4			;Z=also valid code
		add	hl,de
		ld	de,250
		or	a
		sbc	hl,de
		jr	z,ed4
;		push	bc			;NZ=error
;		pop	af
		ret
;		ret	c			;or jp c,error_handler
ed4		call	undraw_cursor
		jp	directory_retrieve





key_down	call	undraw_cursor
		ld	bc,cur_item_addr
		call	item_add
		jr	nz,kd4
		jp	draw_cursor
;		ret	z			;Z=end of dir, nothing to display

kd4		ld	hl,wind_curs_item
		ld	a,(hl)
		cp	(ix+16)
		jr	nc,kd1			;C=cursor at the end of the window

		inc	(hl)			;inc cursor position
;		call	undraw_cursor
		ld	hl,(cursor_w_curad)
		ld	de,32
		add	hl,de
		ld	(cursor_w_curad),hl
kd2		jp	draw_cursor
		
kd1		ld	bc,item_pg_start
		call	item_add
kd3		call	print_page
		jr	kd2

key_up		call	undraw_cursor
		ld	bc,cur_item_addr
		call	item_sub
		jr	z,kd2
;		ret	z			;Z=start of dir, nothing to display

		ld	hl,wind_curs_item
		ld	a,(hl)
		cp	1
;		or	a
		jr	z,ku1			;z=cursor at the start of the window

		dec	(hl)			;dec cursor position
;		call	undraw_cursor
		ld	hl,(cursor_w_curad)
		ld	de,32
		or	a
		sbc	hl,de
		ld	(cursor_w_curad),hl
		jr	kd2
;		jp	draw_cursor


ku1		ld	bc,item_pg_start
		call	item_sub
		jr	kd3
;		jp	print_page


item_add;	ld	hl,(cur_item_addr)	;move pointer one item add,IN=HL=(item addr to add)
		push	bc
		ld	a,(bc)
		ld	l,a
		inc	bc
		ld	a,(bc)
		ld	h,a
		
		ld	a,(hl)
		inc	hl
		ld	d,(hl)
		or	d
		pop	bc
		ret	z			;Z=we are at the end of directory
		ld	e,a
		inc	hl
;		inc	hl
		add	hl,de
		inc	hl
		inc	hl

		push	hl
		ld	a,(hl)
		inc	hl
		ld	l,(hl)
		or	l
		pop	hl
		ret	z			;Z=we are at the end of directory		

iu1		ld	d,h
		ld	e,l
		ld	h,b
		ld	l,c
		;ld	(cur_item_addr),hl
		ld	(hl),e
		inc	hl
		ld	(hl),d
		inc	b		;set NZ
		ret

item_sub;	ld	hl,(cur_item_addr)
		push	bc
		ld	a,(bc)
		ld	l,a
		inc	bc
		ld	a,(bc)
		ld	h,a

		or	a
		ld	de,basic_end
		sbc	hl,de
		add	hl,de
		pop	bc
		ret	z		;Z=we are at dir start
;		jr	c,pgd2		;C=we are at the starting item already, set NZ
		dec	hl
		ld	d,(hl)
		dec	hl
		ld	e,(hl)
		or	a
		sbc	hl,de
;		dec	hl
		dec	hl
		dec	hl
		jr	iu1

;0.92a*******************************
pg_up;		ld	hl,item_add
;		ld	(infsi3+1),hl	;modify the routine to add
;		ld	(mc3+1),hl

		scf
		call	count_from_start_item
		jr	nz,pgu1		;NZ=current page not full

pgu2		ld	e,a
		ld	a,(ix+21)
		cp	(ix+16)		;is cursor on the last item on page?
		ld	a,e
;		call	cfsi1		;return page starting item
		jr	nz,move_cursor	;NZ=not

pgu3		and	a
		call	count_from_start_item
;		push	af
		call	print_page
		dec	b		;with this solution we are dependant on print_page output!!!
		inc	b
		ld	a,(ix+16)
		jr	z,pgu4
		sub	b		
		inc	a		;A= number of items on the following page
;		pop	af
pgu4		ld	b,a
		jr	nz,move_cursor
		jr	mc5		;move item pointer
;		ret

pgu1		cp	(ix+16)		;is the cursor on the last item?
		ret	z
					;continue to move cursor
move_cursor				;move cursor to line A (1-8)
;IN=A= position (1-8)
		push	af		;not needed, routine does not use A anymore
		call	undraw_cursor
		pop	af
		ld	(ix+21),a	;current cursor line
		ld	b,a
		ld	hl,(cursor_w_stadr)
		dec	a
		ld	de,32
mc1		or	a
		jr	z,mc2
		add	hl,de
		dec	a
		jr	mc1
mc2		ld	(cursor_w_curad),hl



mc5		ld	hl,(item_pg_start)
		ld	(cur_item_addr),hl
		dec	b

mc4		push	bc		;B=number of lines to move item pointer
		ld	bc,cur_item_addr
mc3		call	item_add
		pop	bc
		djnz	mc4
		jp	draw_cursor
		

;count rest of items forward
;if page< 8, do not change starting item
;IN=C=return original item_pg_start, NC= do not return original item_pg_start
;OUT=NZ<8, Z>=8, A= number of available items
count_from_start_item
		rr	b		;preserve carry
		push	bc
		ld	hl,item_pg_start
		ld	e,(hl)
		inc	hl
		ld	d,(hl)		;DE=starting item
		exx			;save HL and DE

infsi_sub	ld	b,(ix+16)	;B=items a page. OUT=Z=A=8 found, NZ=found <8=A=number of found pages
infsi1		push	bc
		ld	bc,item_pg_start
infsi3		call	item_add
		pop	bc
		jr	z,infsi2
		djnz	infsi1
infsi2		inc	b
		dec	b
		ld	a,(ix+16)
		jr	z,infsi4
		sub	b
		inc	a		;A= number of items on the following page
infsi4		pop	bc		;Z=8 items found, NZ=<8 items found
		rl	b		;return carry
		ret	nc
;		ret	z		;Z=8 items found, NZ=<8 items found
;		sub	b
;		inc	a		;A= number of items on the following page
					;items<8 do not change page start		
cfsi1		exx
		ld	(hl),d
		dec	hl
		ld	(hl),e		;return original starting item
		ret			;A=items/page

		
	





pg_down;		ld	hl,item_sub
;		ld	(infsi3+1),hl	;modify the routine to add
;		ld	(mc3+1),hl

		ld	a,1
		cp	(ix+21)	;current cursor line
		jr	z,pgd1

		call	pgd_sub1		;move cursor
		jr	pgd3

pgd1		call	pgd_sub2		;Z=cursor on first position already
		jp	z,dir_move1
		call	print_page
		call	pgd2_4
pgd3		jp	draw_cursor



		
pgd_sub1	ld	(ix+21),a
		push	af
		call	undraw_cursor
		pop	af
		ld	hl,(cursor_w_stadr)	;move cursor
		dec	a
		ld	de,32
pgd2_1		or	a
		jr	z,pgd2_3
		add	hl,de
		dec	a
		jr	pgd2_1
pgd2_3		ld	(cursor_w_curad),hl
pgd2_4		ld	hl,(item_pg_start)
		ld	(cur_item_addr),hl
		ret


pgd_sub2	ld	b,(ix+16)	;items a page
pgd1_1		push	bc
		ld	bc,item_pg_start
		call	item_sub
		pop	bc
		ret	z
;		jp	z,dir_move	;Z=we are on dir start
		djnz	pgd1_1
		inc	b		;indicate NZ
		ret



	
;********************************
	
print_item	ld	hl,(cur_item_addr)	;print one item
		ld	e,(hl)
		inc	hl
		ld	d,(hl)
		dec	de
		inc	hl
		inc	hl
		push	hl			;HL=start of item for print
		ld	hl,line_length
		or	a
		sbc	hl,de
		add	hl,de			;HL=line length
		inc	de
		jr	nc,pi_print_it		;NC=line<64, print it

		ex	de,hl			;DE=line length
		pop	hl			;C=line>64, print it with ".." at the end, ;HL=start of item for print
		ld	b,h
		ld	c,l		
		add	hl,de			;move to pos 64
		ld	a,(hl)
		ld	(hl),0
		push	af
		ld	a,"."
		dec	hl
		ld	e,(hl)
		ld	(hl),a
		dec	hl
		ld	d,(hl)
		ld	(hl),a
		push	de
		push	hl
		ld	hl,(cur_lin_prn_adr)
		ld	d,b
		ld	e,c		
		call	PRINTHL
		pop	hl
		pop	de
		pop	af
		ld	(hl),d
		inc	hl
		ld	(hl),e
		inc	hl
		ld	(hl),a
;		ret
print_item_attrs	
		ld	hl,(cur_item_addr)
		ld	c,(hl)
		inc	hl
		ld	b,(hl)
		inc	hl
	IFDEF hgfx64x24
		ld	bc,unmark_item_i
	ELSE
		ld	a,unmark_no_curs	;A=7=not marked
	ENDIF
		bit	0,(hl)
		jr	z,pia1
	IFDEF hgfx64x24
		ld	bc,mark_item_i
	ELSE
		ld	a,mark_no_cursor	;A=2=marked
	ENDIF

	IFDEF hgfx64x24
pia1		ld	e,planar_oznac		;planar #40
		jp	dc_3
	ELSE	
pia1		ld	hl,(cursor_w_curad)
	ENDIF

/*
	IFDEF hgfx64x24
		cp	2
		ld	a,64+7			;polozku zvyraznujeme
		ld	b,#80
		jr	z,pia4
		ld	a,70			;a nezvyraznujeme
		ld	b,#20
pia4		ld	(pia3+1),a
		ld	a,b
		ld	(dc_5+1),a
		ld	a,l
		srl	a
		srl	a
		srl	a
		srl	a
		srl	a
		add	a,8
		ld	h,a
		ld	l,0

		ld	a,64
		ld	(VIDEO_REGS.MASK),a	;zvyrazneny text bude v BPL6
pia3		ld	a,64+7			;64+7= mark, 64=unmark
		ld	(VIDEO_REGS.COLOR),a	;barva cervena

;		ld	a,#80
		jp	dc_7			;dokresli kurzor
	ELSE
*/
		ld	b,32
pia2		ld	(hl),a
		inc	hl
		djnz	pia2
;		ld	(cursor_w_curad),hl
		ret
;	ENDIF

pi_print_it	pop	hl			;HL=start of item for print
		add	hl,de
		dec	hl
		ld	a,(hl)
		push	af			;save one length byte
		ld	(hl),0			;0 for print end
		push	hl
		or	a
		inc	hl
		sbc	hl,de
		ex	de,hl
		ld	hl,(cur_lin_prn_adr)
		call	PRINTHL
		pop	hl
		pop	af
		ld	(hl),a			;return one length byte
;		ret
		jr	print_item_attrs

print_page	;ld	hl,#4800
;		ld	b,8*8
;		call	cls_9_lines
		call	cls_9
		ld	hl,txt_adr_dir_display
		ld	(cur_lin_prn_adr),hl
		ld	b,(ix+16)		;prints whole page. Start=current item that a pointer is set to (cur_item_addr)
		ld	hl,(cur_item_addr)
		push	hl
		ld	hl,(cursor_w_curad)
		push	hl
		ld	hl,(cursor_w_stadr)
		ld	(cursor_w_curad),hl
		ld	hl,(item_pg_start)
		ld	(cur_item_addr),hl	;make item_pg_start current item

pp1		push	bc

	IFDEF hgfx64x24
		ld	a,3			;coulour 3 for directory
		ld	(VIDEO_REGS.COLOR),a
	ENDIF

		call	print_item		;length=number of lines (AP_a_page)
		ld	hl,(cursor_w_curad)
		ld	de,32
		add	hl,de
		ld	(cursor_w_curad),hl
		ld	hl,cur_lin_prn_adr+1
		inc	(hl)
;		call	move_lin_adr_u
		ld	bc,cur_item_addr
		call	item_add
		pop	bc
		jr	z,pp2			;Z=end of directory
		djnz	pp1

pp2		pop	hl			;return cur_item_addr
		ld	(cursor_w_curad),hl
		pop	hl
		ld	(cur_item_addr),hl

;	IFDEF hgfx64x24				;netreba, nastavuje zpet rutina print_item
;		ld	a,7			;back to coulour 7
;		ld	(VIDEO_REGS.COLOR),a
;	ENDIF


		xor	a			;set A=0 to eliminate key press
		ret




;roll item>64 chars
;BC <line_length, item_length>, eg.<64,200>
roll_item	ld	hl,(cur_item_addr)
		ld	c,(hl)
		inc	hl
		ld	b,(hl)
		inc	hl
		inc	hl
;		ld	(rik1+1),hl
		ex	de,hl
				;DE=start of item
		or	a
		ld	hl,line_length
		sbc	hl,bc	;BC=item length
		ret	nc	;NC=line<=64

;		ex	de,hl
		dec	bc
		ld	(roll_item_inc+1),bc
		ld	bc,line_length

		
		ld	a,(ix+21)		;count current item line address
		ld	hl,txt_adr_mezera	;=txt_adr_dir_display-1
ri1		inc	h
		dec	a
		jr	nz,ri1
		ld	(pir2+1),hl
		call	roll_item_inc		;initial press of key x

roll_item_key	exx
		call	KEYSCAN
		exx
		cp	"z"
		call	z,roll_item_dec
		cp	"x"
		call	z,roll_item_inc
		cp	0
		jr	z,roll_item_key
;		pop	hl
;rik1		ld	de,#5555		;initial item start, print item as it should be
;		ld	hl,(pir2+1)
;		call	PRINTHL
		push	af			;A=code key
		call	print_page
		pop	af
		jp	key_loop+3		;go on in ain key routine
;		jp	error_handler_loop	;any other key than z,x brings us from item roll

roll_item_inc	ld	hl,#5555		;upper limiter
		or	a
		sbc	hl,bc
		ld	a,h			;signal A=0 to avoid artificial key press
		ret	z
;		jr	z,roll_item_key
		inc	de
		inc	bc
		jr	print_item_roll

roll_item_dec	or	a
		ld	hl,line_length		;HL=length of item, lower limiter
		sbc	hl,bc
		ld	a,h			;signal A=0 to avoid artificial key press
		ret	z
;		jr	z,roll_item_key
		dec	de
		dec	bc

;IN=HL=start of the name
print_item_roll	push	bc			;save BC
		ld	b,line_length
;		ex	de,hl
;		ld	hl,(cursor_w_curad)	;tady musi byt vypocet radku polozky
pir2		ld	hl,#5555		;item line address

		push	de			;save item pointer
pir1		push	de
		push	bc
		ld	a,(de)
		call	CHAR
		pop	bc
		pop	de
		inc	de
		djnz	pir1
		pop	de			;renew item pointer
		
		pop	bc			;renew BC
		xor	a			;avoid key press
;		jr	roll_item_key
		ret		

;marking item=bit 0 in item attr byte
mark_item	ld	hl,(cur_item_addr)
		ld	c,(hl)
		inc	hl
		ld	b,(hl)
		inc	hl
		ld	a,1
		xor	(hl)
		ld	(hl),a			;bit properly set

		bit	0,(hl)
		ld	hl,(mark_counter)
		jr	z,mi1
		inc	hl
		jr	mi2
mi1		dec	hl			;decrease counter
mi2		ld	(mark_counter),hl
		call	prn_mark_items
		call	print_item_attrs	;print only attributes
		jp	key_down



;find item/s
find_items	ld	de,find_txt
		call	print_ez1

		call	input_line
		jp	z,clear_edit_zone	;Z=abort pressed
		ld	b,0			;BC=length of string, HL= start
;		ld	(ix+15),b		;mark counter
;		ld	(txtadd),hl		;zde dodelat case insensitive
		ld	(txtlen+1),bc		
				
		ld	hl,0
		ld	(mark_counter),hl

		ld	hl,(cur_item_addr)
		push	hl			;preserve current item pointer
		ld	hl,basic_end+fi_len-2
		ld	(cur_item_addr),hl	;set start of dir

		scf
		call	un_mark_all		;umark all previously marked items

	IFDEF hgfx64x24
		call	undraw_cursor		;zustaval viset kurzor po uspesnem hledani, toto by melo pomoct, a kurzor by mel zmizet
	ENDIF

find1		scf
		call	get_item_name
		ex	de,hl			;DE=start of current item			
;		cp	3			;if these 2 lines left out, will work with LIST full too
;		jr	z,find2

						;DE=item name addr
		call	search_by_Busy
		jr	nz,find2		;NZ=item does not match
		ld	hl,(mark_counter)
		inc	hl
		ld	(mark_counter),hl
		dec	hl
		ld	a,h
		or	l			;preserve 1st matching item
		jr	nz,find4
		pop	hl			;we do not want that old one
		ld	hl,(cur_item_addr)
		push	hl			;HL=1st matching item

;		inc	(ix+15)
find4		ld	hl,(cur_item_addr)
		inc	hl
		inc	hl
		set	0,(hl)			;mark the item as matching
		call	prn_mark_items

find2		ld	bc,cur_item_addr
		call	item_add		;move to next item
		jr	nz,find1		;Z=no more items

		call	clear_edit_zone
		ld	hl,(mark_counter)
		ld	a,h
		or	l
		pop	hl			;HL=matching or starting item
		ld	(cur_item_addr),hl
;		ret	z			;no match found, do nothing
;		pop	bc		;get rid off call
		jp	dir_move3

;mark or unmark all items
mark_all	and	a
		jr	unma1
unmark_all	scf
unma1		call	un_mark_all
		call	prn_mark_items
		jp	kd3		;print_page, draw_cursor

undraw_cursor	ld	hl,(cur_item_addr)
		ld	c,(hl)
		inc	hl
		ld	b,(hl)
		inc	hl
	IFDEF hgfx64x24
		ld	bc,mark_no_cursor
	ELSE
		ld	a,mark_no_cursor	;2
	ENDIF
		bit	0,(hl)
		jr	nz,dc_1
	IFDEF hgfx64x24
		ld	bc,unmark_no_curs
	ELSE
		ld	a,unmark_no_curs	;7
	ENDIF
		jr	dc_1

draw_cursor	ld	hl,(cur_item_addr)
		ld	c,(hl)
		inc	hl
		ld	b,(hl)
		inc	hl
	IFDEF hgfx64x24
		ld	bc,mark_cursor
	ELSE
		ld	a,mark_cursor		;58 kurzor na oznacenem souboru
	ENDIF
		bit	0,(hl)
		jr	nz,dc_1

	IFDEF hgfx64x24
		ld	bc,unmark_cursor	
	ELSE
		ld	a,unmark_cursor		;56 kurzor na neoznacenem souboru
	ENDIF
dc_1:
	IFDEF hgfx64x24
		ld	e,planar_kurzor		;planar #80
	ENDIF
dc_3:
		ld	hl,(cursor_w_curad)

;kresli kurzor na neoznacene polozce	56	znak=#80 dc_5		barva=#80 dc_8		OK	FUNGUJE na barve #80 je bila
;smaz kurzor na neoznacene polozce	7	znak=#20		barva=#80		OK	FUNGUJE na barve #80 je bila
;kresli kurzor na oznacene polozce	58	znak=#80		barva=#C0		OK	FUNGUJE na #c0 musi byt bila (podklad), a na #c7 cervena (pismo)
;smaz kurzor na oznacene polozce	2	znak=#20		barva=#C0		OK	FUNGUJE na #c6 musi byt bila

;oznacovani souboru			znak#80, barva 71, Paper 0, maska=64			OK	FUNGUJE	barvy musi byt 64=cerna, 71=cervena
;odoznacovani souboru			znak=#20, barva70, Paper 0, maska 64			OK	FUNGUJE barva 70=bila

;hodnoty ktere potrebujeme pro tisk kurzoru a oznaceni souboru
;planar:	#80, #40
;znak:		#80, #20
;barva:		#80, #C0, #46, #47 

;definuje se jen znak a barva (planar bude zvlast)
;mark_cursor		equ	#80C0
;unmark_cursor		equ	#8080
;mark_no_cursor		equ	#20C0
;unmark_no_cursor	equ	#20c6
;mark_item_i		equ	#8071
;unmark_item_i		equ	#2070

	IFDEF hgfx64x24
/*
						;pro HGFX budou specialni hodnoty, aktivovat pozdeji na zacatku kodu
		ld	e,#80			;znak
		ld	c,#20
		ld	b,e			;barva
		cp	56
		jr	z,dc_6

		cp	7
		ld	e,c
		jr	z,dc_6

		cp	58
		ld	e,#80
		ld	b,#C0
		jr	z,dc_6

		ld	e,c
		
dc_6		ld	a,e

;1 radek v HGFX= #200 bajtu, takze radek vynasobit 512ti
0
#40
#80
#C0
#100
#140
#180
#1C0

#200


		ld	(dc_5+1),a		;znak
		ld	a,b
		ld	(dc_8+1),a		;barva
*/

dc_7		ld	a,e			;kreslime kurzor do BPL v e
		ld	(VIDEO_REGS.MASK),a
		ld	a,c			;barva
		ld	(VIDEO_REGS.COLOR),a
		ld	a,b
		ld	(dc_5+1),a		;znak

/*stary zpusob bez FDMA, jen pomoci charout, z #5900 udelame #0800pro charout
		ld	a,l
		srl	a
		srl	a
		srl	a
		srl	a
		srl	a
		add	a,8
		ld	h,a		
		ld	l,0		;HL=poloha kurzoru dle radku
*/
;nove pocitame polohu pro linearni, z #5900 udelame #1000
		ld	a,l
		srl	a
		srl	a
		srl	a
		srl	a
		srl	a
		add	a,8

		add	a,a		;vynasobime 8
		add	a,a
		add	a,a

		ld	l,a
		ld	h,0		;v hl mame pozadovanou adresu HGFX VRAM- radek

;		ld	(FDMAreg.FD_Adr),hl	;adresa radku pro kurzor
;		ld	(#5b09),hl
		ld (VIDEO_REGS.OFFSET_Y),hl
;;		ld	hl,0			;nulty sloupec
;		ld (VIDEO_REGS.OFFSET_X),hl
;		ld	(#5b00+#B),hl		;FDMA FD_Copy
;		ld	(#5b00+#D),hl		;FDMA FD_Mod

		call	set_fdma_to_fill_len_in_bc_512
		ld	(VIDEO_REGS.OFFSET_X),hl	;sloupec 0
;;		ld	(FDMAreg.FD_Copy),hl
;;		ld	(FDMAreg.FD_Mod),hl

dc_5		ld	hl,0			;znak vyplne bud #80, nebo #20, bhodnota bude v L, H zustane 0
		ld	(FDMAreg.FS_Adr),hl
;		ld	(#5b03),hl
;;		ld	hl,512
;;		ld	(#5b01),hl
;		ld	(FDMAreg.F_len),hl
		ld	a,%00100000
;		ld	(#5b00),a
		ld	(FDMAreg.F_mode),a	;spust FDMA

/*stary zpusob tisku kurzoru bez FDMA
		ld	b,64
dc_4		push	bc
dc_5		ld	a,128			;obdelnik=znak #80 obashuje same #FFka, kurzor kresli, znak #20 pak maže
		call	CHAR
		pop	bc
		djnz	dc_4
*/

		call	set_hgfx_ink_planar	;vracime ink=7, planar= 63
		call	set_fdma_to_chars

	ELSE

		ld	b,#20
dc_2		ld	(hl),a
		inc	hl
		djnz	dc_2
;		ld	a,(ix+15)		;???? why ix+15 not in use, ix+21 is in use instead

	ENDIF
		xor	a			;A=0 to avoid artifical key press
		ret

;kurzory zacinaji na:	#5900, #5920, #5940, #5960, #5980, #59a0, #59c0, #59e0
;			0	32	64	96	128	160	192	224
;odpovida:		#0800, #0900, #0a00, #0b00, #0c00, #0d00, #0e00, #0f00
;vzorec: (zdroj/32)+8

wind_cls	ld	hl,#4860		;clears window with AP list, line 3
		ld	a,(ix+16)
		add	a,a
		add	a,a
		add	a,a
		ld	b,a

	IFDEF hgfx64x24
		ld	c,#03
	ENDIF	
		jp	cls_9_lines



block_asci	ds	10		;blocks converted to ASCII, (used by progress display)
		db	0



;	ld	hl,adr
;	ld	a,2
;	xor	(hl)
;	ld	(hl),a	;spravne nastavovani bitu pres xor, nahradit do nize uvedenych rutin

set_onoff	bit	2,(ix+3)	;find out which wifi is it, MB or el? (el wifi cannot be turned off)
		ret	z
		ld	a,8		;toggle bit 3 of flag1 (Wifi on/off on quit)
		xor	(ix+0)
		ld	(ix+0),a
prn_w_onoff	bit	3,(ix+0)	;print WIFI ON/OFF status
		ld	de,off
		jr	z,set_w_onoff_p
		ld	de,on
set_w_onoff_p	ld	hl,txt_adr_menu2+7
		jp	PRINTHL

set_alogin	ld	a,2		;toggle bit 1 of flag1 (auto login on/off)
		xor	(ix+0)
		ld	(ix+0),a
prn_alogin	bit	1,(ix+0)	;print auto login status
		ld	de,yes
		jr	z,prn_alogin_p
		ld	de,no
prn_alogin_p	ld	hl,txt_adr_menu1+17
		jp	PRINTHL


set_filename	ld	de,enter_fil_nam	;set new default file name
		call	print_ez1

		ld	de,var_name
		push	de
		call	input_line
		pop	de
;		ret	z			;Z=abort pressed during input
		jp	z,clear_ini_keyl	;Z=abort pressed during input, carry out clear_edit_line+jp to key_loop
		ldir
		ex	de,hl
		ld	(hl),0
		jr	prn_file_start

set_start	ld	de,enter_start_add	;set new default file name
		call	print_ez1
		call	input_line
;		ret	z			;Z=abort pressed during input
		jp	z,clear_ini_keyl	;Z=abort pressed during input, carry out clear_edit_line+jp to key_loop
		ex	de,hl
		call	ConvRStr16
		ld	(var_start),hl

prn_file_start	
	IFDEF hgfx64x24
		ld	bc,#0111
	ELSE
		ld	hl,#5000+(32*1)	;print line 17 with filename and start address
		ld	b,8*1
	ENDIF
		call	cls_9_lines
		ld	de,file
		ld	hl,txt_adr_file
		call	PRINTHL
		ld	de,var_name
		call	PRINT
		ld	de,start
		call	PRINT
		ld	hl,(var_start)
		ld	de,block_asci
		push	de
		call	HL2ASCII
		ld	a,h
		ld	(de),a			;nuluj posledni pozici tisku
		pop	de
pfs1		call	PRINT
		jp	clear_edit_zone

set_user	ld	de,enter_usr
		call	print_ez1

		ld	de,var_user
su1		push	de
		call	input_line
		pop	de
		ld	a,b			;B=0
		ld	(INX_HS+1),a		;vrat NOOP, puvodni hodnota, vypisuje ASCII, ne "XXXX"
;		ret	z			;Z=abort pressed during input
		jp	z,clear_ini_keyl	;Z=abort pressed during input, carry out clear_edit_line+jp to key_loop
		ldir
		ex	de,hl
		ld	(hl),0
		jr	prn_host_usr_psw

set_pass	ld	de,psw
		call	print_ez1
		ld	de,var_pasw
		xor	a			;vkladame nop do rutiny INPUT
		bit	2,(ix+0)		;test if pasword is protected
		jr	z,set_pass1
		dec	a			;vkladame #FF
set_pass1	ld	(INX_HS+1),a
		jr	su1

set_hide_pass	ld	hl,flag1		;toggle bit 2 of flag1 (hide ftp password)
		ld	a,4
		xor	(hl)
		ld	(hl),a
	
prn_host_usr_psw
		IFDEF hgfx64x24
		ld	bc,#0112
	ELSE				;print line 18 with host, username, password
		ld	hl,#5000+(32*2)
		ld	b,8*1
	ENDIF
		call	cls_9_lines
		ld	de,host
		ld	hl,txt_adr_hostvar
		call	PRINTHL
		ld	de,host_url
		call	PRINT
		ld	de,user
		call	PRINT
		ld	de,var_user
		call	PRINT
		ld	de,pass
		call	PRINT
		ld	de,var_pasw

		bit	2,(ix+0)
		jr	z,pfs1
		ex	de,hl			;NZ=hide password with XXXXXX
		call	count_com_len

		ld	b,c			;B=length of password
		ld	hl,(HLKO+1)
phup		push	bc
		ld	a,"X"
		call	CHAR
		pop	bc
		djnz	phup
		jp	pfs1+3			;jp clear_edit_zone


set_list_nlst	ld	hl,flag_dir
		bit	4,(hl)
		jr	z,sln1		;Z=LIST->NLST
		res	4,(hl)		;NLST->LIST
		jr	prn_lst_nlst_abbr_ful
sln1		set	4,(hl)

set_full_abbr	ld	hl,flag_dir
		bit	4,(hl)
		jr	nz,sfa1		;NZ=NLST
		bit	2,(hl)
		jr	z,sfa1
sfa2		res	2,(hl)		;set to abbr
		jr	prn_lst_nlst_abbr_ful
sfa1		set	2,(hl)		;set to full

prn_lst_nlst_abbr_ful
		bit	4,(ix+1)
		ld	de,ftp_list
		jr	z,plnaf1	;Z=LIST
		ld	de,ftp_nlst
plnaf1		ld	hl,txt_adr_meziradek+55
		call	PRINTHL
		bit	2,(ix+1)
		ld	de,abbr
		jr	z,plnaf2
		ld	de,full
plnaf2		jp	PRINT

prn_mark_items	ld	hl,(mark_counter)
		ld	de,block_asci
		push	de
		call	HL2ASCII
		ld	a,h
		ld	(de),a
		pop	de
		ld	hl,txt_adr_meziradek+50
		call	PRINTHL
		ld	de,spaces+30
		jp	PRINT

quit_program

;allok		ld	bc,0		;0= all ok (for return to BASIC)
;		push	bc

quit		call	set_def_wifi_speed	;set speed 7 for easier work with uart terminal
		
		bit	3,(ix+0)	;set Wifi on/off on exit
;		push	af
		call	z,wifi_off	;zjednodušení
;		pop	af
;		scf
;		call	nz,wifi_on

		res	0,(ix+1)	;set dir as not read, so that it will be read once you quit Sarah to Basic and return with RAND. USR 51200

		ld	bc,#783B	;return CPU speed
		ld	a,#30
		out	(c),a
		inc	b
return_speed	ld	a,#55		;speed is 0-3
		out	(c),a

	IFDEF hgfx64x24
		call	hgfx_off
	ENDIF
;	IFDEF bs_dos
	IFDEF hgfx64x24
	IFDEF bs_dos
		ld	hl,0		;return error messages to BSDOS
		call	bsdosbuf-4	;call BSDOS service
	ENDIF
	ENDIF


;Busy's solution how to return to Basic
		ld	iy,23610
		ld	hl,(#5CB2)	;ramtop
		ld	(hl),#3E
		dec	hl
		ld	sp,hl
		ld	hl,#1303
		push	hl
		ei
		jp	#1B76






;****************************************************************
;****************************************************************
;****************************************************************


;PARSING
;look for a string in received bytes string, for receive string evaluation purposes
;IN=HL start of the memory area, DE=start of the string we look for, must end with 0, BC=max.len of searched memory, OUT=Z=found, HL=start address of found string in memory, DE=byte coming after found string, NZ=string not found
;10)
look_for_string	ld (lfs5+1),sp
		set 0,(ix+0)

lfs3		ld a,(de)
		cp (hl)
		jr z,lfs_match

		bit 0,(ix+0)		;NZ=no match, was already matching?
		inc hl			;new
		jr nz,lfs2
		dec hl			;new
		pop de			;Z=was matching, now not anymore, renew looked for string
		pop de			;DE=start of searched string
		inc bc
lfs2		set 0,(ix+0)
;		inc hl			;new


lfs1		dec bc
		ld a,b
		or c
		jr nz,lfs3
		inc c			;BC max length reached, set NZ & return
		jr lfs5	

		



lfs_match	bit 0,(ix+0)
		jr z,lfs_alrea_match
		res 0,(ix+0)		;Z=match found, push address
		push de
		push hl

lfs_alrea_match	inc hl
		inc de
		ld a,(de)
		or a
		jr nz,lfs1		;continue macthing if string continues

		ld d,h
		ld e,l			;DE=byte coming after found string
		pop hl			;HL=start address of found string in memory

lfs4		bit 0,(ix+0)
lfs5		ld sp,#5555
		ret			;Z/NZ






;IN=HL=start of looked for string, must end with 0
;OUT=Z=string found, NZ=string not found
;11)
look_on_fly	exx
		ld	bc,0
		exx
		ld	e,#FF		;e= flag, Z=found,NZ=not found
		ld	b,e
		ld	c,e		;BC=timeout
lof3		push	hl
lof1		dec	bc		;bugfix 0.3
lof5		scf
		call	rece_byte
		jr	nz,lof4

		exx			;Z= no byte to receive. ESP can just breathe out and then continue
		dec	bc
		ld	a,c
		or	b
		exx
		jr	z,lofend	;Z=really, no byte to collect
		jr	lof5

lof4		cp	(hl)
		ld	e,0
		jr	z,lof2		

		dec	e		;NZ,char does not match, bring another byte
		pop	hl
		ld	a,b		;max of 65535 unsucessfull tries
		or	c
		jr	z,lofend1
		jr	lof3		

lof2		inc	hl
		ld	a,(hl)
		or	a
		jr	nz,lof1		;still not end, continue search
		
		
lofend		pop	hl
lofend1		inc	e
		dec	e
		ret			;Z/NZ

;12)
search_by_Busy			;IN=DE= starting item address, BC=its length
;OUT=Z=found, NZ=not found
		push	bc
		exx
		pop	bc	;BC'=delka polozky
		exx
ms3		
txtadd		ld	hl,INPBUFF	;HL=Adresa vzoru
;txtadd		ld   hl,#5555 ; Adresa vzoru zadaneho uzivatelom
txtlen		ld   bc,#5555 ; Dlzka polozky
;		ld   a,b	;muzeme vynechat, retezec nebude nikdy prazdny
;		or   c
;		ret	z
;		jr   z,nasiel
;		push de
		call cpi ; Porovnanie dvoch podretazcov
;		pop  de
		ret	po	;Z=shoda. !!!!! if "ret po" deleted, then will find also 1 char inside string
				;if "ret po" left in code, than 1 char will be found only at start, very handy.
		ret	z	;Z=shoda

		exx		;nasla se shoda v pismenku, jsme na konci?
		ld	a,c
		or	b		;BC'=delka polozky
		jr	z,nenasel	;konec polozky
		dec	bc
		exx
		jr	ms3
		
cpi		ld   a,(de)
		call	convert
		push	af
		ld	a,(hl)
		call	convert
		ld	(hl),a
		pop	af
		cpi		;CP (HL): INC HL: DEC BC: LD A,B: OR C (PO/PE)
		inc  de ; Posun na dalsi znak mena suboru
		ret	nz	;NZ=bajty se nerovnaji
		ret	po	;PO=BC=0=delka vzoru
		jr	cpi

nenasel		inc	a	;set NZ
		ret

convert		cp	"A"
		ret	c
		cp	"Z"+1
		ret	nc
		or	#20
		ret

;13) search_until_zero removed - count_com_len is reused for the same job


;RECEIVING
;IN=BC=max.length of data to receive, HL=start of received data, OUT=Z= desired length of data received
;;;;not valid->>>>>, NZ= timeout= data not transfered completely


;7)
receive_data_timeout
		ld de,#290		;timeout, if #80, only app. first #500 bytes carried correctly
receive_data1	ld a,b			;bios1.2, timeout have to increase to #200
		or c
		ret z			;Z=length reached, return
		scf
		call rece_byte
		jr nz,rd1
		dec de			;Z=no byte to receive
		ld a,e			;DE=timeout, in case there is receive interuption
		or d
;		jr nz,receive_data1
;		inc e			;only to set flag to NZ!!
;		ret
		ret z
		jr receive_data1	;do not decrease BC, as no data came in

rd1		ld (hl),a
		inc hl
		dec bc
		jr receive_data1



;SENDING
;IN=HL string (ends with 0), OUT=Z=string has been sent, NZ=not sent, timeout
;1)
clear_exp_name	ld	hl,exp_name		;helper: blank the 10-char file name buffer
		ld	de,exp_name+1
		ld	bc,9
		ld	(hl),32
		ldir
		ret

print_ez2	ld	hl,txt_adr_edit_zone2	;helper: load edit-zone-2 address then print
		jp	PRINTHL

print_ez1	ld	hl,txt_adr_edit_zone1	;helper: load edit-zone-1 address then print
		jp	PRINTHL

send_string	jr ss6			;send_string+1:0 for print info (jr ss6), 18 for not print info (jr ss5)

ss6		push hl			;print it first
		ld hl,txt_adr_module_send
		push	hl
		ld	de,spaces
		call 	PRINTHL
		pop	hl
		pop	de
		push	de		
		call	PRINTHL
		pop hl			;HL=string to be sent

ss5		ld de,0			;maximum timeout

ss2		ld a,(hl)
		or a
		ret z			;Z=end of string

ss1		scf
		call send_byte
		jr nc,ss3
		ld b,a
		ld a,3
		out (254),a		;magenta border= TX line is busy.....
		dec de
		ld a,d
		or e
		jr nz,ss4
		inc e
		ret
ss4		ld a,b			;maybe some timeout could be added here
		jr ss1

ss3		inc hl
		xor a
		out (254),a
		jr ss2


	IFUSED send_data

;IN=HL start of data, BC=data len, OUT=Z=data has been sent
;2)
send_data	ld a,b
		or c
		ret z			;Z=len of data in BC sent
		ld de,0			;maximum timeout

sd1		dec de
		ld a,d
		or e
		jr nz,sd2
		inc e		;set NZ, data not sent
		ret

sd2		ld a,(hl)
		scf
		call send_byte
		jr c,sd1
		inc hl
		dec bc
		jr send_data

	ENDIF


;OTHERS
;15)
;IN=HL=command, out=BC=len of command, must end with 0
count_com_len	ld	bc,0		;counts command length, 16 bit length
cc1		ld	a,(hl)
		or	a
		ret	z
		inc	hl
		inc	bc
		jr	cc1




	
;16)
ConvRStr16
;===============================================================
;http://z80-heaven.wikidot.com/math#toc32
;Input: 
;     DE points to the base 10 number string in RAM. 
;Outputs: 
;     HL is the 16-bit value of the number 
;     DE points to the byte after the number 
;     BC is HL/10 
;     z flag reset (nz)
;     c flag reset (nc)
;Destroys: 
;     A (actually, add 30h and you get the ending token) 
;Size:  23 bytes 
;Speed: 104n+42+11c
;       n is the number of digits 
;       c is at most n-2 
;       at most 595 cycles for any 16-bit decimal value 
;===============================================================

     ld hl,0          ;  10 : 210000 
ConvLoop:             ; 
     ld a,(de)        ;   7 : 1A 
     sub 30h          ;   7 : D630 
     cp 10            ;   7 : FE0A 
     ret nc           ;5|11 : D0 
     inc de           ;   6 : 13 
                      ; 
     ld b,h           ;   4 : 44 
     ld c,l           ;   4 : 4D 
     add hl,hl        ;  11 : 29 
     add hl,hl        ;  11 : 29 
     add hl,bc        ;  11 : 09 
     add hl,hl        ;  11 : 29 
                      ; 
     add a,l          ;   4 : 85 
     ld l,a           ;   4 : 6F 
     jr nc,ConvLoop   ;12|23: 30EE 
     inc h            ; --- : 24 			
     jr ConvLoop      ; --- : 18EB



;17)
;IN=HL=number, OUT=DE=address with the string
HL2ASCII		res 7,(IX+0)		;Leading zero suppression
HL2ASCII_00000		ld bc,10000
			call string_dl
			ld bc,1000
			call string_dl
HL2ASCII_000		ld bc,100
			call string_dl
			ld bc,10
			call string_dl
			ld a,l
			add a,'0'
			LD (DE),A
			INC DE
			RET
			
string_dl:		ld a,'0'-1

string_lp2:		inc a
			or a
			sbc hl,bc
			jr nc,string_lp2
			add hl,bc
			CP '0'
			JR Z,string_store

			SET 7,(IX+0)		;Had something other than zero

string_store:		BIT 7,(IX+0)		;Test if still leading zeros
			RET Z						
			LD (DE),A		;If not store it	
			INC DE
			RET	






	IFUSED wait_long
;18)
wait_long	ld	b,3		;wait long time, DE delay fixed (3x 65536 times)
wait_long_def	call	wait_short	;wait long time, DE delay suer defined (Bx 65536 times), IN=B=delay
		djnz	wait_long_def
		ret

wait_short	ld	de,0		;wait short time, DE delay fixed (65536 times) (tady by mela stacit polovicni hodnota tedy #8000)!!!!
wait_short_def	dec	de		;wait short time, DE delay user defined,IN=DE=delay
		ld	a,d
		or	e
		jr	nz,wait_short_def
		ret

	ENDIF

;19)
print_title
	IFDEF hgfx64x24
		ld	bc,#0200	
	ELSE
		ld	hl,txt_adr_cwd
		ld	b,8*2
	ENDIF
		call	cls_9_lines

		ld	de,title
		ld	hl,txt_adr_header
		call	PRINTHL
		ld	hl,txt_adr_header_line
		ld	b,title_len
underl		ld	a,34			;""""
		push	bc
		call	CHAR
		pop	bc
		djnz	underl
		ret

;20) save dir position, so that you can renew the dir from where you have been
save_dir_position
;		res	6,(ix+1)
		set	6,(ix+1)		;signal, we enter dir
		ld	hl,(cur_item_addr)	;now, remember position in dir, to return to it
		ld	(cur_item_adr_tmp),hl	;when going updir
		or	a
		ld	de,basic_end
		sbc	hl,de
		ld	(item_checksum),hl
		ret	z
;		jr	z,ed6			;Z=we stand on the very first item
		add	hl,de			;NZ=remember position
		ld	e,(hl)
		dec	hl
		dec	hl
		ld	d,(hl)			;DE=checksum
		ld	hl,item_checksum
		ld	(hl),e
		inc	hl
		ld	(hl),d			;checksum on its place
		ld	hl,(cursor_w_curad)	;now read and save other values
		ld	(cursor_w_curad_tmp),hl
		ld	a,(wind_curs_item)
		ld	(wind_curs_item_tmp),a
		ld	hl,(item_pg_start)
		ld	(item_pg_start_tmp),hl
		ret



;22) by Busy
ConvRStr32

;; Vstup: BC = zaciatok postupnosti cislic ukoncena znakom inym ako cislica
;; Vystup: DEHL = 32 bitova hodnota

	xor	a
	ld	h,a
	ld	l,a
	exx
	ld	h,a
	ld	l,a
	ld	b,a
	ld	c,a
	exx
d32lop	ld	a,(bc)
	sub	'0'
	cp	10
	jr	c,d32ano
	ex	de,hl
	exx
	push	hl
	exx
	pop	hl
	ret

d32ano	ld	d,h
	ld	e,l
	add	hl,hl
	exx
	ld	d,h
	ld	e,l
	adc	hl,hl
	exx
	add	hl,hl
	exx
	adc	hl,hl
	exx
	add	hl,de
	exx
	adc	hl,de
	exx
	add	hl,hl
	exx
	adc	hl,hl
	exx
	ld	e,a
	ld	d,#00
	add	hl,de
	exx
	adc	hl,bc
	exx
	inc	bc
	jr	d32lop

;; Koniec rutinky



;28) (Busy's routine)
HL2ASCII32
;Prevod bin->dec bez znamienka
; in: bin
;out: dec


bindec	ld	hl,zzdec            ;; Vynulovanie buffera dec
	ld	bc,lldec*#0100
cls1	ld	(hl),c
	inc	hl
	djnz	cls1
	ld	c,8*llbin           ;; Opakuj pre kazdy bit bin:
bndc0	call	binx2               ;; vyrotovanie bitu z bin
	ld	hl,eedec
	ld	b,lldec             ;; a zarotovanie toho bitu do dec
bndc2	dec	hl
	ld	a,(hl)
	adc	a,a
	cp	#0a
	jr	c,bndc3
	sub	#0a
bndc3	ld	(hl),a
	ccf
	djnz	bndc2
	dec	c
	jr	nz,bndc0

	ld	hl,zzdec
	ld	b,10		;; change it to ASCII
prev_ascii32
	ld	a,(hl)
	or	a
	jr	nz,asc32n
	inc	hl
	djnz	prev_ascii32

	inc	b		;osetreni 0
	dec	hl		;udelej misto pro zobrazeni "O"

asc32n	ld	d,h
	ld	e,l		;; DE=ASCII number start

asc32_n	ld	a,#30
	or	(hl)
	ld	(hl),a
	inc 	hl
	djnz	asc32_n
	ret

binx2	ld	hl,zzbin            ;; Nasobenie bin dvomi
	ld	b,llbin
	xor	a
bnxx2	rl	(hl)
	inc	hl
	djnz	bnxx2
	ret

zzbin	db	#ff,#ff,#ff,#ff		;vstup v bajtech
eebin
llbin	=	eebin-zzbin

zzdec	db	0,0,0,0,0		;vystup v ASCII
	db	6,5,5,3,5
eedec
lldec	=	eedec-zzdec
	db	0			;zarážka pro tisk

;29)input: timeout in (ix+6), output, Z="OK" found, NZ=answer "OK" not found
send_at_check_ok
		call	wifi_wait
		ld	hl,at
		call	send_string
		ld	bc,28
		jp	nz,error_handler
;		jp	nz,error

;		ld	de,#100			;when it is away, it speeds up the search significantly
;		call	wait_short_def

		ld	hl,RX_buf
		ld	bc,20
		push	hl
		push	bc
		ld	de,RX_buf+1		;clear RX_buf before reading bytes to it
		ld	(hl),0
		ldir
		pop	bc
		pop	hl
		push	hl
		push	bc
		call	receive_data_timeout	;much quicker than look_on_fly
;		pop	bc
;		pop	hl
		call	wifi_unwait
		pop	bc
		pop	hl
		ld	de,ok
;		jp	look_for_string
		call	look_for_string
		ret	z
		dec	(ix+6)
		jr	nz,send_at_check_ok
		inc	c			;NZ=OK not found
		ret


;40) OUT CY 0=OK, 1= speed not supported, set and print UART speed
set_print_speed	scf
		push	af
		call	set_baud
		pop	de
		ld	a,d		;A=speed 0-23 we set
print_speed	push	af
ps2		ld	de,TX_buf
		push	de
		ld	h,0
		ld	l,a
		call	HL2ASCII
		ld	a,32
		ld	(de),a
		inc	de
		ld	(de),a
		xor	a
		inc	de
		ld	(de),a
		pop	de
		ld	hl,(HLKO+1)
		push	hl
		ld	hl,txt_adr_speed_login+7
;		ld	(HLKO+1),hl
		call	PRINTHL
		pop	hl			;return print position
		ld	(HLKO+1),hl
		pop	af			;CY/NC
		ret



;48)
convASCII2hex
;IN=HL ASCII number address (2 digits) eg. hl,14
;OUT=A=#14
		ld	a,(hl)
		and	%00001111
		sla	a
		sla	a
		sla	a
		sla	a
		ld	e,a
		inc	hl
		ld	a,(hl)
		and	%00001111
		or	e
		ret

;49) clear whole screen
cls_4000
	IFDEF hgfx64x24
		jp	hgfxcls
	ENDIF
		ld	hl,16384
		push	hl
		ld	de,16385
		ld	bc,6144
		ld	(hl),0
		ldir
		ld	bc,768
		ld	(hl),7
		ldir
		pop	hl
		ret

;50) clear 9 lines, if called from "cls_9_hl", 9 lines starting from HL will be cleared
;if called from "cls_9_lines", the input must be HL=starting address, and B= number of micro lines to clear
;cls_9		ld	hl,#4000+(32*3)
;cls_9_hl	ld	b,8*9

	IFDEF	hgfx64x24
cls_9		ld	bc,#0808		;B=number of lines, C=starting line
cls_9_lines	jr	clear_line_hgfx
	ELSE


cls_9		ld	hl,#4800
		ld	b,8*8
cls_9_lines	push	hl
		xor	a
		ld	e,#20
cls_91		ld	(hl),a
		inc	hl
		dec	e
		jr	nz,cls_91
		pop	hl
		call	DOWNHL
		djnz	cls_9_lines
		xor	a		;A=0 to return to key_loop
		ret
	ENDIF

;54) clears edit zone (2 bottom lines)
clear_edit_zone
	IFDEF hgfx64x24
		ld	bc,#0216
		jr	clear_line_hgfx
	ELSE

		ld	b,2*8
		ld	hl,#50C0
		jr	cls_9_lines
	ENDIF

	IFDEF hgfx64x24
/*
clear_line_hgfx
;input=BC, B=how many lines, C= starting line
		ld	hl,0
		ld	(VIDEO_REGS.OFFSET_X),hl
		ld	a,l
		ld	h,a
		ld	l,c
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	(VIDEO_REGS.OFFSET_Y),hl

clh1		push	bc
		ld	d,h
		ld	e,l
		inc	de
		ld	bc,511
		ld	(hl),255
		ldir
		pop	bc
		djnz	clh1
		ret
*/

clear_line_hgfx
;input=BC, B=how many lines, C= starting line
		ld	h,c
		ld	l,0
		push	bc
		call	give_coords
;		pop	bc			;pocet radku je v B

;		ld	hl,0
;		ld	(VIDEO_REGS.OFFSET_X),hl
;		ld	a,l
;		ld	h,a
;		ld	l,c
;		add	hl,hl
;		add	hl,hl
;		add	hl,hl
;		ld	(VIDEO_REGS.OFFSET_Y),hl

;		push	bc

;;clh1		ld	hl,0			;nulty sloupec
;;		ld	(FDMAreg.FD_Copy),hl
;;		ld	(FDMAreg.FD_Mod),hl

		call	set_fdma_to_fill_len_in_bc_512
;;		ld	(VIDEO_REGS.OFFSET_X),hl	;netreba sloupec nam nuluje rutina give_coords

;		ld	hl,0			;bajt vyplne (smazani) bude 0
		ld	(FDMAreg.FS_Adr),hl
;;		ld	hl,512			;delka bloku (512=1 radek
;;		ld	(FDMAreg.F_Len),hl	;#5b01- nechce se prelozit
;;		ld	(#5b01),hl
		ld	a,%00100000
		ld	(FDMAreg.F_mode),a	;spust FDMA, smaz jeden radek
		pop	bc
		inc	c			;zvysim radek
		djnz	clear_line_hgfx
		jp	set_fdma_to_chars
;		ret


/*maze, ale pomalu
clh2		push	bc
		xor	a
		ld	b,a			;256x
clh1		ld	(hl),a
		inc	hl
		ld	(hl),a			;2x
		inc	hl
		djnz	clh1

		pop	bc
		djnz	clh2
		ret
*/

	ENDIF
	IFUSED prn_ap_name_sig
		
;51) INPUT:de=print position
prn_ap_name_sig	ld	hl,at_cwjap_cur?	;find out current AP
prn_ap_name_sig_def
		push	de			;DE=print position
		call	send_string
;		ld	bc,1			;error to be solved
;		jp	nz,error

		ld	hl,RX_buf		;receive the answer to RX_buf
		ld	bc,100
		push	hl
		push	bc

		ld	a,(ix+2)
		cp	3
		jr	nc,prap1
		ld	de,#D00			;experimental tomeout, it works!!
		call	receive_data1		;for speeds <3 we need bigger receive timeout
		jr	prap6


prap1		call	receive_data_timeout

prap6		pop	bc			;BC=100
		pop	hl			;HL=RX_buf


		push	hl			;HL=RX_buf
		push	bc			;BC=100

		ld	de,ok			;new concept, look for "OK", if not then "No AP"
		call	look_for_string
		jr	z,ap_answ_found


prap2		pop	bc			;BC=100, OK not found
		pop	de			;RX_buf
prap5		pop	hl			;print position


		push	hl			;print position
		ld	de,spaces
		call	PRINTHL

		ld	de,no_ap
		pop	hl			;HL=print position
		res	5,(ix+0)		;probably not needed
		jp	PRINTHL			;No AP


						;check type of answer	
ap_answ_found	pop	bc			;BC=100
		pop	hl			;HL=RX_buf
		push	hl
		push	bc
		ld	de,no_ap
		call	look_for_string
		jr	z,prap2			;"No AP" found, end
		pop	bc			;BC=100
		pop	hl			;HL=RX_buf

		ld	de,dvojt
		call	look_for_string
		jr	nz,prap5		;":" not found, probably nonsence returned
						;due to eg. speed module will not communicate
		ex	de,hl			;AP name found
		ld	de,uvoz
		inc	hl
		push	hl
		call	look_for_string
		ld	(hl),0

		pop	hl			;HL=start of AP name
		pop	bc			;BC=print position (push pop=)

		inc	de			;move behind "."
		ex	de,hl
		push	hl
		ld	h,b
		ld	l,c
		call	PRINTHL


		pop	hl			;HL next positin in receive string
		ld	bc,100

		ld	de,carka
		push	de
		call	look_for_string

		ex	de,hl
		pop	de
		push	de
		call	look_for_string

		pop	de
		push	hl			;HL=signal intensity
		inc	hl			;DE=hledame carku
		ld	c,4
		call	look_for_string
		jr	z,prap3
		pop	hl			;start of signal intensity
		push	hl

prap4		ld	a,(hl)
		cp	#D
		jr	z,prap3
		inc	hl
		jr	prap4


prap3		ld	(hl),0

		pop	de			;print signal inensity
		push	de
		call	PRINT
		pop	de
		inc	de
		inc	de
		call	ConvRStr16
		ld	a,l
		ld	de,excellent
		cp	50			;print text level of signal intensity
		jr	c,prn_sig_txt
		ld	de,good
		cp	60
		jr	c,prn_sig_txt
		ld	de,fair
		cp	70
		jr	c,prn_sig_txt
		ld	de,poor
		
prn_sig_txt	call	PRINT
		ld	de,spaces+25
		jp	PRINT


	ENDIF


;52) gets status (if wifi is connected to FTP or not).
;OUT=A=status "2"-"5"
;OUT sets status 5,ix+0, 0 not logged in, 1 logged in
;OUT=Z=A=3 host ok, login ok
;NZ=5= host x, login x, module not even connected to AP
;NZ=4= TCP or UDP disconnected
;NZ=3= TCP or UDP connected, but not ftp (only internal state of routine), routine will change it to status 4, NZ)
;OUT="current_host" either X, if not connected to ftp server, or host name if connected
;OUT=Z=HL=code returned by NOOP, NZ=HL=0
get_status_ftp	call	clear_rece_buf

		ld	de,STATUS
		ld	hl,txt_adr_speed_login+27
		call	PRINTHL

		ld	hl,cipstatus		;find out, if module connected to wifi
		call	send_string
;		ld	bc,1
;		jp	nz,speed_m_error	;spatne, zasobnik!!!

		ld	hl,RX_buf		;receive the answer about STATUS to RX_buf
		ld	bc,#80
		push	hl
		push	bc

/*
		ld	a,(ix+2)
		cp	3
		jr	nc,gs1
		ld	de,#500			;experimental timeout, it works!!
		call	receive_data1		;for speeds <3 we need bigger receive timeout
		jr	gs2		
*/

gs1		call	receive_data_timeout

gs2		pop	bc		;BC=#80
		pop	hl		;HL=RX_buf

		push	hl
		push	bc
		ld	de,ok		;look for OK in the answer
		call	look_for_string
		jr	z,gs5


		pop	hl		;OK not found
		pop	bc
gs4		ld	de,unknown	;STATUS not found
		ld	hl,txt_adr_speed_login+35
		jp	PRINTHL
;		ld	de,spaces+8
;		jp	PRINT


gs5		pop	bc		;BC=20
		pop	hl		;HL=RX_buf
		ld	de,STATUS
		call	look_for_string
		jr	nz,gs4

		ld	a,(de)		;A=status number ("2"-"5")
		push	de
		ld	(ix+22),a	;status_byte
		ld	hl,block_asci+1	;status= 2,4 or 5- use the same behaviour
		ld	(hl),0
		dec	hl
		ld	(hl),a
		ex	de,hl
		push	af
		ld	hl,txt_adr_speed_login+35
		call	PRINTHL		;print status
		pop	af

		pop	de
		cp	"3"
		set	5,(ix+0)
		jr	z,gs7

gs3		res	5,(ix+0)
		ld	hl,0
		push	hl		;HL=0 if status<> "3"
		push	af		;push NZ state
		ld	hl,#2058	;"X"+#20
;		ld 	hl,"X"		;"X"+0
		xor	a
		ld	(current_host),hl
		ld	(current_host+2),a
gs10		ld	(current_login),hl
gs9		call	print_ftp_status
		pop	af
		ld	a,(ix+22)	;A=status
		pop	hl		;if Z then contains ftp code returned after noop, if NZ, HL=0
		ret			

gs7		ex	de,hl		;A="3",we are connected with TCP or UDP protocol
		ld	b,3
gs6		push	bc
		ld	c,#60
		ld	de,uvoz
		call	look_for_string
		ex	de,hl
		pop	bc		;zde by mìla být kontrola chyby
		djnz	gs6
		push	hl		;HL=start of URL
		ld	de,uvoz
		ld	c,#40
		call	look_for_string	;zde by mìla být kontrola chyby
		ld	(hl),0
		pop	hl		;HL=start of URL
		or	a
		ex	de,hl
		sbc	hl,de
		ld	b,h
		ld	c,l
		add	hl,de
		push	hl		;HL=èárka, now we look for port number 21
		ex	de,hl
		ld	de,current_host
		ldir
		xor	a
		ld	(de),a
;		call	PRINT		;print ftp server name


					;new in 0.99. ftp port can be even different from 21, eg. mobile phone ftp servers, eg: 192.168.0.200:31547

		pop	hl

/*
		inc 	hl		;therefore, we try not to check the port
		ld	a,(hl)
		cp	"2"
		jr	nz,gs8		;NZ=port 21 not found!!! we should unconnect and reconnect on port 21!!!
		inc	hl
		ld	a,(hl)
		cp	"1"		;if port is not 21, then status is 3, but we are not connected to ftp port 21, therefore NZ
		jr	nz,gs8
*/
					;ok, we are successfuly connected to ftp server, now find out if we are logged in
		call	send_noop
		push	hl		;HL=code returned by NOOP
		ld	hl,#2058	;"X"+#20
;		ld 	hl,"X"
		inc	h
		dec	h		;set NZ
		push	af
		jr	c,gs10		;C=we are not logged in
		pop	af
		pop	hl
		ld	hl,ok_
		ld	de,current_login
		ld	bc,3
		ldir
		push	bc		;BC=0
		xor	a		;set Z
		push	af
		jr	gs9
/*
gs8		ld	hl,at_cipclose	;status 3 but not connected to FTP (probably from previous connection), so close connection
		call	send_string
		ld	hl,ok		;add error check!!!
		call	look_on_fly
		jp	nz,cr_err
		ld	a,"3"
		inc	a		;set NZ
		ld	(ix+22),a	;set status 4
;		xor	a
;		inc	a		;set NZ
		jp	gs3
*/

;53) sets speed 155200 Bd on module and UART
set_def_wifi_speed

		ld	a,7
		jr	set_ud_speed_a


;55) a key
akey		call	wifi_unwait

akey1		call	inkey
		or	a
		jr	nz,akey1	;release previous press

akey2		ld	de,akey_txt
		ld	hl,txt_adr_edit_zone2+#30
		push	hl
		call	PRINTHL

		call	KEYSCAN
		pop	hl
		push	af
		ld	de,spaces+16
		call	PRINTHL
		pop	af
		or	a
		jr	z,akey2
		ret

;56) wifi_wait/unwait	signals, that we wait for wifi
	IFDEF hgfx64x24
wifi_wait	push	af
		call	wu2
;		inc	a			;A=32, blue
		ld 	(VIDEO_REGS.COLOR),a
		ld	a,#80			;obdelnik
		jr	wu1
wifi_unwait	push	af
		call	wu2
		ld	a,#20			;znak
wu1		ld	hl,#173f		;pozice
		call	CHAR

		call	set_hgfx_ink_planar	;set back ink and planar

		pop	af
		ret

wu2		ld	a,planar_wifi		;planar 5 (jen pro wifi wait/unwait)
		ld	(VIDEO_REGS.MASK),a
		ret

	ELSE
wifi_wait	push	af
		ld	a,15
		jr	wifi_unwait1
wifi_unwait	push	af
		ld	a,7
wifi_unwait1	ld	(23295),a
		pop	af
		ret
	ENDIF	


;57) align speed on UART and module, speed taken from IX+2. If IX+2=255, align at max MBFW speed. Or speed taken from A,
; then call set_user_defined_speed_a
;mostly for usage in SM2.0
;INPUT=D=currently aligned speed. If D=255 continue with speed align, if 0-23 compare with
;speed you want to align, if same, do not continue.
set_ud_speed
		ld	a,(ix+2)
		inc	a
		jr	z,set_mspeed_mbfw
		dec	a
		jr	set_ud_speed_a
set_mspeed_mbfw	ld	a,(ix+8)		;A=max speed allowed for given MBFW
		cp	23
		jr	nz,set_ud_speed		;if 23, change it to 16 (max speed for module)
		ld	a,16

set_ud_speed_a	cp	24			;check if speed is within 0-23
		ld	bc,33
		jr	nc,suds5		;NC=speed >23, error
						
		ld	b,a			;A=speed to which we want align UART and module
		ld	c,b			;C=speed to which we want align UART and module
		cp	d			;D=currently aligned speed
		ret	z			;Z=speed we want is already aligned
		
		ld	hl,speed_table		;find the speed eg. "16= 3456000"
		or	a
		jr	z,suds2
sudsa1		ld	a,(hl)
		or	a
		inc	hl
		jr	nz,sudsa1
		djnz	sudsa1
suds2		ld	a,(hl)			;HL= Baud speed (eg. "3456000")
		cp	" "
		inc	hl
		jr	nz,suds2
				

		push	bc			;C= UART speed we want

		ld	de,TX_buf		;now prepare AT comand to TX_buf
		push	de
		push	hl			;HL=start of eg "3456000"
		ld	hl,uart
		ld	bc,12
		ldir

		pop	hl			;HL=start of eg "3456000"		
		push	hl
suds3		ld	a,(hl)
		or	a
		inc	bc
		inc	hl
		jr	nz,suds3
		dec	bc
		pop	hl
		ldir

		ld	hl,_8100
		ld	bc,10
		ldir		
		ex	de,hl
		ld	(hl),0
		
		pop	hl
		call	send_string	;set user defined speed on the module via AT+UART+CUR

		ld	hl,ok		;for speeds<3 seems to work
		call	look_on_fly	;correct answer OK means, we aligned speeds sucesfully

		pop	de
		ld	bc,31		;OK not received in answer
		jr	nz,suds1
		

		ld	a,e			;A= UART speed we want
		call	set_print_speed		;set the desired speed in UART
		ret	nc			;NC=set sucessfully

		ld	bc,32

suds1		push	bc
		ld	a,e
		call	set_print_speed
		call	print_bauds
		pop	bc

suds5		pop	hl
		jp	error_handler
;		jp	error


;58) sends abort command (in order to abort existing command and get unstuck)
;send_ftp_command is the main routine that sends command+ string if needed and returns ftp answer code
;IN=A=0=command only (eg. "ABORT"). A=1=comamnd+prepared string from INPUT (eg. "STOR filename"), A=2=command+new INPUT
;OUT=A=0=NC=sent ok, awaited ftp code returned correctly
;A=1=C=c=1=error sending string
;A=2=C=c=11=error in module answer (expected answer ">" not returned)
;A=3=C=c=4=sent ok, but return code other than expected
send_abort	xor	a
		ld	hl,ftp_abor
send_ftp_command
		push	de		;DE=ftp code we expect
		push	hl
		push	af
		ld	bc,0
sfc4		ld	a,(hl)
		or	a
;		cp	#20		;count length of command, some servers won't accept spaces
		inc	bc
		inc	hl
		jr	nz,sfc4
		dec	bc		;command back to original length
		ld	de,TX_buf	;universal routine, send any command in HL
;		ld	bc,5
		pop	af
		pop	hl
		ldir

		cp	1
		jr	c,sfc1		;C=command only
		jr	z,sfc2		;Z=command+ prepared text

		push	de		;NC=command+ new input parameter (string)
		call	input_line
		jr	nz,sfc3
		jp	z,clear_ini_keyl	;Z=abort pressed during input, carry out clear_edit_line+jp to key_loop
;		jp	initsp_keyloop	;Z=input aborted, init SP+ jp key_loop

sfc3		pop	de
		ldir
		jr	sfc1

sfc2		call	input_l_count
		ldir

sfc1		ld	hl,eol
		ld	bc,3
		ldir

		call	clear_edit_zone
;rutina volnì navazuje na cipsend_request hned dole


;59);sends any data in ftp, eg. "AT+CIPSEND=0,6"+ "USER xy"
;data have to be prepared in TX_buf, must end with 0, returns ftp code in HL
;on input DE return code we ask about is on the stack!!
cipsend_request	ld	hl,at_cipsend	;send "AT+CIPSEND="
		call	send_string
		jr	nz,sfcerr1

		bit	4,(ix+3)	;send session ID
		ld	a,"0"
		jr	z,cr1
		inc	a		;A="1"
cr1		ld	hl,TX_buf-3
		push	hl
		ld	(hl),a
		inc	hl
		ld	(hl),","
		inc	hl
		ld	(hl),0
		pop	hl
		call	send_string	;eg. "0,"
		jr	nz,sfcerr1

		ld	hl,TX_buf
		call	count_com_len	;count length of data in TX_buf
;		inc	c
;		inc	c		;add EOL length=2 chars
		ld	h,b
		ld	l,c
		ld	de,RX_buf
		push	de
		call	HL2ASCII
		xor	a
		ld	(de),a

		pop	hl		;RX_buf=length of command in ASCII, eg. "20"
		call	send_string	;send length of command
		jr	nz,sfcerr1

		ld	hl,eol
		call	send_string	;command completely sent
		jr	nz,sfcerr1

		ld	hl,char_zob	;new concept
;		ld	de,char_zob	;Wifi module returned ">" to show readiness to accept?
		call	check_module_answer
		jr	c,sfcerr2
;		jp	c,ret2main_scr	;was error

		ld	hl,TX_buf	;send data to ftp server from TX_buf address
csr1		call	send_string
		jr	nz,sfcerr1
		
		jr	receive_ftp_answer

cr_err		call	set_3_5mhz
		call	passive_receive_off	;hope, it will not affect other routines
		ld	c,1		;error in sending string
		jp	error_handler	;pozor, toto pouziva hodne rutin

sfcerr1		;ld	a,1
		pop	de		;!!! DE=return code we asked about
		ld	c,a
;		ld	c,1		;C=1=error in cipsend_request routine
		jr	sfcerrout
sfcerr2		pop	de		;!!! DE=return code we asked about
		ld	a,2		;bylo ;;;koko
;		ld	c,11		;C=11=error in check_module_answer or receive_ftp_answer;;;;koko
		jr	sfcerrout	;;;bylo ;;;koko
sfcerr3		ld	a,3		;A=3=error in receive_ftp_answer routine, C=error
		ld	c,4
sfcerrout	scf		;set C
;		ccf
		ret	
;60)
;in=wasDE, now HL string we look for in the module answer on fly (in RX_buf), OUT=NC=all ok, else error 4
;(((if called without DE, ignore error)))
;bylo ;;;koko
;pokud nepøijde hledaná odpovìï, skonèí rutina ve smyèce!!!! Abych vìdìl, kde se program zadrhává!!!
/*check_module_answer
		ld	(ix+6),0		;timeout set to 32x repeats
chma2		ld	bc,TX_buf-RX_buf	;length is whole RX buffer
		push	hl
		ld	hl,RX_buf
		push	hl
		push	bc
		call	receive_data_timeout
		pop	bc
		pop	hl			;DE=CONNECT
		pop	de
		push	de
		call	look_for_string
		pop	hl			;DE=string we look for
		jr	nz,chma1		;NZ=not found

		call	clear_rece_buf		;clear the incoming "OK"
		and	a			;set C=0
		ret

chma1		dec	(ix+6)
		jr	nz,chma2		;NZ=repeat

		ld	c,4
		jp	error_handler1
*/;bylo ;;;koko az sem
;funkcni, hledame starou verzi
;IN=HL=string we look for in answer
;OUT=NC=all ok, C=error, string not found, vrací jen C/NC!!!
check_module_answer				;new concept
;;;		ld	(ix+6),#10		;16x must be enough,timeout set to #FF (was only 2x repeats);bylo ;;;koko
		push	hl			;string we look for
		call	clear_RX_buf
;		pop	hl			;string we look for
chma11		ld	bc,TX_buf-RX_buf	;;;;;
;chma111		push	hl			;string we look for
;chma1		ld	bc,#80
		ld	hl,RX_buf
		ld	(hl),b			;zero first byte in RX_buf
		push	hl			;HL=RX_buf
		push	bc			;BC=length to seek
		call	receive_data_timeout
		pop	bc			;BC=length to seek
		pop	hl			;HL=RX_buf

;;;		dec	(ix+6)
;;;		pop	hl			;string we look for
;;;		ld	d,h
;;;		ld	e,l
;;;		jr	z,chma3

		ld	a,(hl)
		or	a
		jr	z,chma11
		push	hl
		push	bc
		ld	de,busy
		call	look_for_string
		pop	bc
		pop	hl
;		jr	z,kokot
		jr	z,chma11		;"busy" anser can occur, so check it too
;;		push	hl
;;		push	bc
;;		ld	de,error_answ
;;		call	look_for_string
;;		pop	bc			;BC=length to seek
;;		pop	hl			;HL=RX_buf

		pop	de			;DE=string we look for
;;;		push	de
;;		jr	z,chma3			;string ERROR found, C=4

		call	look_for_string
;		jr	nz,chma11
;		jr	nz,chma3		;;;;
;		pop	hl			;HL=string we look for.Jed, pokud nenajdes hledanou odpoved, jinak se zacykli
		jr	z,chma1111
;		jr	nz,chma111
;;;		dec	(ix+6)
		jr	nz,chma3
;;;		jr	chma111

chma1111	call	clear_rece_buf		;clear the incoming "OK"
		and	a			;set C=0
		ret
;;;bylo koko
;kokot		halt

;chma2		ld	c,0
;		jr	chma4
;chma2		dec	(ix+6)
;		jr	nz,chma1
;chma3		ld	c,4		;bylo ;;;koko, C=4=answer ERROR returned (reply to AT+CIPSTART=1,"TCP"....etc.)

chma3		scf			;set C=1, as error
		ret
;		jp	error_handler1	;bylo ;;;koko

/*
;		ld	(ix+6),1		;timeout set to #FF (was only 2x repeats)
chma1		push	hl
		call	look_on_fly
		pop	hl
		jr	nz,chma2
						;Z=found
		call	clear_rece_buf		;clear the incoming "OK"
		and	a			;set C=0
		ret

chma2						;chma2 rovnou skok na chybu
;		dec	(ix+6)
;		jr	nz,chma1
;		jr	sfcerr2
		ld	c,4
		jp	error_handler1
;		jp	display_error
*/
/*
check_module_answer
		ld	(ix+6),#20		;timeout set to 32x repeats
chma2		ld	bc,TX_buf-RX_buf	;length is whole RX buffer
		ld	hl,RX_buf
		push	hl
		push	bc
		push	de
		call	receive_data_timeout
		pop	de
		pop	bc			;DE=CONNECT
		pop	hl
		push	de
		call	look_for_string
		pop	de			;DE=string we look for
		jr	nz,chma1		;NZ=not found

		call	clear_rece_buf		;clear the incoming "OK"
		and	a			;set C=0
		ret

chma1		dec	(ix+6)
		jr	nz,chma2		;NZ=repeat

		ld	c,4
		jp	display_error
*/				

;61) !!!"receives_ftp_answer" is a part of send_ftp_command routine. Programs enters it with 2 byte ftp code on the stack!!!
;"receive_ftp_answer_isolated" can be used extra. IN=DE=ftpcode we expect

;OUT=HL=received code number, (not valid anymore and not neededDE= start address of message to print), NC=code found, C=code not found, DE= second code or 0 if none
;OUT=error code 11=error in receiving answer "OK"
;OUT=prints ftp report on the screen (temporarily, in future I want to have 3 lines for ftp report)
;!!!!!toto se dá použít na tisk chyb z ftp, pokud se vracíme s NC, pak v HL máme kod, ktery ftp vraci, muzeme je tisknout, zatim neimplementovano.
receive_ftp_answer_isolated
		push	de			;DE=code we expect
receive_ftp_answer				;new concept
;		ld	(ix+6),2		;was 0	
;		push	hl			;HL=code number we want
		call	clear_RX_buf
rfa3		ld	hl,ok			;look for "OK"
		call	look_on_fly		;lasts 4 seconds. 1x attempt is enough
		jr	z,rfa2
;		dec	(ix+6)
;		jr	nz,rfa3
		ld	c,36
		jp	error_handler
;		jr	nz,sfcerr2
;		jr	nz,rfa_err

;		halt				;testing purposes

rfa2		call	look_for_ipd
		jr	nc,rfa1
		jp	error_handler
rfa1		ld	b,h
		ld	c,l
		ld	hl,RX_buf
		push	hl
		call	receive_data_timeout	;receive ftp message to RX_buf
		ld	(hl),0
		pop	de			;RX_buf starts with code number
		push	de			;DE=start of message to print
		call	ConvRStr16
		pop	de			;DE=start address of message to print
		push	hl			;HL=code number we received
		ld	h,d			;na zasobniku mame: code we received, code we want
		ld	l,e			;HL=start address of message to print

		call	print_ftp_message

		pop	hl			;HL=code number we received
		pop	bc			;BC=code we expect
		or	a
		sbc	hl,bc
		add	hl,bc			;HL=code we obtained
;		jp	nz,sfcerr3
		push	af		;preserve Z flag

		push	hl		;HL=code we obtained
		ld	hl,RX_buf
		ld	bc,#80
		ld	de,eol
		call	look_for_string		;ošetøit? ukonèení øádku je vždycky!!
		push	de			;DE=start of message 2
		ld	a,(de)
		or	a
		jr	z,rfa4			;Z=second message does not exist

		call	ConvRStr16
		pop	de			;DE=start of message 2
		push	hl		;HL=2nd code number
		ld	h,d
		ld	l,e
		call	print_ftp_message

		pop	de		;DE=2nd code number
		pop	hl		;HL=1st code number
		pop	af
		jp	nz,sfcerr3
		jr	rfa5		

rfa4		pop	de			;DE=indifferent
		ld	de,0			;DE=0=signal no 2nd code came in
		pop	hl			;HL=1st code we obtained
		pop	af
		jp	nz,sfcerr3

rfa5		xor	a			;set A=0 and NC=all ok
		ret
		

;rfa_err		ld	c,11
;		jp	display_error
		

;62) clears RX and TX buffers, or only one of them
clear_buffers	ld	bc,buffers_len-1
cb2		ld	hl,RX_buf
		ld	de,RX_buf+1
cb1		ld	(hl),0
		ldir
		ret
clear_RX_buf	ld	bc,buffers_len/2-1
		jr	cb2			
clear_TX_buf	ld	hl,TX_buf
		ld	de,TX_buf+1
		ld	bc,buffers_len/2-1
		jr	cb1

;error handling: (Busy's solution)
;main routine 	ld 	sp,stack
;		...
;		call	subrout1
;		...
;		call	subrout2
;		etc.
;
;subrout1	...
;		jp	error_handler
;		...	
;		and	a	;NC=all ok
;		ret
;
;error_handler	ld 	sp,stack-2
;		call	display_error
;		scf	;C= was error
;		ret
;63) prints error message, IN=register C=error number, OUT=print output, then returns to the main program
;may be called at any time from any place
;if "error_handler" called, it jumps to the highest level, if "display_error" is called, it returns,
;to from where it has been called
;3 types:
;display_error=		only displays error number from C input an returns with carry
;error_handler=		displays error and jumps to error_handler_loop
;error_handler1=	only jumps to error handler loop

error_handler	call	display_error
		call	wifi_unwait
		call	set_3_5mhz
		call	passive_receive_off	;hope it does not affect other routines
;error_handler1	call	wifi_unwait
;		ld	a,c
;		cp	4
;		jp	z,server_connection_error		
		ld 	sp,basic_end-2	;Busy's universal solution. Jump back to "error_handler_loop"
		ret

display_error	set	4,(ix+0)	;PRINT again. Return back to from where you were called.
		ld	h,0
		ld	l,c		;C=error code
		ld	de,block_asci
		push	de
		call	HL2ASCII
		ex	de,hl
		ld	(hl),0
;		call	clear_edit_zone
		ld	de,error_txt
		call	print_ez2
		pop	de
		call	PRINT
		call	akey
		call	clear_edit_zone
		scf
		ret

/*
;error_handler	ld 	sp,stack-2	;Busy's universal solution. Jump back to "key_scan"
error_handler	ld 	sp,stack-2	;Busy's universal solution. Jump back to "error_handler_loop"
		dec	sp
		dec	sp
;		call	display_error
;		scf	;C= was error
;		ret

display_error	set	4,(ix+0)	;PRINT again. Return back to from where you were called.
		ld	h,0
		ld	l,c		;C=error code
		ld	de,block_asci
		push	de
		call	HL2ASCII
		ex	de,hl
		ld	(hl),0
;		call	clear_edit_zone
		ld	de,error_txt
		call	print_ez2
		pop	de
		call	PRINT
		call	akey
		call	clear_edit_zone
		scf
		ret
*/

;64)
;connect to server, main text must be prepared in TX_buf, sends commands eg. "AT+CIPSTART=1,"192.168.112",21"
;OUT=NC=all ok, else error
cipstart_connect
		ld	hl,cipstart		;make connection to server
		call	send_string		;send "AT+CIPSTART="
		ld	c,3
		jp	nz,error_handler	;connect to server
cs_con_buf	ld	hl,TX_buf		;send it
		call	send_string
		ld	c,3
		jp	nz,error_handler

		ld	hl,CONNECT		;new concept
;		ld	de,CONNECT		;check for answer
		jp	check_module_answer


;65)
;sends PASV command to ftp server+ sends connection command "AT+CIPSTART=1,"TCP","h1,h2,h3,h4",port"
;OUT=C=success
enter_passive_mode
		ld	hl,ftp_pasv
		xor	a			;A=0=command only
		ld	de,227
		call	send_ftp_command
		ld	c,41
		jp	c,error_handler

;		ld	de,TX_buf
;		ld	bc,4
;		ldir
;		ld	hl,eol
;		ld	bc,3
;		ldir
;		call	cipsend_request

		ld	hl,TX_buf	;now, enter passive mode with
					; "AT+CIPSTART=1,"TCP","h1,h2,h3,h4",port"
		ld	(hl),"1"
		inc	hl
		ld	(hl),","
		inc	hl
		ex	de,hl
		ld	hl,tcp
		ld	bc,7
		ldir
		push	de		;DE=where to continue with LDIR to TX buffer

		ld	de,zavorka_leva
		ld	hl,RX_buf
		ld	bc,75
		call	look_for_string
		jr	nz,epm4			;NZ=error, string not found
;		jp	nz,error_handler
		
		ld	b,4			;you found start of (h1,h2,h3,h4,p1,p2), now get the numbers
epm1		push	bc
		push	de			;DE points to source IP address
		ld	de,carka
		call	look_for_string
		jr	nz,epm4
		pop	de
		or	a
		sbc	hl,de			;L=length of IP address part
		ex	de,hl			;HL=source
		pop	bc			;cykly
		ld	c,e			;C=délka èásti adresy	
		pop	de			;TX buffer

epm2		ld	a,(hl)			;nasypej èást IP adresy do TX bufferu a zakonèi teèkou
		ld	(de),a
		inc	de
		inc	hl
		dec	c
		jr	nz,epm2
		ld	a,"."
		ld	(de),a
		inc	de
		push	de			;next TX buffer position
		inc	hl
		ld	d,h
		ld	e,l			
		djnz	epm1

		pop	de
		dec	de
		ld	a,34
		ld	(de),a			;IP address is complete in TX buffer
		inc	de
		ld	a,","
		ld	(de),a
		inc	de
		push	de			;DE=next TX buffer position
		
						;HL=port address start (p1,p2)
		ex	de,hl
		call	ConvRStr16
		push	hl			;L=higher port number
		inc	de
		call	ConvRStr16
		pop	de			;L=lower port number
		ld	h,e			;HL=port number
		ld	de,block_asci
		push	de
		push	de
		call	HL2ASCII
		pop	hl
		ex	de,hl
		or	a
		sbc	hl,de
		push	hl
		pop	bc
		pop	hl			;TX pos in buffer
		pop	de
		ldir				;port number in the place
		ld	hl,eol
		ld	bc,3
		ldir

		call	clear_RX_buf
		ld	(ix+6),5
epm3		call	cipstart_connect	;connect to ftp server and evaluate answer
		ret	nc		;NC=all ok, we are connected to server
		dec	(ix+6)
		jr	nz,epm3
epm4		ld	c,9
		jp	error_handler

;66)
;inputs character. OUT=C=length of input string, HL= start of string=INPBUFF
;OUT=NZ=data inputed, Z=abort pressed, A=4
input_line	push	ix
		ld	ixh,64
		call	INPUT
		pop	ix

		cp	4
;		ld	c,a
		ret	z
		dec	c
		inc	c
		ret	z			;Z=cursor was 0
;		jp	z,error_handler

input_l_count	ld	hl,INPBUFF+254		;username
		ld	bc,255		

il1		ld	a,(hl)
		cp	#20		;count from behind, correct way
		jr	z,il3		;C=length of username
		or	a
		jr	nz,il2
il3		dec	c
		dec	hl
		jr	il1
il2		ld	hl,INPBUFF
		dec	c
		inc	c
		jr	z,input_line	;empty line inserted, try again
		ret

clear_inp_buf	ld   hl,INPBUFF
	        ld   b,255
cib		ld   (hl),32
        	inc  hl
	        djnz cib
		ret



;68) sends purely AT+CIPSEND=1,data length
cipsend_lod	ld	hl,at_cipsend	;send "AT+CIPSEND="
		call	send_string
		jp	nz,cr_err

		ld	a,"1"
		ld	hl,TX_buf
		push	hl
		ld	(hl),a
		inc	hl
		ld	(hl),","
		inc	hl
		ld	(hl),0
		pop	hl
		call	send_string	;"1,"
		jp	nz,cr_err

;		ld	hl,(portion_len)
		ld	hl,(ftp_upl_len)
		ld	de,block_asci
		push	de
		call	HL2ASCII
		xor	a
		ld	(de),a
		pop	hl
		call	send_string	;number of bytes to be sent
		jp	nz,cr_err
		ld	hl,eol
		call	send_string
		jp	nz,cr_err

		ld	hl,char_zob	;new concept
;		ld	de,char_zob	;Wifi module returned ">" to show readiness to accept?
		jp	check_module_answer
;		call	check_module_answer	;show error, if any
;		jp	c,ret2main_scr	;was error
;		ret

;69) display_progress	prints length of file each time file is loaded/saved, length taken from rest_len
display_progress
		ld	hl,txt_adr_progress+10
		push	hl
		ld	de,spaces+20
		call	PRINTHL

		ld	hl,rest_len
		ld	de,zzbin
		ld	bc,4
		ldir
		call	HL2ASCII32
		ld	de,zzdec-1
dp0		inc	de
		ld	a,(de)
		or	a
		jr	z,dp0

		pop	hl
		jp	PRINTHL

;70) look_for_ipd	looks for IPDs in the incoming bytes
;OUT=A=connection number (0-3),HL= length of data (eg. +IPD,0,25:)
;!!!! in active mode returns eg: +IPD,0,25:331 Password required....
;!!!! in passive mode returnseg: +IPD,0,11. 11 bytes data then have to be fetched with AT+CIPRECVDATA=0,11.!!!

look_for_ipd	ld	(ix+6),3		;(was 0), 3 attempts for each search
		call	clear_RX_buf
lfi7		ld	hl,ipd			;"+IPD,"
		call	look_on_fly
		jr	z,lfi3
;		dec	(ix+6)
;		jr	nz,lfi7
lfi_err		ld	c,12
lfi_err1	scf				;set C to indicate error
		ret
;		jp	error_handler

lfi3		scf
		call	rece_byte
		jr	nz,lfi4
		dec	(ix+6)
		jr	z,lfi_err
		jr	lfi3

lfi4		sub	#30
		push	af			;A=channel number (0-3)

lfi2		scf
		call	rece_byte
		jr	nz,lfi5
		dec	(ix+6)
		jr	z,lfi_err
		jr	lfi2

lfi5		ld	de,RX_buf		;now read length of data
		push	de
look_f_ipd_loop	scf
		call	rece_byte
		jr	nz,lfi6
		dec	(ix+6)
;		jr	z,lfi_err
		jr	nz,look_f_ipd_loop
		pop	af
		pop	de			;get SP correct
		ld	c,35
		jr	lfi_err1

lfi6		cp	":"
		jr	z,lfi1
		ld	(de),a
		inc	de
		jr	look_f_ipd_loop

lfi1		pop	de			;HL=RX_buf
		call	ConvRStr16		;now parse lenght of data
		pop	af			;A=channel number, HL=lenght of data
		scf
		ccf				;set NC for all ok
		ret				;next reading of bytes brings data



;73)prints status of URL and login
print_ftp_status
		ld	de,logged_in
		ld	hl,txt_adr_speed_login+12
		call	PRINTHL
		ld	de,current_login
		call	PRINT
		ld	hl,txt_adr_host
		ld	de,host
		call	PRINTHL
		ld	de,spaces
		call	PRINT
		ld	de,current_host
		ld	hl,txt_adr_host+6
		jp	PRINTHL



;74) send "noop" command
;OUT=NC="noop" successfuly accepted, all ok
send_noop	xor	a
		ld	hl,ftp_noop		;send NOOP command
		ld	de,200			;ftp code we accept
		jp	send_ftp_command	;tail call
;		jp	send_ftp_command
;		ret
;		jp	nc,key_loop		;!!!!!!!!NC=expeted ftp code returned, OK, we are connected and logged in

/*replaced by prn_host_user_pas
;75) prints selected URL/host
print_url	ld	de,host_url
		ld	hl,txt_adr_hostvar
		call	PRINTHL
		ld	de,spaces
		call	PRINT
pu		jp	clear_edit_zone
*/

;76) OUT= print Transfer OK, or error, or aborted, or incomplete
print_transfer_status
		call	clear_edit_zone
		ld	de,transfer
		call	print_ez1
		ld	a,(ix+23)
		cp	1
		jr	z,pts1		;Z=transfer aborted
;		ret	z
		push	af
		ld	hl,txt_adr_edit_zone1+9
		push	hl	
		ld	de,spaces
		call	PRINTHL
		pop	hl
		pop	af		;flags preserved from previous CP
		ld	de,error_answ
		jr	nc,pts2
		ld	de,ok_
		jr	pts
pts2		cp	3
		jr	nz,pts
		ld	de,incomplete
pts		call	PRINTHL
pts1		call	akey
;		jr	pu
		jp	clear_edit_zone



;78)prints ftp message on the screen
;IN=HL=start address of message to print
print_ftp_message
		push	hl			;HL=start address of message to print

	IFDEF hgfx64x24
	call	set_fdma_to_fill_len_in_bc_512

;Y jsou radky, X=sloupce		
;		ld	hl,0
		ld	(VIDEO_REGS.OFFSET_X),hl
		ld	(VIDEO_REGS.OFFSET_X_R),hl

		ld	hl,txt_adr_ftp_reports_src_hgfx
		ld	(VIDEO_REGS.OFFSET_Y_R),hl
		ld	hl,txt_adr_ftp_reports_trg_hgfx	;nastav zdroj a cil pro ldir
		ld	(VIDEO_REGS.OFFSET_Y),hl	;predelat pro FDMA? nyní 48 bajtu a pomale

	ld	hl,SCR_ADDR				;zdroj/cil
	ld	(FDMAreg.FS_Adr),hl
	ld	(FDMAreg.FD_Adr),hl

	ld	hl,1024					;delka (asi ma byt jen 512, tj. 1 radek
	ld	(FDMAreg.F_Len),hl

		ld	a,PLANAR_MODE_COPY		;nastav mod COPY
		ld	(VIDEO_REGS.PLANAR_MODE),a

	xor	a
	ld	(FDMAreg.F_mode),a			;spust FDMA

		ld	a,PLANAR_MODE_ATTR
		ld	(VIDEO_REGS.PLANAR_MODE),a


/*adresy nefunguji, chce to offsety
	ld	hl,txt_adr_ftp_reports_src		;zdroj
	ld	(FDMAreg.FS_Adr),hl

	ld	hl,txt_adr_ftp_reports_trg		;cil
	ld	(FDMAreg.FD_Adr),hl
	
	ld	hl,1024					;delka (asi ma byt jen 512, tj. 1 radek
	ld	(FDMAreg.F_Len),hl
	
	ld	a,0
	ld	(FDMAreg.F_mode),a			;spust FDMA
*/


/*stare, ale funkcni jen HGFX
		ld	a,PLANAR_MODE_COPY	;nastav mod COPY
		ld	(VIDEO_REGS.PLANAR_MODE),a

		ld	hl,txt_adr_ftp_reports_trg	;nastav zdroj a cil pro ldir
		ld	(VIDEO_REGS.OFFSET_Y),hl	;predelat pro FDMA? nyní 48 bajtu a pomale
		ld	hl,txt_adr_ftp_reports_src
		ld	(VIDEO_REGS.OFFSET_Y_R),hl

;Y jsou radky, X=sloupce		
		ld	hl,0
		ld	(VIDEO_REGS.OFFSET_X),hl
		ld	(VIDEO_REGS.OFFSET_X_R),hl

		ld	b,2				;chceme 2 radky
pfm2		push	bc
		ld	b,0
pfm1		ld	a,(hl)
		ld	(hl),a				
		inc	hl
		ld	a,(hl)
		ld	(hl),a				;2 bajty preneseny
		inc	hl
		djnz	pfm1
		pop	bc				;1 radek prenesen
		djnz	pfm2
							;2 radky preneseny
		ld	a,PLANAR_MODE_ATTR
		ld	(VIDEO_REGS.PLANAR_MODE),a
*/

		ld	bc,#0206			;smaz 3.a 4. radek taky
		call	clear_line_hgfx

		ld	hl,txt_adr_ftp_reports
		push	hl

	ELSE
		ld	hl,#40A0		;print& scroll, we use 3 lines for ftp messages, 2nd line
		ld	de,#4080		;adresy jsou natvrdo:(( 3rd line
		ld	c,#10

rfa_prn1	ld	b,#20			
		push	hl
		push	de
rfa_prn		ld	a,(hl)			;move 2 lines down
		ld	(de),a
		inc	hl
		inc	de
		djnz	rfa_prn
		pop	de
		pop	hl
		inc	h
		inc	d
		dec	c
		jr	z,rfa_prn2
		ld	a,c
		cp	8
		jr	nz,rfa_prn1
		ld	hl,#40C0
		ld	de,#40A0
		jr	rfa_prn1

rfa_prn2	ld	hl,txt_adr_ftp_reports
		push	hl
		ld	de,spaces
		push	de
		call	PRINTHL
		pop	de
		push	de
		call	PRINT				;erase whole line by 2x32 spaces
		pop	de
		push	de
		ld	h,high txt_adr_ftp_reports+1;erase also 4th line
		ld	l,0
		call	PRINTHL
		pop	de
		call	PRINT

	ENDIF
		pop	hl				;HL=print address

;		ld	hl,txt_adr_ftp_reports
		pop	de			;DE=start address of message to print
		jp	PRINTHL			;print ftp report on 1st line


;79) connect to FTP server
connect_to_ftp_server
		call	wifi_wait
		ld	de,TX_buf		;prepare connection command to RX_buf
		ld	a,"0"			;like eg. "TCP","test.ilnx.cz",21"
		ld	(de),a
		inc	de
		ld	a,","
		ld	(de),a
		inc	de
		ld	hl,tcp
		ld	bc,7
		ldir
		ld	hl,host_url
;		push	hl

ctfs4		ld	a,(hl)			;ldir until ":", if any
		or	a
		inc	hl
		jr	z,ctfs3			;Z=URL name complete
		cp	":"
		jr	z,ctfs3
		ld	(de),a
		inc	de
;		inc	hl
		jr	ctfs4
		

;		call	count_com_len
;		pop	hl
;		push	hl
;		ldir				;eg. "test.ilnx.cz"

ctfs3		ld	c,a			;URL name on its place in TX_buf, C=0 or ":"
		ld	a,34			;uvozovky
		ld	(de),a
		inc	de
		ld	a,44			;carka
		ld	(de),a
		inc	de
;		pop	hl			;HL=host_url
;		push	de			;DE=current TX buf addr

		ld	a,c
		or	a
		jr	nz,ctfs1


;		ld	c,46			;BC=46, URL len
;		ld	de,dvojt		;find out port number from host_url
;		call	look_for_string
;		ex	de,hl
;		pop	de			;HL=start of port number, DE=current TX buf addr
;		jr	z,ctfs1			;NZ= no port found after ":", so, port will be 21

fl32		ld	hl,ftp_port

;		ld	hl,ftp_port
;		ld	bc,2
;		ldir

ctfs1		ld	a,(hl)
		or	a
		jr	z,ctfs2
		cp	"0"			;if not numbers, use port 21
		jr	c,fl32
		cp	"9"+1
		jr	nc,fl32
fl31		ld	(de),a
		inc	hl
		inc	de
		jr	ctfs1

ctfs2		ld	hl,eol
		ld	bc,3
		ldir				;connection command completed in TX_buf

		call	clear_RX_buf
fl1		call	cipstart_connect	;connect to ftp server and evaluate answer
		jr	nc,fl2			;NC=all ok, we are connected to server
;error 10 ok, but more precise error code comes from check_module_answer (c=1 or 11)
;		jp	error_handler		;we must end, if not connecttion not successful

server_connection_error
		ld	de,ftp_con_err
		call	print_ez1
		call	akey
clear_ini_keyl	call	clear_edit_zone
;		jp	error_handler1		;ends in a loop, if connection not sucessuful
initsp_keyloop	ld	sp,basic_end-2
		jp	key_loop

fl2	;;	call	get_status_ftp

		ld	h,high txt_adr_ftp_reports-2
		ld	l,0
		ld	(HLKO+1),hl
		ld	hl,RX_buf
		ld	bc,buffers_len
		push	hl
		push	bc
		call	receive_data_timeout

fl21		pop	bc			;BC=length to be serached
		pop	hl			;HL=start adress to be searched
		ld	de,dvojt
		call	look_for_string
		call	nz,wifi_unwait
		ret	nz
;		jr	nz,fl_usr_psw
		push	de			;DE=byte after found string
		push	bc
		call	PRINT
		ld	hl,HLKO+1
		ld	(hl),0
		inc	hl
		inc	(hl)			;increase line number
		jr	fl21

;80) for login and auto login purposes, OUT=Z=old connection same as new, NZ=proceed to connection
test_ftp_connection
		ld	bc,#80
		ld	hl,current_host
		ld	de,host_url
		call	look_for_string
		ret	z			;current url is the same as new one

		ld	de,already_connect
		call	print_ez1
		ld	de,current_host
		call	PRINT
		ld	de,do_you_want_rec
		call	print_ez2
		ld	de,host_url
		call	PRINT
		ld	de,yesno
		call	PRINT
tfc1		call	KEYSCAN
		cp	"y"
		jr	z,logoff_current	;proceed to new connection
		cp	"n"
		jr	z,tfc2
;		jr	z,key_loop
		cp	"b"
		jr	nz,tfc1
tfc2		
;		jp	z,ret2main_scr		;clear edit zone and jp to key:loop
;		jr	tfc1

ret2main_scr	call	passive_receive_off	;hope, it does not affect other routines
		jp	clear_edit_zone	;clear 2 bottom lines
;		jp	key_loop

logoff_current				;end current session
		call	ftp_quit_connection	;send QUIT command
		ld	hl,at_cipclose5
		call	send_string
		ld	hl,ok
		call	look_on_fly
		jp	nz,cr_err		;all closed, now proceed to new connection
		call	clear_edit_zone
		inc	b			;set NZ
		ret
;81)
set_3_5mhz	xor	a			;0=3,5Mhz, 1=7Mhz, 2=14Mhz, 3=20Mhz
		jr	s20
;82)
set_20mhz	ld	a,3
s20		ld	bc,#783B
		ld	l,#30
		out	(c),l
		inc	b
		out	(c),a
;		nop			;test pro LMN
		ret			;nový core by tuto chybu mìl øešit
		halt			;test pro LMN
		halt
		halt
;		ret			;pozor, 2xRET= bezpecny navrat z rutiny. Obcas se RET preskoci a jede se dal!!!! Az to LMN vyresi, tak vymazat ten jeden RET

;83) IN=HL=command, C=including parameter, NC= command only
send_ftp_command_in_passive_mode
		ld	de,TX_buf
;		ld	bc,5
;		ldir

		push	af		;preserve carry
sfcpm2		ld	a,(hl)
		or	a
		jr	z,sfcpm3
		ld	(de),a
		inc	hl
		inc	de
		jr	sfcpm2
	
sfcpm3		pop	af
		jr	nc,sfcpm1

		push de
		call	input_l_count
		pop	de
		ldir
	
sfcpm1		ld	hl,eol
		ld	bc,3
		ldir

;;;koko
		call	clear_rece_buf

		ld	hl,at_cipsend
		call	send_string
		jp	nz,cr_err

		bit	4,(ix+3)	;send session ID
		ld	a,"0"
		jr	z,cr11
		inc	a		;A="1"
cr11		ld	hl,TX_buf-3
		push	hl
		ld	(hl),a
		inc	hl
		ld	(hl),","
		inc	hl
		ld	(hl),0
		pop	hl
		call	send_string	;eg. "0,"
		jp	nz,cr_err

		ld	hl,TX_buf
		call	count_com_len	;count length of data in TX_buf
		ld	h,b
		ld	l,c

		ld	de,RX_buf
		push	de
		call	HL2ASCII
		xor	a
		ld	(de),a

		pop	hl		;RX_buf=length of command in ASCII, eg. "20"
		call	send_string	;send length of command
		jp	nz,cr_err

		ld	hl,eol
		call	send_string	;command completely sent
		jp	nz,cr_err

		ld	hl,char_zob	;new concept
;		ld	de,char_zob	;Wifi module returned ">" to show readiness to accept?
		call	check_module_answer
		jr	c,sfcip_err
;		jp	c,ret2main_scr	;was error

		ld	hl,TX_buf	;send data to ftp server from TX_buf address
		call	send_string
		jp	nz,cr_err

;		ld	(ix+6),3	;was 0
sfcip3		ld	hl,sendok
		call	look_on_fly
		jr	z,sfcip4
;		dec	(ix+6)
;		jr	nz,sfcip3
sfcip_err	ld	c,37
		jp	error_handler
;		jp	nz,cr_err

;koko/*toto myslím netøeba, vrací serii IPDcek, test na UNLINK ERROR!!!!
sfcip4		ld	hl,RX_buf
		ld	bc,#80
		push	hl
		push	bc
		call	receive_data_timeout
;tady teprve je v RXbufferu udaj s IPD, a pod IPD 0 uz byva 226 Transfer ok, pri malych souborech, toto treba osetrit
;ale opravdu se musíme ujistit, že jsou tady IPDèka, jinak program pøedbìhneme, a vrátí chybu 34
		pop	bc
		pop	hl
		ld	de,ipd+2	;omit #D,#A
		call	look_for_string
		jr	nz,sfcip4	;endles loop!!!! avoid!!!

;koko*/

;;;koko sfcip4		;;;kokocall	clear_rece_buf

/*		ld	hl,at_ciprecvdata	;send AT command to receive desired length of data
		call	send_string
		jp	nz,cr_err

		ld	a,"0"
		ld	hl,TX_buf
		push	hl
		ld	(hl),a
		inc	hl
		ld	(hl),","
		inc	hl
		ld	(hl),"1"
		inc	hl
		ld	(hl),"2"
		inc	hl
		ld	(hl),"8"
		inc	hl
		ld	(hl),#D
		inc	hl
		ld	(hl),#A
		inc	hl
		ld	(hl),0
		pop	hl		;HL=TX_buf

		call	send_string	;eg. "0,"
		jp	nz,cr_err

;cr12		ld	hl,ok
;		call	look_on_fly
;		jr	nz,cr12		;dat pryc, najde ok, ktere je az za zpravami z ftpka

		ld	bc,#80
		ld	hl,RX_buf
		push	hl
		ld	de,#FFFF
		call	rece_block

		pop	hl		;HL=RX_buf
		ld	de,dvojt
		call	look_for_string
		push	de
		
		call	ConvRStr16
*/
		call	ask_for_reply_in_passive_mode

		ld	bc,150		;HL=message nr 1, DE=message nr.2 (0 if no message nr 2)
		or	a
		sbc	hl,bc
		jr	z,sfcip1

		add	hl,bc
		ld	bc,125
		or	a
		sbc	hl,bc
		ld	c,13
		jp	nz,error_handler	;neither code 150, nor 125 returned		

sfcip1		ld	a,d
		or	e
		jr	z,sfcip2		;Z=message nr 2 not exist

		ld	hl,226
		or	a
		sbc	hl,de
		jr	nz,sfcip2
		ld	(ix+23),0
		ret

sfcip2		ld	(ix+23),2	;transfer error (but code 226 can come later with longer files)
		ret

/*		push	de


		ld	de,150		;Connection accepted
		or	a
		sbc	hl,de
		ld	c,13
		jp	nz,error_handler
		

		pop	hl		;check, if 226 message comes (it comes with short files)
		push	hl
		call	print_ftp_message

		pop	hl
		ld	de,eol
		ld	bc,#80
		call	look_for_string
		push	de

		call	ConvRStr16
		ld	de,226
		or	a
		sbc	hl,de
		ld	hl,transfer_flag
		pop	de
		ld	(hl),2		;transfer error (but code 226 can come later with longer files)
		ret	nz
;		jr	nz,fdf_main
		ld	(hl),0		;code found, set transfer status as OK
		ld	h,d
		ld	l,e
		jp	print_ftp_message
*/

;84)
;find out, if module has available data, OUT=NZ=data available, HL=always valid length of data (either #800 or less), DE=always max data length (#800 given by download_length)
;OUT=Z=HL=0=data not available
data_available_in_module
;		ld	(ix+6),#5		;5 attempts, increased to #20, seem to help, 0.97- #20 increased to #80
						;was #80, <5= file download returns error 26, the less the quicker directopry retrieve.
data_available_in_module_dir
		ld	a,#20			;for dir 5 repetitions should be enough
		jr	dam6
data_available_in_module_file		
		ld	a,#80			;for sucessful file download we need more than for dir, theoretically can be
dam6		ld	(ix+6),a		;instant repetiotion, bacuse download is not called if file is not completed
		call	clear_rece_buf
;		call	clearni_RXko		;get rid off IPDs, if any

dam1		ld	hl,at_ciprecvlen	;now, send AT command to start receiving data
		call	send_string		;data available? (pridat timeout!!)
		jp	nz,cr_err

dam2		ld	hl,RX_buf		
		ld	bc,#80
		push	hl
		push	bc
		call	receive_data_timeout
		pop	bc
		pop	hl
		ld	de,dvojt
		call	look_for_string
		jr	nz,dam2			;previous icoming IPDs in RX:buf. But we need
						;answer to AT+CIPRECVLEN?
		ex	de,hl
		ld	de,carka
		call	look_for_string
		jp	nz,cr_err
		call	ConvRStr16
		ld	a,h
		or	l
		jr	z,dam3			;Z=no data available, check again
;		ret	nz
		ld	de,download_length
		ex	de,hl
		or	a
		sbc	hl,de			;HL=#800, DE=available length
		jr	nc,dam4
		add	hl,de			;limit len to #800
dam5		xor	a			;HL=#800
		inc	a			;set NZ, data available
		ret
		
dam4		ld	h,d			;data<download_length (#800)
		ld	l,e
		jr	dam5
					
dam3		dec	(ix+6)			;HL=max length of data available in module buffer
		jr	nz,dam1
		ret

;85) ask_for_data_in_passive_mode		;send "AT+CIPRECVDATA=1,2048" in passive receive mode
ask_for_data_in_passive_mode
		push	bc			;BC=rest_chunk
		ld	(rest_chunk),bc

		call	clear_rece_buf
;		call	clearni_RXko		;vycisti pripadne prichozi IPDs

		ld	hl,block_asci
		ld	(hl),"1"
		inc	hl
		ld	(hl),","
		inc	hl
		pop	hl
		ld	de,block_asci+2
		call	HL2ASCII
						;prepare text "1,"+ rest_chunk in block_asci
		ex	de,hl
		ld	(hl),#D
		inc	hl
		ld	(hl),#A
		inc	hl
		ld	(hl),0

		ld	hl,at_ciprecvdata	;send "AT+CIPRECVDATA=1,2048" command to receive desired length of data
		call	send_string
		jp	nz,cr_err

		ld	hl,block_asci
		call	send_string
		jp	nz,cr_err

		ld	hl,ciprecvdata
		call	look_on_fly
		jr	z,afdipm3
		ld	c,37
		jp	error_handler

afdipm3		ld	hl,block_asci
		push	hl
afdipm1		scf
		call	rece_byte
		cp	":"
		jr	z,afdipm2		;Z=prepared to read pure data
		ld	(hl),a
		inc	hl
		jr	afdipm1




/*
afdipm5		ld	hl,carka
		call	look_on_fly		;vyhodnoceni chyby!!!
		jr	z,afdipm3
		ld	c,37
		jp	error_handler

afdipm3		ld	hl,block_asci
		push	hl
afdipm1		scf
		call	rece_byte
		cp	"I"
		jr	z,afdipm4
		cp	":"
		jr	z,afdipm2		;Z=prepared to read pure data
		ld	(hl),a
		inc	hl
		jr	afdipm1
*/
		
afdipm2		pop	de
		ld	(hl),0
		call	ConvRStr16
		ld	(rest_chunk),hl
		ret
/*
afdipm4		scf
		call	rece_byte
		cp	#A
		jr	nz,afdipm4
		jr	afdipm5		

;		ld	hl,dvojt
;		jp	look_on_fly
*/
	
;86) ask_for_reply_in_passive_mode		;send "AT+CIPRECVDATA=1,128" in pasive receive mode
ask_for_reply_in_passive_mode
;OUT=HL=code 1, DE=code 2 or 0 if code 2 not present
		ld	(ix+6),4	;4 attempts

;;;koko		
		call	clear_rece_buf

afripm4		ld	hl,at_ciprecvdata	;send AT command to receive desired length of data
		call	send_string
		jp	nz,cr_err

		ld	a,"0"
		ld	hl,TX_buf
		push	hl
		ld	(hl),a
		inc	hl
		ld	(hl),","
		inc	hl
		ld	(hl),"1"
		inc	hl
		ld	(hl),"2"
		inc	hl
		ld	(hl),"8"
		inc	hl
		ld	(hl),#D
		inc	hl
		ld	(hl),#A
		inc	hl
		ld	(hl),0
		pop	hl		;HL=TX_buf

		call	send_string	;eg. "0,"
		jp	nz,cr_err

afripm2;;;koko		call	clear_RX_buf	;the answer is directly eg: #D,#A,"CIPRECVDATA,42:150 Connection accepted..."
/* rece_block seems to fast with 20 MHz	;delete this call after program rins good
		ld	bc,#80
		push	bc
		ld	hl,RX_buf
		push	hl
		ld	de,#FFFF
		call	rece_block

		pop	hl		;HL=RX_buf
		pop	bc
		push	bc
		ld	de,data
		call	look_for_string
		jr	z,afripm1	;Z=answer found		
		pop	bc
*/
		ld	bc,#80
		push	bc
		ld	hl,RX_buf
		push	hl
		call	receive_data_timeout
		pop	hl
		pop	bc
		ld	de,data
		call	look_for_string
		jr	z,afripm1

		dec	(ix+6)
		jr	nz,afripm4
;		jr	nz,afripm2
afripm3		ld	c,34
		jp	error_handler

afripm1		ld	de,dvojt
		ld	bc,#80
		call	look_for_string	;test na výsledek hledání chybí!!!!!
		jr	nz,afripm3	;NZ=not found
		push	de
		call	ConvRStr16
		pop	de		;DE=start of message 1
		push	hl		;HL=code number 1
		push	de		;DE= start of message 1
		ld	h,d
		ld	l,e
		call	print_ftp_message	;print first message

		pop	hl		;HL=start of the asnwer
		ld	de,eol
		ld	bc,#80
		call	look_for_string
		jr	nz,afripm3
		push	de		;DE=start of message 2
		ld	a,(de)
;		or	a
		cp	#D
		jr	z,afr1		;Z=second message not present
		call	ConvRStr16
		pop	de		;start of message 2
		push	hl		;HL=code number 2
		ld	h,d
		ld	l,e
		call	print_ftp_message
		pop	de		;DE=code number 2
		pop	hl		;HL=code number 1
		ret
afr1		pop	de
		xor	a
		ld	d,a
		ld	e,a		;DE=0, message 2 not present
		pop	hl		;HL=code number 1	
		ret

;77) turn off passive recieve mode
passive_receive_off
		ld	a,"0"		;recvmode=0
		jr	passive_receive_switch

;87) turn on passive receive mode
passive_receive_on
		ld	a,"1"		;recvmode=1
passive_receive_switch
		ld	(recvmode),a
		ld	hl,TX_buf
		push	hl
		ld	(hl),a
		inc	hl
		ld	(hl),0

		ld	hl,at_ciprecvmode	;turn on passive transfer mode
		call	send_string
		jp	nz,cr_err

		pop	hl
		call	send_string	;eg. "0,"
		jp	nz,cr_err
		ld	hl,eol
		call	send_string	;command completely sent
		jp	nz,cr_err
		ld	hl,ok
		call	check_module_answer
		ret	nc
		ld	c,39
		jp	error_handler
;		jp	c,ret2main_scr	;we cannot check "OK" since we are already in passive mode, maybe needs solving
;		ret			;no need to solve, module responses are the same not depending on receive mode

;88) print working directory+ copy it to memory
print_working_directory
;;;koko		
		call	clear_rece_buf
		xor	a		;;;koko
;		and	a
		ld	hl,ftp_pwd
		ld	de,257

;		ld	a,(hl)		;jen test na chybu 34, na nic neprisel
;		cp	"P"
;		jr	z,pwd2
;		halt

pwd2		xor	a		;;;koko		
		call	send_ftp_command
		jr	nc,pwd1		;all ok
					;test BC if 226
		push	hl
		ld	hl,257
		or	a
		sbc	hl,de
		pop	hl
		jr	z,pwd1
		ld	bc,226
		or	a
		sbc	hl,bc
		jr	z,pwd1
;		push	af		;preserve carry
;		ld	de,226		;check not needed anymore, code 226 checked at the dir retrieve end
;		or	a
;		sbc	hl,de
;		pop	bc
;		jr	z,pwd1
;		push	bc
;		pop	af		;carry is back
		ld	c,21
		jp	error_handler

pwd1		
		ld	hl,txt_adr_cwd
		push	hl		;HL=print address
	IFDEF hgfx64x24
		ld	bc,#0200
	ELSE
		ld	b,8*2
	ENDIF
		call	cls_9_lines
		ld	hl,RX_buf
		ld	de,uvoz
		ld	bc,#FF
		call	look_for_string
		push	de		;DE=start of path
		ex	de,hl
		ld	de,uvoz
		call	look_for_string
		ld	(hl),0		;end of path

;		pop	de		;toto asi netøeba, netøeba nahrávat cestu do pamìti
;		or	a
;		sbc	hl,de
;		ld	b,h
;		ld	c,l		;BC=length of path
;		push	de		;DE=start of path
;		ld	hl,ftp_path
;		ldir

		pop	de		;DE= start of path
		pop	hl		;HL= print address
		jp	PRINTHL		;print ftp path on the upper screen lines


;89) get_item_name	;get file name under cursor
;IN=C=bring full info, NC= bring length in DE only (OUT= then A has no meaning)
;OUT=HL=name start, BC= name length, DE= file length
;OUT=A=0= item is a directory+ HL, BC
;OUT=A=1=item is a file+ HL, BC
;OUT=A=2=item type cannot be determined (because of NLST command)+ HL, BC
;OUT=A=3= item not parsed (for the moment) bacause it is LIST in full, HL, BC irrelevant
;OUT=A=4= starting item ".."
;bits 1 (items 0=abbreviated, 1= full) and 3 (current command type 0=LIST, 1=NLST) from flag_dir are of interest here
get_item_name	ex	af,af'		;backup C/NC
		ld	hl,(cur_item_addr)
		ld	c,(hl)
		inc	hl
		ld	b,(hl)		;BC=item length

		dec	hl
		or	a
		ld	de,basic_end
		sbc	hl,de
		add	hl,de
		inc	hl
		inc	hl
;		inc	hl
		ld	a,4
		jr	z,gfn10
					;Z=first item ".." for going updir, BC=length of item
					;HL=basic_end
;		dec	hl
;		dec	hl
		bit	3,(ix+1)
		ld	a,2
		jr	nz,gfn6		;NZ=NLST command
		inc	a		;A=3
		bit	1,(ix+1)
		jr	z,gfn5		;Z=LIST+abbreviated=ok
		ret			;LIST+full, not supported at the moment

gfn6		;dec	a		;A=2=NLST command
		dec	bc
		inc	hl
;		inc	hl
		ret		


gfn5	;	inc	hl		;LIST+abbreviated
		ld	d,h
		ld	e,l
		add	hl,bc		;DE= item offset
		ld	a,(hl)
		push	af		;A= initial value
		push	hl		;HL= ending address
		ld	(hl),0
		ld	h,d
		ld	l,e		;HL= item offset
		inc	hl

		ld	a,(hl)
		cp	"D"
		push	af		;Z=directory, NZ=file



		ld	e,#20
gfn8		inc	hl
		ld	a,(hl)
		cp	e
;		inc	hl		;new
		jr	z,gfn8

		push	hl		;HL=pointer in item
		ex	de,hl
		call	ConvRStr16
		ld	(gfn10+1),hl	;HL=file length
		ex	de,hl		;DE=file length
		ex	af,af'
		pop	hl		;HL=pointer in the item
		jr	c,gfn9
		pop	hl		;A= initial value
		pop	hl		;HL= ending address
		pop	af		;Z=directory, NZ=file
		ret
		

gfn9		ld	b,4
		ld	a,#20
gfn1		cp	(hl)
		inc	hl
		jr	nz,gfn1

gfn2		cp	(hl)
		inc	hl
		jr	z,gfn2
		djnz	gfn1		
/*old
gfn9		ld	b,4		;continue looking for name itself
		ld	e,#20
gfn1		inc	hl
		ld	a,(hl)
		cp	e
		jr	z,gfn1

gfn2		inc	hl
		ld	a,(hl)
		cp	e
		jr	nz,gfn2
		djnz	gfn1
*/
;		inc	hl
		dec	hl
		push	hl		;HL points to name start, now get file length
		ld	bc,0		;BC=file length counter
gfn3		ld	a,(hl)
		or	a
		jr	z,gfn4
		inc	bc
		inc	hl
		jr	gfn3

gfn4		pop	hl		;HL=start of the name
		pop	af		;Z=directory, NZ=file
		ex	af,af'
		pop	de		;DE= ending address
		pop	af		;A= initial value
		ld	(de),a
		ex	af,af'		;Z=directory, NZ=file
		ld	a,0
gfn10		ld	de,#5555	;DE=file length
		ret	z		;A=0=item is a directory
		inc	a		;A=1=item is a file
		ret			;BC=file name length


;90)
print_dir_files_items			;after dir having been read, it prints number of items or dirs and files
		call	cls_dir_files

	IFDEF hgfx64x24
       		ld	a,1			;coulour 1 for dir_files
		ld	(VIDEO_REGS.COLOR),a
	ENDIF

		ld	hl,txt_adr_dir_info	;little space for better clarity
		ld	de,block_asci
		push	de
		ld	de,items
		bit	3,(ix+1)
		jr	nz,pdfi1	;NZ=NLST

		ld	de,dirs
		call	PRINTHL		;print "Dirs: "
		pop	de		;DE=block_asci
		push	de
		ld	hl,(dir_counter)
;		ld	h,0
;		ld	l,(ix+32)	;number of dirs
		call	HL2ASCII
		xor	a
		ld	(de),a
		pop	de
		push	de
		call	PRINT		;print number of directories
		ld	de,files
		call	PRINT		;print "Files: "
		jr	pdfi2

pdfi1		call	PRINTHL
pdfi2		pop	de		;DE=block_asci
		push	de
		ld	hl,(item_file_count)
		call	HL2ASCII
		xor	a
		ld	(de),a
		pop	de

	IFNDEF	hgfx64x24
		jp	PRINT		;Items: has been printed
	ELSE
;		ld	a,4			;back to colour (white)
;		ld	(VIDEO_REGS.COLOR),a
		call	PRINT
		jp	set_hgfx_ink_planar
	ENDIF

cls_dir_files	ld	de,spaces
		ld	hl,txt_adr_dir_info
		push	de
		call	PRINTHL
		pop	de
		jp	PRINT

;91)
search_marked_items
;RET if only marked item found
;IN=cur_item_addr, OUT=NZ=cur_item_addr, Z=already last file
		ld	hl,(cur_item_addr)
smi1		ld	c,(hl)
		inc	hl
		ld	b,(hl)		;BC=item length
		inc	hl
		ld	a,c
		or	b
		ret	z		;Z=last file

		bit	0,(hl)
		ret	nz		;NZ=cur_item_addr

		inc	hl
		inc	hl
		add	hl,bc
		ld	(cur_item_addr),hl
		jr	smi1



;92)
un_mark_all
;unmark or mark all items, IN=C=unmark, NC=mark
		ld	hl,0
		ld	(mark_counter),hl

		ex	af,af'		;preserve carry
		ld	hl,cur_item_addr
		ld	c,(hl)
		inc	hl
		ld	b,(hl)
		push	bc		;preserve original item pointer
		ld	bc,basic_end+fi_len-2
		ld	(hl),b
		dec	hl
		ld	(hl),c		;start of dir

ua1		ld	hl,(cur_item_addr)
		inc	hl
		inc	hl
		res	0,(hl)
		ex	af,af'
		jr	c,ua2
		set	0,(hl)		;mark
		exx
		ld	hl,(mark_counter)
		inc	hl
		ld	(mark_counter),hl
		exx

ua2		ex	af,af'
		ld	bc,cur_item_addr
		call	item_add
		jr	nz,ua1
		pop	hl		;renew original item pointer
		ld	(cur_item_addr),hl
		ret

;93)
;IN=A="A" for ASCCI (directory) or "I" for binary (files)
send_type_command_a
		ld	a,"A"
		jr	stc1
send_type_command_i
		ld	a,"I"
stc1		call	clear_inp_buf
		ld	(INPBUFF),a
		ld	a,1
		ld	de,200			;200 Switching to mode ASCII
		ld	hl,ftp_type
		call	send_ftp_command
		ret	nc
		ld	c,38
		jp	error_handler		

;94)
print_whole_screen
		call	cls_4000

		ld	de,menu1
		ld	hl,txt_adr_menu1
		call	PRINTHL			;print menu line 1
		ld	de,menu2
		ld	hl,txt_adr_menu2
		call	PRINTHL			;print menu line 2

		call	prn_w_onoff		;print if WIFI should be ON/OFF on quit
		call	prn_alogin		;print autologin status
		call	prn_lst_nlst_abbr_ful	;print line 16 with LIST/NLST/full/abbr status
		call	prn_file_start		;print line 17 with filename and start address
		call	prn_host_usr_psw	;print line 18 with host, user, password

pws2		bit	0,(ix+1)		;directory or header?
		jp	nz,print_working_directory
pws1		jp	print_title

	IFDEF hgfx64x24
;95) set_fdma_to_chars	
set_fdma_to_chars
	push	bc
	ld	hl,1	;1 bajt zkopiruj
	ld	de,63	;...a 63 preskoc
	ld	bc,8	;znak ma 8 bajtu
	jr	sftc1

;96)
set_fdma_to_fill_len_in_bc_512
;IN=BC=length
	push	bc
	ld	hl,0
	ld 	d,h
	ld	e,h
	ld	bc,512

sftc1	ld	(FDMAreg.FD_Copy),hl	;...a 63 pøeskoè.
	ld	(FDMAreg.FD_Mod),de
	ld	(FDMAreg.F_Len),bc
	pop	bc
	xor	a			;signal key 0 pressed, because of main keyboard routine
	ret	

;97)
set_hgfx_ink_planar
		ld 	a,4			;vrat puvodni
		ld 	(VIDEO_REGS.COLOR),a
;		ld	a,63
		ld	a,planar_pismo
		ld	(VIDEO_REGS.MASK),a
		ret

	ENDIF

;variables
;ftp_path	ds 0,#FE			;place for ftp path, asi netøeba
var_name	db "SARAH12BSD",0		;variable file name for download-user can change
		ds 56				;reserve
var_start	dw #C800			;variable start address-user can change
host_url	db "sarah.speccy.cz",0		;variable host-user can change 
		ds 30				;reserve for url
var_user	db "sarah",0			;variable user-user can change
		ds 31				;reserve
var_pasw	db "zxftpc",0			;variable password-user can change
		ds 31				;reserve

current_host	ds 64				;current host we are logged in
current_login	ds 3				;contains either "X" or "OK", both followed by 0

;temporary positions and addresses with directory
cursor_w_curad_tmp	dw #5555		;cursor address on the screen (attrs)
wind_curs_item_tmp	db #55			;cursor position on the screen
cur_item_adr_tmp	dw #5555		;item address in memory
item_pg_start_tmp	dw #5555		;address of the starting item on the screen
item_checksum		dw #5555		;if checksum does not match current 2 bytes in memory, position the cursor on the very first item

;commands
at		db "AT",#D,#A,0
ate0		db "ATE0",#D,#A,0
at_cipmux	db "AT+CIPMUX=1",#D,#A,0
cipstatus	db "AT+CIPSTATUS",#D,#A,0
cipstart	db "AT+CIPSTART=",0
uart		db "AT+UART_CUR="
_8100		db ",8,1,0,0",#D,#A
at_cwmode	db "AT+CWMODE=1",#D,#A,0	
;at_cipsntpcfg?	db "AT+CIPSNTPCFG?",#D,#A,0	;/*these relate to wifi setup
;at_cipsntpcfg	db "AT+CIPSNTPCFG=1,",0
;at_rst		db "AT+RST",#D,#A,0
;at_cwjap_cur?	db "AT+CWJAP_CUR?",#D,#A,0
;at_cwjap_def?	db "AT+CWJAP_DEF?",#D,#A,0
;at_autocon	db "AT+CWAUTOCONN?",#D,#A,0
;at_uart_def	db "AT+UART_DEF?",#D,#A,0
;at_cwlapopt	db "AT+CWLAPOPT=1,6",#D,#A,0
;at_cwlap	db "AT+CWLAP",#D,#A,0
;at_cwjap_def	db "AT+CWJAP_DEF=",#22,0
;at_cwqap	db "AT+CWQAP",#D,#A,0		;*/
at_cipsend	db "AT+CIPSEND=",0
at_cipclose1	db "AT+CIPCLOSE=1",#D,#A,0
at_cipclose5	db "AT+CIPCLOSE=5",#D,#A,0
at_cipclose	db "AT+CIPCLOSE",#D,#A,0
at_ciprecvmode	db "AT+CIPRECVMODE=",0
at_ciprecvdata	db "AT+CIPRECVDATA=",0
at_ciprecvlen	db "AT+CIPRECVLEN?",#D,#A,0

;ftp commands
ftp_user	db "USER ",0	;1 argument
ftp_pass	db "PASS ",0	;1 argument
ftp_size	db "SIZE ",0	;1 argument
ftp_pasv	db "PASV",0	;0 argument
ftp_retr	db "RETR ",0	;1 argument
ftp_quit	db "QUIT",0	;0 argument
ftp_stor	db "STOR ",0
ftp_stou	db "STOU ",0
ftp_appe	db "APPE ",0
ftp_abor	db "ABOR",0	;uses no argument
ftp_noop	db "NOOP",0	;uses no argument
ftp_list	db "LIST",0	;uses no argument
ftp_nlst	db "NLST",0
ftp_pwd		db "PWD",0
ftp_cwd		db "CWD ",0	; argument
ftp_cdup	db "CDUP",0
ftp_mkd		db "MKD ",0	;1 argument
ftp_rmd		db "RMD ",0
ftp_dele	db "DELE ",0
ftp_rnfr	db "RNFR ",0
ftp_rnto	db "RNTO ",0
ftp_type	db "TYPE ",0	;we use "A" or "I"

;answers
data		db "DATA",0
STATUS		db "STATUS:",0
CONNECT		db "CONNECT",0
sendok		db "SEND "
ok		db "OK"
eol		db #D,#A,0
dvojt		db ":",0
carka		db ",",0
uvoz		db 34,0
zavorka		db ")",0
zavorka_leva	db "(",0
char_zob	db "OK",13,10,"> ",0
ok_		db "OK",0
no_ap		db "No AP",0
error_answ	db "ERROR",0
ipd		db #D,#A,"+IPD,",0
;code_226	db "226",0
ciprecvdata	db "+CIPRECVDATA,",0
;closed		db "CLOSED",#D,#A,0
busy		db "busy",0

;texts
;dir_txt	db "Dir ",0
;not_empty_txt	db "not empty. Erase?",0
items		db "Items:",0
dirs		db "Dirs:",0
files		db "  Files:",0
full		db "full",0
abbr		db "abbr",0
first_item	db 3,0,0,"..",3,0,0,0
fi_len		equ $-first_item
ftp_port	db "21",0
tcp		db 34,"TCP",34,#2C,34,0	;délka 7 bajtù
speed		db "Speed:",0
module_no_aswer	db "..speed aligned, but no answer from module..",0
spaces		db "                                ",0

menu_dir	db "I-Fn Spc ZX R-Rr 6-Rn 7-MD Del Br-UD ss+/N",0
menu1		db "F-file T-start A-YES H-host E-usr ss+/P-pass U-upl S-size Q-quit",0
;menu1		db "S-size Q-quit F-file T-start A-YES H-host R-user P-pass U-upld",0
;menu2		db "W-wifi OFF ss+/L-auto/login O-logoff V-save app ss+/D-dwnld/file",0
menu2		db "W-wifi OFF Cs/ss+/L-login O-logoff V-savApp Cs/ss+/D-dwnld C-com",0
file		db "File: ",0
start		db "  Start: ",0
user		db "  User: ",0
pass		db "  Pass: ",0
enter_start_add	db "Enter start address: ",0
ftp_con_err	db "Error in connecting to FTP server",0
;login_to_ftp	db "L- login to FTP server",0
;file_size	db "S- file size",0
;download_file	db "D- download file",0
;ftp_quit_txt	db "T- quit FTP",0
;ftp_upl_txt	db "U- upload file",0
;url_txt	db "R- URL:",0
;saveapp_txt	db "A- save app",0
enter_comm	db "Enter command:",0
enter_name	db "Enter new name:",0
enter_dir	db "Enter dir name:",0
enter_url	db "Enter host:",0
enter_usr	db "Enter username:",0
psw		db "Enter password:",0
enter_fil_nam	db "Enter file name:",0
find_txt	db "Find:",0
loading_file	db "Downloading file... ",0
uploading_file	db "Uploading file... ",0
press_b		db "Press B to cancel",0
progress	db "Progress: ",0
file_exist_txt	db "File exists. Overwrite/Append/New/aBbort?",0
title		db "SARAH 1.2, ZX FTP client, Hood, 12/2021- 1/2026, "
wifi_type	db #55	;here will be either "M" for MB wifi, or "E" for el wifi, final result will be eg. MBSD, or MESX or EESX.

;/*	IFDEF mb03
;	IF mb03=1
;		db "MB"
;	ELSE
;	IF el=1
;		db "EL"
;	ENDIF
;*/
	IFDEF bs_dos
;	IF bs_dos=1
		db "BSD"
	ELSE
		db "ESX"
	ENDIF
		db 0
title_len	equ $-title-1
error_txt	db "error=",0

on		db "ON ",0
off		db "OFF",0
logged_in	db "Logged in: ",0
host		db "Host: ",0
transfer	db "Transfer aborted",0
incomplete	db "incomplete",0
save_app_head	db 3			;17 bytes header for application save
zxftpcl		db "SAR12SAV  "
;zxftpcl		db "ZXFtp_cl"		;8chars for esxdos name
;ver		db "09"
save_app_len	dw #5555
save_app_start	dw start_address,0

akey_txt	db " ..press a key..",0
yesno		db " Yes/No?",0
yes		db "yes",0
no		db "no ",0
already_connect	db "Already connected to ",0
do_you_want_rec	db "Reconnect to ",0

/*
press_reset	db "Q- quit",0
wifi_on_exit	db "W- wifi on quit: ",0
set_ap		db "A- connect to AP",0
set_speed_txt	db "V- set speed",0
disconn_AP_txt	db "D- disconnect from AP",0
reset_wifi_txt	db "R- reset WiFi",0
press_run_term	db "T- run terminal",0
disconnect	db "DISCONNECT",0
wifi_reset	db "Resetting Wifi...",0
ntp_timeout	db "NTP server timeout. Try again.",0
gmt_shift	db "GMT shift: ",0
eoleol		db #D,#A
		db #D,#A,0
time_zone_act	db "CFG:1",0
answ_cwjap	db "+CWJAP",0
ready		db "ready",0
ent_psw		db "Enter password for ",0
setting_speed	db "setting speed...",0
con_2_AP	db "connecting to AP...",0
current_ap	db "current AP: ",0
default_ap	db "Default AP: ",0
auto_ap		db "Auto AP: ",0
def_wifi_speed	db "Default wifi speed: ",0
excellent	db ",Best",0
good		db ",Good",0
fair		db ",Fair",0
poor		db ",Poor",0
Bd		db " Bd. ",0
cwjap_err_1	db "..connection timeout",0
cwjap_err_2	db "..wrong password",0
cwjap_err_3	db "..cannot find the target AP",0
cwjap_err_4	db "..connection failed",0
connect_success db "New connection succesful.",0
control_keys	db "Use arrows, ss+ENT for current AP, EDIT to cancel.",0
;cipstatus_2	db "= connected to AP, IP is obtained",0
;cipstatus_3	db "connected to server. Logged on: ",0
;cipstatus_3	db "= created TCP/UDP transmission",0
;cipstatus_4	db "= TCP/UDP transmission diconnected",0
;cipstatus_5	db "= does NOT connect to AP",0
mbfw		db "MBFW= ",0
*/
speed_table	db "0= 2400",0
		db "1= 4800",0
		db "2= 9600",0
		db "3= 19200",0
		db "4= 31250",0
		db "5= 38400",0
		db "6= 57600",0
		db "7= 115200",0  ;(default at reset)
		db "8= 230400",0
		db "9= 460800",0
		db "10= 576000",0
		db "11= 921600",0
		db "12= 1152000",0
		db "13= 1500000",0
		db "14= 2000000",0
		db "15= 2304000",0
		db "16= 3456000",0
;		db "17= 4608000",0
;		db "18= 5760000",0
;		db "19= 6912000",0
;		db "20= 8064000",0
;		db "21= 9216000",0
;		db "22= 10368000",0
;		db "23= 11520000",0
;contr_k_speed	db "Use arrows, ENT select, EDIT to cancel.",0
;sel_spd_ask_txt	db "Speed not supported by module, set it anyway?",0
unknown		db " unknown..",0

;flags=IX+0
flag1		db 8		;see start of the code, 2=SSL connection,0=TCP
flag_dir	db 0		;IX+1, flag related to dir
				;bit 0=dir already read?, 0=no, 1=yes
				;bit 1=current items in memory, 0=abbreviated, 1=full
				;bit 2=user wished items in memory, 0=abbreviated, 1=full
				;bit 3= current command type in memory, 0=LIST, 1=NLST
				;bit 4= user wished command type, 0=LIST, 1=NLST
				;bit 5= temporary flag, item being read in is file or dir, 0=file, 1=dir
				;bit 6= direction we go. 1= enter dir, 0= going updir
				;bit 7= are we testing first item "Total XY"?, 0=no, 1=yes
ud_speed	db 16		;IX+2,we want speed 16 for now (it is max speed)
flag2		db 0		;IX+3, print send command,0=NO, 1=YES
		db #20		;IX+4, free for use (maximum number of raw data reread, see "rece_loop")
		db 0		;reserved, free for use
		db #55		;IX+6, timeout for initi wifi speed management (used on more places)
		db #55		;IX+7, uart speed currently set in HW (0-23 speed set, 255 speed not set)
		db #55		;IX+8, maximum speed for bios (counted from FW)
recvmode	db 0		;IX+9, 0=active, 1=passive
		db #55		;IX+10, free for use
;dir_counter	db #55		;IX+10
	
cursor_w_stadr	dw #5900	;start address of cursor window for AP list
cursor_w_curad	dw #5900	;current address of cursor window
;cursor_w_curad	dw #5555	;current address of cursor window
		db #55		;IX+15, free for use, was counter of marked files (we need 16 bit counter)
AP_a_page	db 8		;;;;;IX+16= maximum number of lines in cursor window
wind_adr	dw #4B00	;not in use, was: start of print address in the window
item_pg_start	dw #5555	;;;;;start address of first dir item on displayed page
wind_curs_item	db #55		;IX+21;;;;current start cursor position of the window (0-AP_a_page)

status_byte	db #55		;IX+22= current status of ftp (TCP) connection, contains "2"-"5"
transfer_flag	db #55		;IX+23=0=transfer OK, 1=transfer aborted, 2= transfer error (used for upload& download for now), 3=incomplete (in case there is no memory for directory)
minutes		db #55		;IX+24, minutes read out from RTC chip

cur_item_addr	dw #5555	;;;;;ix+25, current address/pointer to dir item
cur_lin_prn_adr	dw #5555	;;;;;ix+27, current addres for line/item print
;ftp_path_pointr	dw #5555	;ix+28, points to current dir in the ftp dir path, asi netøeba
item_file_count	dw #5555	;ix+29, item (for NLST)/ file (for LIST) counter (IY will count files/ items)
mark_counter	dw #5555	;ix+30, counts marked files
dir_counter	dw #5555	;IX+32

;end of flags

;core		db #55,#55,#55	

RX_buf		ds #80
TX_buf		ds #80
buffers_len	equ $-RX_buf


	include "keyboard_and_print.asm"

;	IF bs_dos=1
	IFDEF bs_dos
	include "disk_operations_bsdos.asm"
	ELSE
	include "disk_operations_esxdos.asm"
	ENDIF

bios_start
		INCBIN "WifiBios20_MB_EL.cod"
/*
	IFDEF mb03
;	IF  mb03=1
	incbin	"WifiBios19_MB.cod"
	ELSE
	INCBIN	"WifiBios19_EL.cod"
	ENDIF
;	incbin	"WifiBios18.cod"
*/
bios_len	equ $-bios_start


	
;strankovaci bios
		ORG	#BFE0

; Vstup:
;   A = cislo RAM stranky 0-7
;
; Vystup:
;   zvolena stranka je namapovana do #C000-#FFFF
;
; Nastaveni #7FFD:
;   bity 0-2 = RAM page
;   bit 3    = screen 0  (RAM 5)
;   bit 4    = 48K ROM
;   bit 5    = paging enabled
;
; Pozor:
;   bit 5 musi zustat 0, jinak se strankovani zamkne
; ------------------------------------------------------------

PAGE128:
        and     %00000111
        or      %00010000
        ld      (PAGE128_STATE),a
	push	bc
        ld      bc,#7FFD
        out     (c),a
	pop	bc
        ret

PAGE128_STATE:
        db 0
;Ještì lépe bych tam nenechal jen jednu rutinu, ale rovnou celý malý BANK API blok:
PAGE128_RESTORE

;definice stranek:
;ftp directory
;last_ftp_dir_page	equ	3
ftp_dir_page	defb	0,1,3,7,#FF	;FF je zarazka
fdp_pointer	defw	ftp_dir_page+1	;zaciname prvni strankou
dwnld_pag	equ	4
;download_page	defb	dwnld_pag
program_page	equ	6		;zde budou PRINT, INPUT......




;To znamená napøíklad:
;		ld a,6
;		call PAGE128

;total_len	equ $-code_
total_len	equ $-start_ldir












