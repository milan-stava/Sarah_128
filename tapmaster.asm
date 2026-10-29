
;TAPmaster 4.1- no limit in file length, added XOR checksum+ block check control

		DEFINE xorchecksum		;ON/OFF
		DEFINE block_len_check		;ON/OFF

;TM4.0
;#4000-cca#4817		main progam
;#4900			SP (has 64 bytes- that is enough)
;#4900-#5000		(right after SP) file list (#700 in length, middle part of screen roughly, holds max 894 TAPs)
;#5000-#5800		free for texts durind TAP extraction
;#6000-#FFFF		load/save buffer (one sector under must be reserve),buffer does not go under #5C00. Buffer length= #A000= 40960


;HEAD32     EQU #4800		;start of 32 byte header,HEAD32 nahrazeno v TM40 navestim seq_buff
;SPCKO      EQU #4800		;(SP) stack pointer
;SPCKO      EQU #4D00		;(SP) stack pointer
;SPCKO      EQU HEAD32		;(SP) stack pointer
;SPCKO	    EQU #4900

SPCKO		equ #4900
;SPCKO		equ tte+64	;nelze pouzit, hlidame zacatek souboru
;DATA_START EQU #5B00		;start of data buffer, max block length= 42240 bytes (#5B00-#FFFF)
;HEAD32     EQU #4300		;start of 32 byte header
;memory     equ HEAD32+#400	;list of files from #4C00 (max 624 files)
;memory		equ SPCKO+#400
memory		equ SPCKO	;start of file list	
memory_down	equ high memory-1



;        ORG #4000		
 ;TAPmaster disassembling by Hood 2017-2018


START   DI
        LD   SP,SPCKO

        ld      a,(flag2)       ; capture Sarah setting before IX is reused
        and     %00100000      ; bit 5: 0=keep original TAP, 1=delete
        ld      (del_tap+1),a

        xor     a
        call    PAGE128         ; code is at #4000; unmap bank 6 only now

	call	set_20mhz	;set 20 MHz
/*
        LD   HL,(#5CB4)
,  	;23732, P RAMT, address of the last byte of physical RAM
        PUSH HL
        LD   HL,(#5C38)		;23608, RASP (1), length of warning buzz
        PUSH HL
        LD   HL,(#5C7B)		;23675, UDG (2), address of 1st user defined graphic
        PUSH HL
*/
        CALL #3C9E


        LD   HL,SPCKO
        LD   DE,SPCKO+1
        LD   BC,#1300
        LD   (HL),L
        LDIR 			;clear screen

	ld	(first_free),bc	;indikuj 0 jako prvni zalozeny soubor

	ld	hl,22528+(12*32)
	ld	de,22529+(12*32)
	ld	bc,15
	ld	(hl),7
	ldir
	

