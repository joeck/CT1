; ------------------------------------------------------------------
; --  _____       ______  _____                                    -
; -- |_   _|     |  ____|/ ____|                                   -
; --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
; --   | | | '_ \|  __|  \___ \   Zurich University of             -
; --  _| |_| | | | |____ ____) |  Applied Sciences                 -
; -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
; ------------------------------------------------------------------
; --
; -- main.s
; --
; -- CT1 P08 "Strukturierte Codierung" mit Assembler
; --
; -- $Id: struct_code.s 3787 2016-11-17 09:41:48Z kesr $
; ------------------------------------------------------------------
;Directives
        PRESERVE8
        THUMB

; ------------------------------------------------------------------
; -- Address-Defines
; ------------------------------------------------------------------
; input
ADDR_DIP_SWITCH_7_0       EQU        0x60000200
ADDR_BUTTONS              EQU        0x60000210

; output
ADDR_LED_31_0             EQU        0x60000100
ADDR_7_SEG_BIN_DS3_0      EQU        0x60000114
ADDR_LCD_COLOUR           EQU        0x60000340
ADDR_LCD_ASCII            EQU        0x60000300
ADDR_LCD_ASCII_BIT_POS    EQU        0x60000302
ADDR_LCD_ASCII_2ND_LINE   EQU        0x60000314


; ------------------------------------------------------------------
; -- Program-Defines
; ------------------------------------------------------------------
; value for clearing lcd
ASCII_DIGIT_CLEAR        EQU         0x00000000
LCD_LAST_OFFSET          EQU         0x00000028

; offset for showing the digit in the lcd
ASCII_DIGIT_OFFSET        EQU        0x00000030

; lcd background colors to be written
DISPLAY_COLOUR_RED        EQU        0
DISPLAY_COLOUR_GREEN      EQU        2
DISPLAY_COLOUR_BLUE       EQU        4

; ------------------------------------------------------------------
; -- myConstants
; ------------------------------------------------------------------
        AREA myConstants, DATA, READONLY
; display defines for hex / dec
DISPLAY_BIT               DCB        "Bit "
DISPLAY_2_BIT             DCB        "2"
DISPLAY_4_BIT             DCB        "4"
DISPLAY_8_BIT             DCB        "8"
        ALIGN

; ------------------------------------------------------------------
; -- myCode
; ------------------------------------------------------------------
        AREA myCode, CODE, READONLY
        ENTRY

        ; imports for calls
        import adc_init
        import adc_get_value

main    PROC
        export main
        ; 8 bit resolution, cont. sampling
        BL         adc_init 
        BL         clear_lcd

main_loop
; STUDENTS: To be programmed

		BL			clear_lcd_color
		BL			adc_get_value		;R0 = ADC
		
		; read T0
		LDR			R7, =ADDR_BUTTONS
		LDRB		R2, [R7]
		LSRS		R2, R2, #1
		BCC			no_button
		
		; ADC Value
		LDR			R7, =ADDR_7_SEG_BIN_DS3_0
		STRB		R0, [R7]
		
		; LCD to Green
		LDR			R7, =ADDR_LCD_COLOUR
		LDR			R6, =0xFFFF
		STRH		R6, [R7, #2]
		
		MOVS		R3, R0 ; 40 -> 00101000
		MOVS		R6, #0 ; 1
		
		LSRS		R3, R3, #3
		ADDS		R3, R3, #1
		MOVS		R6, R3
		
		; display LED bar
		MOVS		R3, #0 		; shifts R6 times left with ones. result in R3.
		BL			test_fl
fill_loop
		LSLS		R3, R3, #1
		ADDS		R3, R3, #1
		SUBS		R6, R6, #1
test_fl
		CMP			R6, #0
		BHI			fill_loop
		
		; print to led
		LDR			R7, =ADDR_LED_31_0
		STR			R3, [R7]

		BL			end_no_button
		
no_button
		; load DIP switchs
		LDR 		R7, =ADDR_DIP_SWITCH_7_0
		LDRB 		R2, [R7]
		
		SUBS		R2, R2, R0		; R2 = diff = DIP_SW - ADC
		BMI			red
		
		CMP			R2, #16
		BGE			bit_8
		CMP			R2, #4
		BGE			bit_4
		
		LDR			R6, =DISPLAY_2_BIT
		BL			bit_end
bit_4
		LDR			R6, =DISPLAY_4_BIT
		BL			bit_end
bit_8
		LDR			R6, =DISPLAY_8_BIT
bit_end
		
		LDR			R7, =ADDR_LCD_ASCII
		LDRB		R6, [R6]
		STRB		R6, [R7]
		BL			write_bit_ascii
		
		; LCD to Blue
		LDR			R7, =ADDR_LCD_COLOUR
		LDR			R6, =0xFFFF
		STRH		R6, [R7, #4]
		BL			end_red
		
red
		; LCD to Red
		LDR			R7, =ADDR_LCD_COLOUR
		LDR			R6, =0xFFFF
		STRH		R6, [R7]
		
		; count zeros in diff
		MVNS 		R6, R2	;R6 = !diff
		BL			count_zeros
		LDR			R7, =ADDR_LCD_ASCII
		LDR			R5, =ASCII_DIGIT_OFFSET
		STRB		R6, [R7, R5]
		

end_red
		LDR			R7, =ADDR_7_SEG_BIN_DS3_0
		STRB		R2, [R7]

end_no_button
		
; END: To be programmed
        B          main_loop

count_zeros	;count zeros in R6, returns numbers of zeros in R6
		PUSH		{R0, R1, R3}
		MOVS		R0, #0
		MOVS		R3, #0
		MOVS		R1, #8
zeros_loop
		LSRS		R6, R6, #1
		ADCS		R0, R3
		SUBS		R1, R1, #1
		BNE			zeros_loop
		MOVS		R6, R0
		POP			{R0, R1, R3}
		BX			LR
		
clear_lcd_color
		PUSH		{R6, R7}
		LDR			R7, =ADDR_LCD_COLOUR
		MOVS		R6, #0
		STR			R6, [R7]
		STRH		R6, [R7, #4]
		POP			{R6, R7}
		BX			LR

clear_lcd
        PUSH       {R0, R1, R2}
        LDR        R2, =0x0
clear_lcd_loop
        LDR        R0, =ADDR_LCD_ASCII
        ADDS       R0, R0, R2                       ; add index to lcd offset
        LDR        R1, =ASCII_DIGIT_CLEAR
        STR        R1, [R0]
        ADDS       R2, R2, #4                       ; increas index by 4 (word step)
        CMP        R2, #LCD_LAST_OFFSET             ; until index reached last lcd point
        BMI        clear_lcd_loop
        POP        {R0, R1, R2}
        BX         LR

write_bit_ascii
        PUSH       {R0, R1}
        LDR        R0, =ADDR_LCD_ASCII_BIT_POS 
        LDR        R1, =DISPLAY_BIT
        LDR        R1, [R1]
        STR        R1, [R0]
        POP        {R0, R1}
        BX         LR

        ENDP
        ALIGN


; ------------------------------------------------------------------
; End of code
; ------------------------------------------------------------------
        END
