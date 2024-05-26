#ifndef BITS
#define BITS

processor 16f1789
#include <xc.inc>
#include "ram.inc"

; ------------------------------------------------------------------------------
; =============================== Macros =======================================
; ------------------------------------------------------------------------------
; bits names
#undef  GIE
#define GIE     7
#undef  TMR0IE
#define TMR0IE  5
#undef  TMR0CS
#define TMR0CS  5
#undef  PSA
#define PSA     3
#undef  TMR0IF
#define TMR0IF  2
#undef  PSMC3LD
#define PSMC3LD 6
#define C       0
#define Z       2
#define DEBUG_LED_PIN   2
#define ODD_LINE_FLAG   0
#define DAC_OUTPUT_1    0
#define DAC_OUTPUT_2    7
#define BUTTON_UP       5
#define BUTTON_LEFT     4
#define BUTTON_DOWN     3
#define BUTTON_RIGHT    2
#define BUTTON_RESET    1

; Value used when clearing the screen
BACKGROUND_COLOR    equ 0x0     ;0xff = white, 0x0 = black
FRAME_WIDTH         equ 96
FRAME_HEIGHT        equ 144

CHAR_TOP_START	    equ 5	    ; Number of lines above score label
MAX_COLUMN_ARROW    equ 2       ; Max number of arrow per column
ARROW_END           equ (frame_buffer + (11*12) + 1) ; Spawn of most right arrow in frame buffer (start + (size-1) - 33*line + 1 + offset)
ARROW_SPAWN         equ (frame_buffer + ((144-11-16)*12) + 1) ; Spawn of most right arrow in frame buffer (start + (size-1) - 33*line + 1 + offset)
ARROW_SPACE         equ 3       ; Size of space between arrows top-left corner(byte)
PRESS_MARGIN        equ 8       ; 0,5 arrow. Must be entire value.

#endif
