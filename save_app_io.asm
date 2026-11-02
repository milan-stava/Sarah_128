; Fixed-RAM context/ROM bridge. Save a complete loader + main + bank 6.
; ERR_SP catches ROM BREAK/error even when SA-BYTES cannot return normally.
save_app:
        ld      a,(PAGE128_STATE)
        push    af
        ld      a,(flag_dir)
        push    af
        res     0,(ix+1)        ; saved image must never claim cached directory RAM
        ld      hl,(#5C3D)
        push    hl
        ld      hl,save_app_rom_error
        push    hl
        ld      (#5C3D),sp
        call    set_3_5mhz
        ld      a,program_page
        call    PAGE128
        call    save_app_bank
        ld      a,0
        jr      nc,.status
        inc     a
.status ld      (INPBUFF+1),a
        pop     hl              ; discard installed error return
        jr      save_app_finish
save_app_rom_error:
        ld      a,1
        ld      (INPBUFF+1),a
save_app_finish:
        di
        IFNDEF bs_dos
        ld      a,program_page
        call    PAGE128
        call    save_app_close_bank
        jr      nc,.closed
        ld      a,1
        ld      (INPBUFF+1),a
.closed:
        ENDIF
        pop     hl
        ld      (#5C3D),hl
        ld      a,#FF
        ld      (#5C3A),a       ; no pending BASIC error after the trapped save
        pop     af
        ld      (flag_dir),a
        pop     af
        call    PAGE128
        ld      ix,flag1
        ld      iy,#5C3A
        ld      a,(INPBUFF+1)
        or      a
        ret     z
        ld      c,15
        call    display_error
        xor     a
        ret

save_app_rom_block:
        ld      iy,#5C3A
        call    #04C2
        di
        ret
