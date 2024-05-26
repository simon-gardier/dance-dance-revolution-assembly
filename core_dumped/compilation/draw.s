#ifndef DRAW
#define DRAW

processor 16f1789
#include <xc.inc>
#include "bits.inc"
#include "ram.inc"

; ------------------------------------------------------------------------------
; ============================= Subroutines ====================================
; ------------------------------------------------------------------------------
PSECT page1, class = CODE, delta = 2

; ------------------------------------------------------------------------------
; Subroutine load_models()
; Load the models in memory.
; Total duration: 504cc (including call)
; ------------------------------------------------------------------------------
load_models:
    ; Get at the start of models. (4cc)
    movlw   LOW(models)
    movwf   FSR1L
    movlw   HIGH(models)
    movwf   FSR1H
    ; Draw models (496)
    ; Arrow LEFT
    IRP slice,  00000001B, 10000000B, \
                00000011B, 11000000B, \
                00000111B, 11000000B, \
                00001111B, 10000000B, \
                00011111B, 00000000B, \
                00111110B, 00000000B, \
                01111111B, 11111111B, \
                11111111B, 11111111B, \
                11111111B, 11111111B, \
                01111111B, 11111111B, \
                00111110B, 00000000B, \
                00011111B, 00000000B, \
                00001111B, 10000000B, \
                00000111B, 11000000B, \
                00000011B, 11000000B, \
                00000001B, 10000000B
        movlw   slice   ; Put the slice in W.
        MOVWI   FSR1++  ; Put W in INDFn
    endm
    ; Arrow DOWN
    IRP slice,  00000001B, 10000000B, \
                00000011B, 11000000B, \
                00000011B, 11000000B, \
                00000011B, 11000000B, \
                00000011B, 11000000B, \
                00000011B, 11000000B, \
                01100011B, 11000110B, \
                11110011B, 11001111B, \
                11111011B, 11011111B, \
                01111111B, 11111110B, \
                00111111B, 11111100B, \
                00011111B, 11111000B, \
                00001111B, 11110000B, \
                00000111B, 11100000B, \
                00000011B, 11000000B, \
                00000001B, 10000000B
        movlw   slice   ; Put the slice in W.
        MOVWI   FSR1++  ; Put W in INDFn
    endm
    ; Arrow UP
    IRP slice,  00000001B, 10000000B, \
                00000011B, 11000000B, \
                00000111B, 11100000B, \
                00001111B, 11110000B, \
                00011111B, 11111000B, \
                00111111B, 11111100B, \
                01111111B, 11111110B, \
                11111011B, 11011111B, \
                11110011B, 11001111B, \
                01100011B, 11000110B, \
                00000011B, 11000000B, \
                00000011B, 11000000B, \
                00000011B, 11000000B, \
                00000011B, 11000000B, \
                00000011B, 11000000B, \
                00000001B, 10000000B
        movlw   slice   ; Put the slice in W.
        MOVWI   FSR1++  ; Put W in INDFn
    endm
    ; Arrow RIGHT
    IRP slice,  00000001B, 10000000B, \
                00000011B, 11000000B, \
                00000011B, 11100000B, \
                00000001B, 11110000B, \
                00000000B, 11111000B, \
                00000000B, 01111100B, \
                11111111B, 11111110B, \
                11111111B, 11111111B, \
                11111111B, 11111111B, \
                11111111B, 11111110B, \
                00000000B, 01111100B, \
                00000000B, 11111000B, \
                00000001B, 11110000B, \
                00000011B, 11100000B, \
                00000011B, 11000000B, \
                00000001B, 10000000B
        movlw   slice   ; Put the slice in W.
        MOVWI   FSR1++  ; Put W in INDFn
    endm
    ; Char 'S'
    IRP slice, 00111100B, 01000010B, 01000000B, 01000000B, 00111100B, 00000010B, 01000010B, 00111100B
        movlw   slice   ; Put the slice in W.
        MOVWI   FSR1++  ; Put W in INDFn
    endm
    ; Char 'C'
    IRP slice, 00111100B, 01000010B, 01000000B, 01000000B, 01000000B, 01000000B, 01000010B, 00111100B
        movlw   slice   ; Put the slice in W.
        MOVWI   FSR1++  ; Put W in INDFn
    endm
    ; Char 'O'
    IRP slice, 00111100B, 01000010B, 01000010B, 01000010B, 01000010B, 01000010B, 01000010B, 00111100B
        movlw   slice   ; Put the slice in W.
        MOVWI   FSR1++  ; Put W in INDFn
    endm
    ; Char 'R'
    IRP slice, 01111100B, 01000010B, 01000010B, 01111100B, 01000100B, 01000010B, 01000010B, 01000010B
        movlw   slice   ; Put the slice in W.
        MOVWI   FSR1++  ; Put W in INDFn
    endm
    ; Char 'E'
    IRP slice, 01111110B, 01000000B, 01000000B, 01111110B, 01000000B, 01000000B, 01000000B, 01111110B
        movlw   slice   ; Put the slice in W.
        MOVWI   FSR1++  ; Put W in INDFn
    endm
    ; Digit '0'
    IRP slice, 01111110B, 01000010B, 01000010B, 01000010B, 01000010B, 01000010B, 01000010B, 01111110B
        movlw   slice   ; Put the slice in W.
        MOVWI   FSR1++  ; Put W in INDFn
    endm
    ; Digit '1'
    IRP slice, 00000110B, 00000110B, 00000110B, 00000110B, 00000110B, 00000110B, 00000110B, 00000110B
        movlw   slice   ; Put the slice in W.
        MOVWI   FSR1++  ; Put W in INDFn
    endm
    ; Digit '2'
    IRP slice, 01111100B, 01000010B, 00000010B, 00000100B, 00001000B, 00010000B, 00100000B, 01111110B
        movlw   slice   ; Put the slice in W.
        MOVWI   FSR1++  ; Put W in INDFn
    endm
    ; Digit '3'
    IRP slice, 01111100B, 01000010B, 00000010B, 00001100B, 00000010B, 00000010B, 01000010B, 01111110B
        movlw   slice   ; Put the slice in W.
        MOVWI   FSR1++  ; Put W in INDFn
    endm
    ; Digit '4'
    IRP slice, 00000010B, 00000110B, 00001010B, 00010010B, 00100010B, 01111110B, 00000010B, 00000001
        movlw   slice   ; Put the slice in W.
        MOVWI   FSR1++  ; Put W in INDFn
    endm
    ; Digit '5'
    IRP slice, 01111110B, 01000000B, 01000000B, 01111100B, 00000010B, 00000010B, 01000010B, 00111100B
        movlw   slice   ; Put the slice in W.
        MOVWI   FSR1++  ; Put W in INDFn
    endm
    ; Digit '6'
    IRP slice, 00011110B, 00100000B, 01000000B, 01111100B, 01000010B, 01000010B, 01000010B, 00111100B
        movlw   slice   ; Put the slice in W.
        MOVWI   FSR1++  ; Put W in INDFn
    endm
    ; Digit '7'
    IRP slice, 01111110B, 00000010B, 00000010B, 00000100B, 00001000B, 00010000B, 00100000B, 01000000B
        movlw   slice   ; Put the slice in W.
        MOVWI   FSR1++  ; Put W in INDFn
    endm
    ; Digit '8'
    IRP slice, 00111100B, 01000010B, 01000010B, 00111100B, 01000010B, 01000010B, 01000010B, 00111100B
        movlw   slice   ; Put the slice in W.
        MOVWI   FSR1++  ; Put W in INDFn
    endm
    ; Digit '9'
    IRP slice, 00111100B, 01000010B, 01000010B, 00111110B, 00000010B, 00000010B, 01000010B, 00111100B
        movlw   slice   ; Put the slice in W.
        MOVWI   FSR1++  ; Put W in INDFn
    endm
    return

