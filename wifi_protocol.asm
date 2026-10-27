; Shared ESP-AT framing above the unchanged Wi-Fi BIOS.
; Firmware dialect retained: +CIPRECVDATA,<length>:<binary>.
; Events: 1 OK, 2 ERROR, 3 prompt, 4 SEND OK, 5 SEND FAIL,
;         6 busy, 7 active IPD header, 8 receive-data header, 0 other.
; Binary payload is never searched for AT result strings.
AT_OK equ 1
AT_ERROR equ 2
AT_PROMPT equ 3
AT_SEND_OK equ 4
AT_SEND_FAIL equ 5
AT_BUSY equ 6
AT_IPD equ 7
AT_DATA equ 8

; HL=AT command, NC=exact final OK. Sending failures keep the common handler.
at_send_ok
        call send_string
        jp nz,cr_err
        jp ftp_wait_terminal

; Baud discovery cannot use the fatal normal UART timeout. Each read has a
; short polling budget; the complete probe is bounded too. Only standalone OK
; is accepted. Echo and boot notices are skipped; IPD is never searched as text.
at_probe_byte
        push bc
        ld bc,8192
.wait   scf
        call rece_byte
        jr nz,.ready
        dec bc
        ld a,b
        or c
        jr nz,.wait
        pop bc
        scf
        ret
.ready  pop bc
        or a
        ret

at_probe_drain
        ld bc,4096
.next   scf
        call rece_byte
        jr z,.empty
        dec bc
        ld a,b
        or c
        jr nz,.next
        scf
        ret
.empty  or a
        ret

; Z/NC = OK, NZ/C = failure. A=ERROR/BUSY for explicit rejection, 0 otherwise.
at_probe_ok
        ld de,4096
.line   ld hl,RX_buf
        ld b,127
.byte   call at_probe_byte
        jr c,.failed
        ld c,a
        dec de
        ld a,d
        or e
        jr z,.failed
        ld a,c
        cp 13
        jr z,.byte
        cp 10
        jr z,.check
        ld (hl),a
        inc hl
        djnz .byte
        jr .failed
.check  ld (hl),0
        push de
        ld hl,at_ok_text
        call at_line_equal
        jr z,.ok
        ld hl,at_error_text
        call at_line_equal
        jr z,.error
        ld hl,at_busy_prefix
        call ftp_line_prefix
        jr z,.busy
        ld hl,at_ipd_prefix
        call ftp_line_prefix
        jr z,.binary
        ld hl,ciprecvdata
        call ftp_line_prefix
        jr z,.binary
        pop de
        jr .line
.ok     pop de
        xor a
        ret
.busy   ld a,AT_BUSY
        jr .reject
.error  ld a,AT_ERROR
.reject pop de
        or a
        scf
        ret
.binary pop de
.failed xor a
        cp 1
        ld a,0
        ret
at_busy_prefix db "busy ",0

at_next_event
        ld hl,RX_buf
        ld b,127
        ld de,4096                 ;bounded line, including discarded suffix
.byte   call ftp_read_byte
        dec de
        push af
        ld a,d
        or e
        jp z,ftp_frame_error
        pop af
        cp #A
        jr z,.line
        cp #D
        jr z,.byte
        ld c,a
        ld a,b
        cp 127
        ld a,c
        jr nz,.store
        cp " "                     ;also consumes the optional space after >
        jr z,.byte
        cp ">"
        jr z,.prompt
.store  ld c,a
        ld a,b
        or a
        ld a,c
        jr z,.byte
        ld (hl),a
        inc hl
        dec b
        ld (hl),0
        cp ":"
        jr nz,.byte
        push hl
        push bc
        push de
        ld hl,at_ipd_prefix
        call ftp_line_prefix
        jr z,.ipd
        ld hl,ciprecvdata
        call ftp_line_prefix
        jr z,.data
        pop de
        pop bc
        pop hl
        jr .byte
