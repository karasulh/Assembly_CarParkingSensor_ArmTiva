SYSCTL_RCGCTIMER	EQU		0x400FE604		;Timer Clock Register
;Base Adress of Timer
TIMER0			EQU			0x40030000
TIMER1			EQU			0x40031000
TIMER2			EQU			0x40032000
TIMER3			EQU			0x40033000
TIMER4			EQU			0x40034000
TIMER5			EQU			0x40035000

TIMER3_CFG		EQU			0x40033000		;Timer Config
TIMER3_TAMR		EQU			0x40033004		;Timer A Mode
TIMER3_CTL		EQU			0x4003300C		;Timer Control
TIMER3_IMR		EQU			0x40033018		;Timer Interrupt Mask
TIMER3_RIS		EQU			0x4003301C		;Timer Raw Interrupt Status
TIMER3_MIS		EQU			0x40033020		;Timer Masked Interrupt Status
TIMER3_ICR		EQU			0x40033024		;Timer Interrupt Clear
TIMER3_TAILR	EQU			0x40033028		;Timer Interval Load
TIMER3_TAR		EQU			0x40033048		;Timer A Register
TIMER3_TAMATCHR	EQU			0x40033030		;Timer A Match
TIMER3_TAV		EQU			0x40033050		;Timer A Value Register

TIMER3_TAPR		EQU			0x40033038		;Timer A Prescale Register
TIMER3_TAPMR	EQU			0x40033040		;Timer A Prescale Match Register
TIMER3_TAPV		EQU			0x40033064		;Timer A Prescale Value Register


NVIC_EN1		EQU 		0xE000E104 		; IRQ 32 to 63 Set Enable Register
NVIC_PRI8		EQU			0xE000E420		;Interrupt priority which looks 32-35 no's interrupts	
	
Reload_Value	EQU			0xF000			;Reload Value
Pres_Reload_Val EQU			0x01			;Prescale Reload Value ;It should be at least 1 for >5ms

;LABEL			DIRECTIVE			VALUE		COMMENTS
				AREA			subroutines,CODE,READONLY
				THUMB

				EXPORT			Periodic_Time_Init
					
Periodic_Time_Init	PROC
				PUSH		{R0-R7}
				
				LDR			R1,=SYSCTL_RCGCTIMER ;Open clock of timer3
				LDR			R0,[R1]
				ORR 		R0,#0x08
				STR 		R0,[R1]
				NOP
				NOP
				NOP
				
				LDR 		R1,=TIMER3_CTL 		;firstly disable timer 
				LDR 		R0,[R1]
				BIC 		R0,#0x01			;clear bit 0 to disable timer3
				STR 		R0,[R1]
				
				
				LDR			R1,=TIMER3_CFG		;Configuration of 16 vs 32 bit
				LDR			R0,[R1]
				ORR			R0,#0x04			;To use only 16 bit timer, individual mode
				STR			R0,[R1]
				
				
				LDR			R1,=TIMER3_TAMR		;Mode Choices
				LDR			R0,[R1]
				ORR			R0,#0x12			;Choose periodic mode,counts up
				STR			R0,[R1]				
				
						
				LDR 		R1,=TIMER3_TAILR	
				LDR 		R2,=Reload_Value
				STR 		R2,[R1] 			;load reload value
				
				;For step>5ms, we should use prescale in up count mode of timer
				;If prescale should be used in up count mode, then it will be timer extension.			
				LDR			R1,=TIMER3_TAPR		;Prescale Reg.
				LDR			R2,=Pres_Reload_Val
				STR 		R2,[R1] 			;load reload value for prescale register
				
				LDR 		R1, =TIMER3_IMR 	;Or we can pool GPTMRIS register to detect event
				MOV 		R2, #0x01			;enable time-out interrupt
				STR 		R2, [R1]		
				
			
;Use it for interrupt				
				LDR 		R1,=NVIC_PRI8  		;Priority
				LDR 		R2,[R1]
				AND 		R2,#0x0FFFFFFF 		;clear int#35 priority ;35.interrupt for NVIC
				ORR 		R2,#0x80000000 		;set priority#35 as 3 ;31:29. bits are used
				STR 		R2,[R1]
					
					
				LDR 		R1,=NVIC_EN1
				LDR 		R0,[R1]
				ORR 		R0,#0x00000008		;SET bit 3 to 1 for enable interrupt #35(32-63 interrupt number)
				STR 		R0,[R1]	
					
							
				LDR 		R1,=TIMER3_CTL
				LDR 		R0,[R1]
				ORR 		R0,#0x01			;enable timer,1101
				STR 		R0,[R1]
				
	
				
				POP			{R0-R7}
				BX			LR
				
				ENDP
				