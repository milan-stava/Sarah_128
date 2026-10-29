; Second program bank (RAM 6). CFG startup and runtime profile selection.
; All entries require bank 6 mapped. No directory paging calls from this bank.

;zatim zde mame:
;1)prace s CFG souborem, nacteni profilu, zobrazeni profilu, vyber profilu, zobrazeni vybraneho profilu
;2)praci s TAPkou
;3)spusteni snapu SNA a Z80

load_cfg:
        call    cfg_read_file
        ret     c
        jp      parse_cfg

; Reuse the existing BS-DOS loader, without applying Default=1 during browsing.
; OUT: NC, HL=buffer, BC=length, zero-terminated; C=missing/oversized/empty CFG.
cfg_read_file:
        ld      hl,cfg_name
	call	file_exist+3
	jr      nz,.bad

	call	load_init
        ld      hl,(blen+2)
        ld      a,h
        or      l
        jr      nz,.bad
        ld      hl,(flen)
        dec     hl
        ld      de,cfg_capacity
        or      a
        sbc     hl,de
        jr      nc,.bad

.load_body:                     ; help reuses the read without CFG length checks
	ld	ix,cfg_file_here
	push	ix
	call	load_file+4		;nahraj cfg soubor

	ld	bc,(flen)
	pop	hl
	push    hl
	add	hl,bc
	ld	(hl),0			;uzavri konfigurak nulou
        pop     hl
        or      a
        ret
.bad:   scf
        ret


; HL = buffer, BC = length. Check end+1 before writing the sentinel.
; The whole selected profile is validated before the second (apply) pass.
; CR/LF/CRLF, comments, blank lines, final line without EOL are supported.
parse_cfg:
        push    hl
        add     hl,bc
        jr      c,.bad
        ld      (hl),0
        pop     hl
        ld      (cfg_next_line),hl
.find:
        ld      hl,(cfg_next_line)
        call    cfg_get_line
        ret     c
        ld      de,cfg_default
        call    cfg_match_key
        jr      c,.find
        ld      a,b
        or      c                       ; exact Default=1, no trailing characters
        jr      nz,.find
.found:
        ld      hl,(cfg_next_line)
        ld      (cfg_profile_start),hl
        xor     a
        ld      (cfg_apply),a
        jr      cfg_profile
.bad:
        pop     hl
        scf
        ret

cfg_profile:
        ld      ix,cfg_fields
.field:
        push    ix
        pop     de                      ; key stored inline with its descriptor
        ld      a,(de)
        or      a
        jr      z,.done
        ld      hl,(cfg_next_line)
        call    cfg_get_line            ; DE (key) preserved
        ret     c
        call    cfg_match_key
        ret     c
        inc     de                      ; DE = destination/limit/policy
        push    de
        pop     ix
        ld      a,b
        or      a
        jr      nz,.bad
        ld      a,(ix+2)
        cp      c
        jr      c,.bad                 ; reject oversized values, no truncation
        ld      a,c
        or      a
        jr      nz,.nonempty
        bit     1,(ix+3)
        jr      nz,.bad
        jr      .validated
.nonempty:
        bit     2,(ix+3)
        jr      z,.validated
        push    bc
        push    hl
        call    cfg_decimal
        ld      (cfg_number),hl
        pop     hl
        pop     bc
        ret     c
        bit     1,(ix+3)               ; Port must be 1..65535; Start allows 0
        jr      z,.validated
        ld      de,(cfg_number)
        ld      a,d
        or      e
        jr      z,.bad
.validated:
        ld      a,(cfg_apply)
        or      a
        jr      z,.next
        ld      a,c
        or      a
        jr      nz,.store
        bit     0,(ix+3)               ; empty File/Start keep existing values
        jr      nz,.next
.store:
        ld      e,(ix+0)
        ld      d,(ix+1)
        bit     3,(ix+3)
        jr      nz,.word
        inc     bc                      ; copy EOL too, then replace it with zero
        ldir
.terminate:
        xor     a
        dec     de
        ld      (de),a
        jr      .next
