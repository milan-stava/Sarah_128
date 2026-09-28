;rozpis planaru
planar_pismo	equ	%00011111	;31	BPL 0-4
planar_kurzor	equ	%10000000	;128	BPL 7
planar_oznac	equ	%01000000	;64	BPL 6
planar_wifi	equ	%00100000	;32	BPL 5


gzx_port	    equ	0x7C3B	;General ZXI port
gzx_data        equ 0x7D3B
g_zxi_port	    equ	0x7C3B	;General ZXI port
g_zxi_data      equ 0x7D3B
; g_zxi_001 - Extra graphics modes
;   00 - none
;   01 - HiResColour(HRC) - 512x192 pixels / 64x48 attributes / Spectrum attributes
;   02 - HiResindeXedColour(HRXC) - 512x192 pixels / 64x48 attributes / indeXedColours
;   03 - HGFX 1 - 256x192 pixels - two buffers - ZX/linear memory layout
;   04 - HGFX 2 - 512x192 pixels - one buffer - linear memory layout
;   05 - HGFX 3 - 512x384 pixels x 16 colour - one buffer - linear memory layout
;   06 - HGFX 4 - 720x546 pixels x 4 colour - one buffer - linear memory layout (Chunky mode only)
; g_zxi_002 - Advanced video parameters
;	bit0 = 1 - activate first video buffer to page 6 instead of page 5
;	bit1 = 1 - enable BigBorder in HGFX modes
;	bit2 = 1 - RGB  or   0 - BGR palette order for HRXC and HGFX modes

; g_zxi_020 - HGFX - general settings
;   bit0 = memory layout: 0 - standard ZX; 1 - linear
; 	bit1 = border colour: 0 - standard ZX; 1 - indexed (index 0-7)
;	bit2 = ZX transparency: 0 - enable; 1 - disable;
;   bit7 = write to HGFX registers: 0 - enable; 1 - disable; 


; g_zxi_021 - HGFX - high byte of Videoram area
; g_zxi_022 - HGFX - high byte of Registers area
; g_zxi_023 - HGFX - high byte of Indexed colour table area
; g_zxi_02F - HGFX status
;       bit0 = 0 - ready; 1 - busy (e.g. erase/copy full buffer)






g_zxi_001   equ 01h ; - Extra GFX modes
g_zxi_002   equ 02h ; - Advanced video parameters
;	bit0 = 1 - activate first video buffer to page 6 instead of page 5
;	bit1 = 1 - enable BigBorder in HGFX modes
;	bit2 = 1 - RGB  or   0 - BGR palette order for HRXC and HGFX modes
g_zxi_020   equ 20h ;- HGFX - general settings
                    ;   bit0 = memory layout: 0 - standard ZX; 1 - linear
                    ; 	bit1 = border colour: 0 - standard ZX; 1 - indexed (index 0-7)
                    ;	bit2 = ZX transparency: 0 - enable; 1 - disable;
    
g_zxi_021   equ 21h ; - HGFX - high byte of Videoram area
                    ; h40 - default

g_zxi_022   equ 22h ; - HGFX - high byte of Registers area
 	                ; h5B - default

g_zxi_023   equ 23h ; - HGFX - high byte of Indexed colour table area
                    ; start address for a table of 768 bytes, 256 positions
                    ; h5C - default

g_zxi_02F   equ 2Fh ; - HGFX status
                    ; bit0 = 0 - ready; 1 - busy (e.g. erase/copy full buffer)

g_zxi_01C   equ 1Ch ; - HGFX line interrupt Y position - low byte - default 0
g_zxi_01D   equ 1Dh ; - HGFX line interrupt Y position - high byte - default 0



g_zxi_040   equ 0x40    ; - FastDMA - mode
 	                    ; bit0 = disable/enable
     	                ; bit1-7 = reserved, must be 0
g_zxi_041   equ 0x041   ; - FastDMA - high byte of Registers area
                        ; h5D - default



MODE_NONE   equ 00  ; - none
MODE_HRC    equ 01  ; - HiResColour(HRC) - 512x192 pixels / 64x48 attributes / Spectrum attributes
MODE_HRXC   equ 02  ; - HiResindeXedColour(HRXC) - 512x192 pixels / 64x48 attributes / indeXedColours
MODE_HGFX1  equ 03  ; - HGFX 1 - 256x192 pixels - two buffers - ZX/linear memory layout
MODE_HGFX2  equ 04  ; - HGFX 2 - 512x192 pixels - one buffer - linear memory layout
MODE_HGFX3  equ 05  ; - HGFX 3 - 512x384 pixels x 16 colour - one buffer - linear memory layout
MODE_HGFX4  equ 06  ; - HGFX 4 - 720x546 pixels x 4 colour - one buffer - linear memory layout (Chunky mode only)

PLANAR_MODE_INK     equ 0
PLANAR_MODE_COPY    equ 1
PLANAR_MODE_ATTR    equ 2

COPY_ALL    equ 01
ERASE_ALL   equ 02

