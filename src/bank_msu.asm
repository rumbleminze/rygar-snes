.segment "PRGAE"

; Read Flags
.DEFINE MSU_STATUS      $2000
.DEFINE MSU_READ        $2001
.DEFINE MSU_ID          $2002   ; 2002 - 2007

; Write flags
.DEFINE MSU_SEEK        $2000
.DEFINE MSU_TRACK       $2004   ; 2004 - 2005
.DEFINE MSU_VOLUME      $2006
.DEFINE MSU_CONTROL     $2007

.DEFINE CURRENT_NSF     $09FF
.DEFINE REMAPPED_NSF    $09FE
.DEFINE LOOP_VALUE      $09FD
.DEFINE MSU_ENABLE      $09FC
.DEFINE MSU_TRIGGER     $09FB

;___  ___  _____   _   _      ___   ______   _____    ___  
;|  \/  | /  ___| | | | |    / _ \  | ___ \ |  ___|  / _ \ 
;| .  . | \ `--.  | | | |   / /_\ \ | |_/ / | |__   / /_\ \
;| |\/| |  `--. \ | | | |   |  _  | |    /  |  __|  |  _  |
;| |  | | /\__/ / | |_| |   | | | | | |\ \  | |___  | | | |
;\_|  |_/ \____/   \___/    \_| |_/ \_| \_| \____/  \_| |_/
;org $E2F7F5
msu_check:
  PHA
  LDA MSU_ID		; load first byte of msu-1 identification string
  CMP #$53		; is it "M" present from "MSU-1" string?
  BEQ msu_available
  ; fall through to default
  PLA
  LDA $ABAB,Y		; native code
  TAY				; native code
  LDX #$00		; native code
  RTL

; if msu is present, process msu routine
msu_available:
  LDA #$00		; clear disable/enable nsf music flag
  STA MSU_ENABLE		; clear disable/enable nsf music flag

  PLA
  LDA $ABAB,Y		    ; native code
  TAY				        ; native code --> get track-id here !!!
  LDX #$00		      ; native code
  STA CURRENT_NSF		; store current nsf track-id for later retrieval

  LDA #$01
  STA MSU_TRIGGER
  LDA #$FF		      ; load max msu-1 volume byte
  STA MSU_ENABLE		; set mute NSF flag (writing FF in RAM location)

: RTL

msu_nmi_check:
  LDA MSU_TRIGGER
  BEQ :-
  STZ MSU_TRIGGER

  LDA CURRENT_NSF
  CMP #$00			; is this boss or room full of enemies?
  BEQ boss_room
  CMP #$0D			; is it stage 3-1 thru 3-3 music?
  BEQ stage_3
  CMP #$1A			; is it the Final Boss (Medusa) music?
  BEQ medusa_boss
  CMP #$27			; is it Boss stage 1-4, 2-4, and 3-4 music?
  BEQ stage_boss
  CMP #$34			; is it stage 4 (Medusa stage) music?
  BEQ stage_4
  CMP #$41			; is it Angry Grim Reaper music?
  BEQ grim_is_mad
  CMP #$4E			; is it Ending music?
  BEQ ending_credits
  CMP #$5B			; is it Title Screen music?
  BEQ title_screen
  CMP #$68			; is it Pit Dead Game Over music?
  BEQ dead_game_over
  CMP #$75			; is it stage Clear music?
  BEQ stage_clear
  CMP #$82			; is it stage 1-1 thru 1-3 music?
  BEQ stage_1
  CMP #$8F			; is it stage 2-1 thru 2-3 music?
  BEQ stage_2
  RTL

; re-map assigned nsf track-id
stage_1:
  LDA #$01		; assign STAGE 1			TRACK-1 (loop)
  BRA msu_routine
stage_2:
  LDA #$02		; assign STAGE 2			TRACK-2 (loop)
  BRA msu_routine
stage_3:
  LDA #$03		; assign STAGE 3			TRACK-3 (loop)
  BRA msu_routine
stage_4:
  LDA #$04		; assign STAGE 4 MEDUSA		TRACK-4 (loop)
  BRA msu_routine
stage_boss:
  LDA #$05		; assign BOSS STAGE			TRACK-5 (loop)
  BRA msu_routine
boss_room:
  LDA #$06		; assign BOSS       		TRACK-6 (loop)
  BRA msu_routine
medusa_boss:
  LDA #$07		; assign BOSS MEDUSA		TRACK-7 (loop)
  BRA msu_routine
grim_is_mad:
  LDA #$08		; assign GRIM IS MAD		TRACK-8 (loop)
  BRA msu_routine
stage_clear:
  LDA #$09		; assign STAGE CLEAR		TRACK-9 (no loop)
  BRA msu_routine
ending_credits:
  LDA #$0A		; assign ENDING CREDITS		TRACK-10 (no loop)
  BRA msu_routine
