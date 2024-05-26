#ifndef INPUTS
#define INPUTS

processor 16f1789
#include <xc.inc>
#include "bits.inc"
#include "ram.inc"

; ------------------------------------------------------------------------------
; ============================= Subroutines ====================================
; ------------------------------------------------------------------------------
PSECT page4, global, class = CODE, delta = 2
; ------------------------------------------------------------------------------
; Subroutine handle_user_inputs()
; - Check user inputs
; - Lights up pad LEDs
; Returns with the keys pressed in W :
;   00111110 = all keys pressed,
;   00000010 = only reset key pressed,
;   00000110 = right and reset key pressed,...
; Register modified : flags, W
; Total duration: 35 (including call)
; Change bank to bank 2 (LATx)
; ------------------------------------------------------------------------------
handle_user_inputs:
    banksel PORTB    
    movlw   1 << ODD_LINE_FLAG
    andwf   flags, 1  
button_reset:
    btfss   PORTB, BUTTON_RESET
    goto    button_up
    bsf     flags, BUTTON_RESET
button_up:
    btfss   PORTB, BUTTON_UP
    goto    button_left
    btfsc   PORTB_previous, BUTTON_UP
    goto    button_left
    bsf     flags, BUTTON_UP
button_left:
    btfss   PORTB, BUTTON_LEFT
    goto    button_down
    btfsc   PORTB_previous, BUTTON_LEFT
    goto    button_down
    bsf     flags, BUTTON_LEFT
button_down:
    btfss   PORTB, BUTTON_DOWN
    goto    button_right
    btfsc   PORTB_previous, BUTTON_DOWN
    goto    button_right
    bsf     flags, BUTTON_DOWN
button_right:
    btfss   PORTB, BUTTON_RIGHT
    goto    handle_user_inputs_continue
    btfsc   PORTB_previous, BUTTON_RIGHT
    goto    handle_user_inputs_continue
    bsf     flags, BUTTON_RIGHT
handle_user_inputs_continue:
    movf    PORTB, 0
    movwf   PORTB_previous
    movwf   LATD
    return
#endif
