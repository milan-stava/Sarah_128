; Tokenized ZX Spectrum BASIC loader; standalone build contains BASIC only.
; sara_tap.asm includes this file and then appends the two CODE blocks.
; 10 CLEAR 24575: LOAD "SARA1" CODE 24576: OUT 32765,22: LOAD "SARA2" CODE 49152: OUT 32765,16: RANDOMIZE USR 24576
; Build: sjasmplus sara_loader.asm

        DEVICE ZXSPECTRUM128
        ORG #5CCB

        IFNDEF SARA_TAP_FILE
        DEFINE SARA_TAP_FILE "SARA_LOADER.tap"
        ENDIF

        INCLUDE "sara_loader_data.asm"

        EMPTYTAP SARA_TAP_FILE
        SAVETAP SARA_TAP_FILE,BASIC,"SARA",loader_start,loader_line_end-loader_start,10
