GPIO_PORTF_IS		EQU			0x40025404		;Interrupt sense, edge=0 vs level=1
GPIO_PORTF_IBE		EQU			0x40025408		;Interrupt both edges, both edge trigger int. if 1
GPIO_PORTF_IEV		EQU			0x4002540C		;Interrupt Event, falling edge-low level 0, rising edge-high level 1
GPIO_PORTF_IM		EQU			0x40025410		;Interrupt mask, make 1 to active pin for interrupt
GPIO_PORTF_ICR		EQU			0x4002541C		;To delete interrupt flag make 1, Clear register
GPIO_PORTF_RIS		EQU			0x40025414		;Read only, Interrupt Status of Pins
GPIO_PORTF_MIS		EQU			0x40025418		;Read only, learn to Interrupt Mask Status 
NVIC_EN0			EQU			0xE000E100		;NVIC Enable0 1.part(0-31) Register
NVIC_PRI7			EQU			0xE000E41C		;Interrupt Priority 7. Register

;LABEL				DIRECTIVE		VALUE		COMMENTS
					AREA		subroutines,CODE,READONLY
					THUMB

					EXPORT		PortF_Interrupt_Init


PortF_Interrupt_Init PROC
					PUSH {R0-R6}				
				
				
					LDR		R1,=GPIO_PORTF_IS
					MOV		R0,#0x00
					STR		R0,[R1]	;make edge triggering		

					LDR		R1,=GPIO_PORTF_IBE
					MOV		R0,#0x00
					STR		R0,[R1]	;make not both edge triggering
					
					LDR		R1,=GPIO_PORTF_IEV
					MOV		R0,#0x00
					STR		R0,[R1]	;falling edge ;when pushing key it will be active.
					
					LDR		R1,=GPIO_PORTF_IM
					MOV		R0,#0x11 
					STR		R0,[R1]	;F0 and F4 pins are active interrupt
					
					LDR		R1,=GPIO_PORTF_ICR
					MOV		R0,#0x11 ;F0 and F4 pins 
					STR		R0,[R1] ;clear all interrupt flags
					
; PortF is interrupt #30.
; Interrupts 28-31 are handled by NVIC register PRI7.
; Interrupt 30 is controlled by bits 23:21 of PRI7.
; set NVIC interrupt 30 to priority 2					
					LDR 	R1,=NVIC_PRI7		;We should use 15:13 pins of this register for 4n+1=21.interrupt n=5 from pri5
					LDR 	R0,[R1]
					AND 	R0,R0, #0xFF0FFFFF ; clear interrupt 30 priority  23:21. bits should be clear
					ORR 	R0,R0, #0x00400000 ; set interrupt 30 priority to 2 to 23:21. bits
					STR 	R0,[R1]
					
					LDR		R1,=NVIC_EN0
					MOV		R0,#0x40000000 ;To enable NVIC 30.vector which is portF_handler, note : 0.vector is portA_handler
					STR		R0,[R1]
					
				
				
				
					POP {R0-R6}
				
					BX		LR
				
					ENDP