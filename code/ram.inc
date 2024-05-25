processor 16f1789
#include <xc.inc>

#ifndef RAM_INC
#define RAM_INC

; ------------------------------------------------------------------------------
; ============================ Ram variables ===================================
; ------------------------------------------------------------------------------
                   
; ---- [Common RAM] ----
lines_count                     equ 0x70   ;2 bytes
pixels_count                    equ 0x70+2 ;2 bytes
flags                           equ 0x70+4 ;1 byte  [7 : free][5-2 : buttons][1 : state][0 : odd line flag]
curr_frame_byte                 equ 0x70+5 ;1 byte

x_pos                           equ 0x70+6 ;1 byte
drawing_index                   equ 0x70+7 ;1 byte
drawing_counter                 equ 0x70+8 ;1 byte

music_note_iteration_counter    equ 0x70+9 ;1 byte
music_note_index                equ 0x70+10;1 byte
note_data_index                 equ 0x70+11;1 byte
note_data_index_prev            equ 0x70+12;1 byte

PORTB_previous                  equ 0x70+13;1 byte
score                           equ 0x70+14;2 byte

; ---- [Bank 0 -> Bank 0 - 16th byte] ----
arrow_struct        equ 0x2000

; ---- [Bank 0 - 17th byte -> Bank 3 - 63th byte] ----
hearts              equ 0x020h+17   ;1 byte
session_best_score  equ 0x020h+18   ;2 bytes          

; ---- [Bank 3 - 64th byte -> Bank 25] ----
frame_buffer        equ 0x2000 + 304        ; 96 * 144 = 13824px = 1728 bytes, 2032 - 1728 = 304
                                            ; Buffer beginning at bank 3 64th byte (in FSR addressing, see schematic p.56 and p.34-35)

#endif
