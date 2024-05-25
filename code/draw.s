processor 16f1789
#include <xc.inc>
#include "draw.inc"
#include "bits.inc"
#include "ram.inc"
#include "game_logic.inc"

#ifndef DRAW_16BITS_S
#define DRAW_16BITS_S

; ------------------------------------------------------------------------------
; ============================= Subroutines ====================================
; ------------------------------------------------------------------------------
PSECT page1, class = CODE, delta = 2

; ------------------------------------------------------------------------------
; Subroutine draw_arrow_top()
; ------------------------------------------------------------------------------
draw_arrow_top:
    movlw   LOW(ARROW_END_Y)
    movwf   FSR0L
    movlw   HIGH(ARROW_END_Y)
    movwf   FSR0H
    call    draw_arrow_left
    
    movlw   LOW(ARROW_END_Y + ARROW_MARGIN )
    movwf   FSR0L
    movlw   HIGH(ARROW_END_Y + ARROW_MARGIN )
    movwf   FSR0H
    call    draw_arrow_down

    movlw   LOW(ARROW_END_Y + ARROW_MARGIN*2)
    movwf   FSR0L
    movlw   HIGH(ARROW_END_Y + ARROW_MARGIN)
    movwf   FSR0H
    call    draw_arrow_up

    movlw   LOW(ARROW_END_Y + ARROW_MARGIN*3)
    movwf   FSR0L
    movlw   HIGH(ARROW_END_Y + ARROW_MARGIN*3)
    movwf   FSR0H
    call    draw_arrow_right
    return

; ------------------------------------------------------------------------------
; Subroutine draw_arrow_column()
; ------------------------------------------------------------------------------
draw_arrow_column:
    IRP index, 0, 1
        call	get_arrow_struct_index	; Load arrow_struct of the column (17cc)
        addfsr  FSR1, (index*2)         ; Go to the current arrow
        moviw   FSR1++                  ; Get the address of the arrow on the frame buffer in FSR0 (using W)
        movwf   FSR0L
        moviw   FSR1++
        movwf   FSR0H
        movlw   0                       ; Put 0 in W
        iorwf   FSR0L, 0                ; Check if FSR0 != 0
        iorwf   FSR0H, 0
        btfss   STATUS, Z               ; If W != 0 => FSR0 != 0
        call    draw_arrow
    endm
    return

; ------------------------------------------------------------------------------
; Subroutine draw_game_score()
; ------------------------------------------------------------------------------
draw_game_score:
    movlw   LOW(SCORE_TOP_LEFT_Y)
    movwf   FSR0L
    movlw   HIGH(SCORE_TOP_LEFT_Y)
    movwf   FSR0H
    call    draw_S

    movlw   LOW(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT)
    movwf   FSR0L
    movlw   HIGH(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT)
    movwf   FSR0H
    call    draw_c
    
    movlw   LOW(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT*2)
    movwf   FSR0L
    movlw   HIGH(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT*2)
    movwf   FSR0H
    call    draw_o
    
    movlw   LOW(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT*3)
    movwf   FSR0L
    movlw   HIGH(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT*3)
    movwf   FSR0H
    call    draw_r

    movlw   LOW(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT*4)
    movwf   FSR0L
    movlw   HIGH(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT*4)
    movwf   FSR0H
    call    draw_e

    movlw   LOW(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT*5)
    movwf   FSR0L
    movlw   HIGH(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT*5)
    movwf   FSR0H
    movlw   2
    pagesel get_score_digit
    call    get_score_digit
    pagesel $
    call    draw_digit

    movlw   LOW(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT*6)
    movwf   FSR0L
    movlw   HIGH(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT*6)
    movwf   FSR0H
    movlw   1
    pagesel get_score_digit
    call    get_score_digit
    pagesel $
    call    draw_digit

    movlw   LOW(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT*7)
    movwf   FSR0L
    movlw   HIGH(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT*7)
    movwf   FSR0H
    movlw   0
    pagesel get_score_digit
    call    get_score_digit
    pagesel $
    call    draw_digit
    return

; ------------------------------------------------------------------------------
; Subroutine draw_game_hearts()
; ------------------------------------------------------------------------------
draw_game_hearts:
    banksel hearts
    movf    hearts, 0
    brw
    goto    draw_game_hearts_dead
    goto    draw_game_hearts_one_remaining
    goto    draw_game_hearts_two_remaining
    goto    draw_game_hearts_full_hearts

