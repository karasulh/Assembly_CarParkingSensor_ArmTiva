ADC0_SSFIFO3 	EQU 		0x400380A8 ; Channel 3 results/Sample Sequence Result
ADC0_RIS		EQU			0x40038004	;Raw Interrupt Status
ADC0_PSSI 		EQU 		0x40038028 ; Initiate sample/Processor Sample Sequence Initiate
ADC0_ISC		EQU			0x4003800C ; Interrupt Status Clear Register

SW1				EQU			0x40025040	;Switch1		;F4 pin

Count_SW1 		EQU			0x20000750	;Use it to follow of the first push of SW1 or second push of SW1	
GPIO_PORTF_MIS	EQU			0x40025418	;Read only, learn to Interrupt Mask Status 
GPIO_PORTF_ICR	EQU			0x4002541C	;To delete interrupt flag make 1, Clear register

rows			EQU			0x40007330	;all rows bit masked port D as outputs
cols			EQU			0x4002405c	;all columns bit masked port E as inputs
row3			EQU			0x40007100	;row3		D6 pin	L3on_keypad
col4			EQU			0x40024040 	;column4	E4 pin	R4on_keypad


;LABEL			DIRECTIVE	VALUE		COMMENT
            	AREA        sdata, DATA, READONLY
            	THUMB
MSG     		DCB     	"New Threshold Value:"
				DCB			0x0D		; carriage return
				DCB			0x04		;end of transmission

EMPTYMES		DCB			0x0D		;carriage return
				DCB			0x04		;end of transmission
				
point			DCB			"."			;carriage return
				DCB			0x04		;end of transmission

;LABEL			DIRECTIVE		VALUE		COMMENT
				AREA		subroutines,CODE,READONLY
				THUMB
				
				EXPORT		Read_Potentiometer
				EXTERN		ADC_INIT
				EXTERN		DELAY1
				EXTERN		OutStr
				EXTERN		CONVRT
				EXTERN		OutChar
				EXTERN		write_measure
				EXTERN		write_threshold_for_lcd
				EXTERN		clear_screen_lcd
				EXTERN		Numbers_for_LCD
				EXTERN		write_normal_operation
				EXTERN		write_thre_adjustment
				EXTERN		write_brake
				EXTERN		write_car
				EXTERN		write_star
				EXTERN		write_stars
				EXTERN		keypad_control
				EXTERN		DELAY100

Read_Potentiometer PROC
;READ ANALOG FROM E3 Pin

				PUSH		{LR}
				PUSH		{R0-R6} ;DON'T ADD R7, R7 is used for threshold value
			
				LDR			R1,=GPIO_PORTF_ICR		
				MOV			R0,#0x11 ;pin 0,4
				STR			R0,[R1] ;clear all interrupt flags


Start_Sampling 	; initiate sampling by enabling sequencer 3 in ADC0_PSSI
				LDR 		R1,=ADC0_PSSI 		; sample sequence initiate address
				LDR 		R0,[R1]
				ORR 		R0,R0,#0x08 		; set bit 3 for SS3 to initiate sampling
				STR 		R0,[R1]
				
				
Check_complete 	; check for sample complete (bit 3 of ADC0_RIS set)
				LDR 		R1,=ADC0_RIS 		; interrupt address
				LDR 		R0,[R1]
				ANDS 		R0,R0,#0x08
				BEQ 		Check_complete