ADV_NOP     equ 0
ADV_FILL    equ 1
ADV_HAM     equ 2
V_PARAM   equ %00000   ; viz regs_hgfx.asm
SCR_ADDR    equ 16384
; SCR_ADDR    equ 49152
; SCR_ADDR    equ 0
; PAL_ADDR    equ 6144
; PAL_ADDR    equ 0xFB00
;PAL_ADDR    equ 22528
PAL_ADDR	equ #2000
initialise_hgfx
	call	hgfx_init
	jp	hgfx_continue
	
hgfx_init
	call	hgfx_on

    ld a,g_zxi_002  ; adv video params
    ld bc,g_zxi_port
    out (c),a
    ; ld a,2          ; bit 1 - BigBorder
    xor a           ; normal border
    ; ld a,4              ; rgb
    ; ld bc,g_zxi_data  ; inc bc
    inc b
    out (c),a

    ld a,g_zxi_020  ; hgfx general settings
    ld bc,g_zxi_port
    out (c),a
    ld a,%101      ; transparency disable, linear layout
    ; ld a,1
    inc b
    out (c),a

    ; nastaveni adresy hgfx
    ld a,g_zxi_021
    ld bc,g_zxi_port
    out (c),a
;	ld a,0		;bylo 0, ale tluce se to s BSDOSem
    ld a,SCR_ADDR/256
    ; ld bc,g_zxi_data
    inc b
    out (c),a

    ; nastaveni adresy registru hgfx
    ld a,g_zxi_022
    ld bc,g_zxi_port
    out (c),a
    ld a,VIDEO_REGS/256
    ; ld bc,g_zxi_data
    inc b
    out (c),a

    ; nastaveni adresy palety
    ld a,g_zxi_023
    ld bc,g_zxi_port
    out (c),a
    ld a,PAL_ADDR/256
    ; ld bc,g_zxi_data
    inc b
    out (c),a

    ; inicializace palety		;dame to do HGFX ON, kvuli obnove VRAM- blabe, dava tam zmatky
	ld	hl,PAL_ADDR		;nejdriv vymazat, pro zichr
	push	hl
;	ld	de,PAL_ADDR+1
	ld	bc,767

;	ld	(hl),0
;	ldir
pal_ini	xor	a
	ld	(hl),a
	inc	hl
	dec	bc
	ld	a,b
	or	c
	jr	nz,pal_ini	

   ld hl,pal16
;   ld de,PAL_ADDR
  pop de 
  ld bc,pal16_len
   ldir

		ld	hl,pal16+12	;bila barva pro kurzor na pozici 128
		push	hl
		ld	de,PAL_ADDR+128*3
		ld	bc,3
		push	bc
		ldir

		pop	bc			;bila na pozici 70
		pop	hl
		ld	de,PAL_ADDR+70*3
		push	hl
		push	bc
		ldir

		pop	bc
		pop	hl
		ld	de,PAL_ADDR+192*3	;bila pro SELECTED+CURSOR na pozici 192
		push	bc
		ldir

;		pop	hl			;bila jako zakladni pismo na pozici 7
;		pop	bc
;		push	bc
;		ld	de,PAL_ADDR+7*3
;		ldir


		pop	bc
		push	bc
		ld	hl,pal16+3	;barva pisma v kurzoru neoznacenem na pozici 132 pri rollu polozky
		push	hl
		ld	de,PAL_ADDR+132*3
		ldir

		pop	hl		;barva pisma v kurzoru neoznacenem na pozici 131
		pop	bc
		push	bc
		push	hl
		ld	de,PAL_ADDR+131*3
		ldir

		pop	hl
		pop	bc		;... a taky na pozici 135 pro roll item
		push	bc
		push	hl
		ld	de,PAL_ADDR+135*3
		ldir

		pop	hl
		pop	bc		;... a tu samou barvu na pozici 32 pro wifi wait/unwait
		push	bc
		ld	de,PAL_ADDR+32*3
		ldir



		pop	bc
		ld	hl,pal16+6		;cervena pro vybrany soubor na pozici 71
		push	hl
		ld	de,PAL_ADDR+67*3
		push	bc
		ldir

		pop	bc
		pop	hl
