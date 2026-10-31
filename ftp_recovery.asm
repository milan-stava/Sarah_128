; Fixed-RAM recovery. One reconnect attempt per failure, never replay the upload.
; error_recovering: 0=normal, 1=plain-error cleanup, 2=reconnecting.
ftp_recover_session:
        ld      c,36            ; orphaned socket detected before NOOP/LIST
        jp      error_handler

ftp_recovery_begin:
        ld      a,2
        ld      (error_recovering),a
        push    bc
        call    wifi_unwait
        pop     bc
        bit     6,(ix+0)
        jp      z,ftp_recovery_failed ; never send AT at an unknown baud
        call    ftp_mark_disconnected
        call    at_reset_stream
        call    at_probe_drain   ; bounded discard of replies from the old session
        ld      hl,at_cipclose5  ; drop BOTH old data and control connections
        call    at_send_ok
        jr      nc,.closed
        cp      AT_ERROR
        ld      c,43
        jp      nz,ftp_recovery_failed
        ; ERROR may mean all sockets were already closed. Verify, never assume.
        ld      hl,cipstatus
        call    send_string
        ld      c,43
        jp      nz,ftp_recovery_failed
        call    at_status_response
        ld      c,43
        jp      c,ftp_recovery_failed
        ld      a,(at_status_haslink)
        ld      hl,at_status_data
        or      (hl)
        jp      nz,ftp_recovery_failed
.closed:
        call    at_probe_drain
        ld      c,49
        jp      c,ftp_recovery_failed
        call    at_reset_stream
        call    passive_receive_off
        ld      sp,basic_end-2  ; discard calls belonging to the failed operation
        ld      hl,ftp_recovery_done
        push    hl
        jp      auto_login      ; configured host/user/password; fresh listing on success

ftp_recovery_done:
        xor     a
        ld      (error_recovering),a
        jp      key_loop

ftp_recovery_failed:
        push    bc
        call    ftp_mark_disconnected
        pop     bc
        call    display_error   ; one final error, then keyboard; no recursive reconnect
        jp      error_handler_exit

ftp_mark_disconnected:
        res     5,(ix+0)
        res     0,(ix+1)        ; old cache is not a directory on the new connection
        ld      a,3
        ld      (at_closed),a
        ld      a,"4"
        ld      (status_byte),a
        ld      hl,#2058        ; same disconnected markers as get_status_ftp
        ld      (current_host),hl
        ld      (current_login),hl
        xor     a
        ld      (current_host+2),a
        ld      (current_login+2),a
        call    cls_9           ; do not leave a stale directory visible with dead arrows
        call    print_ftp_status
        jp      print_title    ; local title only, never send PWD on a failed connection
