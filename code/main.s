; ------------------------------------------------------------------------------
;                          ____      ____     ____     
;                         |  _"\    |  _"\ U |  _"\ u  
;                        /| | | |  /| | | | \| |_) |/  
;                        U| |_| |\ U| |_| |\ |  _ <    
;                         |____/ u  |____/ u |_| \_\
;                          |||_      |||_    //   \\_  
;                         (__)_)    (__)_)  (__)  (__) 
;
;   @author Gardier Simon, Graillet Arthur, Hormat-Allah Saïd, Trinh Camille
; ------------------------------------------------------------------------------

processor 16f1789
#include <xc.inc>

#include "bits.inc"
#include "ram.inc"
#include "draw.inc"
#include "game_logic.inc"
#include "music.inc"
#include "inputs.inc"
#include "utils.inc"
#include "video.inc"

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
    bsf     TRISB, ARROW_UP
    bsf     TRISB, ARROW_RIGHT
    bsf     TRISB, ARROW_DOWN
    bsf     TRISB, ARROW_LEFT

    banksel ANSELB                          ; set buttons pins as digital I/O
    bcf     ANSELB, ARROW_UP
    bcf     ANSELB, ARROW_RIGHT
    bcf     ANSELB, ARROW_DOWN
    bcf     ANSELB, ARROW_LEFT

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

    ; ---- music initialization ----
    movlw   NOTE_TOTAL_ITERATIONS
    movwf   music_note_iteration_counter    ;frame per note counter initialization
    movlw   TETRIS_SONG_LENGTH
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
    movlw   0x00                            ; PSMC clock=64 MHz
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
    
    ; ---- other -----
    clrf    flags                           ; clear flags (ODD_LINE_FLAG = 0, STATE = MENU_STATE)
    banksel session_best_score
    clrf    session_best_score              ; set the best score of the session to 0
    clrf    session_best_score+1
    clrf    score
    clrf    score+1

    ; ---- program start ----
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
    ; wait for 46cc (back porch) - 2cc (return from hsync) - 4cc (cc to reach first pixel output after call wait) = 42cc
    movlw   21
    call    wait_setup
    banksel flags
    btfsc   flags, ODD_LINE_FLAG    ; if line is odd
    addfsr  FSR0, -FRAME_WIDTH; then go back in frame buffer to draw the line a second time
    movlw   1 << ODD_LINE_FLAG      ; bit mask for the odd line flag
    xorwf   flags, 1                ; complement the odd line flag
    call    wait

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
    ; end 52us - 382cc = 34cc before end of line

    banksel lines_count
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
    goto    next_line1          ; loop if it isnt
    nopfor  12
    return                      ; return if it is (i.e. lines_count == 0)
next_line:
    nopfor  3
next_line1:
    nopfor  13
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

    movlw   6
    movwf   lines_count
vsync1_init_frame_buffer_loop:
    call    hsync
    ; wait for 46cc (5,75us) - 2cc + 416cc (52us) - 7cc = 226dcc + 1cc
    nop
    movlw   226
    call    wait_setup
    call    init_frame_buffer               ; Init 1/6 of buffer (321cc)
    decf    lines_count, 1
    btfsc   STATUS, Z
    goto    vsync1_init_frame_buffer_loop_end
    call    wait
    goto    vsync1_init_frame_buffer_loop
vsync1_init_frame_buffer_loop_end:
    btfss   flags, STATE_FLAG		    ; if state == MENU_STATE
    goto    vsync1_draw_menu                ; then go to menu draw
    goto    vsync1_draw_game		    ; else go to game draw

vsync1_draw_menu:
    ; 1 line - draw "Dance\nDance" line
    call    wait
    ; wait for 46cc (5,75us) - 2cc + 416cc (52us) - 5cc = 227dcc + 1cc
    nop
    movlw   227
    pagesel draw_menu_title1
    call    draw_menu_title1
    pagesel $
    call    wait
    
    ; 1 line - draw "Revolution" line
    call    hsync
    ; wait for 46cc (5,75us) - 2cc + 416cc (52us) - 5cc = 227dcc + 1cc
    nop
    movlw   227
    pagesel draw_menu_title2
    call    draw_menu_title2
    pagesel $
    
    ; 1 line - draw best score line
    call    hsync
    ; wait for 46cc (5,75us) - 2cc + 416cc (52us) - 5cc = 227dcc + 1cc
    nop
    movlw   227
    pagesel draw_menu_best_score
    call    draw_menu_best_score
    pagesel $
    btfss   flags, NEW_BEST_SCORE
    goto    vsync1_draw_menu_notice
    movlw   LOW(BEST_SCORE_TROPHY_TOP_LEFT)
    movwf   FSR0L
    movlw   HIGH(BEST_SCORE_TROPHY_TOP_LEFT)
    movwf   FSR0H
    pagesel draw_trophy
    call    draw_trophy
    pagesel $
    
