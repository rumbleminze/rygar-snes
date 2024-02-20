
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
    
    
update_ppu_mask_store_to_1e:
    LDA #$1E
    STA PPU_MASK_STATE
    ; turns on BG and sprites
    LDA #$11
    STA TM_STATE
    RTL

update_values_for_ppu_mask:
    STZ REUSABLE_CALC_BYTE
    ; we only care about bits 10 (sprites and 08 bg)
    LDA PPU_MASK_STATE
    AND #$10
    BEQ :+
    STA REUSABLE_CALC_BYTE
    : LDA PPU_MASK_STATE
    AND #$08
    BEQ :+
    LDA #$01
    ORA REUSABLE_CALC_BYTE
    STA REUSABLE_CALC_BYTE
    : LDA REUSABLE_CALC_BYTE
    STA TM
    RTL

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