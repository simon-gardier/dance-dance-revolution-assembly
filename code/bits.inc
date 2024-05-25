processor 16f1789
#include <xc.inc>
#include "ram.inc"

#ifndef BITS_INC
#define BITS_INC

; ------------------------------------------------------------------------------
; =============================== Macros =======================================
; ------------------------------------------------------------------------------
; pic bits / pins
#undef  GIE
GIE     equ 7
#undef  TMR0IE
TMR0IE  equ 5
#undef  TMR0CS
TMR0CS  equ 5
#undef  PSA
PSA     equ 3
#undef  TMR0IF
TMR0IF  equ 2
#undef  PSMC3LD
PSMC3LD equ 6
C       equ 0
Z       equ 2

; program specific pins
DEBUG_LED_PIN   equ 2
DAC_OUTPUT_1    equ 0
DAC_OUTPUT_2    equ 7
ARROW_UP       equ 5
ARROW_LEFT     equ 4
ARROW_DOWN     equ 3
ARROW_RIGHT    equ 2
ARROW_SELECTION equ 5

; flags bits
FLAGS_MASK      equ 01000011B
ODD_LINE_FLAG   equ 0
STATE_FLAG      equ 1
MENU_STATE      equ 0
IN_GAME_STATE   equ 1
NEW_BEST_SCORE  equ 6

; Screen constants
BACKGROUND_COLOR            equ 0x0     ;0xff = white, 0x0 = black, 1px = 1 bit, 0 = black, 1 = white
FRAME_WIDTH                 equ 12
FRAME_HEIGHT                equ 18
OFFSET_Y                    equ 12      ; Offset in the Y axis to reach visible lines
CHAR_HEIGHT                 equ 8
CHAR_MARGIN_RIGHT           equ 1

; Music
NOTE_TOTAL_ITERATIONS       equ 5       ; 1 frame = 40ms, 10*40 = 400ms per note
TETRIS_SONG_LENGTH          equ 192

; Game constants
SCORE_TOP_LEFT_Y            equ (frame_buffer + (OFFSET_Y*FRAME_WIDTH) + 1)
SCORE_BOTTOM_MARGIN         equ 1

TITLE_TOP_LEFT              equ (frame_buffer + ((OFFSET_Y+3)*FRAME_WIDTH) + 1)
TITLE_TOP_LEFT_LINE_2       equ TITLE_TOP_LEFT + (1+CHAR_HEIGHT)*FRAME_WIDTH
TITLE_TOP_LEFT_LINE_3       equ TITLE_TOP_LEFT_LINE_2 + (1+CHAR_HEIGHT)*FRAME_WIDTH

BEST_SCORE_TOP_LEFT         equ TITLE_TOP_LEFT_LINE_3 + (1+CHAR_HEIGHT*11)*FRAME_WIDTH
BEST_SCORE_TROPHY_TOP_LEFT  equ (BEST_SCORE_TOP_LEFT+CHAR_MARGIN_RIGHT*8) - (FRAME_WIDTH*(CHAR_HEIGHT-1))
  
NOTICE_TOP_LEFT             equ TITLE_TOP_LEFT + (1+CHAR_HEIGHT*8)*FRAME_WIDTH + 2
NOTICE_ARROW_TOP_LEFT       equ (NOTICE_TOP_LEFT+CHAR_MARGIN_RIGHT*5) - (FRAME_WIDTH*(CHAR_HEIGHT-1))

ARROW_SIZE                  equ 2
ARROW_COLUMN_CAPACITY       equ 2       ; Capacity of the columns, maximum 2 moving arrows
ARROW_END_Y                 equ (frame_buffer + ((OFFSET_Y + CHAR_HEIGHT + SCORE_BOTTOM_MARGIN)*FRAME_WIDTH) + 1)
ARROW_START_Y               equ (frame_buffer + (((FRAME_HEIGHT*8)-OFFSET_Y-(ARROW_SIZE*8))*FRAME_WIDTH) + 1)
ARROW_MARGIN                equ 3       ; Size of space between arrows top-left corner(byte)

PRESSURE_ACCEPTABLE_MARGIN  equ 8       ; 0,5 arrow. Must be entire value.
MAX_HEARTS                  equ 3       ; Numbers of failed arrows before game over

#endif
