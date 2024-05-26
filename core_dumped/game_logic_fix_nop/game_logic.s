#ifndef LOGIC
#define LOGIC

processor 16f1789
#include <xc.inc>
#include "bits.inc"
#include "ram.inc"

; ------------------------------------------------------------------------------
; ============================= Subroutines ====================================
; ------------------------------------------------------------------------------
PSECT page2, class = CODE, delta = 2

; ------------------------------------------------------------------------------
; Subroutine init_arrow_struct()
; Init the arrow_struct
; Total duration: 25cc (including call)
; Change FSR1 pointer
; ------------------------------------------------------------------------------
init_arrow_struct:
    movlw   LOW(arrow_struct)
    movwf   FSR1L
    movlw   HIGH(arrow_struct)
    movwf   FSR1H
    movlw   0
    REPT 16
        movwi   FSR1++
    endm
    return

; ------------------------------------------------------------------------------
; Subroutine create_arrow()
; Place a new arrow in arrow_struct
; drawing_index must contains the index of the arrow column [0;3].
; Total duration: 26cc (including call)
; Change FSR1 pointer
; ------------------------------------------------------------------------------
create_arrow:
    movf    drawing_index, 0        ; Put drawing_index in W
    call    index_create_arrow      ; Get the value to jump
    brw
    IRP index, 0, 1, 2, 3
        ; Get arrow index
        movlw   LOW(arrow_struct + index*2*MAX_COLUMN_ARROW); Load arrow_struct address in FSR1
        movwf   FSR1L
        movlw   HIGH(arrow_struct + index*2*MAX_COLUMN_ARROW)
        movwf   FSR1H
        ; Verify if the arrow doesn't exist already
        moviw   FSR1++                  ; Put INDF1 in W and inc FSR1
        iorwf   INDF1, 0                ; Check if INDF1 == 0
        addfsr  FSR1, -1                ; Come back to previous FSR1
        btfss   STATUS, Z               ; If Z => Create first arrow.
        addfsr  FSR1, 2                 ; If !Z => Create second arrow by getting to the address of the second arrow in arrow_struct
        ; Verify if the arrow to create exist (either second check for first arrow or first check for second arrow)
        moviw   FSR1++                  ; Put INDF1 in W and inc FSR1
        iorwf   INDF1, 0                ; Check if INDF1 == 0
        addfsr  FSR1, -1                ; Come back to previous FSR1
        btfss   STATUS, Z               ; If Z => Create first arrow.
        return                          ; If !Z => Return
        ; Create arrow
        movlw   LOW(ARROW_SPAWN + index*ARROW_SPACE)        ; Place the arrow address in arrow_struct
        movwi   FSR1++
        movlw   HIGH(ARROW_SPAWN + index*ARROW_SPACE)
        movwi   FSR1++
        return
    endm

; ------------------------------------------------------------------------------
; Subroutine index_create_arrow()
; drawing_index must be in W register.
; Total duration: 6cc (including call)
; ------------------------------------------------------------------------------
index_create_arrow:
    brw
    IRP index, 0, 1, 2, 3
        retlw   (index*19)
    endm


; ------------------------------------------------------------------------------
; Subroutine move_arrow()
; Advance all arrow in arrow_struct.
; Total duration: <=112cc (including call)
; Change FSR1
; ------------------------------------------------------------------------------
move_arrow:
    movlw   LOW(arrow_struct)
    movwf   FSR1L
    movlw   HIGH(arrow_struct)
    movwf   FSR1H
    REPT 4*MAX_COLUMN_ARROW
        ; Verify if the arrow exists
        moviw   FSR1++                  ; Put INDF1 in W and inc FSR1
        iorwf   INDF1, 0                ; Check if INDF1 == 0
        addfsr  FSR1, -1                ; Come back to previous FSR1
        btfsc   STATUS, Z               ; If Z => There are no arrow to update.
        bra     7
        ; Remove 2 line from FSR0L of arrow
        movlw   (2*FRAME_WIDTH/8)         ; One line
        subwf   INDF1, 1               ; Decrement address by one line => move the arrow up. Set C if W > f.
        btfsc   STATUS, C               ; Skip next if W < f
        bra     3
        ; Remove 1 from FSR0H of arrow if FSR0L was not enough.
        addfsr  FSR1, 1                 ; Get to the HIGH address of the arrow
        decf    INDF1, 1                ; Decrement HIGH address
        addfsr  FSR1, -1                ; Same FSR1 for both case
        ; Get to the next arrow
        addfsr  FSR1, 2                 ; Get to next arrow
    endm
    return

