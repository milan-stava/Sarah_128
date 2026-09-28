;disk operations- save+ load
;wifi stahovatko, MB03
;Hood
;v1.0

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
exp_name	ds 10

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



delete_file	ld bc,(fnum)
		ld a,erasex
		call bsdos
		jr nc,disk_error
		ret

;first create file, then initialise variables to save into it
save_file_head	call get_flen_in_scs
		ld a,3
		ld (ftyp),a		;can be also 0 for BASIC, 3 for CODE, 4 for ARRAY, etc.
sfh		ld hl,#5555
		ld (fsta),hl		;file start for CODE, will vary

		ld a,#80		;fil with no head, no body
		ld (ident),a
		ld hl,exp_name
		ld de,fname
		ld bc,10
		ldir
		ld ix,header
		ld a,creatx
		call bsdos
		jr nc,disk_error
		ld (fnum),hl		;file with number in HL created
		
		ld hl,0			;prepare beg_sec and sec_num for save/load
		ld (beg_sec),hl
		ld hl,next_params1
		ld (sf1+1),hl		;next params without rest len deducting
		jp count_sec_num			

;save until file completed, called several times
save_into_file
		ld hl,(fnum)		;save part of file
;		ld ix,RX_buf
sif1		ld ix,basic_end		;ver0.22s
		ld bc,(beg_sec)
		ld a,(sec_num)
		ld e,a
		ld a,savex
		call bsdos
		jr nc,disk_error
sf1		jp next_params		;prepare parameters for next save


;file done,change file ident from #55 to #B0 to become visible
save_close	ld bc,(fnum)
		ld ix,header
		push ix
		push bc
		ld a,getsub
		call bsdos
		jr nc,disk_error
		pop hl
		pop ix
		ld a,#B0		
		ld (ident),a
		ld a,owsub
		call bsdos
		ld a,0			;for return to key_loop
		ret c
		
disk_error	ld c,15
d_err		ld ix,flag1
		jp error_handler	;NC=disk error, return to main program



file_exist	ld hl,exp_name		;find out if file exist in HL
		ld e,#FF
		ld a,seasx
		call bsdos
		ret nz
		ld a,getcst
		call bsdos
		ld (fnum),hl
		xor a			;Z
		ret

load_init	ld bc,(fnum)	;find out, if the file exist
		ld (fnum),bc
		ld a,getsub
		ld ix,header
		call bsdos
		ld bc,25
		jr z,d_err		;file not found
		call get_flen_in_scs
		call count_sec_num	;initialise parameters before loading
		ld hl,0
		ld (beg_sec),hl
		ld hl,next_params
		ld (lf1+1),hl
		ret

load_file	ld hl,(fnum)
		ld ix,ftp_dir_start
		ld bc,(beg_sec)
		ld a,(sec_num)
		ld e,a
		ld a,loa1x
		call bsdos
		jr nc,disk_error
lf1		jp next_params		;or, jp last_portion can be here
;		jr next_params		;prepare parameters for next load




;auxiliary routines

get_flen_in_scs	ld de,(blen+2)		;find out len of file in secs
		ld hl,(blen)
		ld (flen),hl
		ld (portion_len),hl	;in case file<buffer
		ld (rest_len),hl
		ld (rest_len+2),de
		ld a,howsec
		call bsdos
		ld (flen_secs),bc
		ld (tmp_file_sec),bc
		ret

count_sec_num	ld a,(disk_buf_len+1)	;gives number of sectors to sec_num, either E=len_buf, or flen_secs (if flen_secs< len_buf)
		srl a
		srl a
		ld (buf_len_secs),a
		ld l,a
		ld h,0			;HL=len of buffer in sectors
		ld de,(flen_secs)
		or a
		sbc hl,de
		jr c,csn1		;C= file length is bigger than buffer
		ld a,e
csn1		ld (sec_num),a
		ret			;NC=...is lower than buffer

;old, working ok
/*
next_params	ld d,0			;set parameters for next save/load
		ld a,(buf_len_secs)	;A=length of save/load buffer
		ld e,a
		ld hl,(beg_sec)
		add hl,de		;HL+E	
		ld (beg_sec),hl		;next position of beg_sec
		ld de,(flen_secs)	;DE=length of file in sectors
		ex de,hl
		or a
		sbc hl,de
		inc h
		dec h
		scf			;set carry to signal next save/load is possible
		jr nz,nx_end		;NZ=still file to save/load
		cp l
		jr c,nx_end		;C= still we can save/load	
					;NC= will be the last save/load
		ld a,l			
nx_end		ld (sec_num),a		;last set of sec_num
		ret
*/

;zkusime vylepsit
next_params	ld	hl,(rest_len)	;substract disk_buf_len from rest_file first
		ld	de,(rest_len+2)	;rest_len can be then used eg. for display copy progress
		ld	bc,(disk_buf_len)
		ld	a,sub32
		call	bsdos
		ld	(rest_len+2),de
		ld	(rest_len),hl

next_params1	ld	hl,(beg_sec)
		ld	a,(buf_len_secs)
		ld	d,0
		ld	e,a
		add	hl,de
		ld	(beg_sec),hl	;inccrease starting sector by buffer length

		ld	hl,(tmp_file_sec)
		or	a
		sbc	hl,de		;substract buffer length from temp file length
		ld	(tmp_file_sec),hl
		ld	a,h
		or	a
		jr	nz,np_next	;NZ=NC= still portion to load/save
		ld	a,l
		cp	e
		jr	nc,np_next	
		ld	e,l
np_next		ld	a,e
		ld	(sec_num),a
		ld	b,a

		push	af
		ld	hl,(flen_secs)	;if file is < buffer, we have to deal it
		ld	a,h
		or	a
		jr	nz,npn1		;NZ=file> buffer
		ld	a,(buf_len_secs)
		cp	l		;L=length of file in secs
		ld	hl,(blen)
		jr	nc,npn2
