; ESXDOS-only launch bridges. The shared entry pushes the return RAM page
; after a successful download. Failed commands restore it and return to Sarah.
M_TAPEIN  equ #8B
M_EXECCMD equ #8F
M_AUTOLOAD equ #90

esx_load_tap:
        call    set_3_5mhz
        ld      iy,#5C3A
        ld      b,0
        ld      ix,exp_name
        ld      a,(DefaultDrive)
        rst     8
        db      M_TAPEIN
        jr      c,esx_launch_error
        xor     a
        rst     8
        db      M_AUTOLOAD
        jr      esx_launch_error ; no HALT/fall-through if autoload returns

esx_load_trdscl:
        call    set_3_5mhz
        ld      iy,#5C3A
        xor     a
        ld      (INPBUFF+7),a    ; first execute "vdisk 0" to eject
        ld      ix,INPBUFF
        rst     8
        db      M_EXECCMD
        push    af
        ld      a," "
        ld      (INPBUFF+7),a    ; then "vdisk 0 <downloaded filename>"
        pop     af
        jr      c,esx_launch_error
        ld      ix,INPBUFF
        rst     8
        db      M_EXECCMD
        jr      c,esx_launch_error
        xor     a
        call    PAGE128         ; normal upper bank and stack for TR-DOS entry
        ld      iy,#5C3A
        im      1
esx_trdos_stack:
        ld      sp,65000
        ei
        jp      15616           ; user's TR-DOS prompt handoff (#3D00)

esx_load_snap:
        call    set_3_5mhz
        ld      iy,#5C3A
        ld      ix,INPBUFF
        rst     8
        db      M_EXECCMD
        ; Successful SNAPLOAD takes over. A return never enters TR-DOS.
esx_launch_error:
        ld      (esx_last_error),a
        pop     af              ; saved page; abandon the bank-6 launch helper
        call    PAGE128
        ld      ix,flag1
        ld      c,15            ; existing disk-operation error display
        call    display_error
        xor     a
        ret
esx_last_error db 0             ; native ESXDOS error (zero may be custom)
