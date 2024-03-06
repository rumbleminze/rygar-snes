; routines related to loading the tiles


; loads a set of tiles via DMA.  Rygar does this using 5 byte
; 
; byte 1 - how many 8-byte chunks of tile to copy, with 00 == 256
; byte 2 - xxxx xyyy - x = target address LB, y = how many sets of chunks to copy
; byte 3 - target HB
; byte 4 - xxxx xyyy - x = src address LB, y = src Bank
; byte 5 - src HB
; our tile Banks correspond to $A8 + original bank
; and because we're using 4bpp instead of 2bpp
; all source addresses have to be doubled.  Because C000 - FFFF was fixed
; in the UnROM game this works, as we'll be using 8000 - FFFF instead of 
; 8000 - BFFF.
load_tiles:

    PHB
    LDA #$A0
    PHA
    PLB
:   LDA RDNMI
    BPL :-

    LDA #$80
    STA VMAIN

    STZ NMITIMEN
    JSL force_blank_no_store
    
    LDA #$01
    STA DMAP5

    LDA TILE_SRC_HB
    SEC
    SBC #$80
    CLC
    ASL 
    CLC
    ADC #$80
    STA TILE_SRC_HB

    LDA TILE_SRC_LB_BANK
    AND #$F8
    CLC
    ASL
    STA A1T5L
    BCC :+
    INC TILE_SRC_HB
:   LDA TILE_SRC_HB
    STA A1T5H

    LDA TILE_SRC_LB_BANK
    AND #$07
    CLC
    ADC #$A8
    STA A1B5

    LDA #$18
    STA BBAD5 

    ; 800 bytes
    ; our byte size is TILE Chunk Count * 8 * (SETS + 1) * 2 (because we're 4bpp instead of 2bpp)
    STZ TILE_WORK_SIZE_HB
    STZ TILE_WORK_SIZE_LB

    LDA TILE_CHUNK_COUNT
    STA TILE_WORK_SIZE_LB
    ; 00 is special
    BNE :+   
    INC TILE_WORK_SIZE_HB
:    
    LDA TILE_DEST_LB_SETS
    AND #$07
    BEQ :++
    TAY
:   INC TILE_WORK_SIZE_HB
    DEY
    BNE :-


    ; multiply the size by 16 to get the actual size.
:   LDX #$05
:   DEX
    BEQ :+              ; done
    ASL TILE_WORK_SIZE_HB
    CLC
    ASL TILE_WORK_SIZE_LB
    BCC :-
    INC TILE_WORK_SIZE_HB
    BRA :-
:   LDA TILE_WORK_SIZE_HB
    

    STA DAS5H

    LDA TILE_WORK_SIZE_LB
    STA DAS5L

    LDA TILE_DEST_HB
    STA VMADDH
    
    LDA TILE_DEST_LB_SETS
    AND #$F8
    STA VMADDL

    ; LDA #$20
    ; STA MDMAEN
    

    LDA TILE_WORK_SIZE_HB
    STA DAS5H
    LDA TILE_WORK_SIZE_LB
    STA DAS5L
    LDA #$20
    STA MDMAEN
    
    LDA NMITIMEN_STATE
    STA NMITIMEN
    LDA VMAIN_STATE
    STA VMAIN
    LDA INIDISP_STATE
    STA INIDISP

    PLB
    RTL