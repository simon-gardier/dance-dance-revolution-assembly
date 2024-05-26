; ------------------------------------------------------------------------------
;                         ___     ___     ___
;                        |   \   |   \   | _ \
;                        | |) |  | |) |  |   /
;                        |___/   |___/   |_|_\
;                       _|"""""|_|"""""|_|"""""|
;                       "`-0-0-'"`-0-0-'"`-0-0-'
;
;   @author Gardier Simon, Graillet Arthur, Hormat-Allah Sa�d, Trinh Camille
; ------------------------------------------------------------------------------
#ifndef MAIN
#define MAIN

processor 16f1789
#include <xc.inc>
#include "bits.inc"
#include "ram.inc"
#include "draw.s"
#include "game_logic.s"
#include "music.s"
#include "inputs.s"

CONFIG  FOSC = INTOSC         ; Oscillator Selection (INTOSC oscillator: I/O function on CLKIN pin)
CONFIG  WDTE = OFF            ; Watchdog Timer Enable (WDT disabled)
CONFIG  PWRTE = OFF           ; Power-up Timer Enable (PWRT disabled)
CONFIG  MCLRE = OFF           ; MCLR Pin Function Select (MCLR/VPP pin function is digital input)
CONFIG  CP = OFF              ; Flash Program Memory Code Protection (Program memory code protection is disabled)
CONFIG  CPD = OFF             ; Data Memory Code Protection (Data memory code protection is disabled)
CONFIG  BOREN = ON            ; Brown-out Reset Enable (Brown-out Reset enabled)
CONFIG  CLKOUTEN = OFF        ; Clock Out Enable (CLKOUT function is disabled. I/O or oscillator function on the CLKOUT pin)
CONFIG  IESO = ON             ; Internal/External Switchover (Internal/External Switchover mode is enabled)
CONFIG  FCMEN = ON            ; Fail-Safe Clock Monitor Enable (Fail-Safe Clock Monitor is enabled)
CONFIG  WRT = OFF             ; Flash Memory Self-Write Protection (Write protection off)
CONFIG  VCAPEN = OFF          ; Voltage Regulator Capacitor Enable bit (Vcap functionality is disabled on RA6.)
CONFIG  PLLEN = OFF           ; PLL Enable (4x PLL disabled)
CONFIG  STVREN = ON           ; Stack Overflow/Underflow Reset Enable (Stack Overflow or Underflow will cause a Reset)
CONFIG  BORV = LO             ; Brown-out Reset Voltage Selection (Brown-out Reset Voltage (Vbor), low trip point selected.)
CONFIG  LPBOR = OFF           ; Low Power Brown-Out Reset Enable Bit (Low power brown-out is disabled)
CONFIG  LVP = OFF

; ------------------------------------------------------------------------------
; ============================ Program start ===================================
; ------------------------------------------------------------------------------
PSECT reset_vec, global, class = CODE, delta = 2
    goto    setup

; ------------------------------------------------------------------------------
; ========================== Interrupts vector =================================
; ------------------------------------------------------------------------------
PSECT isr_vec, global, class = CODE, delta = 2
    retfie

; ------------------------------------------------------------------------------
; ========================= Initialisation code ================================
; ------------------------------------------------------------------------------
PSECT page0, global, class = CODE, delta = 2
setup:
    banksel OSCCON                          ; set clock to 32Mhz
    movlw   0xf8
    movwf   OSCCON

    ; ---- PORTx initialization ----
    banksel LATA                            ; clear the LATCH values of the pins of PORTA
    clrf    LATA
    banksel TRISA                           ; set PORTA data direction as output (used for the generation of 0-0.3V signal)
    clrf    TRISA

    banksel LATB                            ; clear the LATCH values of the pins of PORTB
    clrf    LATB

    banksel TRISB                           ; set buttons pins as input
    bsf     TRISB, BUTTON_UP
    bsf     TRISB, BUTTON_RIGHT
    bsf     TRISB, BUTTON_DOWN
    bsf     TRISB, BUTTON_LEFT
    bsf     TRISB, BUTTON_RESET

    banksel ANSELB                          ; set buttons pins as digital I/O
    bcf     ANSELB, BUTTON_UP
    bcf     ANSELB, BUTTON_RIGHT
    bcf     ANSELB, BUTTON_DOWN
    bcf     ANSELB, BUTTON_LEFT
    bcf     ANSELB, BUTTON_RESET

    banksel LATC                            ; clear the LATCH values of the pins of PORTC
    clrf    LATC
    banksel TRISC                           ; set PORTC data direction as output (used for the generation of 0.6-1V signal)
    clrf    TRISC

    banksel LATD                            ; clear the LATCH values of the pins of PORTD
    clrf    LATD
    banksel TRISD                           ; set PORTD data direction as output (used for pad inputs)
    clrf    TRISD

    banksel LATE                            ; clear the LATCH values of the pins of PORTE
    clrf    LATE
    banksel TRISE                           ; set PORTE as output (used to lights up the debug LED and play music)
    clrf    TRISE

    ; ---- wait timer initialization ----
    banksel INTCON
    bcf     INTCON, GIE                     ; disable global interrupts
    bcf     INTCON, TMR0IE                  ; disable Timer0 interrupts
    movlw   0 << TMR0CS & 0 << PSA & 000B   ; enable timer mode for Timer0, enable prescale and prescale to 1:2 (000 = 1:2, ..., 111 = 1:256)
    banksel OPTION_REG
    movwf   OPTION_REG

    ; ---- frame buffer initialization ----
    movlw   LOW(frame_buffer)
    movwf   FSR0L
    movlw   HIGH(frame_buffer)
    movwf   FSR0H
    REPT 6
            call    init_frame_buffer       ; fill frame_buffer with BACKGROUND_COLOR color
    ENDM

    ; ---- models (arrows, characters,...) initialization ----
    pagesel load_models                     ; select the right page
    call    load_models                     ; load models
    pagesel init_arrow_struct
    call    init_arrow_struct               ; init arrow_struct
    IRP index, 0, 1, 2, 3
        movlw   index
        movwf   drawing_index
        call    create_arrow                ; create one arrow at the bottom of each column
    endm
    pagesel $                               ; come back to this page

    ; ---- music initialization ----
    movlw   NOTE_TOTAL_ITERATIONS
    movwf   music_note_iteration_counter    ;frame per note counter initialization
    movlw   MUSIC_LENGTH
    movwf   music_note_index
    movlw   0
    movwf   note_data_index
    movlw   4
    movwf   note_data_index_prev            ;store the previous played note, any value different than the first one to be played works

    ; ---- psmc initialization ----
    banksel PSMC3CON
    movlw   HIGH(50)                        ; set period
    movwf   PSMC3PRH
    movlw   LOW(50)
    movwf   PSMC3PRL
    movlw   HIGH(50)                        ; set duty cycle
    movwf   PSMC3DCH
    movlw   LOW(50)
    movwf   PSMC3DCL
    clrf    PSMC3PHH                        ; no phase offset
    clrf    PSMC3PHL
    movlw   0x01                            ; PSMC clock=64 MHz
    movwf   PSMC3CLK
    bsf     PSMC3STR0,1                     ; output on B, normal polarity
    bsf     PSMC3POL, 1
    bsf     PSMC3OEN, 1
    bsf     PSMC3PRS, 0                     ; set time base as source for all events
    bsf     PSMC3PHS, 0
    bsf     PSMC3DCS, 0
    movlw   11000000B
    movwf   PSMC3CON                        ; enable PSMC in Single-Phase Mode, this also loads steering and time buffers
    banksel TRISC
    clrf    TRISC                           ; enable pin driver

    ; ---- user inputs initialization ----
    clrf    PORTB_previous
    clrf    PORTB_current

    ; ---- miscellanous ----
    clrf    flags                           ; clear flags
    banksel LATE                            ; lights up debug LED (= program started)
    bsf     LATE, DEBUG_LED_PIN

    goto    dance_dance_revolution          ; starts program
    
; ------------------------------------------------------------------------------
; ============================= Main program ===================================
; ------------------------------------------------------------------------------
dance_dance_revolution:
    call    vsync1
    call    draw_frame
    nop
    nop
    call    vsync2
    call    draw_frame
    goto    dance_dance_revolution

; ------------------------------------------------------------------------------
; =============================== Macros =======================================
; ------------------------------------------------------------------------------

; Nop for cc clock cycle
nopfor MACRO cc
    REPT cc
    nop
    endm
    endm

; ------------------------------------------------------------------------------
; ============================= Subroutines ====================================
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Subroutine draw_frame()
; Draw a complete field of 305 lines, see
; http://martin.hinner.info/vga/pal.html
; https://mseduculiegebe-my.sharepoint.com/:b:/g/personal/s_gardier_student_uliege_be/EYyiBGQIo6ZIicdeoGAyw5sB5kXo_giNImZLOaqswmS3sA?e=BpUf3P
; Must be called 15cc (including call) before line start.
; Ends 9cc before next line.
; Change bank to bank 2 (LATx).
; ------------------------------------------------------------------------------
draw_frame:
    movlw   LOW(frame_buffer)       ; move FSR to the begining of frame buffer
    movwf   FSR0L
    movlw   HIGH(frame_buffer)
    movwf   FSR0H
    movlw   HIGH(288)
    movwf   lines_count+1
    movlw   LOW(288)
    movwf   lines_count
draw_frame_loop:
    call    hsync
    ; wait for 46cc (5,75us) - 2cc (return from hsync) - 6cc (instructions to set first output) = 38cc
    movlw   19
    call    wait_setup
    btfsc   flags, ODD_LINE_FLAG    ; if line is odd
    addfsr  FSR0, -(FRAME_WIDTH / 8); then go back in frame buffer to draw the line a second time
    movlw   1 << ODD_LINE_FLAG      ; bit mask for the odd line flag
    xorwf   flags, 1                ; complement the odd line flag
    call    wait

    ; wait for 416cc (52us) - 11cc (time to reach first vsync signal) = 202dcc + 1cc
    movlw   202
    call    wait_setup
    ; draw frame line
    rept 12
        nopfor  2
        moviw   FSR0++
        movwf   LATC
        rept    7
            nopfor  3
            lslf    LATC, 1
        endm
    endm
    movlw   0
    movwf   LATC

    movf    lines_count         ; move f to W and set Z flag if f was zero
    btfsc   STATUS, Z           ; if low byte reaches 0
    decf    lines_count + 1     ; then decrement high byte
    decf    lines_count         ; decrement low byte anyway
    ; check if we are at the end of the field
    movf    lines_count
    btfss   STATUS, Z           ; check if low byte is zero
    goto    next_line           ; loop if it isnt
    movf    lines_count + 1
    btfss   STATUS, Z           ; check if high byte is zero
    goto    next_line           ; loop if it isnt
    call    wait
    return                      ; return if it is (i.e. lines_count == 0)
next_line:
    call    wait
    nopfor  4
    goto    draw_frame_loop

; ------------------------------------------------------------------------------
; Subroutine vsync1()
; Perform short and long sync before field 1.
; Must be called 7cc (including call) before line start.
; Ends 15cc before next line.
; Change bank to bank 0 (PORTx, TMRx).
; ------------------------------------------------------------------------------
vsync1:
    ; line 623
    call    short_sync
    nopfor 2
    call    short_sync
    nopfor 2
    ; line 624
    call    short_sync
    nopfor 2
    call    short_sync
    nopfor 2
    ; line 625
    call    short_sync
    nopfor 2
    call    short_sync
    nopfor 2
    ; line 1
    call    long_sync
    call    long_sync
    ; line 2
    call    long_sync
    call    long_sync
    ; line 3
    call    long_sync
    call    short_sync
    nopfor 2
    ; line 4
    call    short_sync
    movlw   LOW(frame_buffer)               ; move FSR to the begining of frame buffer, required for vsync1_init_frame_buffer_loop
    movwf   FSR0L
    call    short_sync
    movlw   HIGH(frame_buffer)
    movwf   FSR0H
    ; line 5
    call    short_sync
    banksel flags                           ; setup odd_line
    bcf     flags, ODD_LINE_FLAG            ; clear odd line flag
    call    short_sync

    movlw   6                               ; number of empty lines used to init frame buffer
    movwf   lines_count

    ; Init frame buffer
vsync1_init_frame_buffer_loop:
    call    hsync
    ; wait for 46cc (5,75us) - 2cc + 416cc (52us) - 7cc = 226dcc + 1cc
    nop
    movlw   226
    call    wait_setup
    call    init_frame_buffer               ; Init 1/6 of buffer (321cc)
    decf    lines_count, 1
    btfsc   STATUS, Z
    goto    vsync1_draw_top_arrows_loop_init
    call    wait
    goto    vsync1_init_frame_buffer_loop

    ; Draw top arrows
vsync1_draw_top_arrows_loop_init:
    call    wait
    movlw   2                               ; number of empty lines used to draw the top arrows
    movwf   lines_count
vsync1_draw_top_arrows_loop:
    call    hsync
    ; wait for 46cc (5,75us) - 2cc + 416cc (52us) - 7cc = 226dcc + 1cc
    nop
    movlw   226
    call    wait_setup
    movf    lines_count, 0                  ; Put counter in W
    sublw   2                               ; Get the drawing_index
    movwf   drawing_index                   ; Place it in drawing_index
    pagesel draw_arrow_top                  ; Get the right page
    call    draw_arrow_top                  ; Draw 2 top arrows (312cc)
    pagesel $                               ; Come back to this page
    decf    lines_count, 1
    btfsc   STATUS, Z
    goto    vsync1_draw_moving_arrows_loop_init
    call    wait
    goto    vsync1_draw_top_arrows_loop

    ; Draw moving arrows
vsync1_draw_moving_arrows_loop_init:
    call    wait
    movlw   4                               ; number of empty lines used to draw the top arrows
    movwf   lines_count
vsync1_draw_moving_arrows_loop:
    call    hsync
    ; wait for 46cc (5,75us) - 2cc + 416cc (52us) - 7cc = 226dcc + 1cc
    nop
    movlw   226
    call    wait_setup
    movf    lines_count, 0                  ; put counter in W
    sublw   4                               ; get the drawing_index
    movwf   drawing_index                   ; place it in drawing_index
    pagesel draw_arrow_column               ; get the right page
    call    draw_arrow_column               ; draw the column (348~368cc)
    pagesel $                               ; come back to this page
    decf    lines_count, 1
    btfsc   STATUS, Z
    goto    vsync1_empty_lines_loop_init
    call    wait
    goto    vsync1_draw_moving_arrows_loop

vsync1_empty_lines_loop_init:
    call    wait
    movlw   5                               ; number of remaing empty lines to reach total of 25 vsync lines :
    movwf   lines_count                     ; -8 (sync) -6 (clear frame buffer lines) -2 (draw in frame buffer top arrows) -4 (draw in frame buffer column arrows) = 5 empty lines before field 2
vsync1_empty_lines_loop:    
    call    hsync
    ; wait for 46cc (5,75us) - 2cc + 416cc (52us) - 17cc = 221dcc + 1cc   
    nop
    movlw   221
    call    wait_setup
    decf    lines_count, 1                  
    btfsc   STATUS, Z                       
    goto    vsync1_end                      
    call    wait
    nopfor  10
    goto    vsync1_empty_lines_loop
vsync1_end:
    call    wait
    return

; ------------------------------------------------------------------------------
; Subroutine vsync2()
; Perform short and long sync.
; Must be called 7cc (including call) before line start.
; Ends 15cc before next line.
; Change bank to bank 0.
; ------------------------------------------------------------------------------
vsync2:
    ; line 311
    call    short_sync
    nopfor 2
    call    short_sync
    nopfor 2
    ; line 312
    call    short_sync
    nopfor 2
    call    short_sync
    nopfor 2
    ; line 313
    call    short_sync
    nopfor 2
    call    long_sync
    ; line 314
    call    long_sync
    call    long_sync
    ; line 315
    call    long_sync
    call    long_sync
    ; line 316
    call    short_sync
    nopfor 2
    call    short_sync
    nopfor 2
    ; line 317
    call    short_sync
    banksel flags                           ; setup odd_line
    bcf     flags, ODD_LINE_FLAG            ; clear odd line flag
    call    short_sync
    nopfor  2

    ; handle user inputs and get the pressed arrows
    call    hsync
    ; wait for 46cc (5,75us) - 2cc + 416cc (52us) - 5cc = 227dcc + 1cc
    nop
    movlw   227
    call    wait_setup
    pagesel handle_user_inputs
    call    handle_user_inputs      ; MAX 35cc
    pagesel $
    btfsc   flags, BUTTON_RESET 
    ;TODO   Replace nop by reset
    nop
    pagesel press_arrow
    call    press_arrow             ; MAX 324cc
    pagesel $
    call    wait

    ; move the arrows up
    call    hsync
    ; wait for 46cc (5,75us) - 2cc + 416cc (52us) - 5cc = 227dcc + 1cc
    nop
    movlw   227
    call    wait_setup
    pagesel move_arrow
    call    move_arrow
    pagesel $
    call    wait

    ; remove arrows coming at the top of the screen
    call    hsync
    ; wait for 46cc (5,75us) - 2cc + 416cc (52us) - 5cc = 227dcc + 1cc
    nop
    movlw   227
    call    wait_setup
    pagesel verif_arrow
    call    verif_arrow
    pagesel $
    call    wait

    ; update music and get index of the column in which add a new arrow
    call    hsync
    ; wait for 46cc (5,75us) - 2cc + 416cc (52us) - 7cc = 226dcc + 1cc
    nop
    movlw   226
    call    wait_setup
    pagesel update_game_music
    call    update_game_music
    pagesel $
    pagesel create_arrow
    movwf   drawing_index
    movlw   4
    subwf   drawing_index, 0                ; W <- drawing_index - 4
    btfss   STATUS, Z                       ; Skip if drawing_index == 4
    call    create_arrow
    pagesel $
    call    wait

    movlw   13                              ; number of empty lines to generate to reach total of 24 vsync lines :
    movwf   lines_count                     ; - 7 (sync)- 1 (user input check) - 1 (music update line) - 1 (move arrows) - 1 (delete arrows) = 13 empty lines before field 2
vsync2_empty_lines_loop:                    
    call    hsync
    ; wait for 46cc (5,75us) - 2cc + 416cc (52us) - 17cc = 221dcc + 1cc    
    nop
    movlw   221
    call    wait_setup
    decf    lines_count, 1                  
    btfsc   STATUS, Z                       
    goto    vsync2_end                      
    call    wait
    nopfor  10
    goto    vsync2_empty_lines_loop
vsync2_end:
    call    wait
    return

; ------------------------------------------------------------------------------
; Subroutine hsync()
; Common part for all fields lines.
; Must be called 5cc before next output.
; Total duration: 57cc (including call)
; Change bank to bank 2 (LATx).
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
; Perform one long synchronization followed by a short pulse.
; Must be called 5cc (including call) before line start.
; Ends 5cc before next line.
; Change bank to bank 2 (LATx).
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
; Perform one short synchronization followed by a long pulse.
; Must be called 5cc (including call) before line start.
; Ends 7cc before next line.
; Change bank to bank 0 (PORTx, TMRx).
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
; Subroutine init_frame_buffer()
; Set the frame buffer with BACKGROUND_COLOR
; Buffer is 96x144px = 13824px = 1728 bytes. We clear 1/6 (288) per call.
; FSR0 must be set before the FIRST call.
; FSR0 MUST NOT CHANGE BETWEEN THOSE SIX CALLS
; Execution time with call and return : 2 + 3 + 9*35 + 1 = 321 (1932 total)
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
wait_setup:
    bcf     INTCON, TMR0IF      ; clear Timer0 interrupt flag
    sublw   255                 ; substract from 255 (max incremented value for Timer0) the clock cycles requested in W
    nop
    addlw   9                   ; wait_setup() and wait() already take 14cc, we must remove them from the total to wait
    banksel TMR0
    movwf   TMR0
    return

; ------------------------------------------------------------------------------
; Subroutine wait()
; !! Warning !! wait_setup() must have been called before
; Doesn't change bank.
; ------------------------------------------------------------------------------
wait:
    btfss   INTCON, TMR0IF
    goto    wait
    bcf     INTCON, TMR0IF           ; clear Timer0 interrupt flag
    return

#endif
