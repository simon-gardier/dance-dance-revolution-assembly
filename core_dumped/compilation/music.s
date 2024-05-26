#ifndef MUSIC
#define MUSIC

processor 16f1789
#include <xc.inc>
#include "bits.inc"
#include "ram.inc"

; ------------------------------------------------------------------------------
; =========================== Sound macros =====================================
; ------------------------------------------------------------------------------
NOTE_TOTAL_ITERATIONS           equ 5  ; 1 frame = 40ms, 10*40 = 400ms per note
MUSIC_LENGTH                    equ 192

; ------------------------------------------------------------------------------
; ============================= Subroutines ====================================
; ------------------------------------------------------------------------------
PSECT page3, global, class = CODE, delta = 2
; ------------------------------------------------------------------------------
; Look up table tetris_music_notes() storing the indexes of the notes producing the music "Korobeniki" (i.e. Tetris theme)
; Only the upper staff is played
; Partition taken from : https://musescore.com/user/28837378/scores/5144713
; ------------------------------------------------------------------------------
tetris_music_notes:
    brw
    ;----------Line 1----------
    retlw 5                     ;mi 2
    retlw 5
    retlw 2                     ;si 1
    retlw 3                     ;do 1
    retlw 4                     ;re 2
    retlw 4
    retlw 3                     ;do 1
    retlw 2                     ;si 1
    retlw 1                     ;la 2
    retlw 1
    retlw 1                     ;la 1
    retlw 3                     ;do 1
    retlw 5                     ;mi 2
    retlw 5
    retlw 4                     ;re 1
    retlw 3                     ;do 1
    retlw 2                     ;si 3
    retlw 2
    retlw 2
    retlw 3                     ;do 1
    retlw 4                     ;re 2
    retlw 4
    retlw 5                     ;mi 2
    retlw 5
    retlw 3                     ;do 2
    retlw 3
    retlw 1                     ;la 2
    retlw 1
    retlw 1                     ;la 2
    retlw 1
    retlw 10                    ;silence 2
    retlw 10
    ;----------Line 2----------
    retlw 10                    ;silence 1
    retlw 4                     ;re 2
    retlw 4
    retlw 6                     ;fa 1
    retlw 9                     ;la' 2
    retlw 9
    retlw 7                     ;sol 1
    retlw 6                     ;fa 1
    retlw 5                     ;mi 3
    retlw 5
    retlw 5
    retlw 3                     ;do 1
    retlw 5                     ;mi 2
    retlw 5
    retlw 4                     ;re 1
    retlw 3                     ;do 1
    retlw 2                     ;si 3
    retlw 2
    retlw 2
    retlw 3                     ;do 1
    retlw 4                     ;re 2
    retlw 4
    retlw 5                     ;mi 2
    retlw 5
    retlw 3                     ;do 2
    retlw 3
    retlw 1                     ;la 2
    retlw 1
    retlw 1                     ;la 2
    retlw 1
    retlw 10                    ;silence 2
    retlw 10
    ;----------Line 3----------
    retlw 5                     ;mi 4
    retlw 5
    retlw 5
    retlw 5
    retlw 3                     ;do 4
    retlw 3
    retlw 3
    retlw 3
    retlw 4                     ;re 4
    retlw 4
    retlw 4
    retlw 4
    retlw 2                     ;si 4
    retlw 2
    retlw 2
    retlw 2
    retlw 3                     ;do 4
    retlw 3
    retlw 3
    retlw 3
    retlw 1                     ;la 4
    retlw 1
    retlw 1
    retlw 1
    retlw 0                     ;sol# 8
    retlw 0
    retlw 0
    retlw 0
    retlw 0
    retlw 0
    retlw 0
    retlw 0
    ;----------Line 4----------
    retlw 5                     ;mi 4
    retlw 5
    retlw 5
    retlw 5
    retlw 3                     ;do 4
    retlw 3
    retlw 3
    retlw 3
    retlw 4                     ;re 4
    retlw 4
    retlw 4
    retlw 4
    retlw 2                     ;si 4
    retlw 2
    retlw 2
    retlw 2
    retlw 3                     ;do 2
    retlw 3
    retlw 5                     ;mi 2
    retlw 5
    retlw 9                     ;la' 2
    retlw 9
    retlw 9                     ;la' 2
    retlw 9
    retlw 8                     ;sol#' 8
    retlw 8
    retlw 8
    retlw 8
    retlw 8
    retlw 8
    retlw 8
    retlw 8
    ;----------Line 5----------
    retlw 5                     ;mi 2
    retlw 5
    retlw 2                     ;si 1
    retlw 3                     ;do 1
    retlw 4                     ;re 2
    retlw 4
    retlw 3                     ;do 1
    retlw 2                     ;si 1
    retlw 1                     ;la 2
    retlw 1
    retlw 1                     ;la 1
    retlw 3                     ;do 1
    retlw 5                     ;mi 2
    retlw 5
    retlw 4                     ;re 1
    retlw 3                     ;do 1
    retlw 2                     ;si 3
    retlw 2
    retlw 2
    retlw 3                     ;do 1
    retlw 4                     ;re 2
    retlw 4
    retlw 5                     ;mi 2
    retlw 5
    retlw 3                     ;do 2
    retlw 3
    retlw 1                     ;la 2
    retlw 1
    retlw 1                     ;la 2
    retlw 1
    retlw 10                    ;silence 2
    retlw 10
    ;----------Line 6----------
    retlw 10                    ;silence 1
    retlw 4                     ;re 2
    retlw 4
    retlw 6                     ;fa 1
    retlw 9                     ;la? 2
    retlw 9
    retlw 7                     ;sol 1
    retlw 6                     ;fa 1
    retlw 10                    ;silence 1
    retlw 5                     ;mi 2
    retlw 5
    retlw 3                     ;do 1
    retlw 5                     ;mi 2
    retlw 5
    retlw 4                     ;re 1
    retlw 3                     ;do 1
    retlw 10                    ;silence 1
    retlw 2                     ;si 2
    retlw 2
    retlw 3                     ;do 1
    retlw 4                     ;re 2
    retlw 4
    retlw 5                     ;mi 2
    retlw 5
    retlw 10                    ;silence 1
    retlw 3                     ;do 2
    retlw 3
    retlw 1                     ;la 1
    retlw 1                     ;la 2
    retlw 1
    retlw 10                    ;silence 2
    retlw 10


