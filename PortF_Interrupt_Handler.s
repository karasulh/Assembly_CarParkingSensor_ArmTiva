TIMER3_CTL		EQU			0x4003300C	;Timer Control
SW1				EQU			0x40025040	;Switch1	;F4 pin
SW2				EQU			0x40025004 	;switch2	;F0 pin
Switches		EQU			0x40025044	;SW1 and SW2 swithes masked
GPIO_PORTF_RIS	EQU			0x40025414	;Read only, Interrupt Status of Pins
GPIO_PORTF_MIS	EQU			0x40025418	;Read only, learn to Interrupt Mask Status 
GPIO_PORTF_ICR	EQU			0x4002541C	;To delete interrupt flag make 1, Clear register

Count_SW1 		EQU			0x20000760	;Use it to follow of the first push of SW1 or second push of SW1		

rows			EQU			0x40007330	;all rows bit masked port D as outputs
cols			EQU			0x4002405c	;all columns bit masked port E as inputs
row3			EQU			0x40007100	;row3		D6 pin	L3on_keypad
col4			EQU			0x40024040 	;column4	E4 pin	R4on_keypad

;LABEL			DIRECTIVE		VALUE		COMMENT
				AREA		isr,CODE,READONLY
				THUMB
				
				EXPORT		PortF_Interrupt_Handler
				EXTERN		DELAY1
				EXTERN		DELAY10
				EXTERN		DELAY100
				EXTERN		Read_Potentiometer
				EXTERN		keypad_control
				

PortF_Interrupt_Handler PROC
				PUSH		{LR}
				PUSH		{R0-R6}
				
				LDR			R1,=GPIO_PORTF_MIS	;Which bit/pin goes into interrupt
				LDR			R0,[R1]
				
				CMP			R0,#0x01			;IF SW2/F0 pin is pushed 
				BEQ			Reset_Breaking_State
				
				CMP			R0,#0x10			;IF SW1/F4 pin is pushed 
				BEQ			Threshold_Setting_State
				BNE			exit2

Reset_Breaking_State

				BL			DELAY100			;For debouncing check
				LDR			R1,=GPIO_PORTF_MIS	;Check bouncing
				LDR			R0,[R1]
				CMP			R0,#0x01			;it is the same value ?
				BNE			exit2
				
				;If we are sure	SW2 is pushed:
				MOV			R10,#0				;R10 is used to detect whether it is in preventative breaking mode.
												;If R10 is 1, then the mode is preventative breaking mode. Control it in main.
				
				LDR 		R1,=TIMER3_CTL		;To turn motor again, enable timer
				LDR 		R0,[R1]
				ORR 		R0,#0x01			;enable timer,0001
				STR 		R0,[R1]
				
				
				B			exit2

Threshold_Setting_State
				
				BL			DELAY100			;For debouncing check
				LDR			R1,=GPIO_PORTF_MIS	;Check bouncing
				LDR			R0,[R1]
				CMP			R0,#0x10			;it is the same value ?
				BNE			exit2
				
				LDR			R2,=Count_SW1       ;Increment the flag which count the times of push to SW1
				LDRB		R3,[R2]
				ADD			R3,#1
				STRB		R3,[R2]
												
				
				CMP			R3,#1              ;If the first push to Sw1, then read potentiometer result.
				BLEQ		Read_Potentiometer
				MOVEQ		R3,#0              ;It means Sw1 is pushed for second times, so make flag as 0.
				LDR			R2,=Count_SW1
				STRBEQ		R3,[R2] 
				

exit2			
				LDR			R1,=GPIO_PORTF_ICR		
				MOV			R0,#0x11 ;pin 0,1,2,3
				STR			R0,[R1] ;clear all interrupt flags
			
				POP			{R0-R6}
				POP			{LR}
				BX			LR
				
				ENDP