SYSCTL_RCGCTIMER	EQU		0x400FE604		;Timer Clock Register
;Base Adress of Timer
TIMER0			EQU			0x40030000
TIMER1			EQU			0x40031000
TIMER2			EQU			0x40032000
TIMER3			EQU			0x40033000
TIMER4			EQU			0x40034000
TIMER5			EQU			0x40035000

TIMER0_CFG		EQU			0x40030000		;Timer Config
TIMER0_TAMR		EQU			0x40030004		;Timer A Mode
TIMER0_CTL		EQU			0x4003000C		;Timer Control
TIMER0_IMR		EQU			0x40030018		;Timer Interrupt Mask
TIMER0_RIS		EQU			0x4003001C		;Timer Raw Interrupt Status
TIMER0_MIS		EQU			0x40030020		;Timer Masked Interrupt Status
TIMER0_ICR		EQU			0x40030024		;Timer Interrupt Clear
TIMER0_TAILR	EQU			0x40030028		;Timer Interval Load
TIMER0_TAR		EQU			0x40030048		;Timer A Register
TIMER0_TAMATCHR	EQU			0x40030030		;Timer A Match
TIMER0_TAV		EQU			0x40030050		;Timer A Value Register

TIMER0_TAPR		EQU			0x40030038		;Timer A Prescale Register
TIMER0_TAPMR	EQU			0x40003040		;Timer A Prescale Match Register
TIMER0_TAPV		EQU			0x40003064		;Timer A Prescale Value Register

Reload_Value	EQU			0xFFFF			;Reload Value
Pres_Reload_Val EQU			0xFF			;Prescale Reload Value

NVIC_EN0		EQU 		0xE000E100 		; IRQ 0 to 31 Set Enable Register
NVIC_PRI4		EQU			0xE000E410		;Interrupt priority which looks 16-19 no's interrupts	

Match_Value		EQU			0x0FFF				;Match register value
Pre_Match_Value EQU			0x0F

;LABEL			DIRECTIVE			VALUE		COMMENTS
				AREA			subroutines,CODE,READONLY
				THUMB

				EXPORT			Edge_Time_Init
					
Edge_Time_Init	PROC
				PUSH		{R0-R7}
				
				LDR			R1,=SYSCTL_RCGCTIMER ;Open clock of timer0
				LDR			R0,[R1]
				ORR 		R0,#0x01
				STR 		R0,[R1]
				NOP
				NOP
				NOP
				
				LDR 		R1,=TIMER0_CTL 		;firstly disable timer 
				LDR 		R0,[R1]
				BIC 		R0,#0x01			;clear bit 0 to disable timer0
				STR 		R0,[R1]
				
				
				LDR			R1,=TIMER0_CFG		;Configuration of 16 vs 32 bit
				LDR			R0,[R1]
				ORR			R0,#0x04				;To use only 16 bit timer, individual mode
				STR			R0,[R1]
				
				
				LDR			R1,=TIMER0_TAMR		;Mode Choices
				LDR			R0,[R1]
				ORR			R0,#0x07			;Choose capture or compare mode,Edge Time Mode,Capture Mode ;0111=7
				STR			R0,[R1]				
				
				LDR			R1,=TIMER0_TAPR
				MOV			R2,#15				;divide clock by 16 to get 1us clock
				STR			R2,[R1]
						
				LDR 		R1,=TIMER0_TAILR	
				LDR 		R2,=Reload_Value
				STR 		R2,[R1] 			;load reload value
				
				
				LDR 		R1, =TIMER0_IMR 	;Or we can pool GPTMRIS register to detect event
				MOV 		R2, #0x04			;enable capture event interrupt
				STR 		R2, [R1]		
				
				;LDR 		R1, =TIMER0_IMR 	
				;MOV 		R2, #0x01			;enable timeout interrupt
				;STR 		R2, [R1]
				
;Use it for interrupt				
;				LDR 		R1,=NVIC_PRI4  		;Priority
;				LDR 		R2,[R1]
;				AND 		R2,#0x0FFFFFFF 		;clear int#19 priority ;19.interrupt for NVIC
;				ORR 		R2,#0x40000000 		;set priority#19 as 2 ;31:29. bits are used
;				STR 		R2,[R1]
;					
;					
;				LDR 		R1,=NVIC_EN0
;				LDR 		R0,[R1]
;				ORR 		R0,#0x00080000		;SET bit 19 to 1 for enable interrupt #19
;				STR 		R0,[R1]	
					
				LDR 		R1,=TIMER0_CTL
				LDR 		R0,[R1]
				ORR			R0,#0x0C			;set 3. and 2. bit for both edge event mode	
				STR			R0,[R1]
			
				
				LDR 		R1,=TIMER0_CTL
				LDR 		R0,[R1]
				ORR 		R0,#0x01			;enable timer,1101
				STR 		R0,[R1]
				
	
				
				POP			{R0-R7}
				BX			LR
				
				ENDP
				