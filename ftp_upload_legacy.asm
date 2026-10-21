;Original release handshake and IPD parser, selected only during upload.
upl_old_check_module_answer
		push	hl
		call	clear_RX_buf
upl_old_chma11		ld	bc,TX_buf-RX_buf
		ld	hl,RX_buf
		ld	(hl),b
		push	hl
		push	bc
		call	receive_data_timeout
		pop	bc
		pop	hl
		ld	a,(hl)
		or	a
		jr	z,upl_old_chma11
		push	hl
		push	bc
		ld	de,busy
		call	look_for_string
		pop	bc
		pop	hl
		jr	z,upl_old_chma11
		pop	de
		call	look_for_string
		jr	z,upl_old_chma1111
		jr	nz,upl_old_chma3
upl_old_chma1111	call	clear_rece_buf
		and	a
		ret
upl_old_chma3		scf
		ret

upl_old_look_for_ipd	ld	(ix+6),3
		call	clear_RX_buf
upl_old_lfi7		ld	hl,ipd
		call	look_on_fly
		jr	z,upl_old_lfi3
upl_old_lfi_err		ld	c,12
upl_old_lfi_err1	scf
		ret
upl_old_lfi3		scf
		call	rece_byte
		jr	nz,upl_old_lfi4
		dec	(ix+6)
		jr	z,upl_old_lfi_err
		jr	upl_old_lfi3
upl_old_lfi4		sub	#30
		push	af
upl_old_lfi2		scf
		call	rece_byte
		jr	nz,upl_old_lfi5
		dec	(ix+6)
		jr	z,upl_old_lfi_err
		jr	upl_old_lfi2
upl_old_lfi5		ld	de,RX_buf
		push	de
upl_old_look_f_ipd_loop	scf
		call	rece_byte
		jr	nz,upl_old_lfi6
		dec	(ix+6)
		jr	nz,upl_old_look_f_ipd_loop
		pop	af
		pop	de
		ld	c,35
		jr	upl_old_lfi_err1
upl_old_lfi6		cp	":"
		jr	z,upl_old_lfi1
		ld	(de),a
		inc	de
		jr	upl_old_look_f_ipd_loop
upl_old_lfi1		pop	de
		call	ConvRStr16
		pop	af
		scf
		ccf
		ret

;Same payload read as the original receive_ftp_answer, without consuming AT OK.
upl_old_read_reply
        call upl_old_look_for_ipd
        jp c,error_handler
        ld b,h
        ld c,l
        ld hl,RX_buf
        call receive_data_timeout
        ld (hl),0
        ret
upload_legacy_mode db 0