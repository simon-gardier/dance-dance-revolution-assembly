#ifndef RAM
#define RAM

; ------------------------------------------------------------------------------
; ============================ Ram variables ===================================
; ------------------------------------------------------------------------------

; ---- [Common RAM] ----
lines_count                     equ 0x70   ;2 bytes
pixels_count                    equ 0x70+2 ;2 bytes
flags                           equ 0x70+4 ;1 byte
curr_frame_byte                 equ 0x70+5 ;1 byte

x_pos                           equ 0x70+6 ;1 byte
drawing_index                   equ 0x70+7 ;1 byte
drawing_counter                 equ 0x70+8 ;1 byte

music_note_iteration_counter    equ 0x70+9 ;1 byte
music_note_index                equ 0x70+10;1 byte
note_data_index                 equ 0x70+11;1 byte
note_data_index_prev            equ 0x70+12;1 byte

PORTB_previous                  equ 0x70+13;1byte
PORTB_current                   equ 0x70+14;1byte
score                           equ 0x70+15;1byte

; ---- [Bank 0 -> Bank 3 - 8th byte] ----
models              equ 0x2000      ;248 bytes: 4 arrows -> 5 letters -> 10 digits

; ---- [Bank 3 - 9th byte -> Bank 3 - 24th byte]
arrow_struct        equ models+248  ;16 bytes

; ---- [Bank 3 - 25th byte -> Bank 3 - 63th byte]
; free

; ---- [Bank 3 - 64th byte -> Bank 32] ----
frame_buffer        equ 0x2000 + 304        ; 96 * 144 = 13824px = 1728 bytes, 2032 - 1728 = 304
                                            ; Buffer beginning at bank 8 (in FSR addressing, see schematic p.56 and p.34-35)

#endif
