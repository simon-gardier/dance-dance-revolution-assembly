processor 16f1789
#include <xc.inc>
#include "utils.inc"

#ifndef VIDEO_INC
#define VIDEO_INC

; ------------------------------------------------------------------------------
; Subroutine hsync()
; Common part for all fields lines.
; Must be called 5cc before next output.
; Total duration: 57cc (including call)
; Change bank to bank 2 (LATx).
; ------------------------------------------------------------------------------
GLOBAL hsync

; ------------------------------------------------------------------------------
; Subroutine long_sync()
; Perform one long synchronization followed by a short pulse.
; Must be called 5cc (including call) before line start.
; Ends 5cc before next line.
; Change bank to bank 2 (LATx).
; ------------------------------------------------------------------------------
GLOBAL long_sync

; ------------------------------------------------------------------------------
; Subroutine short_sync()
; Perform one short synchronization followed by a long pulse.
; Must be called 5cc (including call) before line start.
; Ends 7cc before next line.
; Change bank to bank 0 (PORTx, TMRx).
; ------------------------------------------------------------------------------
GLOBAL short_sync

; ------------------------------------------------------------------------------
; Subroutine vsync_empty_lines()
; Generate the empty lines required to complete the 25 lines of vsync1 and the 24 lines of vsync2.
; The number of lines tho be generated must be passed in W.
; Must be called 8cc before first hsync output
; Change bank to bank 0 (PORTx, TMRx).
; ------------------------------------------------------------------------------
GLOBAL vsync_empty_lines

; ------------------------------------------------------------------------------
; Subroutine init_frame_buffer()
; Set the frame buffer with BACKGROUND_COLOR
; Buffer is 96x144px = 13824px = 1728 bytes. We clear 1/6 (288) per call.
; FSR0 must be set before the FIRST call.
; FSR0 MUST NOT CHANGE BETWEEN THOSE SIX CALLS
; Execution time with call and return : 2 + 3 + 9*35 + 1 = 321 (1932 total)
; ------------------------------------------------------------------------------
GLOBAL init_frame_buffer

#endif
