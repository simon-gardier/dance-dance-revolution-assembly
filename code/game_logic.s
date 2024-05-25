processor 16f1789
#include <xc.inc>
#include "bits.inc"
#include "ram.inc"
#include "game_logic.inc"

#ifndef GAME_LOGIC_S
#define GAME_LOGIC_S

; ------------------------------------------------------------------------------
; ============================= Subroutines ====================================
; ------------------------------------------------------------------------------
PSECT page2, class = CODE, delta = 2

; ------------------------------------------------------------------------------
; Subroutine init_arrow_struct()
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
; ------------------------------------------------------------------------------
create_arrow:
    movf    drawing_index, 0        ; Put drawing_index in W
    call    create_arrow_index      ; Get the value to jump
    brw
    IRP index, 0, 1, 2, 3
        ; Get arrow index
        movlw   LOW(arrow_struct + index*2*ARROW_COLUMN_CAPACITY); Load arrow_struct address in FSR1
        movwf   FSR1L
        movlw   HIGH(arrow_struct + index*2*ARROW_COLUMN_CAPACITY)
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
        movlw   LOW(ARROW_START_Y + (index*ARROW_MARGIN))        ; Place the arrow address in arrow_struct
        movwi   FSR1++
        movlw   HIGH(ARROW_START_Y + (index*ARROW_MARGIN))
        movwi   FSR1++
        return
    endm

; ------------------------------------------------------------------------------
; Local subroutine create_arrow_index()
; drawing_index must be in W register.
; Total duration: 6cc (including call)
; ------------------------------------------------------------------------------
create_arrow_index:
    brw
    IRP index, 0, 1, 2, 3
        retlw   (index*19)
    endm


; ------------------------------------------------------------------------------
; Subroutine move_arrow()
; ------------------------------------------------------------------------------
move_arrow:
    movlw   LOW(arrow_struct)
    movwf   FSR1L
    movlw   HIGH(arrow_struct)
    movwf   FSR1H
    REPT 4*ARROW_COLUMN_CAPACITY
        ; Verify if the arrow exists
        moviw   FSR1++                  ; Put INDF1 in W and inc FSR1
        iorwf   INDF1, 0                ; Check if INDF1 == 0
        addfsr  FSR1, -1                ; Come back to previous FSR1
        btfsc   STATUS, Z               ; If Z => There are no arrow to update.
        bra     7
        ; Remove 2 line from FSR0L of arrow
        movlw   (2*FRAME_WIDTH)         ; One line
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
; ------------------------------------------------------------------------------
verif_arrow:
    movlw   LOW(arrow_struct)
    movwf   FSR1L
    movlw   HIGH(arrow_struct)
    movwf   FSR1H
    REPT 4*ARROW_COLUMN_CAPACITY
        ; Verify if the arrow exists
        moviw   FSR1++                  ; Put INDF1 in W and inc FSR1
        iorwf   INDF1, 0                ; Check if INDF1 == 0
        addfsr  FSR1, -1                ; Come back to previous FSR1
        btfsc   STATUS, Z               ; Skip next if FSR0 != 0
        bra     17                      ; If FSR0 == 0, next arrow
        ; Remove ARROW_START_Y+1 from FSR0 of arrow
        ; HIGH part (9)
        addfsr  FSR1, 1                 ; Get to the HIGH address of the arrow
        movlw   HIGH(ARROW_END_Y+12)    ; One line under spawn
        subwf   INDF1, 0
        btfsc   STATUS, Z               ; Skip next if W != f
        bra     4                       ; Next part if W == f
        btfsc   STATUS, C               ; Skip next if W > f
        bra     11                      ; Next arrow if W < f
        call    delete_from_high        ; If W > f => delete
        bra     8                       ; From "low"
        ; LOW part (8)
        addfsr  FSR1, -1                ; Get to the LOW address of the arrow
        movlw   LOW(ARROW_END_Y+12)     ; One line under spawn
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
; ------------------------------------------------------------------------------
press_arrow:
    IRP index, ARROW_LEFT, ARROW_DOWN, ARROW_UP, ARROW_RIGHT                   ; From arrow_up to arrow_right
        btfss   flags, index
        bra     54
        movlw   5-index                     ; Get drawing_index from index
        movwf   drawing_index
        ; Set FSR1 (4cc)
        movlw   LOW(arrow_struct + (5-index)*2*ARROW_COLUMN_CAPACITY)
        movwf   FSR1L
        movlw   HIGH(arrow_struct + (5-index)*2*ARROW_COLUMN_CAPACITY)
        movwf   FSR1H
        REPT 2  ;(2*23 + 206/4 = 98cc)
            ; Verify if the arrow exists
            moviw   FSR1++                  ; Put INDF1 in W and inc FSR1
            iorwf   INDF1, 0                ; Check if INDF1 == 0
            addfsr  FSR1, -1                ; Come back to previous FSR1
            btfsc   STATUS, Z               ; Skip next if FSR0 != 0
            bra     17                      ; If FSR0 == 0, ignore this arrow
            ; Remove ARROW_START_Y+PRESS_MARGE from FSR0 of arrow
            ; HIGH part (9)
            addfsr  FSR1, 1                 ; Get to the HIGH address of the arrow
            movlw   HIGH(ARROW_END_Y+(PRESSURE_ACCEPTABLE_MARGIN*12))    ; PRESSURE_ACCEPTABLE_MARGIN lines under spawn
            subwf   INDF1, 0
            btfsc   STATUS, Z               ; Skip next if W != f
            bra     4                       ; Next part if W == f
            btfsc   STATUS, C               ; Skip next if W > f
            bra     11                      ; Next arrow if W < f
            call    claim_from_high         ; If W > f => delete
            bra     8                       ; From "low"
            ; LOW part (8)
            addfsr  FSR1, -1                ; Get to the LOW address of the arrow
            movlw   LOW(ARROW_END_Y+(PRESSURE_ACCEPTABLE_MARGIN*12))       ; PRESSURE_ACCEPTABLE_MARGIN lines under spawn
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
; Local Subroutine claim_arrow()
; Delete the arrow pointed by FSR1 and increment score.
; Return the FSR1 that point to FSR0L
; Total duration: <42cc (including call). At most 206cc (14*8+94) with 8 consecutive calls.
; ------------------------------------------------------------------------------
claim_from_high:
    addfsr FSR1, -1