draw_game_hearts_full_hearts:
    movlw   LOW(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT*8)
    movwf   FSR0L
    movlw   HIGH(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT*8)
    movwf   FSR0H
    call    draw_filled_heart
    movlw   LOW(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT*9)
    movwf   FSR0L
    movlw   HIGH(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT*9)
    movwf   FSR0H
    call    draw_filled_heart
    movlw   LOW(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT*10)
    movwf   FSR0L
    movlw   HIGH(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT*10)
    movwf   FSR0H
    call    draw_filled_heart
    return

draw_game_hearts_two_remaining:
    movlw   LOW(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT*8)
    movwf   FSR0L
    movlw   HIGH(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT*8)
    movwf   FSR0H
    call    draw_filled_heart
    movlw   LOW(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT*9)
    movwf   FSR0L
    movlw   HIGH(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT*9)
    movwf   FSR0H
    call    draw_filled_heart
    movlw   LOW(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT*10)
    movwf   FSR0L
    movlw   HIGH(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT*10)
    movwf   FSR0H
    call    draw_empty_heart
    return

draw_game_hearts_one_remaining:
    movlw   LOW(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT*8)
    movwf   FSR0L
    movlw   HIGH(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT*8)
    movwf   FSR0H
    call    draw_filled_heart
    movlw   LOW(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT*9)
    movwf   FSR0L
    movlw   HIGH(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT*9)
    movwf   FSR0H
    call    draw_empty_heart
    movlw   LOW(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT*10)
    movwf   FSR0L
    movlw   HIGH(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT*10)
    movwf   FSR0H
    call    draw_empty_heart
    return

draw_game_hearts_dead:
    movlw   LOW(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT*8)
    movwf   FSR0L
    movlw   HIGH(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT*8)
    movwf   FSR0H
    call    draw_empty_heart
    movlw   LOW(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT*9)
    movwf   FSR0L
    movlw   HIGH(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT*9)
    movwf   FSR0H
    call    draw_empty_heart
    movlw   LOW(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT*10)
    movwf   FSR0L
    movlw   HIGH(SCORE_TOP_LEFT_Y+CHAR_MARGIN_RIGHT*10)
    movwf   FSR0H
    call    draw_empty_heart
    return
    
; ------------------------------------------------------------------------------
; Subroutine draw_menu_title1()
; ------------------------------------------------------------------------------
draw_menu_title1:
    movlw   LOW(TITLE_TOP_LEFT)
    movwf   FSR0L
    movlw   HIGH(TITLE_TOP_LEFT)
    movwf   FSR0H
    call    draw_D
    movlw   LOW(TITLE_TOP_LEFT+CHAR_MARGIN_RIGHT)
    movwf   FSR0L
    movlw   HIGH(TITLE_TOP_LEFT+CHAR_MARGIN_RIGHT)
    movwf   FSR0H
    call    draw_a
    movlw   LOW(TITLE_TOP_LEFT+CHAR_MARGIN_RIGHT*2)
    movwf   FSR0L
    movlw   HIGH(TITLE_TOP_LEFT+CHAR_MARGIN_RIGHT*2)
    movwf   FSR0H
    call    draw_n
    movlw   LOW(TITLE_TOP_LEFT+CHAR_MARGIN_RIGHT*3)
    movwf   FSR0L
    movlw   HIGH(TITLE_TOP_LEFT+CHAR_MARGIN_RIGHT*3)
    movwf   FSR0H
    call    draw_c
    movlw   LOW(TITLE_TOP_LEFT+CHAR_MARGIN_RIGHT*4)
    movwf   FSR0L
    movlw   HIGH(TITLE_TOP_LEFT+CHAR_MARGIN_RIGHT*4)
    movwf   FSR0H
    call    draw_e
    
    movlw   LOW(TITLE_TOP_LEFT_LINE_2)
    movwf   FSR0L
    movlw   HIGH(TITLE_TOP_LEFT_LINE_2)
    movwf   FSR0H
    call    draw_D
    movlw   LOW(TITLE_TOP_LEFT_LINE_2+CHAR_MARGIN_RIGHT)
    movwf   FSR0L
    movlw   HIGH(TITLE_TOP_LEFT_LINE_2+CHAR_MARGIN_RIGHT)
    movwf   FSR0H
    call    draw_a
    movlw   LOW(TITLE_TOP_LEFT_LINE_2+CHAR_MARGIN_RIGHT*2)
    movwf   FSR0L
    movlw   HIGH(TITLE_TOP_LEFT_LINE_2+CHAR_MARGIN_RIGHT*2)
    movwf   FSR0H
    call    draw_n
    movlw   LOW(TITLE_TOP_LEFT_LINE_2+CHAR_MARGIN_RIGHT*3)
    movwf   FSR0L
    movlw   HIGH(TITLE_TOP_LEFT_LINE_2+CHAR_MARGIN_RIGHT*3)
    movwf   FSR0H
    call    draw_c
    movlw   LOW(TITLE_TOP_LEFT_LINE_2+CHAR_MARGIN_RIGHT*4)
    movwf   FSR0L
    movlw   HIGH(TITLE_TOP_LEFT_LINE_2+CHAR_MARGIN_RIGHT*4)
    movwf   FSR0H
    call    draw_e
    return

