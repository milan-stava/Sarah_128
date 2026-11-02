; User's ESXDOS TAP/snapshot/TRD/SCL launch routines, isolated from BS-DOS.
; Entry: bank 6, successful download has left its actual local name in exp_name.
; All terminal ESXDOS calls run below #C000: the loader may change RAM paging.
esx_launch_bank:
        or      a
        jp      z,esx_load_tap
        ld      hl,esx_snapload_text
        cp      5
        jr      c,.command
        ld      hl,esx_vdisk_text
.command:
        ld      de,INPBUFF
.prefix:
        ld      a,(hl)
        inc     hl
        or      a
        jr      z,.filename
        ld      (de),a
        inc     de
        jr      .prefix
.filename:
        ld      hl,exp_name
        ld      bc,13           ; full ASCIIZ 8.3 local name; no writes before it
        ldir
        ld      a,(item_extension)
        cp      5
        jp      nc,esx_load_trdscl
        jp      esx_load_snap
esx_snapload_text db "snapload ",0
esx_vdisk_text    db "vdisk 0 ",0
