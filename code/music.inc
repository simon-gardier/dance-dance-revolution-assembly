processor 16f1789
#include <xc.inc>

#ifndef MUSIC_INC
#define MUSIC_INC

; ------------------------------------------------------------------------------
; Subroutine update_music()
; Update the music output on PSMC3.
; Total duration: <= 66cc  (including call) (most of the time, only 7cc)
; Change bank to bank PSMC3CON.
; Return with W = index of the colmun in which add an arrow
; 0 = left, 1 = down, 2 = up, 3 right, 4 = none
; ------------------------------------------------------------------------------
GLOBAL update_music

#endif