.word:
        ld      hl,(cfg_number)
        ld      a,l
        ld      (de),a
        inc     de
        ld      a,h
        ld      (de),a
.next:
        ld      de,4
        add     ix,de
        jr      .field
.bad:
        scf
        ret
.done:
        ld      a,(cfg_apply)
        or      a
        ret     nz                     ; second pass finished, NC
        inc     a
        ld      (cfg_apply),a
        ld      hl,(cfg_profile_start)
        ld      (cfg_next_line),hl
        jp      cfg_profile

; HL = next line. OUT: HL = first nonblank character; cfg_next_line = EOL/EOF.
; DE preserved, BC = line length. Sentinel bounds scans. Leading whitespace OK.
cfg_get_line:
.next:
        ld      a,(hl)
        or      a
        jr      z,.eof
        cp      " "+1
        jr      c,.skip
        cp      ";"
        jr      z,.comment
        push    hl
        call    cfg_line_end
        ld      (cfg_next_line),hl
        pop     hl
        or      a
        ret
.comment:
        call    cfg_line_end
        jr      .next
.skip:
        inc     hl
        jr      .next
.eof:
        scf
        ret

cfg_line_end:
        ld      bc,0
.scan:
        ld      a,(hl)
        or      a
        ret     z
        cp      13
        ret     z
        cp      10
        ret     z
        inc     hl
        inc     bc
        jr      .scan

; HL = line, DE = zero-terminated key. NC/HL = value, C = wrong key.
cfg_match_key:
        ld      a,(de)
        or      a
        ret     z
        cp      (hl)
        jr      nz,.bad
        inc     hl
        inc     de
        dec     bc                      ; remaining line length = value length
        jr      cfg_match_key
.bad:
        scf
        ret

; Checked decimal conversion. Rejects nondigits and >65535 (no wraparound).
cfg_decimal:
        ex      de,hl
        ld      hl,0
.digit:
        ld      a,(de)
        or      a
        ret     z
        cp      13
        ret     z
        cp      10
        ret     z
        sub     "0"
        cp      10
        jr      nc,.bad
        inc     de
        ld      b,h
        ld      c,l
        add     hl,hl
        ret     c
        add     hl,hl
        ret     c
        add     hl,bc
        ret     c
        add     hl,hl
        ret     c
        add     a,l
        ld      l,a
        jr      nc,.digit
        inc     h
        jr      nz,.digit
.bad:
        scf
        ret

cfg_default:    db "Default=1",0

; Key, destination, maximum value length, policy:
; bit 0 keep if empty, bit 1 required/nonzero, bit 2 numeric, bit 3 word store.
cfg_fields:
        db "Name=",0
        dw cfg_profile_name
        db 31,0
        db "Host=",0
        dw host_url
        db 45,2
        db "Port=",0
        dw ftp_port
        db 5,6
        db "User=",0
        dw var_user
        db 31,0
        db "Pass=",0
        dw var_pasw
        db 31,0
        db "File=",0
        dw var_name
        db 56,1
        db "Start=",0
        dw var_start
        db 5,13
        db 0

cfg_next_line:      dw 0
cfg_profile_start:  dw 0
cfg_number:         dw 0
cfg_apply:          db 0
cfg_profile_name:   ds 32

; G selector (first 32 profiles). Returns with IX=flag1. INPBUFF holds the original settings, so no extra backup buffer
; is allocated. Every preview starts from that snapshot (empty File/Start
; therefore keep the settings from entry, not those of another preview).
cfg_browser:
        xor     a
        ld      (cfg_accepted),a
        ld      hl,var_name
        ld      de,INPBUFF
        ld      bc,cfg_settings_len
        ldir
        ld      hl,ftp_port
        ld      bc,6
        ldir
        ld      hl,cfg_profile_name
        ld      bc,32
        ldir
        call    cfg_read_file
        jr      c,.missing
        xor     a
        ld      (cfg_selected),a
        ld      (cfg_top),a
        ld      b,a
        call    cfg_seek_profile
        jr      c,.missing
        ld      ix,flag1
        call    cfg_draw_profiles
