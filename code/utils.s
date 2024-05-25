processor 16f1789
#include <xc.inc>
#include "utils.inc"
#include "bits.inc"

#ifndef UTILS_S
#define UTILS_S

PSECT page0, global, class = CODE, delta = 2
; ------------------------------------------------------------------------------
; Subroutine wait_setup()
; ------------------------------------------------------------------------------
wait_setup:
    bcf     INTCON, TMR0IF      ; clear Timer0 interrupt flag
    sublw   255                 ; substract from 255 (max incremented value for Timer0) the clock cycles requested in W
    nop
    addlw   9                   ; we must remove wait_setup() and wait() execution time from the total to wait
    banksel TMR0
    movwf   TMR0
    return

; ------------------------------------------------------------------------------
; Subroutine wait()
; ------------------------------------------------------------------------------
wait:
    btfss   INTCON, TMR0IF
    goto    wait
    bcf     INTCON, TMR0IF           ; clear Timer0 interrupt flag
    return

#endif
