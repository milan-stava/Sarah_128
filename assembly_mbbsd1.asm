	DEVICE ZXSPECTRUM128

;	DEFINE mb03; 1
	DEFINE bs_dos; 1
	MODULE v0
	INCLUDE "sarah_ftp_client.asm"
	SAVEBIN "SARAH12BSDhgfx",start_address,total_len
	SAVETAP "SARAH12BSD.tap",CODE,"SAR12BSD",start_address,total_len
	ENDMODULE
	UNDEFINE bs_dos
;	UNDEFINE mb03



