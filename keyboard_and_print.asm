;wifi stahovatko, MB03
;keyboard and print routines
;HOod

;17.04.2026- newly HGFX added 64 chars x 24 line

;new feature: can hide passwords with "X"

;print type
;0=standart (print codes #D,#A as 
;1=omit codes #D,#A- take them as end of text (#D,#A= byte 0)
;2=codes #D,#A taken as a new line
print_type=1


;temporary
INPBUFF	ds 256		;buffer for input keys
keysound db 0				;key sound 0= yes,1= no, klavesnicove echo
BORDER   db 1				;okraj


WTKY     xor  a				;ceka na stisk klavesy, nebo +b+ preruseni ;o)
         in   a,(254)		
         cpl  
         and  31
         ret  z
         ld   a,b
         or   a
         jr   z,WTKY
         ld   de,768
WTK2     ex   (sp),hl
         ex   (sp),hl
         dec  de
         ld   a,e
         or   d
         jr   nz,WTK2
         djnz WTKY
         ret  
         
WAIT     ei   				;cekaci smycka, musi se nastavit b-cko
WAIT2    halt 
         djnz WAIT2
         ret  



otherkey	defb $55
lastkey		defb $55
keywait		ld b,20
kw2		push bc
		ld b,0
kw1		djnz kw1
		pop bc
		djnz kw2
		ret
KEYSCAN
return_key			;first press, returns NZ, next presses Z, no return if no key pressed

keyboard	call inkey	;Busy's MRS solution- the best:))
		or a
		jr nz,keyb1
		ld (lastkey),a
		ret		;if no key pressed, RETurn with A=0 and Z flag
;		jr keyboard
/*alternativa, zpomaleni klavesnice pro rychlejsi CPU
keyb1		ei
		halt
		halt
		di
key_cont	ld c,a
*/	
keyb1		ld bc,$400


keyb2		dec c
		jr nz,keyb2
		djnz keyb2
		ld c,a
		call inkey
		cp c
		jr nz,keyboard
		ld a,(lastkey)
		cp c
		jr z,keyb3
		ld a,$80
		jr keyb4
keyb3		ld a,(otherkey)
		ld b,a
keyb7		xor a
keyb5		dec a
		jr nz,keyb5
		call inkey
		cp c
		jr nz,keyboard
		djnz keyb7
		ld a,1
keyb4		ld (otherkey),a
		ld a,c
		ld (lastkey),a
beep		push af
;		or a			;tento or je pro rutinu MRS dulezity, jinak rutina kvici
		call beepk		;beep
		pop af
		ret		;end of Busy's solution			

beepk		ld a,(keysound)		;Busyho nahradni rutina,kratsi
		or a
		ret nz
		ld a,(BORDER)
		xor	a		;black border
		ld e,a
		ld b,$10
		add a,b
;		ld a,$10+border
		out ($fe),a
		ld b,$1c
beepk1		djnz beepk1
		ld a,$08
		add a,e
;		ld a,$08+border
		out ($fe),a
		ret



	IFNDEF hgfx64x24

;hl=umisteni (0-23,0-63)
AADRSET  ld   a,h			;vypocte adresu na obrazovce....
         push hl
         and  %00011000
         or   %01000000
         ld   l,0
         rr   h
         rr   l
         rr   h
         rr   l
         rr   h
         rr   l
         ld   h,a
         pop  bc
         bit  0,c
         jr   nz,AMODIFY
         ld   a,1
ACONT    srl  c
         ld   b,0
         add  hl,bc
         ret  
AMODIFY  xor  a
         jr   ACONT
	ENDIF

	IFDEF hgfx64x24
max_chars	equ	64
max_lines	equ	24

PRINT		ld	hl,(HLKO+1)
PRINTHL		bit 4,(ix+0)
		ret z			;we do not want to print anything
		call	give_coords

print_loop	ld	a,(de)
		or	a
		jr	z,pl1
		cp	#D
		jr	nz,print_loop1

pl1		ld	hl,HLKO+1	;Z=konec textu
		ld	de,text_x
		ld	a,(de)
		ld	(hl),a
		inc	hl
		inc	de
		ld	a,(de)
		ld	(hl),a		;dej pozici tisku X a Y do navesti HLKO
HLKO		ld	hl,#5555
		ret

