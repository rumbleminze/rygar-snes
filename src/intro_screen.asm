intro_screen_data:
.byte $C8, $20, $e2, $00, $69, $71, $70, $6f, $00                                 ; (c) 1986 
.byte$db, $cc, $ca, $d4, $d6, $00                           ; TECMO
.byte $ff                                                               ; 

.byte $A3, $22, $d7, $d6, $d9, $db, $cc, $cb, $00                       ; Ported 
.byte $c9, $e0, $00                                                     ; by 
.byte $d9, $dc, $d4, $c9, $d3, $cc, $d4, $d0, $d5, $e1, $cc, $00        ; Rumbleminze, 
.byte $6A, $68, $6a, $6c, $ff                                           ; 2023

; .byte $05, $23, $02, $16, $00, $03, $12                                 ; 2A03
; .byte $28, $3e, $44, $3d, $33, $12                                      ; SOUND 
; .byte $1a, $3c, $44, $3b, $30, $43, $3e, $41, $12                       ; EMULATOR
; .byte $31, $48, $12, $FF                                                ; BY

; .byte $4C, $23, $22, $34, $3c, $31, $3b, $34, $41, $42, $ff             ; MEMBLERS

.byte $78, $23, $d9, $cc, $dd, $00, $68, $81, $69, $ff ; Version (REV0)
.byte $ff, $ff

write_intro_palette:
    STZ CGADD    
    LDA #$00
    STA CGDATA
    STA CGDATA

    LDA #$FF
    STA CGDATA
    STA CGDATA

    LDA #$B5
    STA CGDATA
    LDA #$56
    STA CGDATA
    
    LDA #$29
    STA CGDATA
    LDA #$25
    STA CGDATA


; sprite default colors
    LDA #$80
    STA CGADD
    LDA #$D0
    STA CGDATA
    LDA #$00
    STA CGDATA
    
    LDA #$b5
    STA CGDATA
    LDA #$56
    STA CGDATA

    LDA #$d0
    STA CGDATA
    LDA #$00
    STA CGDATA
    
    LDA #$00
    STA CGDATA
    LDA #$00
    STA CGDATA

    
    LDA #$90
    STA CGADD
    LDA #$D0
    STA CGDATA
    LDA #$00
    STA CGDATA
    
    LDA #$00
    STA CGDATA
    LDA #$00
    STA CGDATA

    LDA #$d6
    STA CGDATA
    LDA #$10
    STA CGDATA
    
    LDA #$41
    STA CGDATA
    LDA #$02
    STA CGDATA

    
    LDA #$A0
    STA CGADD
    LDA #$D0
    STA CGDATA
    LDA #$00
    STA CGDATA
    
    LDA #$00
    STA CGDATA
    LDA #$00
    STA CGDATA

    LDA #$33
    STA CGDATA
    LDA #$01
    STA CGDATA

    LDA #$D0
    STA CGDATA
    LDA #$00
    STA CGDATA

    
    LDA #$B0
    STA CGADD
    LDA #$D0
    STA CGDATA
    LDA #$00
    STA CGDATA
    
    LDA #$33
    STA CGDATA
    LDA #$01
    STA CGDATA

    LDA #$33
    STA CGDATA
    LDA #$01
    STA CGDATA
    
    LDA #$6a
    STA CGDATA
    LDA #$00
    STA CGDATA

    RTS

write_intro_tiles:
    LDY #$00

next_line:
    ; get starting address
    LDA intro_screen_data, Y
    CMP #$FF
    BEQ exit_intro_write

    PHA
    INY    
    LDA intro_screen_data, Y
    STA VMADDH
    PLA
    STA VMADDL
    INY

next_tile:
    LDA intro_screen_data, Y
    INY

    CMP #$FF
    BEQ next_line

    STA VMDATAL
    BRA next_tile

exit_intro_write:
    RTS

do_intro:
    LDA VMAIN_STATE
    AND #$0F
    STA VMAIN
    LDA #$8F
    STA INIDISP
    STA INIDISP_STATE

    STZ TILE_CHUNK_COUNT
    LDA #$01
    STA TILE_DEST_LB_SETS
    STA TILE_SRC_LB_BANK

    LDA #$10
    STA TILE_DEST_HB

    LDA #$B0
    STA TILE_SRC_HB

    JSL load_tiles

    JSL enable_pause_window
    JSR write_intro_palette
    JSR write_intro_tiles
    ; JSL set_middle_attributes_to_palette_0
    ; JSL set_middle_attributes_to_palette_3
    LDA #$0F
    STA INIDISP
    LDX #$FF

  : LDA RDNMI
  : LDA RDNMI
    AND #$80
    BEQ :-
    DEX
    BNE :--

    JSL disable_pause_window
    LDA INIDISP_STATE
    ORA #$8F
    STA INIDISP_STATE
    STA INIDISP

    RTS