; ------------------------------------------------------------------------------
; Subroutine draw_arrow_top()
; Draw 2 of the 4 top arrows.
; drawing_index must contains the index of the pair to draw [0;1].
; Total duration: 353cc (including call)
; Change FSR0 and FSR1 pointer
; ------------------------------------------------------------------------------
draw_arrow_top:
    ; Get the frame buffer address
    movlw   LOW(ARROW_END)
    movwf   FSR0L
    movlw   HIGH(ARROW_END)
    movwf   FSR0H
    movf    drawing_index, 1            ; Update Z flag
    btfss   STATUS, Z
    addfsr  FSR0, 2*ARROW_SPACE
    lslf    drawing_index               ; Get the model to draw
    ; Draw each arrow of the column
    call    draw_arrow                  ; Draw arrow (152cc)
    movlw   LOW(ARROW_END)
    movwf   FSR0L
    movlw   HIGH(ARROW_END)
    movwf   FSR0H
    movf    drawing_index, 1            ; Update Z flag
    btfss   STATUS, Z
    addfsr  FSR0, 2*ARROW_SPACE
    INCF    drawing_index               ; Increment index for the next model
    addfsr  FSR0, ARROW_SPACE           ; Get to the next arrow address
    call    draw_arrow
    return

; ------------------------------------------------------------------------------
; Subroutine draw_arrow_column()
; Draw a arrow column in the frame buffer.
; drawing_index must contains the index of the arrow type [0;3].
; Total duration: 388cc (including call)
; Change FSR0 and FSR1 pointer
; ------------------------------------------------------------------------------
draw_arrow_column:
    ; Draw each arrow of the column
    IRP index, 0, 1                     ; 2*(16 + 11 + 152)
        call get_arrow_struct_index     ; Load arrow_struct at the right column in FSR1 (16cc)
        addfsr  FSR1, (index*2)         ; Go to the right arrow
        moviw   FSR1++                  ; Get the address of the arrow on the frame buffer in FSR0 (using W)
        movwf   FSR0L
        moviw   FSR1++
        movwf   FSR0H
        movlw   0                       ; Put 0 in W
        iorwf   FSR0L, 0                ; Check if FSR0 != 0
        iorwf   FSR0H, 0
        btfss   STATUS, Z               ; If W != 0 => FSR0 != 0
        call    draw_arrow              ; Draw arrow (152cc)
    endm
    return

