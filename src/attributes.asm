; nes_951d_copy:
;   setAXY16
;   LDA #$80
;   STA VMAIN

;   LDA $0481
;   STA VMADDL ; STA PpuAddr_2006         
;   STA PPU_CURR_VRAM_ADDR
;   LDY #$0000                 
; : LDA $0483,Y 
;   AND #$00FF
;   CLC
;   ADC PPU_TILE_ATTR
;   STA VMDATAL ; PpuData_2007         
;   INY       
;   INC PPU_CURR_VRAM_ADDR                 
;   CPY #$40                 
;   BCC :-
    
;   setAXY8
;   LDA VMAIN_STATE
;   STA VMAIN
;   RTL

; veritcal_scroll_attribute_handle:
; nes_9537_copy:
         
;   JSR nes96c6_copy        
;   LDA $00                  
;   CLC                      
;   ADC #$C0
;   STA $01                  
;   LDA #$23                 
;   STA $02                  
;   LDA $1A                  
;   AND #$01                 
;   BNE :+        
;   LDA #$27         
;   STA $02        
; : LDA $02                  
;   STA ATTR_NES_VM_ADDR_HB      
;   LDA $01                 
;   STA ATTR_NES_VM_ADDR_LB      
;   JSR nes96c6_copy              
;   TAX                     
;   LDY #$00  
; : LDA $03B0,X              
;   STA ATTR_NES_VM_ATTR_START, Y     
;   INX                      
;   INY     
;   CPY #$08                 
;   BNE :-         

;   STY ATTR_NES_VM_COUNT

;   LDA #$00
;   STA ATTR_NES_VM_ATTR_START, Y          
;   INC ATTR_NES_HAS_VALUES
;   RTL 
; nes96c6_copy:
;   LDA VOFS_LB          
;   AND #$E0                 
;   LSR A                    
;   LSR A                    
;   STA $00                  
;   RTS 

rygar_attribute_scroll_write:
  LDA #$08
  STA COL_ATTR_VM_COUNT
  LDA $0320, X
  STA COL_ATTR_VM_HB
  INX
  LDA $0320, X
  STA COL_ATTR_VM_LB
  ; prep for next row
  ADC #$08
  ORA #$C0
  STA $0320, X
  DEX 
  PHX
  LDX #$00
: LDA $0330, Y
  STA COL_ATTR_VM_START, X
  INY
  INX
  DEC $08
  BNE :-
  INC COL_ATTR_HAS_VALUES
  jsl convert_nes_attributes_and_immediately_dma_them
  PLX
  RTL

check_and_copy_attribute_buffer:
  LDA ATTRIBUTE_DMA
  BEQ :+
  JSR copy_prepped_attributes_to_vram
: LDA COLUMN_1_DMA
  BEQ :+
  JSR dma_column_attributes
: RTS

copy_prepped_attributes_to_vram:
  STZ ATTRIBUTE_DMA
  LDA #$80
  STA VMAIN
  STZ DMAP6
  LDA #$19
  STA BBAD6
  LDX ATTRIBUTE_DMA + 1
  LDA #$7E
  STA A1B6
  LDA ATTR_DMA_SRC_HB,X
  STA A1T6H
  LDA ATTR_DMA_SRC_LB,X
  STA A1T6L
  LDA ATTR_DMA_SIZE_LB,X
  CMP #$80
  BMI handle_partials
  BRA handle_full
handle_partials:
  JSR copy_partial_prepped_attributes_to_vram
  BRA :+
handle_full: 
  STA DAS6L
  LDA ATTR_DMA_SIZE_HB,X
  STA DAS6H
  LDA ATTR_DMA_VMADDH,X
  STA VMADDH
  LDA ATTR_DMA_VMADDL,X
  STA VMADDL
  LDA #$40
  STA MDMAEN
: DEC ATTRIBUTE_DMA + 1
  LDA ATTRIBUTE_DMA + 1
  BPL :-
  LDY #$0F
  LDA #$00
: STA ATTRIBUTE_DMA,Y
  DEY
  BPL :-
  LDA #$FF
  STA ATTRIBUTE_DMA + 1
  RTS

copy_partial_prepped_attributes_to_vram:

; these are the same for all of them

  LDA #$7E
  STA A1B6

partial_row_loop:
  LDA ATTR_DMA_SIZE_LB, X
  LSR
  LSR
  STA DAS6L
  LDA #$00
  STA DAS6H
  LDA ATTR_DMA_SRC_LB,X
  CLC
  ADC ATTR_PARTIAL_CURR_OFFSET
  BCC :+
  ; rollover, bump up HB
  INC ATTR_DMA_SRC_HB