; ------------------------------------------------------------------------------
; Look up tables for the notes
; Frequencies of the notes based on : https://web.archive.org/web/20190625211648/https://pages.mtu.edu/~suits/notefreqs.html
; The notes are shifted up, e.g. Sol# 415Hz becomes Si 987Hz
; ------------------------------------------------------------------------------
notes_period_low:
    brw
    retlw   LOW(64841)          ;0 - sol#       987
    retlw   LOW(61184)          ;1 - la         1046
    retlw   LOW(54513)          ;2 - si         1174
    retlw   LOW(51445)          ;3 - do         1244
    retlw   LOW(45844)          ;4 - re         1396
    retlw   LOW(40841)          ;5 - mi         1567
    retlw   LOW(38530)          ;6 - fa         1661
    retlw   LOW(34333)          ;7 - sol        1864
    retlw   LOW(32404)          ;8 - sol#'      1975
    retlw   LOW(30577)          ;9 - la'        2093
    retlw   0                   ;10- silence
notes_period_high:
    brw
    retlw   HIGH(64841)
    retlw   HIGH(61184)
    retlw   HIGH(54513)
    retlw   HIGH(51445)
    retlw   HIGH(45844)
    retlw   HIGH(40841)
    retlw   HIGH(38530)
    retlw   HIGH(34333)
    retlw   HIGH(32404)
    retlw   HIGH(30577)
    retlw   0
