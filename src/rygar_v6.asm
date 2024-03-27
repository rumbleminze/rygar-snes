; Rumblemince's Rygar SNES Port MSU-1 patch (beta 4)
; MSU-1 Patch: tok1440
; Mar-22-2024
; Note: using asar to compile this asm !!!


; Changelog
; ---------
; beta 1	initial release
; beta 2	mute msu-1 when entering doors
; beta 3	fixed rygar defeated not playing msu-1 version
; beta 4	added boss roar to msu-1 track list
; beta 5	fixed flute not playing msu-1 version
; beta 6	fixed argool saved not playing msu-1 version


; rom type
; --------
hirom
;lorom
;sa1rom


; starting address for free rom space
; -----------------------------------
!PATCH_ADDRESS_1 = $27AD50


; _   _   _____   _____   _   __  _____ 
;| | | | |  _  | |  _  | | | / / /  ___|
;| |_| | | | | | | | | | | |/ /  \ `--. 
;|  _  | | | | | | | | | |    \   `--. \
;| | | | \ \_/ / \ \_/ / | |\  \ /\__/ /
;\_| |_/  \___/   \___/  \_| \_/ \____/ 

; hook address for loading track-id
org $2784FA ; original op-code is lda $852e,x
jsr msu_play_routine

; hook address for nsf mute music (between stage transitions)
org $278654 ; original instructions lda #$26 & jsr $cd00
jsr mute_nsf_msu_routine
nop
nop

; hook to play rygar defeated music
org $278106
jsr rygar_defeated
jsr $CD00	; native code
jsl $20824F ; native code

; hook to play flute of pegasus music
org $278294 ; original instructions lda #$1F & jsr $cd00 & lda #$02
jsr play_flute
nop
nop

; hook to play argool Saved
org $27A803
jsr play_argool
nop
nop

;___  ___  _____   _   _      ___   ______   _____    ___  
;|  \/  | /  ___| | | | |    / _ \  | ___ \ |  ___|  / _ \ 
;| .  . | \ `--.  | | | |   / /_\ \ | |_/ / | |__   / /_\ \
;| |\/| |  `--. \ | | | |   |  _  | |    /  |  __|  |  _  |
;| |  | | /\__/ / | |_| |   | | | | | |\ \  | |___  | | | |
;\_|  |_/ \____/   \___/    \_| |_/ \_| \_| \____/  \_| |_/

org !PATCH_ADDRESS_1 ; free rom space
; ---------------------------------
play_argool:
LDA #$10		; load argool saved track-id
JSR resume_argool
JSR $CD00		; native code
RTS

play_flute:
LDA #$1F		; load flute of pegasus track-id
JSR resume_flute
JSR $CD00		; native code
RTS

rygar_defeated:
LDA #$11		; load rygar defeated track-id
JMP resume_rygar

msu_play_routine:
LDA $852E,X		; native code, loads music track id
resume_rygar:
resume_flute:
resume_argool:
STA $7E01CF		; save original nsf track-id to RAM, using this for debugging purposes
JSR track_remap ; remap track id routine

STZ $2006		; drop volume to zero; reduce Static/noise during track changes in sd2snes
STA $2004		; store current valid NSF track-ID
STZ $2005		; must zero out high byte or current msu-1 track will not play !!!

msu_status:	; check msu ready status (required for sd2snes hardware compatibility)
bit $2000
bvs msu_status

LDA $2000		; load MSU-1 track status
AND #$08		; isolate PCM track present byte
CMP #$08		; is PCM track present after attempting to play using STA $2004?
BEQ end_routine_nsf ; if PCM missing, stop any currently playing msu-1 music and default to nsf

LDA $7E01CD		; load loop status
STA $2007		; write current loop value
LDA #$40		; load max msu-1 volume byte
STA $2006		; write max volume value
STA $7E01CC		; set mute NSF flag (writing FF in RAM location)
LDA #$26		; PCM is present, mute NSF value and play msu-1
RTS
end_routine_nsf:
STZ $2007		; mute msu-1
LDA $7E01CF		; no pcm found, default to original nsf music
RTS

track_remap:
CMP #$03		; this Sueru Mountain?
BNE chk_04
JSR set_loop
LDA #$01		; Sueru Mountain remapped as track-01
JMP remap_leave

chk_04:
CMP #$04		; this Gran Mountain?
BNE chk_05
JSR set_loop
LDA #$02		; Gran Mountain remapped as track-02
JMP remap_leave

