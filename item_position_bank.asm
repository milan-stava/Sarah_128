; Track only committed cursor positions. Temporary PRINT/FIND/mark traversal
; never updates this cache. Adjacent moves traverse one record, pages at most
; one screen; FIND/restoration can require a longer walk once.
; The cache is reset before every directory replacement, not on screen redraw.
item_position_reset_bank:
        ld      hl,0
        ld      (item_position_count),hl
        ld      (item_counter),hl
        ret

item_position_bank:
        bit     0,(ix+1)
        jr      z,.empty
        ld      hl,(item_position_count)
        ld      a,h
        or      l
        jr      nz,.cached
        ld      hl,ftp_dir_start
        ld      (item_position_pointer),hl
        ld      hl,ftp_dir_page+1
        ld      (item_position_pointer+2),hl
        ld      hl,1
        ld      (item_position_count),hl
.cached ld      hl,item_position_pointer
        ld      de,dir_search_addr
        ld      bc,4
        ldir
.compare:
        ld      hl,(dir_search_page)
        ld      de,(cur_item_addr_page)
        or      a
        sbc     hl,de
        jr      nz,.step
        ld      hl,(dir_search_addr)
        ld      de,(cur_item_addr)
        or      a
        sbc     hl,de
        jr      z,.selected
.step   ld      hl,(item_position_count)
        jr      c,.forward
        dec     hl
        jr      .move
.forward inc    hl
.move   push    hl              ; 16-bit INC/DEC keep the direction carry
        call    item_position_step
        pop     hl
        jr      z,.empty        ; inconsistent pointer: never loop at boundary
        ld      (item_position_count),hl
        jr      .compare
.selected:
        ld      hl,dir_search_addr
        ld      de,item_position_pointer
        ld      bc,4
        ldir
        ld      hl,(item_position_count)
        jr      .number
.empty  call    item_position_reset_bank
.number ld      (item_counter),hl
        ; Clear all five columns on every redraw (100 -> 99, etc.).
        push    hl
        ld      hl,#2020
        ld      (item_position_text),hl
        ld      (item_position_text+2),hl
        ld      a,' '
        ld      (item_position_text+4),a
        pop     hl
        ld      de,block_asci
        call    HL2ASCII
        ld      hl,block_asci
        ex      de,hl
        or      a
        sbc     hl,de           ; length of decimal text
        ld      c,l
        ld      b,0
        ld      hl,item_position_text+5
        or      a
        sbc     hl,bc
        ex      de,hl
        ld      hl,block_asci
        ldir
        ld      hl,txt_adr_file+line_length-5
        ld      de,item_position_text
        jp      PRINTHL

item_position_pointer dw ftp_dir_start,ftp_dir_page+1
item_position_count dw 0
item_position_text db "     ",0

; OUT BC=1..65535, zero means cancelled/empty/invalid. Reuse CFG's checked
; decimal conversion instead of adding another parser below #C000.
jump_item_bank:
        ld      de,jump_item_prompt
        call    print_ez1
        ld      de,input_empty
        ld      c,5
        call    input_line_edit_limit
        jr      z,.cancel
        push    hl
        add     hl,bc
        ld      (hl),0          ; editor pads with spaces, CFG parser needs NUL
        pop     hl
        call    cfg_decimal
        jr      c,.cancel
        ex      de,hl           ; DE=requested ordinal, including synthetic '..'
        ld      hl,(item_file_count)
        bit     3,(ix+1)        ; current listing: NLST counts all real items
        jr      nz,.total
        ld      bc,(dir_counter) ; LIST counts files and directories separately
        add     hl,bc
.total  inc     hl              ; the synthetic parent is item 1
        or      a
        sbc     hl,de
        jr      c,.cancel       ; no jump for an ordinal outside the listing
        ex      de,hl
        jr      .finish
.cancel ld      hl,0
.finish push    hl
        call    clear_edit_zone
        pop     bc
        ret
jump_item_prompt db "Item number (1-65535): ",0