.preview:
        call    cfg_preview
        call    cfg_draw_cursor
.keys:
        call    KEYSCAN
        cp      1
        jr      z,.cancel
        cp      13
        jr      nz,.move
        ld      a,(cfg_valid)
        or      a
        jr      z,.keys
        ld      (cfg_accepted),a
        jr      cfg_close
.move:
        ld      hl,cfg_selected
        ld      b,(hl)
        cp      11
        jr      nz,.down
        ld      a,b
        or      a
        jr      z,.keys
        dec     b
        jr      .select
.down:
        cp      10
        jr      nz,.keys
        inc     b
        bit     5,b
        jr      nz,.keys
        push    bc
        call    cfg_seek_profile
        pop     bc
        jr      c,.keys
.select:
        push    bc
        call    cfg_hide_cursor
        pop     bc
        ld      a,b
        ld      (cfg_selected),a
        ld      hl,cfg_top
        sub     (hl)
        cp      8
        jr      c,.preview             ; move only the cursor inside the window
        jr      nz,.above             ; row -1: reveal the preceding profile
        inc     (hl)
        ld      a,15                   ; row 8: reveal the next profile below
        jr      .scroll
.above:
        dec     (hl)
        ld      a,8
.scroll:
        ld      (cfg_draw_row),a
        call    cfg_scroll
        ld      a,(cfg_selected)
        ld      b,a
        call    cfg_seek_profile
        call    cfg_draw_name
        jr      .preview
.missing:
        ld      ix,flag1
        ld      de,cfg_missing_text
        call    print_ez1
        call    akey1
.cancel:
        call    cfg_restore_settings
        call    cfg_show_settings
cfg_close:
        call    cfg_clear_window
        ld      hl,txt_adr_mezera
        ld      de,spaces
        call    PRINTHL
        ld      a,(cfg_accepted) ; 1=ENTER confirmed, 0=cancel/missing
        ret
cfg_accepted db 0

; Find Name= lines directly in the CFG; no duplicate directory/index table.
; OUT: HL=Name line, DE=name value, BC=value length, C=EOF.
cfg_find_name:
.next:
        call    cfg_get_line
        ret     c
        push    hl
        ld      de,cfg_fields           ; first descriptor starts with Name=
        call    cfg_match_key
        pop     de
        jr      nc,.found
        ld      hl,(cfg_next_line)
        jr      .next
.found:
        ex      de,hl
        ret

; B=zero-based profile index (0..31). Rescanning saves a pointer table.
cfg_seek_profile:
        ld      hl,cfg_file_here
.next:
        push    bc
        call    cfg_find_name
        pop     bc
        ret     c
        ld      a,b
        or      a
        ret     z
        dec     b
        ld      hl,(cfg_next_line)
        jr      .next

cfg_draw_profiles:
        call    cfg_clear_window
        ld      hl,txt_adr_mezera
        ld      de,cfg_title
        call    PRINTHL
        ld      b,0
        call    cfg_seek_profile
        ret     c
        ld      a,8
        ld      (cfg_draw_row),a
.row:
        call    cfg_draw_name
        ld      hl,cfg_draw_row
        inc     (hl)
        ld      a,(hl)
        cp      16
        ret     z
        ld      hl,(cfg_next_line)
        call    cfg_find_name
        ret     c
        jr      .row

; DE=name value, cfg_draw_row=text row. Used for initial fill and one new row.
cfg_draw_name:
        ld      hl,cfg_profile_name
        ld      b,31
.copy:
        ld      a,(de)
        or      a
        jr      z,.end_name
        cp      13
        jr      z,.end_name
        cp      10
        jr      z,.end_name
        ld      (hl),a
        inc     hl
        inc     de
        djnz    .copy
.end_name:
        ld      (hl),0
        ld      a,(cfg_draw_row)
        ld      h,a
        ld      l,0
        ld      de,cfg_profile_name
        jp      PRINTHL