claim_from_low:
    nop
claim_arrow:
    call    delete_arrow
    call    increment_score
    return

; ------------------------------------------------------------------------------
; Local Subroutine delete_arrow()
; Delete the arrow pointed by FSR1.
; Return the FSR1 that point to FSR0L
; Total duration: <8cc (including call)
; ------------------------------------------------------------------------------
delete_from_high:
    addfsr  FSR1, -1
delete_from_low:
    banksel hearts
    movf    hearts, 1
    btfss   STATUS, Z
    decf    hearts, 1
delete_arrow:
    movlw   0
    movwi   FSR1++
    movwi   FSR1--
    return

; ------------------------------------------------------------------------------
; Subroutine increment_score()
; ------------------------------------------------------------------------------
increment_score:
    incf    score, 1        ; Increment first score digit
    movlw   00001010B       ; 10 in binary
    andwf   score, 0        ; Verify if first "digit" is 10, place result in W
    sublw   00001010B       ; W - 10 = 0 only if score = 10
    btfss   STATUS, Z       ; If first "digit" is not 10
    return                  ; Return
    movlw   00000110B       ; 10 + 6 = 16 = 10000B
    addwf   score, 1        ; Clear first 4 bits and increment next 4.
    movlw   10100000B       ; 4msb is 10 in binary
    andwf   score, 0        ; Verify if second "digit" is 10, place result in W
    sublw   10100000B       ; W - 10 = 0 only if score = 10
    btfss   STATUS, Z       ; If second "digit" is not 10
    return                  ; Return
    clrf    score           ; Clear first 2 digits.
    incf    score+1, 1      ; Increment third score digit
    movlw   00001010B       ; 10 in binary
    andwf   score+1, 0      ; Verify if first "digit" is 10, place result in W
    sublw   00001010B       ; W - 10 = 0 only if score = 10
    btfss   STATUS, Z       ; If first "digit" is not 10
    return                  ; Return
    movlw   00000110B       ; 10 + 6 = 16 = 10000B
    addwf   score+1, 1      ; Clear first 4 bits and increment next 4.
    movlw   10100000B       ; 4msb is 10 in binary
    andwf   score+1, 0      ; Verify if second "digit" is 10, place result in W
    sublw   10100000B       ; W - 10 = 0 only if score = 10
    btfss   STATUS, Z       ; If second "digit" is not 10
    clrf    score+1         ; Reset to avoid overflow  
    return  

; ------------------------------------------------------------------------------
; Subroutine get_score_digit()
; ------------------------------------------------------------------------------
get_score_digit:
    brw
    goto first_digit
    goto second_digit
    goto third_digit
    goto fourth_digit
first_digit:
    movlw   00001111B           ; Mask the digit wanted
    andwf   score, 0            ; Place the digit in W
    return
second_digit:
    movlw   11110000B           ; Mask the digit wanted
    andwf   score, 0            ; Place the digit in W
    swapf   WREG		        ; Put in on the 4 lsb
    return
third_digit:
    movlw   00001111B           ; Mask the digit wanted
    andwf   score+1, 0          ; Place the digit in W
    return
fourth_digit:
    movlw   11110000B           ; Mask the digit wanted
    andwf   score+1, 0          ; Place the digit in W
    swapf   WREG		        ; Put in on the 4 lsb
    return

#endif