notes_duty_cycle_low:
    brw
    retlw   LOW(64841/2)        ;sol#       987
    retlw   LOW(61184/2)        ;la         1046
    retlw   LOW(54513/2)        ;si         1174
    retlw   LOW(51445/2)        ;do         1244
    retlw   LOW(45844/2)        ;re         1396
    retlw   LOW(40841/2)        ;mi         1567
    retlw   LOW(38530/2)        ;fa         1661
    retlw   LOW(34333/2)        ;sol        1864
    retlw   LOW(32404/2)        ;sol#'      1975
    retlw   LOW(30577/2)        ;la'        2093
    retlw   0                   ;10         silence
notes_duty_cycle_high:
    brw
    retlw   HIGH(64841/2)
    retlw   HIGH(61184/2)
    retlw   HIGH(54513/2)
    retlw   HIGH(51445/2)
    retlw   HIGH(45844/2)
    retlw   HIGH(40841/2)
    retlw   HIGH(38530/2)
    retlw   HIGH(34333/2)
    retlw   HIGH(32404/2)
    retlw   HIGH(30577/2)
    retlw   0

; ------------------------------------------------------------------------------
; Subroutine update_game_music()
; Update the music output on PSMC3.
; Total duration: <= 66cc  (including call) (most of the time, only 7cc)
; Change bank to bank PSMC3CON.
; Return with W = index of the colmun in which add an arrow
; 0 = left, 1 = down, 2 = up, 3 right, 4 = none
; ------------------------------------------------------------------------------
update_game_music:
    decfsz  music_note_iteration_counter, 1 ; if note_iteration_counter is not zero
    goto    end_update_game_music_no_note   ; then goto next iteration

    movf    music_note_index, 0             ; else get the index of the note to play
    sublw   MUSIC_LENGTH                    ; (we do MUSIC_LENGTH - music_note_index, because music_note_index starts at MUSIC_LENGTH)
    call    tetris_music_notes              ; retrieve the index of the note to play
    movwf   note_data_index                 ; store this index as we'll need W to retrieve the note data

    banksel PSMC3CON                        ; update PSMC3
    call    notes_period_high
    movwf   PSMC3PRH
    movf    note_data_index, 0
    call    notes_period_low
    movwf   PSMC3PRL
    movf    note_data_index, 0
    call    notes_duty_cycle_high
    movwf   PSMC3DCH
    movf    note_data_index, 0
    call    notes_duty_cycle_low
    movwf   PSMC3DCL
    bsf     PSMC3CON, PSMC3LD               ; request hardware update for the period and dc

    decfsz  music_note_index, 1             ; if we arent at the end of the music
    goto    reset_music_note_iteration_counter    ; then only reset frame counter to decrement to zero before playing a new note
    movlw   MUSIC_LENGTH                    ; else reset music_note_index to MUSIC_LENGTH
    movwf   music_note_index
reset_music_note_iteration_counter:
    movlw   NOTE_TOTAL_ITERATIONS           ; reset note_iteration_counter to NOTE_TOTAL_ITERATIONS
    movwf   music_note_iteration_counter
    movf    note_data_index, 0
    subwf   note_data_index_prev, 0
    btfsc   STATUS, Z                       ; if note_data_index_prev == note_data_index_prev
    goto    end_update_game_music_no_note   ; then return
    movf    note_data_index, 0              ; else store note_data_index in note_data_index_prev
    movwf   note_data_index_prev            ; and compute the arrow column in which place the new arrow
    call    note_data_index_to_arrow_column_index
    return
end_update_game_music_no_note:
    retlw   4

; ------------------------------------------------------------------------------
; Lookup table note_data_index_to_arrow_column_index()
; Return a value in [0, 3] :  0 = left, 1 = down, 2 = up, 3 right
; ------------------------------------------------------------------------------
note_data_index_to_arrow_column_index:
    brw
    retlw   0
    retlw   1
    retlw   2
    retlw   3
    retlw   0
    retlw   1
    retlw   2
    retlw   3
    retlw   0
    retlw   1
    retlw   2

#endif






