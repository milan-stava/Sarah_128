;HGFX_REGISTERS	equ	#3F00		;nelze, pise do BSDOSu
;HGFX_REGISTERS equ	#3800		;pracovni buffer pro 1 sektor, taky nejde
HGFX_REGISTERS	equ	0		;0- tady by BSDOS nic prepisovat nemel

	DISP HGFX_REGISTERS
    STRUCT HGFX
V_PARAM     db 0
;   bit0 = 0 - display video buffer 0; 1 - display video buffer 1
;   bit1 = destination video buffer for writing for all PlanarModes 
;   bit2 = source video buffer for reading in COPY mode and CHUNKY access
;   bit3 = 0 - none ; 1 - reduce operation only to PlannarWorkingWindow 
;   bit4 = 0 - none ; 1 - CHUNKY transparency when byte=0
PLANAR_MODE db 0
ADVANCED    db 0
COLOR       db 0
MASK        db 0
OFFSET_X    dw 0
OFFSET_Y    dw 0
OFFSET_X_R  dw 0
OFFSET_Y_R  dw 0
ADV_FEAT    db 0
PAPER       db 0
FILL_MASK   db 0
WINC_X      dw 0
WINC_Y      dw 0
WIN_W       dw 0
WIN_H       dw 0
	ENDS
	ENT