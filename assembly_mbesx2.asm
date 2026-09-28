	DEVICE ZXSPECTRUM128

;	DEFINE mb03
;	UNDEFINE bs_dos 0
	MODULE v1
	INCLUDE "sarah_ftp_client.asm"
	SAVETAP "SARAH12ESX.tap",CODE,"SAR12ESX",start_address,total_len
	ENDMODULE
;	UNDEFINE mb03

		