; ------------------------------------------------------------------------------
; Subroutine draw_menu_title2()
; ------------------------------------------------------------------------------
draw_menu_title2:
    movlw   LOW(TITLE_TOP_LEFT_LINE_3)
    movwf   FSR0L
    movlw   HIGH(TITLE_TOP_LEFT_LINE_3)
    movwf   FSR0H
    call    draw_R
    movlw   LOW(TITLE_TOP_LEFT_LINE_3+CHAR_MARGIN_RIGHT)
    movwf   FSR0L
    movlw   HIGH(TITLE_TOP_LEFT_LINE_3+CHAR_MARGIN_RIGHT)
    movwf   FSR0H
    call    draw_e
    movlw   LOW(TITLE_TOP_LEFT_LINE_3+CHAR_MARGIN_RIGHT*2)
    movwf   FSR0L
    movlw   HIGH(TITLE_TOP_LEFT_LINE_3+CHAR_MARGIN_RIGHT*2)
    movwf   FSR0H
    call    draw_v
    movlw   LOW(TITLE_TOP_LEFT_LINE_3+CHAR_MARGIN_RIGHT*3)
    movwf   FSR0L
    movlw   HIGH(TITLE_TOP_LEFT_LINE_3+CHAR_MARGIN_RIGHT*3)
    movwf   FSR0H
    call    draw_o
    movlw   LOW(TITLE_TOP_LEFT_LINE_3+CHAR_MARGIN_RIGHT*4)
    movwf   FSR0L
    movlw   HIGH(TITLE_TOP_LEFT_LINE_3+CHAR_MARGIN_RIGHT*4)
    movwf   FSR0H
    call    draw_l
    movlw   LOW(TITLE_TOP_LEFT_LINE_3+CHAR_MARGIN_RIGHT*5)
    movwf   FSR0L
    movlw   HIGH(TITLE_TOP_LEFT_LINE_3+CHAR_MARGIN_RIGHT*5)
    movwf   FSR0H
    call    draw_u
    movlw   LOW(TITLE_TOP_LEFT_LINE_3+CHAR_MARGIN_RIGHT*6)
    movwf   FSR0L
    movlw   HIGH(TITLE_TOP_LEFT_LINE_3+CHAR_MARGIN_RIGHT*6)
    movwf   FSR0H
    call    draw_t
    movlw   LOW(TITLE_TOP_LEFT_LINE_3+CHAR_MARGIN_RIGHT*7)
    movwf   FSR0L
    movlw   HIGH(TITLE_TOP_LEFT_LINE_3+CHAR_MARGIN_RIGHT*7)
    movwf   FSR0H
    call    draw_i
    movlw   LOW(TITLE_TOP_LEFT_LINE_3+CHAR_MARGIN_RIGHT*8)
    movwf   FSR0L
    movlw   HIGH(TITLE_TOP_LEFT_LINE_3+CHAR_MARGIN_RIGHT*8)
    movwf   FSR0H
    call    draw_o
    movlw   LOW(TITLE_TOP_LEFT_LINE_3+CHAR_MARGIN_RIGHT*9)
    movwf   FSR0L
    movlw   HIGH(TITLE_TOP_LEFT_LINE_3+CHAR_MARGIN_RIGHT*9)
    movwf   FSR0H
    call    draw_n
    return
    
