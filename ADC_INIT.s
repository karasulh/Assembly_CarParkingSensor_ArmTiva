;ADC Registers
RCGCADC			EQU			0x400FE638	;ADC clock register
ADC0_ACTSS		EQU			0x40038000	;Active Sample Sequencer Register of ADC0 ;Base adress of ADC0
ADC0_RIS		EQU			0x40038004	;Raw Interrupt Status
ADC0_IM 		EQU 		0x40038008 ; Interrupt select/mask register
ADC0_EMUX 		EQU 		0x40038014 ; Trigger select/ADC event multiplexer select
ADC0_PSSI 		EQU 		0x40038028 ; Initiate sample/Processor Sample Sequence Initiate
ADC0_SSMUX3 	EQU 		0x400380A0 ; Input channel select/Sample Sequence Input Multiplexer Select 3
ADC0_SSCTL3	 	EQU 		0x400380A4 ; Sample sequence control/Interrupt Enable+End of sequence
ADC0_SSFIFO3 	EQU 		0x400380A8 ; Channel 3 results/Sample Sequence Result
ADC0_PC 		EQU 		0x40038FC4 ; Sample rate/ADC Sample Phase Control:
ADC0_ISC		EQU			0x4003800C ; Interrupt Status Clear Register

NVIC_EN0			EQU			0xE000E100		;NVIC Enable0 1.part(0-31) Register
NVIC_PRI4			EQU			0xE000E410		;Interrupt Priority 4. Register

;GPIO Registers
RCGCGPIO 		EQU 		0x400FE608 ; GPIO clock register
PORTE_DEN 		EQU 		0x4002451C ; Digital Enable
PORTE_PCTL 		EQU 		0x4002452C ; Port Control Register/Alternate function select
PORTE_AFSEL 	EQU 		0x40024420 ; Enable Alternate functions
PORTE_AMSEL 	EQU 		0x40024528 ; Enable analog
PORTE_DIR		EQU			0x40024400	;input output choose of pins

;LABEL			DIRECTIVE		VALUE		COMMENT
				AREA		subroutines,CODE,READONLY
				THUMB
				
				EXPORT		ADC_INIT

ADC_INIT		PROC		
;Open Clocks of ADC and GPIO
				LDR			R1,=RCGCADC		;Turn on ADC Clock
				LDR			R0,[R1]
				ORR 		R0,R0,#0x01 	; set bit 0 to enable ADC0 clock
				STR 		R0,[R1]
				NOP
				NOP
				NOP 						; Let clock stabilize
				
				LDR 		R1,=RCGCGPIO 	; Turn on GPIO clock
				LDR 		R0,[R1]
				ORR 		R0,R0,#0x10 	; set bit 4 to enable port E clock
				STR 		R0,[R1]
				NOP
				NOP
				NOP 						; Let clock stabilize
				
; Setup GPIO to make PE3 input for ADC0
				LDR 		R1,=PORTE_AFSEL	; Enable alternate functions
				LDR 		R0,[R1]
				ORR 		R0,R0,#0x08 	; set bit 3 to enable alternate functions on PE3
				STR 		R0,[R1]
				
				; PCTL does not have to be configured
				; since ADC0 is automatically selected when
				; port pin is set to analog.
				
				
				LDR 		R1,=PORTE_DEN	; Disable digital on PE3
				LDR 		R0,[R1]
				BIC 		R0,R0,#0x08 	; clear bit 3 to disable digital on PE3
				STR 		R0,[R1]
				
				LDR 		R1,=PORTE_AMSEL	; Enable analog on PE3
				LDR 		R0,[R1]
				ORR 		R0,R0,#0x08 	; set bit 3 to enable analog on PE3
				STR 		R0,[R1]
				
				LDR 		R1,=PORTE_DIR	; Make input to PE3
				LDR 		R0,[R1]
				BIC 		R0,R0,#0x08 	; clear bit3 for input as PE3
				STR 		R0,[R1]
				
;For ADC Setup, Using ADC0, Use SS3, Use AIN0 for pin E3 :		
				
				LDR 		R1,=ADC0_ACTSS	; Disable sequencer while ADC setup
				LDR 		R0,[R1]
				BIC 		R0,R0,#0x08 	; clear bit 3 to disable seq 3
				STR 		R0,[R1]
				
				
				LDR 		R1,=ADC0_EMUX	; Select trigger source
				LDR			R0,[R1]
				BIC 		R0,R0,#0xF000 	; clear bits 15:12 to select SOFTWARE/Processor trigger
				STR 		R0,[R1] 		; trigger
				
				
				LDR 		R1, =ADC0_SSMUX3 ; Select input channel
				LDR 		R0, [R1]
				BIC 		R0, R0, #0x000F  ; clear bits 3:0 to select AIN0
				STR 		R0, [R1]
				
				
				LDR 		R1,=ADC0_SSCTL3	; Config sample sequence
				LDR 		R0,[R1]
				ORR 		R0,R0,#0x06 	; set bits 2:1 (IE0, END0)
				STR 		R0, [R1]
				
				
				LDR 		R1,=ADC0_PC		; Set sample rate
				LDR 		R0,[R1]
				ORR 		R0,R0,#0x01	    ; set bits 3:0 to 1 for 125k sps
				STR 		R0,[R1]
				
				
				LDR 		R1,=ADC0_ACTSS	; Done with setup, enable sequencer
				LDR 		R0,[R1]
				ORR 		R0,R0,#0x08 	; set bit 3 to enable seq 3
				STR 		R0,[R1] 		; sampling enabled but not initiated yet
							
				
				
				
				BX			LR
				ENDP
				END