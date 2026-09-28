;disk operations- save+ load
;Esxdos
;Hood
;v1.0
;v1.1- fixed issues with existing files rename

/*
usage:
LOAD: uses these calls in the listed order:
1) file_exist...	checks, if file in "exp_name" exists on the disk, NZ= does not exist
2) load_init....	prepare given file. NC= file is smaller than buffer
3) load_file....	NC=we still have portion of file to load

In the course of loading:
rest_len........	length of file in bytes, diminished by disk_buf_len each load save. Starts with blen
portion_len.....	either whole buffer length in bytes, or last part of the file< buffer in bytes


SAVE: use these calls in listed order:
1) save_file_head	open file for saving
2) save_into_file	save file
3) save_close....	close the file
*/

;len_buf	equ buf_len		;=#8000	;for MB03+, buffer len has to be always *#400



;temporary
;vyhovuje např. db "12345678.tap",0, nebo "12345678tap",0 (oba pripady znamenaji totez), nebo "123456789ab",0, pak bude zalozen soubor "12345678.9ab"
;ale nevyhovuje	db "123456789tap",0

exp_name	ds 13


fnum		dw #5555		;file number to be saved/loaded
beg_sec		dw #5555		;beginning sector of file (vary when saving/loading)
sec_num		db #55			;number of sectors to save/load
flen_secs	dw #5555		;length of file in sectors
disk_buf_len	dw #5555		;length of save/load buffer in bytes
buf_len_secs	db #55			;length of save/load buffer in sectors
portion_len	dw #5555		;disk_buf_len, or rest of file (e.g. #8000, #8000, #03f5)
rest_len	dw #5555,#5555		;length of file in bytes, diminished by disk_buf_len each load save. Starts with blen
tmp_file_sec	dw #5555		;auxiliary. Temporary length of file in sectors. Serves for next_params routine

header
ident		db #B0			;file identification	;#80 when create, #B0 when save done
		ds 4			;time& date		;varaible
ftyp		db #55			;tape header		;variable
fname		ds 10			;file name		;variable
flen		dw #5555		;file length for tape	;variable
fsta		dw #5555
		dw #5555
		dw #5555		;body address
blen		ds 4			;body length
		db #FF			;flagbyte		;always FF when save
		db 0			;attrs			;always 0 when save
		dw 0			;1st sec		;always 0 when save header

_11byte_buffer	ds 11


Path
file_handle	defb	#55		;Esxdos file handle

;Poznámky od Lanexe 12:37 06.02.2023
;
;U fseek: vynechej první 3 instrukce (test na otevření souboru), nejsou nutné, u fread taky nejsou :)
;Po každém api volání testuj Carry na chybu, a CloseFile použij vždy, když k nějaké chybě během čtení/zápisu dojde.
;
;
; NOTE: File paths use the slash character (‘/’) as directory separator (UNIX style)
;

M_GETSETDRV  equ $89
M_TAPEOUT    equ #8c

F_OPEN       equ $9a
F_CLOSE      equ $9b
F_READ       equ $9d
F_WRITE      equ $9e
F_UNLINK     equ #aD
F_FSTAT      equ #a1
F_STAT       equ #ac

;F_SEEK       equ $9f
;F_GET_DIR    equ $a8
;F_SET_DIR    equ $a9

FA_READ      equ $01
FA_OVERWRITE equ $0C
;FA_WRITE     equ $02
;FA_APPEND    equ $06

/*od Lanexe
File access:

FA_READ equ %00000001 ; Read access
;FA_WRITE equ %00000010 ; Write access
FA_OPEN_EX equ %00000000 ; Open if exists, else error
FA_OPEN_AL equ %00001000 ; Open if exists, if not create
FA_CREATE_NEW equ %00000100 ; Create if not exists, if exists error
FA_CREATE_AL equ %00001100 ; Create if not exists, else open and truncate
FA_USE_HEADER equ %01000000 ; Use +3DOS header (passed in DE)

ld ix,path
ld b,0b00001010
ld a,"*"
rst 8
defb F_OPEN

Path defb "soubor.bin",0
(před "soubor.bin" nedávej lomítko)

GetSetDrive	c=1
fClose		c=2
file_exist	c=3
load_init	c=4
load_file	c=5

save_file_head	c=6
save_into_file	c=7
save_close	c=2
delete_file	c=1
*/





; Function:  Open file
; In:        IX = filename
;            B  = open mode
;            A  = Drive
; Out:       A  = file handle
;            On error: Carry set
;                      A = 5   File not found
;                      A = 7   Name error - not 8.3?
;                      A = 11  Drive not found
;                      