: STA A1T6L
  
  LDA ATTR_DMA_SRC_HB,X
  STA A1T6H  

  LDA ATTR_DMA_VMADDL,X
  CLC
  ADC ATTR_PARTIAL_CURR_OFFSET 
  BCC :+
  INC ATTR_DMA_VMADDH, X
: STA VMADDL

  LDA ATTR_DMA_VMADDH,X
  STA VMADDH
  
  LDA #$40
  STA MDMAEN

  LDA ATTR_PARTIAL_CURR_OFFSET
  ADC #$20
  STA ATTR_PARTIAL_CURR_OFFSET
  CMP #$80
  BMI partial_row_loop
  STZ ATTR_PARTIAL_CURR_OFFSET
  RTS

disable_attribute_buffer_copy:
  STZ ATTR_NES_VM_ADDR_HB
  STZ ATTR_NES_HAS_VALUES
  ; STZ ATTR_DMA_SIZE_LB
  RTS


attr_lookup_table_1_inf_9450:
.byte $00, $04, $08, $0C, $10, $14, $18, $1C, $80, $84, $88, $8C, $90, $94, $98, $9C

inf_95AE:
.byte $EA, $A1 
inf_95B0:
.byte $00, $D0, $06, $A9, $FF, $8D, $F0, $17, $6B, $4C, $20, $97, $00, $00, $01, $01
attr_lookup_table_2_inf_95C0:
.byte $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $02, $00
.byte $10, $20, $30, $40, $50, $60, $70, $80, $90, $A0, $B0, $C0, $D0, $E0, $F0, $00
.byte $10, $20, $30, $40, $50, $60, $70, $80, $90, $A0, $B0, $C0, $D0, $E0, $F0, $00

; $0C $0D contains address to load 40 attributes
; we always load it as if it's coming from 23C0 - 23FF
load_0x40_attributes_from_ram_for_pause:
  ; 20 at a time
  ; LDX #$00
  ; LDY #$00
  ; mute MSU
  ; if this needs to go to the e2 bank
  ; JSL @mute_nsf
  .if ENABLE_MSU > 0
    .byte $22, .lobyte(stop_nsf), .hibyte(stop_nsf), $e8
  .else
    LDX #$00
    LDY #$00
  .endif

  LDA #$C0
: STA ATTR_NES_VM_ADDR_LB
  LDA #$23
  STA ATTR_NES_VM_ADDR_HB
  LDA #$20
  STA ATTR_NES_VM_COUNT

: LDA ($0C), Y
  STA ATTR_NES_VM_ATTR_START, X
  INY
  INX
  CPX #$20
  BNE :-

  LDA #$00
  STA ATTR_NES_VM_ATTR_START, X
  LDA #$01
  STA ATTR_NES_HAS_VALUES
  PHY
  JSL convert_nes_attributes_and_immediately_dma_them
  PLY
  LDA #$E0
  LDX #$00
  CPY #$40
  BNE:--

  RTL


load_0x40_attributes_for_lvl3:
  ; 20 at a time
  LDX #$00
  LDY #$00
  LDA $0481
: STA ATTR_NES_VM_ADDR_LB
  LDA $0482
  STA ATTR_NES_VM_ADDR_HB
  LDA #$20
  STA ATTR_NES_VM_COUNT

: LDA $0483, Y
  STA ATTR_NES_VM_ATTR_START, X
  INY
  INX
  CPX #$20
  BNE :-

  LDA #$00
  STA ATTR_NES_VM_ATTR_START, X
  LDA #$01
  STA ATTR_NES_HAS_VALUES
  PHY
  JSL convert_nes_attributes_and_immediately_dma_them
  PLY
  LDA #$E0
  LDX #$00
  CPY #$40
  BNE:--

  RTL


convert_nes_attributes_and_immediately_dma_them:
  PHY
  PHA
  PHX
  LDA $20
  PHA
  LDA $21
  PHA
  LDA $22
  PHA
  LDA $23 
  PHA
  JSR check_and_copy_nes_attributes_to_buffer
  JSR check_and_copy_column_attributes_to_buffer
  JSR check_and_copy_attribute_buffer
  pla
  sta $23
  pla
  sta $22
  pla
  sta $21
  pla 
  sta $20
  PLX
  PLA
  PLY
  RTL

