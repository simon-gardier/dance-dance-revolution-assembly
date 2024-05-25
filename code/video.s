processor 16f1789
#include <xc.inc>
#include "video.inc"
#include "utils.inc"
#include "ram.inc"
#include "bits.inc"

#ifndef VIDEO_S
#define VIDEO_S

PSECT page0, global, class = CODE, delta = 2
; ------------------------------------------------------------------------------
; Subroutine hsync()
; ------------------------------------------------------------------------------
hsync:
    ; front porch (0.3V)
    banksel LATA
    bcf     LATC, DAC_OUTPUT_2
    bsf     LATA, DAC_OUTPUT_1
    ; wait for 12cc (1.5us) - 3cc = 9cc
    nopfor  9

    ; sync pulse (0V)
    banksel LATA
    bcf     LATC, DAC_OUTPUT_2
    bcf     LATA, DAC_OUTPUT_1
    ; wait for 38cc (4.75us) - 3cc = 35cc
    nop
    movlw   17
    call    wait_setup
    call    wait

    ; back porch (0.3V)
    banksel LATA
    bcf     LATC, DAC_OUTPUT_2
    bsf     LATA, DAC_OUTPUT_1
    return
    
; ------------------------------------------------------------------------------
; Subroutine long_sync()
; ------------------------------------------------------------------------------
long_sync:
    ; long sync (0V)
    banksel LATA
    bcf     LATC, DAC_OUTPUT_2
    bcf     LATA, DAC_OUTPUT_1
    ; wait for 240cc (30us) - 2cc = 238cc = 119dcc
    movlw   119
    call    wait_setup
    call    wait
    ; short pulse (0.3V)
    bcf     LATC, DAC_OUTPUT_2
    bsf     LATA, DAC_OUTPUT_1
    ; wait for 16cc (2us) - 7cc = 9cc
    nopfor  9
    return

; ------------------------------------------------------------------------------
; Subroutine short_sync()
; ------------------------------------------------------------------------------
short_sync:
    ; short sync (0V)
    banksel LATA
    bcf     LATC, DAC_OUTPUT_2
    bcf     LATA, DAC_OUTPUT_1
    ; wait for 16cc (2us) - 2cc = 14cc
    nopfor  14
    ; long pulse (0.3V)
    bcf     LATC, DAC_OUTPUT_2
    bsf     LATA, DAC_OUTPUT_1
    ; wait for 240cc (30us) - 9cc = 115dcc + 1cc
    nop
    movlw   115
    call    wait_setup
    call    wait
    return

; ------------------------------------------------------------------------------
; Subroutine vsync_empty_lines()
; ------------------------------------------------------------------------------
vsync_empty_lines:
    movwf   lines_count
vsync_empty_lines_loop:    
    call    hsync
    ; wait for 46cc (5,75us) - 4cc + 416cc (52us) - 17cc = 219dcc + 1cc   
    nop
    movlw   219
    call    wait_setup
    decf    lines_count, 1                  
    btfsc   STATUS, Z                       
    goto    vsync_empty_lines_end
    call    wait
    nopfor  10
    goto    vsync_empty_lines_loop
vsync_empty_lines_end:
    call    wait
    return

; ------------------------------------------------------------------------------
; Subroutine init_frame_buffer()
; ------------------------------------------------------------------------------
init_frame_buffer:
    movlw   9
    movwf   pixels_count
    movlw   BACKGROUND_COLOR
clear_frame_buffer_loop:
    REPT    32
        movwi   FSR0++
    endm
    decfsz  pixels_count
    goto    clear_frame_buffer_loop
    return

#endif
    