;file name numbering
;brambora.tap->bram#001.tap
save_file_head
fOpen:		ld de,(blen+2)		;find out len of file in secs
		ld hl,(blen)
		ld (rest_len),hl
		ld (rest_len+2),de
		ld	hl,1
		ld	(esx_counter+1),hl
		ld	a,l
		ld	(_2nd_run+1),a	;indikujeme, ze jde o prvni kolo

fopen_loop	ld	a,(DefaultDrive)
		ld	ix,exp_name
		ld	de,_11byte_buffer
		rst	8
		db	F_STAT
		jp	c,sfh_cont	;C=file does not exist, do not bother with numeration, and continue		
					;NC=file exist, you have to put a numeration in its name

_2nd_run	ld	a,#55			;druhe kolo?
		or	a
		jr	z,fope11		;Z=ano
	
		ld	de,0			;pocitadlo jmena D a pripony E
		ld	hl,exp_name		;nejprve delku jmena
fopen_adr	ld	a,(hl)
		cp	"."
		jr	z,fope31
		or	a
		inc	hl
		jr	z,fope2			;Z=konec pocitani
		inc	d
		jr	fopen_adr
						;Z=jdeme pocitat priponu
fope31		push	hl			;HL=tecka
fope3		inc	hl
		ld	a,(hl)
		or	a
		jr	z,fope2			;Z=mame spocitanou priponu
		inc	e
		jr	fope3
						;nyni mame v D delku jmena a v E delku pripony E=0=zadna pripona
fope2		pop	hl			;HL=tecka
		push	de			;uloz delku jmena a pripony
		inc	e
		dec	e
		jr	z,fope21		

		ld	c,e			;preneseme priponu
		inc	c			;... i s teckou
		ld	b,0
;		dec	hl
		ld	de,_11byte_buffer
		ldir
						;od _11byte_buffer mame priponu
fope21		pop	de
		ld	a,d
		ld	c,a
		cp	4
		jr	c,fope1			;C=jmeno je <4

		ld	c,4
fope1		ld	hl,exp_name
		ld	b,0
		add	hl,bc
		ld	a,(hl)			;HL=adresa, kam budeme vkladat cislo
		cp	"#"			;je uz tam predchozi cislo "#xyz"?
		jr	nz,fope4		;Z=ano
fope11		ld	bc,(esx_counter+1)
		inc	bc
		ld	(esx_counter+1),bc	;zvys o 1
		jr	fope5

fope4		ld	(hl),"#"
fope5		inc	hl
		push	de			;zalohujeme delku jmena a pripony
esx_counter	ld	de,#5555		;pocitadlo verzi souboru
		ld	a,(_2nd_run+1)
		or	a
		push	af			;uschovame priznak
		jr	z,esx_nam_adr		;Z=jedeme druhe kolo

		ld	(esx_nam_adr+1),hl

esx_nam_adr	ld	hl,#5555		;pozice poradoveho cisla ve jmene
		ex	de,hl
		call	HL2ASCII_000		;vloz "xyz"
						;ted musime vlozit priponu
		pop	af			;obnovime priznak
		pop	bc			;C=delka pripony

		jr	z,fopen_loop

		inc	c
		dec	c
		jr	z,fope_end		;Z=soubor bez pripony			

		ld	hl,_11byte_buffer	;vlozime priponu
		inc	c
		ld	b,0
		ldir

fope_end	ex	de,hl			;vloz misto ppripony 0 na ukonceni souboru
		ld	(hl),c
		ld	a,c
		ld	(_2nd_run+1),a		;indikujeme, ze jdeme do druheho kola
		jp	fopen_loop
		
		