; converts attributes stored at 9A0 - A07 to attribute cache
; When we write to VRAM 23C0 - 23FF or 27C0 - 27FF we also must write it to 9A4 - 9E3 
; and 9e8 - a27
check_and_copy_nes_attributes_to_buffer:
  LDA ATTR_NES_HAS_VALUES
  BNE convert_attributes_inf
  RTS
  
convert_attributes_inf:
  PHK
  PLB
  LDX #$00
  JSR disable_attribute_hdma
  LDA #$A1
  STA $20
  LDA #$09
  STA $21
  STZ ATTR_DMA_SRC_LB
  STZ ATTR_DMA_SRC_LB + 1
  LDA #$18
  STA ATTR_DMA_SRC_HB
  LDA #$1A
  STA ATTR_DMA_SRC_HB + 1
  LDY #$00  
inf_9497:
  LDA ($20),Y ; $00.w is $09A1 to start
  ; early rtl  
  STZ ATTR_NES_HAS_VALUES
  BEQ check_and_copy_nes_attributes_to_buffer + 5
  AND #$03
  CMP #$03
  BEQ :+
  JMP inf_9700
: INY
  LDA ($20),Y
  AND #$F0
  CMP #$C0
  BEQ :+
  CMP #$D0
  BEQ :+
  CMP #$E0
  BEQ :+
  CMP #$F0
  BEQ :+
  JMP inf_9700 + 1
: JSR inc_attribute_hdma_store_to_x

  LDA ($20),Y
  PHY
  AND #$0F
  TAY
  LDA attr_lookup_table_1_inf_9450,Y
  PLY
  ; AND #$0F
  ; ASL A
  ; ASL a
  ; ASL a
  ; ASL A
  STA ATTR_DMA_VMADDL,X
  LDA ($20),Y
  AND #$30
  LSR
  LSR
  LSR
  LSR
  ORA #$20
  XBA
  DEY
  LDA ($20),Y
  CMP #$24
  BMI :+
  LDA #$00
  XBA
  INC
  INC
  INC
  INC
  STA ATTR_DMA_VMADDH,X
  BRA :++
: LDA #$00
  XBA
  STA ATTR_DMA_VMADDH,X
: INY
  INY
  LDA ($20),Y
  AND #$3F
  PHX
  TAX
  LDA attr_lookup_table_2_inf_95C0 + 15,X
  PLX
  STA ATTR_DMA_SIZE_LB,X
  LDA ($20),Y
  AND #$3F  
  CMP #$0F
  BPL :+
  LDA #$00
  BRA :++
: PHX
  TAX
  LDA inf_95AE,X
  PLX
: STA ATTR_DMA_SIZE_HB,X
  ; LDA #$80
  ; STA ATTR_DMA_SIZE_LB
  ; STZ ATTR_DMA_SIZE_HB
  LDA ($20),Y
  STA ATTRIBUTE_DMA + 14
  STA ATTRIBUTE_DMA + 15
  LDA ATTRIBUTE_DMA + 2,X
  sta $23
  LDA ATTRIBUTE_DMA + 4,X
  sta $22
  INY
  INY
  TYX
  LDA #$A0
  sta $20
  TYA
  CLC
  ADC $20
  sta $20
  BRA :+
inf_952D:  
  INC $20
: JSR inf_9680
  NOP
  LDA ($20,X)
  PHA
  AND #$03
  TAX
  LDA attr_lookup_table_1_inf_9450,X
  STA ($22),Y
  INY
  STA ($22),Y
  LDY #$20
  STA ($22),Y
  INY
  STA ($22),Y
  LDY #$02
  PLA
  PHA
  AND #$0C
  STA ($22),Y
  INY
  STA ($22),Y
  LDY #$22
  STA ($22),Y
  INY
  STA ($22),Y
  LDY #$40
  PLA
  PHA
  AND #$30
  LSR
  LSR
  LSR
  LSR
  TAX
  LDA attr_lookup_table_1_inf_9450,X
  STA ($22),Y
  INY
  STA ($22),Y
  LDY #$60
  STA ($22),Y
  INY
  STA ($22),Y
  LDY #$42
  PLA
  AND #$C0
  LSR
  LSR
  LSR
  LSR
  STA ($22),Y
  INY
  STA ($22),Y
  LDY #$62
  STA ($22),Y
  INY
  STA ($22),Y
  LDA $22
  CLC
  ADC #$04
  sta $22
  CMP #$20
  BEQ :+
  CMP #$A0
  BNE :++
: CLC
  ADC #$60
  sta $22
  BNE :+
  INC $23
: DEC ATTRIBUTE_DMA + 14
  LDA ATTRIBUTE_DMA + 14
  BEQ :+
  BRA inf_952D