;        LD   A,#46
;        LD   (#3E2),A		;COLOR for screen print

/*
        LD   HL,#900
        LD   (#3E0),HL		;XXX,YYY- print column and line

        XOR  A
        OUT  (#FE),A

        LD   E,A
        LD   A,#C
        RST  #20		;display mode= 0

        LD   HL,INFO_T
        LD   A,#4
        RST  #20		;print text "TAPmaster 2.0..."
*/
		ld	de,INFO_T
		ld	hl,#4C00
		call	PRINTHL

;zrusime, a jako prvni soubor se bude detekovat az pri sejvu...
/*
	ld	a,#18		;now find out first file number of the freshly extracted TAP
	rst	#20
	ld	b,d
	ld	c,e

fo_loop		push	bc
;		ld	ix,HEAD32
		ld	ix,seq_buff
		push	ix
		ld	a,#16
		rst	#20
		pop	hl
		ld	a,(hl)
		and	%11000000
		cp	#80
		pop	bc
		dec	bc
		jr	nz,fo_loop
;		pop	bc
;		jr	z,fo_found
;		dec	bc
;		jr	fo_loop

fo_found	inc	bc		;BC=first free file slot
		ld	(first_free),bc	;now you may continue
*/

;        LD   A,#12
;        RST  #20		;find out load cursor position
				;not needed
	ld	hl,(fnum)
		ld	(input_file),hl

;here comes TM4.1 itself
		ld	bc,(input_file)		;find out TAP length
		ld	a,GETSUB
		ld	ix,seq_buff
		call	bsdos_tm

		ld	hl,(seq_buff+#18)
		ld	(taplen_low),hl
		ld	de,(seq_buff+#1A)
		ld	(taplen_high),de

	IFDEF block_len_check
		ld	a,#FC			;Busy's genial routine
		and	l
		or	h
		or	e
		or	d
		jr	nz,t_cont

t_end		ld	hl,bl_shor
		ld	a,#34
		call	bsdos_tm		;too short, skip this TAP
		rst	0
	ENDIF		
			
t_cont		ld	hl,0
		ld	(tappointer_high),hl
		ld	(tappointer_low),hl

tap_main_loop	ld	hl,0
		ld	(output_file),hl
		xor	a
		ld	(header_tm),a

tml2		ld	hl,(taplen_high)	;test, if TAP file was already finished
		ld	de,(tappointer_high)
		or	a
		sbc	hl,de
		jr	nz,tml1
		ld	hl,(taplen_low)
		ld	de,(tappointer_low)
		or	a
		sbc	hl,de
		jr	nz,tml1
		ld	a,(header_tm)
		or	a
;		ret	z
;		jr	z,tml3

		call	nz,save_header_only	;there is opened header, save it now (only in cases last file of TAP is head only file)

tml3		call	#3C9E
		jp	del_tap

;		ld	a,1
end_tm		out	(#FE),a
;		ei
;		ret

;error1		ld	a,2
;		jr	end_tm

tml1		ld	hl,3			;we start with 3 byte block, eg. 13,00,00
		call	load_block_no_save_len_in_HL		

		ld	hl,(seq_buff)		;test if block is header (flagbyte=0) or data (flagbyte=#FF)

	IFDEF block_len_check
		ld	a,#FD
		and	l
		or	h
		jr	z,t_end			;block<3, skip this TAP		
	ENDIF

		dec	hl
		dec	hl			;lower block length by 2 (flagbyte+ CRC check byte)
		ld	(one_block_len),hl

		ld	a,(seq_buff+2)

	IFDEF xorchecksum
		ld	(xor_start+1),a		;starting byte for xor checksum of a block
	ENDIF
		ld	e,a			;E=block ID byte

		or	a
		ld	bc,17
		sbc	hl,bc			;is block length 17?
		add	hl,bc			;HL=block len in TAP
		ld	a,e			;A=block ID byte
		jr	nz,headerless

yes_17		or	a			;is 17 byte block a header?
		jr	z,it_is_header




headerless;	push	hl
;		call	setdestination
;		pop	hl

		ld	a,(header_tm)
		or	a			;je uz soubor pripraven k zalozeni?
		jr	z,create_and_save_headerless	;Z=neni, zaloz bezhlavickovy

		ld	a,#B0
		ld	(header_tm),a
		ld	hl,(one_block_len)
		ld	(blen_tm),hl
		ld	hl,0
		ld	(blen_tm+2),hl
		ld	(beg_sec_tm),hl

		call	save_general

;load and save into opened file		
lasiof		call	load_block_and_save_no_len
		ret	c			;C=error
	IFNDEF xorchecksum
		ld	bc,1			;skip CRC byte at the end of the block
		call	ad32
	ENDIF

	IFDEF xorchecksum
		call	evaluate_crc		;load parity byte (last byte of the block) and compare with counted checksum
	ENDIF
		jp	tap_main_loop


create_and_save_headerless
		ld	(blen_tm),hl
		ld	hl,0
		ld	(blen_tm+2),hl
		ld	(beg_sec_tm),hl
		ld	a,#A0
		ld	(header_tm),a
		ld	a,4
		ld	(ftyp_tm),a
		ld	hl,noname
		ld	de,fname_tm
		ld	bc,10
		ldir
		ld	a,(seq_buff+2)
		ld	(flag),a
cash1		call	save_general
		jr	lasiof



it_is_header	ld	a,(header_tm)			;je soubor již založen? pak by šlo o hlavičku bez těla. Indikace založení=0 =nezaložen.
		or	a				;pokud je ID byte #B0, znamená to, že předchozí blok v TAPce byl jen hlavička (nestává se často) a musíme
;		jr	z,iih1				;jej uložit s předchozími parametry. A následně vyplnit a předzaložit hlavičku novou
							;Z=založ hlavičku a ulož ji
							;NZ=nejprve sejvni tu starou a pak až novou, jde jen o hlavičku bez těla

		call	nz,save_header_only		;#90= jen hlavicka, save it now

iih1		call	load_block_no_save_no_len	;load the 19 byte block
							;19 byte header block loaded at seq_buff (#C000), now parse it and create a header
;		call	setdestination

		ld	a,#B0			;#B0=head+body
		ld	(header_tm),a
		ld	a,#FF			;navtrdo hlavicka #FF
		ld	(flag),a
		ld	hl,seq_buff
		ld	de,ftyp_tm
		ld	bc,17
		ldir
		ld	hl,(seq_buff+11)
		ld	(blen_tm),hl
		ld	hl,0
		ld	(blen_tm+2),hl
		ld	(beg_sec_tm),hl
;		ld	ix,header
;		ld	a,CREATX
;		call	bsdos_tm
;		jp	nc,ERR_ANY
;		ld	(output_file),hl
	IFDEF xorchecksum
		call	evaluate_crc	
	ENDIF

	IFNDEF xorchecksum
		ld	bc,1
		call	ad32
	ENDIF
		jp	tml2

ERR_ANY		ld	hl,err_disk
		jp	t_end+3

save_header_only
;		call	setdestination
		ld	a,#90				;#90=jen hlavicka
		ld	(header_tm),a
		jr	cash1
;		jr	save_general

;;		ld	a,CREATX
;;		ld	ix,header_tm
;;		call	bsdos_tm
;;		jr	nc,ERR_ANY
;;		ld	(output_file),hl
;;		ret
;		jp	setsour


	IFDEF xorchecksum
evaluate_crc	ld	hl,xor_yes_no		;check if crc byte matches physical check
		ld	(hl),0
		push	hl
		ld	hl,1			;read the last byte of a block (CRC byte)
		call	load_block_no_save_len_in_HL
		pop	hl
		ld	(hl),1

		ld	a,(xor_yes_no)
		or	a
		ret	z
;		jp	z,tap_main_loop

		ld	hl,seq_buff
		ld	a,(xor_start+1)
		cp	(hl)
		ret	z
;		jp	z,tap_main_loop		;Z=xor checksum ok

		ld	hl,xor_err
		ld	a,#34
		call	bsdos_tm
        rst     0               ; invalid TAP: do not delete source or run output
;		call	bsdos_tm		;show message and continue
;		rst	0
	ENDIF

save_general	ld	a,CREATX
		ld	ix,header_tm
		call	bsdos_tm
		jr	nc,ERR_ANY
		ld	bc,(first_free)
		ld	a,b
		or	c
		jr	nz,sg1
		ld	(first_free),hl		;save first file of TAP for future, yuo start run programm with this one

sg1		ld	(output_file),hl
		ret


;IN=value to add/substract in BC
;;sub32_tm	ld	a,SUB32			;add or substract
;;		jr	count32
ad32		ld	a,ADD32
count32		ld	de,(tappointer_high)
;;		ld	de,(filepointer_high)
		ld	hl,(tappointer_low)
;;		ld	hl,(filepointer_low)
		call	bsdos_tm
		ld	(tappointer_high),de
;;		ld	(filepointer_high),hl
		ld	(tappointer_low),hl
;;		ld	(filepointer_low),hl
		ret
	


tappointer_high	dw	#5555			;position pointers inside TAP
tappointer_low	dw	#5555
one_block_len	dw	#5555			;length by which we move inside TAP
taplen_high	dw	#5555
taplen_low	dw	#5555			;length of TAP file being worked with


load_block_no_save_len_in_HL
		ld	(one_block_len),hl	;HL=length of block to load/save
load_block_no_save_no_len
		xor	a			;indicate, there will be no save after block load
		jr	lbas1
load_block_and_save_len_in_HL
		ld	(one_block_len),hl	;HL=length of block to load/save
load_block_and_save_no_len
		ld	a,%00000100		;indicate there will be save after block load
lbas1		ld	(flag1_tm),a	
;main routine, inputs BCDE= filepointer, HL= length to load& save
;		ld	hl,0
;		ld	(output_file),hl

;		ld	hl,flag1		;these 3 lines not needed for TAPmaster, obvious, we want also save
;;;		set	1,(ix+0)		;we do load (to choose bsdos service, either load, or save_not used in TAPmaster)
;		set	2,(hl)			;do save after load

;		ld	de,10000		;DE=file ponter low
		ld	de,(tappointer_low)
;;		ld	(filepointer_low),de
;;		ld	hl,(filelen_low)
		ld	hl,(taplen_low)
		or	a
		sbc	hl,de
;		ld	bc,#1			;BC=file pointer high
		ld	bc,(tappointer_high)
;;		ld	(filepointer_high),bc
;;		ld	hl,(filelen_high)
		ld	hl,(taplen_high)
		sbc	hl,bc
		jr	c,error			;filepointer> total file length

;		ld	de,60000		;DE=data len
		ld	de,(one_block_len)
;;		ld	(blen_tm),de		;blen=4 byte length entry in 32 byte header
;;		ld	(flen_tm),de		;flen=2 byte length entry in 32 byte header

		call	seq_block		;nahraj block s parametry BC, DE, HL
		jr	c,error			;error or finished

allok		ret

error		ld	a,2
		out	(#FE),a
		rst	0			;muze byt rst 0. Pokud se neco nepovedlo, OSL uz muze byt davno prepsany
;		jr	allok



;loop that loads& saves bufer after buffer
;zjistuje, zda je zbytek> nez buffer, pokud ano, nahraj cely buffer, pokud ne, nahraj zbytek
seq_block	ld	hl,seq_buf_len
		or	a
		sbc	hl,de
		jr	nc,seq_block_last	;load last chunk, len=DE
;;		jr	z,seq_block_last

		add	hl,de	
		ex	de,hl
		or	a
		sbc	hl,de
		push	hl			;rest_len-seq_buf_len
		call	sequence_read_write
		pop	de
		ret	c			;C=error in chunk length
		jr	seq_block

;samotny sekvenci cteni/zapis, jeden zapis
;IN: DE=length of data, IX=address to load/ write. OUT: NC=all ok, C=error=number of bytes>seq_buff
seq_block_last					;continue to last load/save chunk
sequence_read_write
		ld	(number_of_bytes_save+1),de	;DE=block len to load
		or a				;check for errors first
		ld	hl,seq_buf_len
		sbc	hl,de
		ret	c			;C= bytes to work with are > seq_buff

					;now count start address
					;p°. BCDE= 70000, pokud je spodnÝch 10 bit¨ nenulovych, pak nahraj pod buffer,
					;tzn udýlej ld a,d: and %00000011: ld d,a a v de mas o kolik soupnout

		push	de		;DE=number_of_bytes
;;		ld	de,(filepointer_low)
		ld	de,(tappointer_low)
		push	de
		ld	a,d
		and	%00000011	;Z=delka zacina na same adresa, jako zacatek bufferu, NZ=delka zacne pod bufferem
		ld	d,a
		pop	bc		;DE=pridat k delce
		pop	hl
		push	hl		;HL=stara delka, ta co opravdu chceme
		add	hl,de
		ld	(number_of_bytes),hl	;HL=nova delka, zvetsena o 1. sektor pred bufferem
		push	bc		;BC=filepointer_low

		or	a
		ld	hl,seq_buff
		sbc	hl,de

					;vypocet pocatecniho sektoru; cislo rotuj o 10 pozic doprava
		pop	de
;;		ld	bc,(filepointer_high)
		ld	bc,(tappointer_high)
		push	bc		;BCDE
		push	de
		push	hl		;HL=startovaci adresa v pameti ZX
		srl 	c
		rr	d
		srl	c
		rr	d		;D=hotovo
		ld	a,c
		and	%00001111
		ld	b,a		;C=hotovo
		ld	c,d		;BC=pocatecni sektor
		push	bc		;BC=pocatecni sektor


		ld	a,HOWSEC
		ld	de,0
		ld	hl,(number_of_bytes)
		call	bsdos_tm 
					;tady mam BC= pocet sektoru
		ld	e,c
		ld	a,e
		ld	(sec_num_tm),a	;for saving purposes

		pop	bc		;BC=pocatecni sektor
		ld	hl,(input_file)
		ld	a,LOAX1
;;;		bit	1,(ix+0)	;tyto 3 radky netreba pri TAPmasterovi
;;;		jr	nz,srw1
;;;		ld	a,SAVEX
srw1		pop	ix		;IX=startovaci adresa (seq_buff nebo mensi) v pameti ZX
;		ld	(start_adr),ix
		call	bsdos_tm		;mame nahrano (load/save)

					;nyni stanov pristi file pointer

		pop	bc		;HL
		pop	de		;BCDE
		pop	hl	
		ld	a,ADD32
		call	bsdos_tm

;;		ld	(filepointer_high),de
		ld	(tappointer_high),de
;;		ld	(filepointer_low),hl
		ld	(tappointer_low),hl

	IFDEF xorchecksum
		ld	a,(xor_yes_no)		;carry out xor checksum,0=no, 1=yes
		or	a
		jr	z,srw3

xor_start	ld	a,#55			;starting byte of block to check xor
		ld	bc,(number_of_bytes_save+1)
		ld	hl,seq_buff
xor_ch1		xor	(hl)
		cpi
		jp	pe,xor_ch1
		ld	(xor_start+1),a		;ulož mezi výsledek
	ENDIF		

srw3		ld	hl,flag1_tm
		bit	2,(hl)
;		jr	z,srw2			;Z=do not save

		call	nz,do_save_after_load	;save 1x buffer or less

srw2		and	a			;set NC to signal all ok
		ret	


do_save_after_load
/*not needed, header already created by prevous routines
		ld	hl,(output_file)
		ld	a,h
		or	l
		jr	nz,dsal1		;Z=start new file

		ld	hl,test_name
		ld	de,fname_tm
		ld	bc,10
		ldir

		ld	a,3
		ld	(ftyp_tm),a

;		push	ix
		ld	ix,header_tm
		ld	a,CREATX
		call	bsdos_tm
		ld	(output_file),hl
;		pop	ix
		ld	hl,0
		ld	(beg_sec_tm),hl		;nuluj pocatecni sektor pri inicializaci
*/
		
dsal1		ld	a,HOWSEC
		ld	de,0
number_of_bytes_save
		ld	hl,#5555		;real data size to save
;		ld	hl,(blen_tm)
		call	bsdos_tm
;;		ld	a,(sec_num_tm)
		ld	e,c
		push	de			;E=pocet sektoru

		ld	hl,(output_file)
		ld	bc,(beg_sec_tm)
		push	bc			;BC=pocatecni sektor
;		push	ix
		ld	ix,seq_buff
;		ld	ix,(start_adr)
;		ld	a,(sec_num_tm)
;		push	af
;		ld	e,a
		ld	a,SAVEX
		call	bsdos_tm
;		pop	bc			;sec_num, number of sectors to save
;		pop	ix

		pop	hl			;starting sector
		pop	bc			;C=pocet sektoru
		ld	b,0
		add	hl,bc
		ld	(beg_sec_tm),hl		;next position of starting sector
		ret	


bsdos_tm	call	#3C9E
		rst	#20
		jp	#3C98



seq_buff	equ	#C400			;one sector reserved before the buffer
seq_buf_len	equ	#3800			;one sector reserved after it for rounded reads
;seq_buf_len	equ	#4000			;length of disk buffer
number_of_bytes	dw	#5555			;length of data block to read/write in one go (used in sequence_read_write)
;rest_len	dw	#5555			;netreba;variable counting (max length of data #FFFF), diminshong to 0
HOWSEC		equ	#0F
LOAX1		equ	#22
ADD32		equ	#0A			;out:DEHL+BC
SUB32		equ	#0B			;out:DEHL-BC
SAVEX		equ	#25
CREATX		equ	#26
GETSUB		equ	#16

;variables concerning sequantial read/ write+ counting routines, need to be filled!!!!
;filepointer_high	dw #5555	;BC	BCDE=novy filepointer po loadu a ukonceni sekvencniho cteni/zapisu
;filepointer_low		dw #5555	;DE
;data_len	dw	#5555		;HL	;i toto v postatý netreba; length of data block to read/write (total length of chunk I wanna load/save)
;filelen_high	dw	#5555		;total length of file
;filelen_low	dw	#1		

input_file	dw	17			;input file (in case of TAP, same number)
output_file	dw	#5555			;output file, changes
noname		db	"..noname.."

;for save routine-variable
sec_num_tm	db #55			;number of sectors to save/load
beg_sec_tm	dw #5555		;beginning sector of file (vary when saving/loading)
;start_adr	dw #5555		;starting address, netreba, mame seq_buff

;test_name	db "testname  "

header_tm
ident_tm	db #B0			;file identification	;#80 when create, #B0 when save done
		ds 4			;time& date		;varaible
ftyp_tm		db #55			;tape header		;variable
fname_tm	ds 10			;file name		;variable
flen_tm		dw #5555		;file length for tape	;variable
fsta_tm		dw #5555
		dw #5555
		dw #5555		;#16-#17 body address
blen_tm		ds 4			;#18-#1B body length
flag		db #FF			;flagbyte		;always FF when save
		db 0			;attrs			;always 0 when save
		dw 0			;1st sec		;always 0 when save header

xor_yes_no	db 1		;1=yes, 0=no
flag1_tm	db 8		;see start of the code, 2=SSL connection,0=TCP
;end of flags




del_tap		ld	a,0		;patched at START: 0=keep TAP, #20=delete
		or	a
		jr	z,dt1

;		ld	bc,(LOA_KUR)	;delete original TAP
		ld	bc,(input_file)
		ld	a,#28
		rst	#20

dt1		ld	bc,(first_free)
		push	bc
		ld	ix,seq_buff
;		ld	ix,HEAD32
		push	ix
		ld	a,#16
		rst	#20
		pop	hl
		ld	a,(hl)
		and	%11000000
		cp	#80
		jp	nz,ERR_ANY
;		jr	z,run1
;		halt			;file not valid, TOTO VYŘEŠIT!!

;run1		ld	a,(HEAD32+5)
;		or	a
;		ld	a,239		;"LOAD"
;		jr	z,run2
;
;run2		ld	a,230		;"NEW"
;		ld	(SLAVE),a

run1;		pop	hl		;HL=file number
;		ld	(SLAVE),hl	;uloz cislo pro BASIC
;		call	ROZLOZ
;		ld	hl,NNNAME
;		ld	de,BZ4
;		ld	bc,5
;		ldir

		call	#3c98		;page in ZX ROM

		ld	hl,odkud
		ld	de,#5B00
		push	de
		ld	bc,move_len1+move_len2
		ldir
		ret			;JP to loader

odkud
; Program pre INICIALIZACIU BASIC a LOAD *"LNAME"
; Tento PGM je prelozeny na ADR #5B00 !!!!
; Cely sa presuva na ADR #5B00
; autor: Busy
;
      ;;org  #5b00
        ENT                     ; close #4000 relocation before the loader
	DISP	#5B00
;
stpb	pop	hl
	ld	(SLAVE),hl
	di
	im	1
	ld	hl,1200h 
	ld	de,rstpe
	ld	bc,128bh-1200h 
	ldir
	ex	de,hl
	ld	a,0c3h 
	ld	(hl),a
	inc	hl
	ld	(hl),low nret
	inc	hl
	ld	(hl),high nret         	;Nastavenie navratu z INIT

	ld	hl,adr1230h		;tady musime preplacnout z adresy #1230 puvodni 4 bajty z ROM, patch 64zn/radek tam ma neco jineho
;	ld	de,#5B9E
	ld	de,#5B9A
	ld	bc,4
	ldir

	ld	hl,5c00h            	;Od 5c00h sa bude mazat!
zmaz	ld	(hl),b              	;mazanie (B=0)
	inc	hl
	xor	a
	xor	h                   	;je UZ ROM?
	jr	nz,zmaz
	dec	hl
	jp	rstpe               	;pramt -> Skok do vytvoreneho PGM
;
; Tu je navrat z vytvoreneho PGM
;
nret	ld	hl,12cfh            	;corrin
	push	hl
;;	ld	hl,0d6bh            	;cls
;;	push	hl
	ld	de,(5c59h)          	;eline
	ld	hl,comm
	ld	bc,tapmlen                  ;dlzka prikaz riadku
	ldir
	ex	de,hl
	call	16b3h 
	ld	(iy+31h),02h 
	ld	(iy+01h),10         	;= set 1,.. (TL..) + set 3,.. !!!

		xor	a				;set back 3,5MHz
		ld	bc,#783B
		ld	l,#30
		out	(c),l
		inc	b
		out	(c),a
;		ret			;nový core by tuto chybu měl řešit (ret nereagoval při 20MHz)


;;	ld hl,#5B00		;mazani bufferu, ale nemuzeme, premazeme sami sebe, vyhodime to pryc
;;	xor a
;;zmaz1	ld (hl),a
;;	inc l
;;	jr nz,zmaz1
;;	ret				;skok do ROM- hra se spusti			
	jp	#0d6b			;CLS a z nej RET skoci na 12cfh... start
;	jp	0edfh               	;zmazanie buffera, end of tapmaster, run program- nelze v BSROM pouzit, ma zde jiny kod
move_len1	equ	$-stpb
;		ENT

comm
;		DEFB 253,192,34,97,34,45,176,34,49,34		;CLEAR USR "a"- VAL "1" (not to loose first UDG char)
;		DEFB 58				;:
		DEFB 230,"0",#E,0,0		;NEW,0,#E
SLAVE		defw #5555			;16bit hodnota
		defb 0				
;SLAVE    	DEFB 230,176,34			;NEW (230 #E6))/LOAD (239, #EF)  VAL "xy"
;BZ4      	DB "     ",34
adr1230h	db #FD,#21,#3A,#5C		
move_len2	equ $-comm

;	db	0efh,'*"'            	;load*"
;lname	db	'1234567890'        	;meno
;	db	'"'                 	;"
tapmlen equ $-comm
rstpe
        ASSERT rstpe+(#128B-#1200)+3 <= #5C00
		ENT
        DISP #4000+($-tapmaster_start) ; resume TAPmaster runtime addresses



;DONE    DB "Done"
;        DB 0,#C9



;INFO_T  DB ".TAPmaster 2.0.1",0		;missing #C9 here???
INFO_T  DB "Extracting TAP..",0

	IFDEF block_len_check
bl_shor DB "Too short,skipped",0,#C9
	ENDIF
err_disk	DB "Disk error",0,#C9

	IFDEF xorchecksum
xor_err	DB "Checksum error",0,#C9
	ENDIF

first_free	db	#55,#55		;this is file we will run after TAP is extracted

/*
LOA_KUR    DB #55,#55

ZACIAT_SEC DB #55,#55

DATA12     DB #55,#55

DATA13     DB #55,#55
POCET_SEC  DB #55,#55

DATA9      DB #55,#55

DATA10     DB #55,#55

DATA11     DB #55,#55

SAVE_LEN   DB #55,#55

SAVE_FLAG  DB #55


HEAD32		DS 32
	
TOT_LEN=$-START
*/

  
