;LABEL				DIRECTIVE	VALUE		COMMENT
GPIO_PORTD_DATA		EQU			0x400073FC	;accesible all pins of D to write and read
A0_pin				EQU			0x40004004	;					;A0 pin
A1_pin				EQU			0x40004008	;					;A1 pin
CLK_A2_pin			EQU			0x40004010 	;SSICLK				;A2 pin
CE_Fss_A3_pin		EQU			0x40004020 	;Fss/CE/Chip Enable	;A3 pin
A4_pin				EQU			0x40004040 	;					;A4 pin
TX_A5_pin			EQU			0x40004080 	;SsiTx /DIN			;A5 pin
DC_A6_pin			EQU			0x40004100	;Data/Command		;A6	pin
RST_A7_pin			EQU			0x40004200	;RST				;A7 pin

SSI0_DR			EQU			0x40008008	;SSI Data Register
SSI0_SR			EQU			0x4000800C	;SSI Status Register


				
numbers_address			EQU			0x20000700	;It is used to store "digits" hexa codes to write it on LCD				



;LABEL			DIRECTIVE		VALUE		COMMENT
				AREA		subroutines,CODE,READONLY
				THUMB
				
				EXPORT		Numbers_for_LCD
				EXTERN 		SPI_Configuration
				EXTERN 		DELAY100
				
Numbers_for_LCD	PROC	
				PUSH		{R0-R12}

;This subroutine is writing the digits to LCD according to R11 which shows the digit which will be written. 
				
;According to number, this number information will give to LCD.				
Write_number_LCD			
				
				CMP			R11,#0
				BEQ.W		write_0
				CMP			R11,#1
				BEQ.W		write_1
				CMP			R11,#2
				BEQ.W		write_2
				CMP			R11,#3
				BEQ.W		write_3
				CMP			R11,#4
				BEQ.W		write_4
				CMP			R11,#5
				BEQ.W		write_5
				CMP			R11,#6
				BEQ.W		write_6
				CMP			R11,#7
				BEQ.W		write_7
				CMP			R11,#8
				BEQ.W		write_8
				CMP			R11,#9
				BEQ.W		write_9
				BNE.W		exit
				
				

write_0
;Save the "0" codes to memory adress				
				LDR			R1,=numbers_address
				MOV			R0,#0x3e
				STRB		R0,[R1],#1
				MOV			R0,#0x51
				STRB		R0,[R1],#1
				MOV			R0,#0x49													
				STRB		R0,[R1],#1
				MOV			R0,#0x45
				STRB		R0,[R1],#1
				MOV			R0,#0x3e
				STRB		R0,[R1],#1
;Save the blank codes to memory address
				MOV			R0,#0x00
				STRB		R0,[R1],#1
				B			writing_LCD
				
write_1
;Save the "1" codes to memory adress				
				LDR			R1,=numbers_address
				MOV			R0,#0x00
				STRB		R0,[R1],#1
				MOV			R0,#0x42
				STRB		R0,[R1],#1
				MOV			R0,#0x7f													
				STRB		R0,[R1],#1
				MOV			R0,#0x40
				STRB		R0,[R1],#1
				MOV			R0,#0x00
				STRB		R0,[R1],#1
;Save the blank codes to memory address
				MOV			R0,#0x00
				STRB		R0,[R1],#1
				B			writing_LCD

write_2
;Save the "2" codes to memory adress				
				LDR			R1,=numbers_address
				MOV			R0,#0x42
				STRB		R0,[R1],#1
				MOV			R0,#0x61
				STRB		R0,[R1],#1
				MOV			R0,#0x51													
				STRB		R0,[R1],#1
				MOV			R0,#0x49
				STRB		R0,[R1],#1
				MOV			R0,#0x46
				STRB		R0,[R1],#1
;Save the blank codes to memory address
				MOV			R0,#0x00
				STRB		R0,[R1],#1
				B			writing_LCD

write_3
;Save the "3" codes to memory adress				
				LDR			R1,=numbers_address
				MOV			R0,#0x21
				STRB		R0,[R1],#1
				MOV			R0,#0x41
				STRB		R0,[R1],#1
				MOV			R0,#0x45													
				STRB		R0,[R1],#1
				MOV			R0,#0x4b
				STRB		R0,[R1],#1
				MOV			R0,#0x31
				STRB		R0,[R1],#1
;Save the blank codes to memory address
				MOV			R0,#0x00
				STRB		R0,[R1],#1
				B			writing_LCD
				