: JSR inf_9690
  NOP
  LDA ($20,X)
  BNE inf_95b9

  STZ ATTR_NES_HAS_VALUES
  LDA #$FF
  STA ATTRIBUTE_DMA
  RTS

inf_95b9:
  ; i can't find this getting called, and 9720 looks non-sensical to me
  JMP inf_9720

inc_attribute_hdma_store_to_x:
  INC ATTRIBUTE_DMA + 1
  LDX ATTRIBUTE_DMA + 1
  RTS


disable_attribute_hdma:
  LDA #$FF
  STA ATTRIBUTE_DMA + 1
  RTS

inf_9680:
  LDA $20
  BNE :+
  INC $21
: LDX #$00
  LDY #$00
  RTS


inf_9690:
  LDA #$FF
  STA ATTRIBUTE_DMA
  INC $20
  LDX #$00
  RTS

inf_9700:
  INY
  INY
  LDA $22
  PHA
  STY $22
  LDA ($20),Y
  AND #$3F
  CLC
  ADC $22
  INC
  TAY
  PLA
  sta $22
  JMP inf_9497

inf_9720:
  LDA $22
  PHA
  STZ $22
: LDA $20
  CMP #$A1
  BEQ :+
  DEC $20
  INC $22
  BRA :-
: LDY $22
  PLA
  sta $22
  JMP inf_9497


copy_full_screen_attributes:
  LDX #$00
  LDY #$00
  LDA #$C0
: STA ATTR_NES_VM_ADDR_LB
  LDA FULL_ATTRIBUTE_COPY_HB
  STA ATTR_NES_VM_ADDR_HB

  LDA #$20
  STA ATTR_NES_VM_COUNT

: LDA (FULL_ATTRIBUTE_COPY_SRC_LB), Y
  STA ATTR_NES_VM_ATTR_START, X
  INY
  INX
  CPX #$20
  BNE :-

  LDA #$00
  STA ATTR_NES_VM_ATTR_START, X
  LDA #$01
  STA ATTR_NES_HAS_VALUES
  PHY
  JSL convert_nes_attributes_and_immediately_dma_them
  PLY
  LDA #$E0
  LDX #$00
  CPY #$40
  BNE:--
  RTS

check_and_copy_column_attributes_to_buffer:
  LDA COL_ATTR_HAS_VALUES
  BNE convert_column_of_tiles
  RTS

convert_column_of_tiles:
  LDA COL_ATTR_VM_HB
  ; early rtl
  BNE :+
  RTL
: LDA COL_ATTR_VM_LB
  AND #$F0
  CMP #$C0
  BEQ :+
  CMP #$D0
  BEQ :+
  CMP #$E0
  BEQ :+
  CMP #$F0
  BEQ :+
  RTL
: 
  ; LDA COL_ATTR_VM_LB
  ; PHY
  ; AND #$0F
  ; TAY
  ; LDA attr_lookup_table_1_inf_9450,Y
  ; PLY
  LDA COL_ATTR_VM_LB
  AND #$0F
  ASL A
  ASL a

  ; ASL a
  ; ASL A  
  STA C1_ATTR_DMA_VMADDL
  LDA COL_ATTR_VM_HB
  AND #$24
  STA C1_ATTR_DMA_VMADDH

  LDA #$20
  STA C1_ATTR_DMA_SIZE_LB
  STZ C1_ATTR_DMA_SIZE_HB

  LDY #$00
  LDX #$00
