; RAM 6: memory-only transfer, bounded ASCII viewer and history-free pagination.
; text_fill/text_receive temporarily unmap us and restore RAM 6 before RET.
text_viewer_bank_start:
text_viewer_control:
        ld      hl,0
        ld      (text_local_base),hl ; FTP uses the four remote data banks
        ld      a,1
        ld      hl,ftp_size
        ld      de,213
        call    send_ftp_command
        jp      c,.bad_size
        ld      de,213
        or      a
        sbc     hl,de
        jp      nz,.bad_size
        ld      bc,RX_buf+4
        call    ConvRStr32       ; HL=high, DE=low
        ld      a,h
        or      l
        ld      (text_truncated),a
        jr      z,.length
        ld      de,#FFFF
.length ld      (text_length),de
        or      a
        jr      z,.start
        ld      hl,txt_adr_edit_zone2
        ld      de,text_large
        call    pts
.start  ld      hl,0
        ld      (text_pos),hl
        call    set_20mhz
        ld      hl,(text_length)
        ld      a,h
        or      l
        jp      z,.view_empty
        call    enter_passive_mode
        call    passive_receive_on
        ld      hl,ftp_retr
        scf
        call    send_ftp_command_in_passive_mode
.read   call    KEYSCAN
        cp      "b"
        jp      z,.abort
        ld      hl,(text_length)
        ld      de,(text_pos)
        or      a
        sbc     hl,de
        jr      z,.complete
        push    hl              ; target bytes still missing
        call    data_available_in_module_file
        pop     de
        jr      z,.read_error
        or      a
        sbc     hl,de
        add     hl,de
        jr      c,.remaining
        ex      de,hl
.remaining                       ; HL=min(available, missing)
        ld      de,(text_pos)
        push    hl
        ld      h,d
        ld      l,e
        ld      a,h
        and     #3F
        ld      h,a
        ld      bc,#4000
        ex      de,hl
        ld      h,b
        ld      l,c
        or      a
        sbc     hl,de           ; bytes left in current bank
        pop     de
        or      a
        sbc     hl,de
        add     hl,de
        jr      c,.request
        ex      de,hl
.request ld     b,h
        ld      c,l
        ld      hl,(text_pos)
        call    text_receive
        jr      c,.read_error
        ld      hl,(text_pos)
        ld      de,(rest_chunk)
        add     hl,de
        ld      (text_pos),hl
        jr      .read
.complete ld    a,(text_truncated)
        or      a
        jr      nz,.cut
        ld      a,(transfer_flag)
        or      a
        jr      z,.close
        call    ask_for_reply_in_passive_mode
        ld      de,226
        or      a
        sbc     hl,de
        jr      nz,.read_error
.close  call    ftp_close_data
        call    passive_receive_off
        jr      .view_empty
.cut    call    ftp_abort_transfer ; truncated source: drain ABOR through NOOP barrier
.view_empty
        call    set_3_5mhz
        jp      text_browse
.read_error
        call    ftp_abort_transfer
        ld      hl,txt_adr_edit_zone2
        ld      de,text_failed
        jp      pts
.abort  jp      ftp_abort_transfer
.bad_size
        ld      hl,txt_adr_edit_zone2
        ld      de,text_no_file
        jp      pts

; Both scan-only and drawing use this exact page walker.
text_page:
        ld      hl,0
        ld      (text_coords),hl
.next   call    text_get
        ret     c
        cp      13
        jr      z,.cr
        cp      10
        jr      z,.newline
        cp      9
        jr      nz,.ascii
        ld      a,32            ; tab occupies one column
.ascii  cp      32
        jr      c,.dot
        cp      127
        jr      c,.char
.dot    ld      a,"."
.char   ld      c,a
        ld      hl,(text_coords)
        ld      a,l
        cp      text_columns
        jr      c,.emit
        ld      l,0
        inc     h
        ld      (text_coords),hl
        ld      a,h
        cp      text_rows
        jp      z,text_unget    ; next char belongs to next page
