;LABEL				DIRECTIVE	VALUE		COMMENT
GPIO_PORTD_DATA		EQU			0x400073FC	;accesible all pins of D to write and read
;A0_pin				EQU			0x40004004	;					;A0 pin
;A1_pin				EQU			0x40004008	;					;A1 pin
CLK_A2_pin			EQU			0x40004010 	;SSICLK				;A2 pin
CE_Fss_A3_pin		EQU			0x40004020 	;Fss/CE/Chip Enable	;A3 pin
;A4_pin				EQU			0x40004040 	;					;A4 pin
TX_A5_pin			EQU			0x40004080 	;SsiTx /DIN			;A5 pin
DC_A6_pin			EQU			0x40004100	;Data/Command		;A6	pin
RST_A7_pin			EQU			0x40004200	;RST				;A7 pin

SSI0_DR				EQU			0x40008008	;SSI Data Register
SSI0_SR				EQU			0x4000800C	;SSI Status Register
;SSI1_SR_BSY         EQU    		0x00000010  // SSI Busy Bit
;SSI1_SR_TNF         EQU		    0x00000002  // SSI Transmit FIFO Not Full

thre_address			EQU			0x20000700	;It is used to store "Thre(mm):" hexa codes to write it on LCD


;LABEL			DIRECTIVE		VALUE		COMMENT
				AREA		subroutines,CODE,READONLY
				THUMB
				
				EXPORT		write_threshold_for_lcd
				
write_threshold_for_lcd	PROC	
				PUSH		{R0-R12}

;This subroutine is used to write to LCD as "Thre(mm):"

											
;Save the "T" codes to memory adress				
				LDR			R1,=thre_address
				MOV			R0,#0x01
				STRB		R0,[R1],#1
				MOV			R0,#0x01
				STRB		R0,[R1],#1
				MOV			R0,#0x7f
				STRB		R0,[R1],#1
				MOV			R0,#0x01
				STRB		R0,[R1],#1
				MOV			R0,#0x01
				STRB		R0,[R1],#1
;Save the blank codes to memory address
				MOV			R0,#0x00
				STRB		R0,[R1],#1
;Save the "h" codes to memory adress				
				MOV			R0,#0x7f
				STRB		R0,[R1],#1
				MOV			R0,#0x08
				STRB		R0,[R1],#1		
				MOV			R0,#0x04
				STRB		R0,[R1],#1
				MOV			R0,#0x04
				STRB		R0,[R1],#1
				MOV			R0,#0x78
				STRB		R0,[R1],#1
;Save the blank codes to memory address
				MOV			R0,#0x00
				STRB		R0,[R1],#1			
;Save the "r" codes to memory adress				
				MOV			R0,#0x7c
				STRB		R0,[R1],#1
				MOV			R0,#0x08
				STRB		R0,[R1],#1
				MOV			R0,#0x04
				STRB		R0,[R1],#1
				MOV			R0,#0x04
				STRB		R0,[R1],#1
				MOV			R0,#0x08
				STRB		R0,[R1],#1
;Save the blank codes to memory address
				MOV			R0,#0x00
				STRB		R0,[R1],#1
;Save the "e" codes to memory adress				
				MOV			R0,#0x38
				STRB		R0,[R1],#1
				MOV			R0,#0x54
				STRB		R0,[R1],#1
				MOV			R0,#0x54
				STRB		R0,[R1],#1
				MOV			R0,#0x54
				STRB		R0,[R1],#1
				MOV			R0,#0x18
				STRB		R0,[R1],#1
;Save the blank codes to memory address
				MOV			R0,#0x00
				STRB		R0,[R1],#1				
;Save the "(" codes to memory adress				
				MOV			R0,#0x00
				STRB		R0,[R1],#1
				MOV			R0,#0x1c
				STRB		R0,[R1],#1
				MOV			R0,#0x22
				STRB		R0,[R1],#1
				MOV			R0,#0x41
				STRB		R0,[R1],#1
				MOV			R0,#0x00
				STRB		R0,[R1],#1	
;Save the blank codes to memory address
				MOV			R0,#0x00
				STRB		R0,[R1],#1				
;Save the "m" codes to memory adress				
				MOV			R0,#0x7c
				STRB		R0,[R1],#1
				MOV			R0,#0x04
				STRB		R0,[R1],#1
				MOV			R0,#0x18
				STRB		R0,[R1],#1
				MOV			R0,#0x04
				STRB		R0,[R1],#1
				MOV			R0,#0x78
				STRB		R0,[R1],#1
;Save the blank codes to memory address
				MOV			R0,#0x00
				STRB		R0,[R1],#1
