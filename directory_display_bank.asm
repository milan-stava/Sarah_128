; Directory display and horizontal scrolling, executed in program bank 6.
; Banked directory reads use fixed-RAM bridges and always return in bank 6.
; Keep LIST metadata and original filenames intact; only the display is split.
dir_display_item:
        ld      hl,(cur_lin_prn_adr)
        ld      (dir_display_screen),hl
        call    dir_display_prepare
        jp      print_item_roll

dir_display_prepare:
        xor     a
        ld      (dir_display_rolling),a
        ld      hl,0
        ld      (roll_pos),hl
        ld      a,line_length
        ld      (dir_display_width),a
        ld      hl,#2020
        ld      (dir_display_ext),hl
        ld      a," "
        ld      (dir_display_ext+2),a
        call    dir_display_info
        ld      (dir_display_type),a
        ld      (dir_display_name_len),bc

        ; Physical item + page-table companion -> logical directory offset.
        ld      hl,(cur_item_addr_page)
        ld      de,ftp_dir_page+1
        or      a
        sbc     hl,de
        ld      a,l
        rrca
        rrca
        ld      e,a
        ld      hl,(cur_item_addr)
        ld      a,h
        and     #3F
        or      e
        ld      h,a
        push    hl
        ld      b,2
        call    dir_display_read
        pop     hl
        inc     hl
        inc     hl
        inc     hl
        ld      (dir_display_start),hl
        ld      hl,(dir_print_buf)
        ld      a,h
        or      l
        jr      z,.length_ready
        dec     hl              ; stored length includes the attribute byte
.length_ready:
        ld      (dir_display_length),hl
        ld      a,(dir_display_type)
        dec     a
        cp      2               ; only known files and NLST unknown items
        ret     nc              ; directories, full LIST and malformed rows
        ld      a,h
        or      a
        ld      b,4
        jr      nz,.tail
        ld      a,l
        cp      4
        jr      nc,.tail
        or      a
        ret     z
        ld      b,a
.tail:
        ld      e,b
        ld      d,0
        or      a
        sbc     hl,de
        ld      de,(dir_display_start)
        add     hl,de
        push    bc
        call    dir_display_read
        pop     bc
        ld      c,b
        ld      e,b
        ld      d,0
        ld      hl,dir_print_buf-1
        add     hl,de
        ld      b,0             ; suffix length, scanning from the last byte
.scan:
        ld      a,(hl)
        cp      "."
        jr      z,.dot
        cp      " "+1
        ret     c               ; trailing whitespace/control is not a suffix
        inc     b
        dec     hl
        dec     c
        jr      nz,.scan
        ret                     ; no final dot within the last four bytes
.dot:
        ld      a,b
        or      a
        ret     z               ; trailing dot
        ld      e,b
        ld      d,0
        inc     de              ; dot + suffix
        push    hl
        ld      hl,(dir_display_name_len)
        or      a
        sbc     hl,de
        pop     hl
        ret     c
        ret     z               ; .cfg is a dotfile, not an empty basename
        push    hl
        ld      hl,(dir_display_length)
        or      a
        sbc     hl,de
        ld      (dir_display_length),hl
        pop     hl
        inc     hl
        ld      c,b
        ld      b,0
        ld      de,dir_display_ext
        ldir                    ; one/two-byte suffixes keep trailing spaces
        ld      a,line_length-4 ; blank separator + aligned three-column suffix
        ld      (dir_display_width),a
        ret

dir_display_roll:
        call    dir_display_prepare
        ld      a,(dir_display_width)
        ld      e,a
        ld      d,0
        ld      hl,(dir_display_length)
        or      a
        sbc     hl,de
        jr      c,roll_item_no_move
        jr      z,roll_item_no_move
        ld      (roll_max),hl
        ld      a,(ix+21)
        ld      hl,txt_adr_mezera
.row:   inc     h
        dec     a
        jr      nz,.row
        ld      (dir_display_screen),hl
        ld      a,1
        ld      (dir_display_rolling),a
        call    roll_item_inc   ; preserve the existing initial X movement
.key:   call    KEYSCAN
        cp      "z"
        call    z,roll_item_dec
        cp      "x"
        call    z,roll_item_inc
        or      a
        jr      z,.key
        ret                     ; low bridge repaints and dispatches this key

roll_item_inc:
        ld      hl,(roll_pos)
        ld      de,(roll_max)
        or      a
        sbc     hl,de
        jr      z,roll_item_no_move
        add     hl,de
        inc     hl
        jr      dir_display_move
roll_item_dec:
        ld      hl,(roll_pos)
        ld      a,h
        or      l
        jr      z,roll_item_no_move
        dec     hl
dir_display_move:
        ld      (roll_pos),hl
        jr      print_item_roll
roll_item_no_move:
        xor     a
        ret

; One formatter for the initial row and all scrolling positions. Copy only
; the visible bytes; a four-byte tail read suffices even for very long names.
print_item_roll:
        ld      hl,dir_print_buf
        ld      de,dir_print_buf+1
        ld      bc,line_length-1
        ld      (hl)," "
        ldir
        xor     a
        ld      (de),a
        ld      hl,(dir_display_length)
        ld      de,(roll_pos)
        or      a
        sbc     hl,de
        ld      a,(dir_display_width)
        ld      c,a
        ld      a,h
        or      a
        jr      nz,.long
        ld      a,l
        cp      c
        jr      c,.fits
        jr      z,.fits
.long:  ld      b,c
        ld      a,1
        jr      .copy
.fits:  ld      b,l
        xor     a
.copy:  ld      (dir_display_more),a
        ld      a,b
        or      a
        jr      z,.decorate
        ld      hl,(dir_display_start)
        ld      de,(roll_pos)
        add     hl,de
        call    dir_display_read
.decorate:
        ld      a,(dir_display_width)
        cp      line_length
        jr      z,.unsplit
        ld      hl,dir_display_ext
        ld      de,dir_print_buf+line_length-3
        ld      bc,3
        ldir
        jr      .dots
.unsplit:
        ld      a,(dir_display_rolling)
        or      a
        jr      nz,.print       ; old whole-name scrolling has no added dots
.dots:  ld      a,(dir_display_more)
        or      a
        jr      z,.print
        ld      a,(dir_display_width)
        ld      e,a
        ld      d,0
        ld      hl,dir_print_buf-2
        add     hl,de
        ld      (hl),"."
        inc     hl
        ld      (hl),"."
.print: ld      hl,(dir_display_screen)
        ld      de,dir_print_buf
        call    PRINTHL
        xor     a
        ret

dir_display_screen   dw 0
dir_display_start    dw 0
dir_display_length   dw 0
dir_display_name_len dw 0
roll_pos             dw 0
roll_max             dw 0
dir_display_width    db line_length
dir_display_type     db 0
dir_display_rolling  db 0
dir_display_more     db 0
dir_display_ext      db "   "
