set_ppu_control_and_mask_to_0:
    LDA VMAIN_STATE
    AND #$FC
    STA VMAIN

    LDA NMITIMEN_STATE
    AND #$7F
    STA NMITIMEN

    RTL

update_ppu_control_values_from_a:
    ; we only care about a few values for ppu control
    ; these bits Nxxx xIAA
    ; N = NMI enabled
    ; I = Increment mode 0 = H, 1 = V
    ; AA = Base Nametable
    ;   this controls which quadrant of the TileMap the NES shows
    ;   for us this controls what the HB of the the H/V Offset should be
    ; 00 = 2000 = 0 H 0 V
    ; 01 = 2400 = 1 H 0 V
    ; 10 = 2800 = 0 H 1 V
    ; 11 = 2C00 = 1 H 1 V

    PHA
    AND #$80
    CMP #$80
    BNE :+
    jsl enable_nmi
    bra :++
:   jsl disable_nmi_no_store

:   PLA
    PHA
    AND #$04
    CMP #$04
    BNE :+
    jsl set_vram_increment_to_32_no_store
    bra :++
:   jsl set_vram_increment_to_1

:   STZ HOFS_HB
    STZ VOFS_HB
    PLA
    pha
    AND #$03
    CMP #$03
    BEQ hvoffset11
    CMP #$02
    BEQ hvoffset10
    CMP #$01
    BEQ hvoffset01

 hvoffset00:   
    bra ret_from_update_ppu_control_values_from_a

 hvoffset01:  
    INC HOFS_HB
    bra ret_from_update_ppu_control_values_from_a
 
 hvoffset10:  
    INC VOFS_HB
    bra ret_from_update_ppu_control_values_from_a
 
 hvoffset11:  
    INC HOFS_HB
    INC VOFS_HB
    

ret_from_update_ppu_control_values_from_a:
    ; LDA INIDISP_STATE
    ; STA INIDISP
    pla
    RTL

set_ppu_control_to_0_and_store:
    LDA #$00
    STA PPU_CONTROL_STATE

    ; setting to 0 means increment by 1
    LDA VMAIN_STATE
    AND #$FC
    STA VMAIN
    STA VMAIN_STATE

    ; setting to 0 means disable NMI
    LDA NMITIMEN_STATE
    AND #$7F
    STA NMITIMEN
    STA NMITIMEN_STATE

    RTL

update_ppu_control_store_to_10:
    LDA #$10
    STA PPU_CONTROL_STATE

    ; sets address increment to 1, we do that with vmain
    STZ VMAIN_STATE

    ; disables NMI
    STZ NMITIMEN_STATE
    RTL

set_ppu_mask_to_stored_value:
    LDA TM_STATE
    STA TM
    RTL

set_ppu_mask_to_accumulator:
    PHA
    AND #$18
    CMP #$18
    BNE :+
        LDA #$11
        BRA :++++
:   CMP #$10
    BNE :+
        LDA #$10
        BRA :+++
:   CMP #$08
    BNE :+
        LDA #$01
        BRA :++
:   LDA #$00    
:    
    STA TM
    PLA
    RTL
    

update_vh_write_by_0b:
  LDA VMAIN_STATE
  AND #$FC
  LDX $0B
  BPL :+  
  ORA #$01
: STA $06
  STA VMAIN

  RTL

update_ppu_mask_store_to_1e:
    LDA #$1E
    STA PPU_MASK_STATE
    ; turns on BG and sprites
    LDA #$11
    STA TM_STATE
    JSL disable_pause_window
    RTL

update_values_for_ppu_mask:
    STZ TM_STATE
    ; we only care about bits 10 (sprites and 08 bg)
    LDA PPU_MASK_STATE
    AND #$06
    BNE :+
    JSL enable_pause_window
    BRA :++
:   JSL disable_pause_window
:   LDA PPU_MASK_STATE
    AND #$10
    CMP #$10
    BNE :+
    STA TM_STATE
    : LDA PPU_MASK_STATE
    AND #$08
    CMP #$08
    BNE :+
    LDA #$01
    ORA TM_STATE
    STA TM_STATE
    : 
    
    LDA TM_STATE
    STA TM
    BEQ :+
    LDA #$0F
    STA INIDISP
:   RTL

enable_nmi_and_store:
    ; make sure any NMI flags are clear
    LDA RDNMI
    LDA NMITIMEN_STATE
    ORA #$80
    STA NMITIMEN_STATE
    STA NMITIMEN

    LDA PPU_CONTROL_STATE
    ORA #$80
    STA PPU_CONTROL_STATE

    ; not sure on this
    LDA INIDISP_STATE
    AND #$7F
    STA INIDISP
    STA INIDISP_STATE

    RTL

enable_nmi:
    LDA RDNMI
    LDA NMITIMEN_STATE
    ORA #$80
    STA NMITIMEN

    RTL

reset_tm_state:
    LDA TM_STATE
    STA TM
    RTL
    
disable_nmi_and_store:
    LDA NMITIMEN_STATE
    AND #$7F
    STA NMITIMEN_STATE
    STA NMITIMEN

    LDA PPU_CONTROL_STATE
    AND #$7F
    STA PPU_CONTROL_STATE

    RTL

disable_nmi_no_store:
    LDA NMITIMEN_STATE
    AND #$7F
    STA NMITIMEN

    RTL

reset_nmi_status:
    ; make sure any NMI flags are clear
    LDA RDNMI
    LDA NMITIMEN_STATE
    STA NMITIMEN
    RTL

reset_nmi_and_inidisp_status:
    JSL reset_nmi_status
    JSL reset_inidisp
    RTL

set_vram_increment_to_1:
    LDA VMAIN_STATE
    AND #$FC
    STA VMAIN
    RTL

set_vram_increment_to_1_and_store:
    LDA PPU_CONTROL_STATE
    AND #$FB
    STA PPU_CONTROL_STATE

    LDA VMAIN_STATE
    AND #$FC
    STA VMAIN
    STA VMAIN_STATE
    RTL

set_vram_increment_to_32_and_store:
    LDA PPU_CONTROL_STATE
    ORA #$04
    STA PPU_CONTROL_STATE

    LDA VMAIN_STATE
    ORA #$01
    STA VMAIN
    STA VMAIN_STATE

    RTL

set_vram_increment_to_32_no_store:
    LDA VMAIN_STATE
    ORA #$01
    STA VMAIN

    RTL

reset_vmain_and_inidisp:
    JSL reset_vmain_to_stored_state
    JSL reset_inidisp
    RTL

reset_vmain_to_stored_state:
    LDA VMAIN_STATE
    STA VMAIN
    RTL

force_blank_and_store:
    LDA INIDISP_STATE
    ORA #$80
    STA INIDISP
    STA INIDISP_STATE
    RTL

force_blank_no_store:
    LDA INIDISP_STATE
    ORA #$80
    STA INIDISP
    RTL

turn_off_forced_blank_and_store:    
    LDA INIDISP_STATE
    AND #$7F
    STA INIDISP_STATE
    STA INIDISP
    RTL

reset_inidisp:
    LDA INIDISP_STATE
    STA INIDISP
    RTL

disable_nmi_and_fblank_no_store:
    JSL force_blank_no_store
    JSL disable_nmi_no_store
    RTL