;LABEL				DIRECTIVE	VALUE		COMMENT
GPIO_PORTF_DATA		EQU			0x4002507C	;accesible all pins of F to write and read
GPIO_PORTF_DIR		EQU			0x40025400	;input output choose of pins	
GPIO_PORTF_AFSEL	EQU			0x40025420	;specific function selection, now no selection
GPIO_PORTF_DEN		EQU			0x4002551C	;digital enable of pins
	
GPIO_PORTF_LOCK 	EQU			0x40025520	;Port F Lock Register ;it needs to unlock F0
UNLOCK				EQU			0x4C4F434B	;To open F0 port SW2
GPIO_PORTF_CR		EQU			0x40025524	;Commit Register For Port F
	
GPIO_PORTF_PUR		EQU			0x40025510	;Pull up resistors
IOB					EQU			0x0E		;0:inputs,1:outputs
SYSCTL_RCGCGPIO		EQU			0x400FE608	;use it open and close ports
PUB					EQU			0x11
SW2					EQU			0x40025004 	;switch2	;F0 pin
RED					EQU			0x40025008 		;F1 pin
BLUE				EQU			0x40025010 		;F2 pin
GREEN				EQU			0x40025020 		;F3 pin
SW1					EQU			0x40025040	;Switch1		;F4 pin
LEDS				EQU			0x40025038	;all leds masked
Switches			EQU			0x40025044	;all swithes masked
	
	

;LABEL			DIRECTIVE		VALUE		COMMENT
				AREA		subroutines,CODE,READONLY
				THUMB
				
				EXPORT		PortF_Init
				EXTERN		DELAY100	
					
PortF_Init		PROC	
				
				
				
				LDR			R1,=SYSCTL_RCGCGPIO
				LDR			R0,[R1]
				ORR			R0,R0,#0x20
				STR			R0,[R1]
				NOP
				NOP
				NOP								;For Clock Run Waiting Time
				
				
				LDR			R0,=UNLOCK			;To use SW2, we must open F0 pin.
				LDR			R1,=GPIO_PORTF_LOCK
				STR			R0,[R1]	
				
				LDR			R1,=GPIO_PORTF_CR	;Commit, can change their values.
				LDR			R0,[R1]
				ORR			R0,#0xFF
				STR			R0,[R1]
				
				
				LDR			R1,=GPIO_PORTF_DIR
				LDR			R0,[R1]
				;BIC			R0,#0xFF
				ORR			R0,#IOB				;F0 and F4 which are SW1 and SW2 are inputs, leds are outputs.
				STR			R0,[R1]
				
				LDR			R1,=GPIO_PORTF_AFSEL
				LDR			R0,[R1]
				BIC			R0,#0x11			;No special function for SW1 and SW2
				STR			R0,[R1]
				
				LDR			R1,=GPIO_PORTF_DEN
				LDR			R0,[R1]
				ORR			R0,#0xFF			;Digital Enable
				STR			R0,[R1]
				
				
				LDR			R1,=GPIO_PORTF_PUR	;Pull Up Resistor to input
				MOV			R0,#PUB
				STR			R0,[R1]
				
				LDR			R1,=GPIO_PORTF_DATA	;Make OFF all LED's by giving 0 to all output port
				LDR			R0,[R1]
				BIC			R0,#0xF
				STR			R0,[R1]
				
				
				BX 			LR
				
				ENDP