vsync1_draw_menu_notice:
    call    wait
    ; 1 line - draw notice
    call    hsync
    ; wait for 46cc (5,75us) - 2cc + 416cc (52us) - 9cc = 225dcc + 1cc
    nop
    movlw   225
    pagesel draw_menu_notice
    call    draw_menu_notice
    pagesel $

vsync1_draw_menu_empty_lines:
    call    wait
    movlw   7				    ; number of remaing empty lines to reach total of 25 vsync lines :
    call    vsync_empty_lines               ; -8 (sync) 
                                            ; -6 (clear frame buffer lines) 
                                            ; -1 (draw title part 1) 
                                            ; -1 (draw title part 2) 
                                            ; -1 (draw best score) 
                                            ; -1 (draw notice) = 7 empty lines before field 1
    return

vsync1_draw_game:
    ; 1 line - draw game score
    call    wait
    nopfor  2
    call    hsync
    ; wait for 46cc (5,75us) - 2cc + 416cc (52us) - 5cc = 227dcc + 1cc
    nop
    movlw   227
    call    wait_setup
    pagesel draw_game_score
    call    draw_game_score
    pagesel $
    call    wait

vsync1_draw_game_hearts:
    ; 1 line - draw game hearts
    call    hsync
    ; wait for 46cc (5,75us) - 2cc + 416cc (52us) - 5cc = 227dcc + 1cc
    nop
    movlw   227
    call    wait_setup
    pagesel draw_game_hearts
    call    draw_game_hearts
    pagesel $
    call    wait

vsync1_draw_game_top_arrows:
    ; 1 line - draw top arrows
    call    hsync
    ; wait for 46cc (5,75us) - 2cc + 416cc (52us) - 7cc = 226dcc + 1cc
    nop
    movlw   226
    call    wait_setup
    pagesel draw_arrow_top                  ; Get the right page
    call    draw_arrow_top                  ; Draw 2 top arrows (312cc)
    pagesel $                               ; Come back to this page
    call    wait

    ; 4 lines - draw moving arrows
    movlw   4                               ; number of empty lines used to draw the top arrows
    movwf   lines_count
vsync1_draw_game_arrows_loop:
    call    hsync
    ; wait for 46cc (5,75us) - 2cc + 416cc (52us) - 9cc = 225dcc + 1cc
    nop
    movlw   225
    call    wait_setup
    movf    lines_count, 0                  ; put counter in W
    sublw   4                               ; get the drawing_index
    movwf   drawing_index                   ; place it in drawing_index
    pagesel draw_arrow_column               ; get the right page
    call    draw_arrow_column               ; draw the column (348~368cc)
    pagesel $                               ; come back to this page
    decf    lines_count, 1
    btfsc   STATUS, Z
    goto    vsync1_draw_game_empty_lines
    call    wait
    nopfor  2
    goto    vsync1_draw_game_arrows_loop

vsync1_draw_game_empty_lines:
    call    wait
    movlw   4				    ; number of remaing empty lines to reach total of 25 vsync lines :
    call    vsync_empty_lines               ; -8 (sync) 
    return                                  ; -6 (clear frame buffer lines) 
                                            ; -1 (draw game score) 
                                            ; -1 (draw game hearts) 
                                            ; -1 (draw top arrows) 
                                            ; -4 (draw in frame buffer column arrows) = 4 empty lines before field 1

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
    banksel flags
    bcf     flags, ODD_LINE_FLAG	    ; clear line flag (used to draw each buffer line two times)
    call    short_sync
    nopfor  2

    ;1 line - handle user inputs and puts in flags the newly pressed arrows
    call    hsync
    ; wait for 46cc (5,75us) - 2cc + 416cc (52us) - 5cc = 227dcc + 1cc
    nop
    movlw   227
    call    wait_setup
    pagesel handle_user_inputs
    call    handle_user_inputs
    pagesel $
    btfss   flags, STATE_FLAG		    ; if state == MENU_STATE
    goto    vsync2_menu_update              ; then go to menu update
    goto    vsync2_game_update		    ; else go to game update

vsync2_menu_update:
    call    wait
    ; update music and get index of the column in which add a new arrow
    call    hsync
    ; wait for 46cc (5,75us) - 2cc + 416cc (52us) - 9cc = 225dcc + 1cc
    nop
    movlw   225
    call    wait_setup
    pagesel update_music
    call    update_music
    pagesel $
    btfsc   flags, ARROW_SELECTION
    goto    vsync2_menu_update_to_game

    ; remaining vsync2 empty lines
    call    wait
    movlw   15                              ; number of empty lines to generate to reach total of 24 vsync lines :
    call    vsync_empty_lines               ; -7 (sync) -1 (user input check) -1 (update music) = 16 empty lines before field 2
    return
    