; ------------------------------------------------------------------------------
; Subroutine verif_arrow()
; Verify if an arrow should be deleted because out-of-range.
; Total duration: <=256cc (including call)
; Change FSR1
; ------------------------------------------------------------------------------
verif_arrow:
    movlw   LOW(arrow_struct)
    movwf   FSR1L
    movlw   HIGH(arrow_struct)
    movwf   FSR1H
    REPT 4*MAX_COLUMN_ARROW
        ; Verify if the arrow exists
        moviw   FSR1++                  ; Put INDF1 in W and inc FSR1
        iorwf   INDF1, 0                ; Check if INDF1 == 0
        addfsr  FSR1, -1                ; Come back to previous FSR1
        btfsc   STATUS, Z               ; Skip next if FSR0 != 0
        bra     17                      ; If FSR0 == 0, next arrow
        ; Remove ARROW_SPAWN+1 from FSR0 of arrow
        ; HIGH part (9)
        addfsr  FSR1, 1                 ; Get to the HIGH address of the arrow
        movlw   HIGH(ARROW_END+12)    ; One line under spawn
        subwf   INDF1, 0
        btfsc   STATUS, Z               ; Skip next if W != f
        bra     4                       ; Next part if W == f
        btfsc   STATUS, C               ; Skip next if W > f
        bra     11                      ; Next arrow if W < f
        call    delete_from_high        ; If W > f => delete
        bra     8                       ; From "low"
        ; LOW part (8)
        addfsr  FSR1, -1                ; Get to the LOW address of the arrow
        movlw   LOW(ARROW_END+12)     ; One line under spawn
        subwf   INDF1, 0
        btfsc   STATUS, Z               ; Skip next if W != f
        call    delete_from_low         ; Remove arrow if W == f
        btfsc   STATUS, C               ; Skip next if W > f
        bra     1                       ; Next arrow if W < f
        call    delete_from_low         ; If W > f => delete
        ; LOW and verif part (1)
        addfsr  FSR1, 1                 ; Helps to get the same FSR1 for 3 case.
        ; Every case (1)
        addfsr  FSR1, 1                 ; Get to next arrow
    endm
    return


; ------------------------------------------------------------------------------
; Subroutine press_arrow()
; Delete the arrows close to the top if the corresponding button is pressed.
; Change FSR0 and FSR1
; Total duration: MAX 324cc (including call)
; ------------------------------------------------------------------------------
press_arrow:
    IRP index, 5, 4, 3, 2                   ; From arrow_up to arrow_right
        btfss   flags, index
        bra     54
        movlw   5-index                     ; Get drawing_index from index
        movwf   drawing_index
        ; Set FSR1 (4cc)
        movlw   LOW(arrow_struct + (5-index)*2*MAX_COLUMN_ARROW)
        movwf   FSR1L
        movlw   HIGH(arrow_struct + (5-index)*2*MAX_COLUMN_ARROW)
        movwf   FSR1H
        REPT 2  ;(2 * 24 = 48cc)
            ; Verify if the arrow exists
            moviw   FSR1++                  ; Put INDF1 in W and inc FSR1
            iorwf   INDF1, 0                ; Check if INDF1 == 0
            addfsr  FSR1, -1                ; Come back to previous FSR1
            btfsc   STATUS, Z               ; Skip next if FSR0 != 0
            bra     17                      ; If FSR0 == 0, ignore this arrow
            ; Remove ARROW_SPAWN+PRESS_MARGE from FSR0 of arrow
            ; HIGH part (9)
            addfsr  FSR1, 1                 ; Get to the HIGH address of the arrow
            movlw   HIGH(ARROW_END+(PRESS_MARGIN*12))    ; One line under spawn
            subwf   INDF1, 0
            btfsc   STATUS, Z               ; Skip next if W != f
            bra     4                       ; Next part if W == f
            btfsc   STATUS, C               ; Skip next if W > f
            bra     11                      ; Next arrow if W < f
            call    claim_from_high         ; If W > f => delete
            bra     8                       ; From "low"
            ; LOW part (8)
            addfsr  FSR1, -1                ; Get to the LOW address of the arrow
            movlw   HIGH(ARROW_END+(PRESS_MARGIN*12))       ; One line under spawn
            subwf   INDF1, 0
            btfsc   STATUS, Z               ; Skip next if W != f
            call    claim_from_low          ; Remove arrow if W == f
            btfsc   STATUS, C               ; Skip next if W > f
            bra     1                       ; Next arrow if W < f
            call    claim_from_low          ; If W > f => delete
            ; LOW and verif part (1)
            addfsr  FSR1, 1                 ; Helps to get the same FSR1 for 3 case.
            ; Every case (1)
            addfsr  FSR1, 1                 ; Get to next arrow
        endm
    endm
    return

; ------------------------------------------------------------------------------
; Subroutine claim_arrow()
; Delete the arrow pointed by FSR1 and increment score.
; Return the FSR1 that point to FSR0L
; Total duration: <13cc (including call)
; ------------------------------------------------------------------------------
claim_from_high:
    addfsr FSR1, -1
claim_from_low:
    nop
claim_arrow:
    call    delete_arrow
    incf    score, 1
    return

; ------------------------------------------------------------------------------
; Subroutine delete_arrow()
; Delete the arrow pointed by FSR1.
; Return the FSR1 that point to FSR0L
; Total duration: <8cc (including call)
; ------------------------------------------------------------------------------
delete_from_high:
    addfsr FSR1, -1
delete_from_low:
delete_arrow:
    movlw   0
    movwi   FSR1++
    movwi   FSR1++
    return

#endif
