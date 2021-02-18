;LABEL				DIRECTIVE	VALUE		COMMENT
GPIO_PORTD_DATA		EQU			0x400073FC	;accesible all pins of D to write and read
GPIO_PORTD_DIR		EQU			0x40007400	;input output choose of pins	
GPIO_PORTD_AFSEL	EQU			0x40007420	;specific function selection, now no selection
GPIO_PORTD_DEN		EQU			0x4000751C	;digital enable of pins
IOD					EQU			0x0F		;0:inputs,1:outputs
SYSCTL_RCGCGPIO		EQU			0x400FE608	;use it open and close ports
	
GPIO_PORTD_LOCK 	EQU			0x40007520	;Port D Lock Register ;it needs to unlock F0
UNLOCK				EQU			0x4C4F434B	;To open F0 port SW2
GPIO_PORTD_CR		EQU			0x40007524	;Commit Register For Port D

;SW1					EQU			0x40007004 	;switch1	;D0 pin
;SW2					EQU			0x40007008 	;switch2	;D1 pin
;SW3					EQU			0x40007010 	;switch3	;D2 pin
;SW4					EQU			0x40007020 	;switch4	;D3 pin
;IN1					EQU			0x40007040	;		;D4 pin
;IN2					EQU			0x40007080	;		;D5	pin
;IN3					EQU			0x40007100	;		;D6	pin
;IN4					EQU			0x40007200	;		;D7 pin


;LABEL			DIRECTIVE		VALUE		COMMENT
				AREA		subroutines,CODE,READONLY
				THUMB
				
				EXPORT		PortD_Init
					
					
PortD_Init		PROC	
				
				LDR			R1,=SYSCTL_RCGCGPIO
				LDR			R0,[R1]
				ORR			R0,R0,#0x08			;Open D port
				STR			R0,[R1]
				NOP
				NOP
				NOP								;For Clock Run Waiting Time
				
				
				
				LDR			R1,=GPIO_PORTD_DIR
				LDR			R0,[R1]
				BIC			R0,#0xFF
				ORR			R0,#IOD
				STR			R0,[R1]
				
				LDR			R1,=GPIO_PORTD_AFSEL
				LDR			R0,[R1]
				BIC			R0,#0xFF
				STR			R0,[R1]
				
				LDR			R1,=GPIO_PORTD_DEN
				LDR			R0,[R1]
				ORR			R0,#0xFF
				STR			R0,[R1]
				
				BX			LR
				
				ENDP
				END