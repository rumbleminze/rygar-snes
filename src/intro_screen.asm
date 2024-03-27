intro_screen_data:
.byte $48, $20, $e2, $00, $69, $71, $70, $6f, $00                                 ; (c) 1986 
.byte $db, $cc, $ca, $d4, $d6, $00                           ; TECMO
.byte $ff                                                               ; 

.byte $82, $20, $d7, $d9, $cc, $da, $da, $00                            ; press
.byte $da, $cc, $d3, $cc, $ca, $db, $00, $db, $d6, $ff                  ; select to
.byte $A2, $20, $da, $de, $d0, $db, $ca, $cf, $00                       ; switch
.byte $da, $d7, $d9, $d0, $db, $cc, $da, $ff                            ; sprites

.byte $ae, $21, $d4, $dc, $da, $d0, $ca, $FF
.byte $e4, $21, $d6, $d9, $d0, $ce, $d0, $d5, $c8, $d3, $FF
.byte $f5, $21, $d4, $da, $dc, $69, $FF

.byte $A3, $22, $d7, $d6, $d9, $db, $cc, $cb, $00                       ; Ported 
.byte $c9, $e0, $00                                                     ; by 
.byte $d9, $dc, $d4, $c9, $d3, $cc, $d4, $d0, $d5, $e1, $cc, $00        ; Rumbleminze, 
.byte $6A, $68, $6a, $6c, $ff                                           ; 2023

.byte $00, $23, $6a, $c8, $68, $6b, $00                                 ; 2A03
.byte $DA, $D6, $DC, $D5, $CB, $00                                      ; SOUND 
.byte $CC, $D4, $DC, $D3, $C8, $DB, $D6, $D9, $00                       ; EMULATOR
.byte $C9, $E0, $00                                                ; BY
.byte $d4, $cc, $d4, $c9, $d3, $cc, $d9, $da, $ff             ; MEMBLERS

.byte $41, $23, $d4, $da, $dc, $69, $00                 ; MSU1 TRACKS BY
.byte $db, $d9, $c8, $ca, $d2, $da, $00
.byte $c9, $e0, $ff                     
.byte $61, $23, $dd, $ce, $d4, $dc, $da, $d0, $ca, $00 ; VG MUSIC REVISITED
.byte $d9, $cc, $dd, $d0, $da, $d0, $db, $cc, $cb, $ff
            

.byte $78, $23, $d9, $cc, $dd, $00, $69, $81, $69, $ff ; Version (REV0)
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
    JSR load_intro_tilesets
    JSR write_intro_palette
    JSR write_default_palettes
    JSR write_intro_tiles
    JSR write_intro_sprites

    LDA #$0F
    STA INIDISP
    LDX #$FF


:
    jsr check_for_code_input
    jsr check_for_sprite_swap
    jsr check_for_msu
    LDA JOYTRIGGER1
    AND #$10
    CMP #$10
    BNE :-

    JSL disable_pause_window
    LDA INIDISP_STATE
    ORA #$8F
    STA INIDISP_STATE
    STA INIDISP

:   RTS
check_for_sprite_swap:

    LDA JOYTRIGGER1
    AND #$20
    CMP #$20
    BNE :-

    ; select was hit, swap the value for sprites
    LDA USE_ARCADE_SPRITE
    BEQ :+
    STZ USE_ARCADE_SPRITE
    BRA :++
:   LDA #$03
    STA USE_ARCADE_SPRITE
:   jsr load_intro_tilesets
    LDA #$0F
    STA INIDISP
:   rts
check_for_msu:
    LDA JOYTRIGGER1
    AND #$01
    CMP #$01
    BEQ :+
    LDA JOYTRIGGER1
    AND #$02
    CMP #$02
    BNE :-
:   LDA MSU_SELECTED
    EOR #$01
    STA MSU_SELECTED

    LDA SNES_OAM_START + (4*9 - 1)
    EOR #$40
    STA SNES_OAM_START + (4*9 - 1)
    JSR dma_oam_table
    RTS
intro_sprite_info:
    ; x, y, sprite
    .byte $80, $30, $00, $00
    .byte $80, $38, $01, $00
    .byte $88, $30, $02, $00
    .byte $88, $38, $03, $00
    .byte $80, $40, $08, $00
    .byte $80, $48, $09, $00
    .byte $88, $40, $0a, $00
    .byte $88, $48, $0B, $00
    .byte $80, $78, $54, $40
    .byte $ff

write_intro_sprites:
    LDY #$00
    LDX #$09

:   LDA intro_sprite_info, y
    STA SNES_OAM_START, y
    INY
    LDA intro_sprite_info, y
    STA SNES_OAM_START, y
    INY
    LDA intro_sprite_info, y
    STA SNES_OAM_START, y
    INY
    LDA intro_sprite_info, y
    STA SNES_OAM_START, y
    INY
    DEX
    BNE :-

    JSR dma_oam_table

    rts

load_intro_tilesets:
    lda #$01
    sta NMITIMEN
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

    STZ TILE_CHUNK_COUNT
    LDA #$01
    STA TILE_DEST_LB_SETS
    STZ TILE_SRC_LB_BANK
    STZ TILE_DEST_HB
    LDA #$80
    STA TILE_SRC_HB
    JSL load_tiles
    rts