/*old, functioning was not good
fopen_adr	ld	hl,#5555	;end of file name for search
		push	hl

		dec	hl
		dec	hl
		dec	hl
		dec	hl
		ld	a,"#"
		cp	(hl)
		jr	z,fope1

		pop	hl
		push	hl
		ld	de,exp_name
		or	a
		sbc	hl,de
		ld	a,l
		ex	af,af'
		ld	a,8
		sub	l
		ld	b,h
		cp	4		;NC=posun o 4, C= posun o vysledek
		jr	c,fope3
		ld	a,4
fope3		pop	hl		;HL=end of file name
;		push	hl		;look for complete name end
		ld	b,a
;		ex	af,af'
		ld	a,(hl)
		or	a
		jr	z,fope2_	;Z=file has no extension
fope33		ld	a,(hl)
		or	a
		jr	z,fope32
		inc	hl
		jr	fope33

fope32		dec	hl
		ld	d,h
		ld	e,l
		ld	a,b
fope35		or	a
		jr	z,fope34
		inc	de
		dec	a
		jr	fope35
fope34		ld	bc,4
		inc	de
		ld	a,b
		ld	(de),a
		dec	de		;0 at the end of file name
		lddr			;mame posunutou priponu
;;		inc	de
;;		ld	(fopen_adr+1),de

fope2_		
;		pop	hl		;NZ=numbering does not exist yet, start it
		ld	hl,exp_name
		ex	af,af'
		cp	5
		jr	c,fope22
		ld	a,4
fope22		dec	a
fope21		or	a
		jr	z,fope2
		inc	hl
;		dec	hl
		dec	a
		jr	fope21
fope2		ld	c,(hl)
		push	hl		;preserve name pos nr. 4
		push	bc
		ld	d,h
		ld	e,l
esx_counter	ld	hl,#5555
		call	HL2ASCII_00000
		ld	(fopen_adr+1),de
		pop	bc
		pop	hl
		ld	(hl),c
		inc	hl
		ld	(hl),"#"
		ld	a,(de)		;test if name has extension, if not put 0
		cp	"."
		jr	z,fopen_loop
		xor	a
		ld	(de),a
		jp	fopen_loop

fope1		pop	bc		;only to get rid off initial push
		push	hl
		inc	hl		;numbering already exist, increase number
		ex	de,hl
		call	ConvRStr16
		inc	hl		;increase number by 1
		ld	(esx_counter+1),hl
		pop	hl
		dec	hl
		jr	fope2
*/

sfh_cont        ld   a, (DefaultDrive)  ; get drive we're on
		ld b,FA_OVERWRITE
             ld   ix,exp_name        ; ix = Pointer to file name (ASCIIZ)
             rst  $08
             db   F_OPEN             ; open read mode
	ld	c,4
;	jr c,central_err	;po zprovoznění smazat
		jr	c,d_err

             ld	  (file_handle),a  
		jr	nc,esx_count_save_len

/*
;po zprovoznění smazat
central_err	ld	b,a		;B=holds esxdos error code
		ld	a,c		;border colour shows my internal error code
		out	(#FE),a
		halt
*/
; Function: Detect if unit is ready
; Out:      A = default drive (required for all file access)
;           Carry flag will be set if error.
GetSetDrive:
             xor  a               ; A=0, get the default drive
             rst  $08
             db   M_GETSETDRV             
             ld   (DefaultDrive),a
             ret nc
	ld	c,1
;	jr central_err	;po zprovoznění smazat
		jr	d_err
DefaultDrive db   0

; Function:  Write bytes to a file
; In:        A  = file handle
; Out:       Carry flag active if error when closing
save_close
fClose: 
             ld   a,(file_handle)           ; a  = file handler
             rst  $08
             db   F_CLOSE
	ret nc
;	ld	c,2
;	jr central_err	;po zprovoznění smazat

d_err		ld c,15
		ld ix,flag1
		jp error_handler	;NC=disk error, return to main program


	

/*
; Function:  Read bytes from a file
; In:        A  = file handle
;            ix = address to load into
;            bc = number of bytes to read
; Out:       Carry flag is set if read fails.
fRead:
             ld   ix, 16384          ; ix = address where to store what is read
             ld   bc, 6912           ; bc = bytes to read
             ld   a,(file_handle)      ; a  = the file handler
             rst  $08
             db   F_READ             ; read file
	jr c,d_err
             ret
*/

save_into_file
; Function:  Write bytes to a file
; In:        A  = file handle
;            ix = address to save from 
;            bc = number of bytes to write
; Out:       Carry flag is set if write fails.
fWrite:
;		halt
;		ret

sif1         ld   ix, basic_end      ; ix = memory address to save from
sif2         ld   bc,#5555           ; bc = bytes to write
             ld   a,(file_handle)    ; a  = file handler
             rst  $08
             db   F_WRITE            ; write file
;	ld	c,7
;	jr c,central_err	;po zprovoznění smazat
		jr	c,disk_error

esx_count_save_len			;count if save will be whole buffer or less (in case of last part)
		ld	hl,(disk_buf_len)
		ld	bc,(rest_len+2)
		ld	a,b
		or	c
		jr	nz,ecsl1	;NZ=save the whole buffer

		ld	bc,(rest_len)
		or	a
		sbc	hl,bc
		add	hl,bc
		jr	c,ecsl1
		ld	h,b		;save last portion (=buffer length or less)
		ld	l,c

ecsl1		ld	(sif2+1),hl
		ret