print_loop1	push	de
		call	printchar
		pop	de
		inc	de
		jr	print_loop

give_coords	push	af
		push	hl		;predej koordinaty v HL (napr. HL=#0105) tiskove rutine
		ld	(pch1+1),hl
		pop	bc
		ld	a,b
		ld	(text_y),a
		ld	l,a
		ld	h,0
		add	hl,hl
		add	hl,hl
		add	hl,hl		;8x
		ld	(y),hl		;pozice pro tisk HGFX
		ld	(VIDEO_REGS.OFFSET_Y),hl

		ld	a,c
		ld	(text_x),a	;ulozi pozadovanou pozici tisku do souradnic tiskove rutiny
		ld	l,a
		ld	h,0
		add	hl,hl
		add	hl,hl
		add	hl,hl		;8x
		ld	(x),hl		;pozice pro tisk HGFX
		ld	(VIDEO_REGS.OFFSET_X),hl
		pop	af
		ret

CHAR		call	give_coords	;toto zajisti kompatibilitu s vyssimu rutinami, ktera maji na vstupu v HL pozici znaku (napr HL=#0105)
printchar				;samotny tisk znaku

/*s kazdym znake, zdrzuje to, dame to za praci s kurzorem
	ld	hl,1	;1 bajt zkopíruj...			;priprav si tisk FDMA; dat to mimo tisk znaku- zdrzuje to tady
;	ld	(#5b00+#B),hl
	ld	(FDMAreg.FD_Copy),hl	;...a 63 přeskoč.
	ld	hl,63
	ld	(FDMAreg.FD_Mod),hl
;	ld	(#5b00+#D),hl
	ld	hl,8	;znak má 8 bajtů
;	ld	(#5b00+1),hl
	ld	(FDMAreg.F_Len),hl
*/

    cp 13
    jr z,nexty

    ld hl,(y)
    ld (VIDEO_REGS.OFFSET_Y),hl
    call char_out
    call nextx
pch1	ld	hl,#5555				;zvyseni tiskove pozice o 1 na vystupu. Uzitecne pro stare rutiny vyssi, pouzivajici jen CHAR
    ret							;funkce rutin pro HGFX se nemeni. Jen pridavama kompatibilitu s vyssimi rutinami

char_out				;pridavame tisk pres FDMA

    ld l,a
    ld h,0
    add hl,hl
    add hl,hl
    add hl,hl   ;*8
    ld bc,FONT-256

    add hl,bc				;HL=zdroj- bajt znaku
		ld	(FDMAreg.FS_Adr),hl
;		ld	(#5b00+3),hl
;    ld de,SCR_ADDR
;	ld de,0
	ld	hl,SCR_ADDR
	ld	(FDMAreg.FD_Adr),hl

	ld	a,%0001000
	ld	(FDMAreg.F_mode),a	;spust prenos
;	ld	(#5b00),a
;tady by melo/mohlo byt jeste pricteni 8 do offsetu Y
	ret
/*
    ld b,8				;FDMA= 10T/ 1 znak
chloop
    ld a,(hl)				;7
    ld (de),a				;7
    inc hl				;6

    push hl				;11
    ld hl,(VIDEO_REGS.OFFSET_Y)		;16
    inc hl				;6
    ld (VIDEO_REGS.OFFSET_Y),hl		;16
    pop hl				;10
    djnz chloop				;13/8
    ret					;87*8=696
*/

nextx
    ld a,(text_x)
    inc a
		ld	hl,pch1+1		;nastav se na sloupec
		cp	max_chars
;    cp 64   ; sirka scr ve znacich
    jr z,nextline
		inc	(hl)			;zvysujeme pozici o 1 sloupec
    ld (text_x),a
    ld hl,(x)				;takto oznacene;;;netreba pro tisk
    ld de,8 ; sirka fontu
    add hl,de
    ld (x),hl
    ld (VIDEO_REGS.OFFSET_X),hl
    ret

nextline
	xor	a
	ld	(hl),a				;skok na dalsi radek, sloupec 0
	inc	hl
	inc	(hl)				;zvys radek o 1
    ld hl,0
    ld (x),hl
    ld (VIDEO_REGS.OFFSET_X),hl
;    ld a,0
    ld (text_x),a


nexty
    ld a,(text_y)
    inc a
		cp	max_lines
;    cp 24
    jr z,konec_stranky
    ld (text_y),a
    ld hl,(y)
    ld de,8 ; vyska fontu
    add hl,de
    ld (y),hl
    ld (VIDEO_REGS.OFFSET_Y),hl
    ret

konec_stranky
    ld a,0
    ld (text_y),a
    ld bc,0
; bc = y x
setpos
    ld (text_x),bc
	ld	(pch1+1),bc			;nulujeme i pozici pro tisk znaku CHAR (jen pro vyssi rutiny)
    ld l,c
    ld h,0
    add hl,hl
    add hl,hl
    add hl,hl   ; *8 sirka fontu
    ld (x),hl

    ld l,b
    ld h,0
    add hl,hl
    add hl,hl
    add hl,hl   ; *8 vyska fontu
    ld (y),hl
    ret

x   dw 0
y   dw 0
;    include "hgfx.asm"
text_x
    db 0
text_y
    db 0
font
;    incbin "zx.fnt"
;	incbin "8x8-l2_short.fnt"
;    ALIGN 256
	DISP	HGFX_REGISTERS
VIDEO_REGS  HGFX 
	ENT


	ELSE
POS2HL	ld	h,b			;ukonceni tiskove rutiny, ulozeni pozice
	ld	l,c
	ld	(HLKO+1),hl
HLKO	ld	hl,#4000		;init, zacatek screenu
	ret


PRINT   ld hl,(HLKO+1) 
PRINTHL	bit 4,(ix+0)
	ret z			;we do not want to print anything
	push hl			;vypise text. Konec textu je definovan bytem 0
         call ADRSET
         pop  bc
         ex   de,hl
         jr   z,SECND
FIRST    ld   a,(hl)
         or   a
	jr	z,POS2HL

	IFN print_type=0	;start of conditional assembly
	cp	#D

	IF print_type=2
	jr	z,f2
	ENDIF

	IF print_type=1
	jr	z,POS2HL	;codes #D, and #A interpretted as end of text
	ENDIF


	cp	#A
	
	IF print_type=2
	jr	nz,f1
	ENDIF

	IF print_type=1
	jr	z,POS2HL
	ENDIF

	IF print_type=2
f2	ld	a,#10		;omit codes #D, #A
	add	a,e		;
	and	%11110000	;
	ld	e,a		;skip to next line
	inc	hl		;
	jr	FIRST		;
	ENDIF
	ENDIF			;end of conditional assembly
	
f1        push hl
         push de
         push bc
         add  a,a
         ld   l,a
         ld   h,0
         add  hl,hl
         add  hl,hl
         ld   bc,FONT-256
         add  hl,bc
         ex   de,hl

;ver27 vracime zpet font na #B700, takze i zrychlujeme rutinu;ver26, kvuli posunu fontu kvuli volnemu mistu davame o 2 takty pomalejsi instukci, ale font muzeme umistit mimo nasobky #10 (bylo tam jen inc e)..... musi tu byt INC DE a font muze byt kdekoliv

	DUP 7
	ld	a,(hl)
	and	%00001111
	ld	b,a
        ld   a,(de)
        and  %11110000
	or	b
         ld   (hl),a
         inc  de
         inc  h			
	EDUP

	ld	a,(hl)
	and	%00001111
	ld	b,a
        ld   a,(de)
        and  %11110000
	or	b
         ld   (hl),a


/*
         ld   a,(de)		
         and  %11110000
         or   (hl)
         ld   (hl),a
         inc  de
         inc  h
         ld   a,(de)
         and  %11110000
         or   (hl)
         ld   (hl),a
         inc  de
         inc  h
         ld   a,(de)
         and  %11110000
         or   (hl)
         ld   (hl),a
         inc  de
         inc  h
         ld   a,(de)
         and  %11110000
         or   (hl)
         ld   (hl),a
         inc  de
         inc  h
         ld   a,(de)
         and  %11110000
         or   (hl)
         ld   (hl),a
         inc  de
         inc  h
         ld   a,(de)
         and  %11110000
         or   (hl)
         ld   (hl),a
         inc  de
         inc  h
         ld   a,(de)
         and  %11110000
         or   (hl)
         ld   (hl),a
*/

         pop  bc
         inc  c
         pop  de
         pop  hl
         inc  hl
SECND    ld   a,(hl)
         or   a
	jp	z,POS2HL

	IFN print_type=0	;here starts conditional assembly
	cp	#D

	IF print_type=2
	jr	z,s2
	ENDIF

	IF print_type=1
	jp	z,POS2HL	;codes #D, and #A interpretted as end of text
	ENDIF


	cp	#A

	IF print_type=2
	jr	nz,s1
	ENDIF

	IF print_type=1
	jp	z,POS2HL
	ENDIF

	IF print_type=2
s2	ld	a,#10		;
	add	a,e		;omit codes #D, #A
	and	%11110000	;
	ld	e,a		;skip to next line
	inc	hl		;
	jr	SECND		;
	ENDIF
	ENDIF			;end of conditional assembly


s1         push hl
         push de
         push bc
         add  a,a
         ld   l,a
         ld   h,0
         add  hl,hl
         add  hl,hl
         ld   bc,FONT-256
         add  hl,bc
         ex   de,hl


	DUP 7
	ld	a,(hl)
	and	%11110000
	ld	b,a
        ld   a,(de)
        and  %00001111
	or	b
         ld   (hl),a
         inc  de
         inc  h			
	EDUP

	ld	a,(hl)
	and	%11110000
	ld	b,a
        ld   a,(de)
        and  %00001111
	or	b
         ld   (hl),a



/*
         ld   a,(de)
         and  %00001111
         or   (hl)
         ld   (hl),a
         inc  de
         inc  h
         ld   a,(de)
         and  %00001111
         or   (hl)
         ld   (hl),a
         inc  de
         inc  h
         ld   a,(de)
         and  %00001111
         or   (hl)
         ld   (hl),a
         inc  de
         inc  h
         ld   a,(de)
         and  %00001111
         or   (hl)
         ld   (hl),a
         inc  de
         inc  h
         ld   a,(de)
         and  %00001111
         or   (hl)
         ld   (hl),a
         inc  de
         inc  h
         ld   a,(de)
         and  %00001111
         or   (hl)
         ld   (hl),a
         inc  de
         inc  h
         ld   a,(de)
         and  %00001111
         or   (hl)
         ld   (hl),a
*/


         pop  bc
         inc  c
         pop  de
         pop  hl
         inc  de
	jr nz,cth
	ld a,#40
	cp d			;chces na 9 radek? Pak skoc na nulty
	jr nc,cth
	ld d,a
;         call z,CTH		;prozatini reseni, tisk v kuse jen do horni jen tretiny
cth         inc  hl
         jp   FIRST
         
;CTH      ld   a,d
;         add  a,8
;         ld   d,a
;        ret  

;start bc=4002, de=4000
;prvni 4,BC=4000, de=407F
;druha ctyrka. BC=4000, de=4100

      
         
ADRSET   ld   a,h			;vypocte adresu na obrazovce... patri k rutine PRINT
         push hl
         and  %00011000
         or   %01000000
         ld   l,0
         rr   h
         rr   l
         rr   h
         rr   l
         rr   h
         rr   l
         ld   h,a
         pop  bc
         bit  0,c
         ld   a,1
         jr   z,CONT
         xor  a
CONT     srl  c
         ld   b,0
         add  hl,bc
         or   a
         ret  
;TIMEOUT  db "Time out"
;         db $00,$C9



;hl=umisteni
;a=kod znaku
CHAR     ld   b,a			;vypis znaku 
         and  %11100000
         ld   a,b
         jr   nz,CHAR0
         ld   a,32
CHAR0    
         push bc
         push de
         push hl
         push af
         call AADRSET
         or   a
         jr   z,ASECND2
         ld   c,$F0
         jr   ASECND1
ASECND2  ld   c,$0F
ASECND1  pop  af
         ex   de,hl
         ld   l,a
         ld   h,0
         add  hl,hl
         add  hl,hl
         add  hl,hl
         push bc
         ld   bc,FONT-256
         add  hl,bc
         pop  bc
         ex   de,hl


         
         ld   b,(hl)
         ld   a,c
         cpl  
         and  b
         ld   (hl),a
         ld   a,(de)
         and  c
         or   (hl)
         ld   (hl),a
         inc  de
         inc  h
         
         ld   b,(hl)
         ld   a,c
         cpl  
         and  b
         ld   (hl),a
         ld   a,(de)
         and  c
         or   (hl)
         ld   (hl),a
         inc  de
         inc  h
         
         ld   b,(hl)
         ld   a,c
         cpl  
         and  b
         ld   (hl),a
         ld   a,(de)
         and  c
         or   (hl)
         ld   (hl),a
         inc  de
         inc  h
         
         ld   b,(hl)
         ld   a,c
         cpl  
         and  b
         ld   (hl),a
         ld   a,(de)
         and  c
         or   (hl)
         ld   (hl),a
         inc  de
         inc  h
         
         ld   b,(hl)
         ld   a,c
         cpl  
         and  b
         ld   (hl),a
         ld   a,(de)
         and  c
         or   (hl)
         ld   (hl),a
         inc  de
         inc  h
         
         ld   b,(hl)
         ld   a,c
         cpl  
         and  b
         ld   (hl),a
         ld   a,(de)
         and  c
         or   (hl)
         ld   (hl),a
         inc  de
         inc  h
         
         ld   b,(hl)
         ld   a,c
         cpl  
         and  b
         ld   (hl),a
         ld   a,(de)
         and  c
         or   (hl)
         ld   (hl),a
         inc  de
         inc  h
         
         ld   b,(hl)
         ld   a,c
         cpl  
         and  b
         ld   (hl),a
         ld   a,(de)
         and  c
         or   (hl)
         ld   (hl),a
         
         pop  hl
         pop  de
         pop  bc
         inc  l
         ret  

  	ENDIF		;tady konci podmineny preklad HGFX 



; INPUT starts empty; INPUT_VALUE takes a zero-terminated value in DE.
; IXH=maximum length (1..63). Fixed end marker bounds insert/delete shifts.
; Copy first, then pad: DE may point to INPBUFF itself (rename).
INPUT    ld   de,input_empty
INPUT_VALUE:
         ld   hl,INPBUFF
         ld   b,ixh
         ld   c,0
.copy    ld   a,(de)
         or   a
         jr   z,.pad
         call INPUT_MASK
         ld   (hl),a
         inc  hl
         inc  de
         inc  c
         djnz .copy
.pad     ld   a,c
         cpl
         ld   b,a
.spaces  ld   (hl),32
         inc  hl
         djnz .spaces
         ld   (hl),0                  ; INPBUFF+255, for shared length scans
         ld   hl,INPBUFF+63
         ld   (hl),0                  ; editor shifts must stop here
         ld   a,c
INPUT2   ld   (CURSOR+1),a
;         ld   hl,12*256+16	;puvodni z MBC
         ld   hl,txt_adr_edit_zone2
         ld   (INPOS+1),hl
IN2      ld   b,63
INPOS    ld   hl,0
         ld   de,INPBUFF
CURSOR   ld   c,0
;IN3      ld   a,e

IN3
		push	hl
		push	de
		ld	h,d
		ld	l,e
		ld	de,INPBUFF
		or	a
		sbc	hl,de
		ld	a,l
		pop	de
		pop	hl


         push bc
         cp   c
         jr   nz,INXXX
         ld   a,c
         or   a
         ld   b,'>'
         jr   z,CURTV2
         ld   b,'_'
CURTV2   ld   a,b
         push de
         call CHAR
         pop  de
INXXX   ld   a,(de)
	bit	7,a
	res	7,a
	jr	z,INXXX3		;Z=normal ASCII, NZ=tisk "X"
	ld	a,"X"			;pokud je nastaven 7.bit, tiskni X misto znaku
INXXX3	         push de
         call CHAR			;samotny tisk znaku
         pop  de
		inc	de
;         inc  e
         pop  bc
         djnz IN3

		push	hl
		push	de
		ld	h,d
		ld	l,e
		ld	de,INPBUFF
		or	a
		sbc	hl,de
		ld	a,l
		pop	de
		pop	hl
		

;         ld   a,e
         cp   c
         jr   nz,INXXX2
         ld   a,c
         cp   ixh
         ld   b,'<'
         jr   z,CURTV
         ld   b,'_'
CURTV    ld   a,b
         call CHAR
INXXX2   ld   b,1	;puvodne bylo 15 a kurzor byl liny a spatne reagoval
         call WTKY
INQQQ    call KEYSCAN
	or a
         jr   z,INQQQ	;tady se vyhodnoti klavesnice a tisknutelne znaky se daji do bufferu, ktery se vytiskne, viz vyse
;         jr   nz,INQQQ
;         ld   a,e
;         inc  a
;         jr   z,INQQQ
;         ld   a,d
;         ld   hl,iiss
;         cp   $18
;         jr   z,INSSS
;         ld   hl,iics
;         cp   $27
;         jr   z,INSSS
;         ld   hl,iinn
;INSSS    ld   d,0
;         add  hl,de
;         ld   a,(hl)
;         or   a
;         jr   z,INQQQ
         cp   1                       ; INKEY also returns 1 for two ordinary keys
         jr   nz,IN_CHECK_END
         ld   a,#7F
         in   a,(#FE)                 ; SPACE in row #7FFE, active low bit 0
         rrca
         jr   c,INQQQ                 ; ordinary rollover is not cancellation
         ld   a,#FE
         in   a,(#FE)                 ; CAPS SHIFT in row #FEFE
         rrca
         jr   c,INQQQ
         ld   a,4
IN_CHECK_END:
         cp   4
;         ret  z
		jr	z,IN_END 
        cp   13
		jr	z,IN_END
;         ret  z
         cp   199
         jp   z,INPUT
         ld   hl,IN2
         push hl
         ld   hl,CURSOR+1
         cp   8
         jr   z,CURSLEFT
         cp   9
         jr   z,CURSRGHT
         cp   12
         jr   z,BCKSPACE
         cp   15
         jr   z,DELETE
         cp   32
         ret  c
         cp   128
         ret  nc

         call INPUT_MASK


IN6         ex   af,af'
         push hl
         call input_l_count
         ld   a,c
         pop  hl
         cp   ixh
         ret  nc                      ; a full value must not lose its last character
         ld   a,(hl)
         cp   ixh
         ret  nc
         inc  (hl)
         ld   l,(hl)
         dec  l

		push	de
		ld	a,l
		ld	hl,INPBUFF
		ld	de,0
		ld	e,a
		add	hl,de
		pop	de
		


;         ld   h,INPBUFF/256

IN5      ld   a,(hl)
         or   a
         ret  z
         ex   af,af'
         ld   (hl),a
         inc  hl
         jr   IN5
CURSLEFT ld   a,(hl)
         or   a
         ret  z
         dec  (hl)
         ret  
CURSRGHT ld   a,(hl)
         cp   ixh
         ret  nc
         inc  (hl)
         ret  
DELETE   ld   a,(hl)
         cp   ixh
         ret  nc
         inc  a
         jr   BCK2
BCKSPACE ld   a,(hl)
         or   a
         ret  z
         dec  (hl)
BCK2     ld   l,a

		push	de
		ld	a,l
		ld	hl,INPBUFF
		ld	de,0
		ld	e,a
		add	hl,de
		pop	de


;         ld   h,INPBUFF/256

         ld   e,l
         ld   d,h
	dec	de		;byl error, pri deletu to mohlo mazat pamet
;         dec  e
DEL2     ld   a,(hl)
         ldi  
         or   a
         jr   nz,DEL2
         ex   de,hl
	dec	hl
;         dec  l
         ld   (hl),' '
         ret  

IN_END		ld	b,63			;na konci musime smazat vsechny 7 bity
		ld	hl,INPBUFF
IN_END1		res	7,(hl)
		inc	hl
		djnz	IN_END1
		ld	hl,CURSOR+1
		ld	c,(hl)			;C=pozice kurzoru
		ret

; Same mask for prefilled and newly typed characters; original value untouched.
INPUT_MASK:
INX_HS   or   0                       ; operand 0=plain, #80=masked
         ret
input_empty: db 0
	

	include "inkey.a80"	;ver26, premistujeme na #BF01



DOWNHL   inc  h				;voala, tohla snad musi byt vsude :))))
         ld   a,h
         and  7
         ret  nz
         ld   a,l
         add  a,32
         ld   l,a
         ret  c
         ld   a,h
         sub  8
         ld   h,a
         ret  



FONT
TOFONT	

	IFDEF hgfx64x24
	incbin "8x8-l2_short.fnt"
	ELSE
	incbin "1_W1250.BIN"
	ENDIF