npn1		ld	hl,(disk_buf_len);here we continue. Count rest of length, if needed
npn2		ld	(portion_len),hl
		pop	af
		ret	nc		;NC-we still have a portion to load/save, it is full buffer, return
		ld 	hl,last_portion	;if last part to load, modify the jump after load last part
		ld 	(lf1+1),hl
		ret


last_portion	ld	hl,blen		;ziskej delku posledni casti v bajtech na zaklade poctu poslednich sektoru.
					;Pokud je spodnich 10 bitu delky souboru 0, pak je posledni sektor cely obsazeny.
					;Pak staci pocet sektoru rotovat o 10 bitu vlevo a mam vyslednou delku.
					;Jinak rotuj o 10 bitu vlevo pocet sektoru zmenseny o 1 a pripocti k tomu 10 bitu celkove 						;delky souboru
		ld	a,(sec_num)
		ld	b,a
		ld	a,(hl)
		or	a
		jr	nz,nx_end2
		inc	hl
		ld	a,(hl)
		and	3
		jr	nz,nx_end2

		sla	b		;posledni sektor je cely obsazeny, rotuj pocet sektoru o 10 bitu vlevo
		sla	b
		ld	h,b
		ld	l,0
;		ld	c,0		;chyba
		jr	nx_end1		

nx_end2		dec	b		;A=pocet sektoru, posledni sektor je castecne obsazeny
		sla	b
		sla	b
		ld 	hl,blen+1
		ld	a,(hl)
		and	3
		or	b
		ld	b,a
		dec	hl
		ld	l,(hl)
		ld	h,b
nx_end1		ld	(portion_len),hl	;HL= delka v bajtech zbyvajici casti. Bud cely buffer, nebo zbytek souboru
		scf
		ret			


/*
;vylepsene next_params: navic odecitani delky souboru pri kopirovani, pocitani aktualni porce k loadu/sejvu
next_params	ld	hl,(beg_sec)	;pocatecni sektor pro start loadu
		ld	d,0
		ld	a,(buf_len_secs)
		ld	e,a
		ld	c,e		;C=delka bufferu v sektorech	
		add	hl,de		;v HL mam zamyslenou delku souboru po loadu/sejvu
		ld	de,(flen_secs)	;nesmi byt >celkova delka souboru
		ex	de,hl
		or	a
		sbc	hl,de		;je poc sektor+ buffer > delka souboru?
		ld	a,c
		jr	nc,nx_end	;C=ano, nasledny load/sejv bude posledni
		ld	a,l
		cpl
nx_end		ld	(sec_num),a
		ld	b,a
		cp	c
		ld	hl,(disk_buf_len)
		jr	z,nx_end1
		ld	hl,blen		;ziskej delku posledni casti v bajtech na zaklade poctu poslednich sektoru.
					;Pokud je spodních 10 bitů délky souboru 0, pak je posledni sektor cely obsazeny.
					;Pak staci pocet sektoru rotovat o 10 bitu vlevo a mam vyslednou delku.
					;Jinak rotuj o 10 bitu vlevo pocet sektoru zmenseny o 1 a pripocti k tomu 10 bitu celkove 						;delky souboru
		ld	a,(hl)
		or	a
		jr	nz,nx_end2
		inc	hl
		ld	a,(hl)
		and	3
		jr	nz,nx_end2

		sla	b		;posledni sektor je cely obsazeny, rotuj pocet sektoru o 10 bitu vlevo
		sla	b
		ld	h,b
		ld	c,0
		jr	nx_end1		

nx_end2		dec	b		;A=pocet sektoru, posledni sektor je castecne obsazeny
		sla	b
		sla	b
		ld 	hl,blen+1
		ld	a,(hl)
		and	3
		or	b
		ld	b,a
		dec	hl
		ld	l,(hl)
		ld	h,b
		push	hl

		ld	hl,(rest_len)	;substract disk_buf_len from rest_file first
		ld	de,(rest_len+2)	;rest_len can be then used eg. for display copy progress
		ld	bc,(disk_buf_len)
		ld	a,sub32
		call	bsdos
		ld	(rest_len+2),de
		ld	(rest_len),hl

		pop	hl
		xor	a		;set NZ
		inc	a
nx_end1		ld	(portion_len),hl	;HL= delka v bajtech zbyvajici casti. Bud cely buffer, nebo zbytek souboru
		ret			;OUT=Z=not last load/save, NZ=next load/save will be last
*/

	IFDEF hgfx64x24
getversion;	xor	a		;not needed, address of buffer is always #2300
;		call	bsdos
;		ld	(bsdosbuf+1),ix	;buffer dosu, na adrese buffer+#80 je chybove hlaseni

		ld	hl,bsdosbuf	;presmerujeme hlaseni bsdosu na vlastni rutinu
		ld	a,sdmsx
		jr	bsdos		

bsdosbuf
				;dole je nyni pripnuty bsdos
		ld	ix,flag1	;bez toho to netiskne
		ld	de,#2380	;DE=adresa chyboveho textu
		ld	hl,txt_adr_edit_zone2
;		call	#3C9A		;DOS se zakazanym zapisem- netreba HGFX VRAM je mimo BSDOS (od #4000)
		call	PRINTHL
		call	akey
		call	clear_edit_zone
;		call	#3C9E		;DOS- povol zapis
		and	a		;set NC for abort
		ret			;navrat do BSDOSu
	ENDIF

getver		equ 0
sdmsx		equ #35	
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
bsdos		call #3C9E
		rst #20
		call #3C98
		ret

;		ds #20			;place for application SP
end
len=end-start_address