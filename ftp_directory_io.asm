; Prijem FTP nezavisly na mezerach mezi bajty UART. Bez zmeny BIOSu.
; Chyba 48 = timeout UART/AT odpovedi, 49 = neplatne ramovani/odpoved.

; Vstup: zadny. Vystup: A=bajt, NZ; timeout jde do error_handler (48).
; Meni: AF. Zachovava BC, DE, HL, IX, IY i alternativni registry.
ftp_read_byte
        push bc
        push de
        push hl
        ld bc,#783B
        ld a,#30
        out (c),a
        inc b
        in a,(c)
        and 3
        ld e,a
        ld d,0
        ld hl,ftp_timeout_scales
        add hl,de
        ld e,(hl)
        pop hl
        ld bc,0
.wait   scf
        call rece_byte
        jr nz,.ready
        dec bc
        ld a,b
        or c
        jr nz,.wait
        dec de
        ld a,d
        or e
        jr nz,.wait
        ld c,48
        jp error_handler
.ready  pop de
        pop bc
        ret
; Comparable polling time at 3.5 / 7 / 14 / 20 MHz (not a hardware clock).
ftp_timeout_scales db 8,16,32,46

; HL=vzor, porovnani se zacatkem RX_buf. Z=shoda, DE=za prefixem.
; Meni AF, DE, HL, zachovava BC.
ftp_line_prefix
        ld de,RX_buf
.next   ld a,(hl)
        or a
        ret z
        ld a,(de)
        cp (hl)
        ret nz
        inc hl
        inc de
        jr .next

; Docte konecnou odpoved AT. NC=OK, C=ERROR; ostatni radky preskoci.
; Max. 64 radku; zadne mazani RX fronty. Meni AF, BC, DE, HL.
ftp_wait_terminal
        ld a,AT_OK
        jp at_wait_event

ftp_frame_error
        ld c,49
        jp error_handler

; BC=unread binary bytes after a short BIOS block read. Never parse their OK
; substrings as AT messages. The normal per-byte timeout remains bounded.
ftp_discard_payload
        ld a,b
        or c
        jr z,.terminal
.byte   call ftp_read_byte
        dec bc
        ld a,b
        or c
        jr nz,.byte
.terminal call ftp_wait_terminal
        jp c,ftp_frame_error
        ret

; Download abort stays passive until the data socket has been closed. Never
; enter the legacy upload reader or release pending data into active UART mode.
ftp_abort_download
        call set_3_5mhz
        ld hl,ftp_abort_wire
        call ftp_send_six
        ld bc,#0400               ;up to 3 transfer/ABOR replies, then NOOP 200
.reply  push bc
        call ask_for_reply_in_passive_mode
        pop bc
        ld de,200
        or a
        sbc hl,de
        jr z,.barrier
        add hl,de
        ld de,426
        or a
        sbc hl,de
        jr z,.interrupted
        add hl,de
        ld de,225
        or a
        sbc hl,de
        jr z,.complete
        dec hl                    ;226 is also a successful completion
        ld a,h
        or l
        jr nz,.error
.complete set 0,c
        bit 1,c
        jr nz,.next
        push bc
        ld hl,ftp_noop_wire
        call ftp_send_six          ;send only after the first final ABOR reply
        pop bc
        set 1,c
        jr .next
.interrupted res 0,c
.next   djnz .reply
.error  ld c,16
        jp error_handler
.barrier ld a,c
        cp 3
        jr nz,.error              ;require final 225/226 and our NOOP marker
        call ftp_close_data
        call passive_receive_off
        jp ful_abort_done         ;existing display/refresh and stack unwinding

; Close channel 1 and consume its actual terminal, not a preceding UNLINK notice.
; A rejected close is harmless only when no data remains. Never ignore busy.
ftp_close_data
        ld hl,at_cipclose1
        call at_send_ok
        ret nc
        cp AT_ERROR
        jr nz,.close_error        ;busy/SEND FAIL cannot mean already closed
        call ftp_query_lengths
        ld a,h
        or l
        jr nz,.close_error        ;ERROR is tolerable only with no pending data
        ret
.close_error ld c,43
        jp error_handler

; Both ABOR and NOOP are six bytes including CR/LF. HL=wire command.
ftp_send_six
        push hl
        ld hl,ftp_send_six_request
        call send_string
        jp nz,cr_err
        ld a,AT_PROMPT
        call at_wait_event
        jp c,ftp_frame_error
        pop hl
        call send_string
        jp nz,cr_err
        call at_wait_send
        jp c,ftp_frame_error
        ret
ftp_send_six_request db "AT+CIPSEND=0,6",13,10,0
ftp_abort_wire db "ABOR",13,10,0
ftp_noop_wire db "NOOP",13,10,0

; Mezery mezi prazdnymi dotazy. Meni AF, DE; BC zachovano.
ftp_poll_delay
        ld de,0
.wait   dec de
        ld a,d
        or e
        jr nz,.wait
        ret