; ------------------------------------------------------------------------------
; Subroutine draw_menu_best_score()
; ------------------------------------------------------------------------------
draw_menu_best_score:
    movlw   LOW(BEST_SCORE_TOP_LEFT)
    movwf   FSR0L
    movlw   HIGH(BEST_SCORE_TOP_LEFT)
    movwf   FSR0H
    call    draw_B
    
    movlw   LOW(BEST_SCORE_TOP_LEFT+CHAR_MARGIN_RIGHT)
    movwf   FSR0L
    movlw   HIGH(BEST_SCORE_TOP_LEFT+CHAR_MARGIN_RIGHT)
    movwf   FSR0H
    call    draw_e
    
    movlw   LOW(BEST_SCORE_TOP_LEFT+CHAR_MARGIN_RIGHT*2)
    movwf   FSR0L
    movlw   HIGH(BEST_SCORE_TOP_LEFT+CHAR_MARGIN_RIGHT*2)
    movwf   FSR0H
    call    draw_s
 
    movlw   LOW(BEST_SCORE_TOP_LEFT+CHAR_MARGIN_RIGHT*3)
    movwf   FSR0L
    movlw   HIGH(BEST_SCORE_TOP_LEFT+CHAR_MARGIN_RIGHT*3)
    movwf   FSR0H
    call    draw_t
    
    movlw   LOW(BEST_SCORE_TOP_LEFT+CHAR_MARGIN_RIGHT*4)
    movwf   FSR0L
    movlw   HIGH(BEST_SCORE_TOP_LEFT+CHAR_MARGIN_RIGHT*4)
    movwf   FSR0H
    call    draw_colon
    
    ; ---- score itself -----
    movlw   LOW(BEST_SCORE_TOP_LEFT+CHAR_MARGIN_RIGHT*5)
    movwf   FSR0L
    movlw   HIGH(BEST_SCORE_TOP_LEFT+CHAR_MARGIN_RIGHT*5)
    movwf   FSR0H
    movlw   2
    pagesel get_score_digit
    call    get_score_digit
    pagesel $
    call    draw_digit

    movlw   LOW(BEST_SCORE_TOP_LEFT+CHAR_MARGIN_RIGHT*6)
    movwf   FSR0L
    movlw   HIGH(BEST_SCORE_TOP_LEFT+CHAR_MARGIN_RIGHT*6)
    movwf   FSR0H
    movlw   1
    pagesel get_score_digit
    call    get_score_digit
    pagesel $
    call    draw_digit

    movlw   LOW(BEST_SCORE_TOP_LEFT+CHAR_MARGIN_RIGHT*7)
    movwf   FSR0L
    movlw   HIGH(BEST_SCORE_TOP_LEFT+CHAR_MARGIN_RIGHT*7)
    movwf   FSR0H
    movlw   0
    pagesel get_score_digit
    call    get_score_digit
    pagesel $
    call    draw_digit
    
    return
    
; ------------------------------------------------------------------------------
; Subroutine draw_menu_notice()
; ------------------------------------------------------------------------------
draw_menu_notice:
    movlw   LOW(NOTICE_TOP_LEFT)
    movwf   FSR0L
    movlw   HIGH(NOTICE_TOP_LEFT)
    movwf   FSR0H
    call    draw_P
    
    movlw   LOW(NOTICE_TOP_LEFT+CHAR_MARGIN_RIGHT)
    movwf   FSR0L
    movlw   HIGH(NOTICE_TOP_LEFT+CHAR_MARGIN_RIGHT)
    movwf   FSR0H
    call    draw_r
    
    movlw   LOW(NOTICE_TOP_LEFT+CHAR_MARGIN_RIGHT*2)
    movwf   FSR0L
    movlw   HIGH(NOTICE_TOP_LEFT+CHAR_MARGIN_RIGHT*2)
    movwf   FSR0H
    call    draw_e
 
    movlw   LOW(NOTICE_TOP_LEFT+CHAR_MARGIN_RIGHT*3)
    movwf   FSR0L
    movlw   HIGH(NOTICE_TOP_LEFT+CHAR_MARGIN_RIGHT*3)
    movwf   FSR0H
    call    draw_s
    
    movlw   LOW(NOTICE_TOP_LEFT+CHAR_MARGIN_RIGHT*4)
    movwf   FSR0L
    movlw   HIGH(NOTICE_TOP_LEFT+CHAR_MARGIN_RIGHT*4)
    movwf   FSR0H
    call    draw_s

    movlw   LOW(NOTICE_ARROW_TOP_LEFT)
    movwf   FSR0L
    movlw   HIGH(NOTICE_ARROW_TOP_LEFT)
    movwf   FSR0H
    call    draw_arrow_up
    return

