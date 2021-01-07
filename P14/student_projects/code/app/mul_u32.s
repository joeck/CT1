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
;* -- Description : Multiplication 32 bit unsigned
;* -- 
;* -- $Id: mul_u32.s 3776 2016-11-14 11:35:26Z kesr $
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
                        
mul_u32         PROC
                EXPORT mul_u32
                IMPORT display_char    
                PUSH {LR}

; Set LCD "mul_u32"
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
				LDR		   R2, =0x0475
				BLX   	   R0
                ADDS       R3, R3, #ADR_LCD_STEP
				LDR		   R2, =0x0533
				BLX   	   R0
                ADDS       R3, R3, #ADR_LCD_STEP
				LDR		   R2, =0x0632
				BLX   	   R0

; Set up unit test
init_test       LDR  R0, =0                 ; Index of testrun
                LDR  R1, =0                 ; Fail mask
                LDR  R2, =ADR_7SEG          ; Clear 7-segment display
                LDR  R3, =0xffffffff
                STR  R3, [R2]   

exec_operation  LSLS R0, #2                 ; Shift index left for word access
                LDR  R2, =op1_table         ; Load operands in registers R6, R7       
                LDR  R6, [R2, R0]
                LDR  R2, =op2_table                
                LDR  R7, [R2, R0]
                BL   operation              ; Branch to label with return address (LR)
                
store_result    LSLS R0, #1                 ; Shift index left (again) for doubleword access
                LDR  R2, =result_table
                STR  R6, [R2, R0]           ; Store lower word
                MOV  R4, R0
                LDR  R5, =4
                ADDS R4, R5
                STR  R7, [R2, R4]           ; Store upper word
                
verify_result   LDR  R2, =golden_table
                LDR  R3, [R2, R0]
                LDR  R5, [R2, R4]
                LSRS R0, #3                 ; Shift index back to original "position"
                CMP  R3, R6
                BNE  test_failed
                CMP  R5, R7
                BEQ  inc_test               ; Branch to inc_test if result correct
test_failed     LDR  R2, =1                 ; Set bit at position of failed test
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

                    
; 32 bit multiplication
; - multiplier in R6
; - multiplicand in R7
; - 64 bit result in R6 (lower) / R7 (upper)
operation       PUSH {R0-R5, LR}

                ; STUDENTS: To be programmed
				MOVS	R0, #0				; zwischenresultat
				MOVS	R1, #0				; zwischenresultat
				
				MOVS	R2, R7				; shifted variables
				MOVS	R3, #0
				
				MOVS	R4, #0				; counter für schleife
				MOVS	R5, #0				; 0
				
start_loop
				LSRS	R6, R6, #1
				BCC		end_add
				ADDS	R0, R2
				ADCS	R1, R3
end_add
				LSLS	R2, R2, #1
				ADCS	R3, R3				; shift left with carry
				
				ADDS	R4, #1
				CMP		R4, #32				; test für schleife
				BNE		start_loop

				MOVS	R6, R0
				MOVS	R7, R1
                ; END: To be programmed

                POP  {R0-R5, PC}            ; Return to main

                ENDP


; -------------------------------------------------------------------
; -- Variables
; -------------------------------------------------------------------
				ALIGN
                AREA myConstants, DATA, READONLY

op1_table       DCD     0x00000001, 0x00001717, 0xffffffff, 0x73a473a4
                DCD     0x43f887cc, 0xe372e372, 0x22dddd22, 0x7fffffff
op2_table       DCD     0xffffffff, 0x00004a4a, 0xffffffff, 0x4c284c28
                DCD     0xc33e6abf, 0x00340234, 0xbcccddde, 0x7fffffff
    
golden_table    DCQ     0x00000000ffffffff, 0x0000000006b352a6
                DCQ     0xfffffffe00000001, 0x2267066da5a6c1a0 
                DCQ     0x33d6e1f8e60fc934, 0x002e354b4c451728
                DCQ     0x19b6d568f3641d7c, 0x3fffffff00000001                


                AREA myVars, DATA, READWRITE
                    
result_table    SPACE   8*8                 ; Reserve 8 doublewords of memory


; -------------------------------------------------------------------
; -- End of file
; -------------------------------------------------------------------                      
                END