; A=8 scrolls down, A=15 scrolls up. Copy overlapping pixels in the safe
; direction and clear only the newly exposed row. Cursor is already removed.
cfg_scroll:
        IFDEF hgfx64x24
        push    af
        ld      hl,0
        ld      (VIDEO_REGS.OFFSET_X),hl
        ld      (VIDEO_REGS.OFFSET_X_R),hl
        ld      l,64
        ld      (VIDEO_REGS.OFFSET_Y),hl
        ld      (VIDEO_REGS.OFFSET_Y_R),hl
        ld      a,#FF
        ld      (VIDEO_REGS.MASK),a
        ld      a,PLANAR_MODE_COPY
        ld      (VIDEO_REGS.PLANAR_MODE),a
        pop     af
        ENDIF
        cp      8
        IFDEF hgfx64x24
        ld      hl,SCR_ADDR+3583
        ld      de,SCR_ADDR+4095
        ELSE
        ld      hl,#48DF
        ld      de,#48FF
        ENDIF
        ld      a,#B8                  ; LDDR when the content moves down
        jr      z,.copy
        IFDEF hgfx64x24
        ld      hl,SCR_ADDR+512
        ld      de,SCR_ADDR
        ELSE
        ld      hl,#4820
        ld      de,#4800
        ENDIF
        ld      a,#B0                  ; LDIR when the content moves up
.copy:
        ld      (.transfer+1),a        ; bank 6 is writable RAM
.stripe:
        IFDEF hgfx64x24
        ld      bc,3584                ; seven 512-byte HGFX character rows
        ELSE
        push    hl
        push    de
        ld      bc,224                 ; seven 32-byte ZX rows per pixel stripe
        ENDIF
.transfer:
        ldir
        IFDEF hgfx64x24
        ld      a,PLANAR_MODE_ATTR
        ld      (VIDEO_REGS.PLANAR_MODE),a
        ld      a,(cfg_draw_row)
        ld      c,a
        ld      b,1
        call    cls_9_lines
        jp      set_hgfx_ink_planar
        ELSE
        pop     de
        pop     hl
        inc     h
        inc     d
        bit     3,h
        jr      nz,.stripe             ; #48..#4F, stop on #50
        ld      a,(cfg_draw_row)
        sub     8
        rrca
        rrca
        rrca
        ld      l,a
        ld      h,#48
        ld      b,8
        jp      cls_9_lines
        ENDIF

cfg_clear_window:
        IFDEF hgfx64x24
        ld      a,#FF                  ;clear text, markers and old cursor plane
        ld      (VIDEO_REGS.MASK),a
        ENDIF
        call    cls_9
        IFDEF hgfx64x24
        jp      set_hgfx_ink_planar
        ELSE
        ld      hl,#5900
        ld      de,#5901
        ld      bc,255
        ld      (hl),7
        ldir
        ret
        ENDIF

; Use the directory's full-width renderer, skipping its bank-mapping prelude.
cfg_draw_cursor:
        IFDEF hgfx64x24
        ld      bc,unmark_cursor
        ELSE
        ld      a,unmark_cursor
        ENDIF
        jr      cfg_cursor
cfg_hide_cursor:
        IFDEF hgfx64x24
        ld      bc,unmark_no_curs
        ELSE
        ld      a,unmark_no_curs
        ENDIF
cfg_cursor:
        push    af
        ld      a,(cfg_selected)
        ld      hl,cfg_top
        sub     (hl)
        rrca
        rrca
        rrca
        ld      l,a
        ld      h,#59
        pop     af
        IFDEF hgfx64x24
        ld      e,planar_kurzor
        ENDIF
        jp      draw_cursor_row

cfg_preview:
        call    cfg_restore_settings
        ld      hl,cfg_selected
        ld      b,(hl)
        call    cfg_seek_profile
        ld      (cfg_next_line),hl
        ld      (cfg_profile_start),hl
        xor     a
        ld      (cfg_apply),a
        call    cfg_profile
        ld      a,1
        jr      nc,.valid
        xor     a
