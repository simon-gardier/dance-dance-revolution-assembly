processor 16f1789
#include <xc.inc>
    
#ifndef GAME_LOGIC_INC
#define GAME_LOGIC_INC

; ------------------------------------------------------------------------------
; Subroutine init_arrow_struct()
; Init the arrow_struct
; Total duration: 25cc (including call)
; Change FSR1 pointer
; ------------------------------------------------------------------------------
GLOBAL init_arrow_struct

; ------------------------------------------------------------------------------
; Subroutine create_arrow()
; Place a new arrow in arrow_struct
; drawing_index must contains the index of the arrow column [0;3].
; Total duration: 26cc (including call)
; Change FSR1 pointer
; ------------------------------------------------------------------------------
GLOBAL create_arrow

; ------------------------------------------------------------------------------
; Subroutine move_arrow()
; Advance all arrow in arrow_struct.
; Total duration: <=112cc (including call)
; Change FSR1
; ------------------------------------------------------------------------------
GLOBAL move_arrow

; ------------------------------------------------------------------------------
; Subroutine verif_arrow()
; Verify if an arrow should be deleted because out-of-range.
; Total duration: <=256cc (including call)
; Change FSR1
; ------------------------------------------------------------------------------
GLOBAL verif_arrow

; ------------------------------------------------------------------------------
; Subroutine press_arrow()
; Delete the arrows close to the top if the corresponding button is pressed 
; and decrement the hearts.
; Change FSR0 and FSR1
; Total duration: MAX 402cc (including call) if 8 arrows are claimed. Which is
; impossible without cheating and unlucky game output.
; ------------------------------------------------------------------------------
GLOBAL press_arrow

; ------------------------------------------------------------------------------
; Subroutine increment_score()
; Increment the score by 1. Maintains each score digit within 4 bits.
; Total duration: <31cc (including call). But at most 94cc (31+9x7) with 8 consecutive calls.
; ------------------------------------------------------------------------------
GLOBAL increment_score

; ------------------------------------------------------------------------------
; Subroutine get_score_digit()
; Return the score digit in W. 
; Digit number must be in W when called.
; Total duration: 11cc (including call).
; ------------------------------------------------------------------------------
GLOBAL get_score_digit

#endif