;		push	bc
		ld	de,PAL_ADDR+195*3	;cervena pro SELECTED+CURSOR (pozice #c7)
		ldir

;		pop	bc			;BC=3
;		ld	hl,pal16+3		;kopirujeme modrou pro wifi wait/unwait
;		ld	de,PAL_ADDR+32*3
;		ldir

    
    ld a,V_PARAM
    ld (VIDEO_REGS.V_PARAM),a
;;    ld hl,0					;asi neni treba, rutiny si inicializuji offsety samy
;;    ld (VIDEO_REGS.OFFSET_X),hl
;;    ld (VIDEO_REGS.OFFSET_Y),hl
;;    ld (VIDEO_REGS.OFFSET_X_R),hl
;;    ld (VIDEO_REGS.OFFSET_Y_R),hl
    ; ld (VIDEO_REGS.WINC_Y),hl
    ; ld hl,384
    ; ld (VIDEO_REGS.WIN_H),hl

    ld a,PLANAR_MODE_ATTR
    ; ld a,PLANAR_MODE_INK
    ld (VIDEO_REGS.PLANAR_MODE),a

;    ld a,255				;puvodne, vsechny bitplany
;	ld	a,63			;jen BPL0-4
;    ld (VIDEO_REGS.MASK),a

    ld a,0
    ld (VIDEO_REGS.COLOR),a
;    ld a,255
;	ld	a,63
;   ld (VIDEO_REGS.MASK),a

    call hgfxcls


;     ld a,0
;     ld (VIDEO_REGS.PAPER),a
;     ; ret
; fdma_init
;     ld bc,g_zxi_port
;     ld a,g_zxi_040
;     out (c),a
;     inc b
;     ld a,1
;     out (c),a
;     dec b
;     ld a,g_zxi_041
;     out (c),a
;     inc b
;     ld a,FDMA_REGS/256
;     out (c),a
;;    ret

	ld a,4				;bylo 7
	ld (VIDEO_REGS.COLOR),a
        ld a,0
        ld (VIDEO_REGS.PAPER),a
	ret				;end of hgfx_init

cls
hgfxcls
	ld	a,255
    ld (VIDEO_REGS.MASK),a
    ld a,ERASE_ALL
    ld (VIDEO_REGS.ADVANCED),a
    ; call hgfx_wait
    ; ret

hgfx_wait
    ld bc,g_zxi_port
    ld a,g_zxi_02F
    out (c),a
    inc b
1
    in a,(c)
    ; cp 0
    and 1
    jr nz,1B
	ld	a,planar_pismo
    ld (VIDEO_REGS.MASK),a
    ret

hgfx_on
    ld a,g_zxi_001  ; hgfx mode 2
    ld bc,g_zxi_port
    out (c),a
    ; ld a,MODE_HGFX3
    ld a,MODE_HGFX2
    ; ld bc,g_zxi_data  ; inc bc
    inc b
    out (c),a
	ret

hgfx_off
    ld a,g_zxi_001  ; hgfx mode 2
    ld bc,g_zxi_port
    out (c),a
    ; ld a,MODE_HGFX3
    ld a,MODE_NONE
    ; ld bc,g_zxi_data  ; inc bc
    inc b
    out (c),a
    ret

pal16
    db 0x00,0x00,0x00	;podkladova barva
    db 0xFF,0x00,0x00	;pro wifinu tmave modra
    db 0x00,0x00,0xB6	;cervena
;    db 0xB6,0x00,0xB6	;original, dame pryc, nahradime
    db 192,224,0	;barva c. 3, pro svetle modrou v adresari
    db 0xB6,0xB6,0xB6	;bila
;    db 0xB6,0xB6,0x00
;    db 0x00,0xB6,0xB6
;    db 0xB6,0xB6,0xB6	;bila
;    db 0x00,0x00,0x00
;    db 0xFF,0x00,0x00
;    db 0x00,0x00,0xFF
;    db 0xFF,0x00,0xFF
;    db 0x00,0xFF,0x00
;    db 0xFF,0xFF,0x00
;    db 0x00,0xFF,0xFF		;musime dat pryc neni misto
;    db 0xFF,0xFF,0xFF
pal16_len   equ $-pal16

FDMAstart	equ	#5b00
gZxi		equ	#7c3b
fDMA
.Init
;	ld	hl,FDMAreg	;prenes FDMA registry	;asi netřeba, FDMA registry definujeme pomoci DISP
;	ld	de,#5b00
;	ld	bc,#10
;	ldir

	ld	bc,gZxi
	ld	a,0x40	;FDMA
	out	(c),a
	inc	b
	ld	a,1	;Enable
	out	(c),a
	dec	b
	ld	a,0x41
	out	(c),a
	inc	b
	ld	a,#5B		;zacatek registru od #5b00
;	ld	a,(h)FDMAreg	;Registry zde
	out	(c),a

	call	set_fdma_to_chars

/*
	ld	hl,0
	ld	(FDMAreg.FS_Copy),hl
	ld	(FDMAreg.FS_Mod),hl

	ld	hl,1	;1 bajt zkopíruj...
	ld	(FDMAreg.FD_Copy),hl	;...a 63 přeskoč.
	ld	hl,63
	ld	(FDMAreg.FD_Mod),hl


	ld	hl,8	;znak má 8 bajtů
	ld	(FDMAreg.F_Len),hl
	
	ld	hl,HGFX.vid
	ld	(fDMAreg.FD_Adr),hl
*/

	ret



	DISP FDMAstart

FDMAreg
.F_mode		defb	0	;Mode
				; b0 Reset Source adr
				; b1 Reset Dest adr
				; b0 LDIR (0), LDDR (1)
.F_Len		defw	0	;Total length

;Source
.FS_Adr		defw	0	;Zdroj dat
.FS_Copy	defw	0	;CopyLen
.FS_Mod		defw	0	;Modulo

;Destination
.FD_Adr		defw	0	;Cíl dat
.FD_Copy	defw	0	;CopyLen
.FD_Mod		defw	0	;Modulo
	ENT