; Dotaz na DELKY obou kanalu, vcetne koncoveho OK.
; Vystup HL=kanal 1 (data), DE=kanal 0 (FTP odpovedi). Meni AF, BC, DE, HL.
ftp_query_lengths
        ld hl,at_ciprecvlen
        call send_string
        jp nz,cr_err
        ld b,64
.line   push bc
        call at_next_event
        cp AT_IPD
        jr nz,.check
        call at_buffer_ipd
        jr .again
.check  cp AT_ERROR
        jp z,ftp_frame_error
        cp AT_BUSY
        jp z,ftp_frame_error
        ld hl,ftp_length_prefix
        call ftp_line_prefix
        jr z,.parse
.again  pop bc
        djnz .line
        jp ftp_frame_error
.parse  pop bc
        call at_parse_decimal
        ld a,(de)
        cp ","
        jp nz,ftp_frame_error
        push hl
        inc de
        ld a,(de)
        cp ","
        ld hl,0
        jr z,.empty
        call at_parse_decimal
.empty  ld a,(de)
        cp ","
        jp nz,ftp_frame_error
        push hl
        call ftp_wait_terminal
        jp c,ftp_frame_error
        pop hl
        pop de
        ret
ftp_length_prefix db "+CIPRECVLEN:",0

ftp_active_reply
        ld hl,ftp_active_byte
        ld (ftp_reply_byte+1),hl
        call ftp_read_reply
        push hl
        ld hl,TX_buf
        ld de,RX_buf
        ld bc,128
        ldir
        pop hl
        ret

ftp_read_length
        ld hl,block_asci
        ld b,5
.next   call ftp_read_byte
        cp ":"
        jr z,.done
        cp "0"
        jp c,ftp_frame_error
        cp "9"+1
        jp nc,ftp_frame_error
        ld (hl),a
        inc hl
        djnz .next
        call ftp_read_byte
        cp ":"
        jp nz,ftp_frame_error
.done   ld (hl),0
        ld a,b
        cp 5
        jp z,ftp_frame_error
        ld de,block_asci
        jp at_parse_decimal

; Byte ridiciho FTP streamu v pasivnim rezimu. AT obalky se nectou jako data.
; Buffer prezije mezi 150 a 226, i kdyz oba kody prijdou v jednom bloku.
; Vystup A=bajt, ostatni hlavni registry zachovany krome F.
ftp_control_byte
        push bc
        push de
        push hl
        ld a,(ftp_control_left)
        or a
        jr nz,.byte
        ld b,128
.poll   push bc
        call ftp_query_lengths
        ld a,(ftp_control_left)
        or a
        jr nz,.queued_query
        ld a,d
        or e
        pop bc
        jr nz,.fetch
        call ftp_poll_delay     ; nevycerpat pokusy behem kratke mezery na siti
        djnz .poll
        ld c,48
        jp error_handler
.queued_query pop bc
        jr .byte
.fetch  push bc
        ld hl,ftp_control_request
        call send_string
        jp nz,cr_err
        call at_wait_data
        pop bc
        ld a,h
        or a
        jp nz,ftp_frame_error
        ld a,l
        or a
        jr z,.empty_fetch
        cp 129
        jp nc,ftp_frame_error
        ld (ftp_control_left),a
        ld b,a
        ld hl,ftp_control_buffer
        ld (ftp_control_next),hl
.data   call ftp_read_byte
        ld (hl),a
        inc hl
        djnz .data
        call ftp_wait_terminal
        jp c,ftp_frame_error
        jr .byte
.empty_fetch push bc
        call ftp_wait_terminal
        pop bc
        jp c,ftp_frame_error
        call ftp_poll_delay
        djnz .poll
        ld c,48
        jp error_handler
.byte   ld hl,(ftp_control_next)
        ld a,(hl)
        inc hl
        ld (ftp_control_next),hl
        ld hl,ftp_control_left
        dec (hl)
        jr nz,.return
        ld hl,ftp_control_buffer
        ld (ftp_control_next),hl
.return pop hl
        pop de
        pop bc
        ret
ftp_control_request db "AT+CIPRECVDATA=0,128",13,10,0
ftp_control_left db 0
ftp_control_next dw ftp_control_buffer
ftp_control_buffer ds 128
; TX_buf je po odeslani LIST/RETR volny. Dotazy nize jej nepouzivaji.
; Sdileni usetri 128 B, RX_buf mezitim slouzi na AT odpovedi.
ftp_reply_line equ TX_buf
dr_first_byte db 0
dr_reply_pending db 0

; Docte OK po predchozim bloku adresare, az po presne rest_chunk bajtech.
; Volano s prohozenou hlavni/alternativni sadou v dr_get_data.
dr_finish_chunk
        ld a,(dr_reply_pending)
        or a
        ret z
        xor a
        ld (dr_reply_pending),a
        call ftp_wait_terminal
        jp c,ftp_frame_error
        ret