.ipd   call at_parse_channel
        ld (at_payload_channel),a
        call at_parse_decimal
        ld a,(de)
        cp ":"
        jp nz,ftp_frame_error
        ld (at_payload_left),hl
        pop de
        pop bc
        pop hl
        ld a,AT_IPD
        ret
.data   call at_parse_decimal
        ld a,(de)
        cp ":"
        jp nz,ftp_frame_error
        ld (at_data_length),hl
        pop de
        pop bc
        pop hl
        ld a,AT_DATA
        ret
.prompt ld a,AT_PROMPT
        ret
.line   ld (hl),0
        ld a,b
        cp 127
        jr nz,.classify
        xor a
        ret
.classify
        ;Exact strings: an OK inside a payload or larger token is not terminal.
        ld hl,at_result_table
.match  ld e,(hl)
        inc hl
        ld d,(hl)
        inc hl
        ld a,d
        or e
        jr z,.notice
        push hl
        ex de,hl
        call at_line_equal
        pop hl
        ld a,(hl)
        inc hl
        ret z
        jr .match
.notice ld hl,at_unlink_error
        call ftp_line_prefix
        jr nz,.socket_notice
.space  ld a,(de)
        cp " "
        jr nz,.unlink_result
        inc de
        jr .space
.unlink_result
        ld hl,at_error_text
.unlink_compare
        ld a,(de)
        cp (hl)
        jr nz,.socket_notice
        inc de
        inc hl
        or a
        jr nz,.unlink_compare
        ld a,AT_ERROR
        ret
.socket_notice call at_notice
        xor a
        ret

;HL=zero-terminated pattern. Exact comparison against RX_buf.
at_line_equal
        ld de,RX_buf
.next   ld a,(de)
        cp (hl)
        ret nz
        inc de
        inc hl
        or a
        jr nz,.next
        ret

;Update socket lifecycle independently of the command currently awaited.
at_notice
        ld hl,at_connect0
        call at_line_equal
        jr z,.open0
        ld hl,at_connect1
        call at_line_equal
        jr z,.open1
        ld hl,at_closed0
        call at_line_equal
        jr z,.close0
        ld hl,at_closed1
        call at_line_equal
        jr z,.close1
        ld hl,at_wifi_lost
        call at_line_equal
        ret nz
        ld a,3
        ld (at_closed),a
        res 5,(ix+0)
        ret
.open0 ld hl,at_closed
        res 0,(hl)
        ret
.open1 ld hl,at_closed
        res 1,(hl)
        ret
.close0 ld hl,at_closed
        set 0,(hl)
        res 5,(ix+0)
        ret
.close1 ld hl,at_closed
        set 1,(hl)
        ret

;DE=channel,comma,decimal. Returns A=channel, DE at first length digit.
at_parse_channel
        ld a,(de)
        sub "0"
        cp 5
        jp nc,ftp_frame_error
        push af
        inc de
        ld a,(de)
        cp ","
        jp nz,ftp_frame_error
        inc de
        pop af
        ret

;Checked unsigned decimal, at least one digit, no wraparound. DE at delimiter.
at_parse_decimal
        ld hl,0
        ld a,(de)
        cp "0"
        jp c,ftp_frame_error
        cp "9"+1
        jp nc,ftp_frame_error
.digit  ld a,(de)
        cp "0"
        ret c
        cp "9"+1
        ret nc
        sub "0"
        push af
        ld b,h
        ld c,l
        add hl,hl
        jp c,ftp_frame_error
        add hl,hl
        jp c,ftp_frame_error
        add hl,bc
        jp c,ftp_frame_error
        add hl,hl
        jp c,ftp_frame_error
        pop af
        add a,l
        ld l,a
        jr nc,.next
        inc h
        jp z,ftp_frame_error
.next   inc de
        jr .digit

;Wait for exactly one event type. Other socket traffic is retained, not flushed.
;busy is not success and never causes an automatic replay of a command.
at_wait_event
        ld (at_expected),a
        ld b,64
