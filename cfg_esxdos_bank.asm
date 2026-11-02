; Local CFG/help reader. Only the common parser/browser depends on its result.
; Never use the fatal disk-error handler during startup or leak an open handle.
; HL=ASCIIZ local name. NC: flen/blen filled; C: missing/stat failure.
cfg_esx_open:
        push    hl
        ld      a,#FF
        ld      (cfg_esx_handle),a
        xor     a
        rst     8
        db      M_GETSETDRV
        pop     ix
        ret     c
        ld      (DefaultDrive),a
        ld      b,FA_READ
        rst     8
        db      F_OPEN
        ret     c
        ld      (cfg_esx_handle),a
        ld      ix,_11byte_buffer
        rst     8
        db      F_FSTAT
        jr      c,.bad
        ld      hl,_11byte_buffer+7
        ld      de,blen
        ld      bc,4
        ldir
        ld      hl,(blen)
        ld      (flen),hl
        or      a
        ret
.bad:   call    cfg_esx_close
        scf
        ret

; Exact-byte read into the free bank-6 workspace; close on every return path.
cfg_esx_read:
        ld      a,(cfg_esx_handle)
        ld      ix,cfg_file_here
        ld      bc,(flen)
        rst     8
        db      F_READ
        jr      c,.bad
        ld      hl,(flen)
        or      a
        sbc     hl,bc
        jr      nz,.bad
        call    cfg_esx_close
        ret     c
        ld      hl,cfg_file_here
        ld      bc,(flen)
        or      a
        ret
.bad:   call    cfg_esx_close
        scf
        ret
cfg_esx_close:
        ld      a,(cfg_esx_handle)
        cp      #FF
        jr      z,.closed
        push    af
        ld      a,#FF
        ld      (cfg_esx_handle),a
        pop     af
        rst     8
        db      F_CLOSE
        ret
.closed or      a
        ret
cfg_esx_handle db #FF