; ------------------------------------------------------------------------------
; Subroutine draw_digit()
; Draw the digit store in W, W must be in range [0;9]
; Total duration: 35cc (including call)
; Change W
; ------------------------------------------------------------------------------
draw_digit:
    lslf    WREG, 1
    brw
    call    draw_0
    return
    call    draw_1
    return
    call    draw_2
    return
    call    draw_3
    return
    call    draw_4
    return
    call    draw_5
    return
    call    draw_6
    return
    call    draw_7
    return
    call    draw_8
    return
    call    draw_9
    return

; ------------------------------------------------------------------------------
; Local Subroutine draw_arrow()
; Draw a arrow in the frame buffer.
; FSR0 must point to the top-left position of the arrow to draw.
; drawing_index must contains the index of the arrow type [0;3].
; Total duration: 108cc (including call)
; Change bank to bank ?.
; ------------------------------------------------------------------------------
draw_arrow:
    movf    drawing_index, 0
    lslf    WREG, 1
    brw
    call    draw_arrow_left
    return
    call    draw_arrow_down
    return
    call    draw_arrow_up
    return
    call    draw_arrow_right
    return

; ------------------------------------------------------------------------------
; Local Subroutine get_arrow_struct_index()
; Place the address of the arrow column in arrow_struct in FSR1.
; drawing_index must contains the index of the arrow type [0;3].
; Total duration: 17cc (including call)
; Change FSR1 pointer
; ------------------------------------------------------------------------------
get_arrow_struct_index:
    call    index_draw_arrow_column     ; Get the number of instruction to jump (6)
    brw                                 ; Jump to right address
    IRP column_index, 0, 1, 2, 3
        movlw   LOW(arrow_struct + column_index*2*ARROW_COLUMN_CAPACITY)
        movwf   FSR1L
        movlw   HIGH(arrow_struct + column_index*2*ARROW_COLUMN_CAPACITY)
        movwf   FSR1H
        return
    endm

; ------------------------------------------------------------------------------
; Local Subroutine index_draw_arrow_column()
; drawing_index must contains the index of the arrow type [0;3].
; Total duration: 7cc (including call)
; ------------------------------------------------------------------------------
index_draw_arrow_column:
    movf    drawing_index, 0        ; Put drawing_index in W.
    brw                             ; Jump to right address
    IRP index, 0, 1, 2, 3
        retlw   (index*5)
    endm

; ------------------------------------------------------------------------------
; Local Subroutines draw_x() for 8x8 bits models
; Total duration: 28cc (including call)
; Change FSR0
; ------------------------------------------------------------------------------
draw_S:
    IRP slice,	01111100B, \
                11000110B, \
                11000000B, \
                01000000B, \
                00111100B, \
                00000110B, \
                11000110B, \
                01111100B
        movlw   slice
        iorwf   INDF0, 1
        addfsr  FSR0, FRAME_WIDTH 
    endm
    return
    
draw_P:
    IRP slice,	11111100B, \
                11000110B, \
                11000110B, \
                11111100B, \
                11000000B, \
                11000000B, \
                11000000B, \
                11000000B
        movlw   slice
        iorwf   INDF0, 1
        addfsr  FSR0, FRAME_WIDTH 
    endm
    return

draw_c:
    IRP slice,	00000000B, \
                00000000B, \
                00000000B, \
                01111100B, \
                11000110B, \
                11000000B, \
                11000110B, \
                01111100B
        movlw   slice
        iorwf   INDF0, 1
        addfsr  FSR0, FRAME_WIDTH 
    endm
    return