.next   push bc
        call at_next_event
        cp AT_IPD
        jr nz,.result
        call at_buffer_ipd
        xor a
.result ld c,a
        ld a,(at_expected)
        cp c
        jr z,.ok
        ld a,c
        cp AT_ERROR
        jr z,.error
        cp AT_SEND_FAIL
        jr z,.error
        cp AT_BUSY
        jr z,.error                 ;not accepted: return control to caller
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

at_wait_send
        ld a,AT_SEND_OK
        jp at_wait_event
at_wait_data
        ld a,AT_DATA
        call at_wait_event
        jp c,ftp_frame_error
        ld hl,(at_data_length)
        ret

;IPD received before an AT terminal: preserve control bytes in existing buffer.
;Capacity is checked; excess data is an explicit error, never memory corruption.
at_buffer_ipd
        ld a,(at_payload_channel)
        or a
        jp nz,ftp_frame_error
        ld hl,(at_payload_left)
        ld a,h
        or l
        ret z
        ex de,hl                   ;DE=payload count
        ld hl,(ftp_control_next)
        ld a,(ftp_control_left)
        ld c,a
        ld b,0
        add hl,bc
        ld (at_queue_end),hl
        add hl,de
        jp c,ftp_frame_error
        ld bc,ftp_control_buffer+128
        or a
        sbc hl,bc
        jr c,.copy
        ld a,h
        or l
        jp nz,ftp_frame_error
.copy   ld hl,(at_queue_end)
.byte   ld a,d
        or e
        jr z,.done
        call ftp_read_byte
        ld (hl),a
        inc hl
        ld a,(ftp_control_left)
        inc a
        ld (ftp_control_left),a
        dec de
        jr .byte
.done   ld hl,0
        ld (at_payload_left),hl
        ret

;One byte of the active FTP stream; payload count survives TCP packet splits.
ftp_active_byte
        push bc
        push de
        push hl
        ld a,(ftp_control_left)
        or a
        jr nz,.queued
        ld b,64
.again  ld hl,(at_payload_left)
        ld a,h
        or l
        jr nz,.payload
        push bc
        call at_next_event
        pop bc
        cp AT_IPD
        jr z,.channel
        cp AT_ERROR
        jp z,ftp_frame_error
        ld a,(at_closed)
        bit 0,a
        jp nz,ftp_frame_error
        djnz .again
        ld c,48
        jp error_handler
.channel ld a,(at_payload_channel)
        or a
        jp nz,ftp_frame_error
        jr .again
.payload dec hl
        ld (at_payload_left),hl
        call ftp_read_byte
        jr .return
.queued ld hl,(ftp_control_next)
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

;Common logical FTP reply reader (active/passive). TX_buf is free after send.
;Multiline xyz- replies finish only at xyz<space>. Long text is drained safely.
ftp_read_reply
        ld hl,0
        ld (ftp_multiline),hl
        ld b,64
.line   push bc
        ld hl,ftp_reply_line
        ld b,127
        ld de,4096
.byte   call ftp_reply_byte
        dec de
        push af
        ld a,d
        or e
        jp z,ftp_frame_error
        pop af
        ld c,a
        ld a,b
        or a
        ld a,c
        jr z,.discard
        ld (hl),a
        inc hl
        dec b
.discard cp #A
        jr nz,.byte
        ld (hl),0
        ld de,ftp_reply_line
        ld a,(de)
        cp "0"
        jr c,.intermediate
        cp "9"+1
        jr nc,.intermediate
        call at_parse_decimal
        push hl
        ld hl,ftp_reply_line+3
        or a
        sbc hl,de
        pop hl
        jp nz,ftp_frame_error
        ld a,(de)
        cp "-"
        jr nz,.last
        ld bc,(ftp_multiline)
        ld a,b
        or c
        jr nz,.continue
        ld (ftp_multiline),hl
        jr .continue
