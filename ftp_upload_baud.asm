; Keep ordinary traffic at its configured baud. Only an active upload uses2304000.
; Saved byte is cleared BEFORE restoring, so a failed change cannot retry forever.
ftp_upload_baud_begin:
        ld      a,(ix+7)        ; last verified startup/upload UART index
        ld      (ftp_upload_baud_saved),a
        ld      a,15            ; speed_table index2304000
        jp      ftp_upload_baud_change

ftp_upload_baud_restore:
        ld      a,(ftp_upload_baud_saved)
        cp      #FF
        ret     z               ; also used by common download cleanup
        push    af
        ld      a,#FF
        ld      (ftp_upload_baud_saved),a
        bit     6,(ix+0)
        jr      z,.unknown      ; never send AT at an unverified UART
        pop     af
        jr      ftp_upload_baud_change
.unknown pop    af
        ret

ftp_upload_baud_change:
        push    af
        call    find_out_speed  ; actual host UART: a previous partial change may have failed
        jr      nc,.known
        pop     af
        ld      c,32
        jp      error_handler
.known  pop     af
        push    af
        call    set_ud_speed_a  ; existing ESP change, host change, then AT verification
        pop     af
        ld      (ix+7),a
        xor     a
        ret

ftp_upload_baud_saved db #FF