/*
; Function:  Seek into file
; In:        A    = file handle
;            L    = mode:  0 - from start of file
;                          1 - forward from current position
;                          2 - back from current position
;            BCDE = bytes to seek
; Out:       BCDE = Current file pointer. (*does not return this yet)
;            
fSeek:   
             ld   a, (file_handle)   ; file handle
             or   a                  ; is it zero?
             ret  z                  ; if so return
             ld   l,0
             ld   bc,0
             ld   de,0
             rst  $08           
             db   F_SEEK
             ret



; Function:  SetDirectory
; In:        A    = Drive
;            HL   = pointer to zero terminated path string ("path",0)
; Out:       carry set if error
;            
SetDir:
             ld   a,(DefaultDrive)   ; drive to change directory on
             ld   hl,Path            ; point to "path",0 to set
             rst  $08           
             db   F_SET_DIR  
             ret



; Function:  Get Directory
; In:        A    = Drive
;            HL   = pointer to where to STORE zero terminated path string
; Out:       carry set if error
;            
GetDir:     
             ld   a,(DefaultDrive)   ; drive to get current directory from
             ld   hl,Path            ; location to store path string in
             rst  $08           
             db   F_GET_DIR  
             ret


;correct delete file: first file have to be closed, then deleted.

F_UNLINK: Delete a file

A=drive
IX=pointer to asciiz file/path



ld a,"*"
Ld IX,Jmeno
rst 8
defb F_UNLINK
;(v carry je výsledek (true=chyba))

Jmeno defb "brambor.bin",0
*/

delete_file	call fClose
		ld a,(DefaultDrive)
		ld ix,exp_name
		rst 8
		db F_UNLINK
;	ld	c,1
;	jr c,central_err	;po zprovoznění smazat
		jr c,d_err
		ret

disk_error	call	fClose			;carry=error
		jr	d_err


sfh		ld hl,#5555

file_exist	ld   a, (DefaultDrive)  ; get drive we're on
		ld b,FA_READ
             ld   ix,exp_name        ; ix = Pointer to file name (ASCIIZ)
             rst  $08
             db   F_OPEN             ; open read mode
             ld	  (file_handle),a
;	ld	c,3  
;	jr c,central_err	;po zprovoznění smazat
		jr nc,fe_ok          ; Returns a file handler in 'A' register.
		cp	5		;5= File not Found
		jr	nz,disk_error
fe_nok		inc a
		ret			;ret with NZ
fe_ok		xor a
		ret			;ret with Z

load_init	ld a,(file_handle)
		ld ix,_11byte_buffer
		rst #8
		db F_FSTAT

;	ld	c,4
;	jp c,central_err	;po zprovoznění smazat
		jr c,disk_error

		ld hl,_11byte_buffer+7
		ld de,rest_len
		ld bc,4
		ldir

li2		ld	bc,(rest_len+2)
		ld	hl,(disk_buf_len)
		ld	a,b
		or	c	;or c= always NC, if higher 16 bit=non zero, jump with NC to li1
		jr	nz,li1	;NZ=save the whole buffer

		ld	b,h
		ld	c,l
		ld	hl,(rest_len)
		or	a
		sbc	hl,bc
		add	hl,bc		;if Z, set C as well
		jr	z,li3
		jr	c,li1
		ld	h,b		;save last portion (=buffer length or less)
		ld	l,c

li1		ld	(lf2+1),hl
li4		ld	(portion_len),hl
		ret			;C=last part, NC= continuus part
li3		ccf
		jr	li1






fRead
load_file	ld a,(file_handle)
		ld ix,basic_end			;address where to load
lf2		ld bc,#5555			;length
		ld (lf3+1),bc
		rst 8
		db F_READ
;	ld	c,5
;	jp c,central_err	;po zprovoznění smazat
		jp c,disk_error

lf1		ld	hl,(rest_len)	;substract disk_buf_len from rest_file first
		ld	de,(rest_len+2)	;rest_len can be then used eg. for display copy progress
		ld	bc,(disk_buf_len)
		call	bsdos
		ld	(rest_len+2),de
		ld	(rest_len),hl
		call	li2
lf3		ld	hl,#5555
		jr	li4

;		call li2		;find out, if next portion< buffer
;		ret c			;C=last part, no more substraction


tapeout_open	ld hl,zxftpcl
		ld de,tapeout_name
;		ld bc,7
		ld bc,8
		ldir
		ld b,3
		jr tapeout
tapeout_close	ld b,1
tapeout		ld a,(DefaultDrive)
		ld ix,tapeout_name
		rst 8
		db M_TAPEOUT
		jp	c,disk_error
		ret
;tapeout_name	ds 7
tapeout_name	ds 8
		db ".tap",0	

sub32		equ #B
howsec		equ #F
getcst		equ #12
getsub		equ #16
seasx		equ #19
owsub		equ #1B
loa1x		equ #22
savex		equ #25
creatx		equ #26
erasex		equ #28

bsdos		xor	a		;6 bajtů
		sbc	hl,bc
		ret	nc
		dec	de
		ret
;	ENDIF

end
len=end-start_address
