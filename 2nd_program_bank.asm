; Bank 6: optional sara.cfg, fixed profile order as documented in sara.cfg.txt.
; load_cfg: bank 6 must already be mapped. NC = applied,
; C = absent, aborted, too large, no default or invalid profile (settings kept).
; Uses GETSUB body length (32-bit), not the tape header length. No load_init:
; the shared disk buffer is not initialized yet at this point during startup.

load_cfg:
        ld      hl,cfg_name
	call	file_exist+3
	ret	nz			;soubor cfg neexistuje, vrat se a pokracuj s hodnotami danymi programem

	call	load_init

	ld	ix,cfg_file_here
	push	ix
	call	load_file+4		;nahraj cfg soubor

	ld	bc,(flen)
	pop	hl
	add	hl,bc
;	inc	hl
	ld	(hl),0			;uzavri konfigurak nulou

	sbc	hl,bc			;vrat HL na puvodni hodnotu
;	dec	hl


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

cfg_file_here:
cfg_capacity equ #FFFF-cfg_file_here  ; last byte reserved for zero terminator
        ASSERT cfg_capacity > 0
