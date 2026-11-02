; All main-screen shortcuts, including local G/K on both DOS variants.
; Dynamic A/W status offsets remain compatible with the existing printers.
print_menu_bank:
        or      a
        jr      nz,.directory
        ld      hl,txt_adr_menu1
        ld      de,menu1
        call    PRINTHL
        ld      hl,txt_adr_menu2
        ld      de,menu2
        call    PRINTHL
        ld      hl,txt_adr_meziradek
        ld      de,menu3
        jp      PRINTHL
.directory:
        ld      hl,txt_adr_dir_info+22
        ld      de,menu_dir
        jp      PRINTHL
menu1 db "F-file T-start A-YES H-host E-usr P-pw U-up S-sz Q-q G-CFG K-Hlp",0
        ASSERT $-menu1-1 <= line_length
menu2 db "W-wifi OFF L/ssL-login O-off V-save D-down C-cmd R-read Z-Txt",0
        ASSERT $-menu2-1 <= line_length
menu3 db "ssP-show CS/ssD-file N/ssN-list CS/ssM-mark Arrows-move/page",0
        ASSERT $-menu3-1 <= line_length
menu_dir db "I-find Sp-M ZX-roll 6-Rn 7-MD Del Br-U Ent",0
menu_dir_len equ $-menu_dir-1
        ASSERT menu_dir_len <= line_length-22