; ------------------------------------------------------------------------------
; Subroutine get_arrow_struct_index()
; Place the address of the arrow column in arrow_struct in FSR1.
; drawing_index must contains the index of the arrow type [0;3].
; Total duration: 17cc (including call)
; Change FSR1 pointer
; ------------------------------------------------------------------------------
get_arrow_struct_index:
    call    index_draw_arrow_column     ; Get the number of instruction to jump (6)
    brw                                 ; Jump to right address
    IRP column_index, 0, 1, 2, 3
        movlw   LOW(arrow_struct + column_index*2*MAX_COLUMN_ARROW)
        movwf   FSR1L
        movlw   HIGH(arrow_struct + column_index*2*MAX_COLUMN_ARROW)
        movwf   FSR1H
        return
    endm

; ------------------------------------------------------------------------------
; Subroutine index_draw_arrow_column()
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
; Subroutine draw_arrow()
; Draw a arrow in the frame buffer.
; FSR0 must point to the top-left position of the arrow to draw.
; drawing_index must contains the index of the arrow type [0;3].
; Total duration: 166cc (including call)
; Change FSR1 pointer
; Change bank to bank ?.
; ------------------------------------------------------------------------------
draw_arrow:
    ; Load model. (17cc)
    call    load_arrow_model    ; Set FSR1.
    ; Prepare counter. (2)
    movlw   16
    movwf   drawing_counter
arrow_slice_loop:
    ; Draw one full slice per loop. (130)
    moviw   FSR1++              ; Load the slice in W.
    iorwf   INDF0, 1            ; Add the 1's to the frame buffer.
    addfsr  FSR0, 1             ; Get to the next byte.
    moviw   FSR1++
    iorwf   INDF0, 1
    addfsr  FSR0, 11            ; Get to the next line every 2 slice.
    decfsz  drawing_counter     ; Decrement counter.
    goto    arrow_slice_loop    ; Loop if not 0.
    return                      ; Return otherwise.

