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
;* -- Description : Multiplication and division
;* -- 
;* -- $Id: main.s 3775 2016-11-14 08:13:44Z kesr $
;* ------------------------------------------------------------------


; -------------------------------------------------------------------
; -- Constants
; -------------------------------------------------------------------
    
                AREA myCode, CODE, READONLY
                    
                THUMB
    
ADR_BUTTONS     EQU     0x60000210
ADDR_LCD_ASCII  EQU  	0x60000300

; -------------------------------------------------------------------
; -- Main
; -------------------------------------------------------------------   
                        
main            PROC
                EXPORT main
				IMPORT mul_u16
                IMPORT mul_s16
                IMPORT mul_u32
                
wait_for_button LDR   R0, =ADR_BUTTONS          ; Read buttons
                LDRB  R1, [R0]
                LDR   R0, =mul_u16
                LSRS  R1, #1                    ; Test for T0
                BCS   load_proc                 ; and branch if pressed
                LDR   R0, =mul_s16
                LSRS  R1, #1                    ; Test for T1
                BCS   load_proc                 ; and branch if pressed
                LDR   R0, =mul_u32
                LSRS  R1, #1                    ; Test for T2
                BCC   next                      ; and branch if pressed
load_proc       BLX   R0
next            B     wait_for_button           ; Wait for next button
				
                ENDP

display_char  	PROC
				EXPORT display_char
				PUSH   		{R0, R1, LR}
				LDR     	R0, =ADDR_LCD_ASCII         ; load ASCII register address
				LDR     	R1, =0
                STRH 	    R2, [R0, R3]
                POP 	    {R0, R1, PC}

				ENDP
; -------------------------------------------------------------------
; -- End of file
; ------------------------------------------------------------------- 
				ALIGN
                END