.emit   ld      a,(text_draw)
        or      a
        jr      z,.advance
        ld      a,c
        call    CHAR
.advance ld     hl,(text_coords)
        inc     l
        ld      (text_coords),hl
        jr      .next
.cr     call    text_get         ; consume CRLF together, even across banks/pages
        jr      c,.newline
        cp      10
        call    nz,text_unget
.newline ld     hl,(text_coords)
        ld      l,0
        inc     h
        ld      (text_coords),hl
        ld      a,h
        cp      text_rows
        ret     z
        jr      .next

text_get:
        ld      hl,(text_pos)
        ld      de,(text_length)
        or      a
        sbc     hl,de
        jr      nc,.eof
        add     hl,de
        ld      de,(text_local_base)
        ld      a,d
        or      e
        jr      z,.remote
        push    hl
        add     hl,de
        ld      a,(hl)          ; local help is already in this program bank
        pop     hl
        jr      .advance
.remote
        ld      de,(text_cache_page) ; D=logical high byte, E=0 if valid
        ld      a,e
        or      a
        jr      nz,.fill
        ld      a,d
        cp      h
        jr      z,.cached
.fill   ld      d,h
        ld      e,0
        ld      (text_cache_page),de
        call    text_fill
.cached push    hl
        ld      e,l
        ld      d,0
        ld      hl,INPBUFF
        add     hl,de
        ld      a,(hl)
        pop     hl
.advance
        inc     hl
        ld      (text_pos),hl
        or      a
        ret
.eof    scf
        ret
text_unget:
        ld      hl,(text_pos)
        dec     hl
        ld      (text_pos),hl
        ret

text_browse:
        ld      hl,#FFFF
        ld      (text_cache_page),hl ; previous file/name may still be in INPBUFF
        ld      hl,0
        ld      (text_start),hl
.draw   call    set_20mhz
        ld      hl,(text_start)
        ld      (text_pos),hl
        call    cls_4000
        ld      a,1
        ld      (text_draw),a
        call    text_page
        ld      hl,(text_pos)
        ld      (text_next),hl
        call    set_3_5mhz       ; keyboard debounce runs at the usual speed
.key    call    KEYSCAN
        cp      1               ; BREAK
        jr      z,.exit
        cp      9               ; right: next screen
        jr      z,.down
        cp      8               ; left: previous screen
        jr      nz,.key
        ld      hl,(text_start)
        ld      a,h
        or      l
        jr      z,.key
        call    set_20mhz       ; accelerate history-free backward rescan
        xor     a
        ld      (text_draw),a
        ld      hl,0
        ld      (text_pos),hl
.scan   ld      hl,(text_pos)
        ld      (text_candidate),hl
        call    text_page
        ld      hl,(text_pos)
        ld      de,(text_start)
        or      a
        sbc     hl,de
        jr      c,.scan
        ld      hl,(text_candidate)
        jr      .select
.down   ld      hl,(text_next)
        ld      de,(text_length)
        or      a
        sbc     hl,de
        jr      nc,.key
        add     hl,de
.select ld      (text_start),hl
        jr      .draw
.exit   call    inkey            ; do not let a held BREAK navigate to parent
        or      a
        jr      nz,.exit
        ret

        IFDEF hgfx64x24
text_columns equ max_chars
text_rows equ max_lines
        ELSE
text_columns equ 64
text_rows equ 24
        ENDIF
text_large db "File >65535 B. Showing first 65535 bytes.",0
text_failed db "Text download failed",0
text_no_file db "Not a readable file",0
text_length dw 0
text_pos dw 0
text_coords dw 0
text_start dw 0
text_next dw 0
text_candidate dw 0
text_draw db 0
text_truncated db 0
text_cache_page dw #FFFF
text_local_base dw 0
text_viewer_bank_len equ $-text_viewer_bank_start