.intermediate
        ld hl,(ftp_multiline)
        ld a,h
        or l
        jp z,ftp_frame_error
        jr .continue
.last   cp " "
        jr nz,.continue
        push hl
        ld bc,(ftp_multiline)
        ld a,b
        or c
        jr z,.finish
        or a
        sbc hl,bc
        jr z,.finish
        pop hl
.continue pop bc
        djnz .line
        jp ftp_frame_error
.finish pop hl
        pop bc
        ret
ftp_reply_byte jp ftp_active_byte

at_result_table
        dw at_ok_text
        db AT_OK
        dw at_error_text
        db AT_ERROR
        dw at_send_ok_text
        db AT_SEND_OK
        dw at_send_fail_text
        db AT_SEND_FAIL
        dw at_busy_s
        db AT_BUSY
        dw at_busy_r
        db AT_BUSY
        dw at_busy_p
        db AT_BUSY
        dw 0
at_ok_text db "OK",0
at_error_text db "ERROR",0
at_send_ok_text db "SEND OK",0
at_send_fail_text db "SEND FAIL",0
at_busy_s db "busy s...",0
at_busy_r db "busy r...",0
at_busy_p db "busy p...",0
at_unlink_error db "UNLINK",0
at_ipd_prefix db "+IPD,",0
at_connect0 db "0,CONNECT",0
at_connect1 db "1,CONNECT",0
at_closed0 db "0,CLOSED",0
at_closed1 db "1,CLOSED",0
at_wifi_lost db "WIFI DISCONNECT",0
at_closed db 0
at_expected db 0
at_payload_channel db 0
at_payload_left dw 0
at_data_length dw 0
at_queue_end dw 0

; Called after error recovery drained the UART; no partial payload may survive.
at_reset_stream
        ld hl,0
        ld (at_payload_left),hl
        ld a,l
        ld (ftp_control_left),a
        ld hl,ftp_control_buffer
        ld (ftp_control_next),hl
        ret

; Collect STATUS and control-link description, through the exact final OK.
; TX_buf is scratch, RX_buf retains the old caller's aggregate-text interface.
at_status_response
        xor a
        ld (at_status_haslink),a
        ld hl,TX_buf
        ld (hl),0
        ld (at_status_next),hl
        ld b,64
.next   push bc
        call at_next_event
        cp AT_IPD
        jr nz,.result
        call at_buffer_ipd
        jr .again
.result cp AT_OK
        jr z,.ok
        cp AT_ERROR
        jr z,.error
        cp AT_BUSY
        jr z,.error
        ld hl,STATUS
        call ftp_line_prefix
        jr z,.append
        ld hl,at_status_link
        call ftp_line_prefix
        jr nz,.again
        ld a,1
        ld (at_status_haslink),a
.append ld hl,RX_buf
        ld de,(at_status_next)
.copy   ld a,(hl)
        or a
        jr z,.newline
        push hl
        ld hl,TX_buf+125
        or a
        sbc hl,de
        pop hl
        jr c,.error
        ld (de),a
        inc de
        inc hl
        jr .copy
.newline ld a,13
        ld (de),a
        inc de
        ld a,10
        ld (de),a
        inc de
        xor a
        ld (de),a
        ld (at_status_next),de
.again  pop bc
        djnz .next
        scf
        ret
.error  pop bc
        scf
        ret
.ok     pop bc
        ld hl,TX_buf
        ld de,RX_buf
        ld bc,128
        ldir
        ld hl,STATUS
        call ftp_line_prefix
        jr nz,.missing
        ld a,(de)
        cp "3"
        jr nz,.valid
        ld a,(at_status_haslink)
        or a
        jr z,.missing
.valid
        or a
        ret
.missing scf
        ret
at_status_link db "+CIPSTATUS:0,",0
at_status_next dw 0
at_status_haslink db 0
ftp_multiline dw 0
