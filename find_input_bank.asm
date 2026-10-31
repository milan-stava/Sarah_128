; Bank 6 stays mapped while the fixed-RAM editor runs. Directory RAM is untouched.
; OUT: Z=cancel/empty, NZ=accepted; HL=INPBUFF, BC=length, IX preserved.
find_input_bank:
        ld      de,find_cache
        call    input_line_edit
        ret     z               ; BREAK/empty must not replace the previous query
        push    hl
        push    bc
        ldir                    ; DE still points to find_cache; BC is nonzero
        xor     a
        ld      (de),a          ; terminate at actual length, not editor column 63
        pop     bc
        pop     hl
        inc     a               ; NZ=accepted (the zero terminator set Z)
        ret

find_cache: defs 64,0            ; empty on startup, separate from CFG/help workspace
