processor 16f1789
#include <xc.inc>

#ifndef DRAW_INC
#define DRAW_INC

; ------------------------------------------------------------------------------
; Subroutine draw_menu_title1()
; Draw the "Dance Dance" part of the menu title 
; Total duration: 324cc (including call)
; Change FSR0
; ------------------------------------------------------------------------------
GLOBAL draw_menu_title1

; ------------------------------------------------------------------------------
; Subroutine draw_menu_title2()
; Draw the "Revoltion" part of the menu title 
; Total duration: 324cc (including call)
; Change FSR0
; ------------------------------------------------------------------------------
GLOBAL draw_menu_title2
    
; ------------------------------------------------------------------------------
; Subroutine draw_menu_best_score()
; Draw the best score in the menu. The score is NOT taken from session_best_score
; but from score.
; Total duration: 291cc (including call)
; Change FSR0
; ------------------------------------------------------------------------------
GLOBAL draw_menu_best_score

; ------------------------------------------------------------------------------
; Subroutine draw_menu_notice()
; Draw the "Press arrow" notice
; Total duration: 268cc (including call)
; Change FSR0
; ------------------------------------------------------------------------------
GLOBAL draw_menu_notice

; ------------------------------------------------------------------------------
; Subroutine draw_arrow_top()
; Draw the 4 top arrows.
; Total duration: 420cc (including call)
; W must contains the index of the pair to draw [0;1].
; Change FSR0
; ------------------------------------------------------------------------------
GLOBAL draw_arrow_top

; ------------------------------------------------------------------------------
; Subroutine draw_arrow_column()
; Draw a arrow column in the frame buffer.
; drawing_index must contains the index of the arrow type [0;3].
; Total duration: 272 (including call)
; Change FSR0 and FSR1 pointer
; ------------------------------------------------------------------------------
GLOBAL draw_arrow_column

; ------------------------------------------------------------------------------
; Subroutine draw_game_score()
; Draw the game score in the top left side of the screen
; Total duration: 323cc (including call)
; Change FSR0, W
; ------------------------------------------------------------------------------
GLOBAL draw_game_score

; ------------------------------------------------------------------------------
; Subroutine draw_game_hearts()
; Draw the game hearts
; Total duration: 106cc (including call)
; Change FSR0, W
; ------------------------------------------------------------------------------
GLOBAL draw_game_hearts

; ------------------------------------------------------------------------------
; Subroutine draw_trophy()
; Draw a game trophy when we have a new best score
; Total duration: 100cc (including call)
; Change FSR0, W
; ------------------------------------------------------------------------------
GLOBAL draw_trophy
#endif
