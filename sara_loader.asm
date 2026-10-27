; Tokenized ZX Spectrum BASIC loader; standalone build contains BASIC only.
; sara_tap.asm includes this file and then appends the two CODE blocks.
; 10 CLEAR 24575: LOAD "SARA1" CODE 24576: OUT 32765,22: LOAD "SARA2" CODE 49152: OUT 32765,16: RANDOMIZE USR 24576
; Build: sjasmplus sara_loader.asm

        DEVICE ZXSPECTRUM128
        ORG #5CCB

        IFNDEF SARA_TAP_FILE
        DEFINE SARA_TAP_FILE "SARA_LOADER.tap"
        ENDIF

        MACRO BASIC_UINT16 value
        db #0E,0,0
        dw value
        db 0
        ENDM

loader_start
        db 0,10                         ; BASIC line number, big endian
        dw loader_line_end-loader_line  ; line length includes final CR
loader_line
        db #FD,"24575"                  ; CLEAR 24575
        BASIC_UINT16 24575
        db ": ",#EF,'"SARA1" ',#AF,"24576" ; LOAD "SARA1" CODE 24576
        BASIC_UINT16 24576
        db ": ",#DF,"32765"            ; OUT 32765,22
        BASIC_UINT16 32765
        db ",22"
        BASIC_UINT16 22
        db ": ",#EF,'"SARA2" ',#AF,"49152" ; LOAD "SARA2" CODE 49152
        BASIC_UINT16 49152
        db ": ",#DF,"32765"            ; OUT 32765,16
        BASIC_UINT16 32765
        db ",16"
        BASIC_UINT16 16
        db ": ",#F9,#C0,"24576"        ; RANDOMIZE USR 24576
        BASIC_UINT16 24576
        db 13
loader_line_end

        EMPTYTAP SARA_TAP_FILE
        SAVETAP SARA_TAP_FILE,BASIC,"SARA",loader_start,loader_line_end-loader_start,10
