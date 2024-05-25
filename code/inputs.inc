processor 16f1789
#include <xc.inc>

#ifndef INPUTS_INC
#define INPUTS_INC

; ------------------------------------------------------------------------------
; Subroutine handle_user_inputs()
; - Check user inputs
; - Lights up pad LEDs
; Returns in flags the keys pressed that werent pressed on last call :
;   xx1111xx = all keys pressed,
;   xx0001xx = only right key pressed,
;   xx0011xx = right and down key pressed,...
; Register modified : flags, W
; Total duration: <= 30cc (including call)
; Change bank to bank 2 (LATx)
; ------------------------------------------------------------------------------
GLOBAL handle_user_inputs

#endif