write_4
;Save the "4" codes to memory adress				
				LDR			R1,=numbers_address
				MOV			R0,#0x18
				STRB		R0,[R1],#1
				MOV			R0,#0x14
				STRB		R0,[R1],#1
				MOV			R0,#0x12													
				STRB		R0,[R1],#1
				MOV			R0,#0x7f
				STRB		R0,[R1],#1
				MOV			R0,#0x10
				STRB		R0,[R1],#1
;Save the blank codes to memory address
				MOV			R0,#0x00
				STRB		R0,[R1],#1
				B			writing_LCD

write_5
;Save the "5" codes to memory adress				
				LDR			R1,=numbers_address
				MOV			R0,#0x27
				STRB		R0,[R1],#1
				MOV			R0,#0x45
				STRB		R0,[R1],#1
				MOV			R0,#0x45													
				STRB		R0,[R1],#1
				MOV			R0,#0x45
				STRB		R0,[R1],#1
				MOV			R0,#0x39
				STRB		R0,[R1],#1
;Save the blank codes to memory address
				MOV			R0,#0x00
				STRB		R0,[R1],#1
				B			writing_LCD
write_6
;Save the "6" codes to memory adress				
				LDR			R1,=numbers_address
				MOV			R0,#0x3c
				STRB		R0,[R1],#1
				MOV			R0,#0x4a
				STRB		R0,[R1],#1
				MOV			R0,#0x49													
				STRB		R0,[R1],#1
				MOV			R0,#0x49
				STRB		R0,[R1],#1
				MOV			R0,#0x30
				STRB		R0,[R1],#1
;Save the blank codes to memory address
				MOV			R0,#0x00
				STRB		R0,[R1],#1
				B			writing_LCD
write_7
;Save the "7" codes to memory adress				
				LDR			R1,=numbers_address
				MOV			R0,#0x01
				STRB		R0,[R1],#1
				MOV			R0,#0x71
				STRB		R0,[R1],#1
				MOV			R0,#0x09													
				STRB		R0,[R1],#1
				MOV			R0,#0x05
				STRB		R0,[R1],#1
				MOV			R0,#0x03
				STRB		R0,[R1],#1
;Save the blank codes to memory address
				MOV			R0,#0x00
				STRB		R0,[R1],#1
				B			writing_LCD
write_8
;Save the "8" codes to memory adress				
				LDR			R1,=numbers_address
				MOV			R0,#0x36
				STRB		R0,[R1],#1
				MOV			R0,#0x49
				STRB		R0,[R1],#1
				MOV			R0,#0x49													
				STRB		R0,[R1],#1
				MOV			R0,#0x49
				STRB		R0,[R1],#1
				MOV			R0,#0x36
				STRB		R0,[R1],#1
;Save the blank codes to memory address
				MOV			R0,#0x00
				STRB		R0,[R1],#1
				B			writing_LCD
write_9
;Save the "9" codes to memory adress				
				LDR			R1,=numbers_address
				MOV			R0,#0x06
				STRB		R0,[R1],#1
				MOV			R0,#0x49
				STRB		R0,[R1],#1
				MOV			R0,#0x49													
				STRB		R0,[R1],#1
				MOV			R0,#0x29
				STRB		R0,[R1],#1
				MOV			R0,#0x1e
				STRB		R0,[R1],#1
;Save the blank codes to memory address
				MOV			R0,#0x00
				STRB		R0,[R1],#1
				B			writing_LCD


writing_LCD
;Wait if SPI is busy
wait_until_not_busy_first
				LDR			R1,=SSI0_SR		;Status Register
				LDR			R0,[R1]
				AND			R0,#0x10		;BSY flag is obtained.
				CMP			R0,#0x10		
				BEQ			wait_until_not_busy_first	
				
;Choose Data Choice for LCD
Data_LCD		
				LDR			R1,=DC_A6_pin	;Choose Data/Command
				LDR			R0,[R1]
				ORR			R0,#0x40		;Choose Command with D6 pin
				STR			R0,[R1]	
				
				
				LDR			R3,=numbers_address
				LDR			R4,=0x20000706	;which shows the end of memory of this word "Meas(mm):"
				
check_if_word_finishes				
				CMP			R3,R4
				BNE			Write_thre_LCD
				BEQ			exit
				
;This part writes to LCD: "digit"				
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

				POP			{R0-R12}
				BX			LR
				ENDP
				END