processor 16f1789
#include <xc.inc>

#ifndef UTILS_INC
#define UTILS_INC

; ------------------------------------------------------------------------------
; Macro nopfor
; Nop for cc clock cycle
; ------------------------------------------------------------------------------
nopfor MACRO cc
    REPT cc
    nop
    endm
    endm

; ------------------------------------------------------------------------------
; Subroutine wait()
; !! Warning !! wait_setup() must have been called before
; Doesn't change bank.
; ------------------------------------------------------------------------------
GLOBAL wait

; ------------------------------------------------------------------------------
; Subroutine wait_setup()
; Usage example :
;   movlw to_wait
;   call wait_setup
; Where to_wait should be the number of instructions to wait / 2. 1cc = 125us
; "movlw to_wait" and "call wait_setup" are implicitely counted in the waiting time,
; do not add them in the to_wait value.
; Change bank to bank 0 (PORTx, TMRx).
; ------------------------------------------------------------------------------
GLOBAL wait_setup

#endif
