;* ------------------------------------------------------------------
;* --  _____       ______  _____                                    -
;* -- |_   _|     |  ____|/ ____|                                   -
;* --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
;* --   | | | '_ \|  __|  \___ \   Zurich University of             -
;* --  _| |_| | | | |____ ____) |  Applied Sciences                 -
;* -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
;* ------------------------------------------------------------------
;* --
;* -- Project     : CT1 - Lab 9
;* -- Description : Multiplication 16 bit signed
;* -- 
;* -- $Id: mul_s16.s 3776 2016-11-14 11:35:26Z kesr $
;* ------------------------------------------------------------------


; -------------------------------------------------------------------
; -- Constants
; -------------------------------------------------------------------
    
                AREA myCode, CODE, READONLY
                    
                THUMB

NR_OF_TESTS     EQU     8
    
ADR_LED         EQU     0x60000100
ADR_7SEG        EQU     0x60000110
ADR_LCD_STEP    EQU     0x1
    
MSG_FAIL        EQU     0x8e88f9c7
MSG_PASS        EQU     0x8c889292
    

; -------------------------------------------------------------------
; -- Main
; -------------------------------------------------------------------   
                        
mul_s16         PROC
                EXPORT mul_s16
                IMPORT display_char    
                PUSH {LR}

; Set LCD "mul_s16"
LCD_set			LDR        R3, =0x0
                LDR		   R0, =display_char
				LDR		   R2, =0x006D
				BLX   	   R0
                ADDS       R3, R3, #ADR_LCD_STEP
				LDR		   R2, =0x0175
				BLX   	   R0
                ADDS       R3, R3, #ADR_LCD_STEP
				LDR		   R2, =0x026C
				BLX   	   R0
                ADDS       R3, R3, #ADR_LCD_STEP
				LDR		   R2, =0x035F
				BLX   	   R0
                ADDS       R3, R3, #ADR_LCD_STEP
				LDR		   R2, =0x0473
				BLX   	   R0
                ADDS       R3, R3, #ADR_LCD_STEP
				LDR		   R2, =0x0531
				BLX   	   R0
                ADDS       R3, R3, #ADR_LCD_STEP
				LDR		   R2, =0x0636
				BLX   	   R0

; Set up unit test
init_test       LDR  R0, =0                 ; Index of testrun
                LDR  R1, =0                 ; Fail mask
                LDR  R2, =ADR_7SEG          ; Clear 7-segment display
                LDR  R3, =0xffffffff
                STR  R3, [R2]     

exec_operation  LSLS R0, #1                 ; Shift index left for halfword access
                LDR  R2, =op1_table         ; Load operands in registers R6, R7       
                LDRH R6, [R2, R0]
                LDR  R2, =op2_table                
                LDRH R7, [R2, R0]
                BL   operation              ; Branch to label with return address (LR)
                
store_result    LSLS R0, #1                 ; Shift index left (again) for word access
                LDR  R2, =result_table
                STR  R7, [R2, R0]
                
verify_result   LDR  R2, =golden_table
                LDR  R3, [R2, R0]
                LSRS R0, #2                 ; Shift index back to original "position"
                CMP  R3, R7
                BEQ  inc_test               ; Branch to inc_test if result correct
                LDR  R2, =1                 ; Set bit at position of failed test
                LSLS R2, R0
                ORRS R1, R2

inc_test        ADDS R0, #1
                LDR  R2, =NR_OF_TESTS
                CMP  R0, R2
                BNE  exec_operation
                
displ_results   LDR  R2, =ADR_7SEG
                LDR  R3, =MSG_FAIL
                LDR  R4, =0
                CMP  R1, R4
                BNE  displ_message          ; Fail
                LDR  R3, =MSG_PASS          ; Pass
displ_message   STR  R3, [R2]                
                LDR  R2, =ADR_LED           ; Display which runs failed
                STR  R1, [R2]

                POP  {PC}

                    
; 16 bit multiplication signed
; - multiplier in R6
; - multiplicand in R7
; - 32 bit result in R7
operation       PUSH {R0-R5, LR}

                ; STUDENTS: To be programmed 
				SXTH	R6, R6				; signextension
				SXTH	R7, R7				; signextension
				
				MOVS	R0, #0				; Zwischenresultat in R0
				MOVS	R1, #0				; Counter für schleife und shift
start_loop
				
				LSRS	R6, R6, #1
				BCC		end_add
				MOVS	R4, R7
				LSLS	R4, R4, R1			; Shift R7 into R4, R1 times
				ADDS	R0, R4				; Add shifted to zwischenresultat
end_add
				ADDS	R1, #1
				CMP		R1, #32				; test für schleife
				BNE		start_loop
end_loop
				MOVS	R7, R0


                ; END: To be programmed

                POP  {R0-R5, PC}            ; Return to main

                ENDP


; -------------------------------------------------------------------
; -- Variables
; -------------------------------------------------------------------
				ALIGN
                AREA myConstants, DATA, READONLY

op1_table       DCW     0x0001, 0x0017, 0xffff, 0x73a4, 0x43cc, 0xe372, 0xdd22, 0x7fff
op2_table       DCW     0xffff, 0x004a, 0xffff, 0x4c28, 0xc3bf, 0x0234, 0xbcde, 0x7fff
    
golden_table    DCD     0xffffffff, 0x000006a6, 0x00000001, 0x2266c1a0 
                DCD     0xf00af934, 0xffc11728, 0x0924bb7c, 0x3fff0001


                AREA myVars, DATA, READWRITE
                    
result_table    SPACE   8*4                 ; Reserve 8 words of memory


; -------------------------------------------------------------------
; -- End of file
; -------------------------------------------------------------------                      
                END