: LDA COL_ATTR_VM_START, Y

  ; convert magic!
  ; each attribute value gives us 4 attribute values
  ; in a grid of:
  ; 
  ; A A B B
  ; A A B B
  ; C C D D
  ; C C D D
  ;
  ; we'll store them in 4 batches to be DMA'd
  ; and store them in columns, but as rows, get it?
  ; 
  ; column1:  A A C C
  ; column2:  A A C C
  ; column3:  B B D D
  ; column4:  B B D D

  ; magic convert
  ; NES attribues will be in 1 byte, for the above description in this way:
  ; 0xDDCCBBAA
  ; The only thing we care about with Kid icarus is the palette
  ; 
  ; palattes for SNES are put in bits 4, 8 & 16 of the high byte:
  ; we're only useing 4 palattes, so we'll shift things to byte 4, 8 of the low nibble
  ; ___0 00___

  ; get A (TL)
  AND #$03
  ASL
  ASL
  STA C1_ATTRIBUTE_CACHE, X
  STA C1_ATTRIBUTE_CACHE + 1, X
  ; store in UR and LR row
  STA C1_ATTRIBUTE_CACHE + $20, X
  STA C1_ATTRIBUTE_CACHE + $20 + 1, X

  ; get B (TR), write them as dma lines 3 and 4.
  LDA COL_ATTR_VM_START, Y
  CLC
  AND #$0C
  STA C1_ATTRIBUTE_CACHE + $40, X
  STA C1_ATTRIBUTE_CACHE + $40 + 1, X
  STA C1_ATTRIBUTE_CACHE + $60, X
  STA C1_ATTRIBUTE_CACHE + $60 + 1, X

  ; get C (BL)
  LDA COL_ATTR_VM_START, Y
  CLC
  AND #$30
  LSR A
  LSR A
  STA C1_ATTRIBUTE_CACHE + 2, X
  STA C1_ATTRIBUTE_CACHE + 3, X
  STA C1_ATTRIBUTE_CACHE + $20 + 2, X
  STA C1_ATTRIBUTE_CACHE + $20 + 3, X

  ; get D (BR)
  LDA COL_ATTR_VM_START, Y
  AND #$C0
  LSR A
  LSR A
  LSR A
  LSR A
  STA C1_ATTRIBUTE_CACHE + $40 + 2, X
  STA C1_ATTRIBUTE_CACHE + $40 + 3, X
  STA C1_ATTRIBUTE_CACHE + $60 + 2, X
  STA C1_ATTRIBUTE_CACHE + $60 + 3, X

  INX
  INX
  INX
  INX

  INY
  CPY #$08
  BNE :-

  INC COLUMN_1_DMA
  STZ COL_ATTR_HAS_VALUES
  RTS

; uses DMA channel 2 to copy a buffer of column attributes
dma_column_attributes:
  STZ COLUMN_1_DMA

  ; write vertically for columns
  LDA #$81
  STA VMAIN

  LDX #$04

  LDA #.hibyte(C1_ATTRIBUTE_CACHE)
  STA C1_ATTR_DMA_SRC_HB
  LDA #.lobyte(C1_ATTRIBUTE_CACHE)
  STA C1_ATTR_DMA_SRC_LB

: STZ DMAP6

  LDA #$19
  STA BBAD6

  LDA #$7E
  STA A1B6

  LDA C1_ATTR_DMA_SRC_HB
  STA A1T6H
  LDA C1_ATTR_DMA_SRC_LB
  STA A1T6L

  LDA C1_ATTR_DMA_SIZE_LB
  STA DAS6L
  LDA C1_ATTR_DMA_SIZE_HB
  STA DAS6H

  LDA C1_ATTR_DMA_VMADDH
  STA VMADDH
  LDA C1_ATTR_DMA_VMADDL
  STA VMADDL

  LDA #$40
  STA MDMAEN

  INC C1_ATTR_DMA_VMADDL
  LDA C1_ATTR_DMA_SRC_LB
  CLC
  ADC #$20
  STA C1_ATTR_DMA_SRC_LB
  DEX
  BNE :-

  LDY #$0F
  LDA #$00
: STA COLUMN_1_DMA,Y
  DEY
  BPL :-
  LDA #$FF
  STA COLUMN_1_DMA + 1

  LDA #$80
  STA VMAIN

  RTS

; X should contain VMADDH
; Y should contain VMADDL
; A should contain VMDATAL
add_extra_vram_update:
  STY VRAM_UPDATE_ADDR_LB
  STX VRAM_UPDATE_ADDR_HB
  STA VRAM_UPDATE_DATA

  LDA EXTRA_VRAM_UPDATE
  ASL A
  ADC EXTRA_VRAM_UPDATE
  INC A
  TAY

  LDA VRAM_UPDATE_ADDR_LB
  STA EXTRA_VRAM_UPDATE, Y

  LDA VRAM_UPDATE_ADDR_HB
  STA EXTRA_VRAM_UPDATE + 1, Y

  LDA VRAM_UPDATE_DATA
  STA EXTRA_VRAM_UPDATE + 2, Y

  INC EXTRA_VRAM_UPDATE
  RTL

write_one_off_vrams:
  
  LDX EXTRA_VRAM_UPDATE
  BEQ :++
  LDY #$00
: LDA EXTRA_VRAM_UPDATE+1, Y
  STA VMADDL  
  INY

  LDA EXTRA_VRAM_UPDATE+1, Y
  STA VMADDH
  INY

  LDA EXTRA_VRAM_UPDATE+1, Y
  STA VMDATAL
  INY

  DEX
  BNE :-  

: STZ EXTRA_VRAM_UPDATE
  RTS