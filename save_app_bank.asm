; Block headers, BASIC loader and sequencing stay in bank 6. SA-BYTES takes
; A=flag, DE=length, IX=source; all six blocks make one standalone Sarah TAP.
save_app_bank:
        IFNDEF bs_dos
        xor     a
        ld      (INPBUFF),a
        ld      a,(DefaultDrive)
        ld      ix,save_app_filename
        ld      b,3             ; same overwrite mode/name as the old V action
        rst     8
        db      M_TAPEOUT
        ret     c
        ld      a,1
        ld      (INPBUFF),a
        ENDIF
        ld      ix,save_basic_header
        call    save_app_header
        jr      nc,.failed
        ld      ix,saved_loader.loader_start
        ld      de,saved_loader.loader_line_end-saved_loader.loader_start
        call    save_app_data
        jr      nc,.failed
        ld      ix,save_main_header
        call    save_app_header
        jr      nc,.failed
        ld      ix,start_address
        ld      de,#6000
        call    save_app_data
        jr      nc,.failed
        ld      ix,save_bank_header
        call    save_app_header
        jr      nc,.failed
        ld      ix,#C000
        ld      de,program_page_len
        call    save_app_data
        ccf                     ; ROM returns C=success; controller returns C=error
        ret
.failed scf
        ret
save_app_header:
        xor     a
        ld      de,17
        jp      save_app_rom_block
save_app_data:
        ld      a,#FF
        jp      save_app_rom_block

        IFNDEF bs_dos
save_app_close_bank:
        ld      a,(INPBUFF)
        or      a
        ret     z
        xor     a
        ld      (INPBUFF),a
        ld      a,(DefaultDrive)
        ld      ix,save_app_filename
        ld      b,1
        rst     8
        db      M_TAPEOUT
        ret
save_app_filename db "SAR12SAV.tap",0
        ENDIF

save_basic_header db 0,"SARA      "
        dw saved_loader.loader_line_end-saved_loader.loader_start,10
        dw saved_loader.loader_line_end-saved_loader.loader_start
save_main_header db 3,"SARA1     "
        dw #6000,start_address,#8000
save_bank_header db 3,"SARA2     "
        dw program_page_len,#C000,#8000
        MODULE saved_loader
        INCLUDE "sara_loader_data.asm"
        ENDMODULE