draw_o:
    IRP slice,	00000000B, \
                00000000B, \
                00000000B, \
                01111100B, \
                11000110B, \
                11000110B, \
                11000110B, \
                01111100B
        movlw   slice
        iorwf   INDF0, 1
        addfsr  FSR0, FRAME_WIDTH 
    endm
    return

draw_r:
    IRP slice,	00000000B, \
                00000000B, \
                00000000B, \
                11011110B, \
                11100000B, \
                11000000B, \
                11000000B, \
                11000000B
        movlw   slice
        iorwf   INDF0, 1
        addfsr  FSR0, FRAME_WIDTH 
    endm
    return

draw_e:
    IRP slice,	00000000B, \
                00000000B, \
                00000000B, \
                01111100B, \
                11000110B, \
                11111110B, \
                11000000B, \
                01111100B
        movlw   slice
        iorwf   INDF0, 1
        addfsr  FSR0, FRAME_WIDTH 
    endm
    return

draw_0:
    IRP slice,	01111100B, \
                11000110B, \
                11001110B, \
                11011110B, \
                11010110B, \
                11110110B, \
                11000110B, \
                01111100B
        movlw   slice
        iorwf   INDF0, 1
        addfsr  FSR0, FRAME_WIDTH 
    endm
    return
    
draw_1:
    IRP slice,	00011000B, \
                00111000B, \
                00111000B, \
                00011000B, \
                00011000B, \
                00011000B, \
                00011000B, \
                00111100B
        movlw   slice
        iorwf   INDF0, 1
        addfsr  FSR0, FRAME_WIDTH 
    endm
    return

draw_2:
    IRP slice,	01111100B, \
                11000110B, \
                00000110B, \
                01111100B, \
                11000000B, \
                11000000B, \
                11000110B, \
                11111110B
        movlw   slice
        iorwf   INDF0, 1
        addfsr  FSR0, FRAME_WIDTH 
    endm
    return

draw_3:
    IRP slice,	11111110B, \
                00001100B, \
                00011000B, \
                00111100B, \
                00000110B, \
                00000110B, \
                11000110B, \
                01111100B
        movlw   slice
        iorwf   INDF0, 1
        addfsr  FSR0, FRAME_WIDTH 
    endm
    return

draw_4:
    IRP slice,	00011110B, \
                00110110B, \
                01100110B, \
                11000110B, \
                11111110B, \
                00000110B, \
                00000110B, \
                00000110B
        movlw   slice
        iorwf   INDF0, 1
        addfsr  FSR0, FRAME_WIDTH 
    endm
    return

draw_5:
    IRP slice,	11111100B, \
                11000000B, \
                11000000B, \
                11111100B, \
                00000110B, \
                00000110B, \
                11000100B, \
                01111100B
        movlw   slice
        iorwf   INDF0, 1
        addfsr  FSR0, FRAME_WIDTH 
    endm
    return
    
draw_6:
    IRP slice,	01111100B, \
                11000110B, \
                11000000B, \
                11111100B, \
                11000110B, \
                11000110B, \
                11000110B, \
                01111000B
        movlw   slice
        iorwf   INDF0, 1
        addfsr  FSR0, FRAME_WIDTH 
    endm
    return

draw_7:
    IRP slice,	11111110B, \
                11000110B, \
                00001100B, \
                00011000B, \
                00110000B, \
                00110000B, \
                00110000B, \
                00110000B
        movlw   slice
        iorwf   INDF0, 1
        addfsr  FSR0, FRAME_WIDTH 
    endm
    return

draw_8:
    IRP slice,	01111100B, \
                11000110B, \
                11000110B, \
                01111100B, \
                11000110B, \
                11000110B, \
                11000110B, \
                01111100B
        movlw   slice
        iorwf   INDF0, 1
        addfsr  FSR0, FRAME_WIDTH 
    endm
    return

draw_9:
    IRP slice,	01111100B, \
                11000110B, \
                11000110B, \
                11000110B, \
                01111110B, \
                00000110B, \
                11000110B, \
                01111100B
        movlw   slice
        iorwf   INDF0, 1
        addfsr  FSR0, FRAME_WIDTH 
    endm
    return

