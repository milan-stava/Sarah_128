; Combined Sarah 128 tape. Include after assembling the main code and bank 6.
; program_page_len must describe actual data assembled at #C000 in bank 6.
        ASSERT program_page == 6
        ASSERT program_page_len > 0
        ASSERT program_page_len <= #4000

        INCLUDE "sara_loader.asm"
        SAVETAP SARA_TAP_FILE,CODE,"SARA1",#6000,#6000
        SLOT 3
        PAGE program_page
        SAVETAP SARA_TAP_FILE,CODE,"SARA2",#C000,program_page_len
        PAGE 0