.valid:
        ld      (cfg_valid),a
        call    cfg_show_settings
        ld      de,cfg_help_text
        call    print_ez1
        ld      de,ftp_port
        call    PRINT
        ld      a,(cfg_valid)
        or      a
        ret     nz
        ld      hl,txt_adr_edit_zone2
        ld      de,cfg_invalid_text
        jp      PRINTHL

cfg_restore_settings:
        ld      hl,INPBUFF
        ld      de,var_name
        ld      bc,cfg_settings_len
        ldir
        ld      de,ftp_port
        ld      bc,6
        ldir
        ld      de,cfg_profile_name
        ld      bc,32
        ldir
        ret

cfg_show_settings:
        ld      ix,flag1
        call    prn_file_start
        jp      prn_host_usr_psw

cfg_settings_len equ cfg_name-var_name
        ASSERT cfg_settings_len+6+32 <= 256
cfg_selected:       db 0
cfg_top:            db 0
cfg_draw_row:       db 0
cfg_valid:          db 0
cfg_help_text:      db "Up/Down Enter=OK BREAK=cancel Port: ",0
cfg_missing_text:   db "CFG missing/invalid",0
cfg_invalid_text:   db "Invalid CFG profile",0
cfg_title:          db "Your profiles:",0


;2) prace s TAPkou
work_tap	di
		ld	hl,tapmaster_start
		ld	de,#4000
		push	de
		ld	bc,tapmaster_len
		ldir
		ret				;JP to TAPmaster
tapmaster_start	DISP	#4000
tapmaster
		include	"tapmaster.asm"		;here hand over to TAPmaster completely
tapmaster_len	equ	$-tapmaster
        ENT                     ; resume physical bank-6 assembly address
        ASSERT $ == tapmaster_start+tapmaster_len
        ASSERT tapmaster_len > 0
        ASSERT #4000+tapmaster_len <= SPCKO-64
;to je cele pro TAPku

;3) spusteni snapu SNA a Z80
work_snap       ld	a,#63			;now jump into bsdos nmi menu and run snap
		out	(23),a

        ; VER contains ASCII minor-version digits; bit 7 marks inverse text.
        ld      a,(#26D2)
        and     #7F
        sub     "0"
        cp      10
        jr      nc,slb
        ld      b,a
        add     a,a
        add     a,a
        add     a,b
        add     a,a             ; tens * 10
        ld      b,a
        ld      a,(#26D3)
        and     #7F
        sub     "0"
        cp      10
        jr      nc,slb
        add     a,b
        cp      65
        jr      c,slb           ; accept 1.65..1.99, including 1.67

		ld	hl,(fnum)
		ld	(#5aa0),hl		;file number
		ld	sp,#57e2
;		jp	#d13			;load snap and JP back to nmi menu
		jp	#11DD			;start snap autoload, v kodu nmi navesti SA6


slb		ld	hl,txt_adr_edit_zone2
		ld	de,nmi_not_found_txt
                call    pts
                jp      snap_not_found

nmi_not_found_txt db "Unsupported NMI menu",0

; Local help shares CFG's disk reader and free bank-6 workspace.
; The distributed sara.hlp is assumed to fit, as requested by the user.
help_bank:
        ld      hl,help_name
        call    file_exist+3
        jr      nz,.missing
        call    load_init
        call    cfg_read_file.load_body
        ld      ix,flag1
        ld      (text_local_base),hl
        ld      (text_length),bc
        call    text_browse
        jr      .restore_ui
.missing ld     ix,flag1
        ld      hl,txt_adr_edit_zone2
        ld      de,help_missing
        call    pts
.restore_ui
        call    cls_4000
        call    print_screen_layout
        jp      print_title     ; directory is redrawn from fixed RAM after return
help_name db "sara.hlp  "
help_missing db "sara.hlp not found",0

        INCLUDE "text_viewer_bank.asm"

cfg_file_here:
cfg_capacity equ #FFFF-cfg_file_here  ; last byte reserved for zero terminator
        ASSERT cfg_capacity > 0
