.p816
.smart

.include "macros.inc"
.include "registers.inc"
.include "vars.inc"
.include "2a03_variables.inc"
.include "2a03_emu_upload.asm"
.include "hiromheader.asm"

.segment "CODE"
.include "resetvector.asm"

.segment "EMPTY_SPACE"
.include "2a03_emulator_first_8000.asm"
.include "2a03_emulator_second_8000.asm"

.include "bank-snes.asm"
.include "bank0.asm"
.include "bank1.asm"
.include "bank2.asm"
.include "bank3.asm"
.include "bank4.asm"
.include "bank5.asm"
.include "bank6.asm"
.if ENABLE_MSU > 0
     .include "bank_msu.asm"
.endif

; .include "base_tiles.asm"
; .include "title_screen_tiles.asm"
; .include "level_specific_tiles.asm"
.include "tiles0.asm"
.include "tiles1.asm"
.include "tiles2.asm"
.include "tiles0-new-tiles.asm"
.include "tiles1-new-tiles.asm"
.include "tiles2-new-tiles.asm"