Sample_completed
				LDR			R5,=MSG		;Explanation of results is written onto termite.
				BL			OutStr
				
				;branch fails if the flag is set so data can be read and flag is cleared
				LDR 		R1,=ADC0_SSFIFO3 	; result address
				LDR 		R0,[R1]				;R0 gives the result of analog signal in terms of decimal format between 0-4095 for 12 bit
				
				MOV			R2,#999				;shows max limit of distance mm
				MUL			R7,R0,R2			;Direct proportion: 999 mm is equal to 4095 in digital value, so find R7(current value potentiometer) in digital
				MOV			R2,#4095			;12 bit=4096-1=4095 max value
				UDIV		R7,R7,R2			;R7 is between 0-999 mm
				
				BL			clear_screen_lcd	 ;Used to clean the screen of LCD panel
				BL			write_measure		 ;Used to write "Meas(mm):"
				BL			write_star			 ;Used to write "***"
				

				;Write threshold value to LCD by selecting each digit of numbers, then send them to LCD screen
				BL			write_threshold_for_lcd ;it writes "Thre(mm):"	
				MOV			R1,#100
				UDIV		R11,R7,R1
				BL			Numbers_for_LCD		;first digit
				MOV			R1,#100
				MUL			R11,R1
				SUB			R11,R7,R11
				MOV			R1,#10
				UDIV		R11,R11,R1
				BL			Numbers_for_LCD		;second digit
				MOV			R1,#10
				UDIV		R11,R7,R1
				MUL			R11,R1
				SUB			R11,R7,R11
				BL			Numbers_for_LCD		;third digit
				
				;To show the operation mode:Threshold Adjustment Mode
				BL			write_thre_adjustment
				;To show stars
				BL			write_stars
				
				;Write to termite
				MOV			R4,R7				;Print threshould distance
				LDR			R5,=0x20000500
				BL			CONVRT
				BL			OutStr
				BL			DELAY1
				LDR			R5,=EMPTYMES		;Endline for termite.
				BL			OutStr
				
				
				LDR 		R1,=ADC0_ISC		; Interrupt Clear Register
				MOV 		R0,#0x08
				STR 		R0,[R1] ; clear flag
				

;BONUS//BONUS//BONUS
;To use Keypad, we pool the key K12(12.button). When we pushed the K12 for 1 sec, it will capture and after being sure that the key is pressed
;It goes to "keypad_control" subroutine, to take digits.
;;;;;;;;;;;;;;;;;;;;KEYPAD	pooling							
keypad_check_start
				LDR			R1,=row3		;Make 3. row output as 0.
				LDR			R0,[R1]
				BIC			R0,#0x40
				STR			R0,[R1]
				MOV			R2,#3

press_key_check				
											;Check is there any key pressed
				LDR			R1,=col4		;use column to read
				NOP
				LDR			R0,[R1]			
				AND			R0,#0x10
				CMP			R0,#0x10		;If no key pressed, then input should give 10000.
				BNE			control_debounce
				CMP			R2,#0			;3 times pooling for each loop
				SUBNE		R2,#1
				BNE			press_key_check		
				BEQ			continue_to_check

control_debounce	
				LDR			R5,=point		;Endline for termite. Shows the control belongs to keypad.
				BL			OutStr
				
				BL			DELAY100		;control for debouncing
				LDR			R1,=col4		;use column to read
				LDR			R0,[R1]			;control again the value
				NOP
				AND			R0,#0x10
				CMP			R0,#0x10		;To be sure, we again check whether the input is different than 10111
				BEQ			continue_to_check
				BNE			releasing

releasing
				
				LDR			R1,=cols		;use column to read
				NOP
				LDR			R0,[R1]	
				AND			R0,#0x17
				CMP			R0,#0x17		;look for directly whether all inputs are 1
				BNE			releasing		;If not, we understand key is still being pressed.
				BEQ			control_debounce2	;If yes, then we check the debouncing
				

control_debounce2
				BL			DELAY100		;control for debouncing
				LDR			R1,=cols		;use column to read
				NOP
				LDR			R0,[R1]
				AND			R0,#0x17
				CMP			R0,#0x17		;checking "Really released?"
				BNE			releasing	
				BLEQ		keypad_control		;then we are sure the key is released.
				BEQ			exit

;;;;;;;;;;;;Keypad part finishes.


continue_to_check

				LDR			R1,=GPIO_PORTF_MIS	;Which bit/pin goes into interrupt for F port
				LDR			R0,[R1]
				CMP			R0,#0x10			;If it is equal then the second times, SW1 is pushed.
				BEQ			exit				;Leave to take new samples
				

				B 			Start_Sampling
												
				
				
exit				
				
				POP			{R0-R6}
				POP			{LR}
				BX			LR
				ENDP
				END