;Save the "m" codes to memory adress				
				MOV			R0,#0x7c
				STRB		R0,[R1],#1
				MOV			R0,#0x04
				STRB		R0,[R1],#1
				MOV			R0,#0x18
				STRB		R0,[R1],#1
				MOV			R0,#0x04
				STRB		R0,[R1],#1
				MOV			R0,#0x78
				STRB		R0,[R1],#1
;Save the blank codes to memory address
				MOV			R0,#0x00
				STRB		R0,[R1],#1
;Save the ")" codes to memory adress				
				MOV			R0,#0x00
				STRB		R0,[R1],#1
				MOV			R0,#0x41
				STRB		R0,[R1],#1
				MOV			R0,#0x22
				STRB		R0,[R1],#1
				MOV			R0,#0x1c
				STRB		R0,[R1],#1
				MOV			R0,#0x00
				STRB		R0,[R1],#1
;Save the blank codes to memory address
				MOV			R0,#0x00
				STRB		R0,[R1],#1				
;Save the ":" codes to memory adress				
				MOV			R0,#0x00
				STRB		R0,[R1],#1
				MOV			R0,#0x36
				STRB		R0,[R1],#1				
				MOV			R0,#0x36
				STRB		R0,[R1],#1
				MOV			R0,#0x00
				STRB		R0,[R1],#1
				MOV			R0,#0x00
				STRB		R0,[R1],#1
;Save the blank codes to memory address
				MOV			R0,#0x00
				STRB		R0,[R1]


;Wait if SPI is busy
wait_until_not_busy_first
				LDR			R1,=SSI0_SR		;Status Register
				LDR			R0,[R1]
				AND			R0,#0x10		;BSY flag is obtained.
				CMP			R0,#0x10		
				BEQ			wait_until_not_busy_first
				
;To write to 2. line, change command settings, make Y=1
;Choose Command Part
Command_LCD
				LDR			R1,=DC_A6_pin	;Choose Data/Command
				LDR			R0,[R1]
				BIC			R0,#0x40		;Choose Command with A6 pin
				STR			R0,[R1]
				
wait_until_not_busy
				LDR			R1,=SSI0_SR		;Status Register
				LDR			R0,[R1]
				AND			R0,#0x10		;BSY flag is obtained.
				CMP			R0,#0x10		
				BEQ			wait_until_not_busy				

assign_command1	
				LDR			R1,=SSI0_DR		;Write Command
				MOV			R0,#0x80		;Set cursor X: 0	
				STR			R0,[R1]			

wait_until_not_busy2
				LDR			R1,=SSI0_SR		;Status Register
				LDR			R0,[R1]
				AND			R0,#0x10		;BSY flag is obtained.
				CMP			R0,#0x10		
				BEQ			wait_until_not_busy2

assign_command3	
				LDR			R1,=SSI0_DR		;Write Command
				MOV			R0,#0x41		;Set cursor Y: 1
				STR			R0,[R1]			

wait_until_not_busy3
				LDR			R1,=SSI0_SR		;Status Register
				LDR			R0,[R1]
				AND			R0,#0x10		;BSY flag is obtained.
				CMP			R0,#0x10		
				BEQ			wait_until_not_busy3
				



;Choose Data Choice for LCD
Data_LCD		
				LDR			R1,=DC_A6_pin	;Choose Data/Command
				LDR			R0,[R1]
				ORR			R0,#0x40		;Choose Command with D6 pin
				STR			R0,[R1]	
				
				
				LDR			R3,=thre_address
				LDR			R4,=0x20000736	;which shows the end of memory of this word "Meas(mm):"
				
check_if_word_finishes				
				CMP			R3,R4
				BNE			Write_thre_LCD
				BEQ			exit
				
;This part writes to LCD: "Thre(mm):"				
Write_thre_LCD		

wait_until_transmit_FIFO_not_full_Meas
				LDR			R1,=SSI0_SR		;Status Register
				LDR			R0,[R1]
				AND			R0,#0x02		;TNF flag is obtained.
				CMP			R0,#0x02		
				BNE			wait_until_transmit_FIFO_not_full_Meas ;If TNF=0, then transmit buffer is full
				BEQ			send_data_Thre		;If TNF=1, then send a new data.

send_data_Thre		
				LDRB		R0,[R3],#1
				LDR			R1,=SSI0_DR		;Write Data to show
				STR			R0,[R1]
				B			check_if_word_finishes

exit			

;				LDR			R1,=CE_Fss_A3_pin
;				LDR			R0,[R1]
;				ORR			R0,0xFF
;				STR			R0,[R1]
				

				POP			{R0-R12}
				BX			LR
				ENDP
				END