; ------------------------------------------------------------------------------
; Subroutine load_arrow_model()
; Load the arrow model pointer in FSR1.
; drawing_index must contains the index of the arrow type [0;3].
; Total duration: 17cc (including call)
; Change FSR1 pointer
; ------------------------------------------------------------------------------
load_arrow_model:
    ; Get jump size (7cc)
    call index_load_arrow_model             ; Put the number of instruction to jump in W
    ; Jump and set values (8cc)
    brw                                     ; Jump W instruction
    IRP index, 0, 1, 2, 3
        ; Models
        movlw   LOW(models + (index*32))    ; Arrow=32bytes
        movwf   FSR1L
        movlw   HIGH(models + (index*32))
        movwf   FSR1H
        return
    endm

; ------------------------------------------------------------------------------
; Subroutine index_load_arrow_model()
; drawing_index must contains the index of the arrow type [0;3].
; Total duration: 7cc (including call)
; ------------------------------------------------------------------------------
index_load_arrow_model:
    movf    drawing_index, 0    ; Put drawing_index in W.
    brw
    IRP index, 0, 1, 2, 3
        retlw   (index*5)
    endm

; ------------------------------------------------------------------------------
; Subroutine draw_char()
; Draw a character in the frame buffer.
; x_pos must contains horizontal offset from the left (per 8px) [0;11]
; drawing_index must contains the index of the character [0;14].
; Total duration: 79cc (including call)
; Change bank to bank ?.
; ------------------------------------------------------------------------------
draw_char:
    ; Set both pointers. (22cc)
    movf    drawing_index, 0    ; Put drawing_index in W.
    call    load_char_pointers  ; Set FSR0 and FSR1.
    ; Add x to pointer. (4cc)
    movf    x_pos, 0            ; Move x_pos in W register
    addwf   FSR0L, 1            ; Add x_pos to FSR0L.
    btfsc   STATUS, C           ; If addition carry.
    incf    FSR0H               ; Increment FSR0H.
    ; Prepare counter. (2cc)
    movlw   8
    movwf   drawing_counter
char_slice_loop:
    ; Draw one slice per loop. (49cc)
    moviw   FSR1++              ; Load the slice in W.
    iorwf   INDF0, 1            ; Add the 1's to the frame buffer.
    addfsr  FSR0, 12            ; Get to the next line after every slice.
    decfsz  drawing_counter     ; Decrement counter.
    goto    char_slice_loop     ; Loop if not 0.
    return                      ; Return otherwise.

; ------------------------------------------------------------------------------
; Subroutine load_char_pointers()
; Load the char model and the topleft corner of the drawing zone with FSR0/1.
; drawing_index must contains the index of the character [0;14].
; Total duration: 21cc (including call)
; ------------------------------------------------------------------------------
load_char_pointers:
    ; Move FSR0 at the right line (4cc)
    movlw   LOW(frame_buffer + (CHAR_TOP_START*12))    ; Start at the right line
    movwf   FSR0L
    movlw   HIGH(frame_buffer + (CHAR_TOP_START*12))
    movwf   FSR0H
    ; Get jump size (7cc)
    call    index_char_pointers
    ; Jump and set values (8cc)
    brw
    IRP index, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14
        movlw   LOW(models + (4*32) + (index*8))        ; Arrow=32bytes, char=8bytes
        movwf   FSR1L
        movlw   HIGH(models + (4*32) + (index*8))
        movwf   FSR1H
        return
    endm

; ------------------------------------------------------------------------------
; Subroutine index_char_pointers()
; drawing_index must contains the index of the character [0;14].
; Total duration: 7cc (including call)
; ------------------------------------------------------------------------------
index_char_pointers:
    movf    drawing_index, 0    ; Put drawing_index in W.
    brw
    IRP index, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14
        retlw   (index*5)
    endm

#endif
