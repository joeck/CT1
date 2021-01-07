;* ------------------------------------------------------------------
;* --  _____       ______  _____                                    -
;* -- |_   _|     |  ____|/ ____|                                   -
;* --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
;* --   | | | '_ \|  __|  \___ \   Zurich University of             -
;* --  _| |_| | | | |____ ____) |  Applied Sciences                 -
;* -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
;* ------------------------------------------------------------------
;* --
;* -- Project     : CT1 - Lab 7
;* -- Description : Control structures
;* -- 
;* -- $Id: main.s 3748 2016-10-31 13:26:44Z kesr $
;* ------------------------------------------------------------------


; -------------------------------------------------------------------
; -- Constants
; -------------------------------------------------------------------
    
                AREA myCode, CODE, READONLY
                    
                THUMB

ADDR_LED_15_0           EQU     0x60000100
ADDR_LED_31_16          EQU     0x60000102
ADDR_7_SEG_BIN_DS1_0    EQU     0x60000114
ADDR_DIP_SWITCH_15_0    EQU     0x60000200
ADDR_HEX_SWITCH         EQU     0x60000211

NR_CASES        		EQU     0xB

jump_table      ; ordered table containing the labels of all cases
                ; STUDENTS: To be programmed 
				
				DCD		case_dark
				DCD		case_add
				DCD		case_sub
				DCD		case_mul
				DCD		case_and
				DCD		case_or
				DCD		case_xor
				DCD		case_not
				DCD		case_nand
				DCD		case_nor
				DCD		case_xnor
					
                ; END: To be programmed
    

; -------------------------------------------------------------------
; -- Main
; -------------------------------------------------------------------   
                        
main            PROC
                EXPORT main
                
read_dipsw      ; Read operands into R0 and R1 and display on LEDs
                ; STUDENTS: To be programmed
				
				;ops
				LDR		R7, =ADDR_DIP_SWITCH_15_0
				
				MOVS	R0, #0
				MOVS	R1, #0
				
				; read operands
				LDRB	R1, [R7]		;op2
				LDRB	R0, [R7, #1]	;op1
				
				; write to LED
				LDR		R7, =ADDR_LED_15_0
				STRB	R1, [R7]
				STRB	R0, [R7, #1]

                ; END: To be programmed
                    
read_hexsw      ; Read operation into R2 and display on 7seg.
                ; STUDENTS: To be programmed

				LDR		R7, =ADDR_HEX_SWITCH
				MOVS	R2, #0
				
				; read hexswitch
				LDRB	R2, [R7, #0]		;hex-switch
				MOVS	R7, #0x0F
				ANDS	R2, R2, R7			;only use lower 4 bits
				
				; write to 7-segment display
				LDR		R7, =ADDR_7_SEG_BIN_DS1_0
				STRB	R2, [R7]

                ; END: To be programmed
                
case_switch     ; Implement switch statement as shown on lecture slide
                ; STUDENTS: To be programmed
				
				CMP		R2, #NR_CASES
				BHS		case_default
				LSLS	R2, #2
				LDR		R7, =jump_table
				LDR		R7, [R7, R2]
				BX 		R7


                ; END: To be programmed


; Add the code for the individual cases below
; - operand 1 in R0
; - operand 2 in R1
; - result in R0

case_dark       
                LDR  R0, =0
                B    display_result  

case_add        
                ADDS R0, R0, R1
                B    display_result
				
case_sub		SUBS R0, R0, R1
				B	 display_result
				
case_mul		MULS R0, R1, R0
				B	 display_result
				
case_and		ANDS R0, R0, R1
				B	 display_result
				
case_or			ORRS R0, R0, R1
				B	 display_result
				
case_xor		EORS R0, R0, R1
				B	 display_result
				
case_not		MVNS R0, R0
				B	 display_result
				
case_nand		ANDS R0, R0, R1
				MVNS R0, R0
				B	 display_result

case_nor		ORRS R0, R0, R1
				MVNS R0, R0
				B	 display_result
				
case_xnor		EORS R0, R0, R1
				MVNS R0, R0
				B	 display_result
				
case_default	LDR  R0, =0xFFFF
				B	 display_result

; STUDENTS: To be programmed


; END: To be programmed


display_result  ; Display result on LEDs
                ; STUDENTS: To be programmed
				
				LDR		R7, =ADDR_LED_31_16
				STRH	R0, [R7]

                ; END: To be programmed

                B    read_dipsw
                
                ALIGN
                ENDP

; -------------------------------------------------------------------
; -- End of file
; -------------------------------------------------------------------                      
                END