draw_D:
    IRP slice,	11111000B, \
                11001100B, \
                11000110B, \
                11000110B, \
                11000110B, \
                11000110B, \
                11001100B, \
                11111100B
        movlw   slice
        iorwf   INDF0, 1
        addfsr  FSR0, FRAME_WIDTH 
    endm
    return

draw_a:
    IRP slice,	00000000B, \
                00000000B, \
                00000000B, \
                01111100B, \
                00000110B, \
                01111110B, \
                11000110B, \
                01111110B
        movlw   slice
        iorwf   INDF0, 1
        addfsr  FSR0, FRAME_WIDTH 
    endm
    return

draw_n:
    IRP slice,	00000000B, \
                00000000B, \
                00000000B, \
                11111100B, \
                11000110B, \
                11000110B, \
                11000110B, \
                11000110B
        movlw   slice
        iorwf   INDF0, 1
        addfsr  FSR0, FRAME_WIDTH 
    endm
    return

draw_R:
    IRP slice,	11111100B, \
                11000110B, \
                11000110B, \
                11111100B, \
                11000110B, \
                11000110B, \
                11000110B, \
                11000110B
        movlw   slice
        iorwf   INDF0, 1
        addfsr  FSR0, FRAME_WIDTH 
    endm
    return

draw_v:
    IRP slice,	00000000B, \
                00000000B, \
                00000000B, \
                11000110B, \
                11000110B, \
                11000110B, \
                01101100B, \
                00111000B
        movlw   slice
        iorwf   INDF0, 1
        addfsr  FSR0, FRAME_WIDTH 
    endm
    return

draw_l:
    IRP slice,	00000000B, \
                00000000B, \
                00000000B, \
                00110000B, \
                00110000B, \
                00110000B, \
                00110000B, \
                00011000B
        movlw   slice
        iorwf   INDF0, 1
        addfsr  FSR0, FRAME_WIDTH 
    endm
    return

draw_u:
    IRP slice,	00000000B, \
                00000000B, \
                00000000B, \
                11000110B, \
                11000110B, \
                11000110B, \
                11000110B, \
                01111100B
        movlw   slice
        iorwf   INDF0, 1
        addfsr  FSR0, FRAME_WIDTH 
    endm
    return
    
draw_t:
    IRP slice,	00000000B, \
                00000000B, \
                00000000B, \
                00110000B, \
                01111100B, \
                00110000B, \
                00110000B, \
                00011100B
        movlw   slice
        iorwf   INDF0, 1
        addfsr  FSR0, FRAME_WIDTH 
    endm
    return
    
draw_i:
    IRP slice,	00000000B, \
                00011000B, \
                00011000B, \
                00000000B, \
                00011000B, \
                00011000B, \
                00011000B, \
                00011000B
        movlw   slice
        iorwf   INDF0, 1
        addfsr  FSR0, FRAME_WIDTH 
    endm
    return
    
draw_B:
    IRP slice,	11111000B, \
                11000110B, \
                11000110B, \
                11111100B, \
                11000110B, \
                11000110B, \
                11000110B, \
                11111000B
        movlw   slice
        iorwf   INDF0, 1
        addfsr  FSR0, FRAME_WIDTH 
    endm
    return
    
draw_s:
    IRP slice,	00000000B, \
                00000000B, \
                00000000B, \
                01111100B, \
                11000000B, \
                01111100B, \
                00000110B, \
                11111100B
        movlw   slice
        iorwf   INDF0, 1
        addfsr  FSR0, FRAME_WIDTH 
    endm
    return
    
draw_empty_heart:
    IRP slice,	00000000B, \
                01100110B, \
                10011001B, \
                10000001B, \
                10000001B, \
                01000010B, \
                00100100B, \
                00011000B
        movlw   slice
        iorwf   INDF0, 1
        addfsr  FSR0, FRAME_WIDTH 
    endm
    return

draw_filled_heart:
    IRP slice,	00000000B, \
                01100110B, \
                11111111B, \
                11111111B, \
                11111111B, \
                01111110B, \
                00111100B, \
                00011000B
        movlw   slice
        iorwf   INDF0, 1
        addfsr  FSR0, FRAME_WIDTH 
    endm
    return
    
