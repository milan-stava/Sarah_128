; Fixed-RAM bridges. Everything else, including pagination, lives in RAM 6.
; No file creation, writes or deletion are used by this viewer.
text_viewer_fixed_start:
view_as_text:
        bit     5,(ix+0)
        jr      z,.ignore
        call    send_type_command_i ; destroys INPBUFF: prepare filename AFTER it
.ready:                         ; ENTER has already sent TYPE I
        ld      a,(PAGE128_STATE)
        push    af
        call    get_item_name
        dec     a
        cp      2               ; only LIST file or NLST unknown type
        jr      nc,.restore
        ld      a,b
        or      a
        jr      nz,.restore     ; INPBUFF has 256 bytes including terminator
        ld      a,c
        or      a
        jr      z,.restore
        push    hl
        push    bc
        call    clear_inp_buf
        pop     bc
        pop     hl
        ld      de,INPBUFF
        call    DIR128_COPY_NAME_TO_DE
        xor     a
        ld      (de),a
        call    save_dir_position_snapshot
        ld      a,program_page
        call    PAGE128
        call    text_viewer_control
        pop     af
        call    PAGE128
        call    print_whole_screen
        bit     0,(ix+1)
        jr      z,.reload
        call    resume_directory_screen
        jr      .ignore
.reload call    directory_retrieve
.ignore xor     a
        ret
.restore pop    af
        call    PAGE128
        jr      .ignore

; Logical HL in 0..#FFFE -> physical HL, map one of four data banks.
; DE and AF changed. Bank 4 alone leaves the entire FTP directory intact.
text_map:
        push    hl
        ld      a,h
        rlca
        rlca
        and     3
        ld      e,a
        ld      d,0
        ld      hl,text_pages
        add     hl,de
        ld      a,(hl)
        call    PAGE128
        pop     hl
        ld      a,h
        and     #3F
        or      #C0
        ld      h,a
        ret
text_pages: db dwnld_pag,0,1,3

; Refill an aligned 256-byte window in the existing INPBUFF after FTP is done.
; HL=logical offset (preserved). The aligned window never crosses a RAM bank.
text_fill:
        push    hl
        ld      l,0
        call    text_map
        ld      de,INPBUFF
        ld      bc,256
        ldir
        ld      a,program_page
        call    PAGE128
        pop     hl
        ret

; HL=logical destination, BC=request (bounded by remaining bank/file space).
; OUT C=failed, NC=received rest_chunk bytes; always return with bank 6.
text_receive:
        push    hl
        call    ask_for_data_in_passive_mode
        pop     hl
        ld      a,(rest_chunk)
        ld      de,(rest_chunk)
        or      d
        jr      z,.empty
        ld      a,h
        and     #C0
        jr      z,.map
        res     0,(ix+1)         ; invalidate BEFORE overwriting any directory RAM
.map    call    text_map
        ld      bc,(rest_chunk)
        ld      de,#FFFF
        call    rece_block
        jr      c,.terminal
        call    ftp_discard_payload
.failed scf
        jr      .return
.empty  call    ftp_wait_terminal ; even a zero-byte modem frame has a terminal
        jr      .failed
.terminal call  ftp_wait_terminal
.return push    af
        ld      a,program_page
        call    PAGE128
        pop     af
        ret
text_viewer_fixed_len equ $-text_viewer_fixed_start
