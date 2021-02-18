; constants

;===================
; Timer 1 registers
;===================
TIMER1_CFG			EQU 0x40031000 ; Timer Configuration
TIMER1_TAMR			EQU 0x40031004 ; Timer A Mode
TIMER1_CTL			EQU 0x4003100C ; Timer Control
TIMER1_TAILR		EQU 0x40031028 ; Timer Interval
TIMER1_TAMATCHR		EQU	0x40031030 ; Timer Match
TIMER1_TAPR			EQU 0x40031038 ; Timer Prescaler
TIMER1_IMR		EQU			0x40031018		;Timer Interrupt Mask
;=======================
; GPIO Port F registers
;=======================
;GPIO Registers
GPIO_PORTF_DATA		EQU 0x40025010 ; Access BIT2
GPIO_PORTF_DIR 		EQU 0x40025400 ; Port Direction
GPIO_PORTF_AFSEL	EQU 0x40025420 ; Alt Function enable
GPIO_PORTF_DEN 		EQU 0x4002551C ; Digital Enable
GPIO_PORTF_AMSEL 	EQU 0x40025528 ; Analog enable
GPIO_PORTF_PCTL 	EQU 0x4002552C ; Alternate Functions

;=================
;System Registers
;=================
SYSCTL_RCGCGPIO 	EQU 0x400FE608 ; GPIO Gate Control
SYSCTL_RCGCTIMER 	EQU 0x400FE604 ; GPTM Gate Control
	

;For 4kHz and %25 duty cycle
Reload_Value	EQU			4000	;Reload Value  ;0x0FA0
Match_Value		EQU			1000	;initial for 25%		;Match register value 0x03E8	

	

		AREA subroutine, READONLY, CODE
        thumb
		EXTERN InChar
		EXPORT	pwm_pulse
        

;==============
; PF2 PWM Init
;==============
pwm_pulse PROC
	;===================
	; Configure PORTF.2
	;===================
		PUSH		{R0-R7}
		LDR R1, =SYSCTL_RCGCGPIO ; start GPIO clock
		LDR R0, [R1]
		ORR R0, R0, #0x20 ; set bit 5 for port F
		STR R0, [R1]
		NOP ; allow clock to settle
		NOP
		NOP
		LDR R1, =GPIO_PORTF_DIR ; set direction of PF2
		LDR R0, [R1]
		ORR R0, R0, #0x04 ; set bit2 for output
		STR R0, [R1]
		LDR R1, =GPIO_PORTF_AFSEL ; specific timer port function
		LDR R0, [R1]
		ORR R0, R0, #0x04
		STR R0, [R1]
		LDR R1, =GPIO_PORTF_PCTL ; yes alternate function
		LDR R0, [R1]
		ORR R0, R0, #0x00000700
		STR R0, [R1]
		LDR R1, =GPIO_PORTF_AMSEL ; disable analog
		MOV R0, #0
		STR R0, [R1]
		LDR R1, =GPIO_PORTF_DEN ; enable port digital
		LDR R0, [R1]
		ORR R0, R0, #0x04
		STR R0, [R1]
	
	;====================
	; Configure TIMER1-A
	;====================
	
		LDR			R1,=SYSCTL_RCGCTIMER ;Open clock of timer1
		LDR			R0,[R1]
		ORR 		R0,#0x02
		STR 		R0,[R1]
		NOP
		NOP
		NOP
		
		LDR 		R1,=TIMER1_CTL 		;firstly disable timer 
		LDR 		R0,[R1]
		BIC 		R0,#0x01			;clear bit 0 to disable timer0
		STR 		R0,[R1]

		LDR			R1,=TIMER1_CFG		;Configuration of 16 vs 32 bit
		LDR			R0,[R1]
		ORR			R0,#0x04				;To use only 16 bit timer, individual mode
		STR			R0,[R1]

		LDR			R1,=TIMER1_TAMR		;Mode Choices
		LDR			R0,[R1]
		ORR			R0,#0x0A			;Choose periodic,Edge count Mode,PWM Mode ;1010=10
		STR			R0,[R1]				
		
		LDR 		R1,=TIMER1_CTL 		;PWM output is inverted or not 
		LDR 		R0,[R1]				;Look the 6. bit of CTL reigster
		ORR 		R0,#0x40			;Make 1 for inverted
		STR 		R0,[R1]				;yes Inverted
	
		;LDR 		R1, =TIMER1_IMR 	;Or we can pool GPTMRIS register to detect event
		;MOV 		R2, #0x04			;enable capture event interrupt
		;STR 		R2, [R1]
		
		LDR 		R1, =TIMER1_TAPR		;Zero Prescaler
		MOV 		R2, #0  
		STR 		R2, [R1] 
		
		LDR 		R1,=TIMER1_TAILR	
		LDR 		R2,=Reload_Value
		STR 		R2,[R1] 			;load reload value

		
		LDR			R1,=TIMER1_TAMATCHR
		LDR			R0,=Match_Value		;Specify match value
		STR			R0,[R1]
		
		LDR 		R1,=TIMER1_CTL
		LDR 		R0,[R1]
		ORR 		R0,#0x03			;enable timer,0001
		STR 		R0,[R1]
	
		POP			{R0-R7}
		BX			LR
		ENDP
		END

	