title_screen:
  LDA #$0B		; assign TITLE SCREEN		TRACK-11 (no loop)
  BRA msu_routine
dead_game_over:
  LDA #$0C		; assign GAME OVER			TRACK-12 (no loop)
  BRA msu_routine

;check if PCM track is present and play it, otherwise, default to NSF playback
msu_routine:
  STA REMAPPED_NSF		; store current re-mapped nsf track-id for later retrieval

  stz MSU_VOLUME		; drop volume to zero; reduce STAtic/noise during track changes in sd2snes
  STA MSU_TRACK		  ; store current valid NSF track-ID
  stz MSU_TRACK + 1	; must zero out high byte or current msu-1 track will not play !!!

msu_status:		; check msu ready status (required for sd2snes hardware compatibility)
  bit MSU_STATUS
  bvs msu_status

  LDA MSU_STATUS ; load track STAtus
  AND #$08		; isolate PCM track present byte
  CMP #$08		; is PCM track present after attempting to play using STA $2004?
  BNE play_msu
  BRA end_routine

play_msu:		          ; play PCM track and mute NSF music
  LDA REMAPPED_NSF		; restore re-mapped NSF track
  CMP #$09            ; if current track number is greater than 8, it is a no-loop track
  bcs loop_no
  LDA #$03		        ; load loop byte
  BRA loop_yes
loop_no:
  LDA #$01		        ; load no-loop byte
loop_yes:
  STA LOOP_VALUE		; store current loop value (debug purposes)
  STA MSU_CONTROL		; write current loop value
  LDA #$FF		      ; load max msu-1 volume byte
  STA MSU_VOLUME		; write max volume value
  ; STA MSU_ENABLE		; set mute NSF flag (writing FF in RAM location)
end_routine:
  LDA CURRENT_NSF		; restore original nsf track-id
  RTL


; _   _   _____  ______    ___  ___  _   _   _____   _____ 
;| \ | | /  ___| |  ___|   |  \/  | | | | | |_   _| |  ___|
;|  \| | \ `--.  | |_      | .  . | | | | |   | |   | |__  
;| . ` |  `--. \ |  _|     | |\/| | | | | |   | |   |  __| 
;| |\  | /\__/ / | |       | |  | | | |_| |   | |   | |___ 
;\_| \_/ \____/  \_|       \_|  |_/  \___/    \_/   \____/ 

;org $E2F626
mute_nsf:
  LDA MSU_ENABLE		; retrieve NSF mute flag
  CMP #$FF		; is it set? then mute NSF music
  BNE no_nsf_mute
  LDA #$00		; mute NSF music value
  STA $032B,X		; native code
  RTL
no_nsf_mute:
  LDA $AC88,Y		; native code
  STA $032B,X		; native code
  RTL


; _   _   _____  ______     _____   _____   _____  ______ 
;| \ | | /  ___| |  ___|   /  ___| |_   _| |  _  | | ___ \
;|  \| | \ `--.  | |_      \ `--.    | |   | | | | | |_/ /
;| . ` |  `--. \ |  _|      `--. \   | |   | | | | |  __/ 
;| |\  | /\__/ / | |       /\__/ /   | |   \ \_/ / | |    
;\_| \_/ \____/  \_|       \____/    \_/    \___/  \_|  

;org $E2F5F5
stop_nsf:
  LDX #$00		; native code
  LDY #$00		; native code
  PHA
  LDA CURRENT_NSF		; load currently playing msu-1 track
  CMP #$5B		; is it the Title Screen?
  BNE skip_mute
  STZ MSU_CONTROL		; mute msu-1 (from title screen)
skip_mute:
  PLA
  RTL

pause_enter_room:
    LDA #$00		; native code
    STZ MSU_CONTROL		; stop msu-1 playback (entering room)
    JML $A3CA90		; native code (modified due to hook used prior)


pause_main:
;org $E2F608
  LDA $00				; native code
  CMP #$01			; are we in inventory screen?
  BNE check_3_stages
  PHA
  LDA #$20
  STA MSU_VOLUME			; write lower volume level
  PLA
  BRA end_chk_stages
check_3_stages:
  CMP #$03			; are we back in the game?
  BNE end_chk_stages
  PHA
  LDA #$FF
  STA MSU_VOLUME			; write max volume level
  PLA
end_chk_stages:
  STA $38				; native code
  RTL

;org $22F63C
pause_boss:
  PHA
  CMP #$01			; are we in inventory screen?
  BNE check_3_boss
  PHA
  LDA #$20
  STA MSU_VOLUME			; write lower volume level
  PLA
  BRA end_chk_boss
check_3_boss:
  CMP #$03			; are we back in the game?
  BNE end_chk_boss
  PHA
  LDA #$FF
  STA MSU_VOLUME			; write max volume level
  PLA
end_chk_boss:
  PLA
  RTL
