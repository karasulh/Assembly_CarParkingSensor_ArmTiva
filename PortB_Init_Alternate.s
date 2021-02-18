;LABEL				DIRECTIVE	VALUE		COMMENT
GPIO_PORTB_DATA		EQU			0x400053FC	;accesible all pins of B to write and read
GPIO_PORTB_DIR		EQU			0x40005400	;input output choose of pins	
GPIO_PORTB_AFSEL	EQU			0x40005420	;specific function enable, now no selection
GPIO_PORTB_DEN		EQU			0x4000551C	;digital enable of pins
;IOB					EQU			0xF0		;0:inputs,1:outputs
SYSCTL_RCGCGPIO		EQU			0x400FE608	;use it open and close ports
GPIO_PORTB_AMSEL	EQU			0x40005528  ;analog enable
GPIO_PORTB_PCTL		EQU			0x4000552C  ;port function control if alternative function selected

;GPIO_PORTB_PDR		EQU			0x40005514	;Pull down resistors
;PDB					EQU			0x0F
;SW1					EQU			0x40005004 	;switch1	;B0 pin
;SW2					EQU			0x40005008 	;switch2	;B1 pin
;SW3					EQU			0x40005010 	;switch3	;B2 pin
;SW4					EQU			0x40005020 	;switch4	;B3 pin
;Out1				EQU			0x40005040	;		;B4 pin
;Out2				EQU			0x40005080	;		;B5	pin
;Out3				EQU			0x40005100	;		;B6	pin
;Out4				EQU			0x40005200	;		;B7 pin


;LABEL			DIRECTIVE		VALUE		COMMENT
				AREA		subroutines,CODE,READONLY
				THUMB
				
				EXPORT		PortB_Init_Alternate
					
;Use for alternate timer function to capture edge time and use B port also as motor driver gpio					
PortB_Init_Alternate		PROC	
				PUSH		{R0-R7}
				
				LDR			R1,=SYSCTL_RCGCGPIO
				LDR			R0,[R1]
				ORR			R0,R0,#0x02			;Open clock of B port
				STR			R0,[R1]
				NOP
				NOP
				NOP								;For Clock Run Waiting Time
				
				LDR			R1,=GPIO_PORTB_DIR
				LDR			R0,[R1]
				ORR			R0,#0x0F			;0.1.2.3 pins are output to drive motor
				BIC			R0,#0x40			;Use PB6 as input,other pins are not touched			
				STR			R0,[R1]
				
				LDR			R1,=GPIO_PORTB_DEN
				LDR			R0,[R1]
				ORR			R0,#0xFF			;Make all pins digital
				STR			R0,[R1]
				
				LDR			R1,=GPIO_PORTB_AFSEL
				LDR			R0,[R1]
				BIC			R0,#0xFF
				ORR			R0,#0x40			;Set PB6 pin for alternate function to use for timer0A for edge time mode
				STR			R0,[R1]
				
				
				LDR			R1,=GPIO_PORTB_PCTL	
				LDR			R0,[R1]
				ORR			R0,#0x07000000		;make 7 to enable timer function of 6.section(pin6) of PCTL 
				STR			R0,[R1]
				
				LDR			R1,=GPIO_PORTB_AMSEL
				MOV			R0,#0x00			;disable analog function
				STR			R0,[R1]			
				
				POP			{R0-R7}
				BX			LR
				
				ENDP
				END