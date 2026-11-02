        IFNDEF SARA_BASIC_MACRO_DEFINED
        DEFINE SARA_BASIC_MACRO_DEFINED
        MACRO BASIC_UINT16 value
        db #0E,0,0
        dw value
        db 0
        ENDM
        ENDIF

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
