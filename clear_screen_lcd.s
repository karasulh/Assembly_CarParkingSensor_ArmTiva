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




;LABEL			DIRECTIVE		VALUE		COMMENT
				AREA		subroutines,CODE,READONLY
				THUMB
				
				EXPORT		clear_screen_lcd
				
clear_screen_lcd	PROC	
				PUSH		{R0-R12}


;This subroutine is used to clean the screen by writing " " to all screen.
				
;Choose Data Choice for LCD
Data_LCD		
				LDR			R1,=DC_A6_pin	;Choose Data/Command
				LDR			R0,[R1]
				ORR			R0,#0x40		;Choose Command with D6 pin
				STR			R0,[R1]	
				
				
				MOV			R3,#0
				MOV			R4,#504 ;Xsize=84,Ysize=6;504=84*6
				
check_if_screen_finishes				
				CMP			R3,R4
				BLO			clear_LCD
				BEQ			exit
				
;This part writes to LCD: " "				
clear_LCD										
wait_until_transmit_FIFO_not_full_cle
				LDR			R1,=SSI0_SR		;Status Register
				LDR			R0,[R1]
				AND			R0,#0x02		;TNF flag is obtained.
				CMP			R0,#0x02		
				BNE			wait_until_transmit_FIFO_not_full_cle ;If TNF=0, then transmit buffer is full
				BEQ			send_data_clear		;If TNF=1, then send a new data.

send_data_clear		
				LDR			R1,=SSI0_DR		;Write Data to show
				MOV			R0,#0x00		;clear byte
				STR			R0,[R1]
				ADD			R3,#1			;pass the other locations
				B			check_if_screen_finishes

exit			

				

				POP			{R0-R12}
				BX			LR
				ENDP
				END