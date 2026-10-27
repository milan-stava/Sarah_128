	DEVICE ZXSPECTRUM128

;	DEFINE mb03; 1
	DEFINE bs_dos; 1
	MODULE v0
	INCLUDE "sarah_ftp_client.asm"
	SAVEBIN "SARAH12BSDhgfx",start_address,total_len
	EMPTYTAP "SARAH12BSD.tap"
	SAVETAP "SARAH12BSD.tap",CODE,"SAR12BSD",start_address,total_len
	IF program_page_len > 0
	INCLUDE "sara_tap.asm"
	ELSE
	INCLUDE "sara_loader.asm"
	DISPLAY "SARA_LOADER.tap: CODE blocks pending actual bank-6 data (program_page_len=0)."
	ENDIF
	ENDMODULE
	UNDEFINE bs_dos
;	UNDEFINE mb03



