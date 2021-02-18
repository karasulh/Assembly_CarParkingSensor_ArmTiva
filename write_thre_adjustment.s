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

adjust_address			EQU			0x20000700	;It is used to store "=>Thre. Adj." hexa codes to write it on LCD


;LABEL			DIRECTIVE		VALUE		COMMENT
				AREA		subroutines,CODE,READONLY
				THUMB
				
				EXPORT		write_thre_adjustment
				
write_thre_adjustment	PROC	
				PUSH		{R0-R12}


;This subroutine is used to write to LCD as "Thre. Adj."

;Save the "=" codes to memory adress				
				LDR			R1,=adjust_address
				MOV			R0,#0x14
				STRB		R0,[R1],#1
				MOV			R0,#0x14
				STRB		R0,[R1],#1
				MOV			R0,#0x14
				STRB		R0,[R1],#1
				MOV			R0,#0x14
				STRB		R0,[R1],#1
				MOV			R0,#0x14
				STRB		R0,[R1],#1
;Save the blank codes to memory address
				MOV			R0,#0x00
				STRB		R0,[R1],#1
;Save the ">" codes to memory adress				
				MOV			R0,#0x00
				STRB		R0,[R1],#1
				MOV			R0,#0x41
				STRB		R0,[R1],#1
				MOV			R0,#0x22
				STRB		R0,[R1],#1
				MOV			R0,#0x14
				STRB		R0,[R1],#1
				MOV			R0,#0x08
				STRB		R0,[R1],#1
;Save the blank codes to memory address
				MOV			R0,#0x00
				STRB		R0,[R1],#1
;Save the "T" codes to memory adress				
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
;Save the "." codes to memory adress				
				MOV			R0,#0x00
				STRB		R0,[R1],#1
				MOV			R0,#0x60
				STRB		R0,[R1],#1
				MOV			R0,#0x60
				STRB		R0,[R1],#1
				MOV			R0,#0x00
				STRB		R0,[R1],#1
				MOV			R0,#0x00
				STRB		R0,[R1],#1
;Save the blank codes to memory address
				MOV			R0,#0x00
				STRB		R0,[R1],#1
;Save the blank codes to memory adress				
				MOV			R0,#0x00
				STRB		R0,[R1],#1
				MOV			R0,#0x00
				STRB		R0,[R1],#1				
				MOV			R0,#0x00
				STRB		R0,[R1],#1
				MOV			R0,#0x00
				STRB		R0,[R1],#1
				MOV			R0,#0x00
				STRB		R0,[R1],#1
;Save the blank codes to memory address
				MOV			R0,#0x00
				STRB		R0,[R1]
;Save the "A" codes to memory adress				
				MOV			R0,#0x7e
				STRB		R0,[R1],#1
				MOV			R0,#0x11
				STRB		R0,[R1],#1
				MOV			R0,#0x11
				STRB		R0,[R1],#1
				MOV			R0,#0x11
				STRB		R0,[R1],#1
				MOV			R0,#0x7e
				STRB		R0,[R1],#1
;Save the blank codes to memory address
				MOV			R0,#0x00
				STRB		R0,[R1],#1		
				
;Save the "d" codes to memory adress				
				MOV			R0,#0x38
				STRB		R0,[R1],#1
				MOV			R0,#0x44
				STRB		R0,[R1],#1				
				MOV			R0,#0x44
				STRB		R0,[R1],#1
				MOV			R0,#0x48
				STRB		R0,[R1],#1
				MOV			R0,#0x7f
				STRB		R0,[R1],#1
;Save the blank codes to memory address
				MOV			R0,#0x00
				STRB		R0,[R1]
				
;Save the "j" codes to memory adress				
				MOV			R0,#0x20
				STRB		R0,[R1],#1
				MOV			R0,#0x40
				STRB		R0,[R1],#1				
				MOV			R0,#0x44
				STRB		R0,[R1],#1
				MOV			R0,#0x3d
				STRB		R0,[R1],#1
				MOV			R0,#0x00
				STRB		R0,[R1],#1
;Save the blank codes to memory address
				MOV			R0,#0x00
				STRB		R0,[R1]
;Save the "." codes to memory adress				
				MOV			R0,#0x00
				STRB		R0,[R1],#1
				MOV			R0,#0x60
				STRB		R0,[R1],#1				
				MOV			R0,#0x60
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

;To write to 3. line change command settings, make Y=2
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

assign_command	
				LDR			R1,=SSI0_DR		;Write Command
				MOV			R0,#0x80		;Set cursor X: 0	
				STR			R0,[R1]	
				
;Check if it is not busy
wait_until_not_busy1
				LDR			R1,=SSI0_SR		;Status Register
				LDR			R0,[R1]
				AND			R0,#0x10		;BSY flag is obtained.
				CMP			R0,#0x10		
				BEQ			wait_until_not_busy1

assign_command1	
				LDR			R1,=SSI0_DR		;Write Command
				MOV			R0,#0x42		;Set cursor Y: 0
				STR			R0,[R1]		
				
;Check if it is not busy
wait_until_not_busy2
				LDR			R1,=SSI0_SR		;Status Register
				LDR			R0,[R1]
				AND			R0,#0x10		;BSY flag is obtained.
				CMP			R0,#0x10		
				BEQ			wait_until_not_busy2


				
;Choose Data Choice for LCD
Data_LCD		
				LDR			R1,=DC_A6_pin	;Choose Data/Command
				LDR			R0,[R1]
				ORR			R0,#0x40		;Choose Command with D6 pin
				STR			R0,[R1]	
				
				
				LDR			R3,=adjust_address
				LDR			R4,=0x20000745	;which shows the end of memory of this word "=>Thre. Adj."
				
check_if_word_finishes				
				CMP			R3,R4
				BNE			Write_thre_adj_LCD
				BEQ			exit
				
;This part writes to LCD: "Meas(mm):"				
Write_thre_adj_LCD										
wait_until_transmit_FIFO_not_full_Adj
				LDR			R1,=SSI0_SR		;Status Register
				LDR			R0,[R1]
				AND			R0,#0x02		;TNF flag is obtained.
				CMP			R0,#0x02		
				BNE			wait_until_transmit_FIFO_not_full_Adj ;If TNF=0, then transmit buffer is full
				BEQ			send_data_Adj		;If TNF=1, then send a new data.

send_data_Adj		
				LDRB		R0,[R3],#1
				LDR			R1,=SSI0_DR		;Write Data to show
				STR			R0,[R1]
				B			check_if_word_finishes

exit			

				

				POP			{R0-R12}
				BX			LR
				ENDP
				END