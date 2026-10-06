; Prijem FTP nezavisly na mezerach mezi bajty UART. Bez zmeny BIOSu.
; Chyba 48 = timeout UART/AT odpovedi, 49 = neplatne ramovani/odpoved.

; Vstup: zadny. Vystup: A=bajt, NZ; timeout jde do error_handler (48).
; Meni: AF. Zachovava BC, DE, HL, IX, IY i alternativni registry.
ftp_read_byte
        push bc
        push de
        ld de,8
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

; Radek AT do RX_buf (max. 127 bajtu + nula). Dlouhy zbytek se docte.
; Meni AF, BC, HL; DE a alternativni registry zachovany.
ftp_read_line
        ld hl,RX_buf
        ld b,127
.next   call ftp_read_byte
        ld c,a
        ld a,b
        or a
        ld a,c
        jr z,.discard
        ld (hl),a
        inc hl
        dec b
.discard cp #A
        jr nz,.next
        ld (hl),0
        ret

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
        ld b,64
.next   push bc
        call ftp_read_line
        ld hl,ok
        call ftp_line_prefix
        jr z,.ok
        ld hl,RX_buf
        ld de,ftp_error_line
        ld a,127
        sub b                   ; hledat pouze ve skutecne prijatem radku
        ld c,a
        ld b,0
        call look_for_string     ; take starsi "UNLINK ... ERROR" po CIPCLOSE
        jr z,.error
        pop bc
        djnz .next
        ld c,48
        jp error_handler
.ok     pop bc
        or a
        ret
.error  pop bc
        scf
        ret
ftp_error_line db "ERROR",13,10,0

ftp_frame_error
        ld c,49
        jp error_handler

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
        call ftp_read_line
        ld hl,ftp_length_prefix
        call ftp_line_prefix
        pop bc
        jr z,.parse
        djnz .line
        jp ftp_frame_error
.parse  call ConvRStr16
        ld a,(de)
        cp ","
        jp nz,ftp_frame_error
        push hl
        inc de
        call ConvRStr16
        push hl
        call ftp_wait_terminal
        jp c,ftp_frame_error
        pop hl
        pop de
        ret
ftp_length_prefix db "+CIPRECVLEN:",0

; Aktivni ridici odpoved muze byt rozdelena mezi nekolik +IPD bloku.
; Cteme vsechny bajty a dokoncime radek, maximalne 127 B + nula.
; Meni AF, BC, DE, HL, BC'. Prilis dlouha odpoved = 49, nikoli prepis TX_buf.
ftp_active_reply
        ld de,RX_buf
        ld bc,127
.packet push bc
        push de
        call look_for_ipd
        jp c,error_handler
        or a
        jp nz,ftp_frame_error    ; ridici kanal musi byt 0
        pop de
        pop bc
.byte   ld a,h
        or l
        jr z,.end_packet
        ld a,b
        or c
        jp z,ftp_frame_error
        call ftp_read_byte
        ld (de),a
        inc de
        dec bc
        dec hl
        jr .byte
.end_packet
        ; Pozadujeme ukonceny radek, ne pouze docasny konec TCP paketu.
        dec de
        ld a,(de)
        inc de
        cp #A
        jr nz,.packet
        xor a
        ld (de),a
        ret

; Nacte desetinnou delku nasledovanou dvojteckou (max. 5 cislic).
; HL=delka. Meni AF, BC, DE, HL. Odpoved nesmi preteci block_asci.
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
        ld de,block_asci
        jp ConvRStr16

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
        ld a,d
        or e
        pop bc
        jr nz,.fetch
        call ftp_poll_delay     ; nevycerpat pokusy behem kratke mezery na siti
        djnz .poll
        ld c,48
        jp error_handler
.fetch  ld hl,ftp_control_request
        call send_string
        jp nz,cr_err
        ld hl,ciprecvdata
        call look_on_fly
        jp nz,ftp_frame_error
        call ftp_read_length
        ld a,h
        or a
        jp nz,ftp_frame_error
        ld a,l
        or a
        jp z,ftp_frame_error
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
.byte   ld hl,(ftp_control_next)
        ld a,(hl)
        inc hl
        ld (ftp_control_next),hl
        ld hl,ftp_control_left
        dec (hl)
        pop hl
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