chk_05:
CMP #$05		; this Garloz?
BNE chk_06
JSR set_loop
LDA #$03		; Garloz remapped as track-03
JMP remap_leave

chk_06:
CMP #$06		; this Den of Sagila?
BNE chk_07
JSR set_loop
LDA #$04		; Den of Sagila remapped as track-04
JMP remap_leave

chk_07:
CMP #$07		; this Palace of Dorago
BNE chk_08
JSR set_loop
LDA #$05		; Palace of Dorago as track-05
JMP remap_leave

chk_08:
CMP #$08		; this Lapis?
BNE chk_09
JSR set_loop
LDA #$06		; Lapis re-mapped as track-06
JMP remap_leave

chk_09:
CMP #$09		; this Sky Castle
BNE chk_0A
JSR set_loop
LDA #$07		; Sky Castle re-mapped as track-07
JMP remap_leave

chk_0A:
CMP #$0A		; this Tower of Garba
BNE chk_0B
JSR set_loop
LDA #$08		; Tower of Garba re-mapped as track-08
JMP remap_leave

chk_0B:
CMP #$0B		; this Boss Roar
BNE chk_0C
JSR set_loop
LDA #$0F		; Boss Roar re-mapped as track-15
JMP remap_leave

chk_0C:
CMP #$0C		; this Legendary God
BNE chk_10
JSR set_loop
LDA #$09		; Legendary God re-mapped as track-09
JMP remap_leave

chk_10:
CMP #$10		; this Argool Saved?
BNE chk_11
JSR set_loop
LDA #$0A		; Argool Saved re-mapped as track-10
JMP remap_leave

chk_11:
CMP #$11		; this Rygar Defeated
BNE chk_1F
JSR set_no_loop
LDA #$0B		; Rygar Defeated re-mapped as track-11
JMP remap_leave

chk_1F:
CMP #$1F		; this Flute of Pegasus followed by Gran Mountain music on same track?
BNE chk_27
JSR set_loop
LDA #$0C		; Flute of Pegasus re-mapped as track-12
JMP remap_leave

chk_27:
CMP #$27		; this Primeval Mountain?
BNE chk_28
JSR set_loop
LDA #$0D		; Primeval Mountain re-mapped as track-13
JMP remap_leave

chk_28:
CMP #$28		; this Eruga's Forest
BNE do_nothing
JSR set_loop
LDA #$0E		; Eruga's Forest re-mapped as track-14
JMP remap_leave

do_nothing:
LDA #$00		; write zero to remapped RAM location, nothing to do

remap_leave:
STA $7E01CE		; save remapped nsf track-id to RAM
RTS

set_loop:		; routine to set msu-1 track to loop
LDA #$03
STA $7E01CD		; store current loop status to RAM for later retrieval
RTS

set_no_loop:	; routine to set msu-1 track not to loop
LDA #$01
STA $7E01CD		; store current loop status to RAM for later retrieval
RTS

mute_nsf_msu_routine: ; mutes nsf or msu-1 music after going through door
STZ $2007	; mute msu-1
LDA #$26	; native code, mutes nsf
JSR $CD00	; native code
RTS

; _   _   _____   _____   _____   _____ 
;| \ | | |  _  | |_   _| |  ___| /  ___|
;|  \| | | | | |   | |   | |__   \ `--. 
;| . ` | | | | |   | |   |  __|   `--. \
;| |\  | \ \_/ /   | |   | |___  /\__/ /
;\_| \_/  \___/    \_/   \____/  \____/ 

; RAM Cheats
; ----------
; Allowed Health Max Bar at $CA -> set to 18
; Current Health -> set to 18 (freeze for infinite health)

; PAR Codes
; ---------


; Re-mapped Track-ID
; ------------------
;01 Sueru Mountain (loops)
;02 Gran Mountain (loops)
;03 Garloz (loops)
;04 Den of Sagila (loops)
;05 Palace of Dorago (loops)
;06 Lapis (loops)
;07 Sky Castle (loops)
;08 Tower of Garba (loops)
;09 Legendary God (loops)
;10 Argool Saved (loops)
;11 Rygar Defeated (no loop)
;12 Flute of Pegasus + Gran Mountain (loop)
;13 Primeval Mountain (loops)
;14 Eruga's Forest (loops)
;15 Boss Roar (loops)