vsync2_menu_update_to_game:
    ; 1 line - prepare program to start a new game
    call    wait
    nopfor  4
    call    hsync
    ; wait for 46cc (5,75us) - 2cc + 416cc (52us) - 9cc = 225dcc + 1cc
    nop
    movlw   225
    bsf	    flags, STATE_FLAG               ; set program state as IN_GAME_STATE
    ; game reset
    clrf    score
    clrf    score+1
    bcf     flags, NEW_BEST_SCORE
    banksel hearts
    movlw   MAX_HEARTS
    movwf   hearts
    pagesel init_arrow_struct
    call    init_arrow_struct
    pagesel $
    ; music reset
    movlw   NOTE_TOTAL_ITERATIONS
    movwf   music_note_iteration_counter
    movlw   TETRIS_SONG_LENGTH
    movwf   music_note_index
    movlw   0
    movwf   note_data_index
    movlw   4
    movwf   note_data_index_prev
    call    wait

    ; remaining vsync2 empty lines
    movlw   15                              ; number of empty lines to generate to reach total of 24 vsync lines :
    call    vsync_empty_lines               ; -7 (sync) -1 (user input check) -1 (update music/test user inputs) -1 (reset) = 15 empty lines before field 2
    return

vsync2_game_update:
    call    wait
    ; 1 line - remove pressed arrows, increment score
    call    hsync
    ; wait for 46cc (5,75us) - 2cc + 416cc (52us) - 5cc = 227dcc + 1cc
    nop
    movlw   227
    call    wait_setup
    pagesel press_arrow
    call    press_arrow
    pagesel $
    call    wait

    ; 1 line - move the arrows up
    call    hsync
    ; wait for 46cc (5,75us) - 2cc + 416cc (52us) - 5cc = 227dcc + 1cc
    nop
    movlw   227
    call    wait_setup
    pagesel move_arrow
    call    move_arrow
    pagesel $
    call    wait

    ; 1 line - remove arrows coming at the top of the screen
    call    hsync
    ; wait for 46cc (5,75us) - 2cc + 416cc (52us) - 7cc = 226dcc + 1cc
    nop
    movlw   226
    call    wait_setup
    pagesel verif_arrow
    call    verif_arrow
    pagesel $
    banksel hearts		    
    movf    hearts, 1
    btfsc   STATUS, Z			    ; if hearts == 0
    goto    vsync2_game_update_to_menu      ; then update program to dispolay the menu

vsync2_game_update_music:
    call    wait
    nopfor  2
    ; update music and get index of the column in which add a new arrow
    call    hsync
    ; wait for 46cc (5,75us) - 2cc + 416cc (52us) - 9cc = 225dcc + 1cc
    nop
    movlw   225
    call    wait_setup
    pagesel update_music
    call    update_music
    pagesel $
    pagesel create_arrow
    movwf   drawing_index
    movlw   4
    subwf   drawing_index, 0                ; W <- drawing_index - 4
    btfss   STATUS, Z                       ; Skip if drawing_index == 4
    call    create_arrow
    pagesel $
    call    wait

    ; remaining vsync2 empty lines
    movlw   12                              ; number of empty lines to generate to reach total of 24 vsync lines :
    call    vsync_empty_lines               ; -7 (sync)
                                            ; -1 (user input check) 
                                            ; -1 (pressed arrows) 
                                            ; -1 (move arrows) 
                                            ; -1 (delete arrows) 
                                            ; -1 (music update) = 12 empty lines before field 2
    return

vsync2_game_update_to_menu:
    call    wait
    call    hsync
    ; wait for 46cc (5,75us) - 2cc + 416cc (52us) - 9cc = 225dcc + 1cc
    nop
    movlw   225
    call    wait_setup
    bcf	    flags, STATE_FLAG               ; set program state as MENU_STATE
    ; ----- reset music -----
    movlw   NOTE_TOTAL_ITERATIONS
    movwf   music_note_iteration_counter    ; frame per note counter initialization
    movlw   TETRIS_SONG_LENGTH
    movwf   music_note_index
    movlw   0
    movwf   note_data_index
    movlw   4
    movwf   note_data_index_prev            ; store the previous played note, any value different than the first one to be played works
    ; ---- update best score -----
    banksel session_best_score
    movf    score+1, 0
    subwf   session_best_score+1, 0
    btfss   STATUS, C
    goto    update_best_score
    btfss   STATUS, Z
    goto    vsync2_game_update_to_menu_end
    
    movf    score, 0
    subwf   session_best_score, 0
    btfss   STATUS, C
    goto    update_best_score
    btfss   STATUS, Z
    goto    vsync2_game_update_to_menu_end
update_best_score:
    movf    score+1, 0
    movwf   session_best_score+1
    movf    score, 0
    movwf   session_best_score
    bsf     flags, NEW_BEST_SCORE
    
    
vsync2_game_update_to_menu_end:
    movf    session_best_score+1, 0
    movwf   score+1
    movf    session_best_score, 0
    movwf   score
    call    wait

    ; remaining vsync2 empty lines
    movlw   12                              ; number of empty lines to generate to reach total of 24 vsync lines :
    call    vsync_empty_lines               ; -7 (sync)
                                            ; -1 (user input check) 
                                            ; -1 (pressed arrows) 
                                            ; -1 (move arrows) 
                                            ; -1 (delete arrows) 
                                            ; -1 (menu setup) = 12 empty lines before field 2
    return
