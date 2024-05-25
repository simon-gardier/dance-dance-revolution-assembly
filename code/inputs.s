processor 16f1789
#include <xc.inc>
#include "bits.inc"
#include "ram.inc"
#include "inputs.inc"

#ifndef INPUTS
#define INPUTS

; ------------------------------------------------------------------------------
; ============================= Subroutines ====================================
; ------------------------------------------------------------------------------
PSECT page3, global, class = CODE, delta = 2

; ------------------------------------------------------------------------------
; Subroutine handle_user_inputs()
; ------------------------------------------------------------------------------
handle_user_inputs:
    banksel PORTB    
    movlw   FLAGS_MASK
    andwf   flags, 1
button_up:
    btfss   PORTB, ARROW_UP
    goto    button_left
    btfsc   PORTB_previous, ARROW_UP
    goto    button_left
    bsf     flags, ARROW_UP
button_left:
    btfss   PORTB, ARROW_LEFT
    goto    button_down
    btfsc   PORTB_previous, ARROW_LEFT
    goto    button_down
    bsf     flags, ARROW_LEFT
button_down:
    btfss   PORTB, ARROW_DOWN
    goto    button_right
    btfsc   PORTB_previous, ARROW_DOWN
    goto    button_right
    bsf     flags, ARROW_DOWN
button_right:
    btfss   PORTB, ARROW_RIGHT
    goto    handle_user_inputs_continue
    btfsc   PORTB_previous, ARROW_RIGHT
    goto    handle_user_inputs_continue
    bsf     flags, ARROW_RIGHT
handle_user_inputs_continue:
    movf    PORTB, 0
    movwf   PORTB_previous
    movwf   LATD
    return
#endif