draw_colon:
    IRP slice,	00000000B, \
                00000000B, \
                00011000B, \
                000000000B, \
                00000000B, \
                00000000B, \
                00011000B, \
                00000000B
        movlw   slice
        iorwf   INDF0, 1
        addfsr  FSR0, FRAME_WIDTH 
    endm
    return
    
; ------------------------------------------------------------------------------
; Local Subroutines draw_x_model() for 16x16 bits models
; Total duration: 100cc (including call)
; Change FSR0
; ------------------------------------------------------------------------------

draw_arrow_left:
    IRP slice,  0000000110000000B, \
                0000001111000000B, \
                0000011111000000B, \
                0000111110000000B, \
                0001111100000000B, \
                0011111000000000B, \
                0111111111111110B, \
                1111111111111111B, \
                1111111111111111B, \
                0111111111111110B, \
                0011111000000000B, \
                0001111100000000B, \
                0000111110000000B, \
                0000011111000000B, \
                0000001111000000B, \
                0000000110000000B
        movlw   HIGH(slice)		    ; Load the slice in W.
        iorwf   INDF0, 1		    ; Add the 1's to the frame buffer.
    addfsr  FSR0, 1			    ; Move in frame buffer
    movlw   LOW(slice)		    ; Load the slice in W.
        iorwf   INDF0, 1		    ; Add the 1's to the frame buffer.
        addfsr  FSR0, FRAME_WIDTH-1	    ; Move FSR0 to next line
    endm
    return

draw_arrow_up:
    IRP slice,  0000000110000000B, \
                0000001111000000B, \
                0000011111100000B, \
                0000111111110000B, \
                0001111111111000B, \
                0011111111111100B, \
                0111111111111110B, \
                1111101111011111B, \
                1111001111001111B, \
                0110001111000110B, \
                0000001111000000B, \
                0000001111000000B, \
                0000001111000000B, \
                0000001111000000B, \
                0000001111000000B, \
                0000000110000000B
        movlw   HIGH(slice)
        iorwf   INDF0, 1
    addfsr  FSR0, 1
    movlw   LOW(slice)
        iorwf   INDF0, 1
        addfsr  FSR0, FRAME_WIDTH-1
    endm
    return

draw_arrow_down:
    IRP slice,  0000000110000000B, \
                0000001111000000B, \
                0000001111000000B, \
                0000001111000000B, \
                0000001111000000B, \
                0000001111000000B, \
                0110001111000110B, \
                1111001111001111B, \
                1111101111011111B, \
                0111111111111110B, \
                0011111111111100B, \
                0001111111111000B, \
                0000111111110000B, \
                0000011111100000B, \
                0000001111000000B, \
                0000000110000000B
        movlw   HIGH(slice)
        iorwf   INDF0, 1
    addfsr  FSR0, 1
    movlw   LOW(slice)
        iorwf   INDF0, 1
        addfsr  FSR0, FRAME_WIDTH-1
    endm
    return

draw_arrow_right:
    IRP slice,  0000000110000000B, \
                0000001111000000B, \
                0000001111100000B, \
                0000000111110000B, \
                0000000011111000B, \
                0000000001111100B, \
                0111111111111110B, \
                1111111111111111B, \
                1111111111111111B, \
                0111111111111110B, \
                0000000001111100B, \
                0000000011111000B, \
                0000000111110000B, \
                0000001111100000B, \
                0000001111000000B, \
                0000000110000000B
        movlw   HIGH(slice)
        iorwf   INDF0, 1
    addfsr  FSR0, 1
    movlw   LOW(slice)
        iorwf   INDF0, 1
        addfsr  FSR0, FRAME_WIDTH-1
    endm
    return

draw_trophy:
    IRP slice,  0000000000000000B, \
                0000000000000000B, \
                0001100000011000B, \
                1111111111111111B, \
                1001111101111001B, \
                1001111001111001B, \
                1101110101111011B, \
                0111111101111110B, \
                0000111101110000B, \
                0000011111100000B, \
                0000000110000000B, \
                0000000110000000B, \
                0000001111000000B, \
                0000011111100000B, \
                0000111111110000B, \
                0000111111110000B
        movlw   HIGH(slice)
        iorwf   INDF0, 1
    addfsr  FSR0, 1
    movlw   LOW(slice)
        iorwf   INDF0, 1
        addfsr  FSR0, FRAME_WIDTH-1
    endm
    return

#endif
