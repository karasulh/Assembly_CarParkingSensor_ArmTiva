;LABEL			DIRECTIVE	VALUE		COMMENT
;GPIO Port E Registers
SYSCTL_RCGCGPIO EQU 		0x400FE608 ; GPIO clock register
PORTE_DEN 		EQU 		0x4002451C ; Digital Enable
PORTE_PCTL 		EQU 		0x4002452C ; Port Control Register/Alternate function select
PORTE_AFSEL 	EQU 		0x40024420 ; Enable Alternate functions
PORTE_AMSEL 	EQU 		0x40024528 ; Enable analog
PORTE_DIR		EQU			0x40024400	;input output choose of pins
PORTE_PUR		EQU			0x40024510	;Pull up resistors

;GPIO Port D Registers
GPIO_PORTD_DATA		EQU			0x400073FC	;accesible all pins of D to write and read
GPIO_PORTD_DIR		EQU			0x40007400	;input output choose of pins	
GPIO_PORTD_AFSEL	EQU			0x40007420	;specific function selection, now no selection
GPIO_PORTD_DEN		EQU			0x4000751C	;digital enable of pins

GPIO_PORTF_MIS	EQU			0x40025418	;Read only, learn to Interrupt Mask Status 

col1				EQU			0x40024004 	;column1	E0 pin	R1on_keypad
col2				EQU			0x40024008 	;column2	E1 pin	R2on_keypad
col3				EQU			0x40024010 	;column3	E2 pin	R3on_keypad
col4				EQU			0x40024040 	;column4	E4 pin	R4on_keypad
row1				EQU			0x40007010	;row1 		D2 pin	L1on_keypad
row2				EQU			0x40007020	;row2		D3 pin	L2on_keypad
row3				EQU			0x40007100	;row3		D6 pin	L3on_keypad
row4				EQU			0x40007200	;row4		D7 pin	L4on_keypad	
rows				EQU			0x40007330	;all rows bit masked port D as outputs
cols				EQU			0x4002405c	;all columns bit masked port E as inputs

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
				AREA		main_sub,CODE,READONLY
				THUMB
				
				EXPORT		keypad_control
				EXPORT		PortE_D_Init
				EXTERN		DELAY1	
				EXTERN		DELAY100
				EXTERN		DELAY10
				EXTERN		OutStr
				EXTERN		CONVRT
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


PortE_D_Init	PROC
				
				LDR 		R1,=SYSCTL_RCGCGPIO 	; Turn on GPIO clock
				LDR 		R0,[R1]
				ORR 		R0,R0,#0x18			 	; set bit 3,4 to enable port D,E clock
				STR 		R0,[R1]
				NOP
				NOP
				NOP 						; Let clock stabilize

;Port E as input
				LDR 		R1,=PORTE_AFSEL	; Disable alternate functions
				LDR 		R0,[R1]
				BIC 		R0,R0,#0x17 	; except pin 3(analog read) to disable alternate functions 0,1,2,4
				STR 		R0,[R1]
				
				
				
				LDR 		R1,=PORTE_DEN	; Enable digital
				LDR 		R0,[R1]
				ORR 		R0,R0,#0x17 	; 0,1,2,4 bit pins are digital
				STR 		R0,[R1]
				
				LDR 		R1,=PORTE_AMSEL	; Disable analog 
				LDR 		R0,[R1]
				BIC 		R0,R0,#0x17 	; except bit 3, disable analog 
				STR 		R0,[R1]
				
				LDR 		R1,=PORTE_DIR	; Use pins as inputs
				LDR 		R0,[R1]
				BIC 		R0,R0,#0x17 	; clear bit0,1,2,4 for input 
				STR 		R0,[R1]
				
				
				LDR			R1,=PORTE_PUR	;Pull Up Resistor to input
				MOV			R0,#0x17
				STR			R0,[R1]
				
;Port D as output

				
				LDR			R1,=GPIO_PORTD_AFSEL
				LDR			R0,[R1]
				BIC			R0,#0x4C		;2.3.6. pins are normal gpio
				STR			R0,[R1]
				
				LDR			R1,=GPIO_PORTD_DEN
				LDR			R0,[R1]
				ORR			R0,#0x4C       ;2.3.6. pins are digital.
				STR			R0,[R1]
				
				LDR			R1,=GPIO_PORTD_DIR
				LDR			R0,[R1]
				ORR			R0,#0x4C		;2.3.6. pins are output
				STR			R0,[R1]
				
				BX			LR
				ENDP
				


;BONUS//BONUS//BONUS
keypad_control	PROC	
				PUSH		{LR}
				PUSH		{R0-R6}
				PUSH		{R8-R12}
				
				MOV			R12,#0			;Use a flag to get 3 buttons as 3 digits from user
				
				
new_start		

				CMP			R12,#3          ;3.button is taken, then make flag 0 to take first digit again.
				MOVEQ		R12,#0
				
				LDR			R1,=rows				;Make ALL rows output as 0.
				LDR			R0,[R1]
				BIC			R0,#0x4C
				STR			R0,[R1]
				
				

press_key_check		
				;Previously::Check second push to SW2
				LDR			R1,=GPIO_PORTF_MIS	;Which bit/pin goes into interrupt for F port
				LDR			R0,[R1]
				CMP			R0,#0x10			;If it is equal then the second times, SW1 is pushed.
				BEQ.W		finish_3_digit_taken ;Leave to take new samples
											;Check is there any key pressed
				LDR			R1,=cols		;use column to read
				NOP
				LDR			R0,[R1]			
				AND			R0,#0x17
				CMP			R0,#0x17		;If no key pressed, then input should give 10111.
				BEQ			press_key_check
				BNE			control_debounce

control_debounce	

				BL			DELAY100		;control for debouncing
				LDR			R1,=cols		;use column to read
				LDR			R0,[R1]			;control again the value
				NOP
				AND			R0,#0x17
				CMP			R0,#0x17		;To be sure, we again check whether the input is different than 10111
				BEQ			press_key_check
				BNE			key_finder	;then we are sure the key is pressed.



key_finder		
				ADD			R12,#1			;Use a flag to get 3 buttons as 3 digits from user
				
											;All combinations for row. Write to rows R4,R3,R2,R1:1110,1101,1011,0111
				LDR			R1,=rows		
				MOV			R2,#0x48		;1110
				STRB		R2,[R1]			;first row become 1, others 0
				MOV			R6,#0			;R6 row number
				BL			column_checker
			
				LDR			R1,=rows
				MOV			R2,#0x44		;1101
				STRB		R2,[R1]			;second row become 1, others 0
				MOV			R6,#1			;R6 row number
				BL			column_checker
			
				LDR			R1,=rows
				MOV			R2,#0x0C		;1011
				STRB		R2,[R1]			;third row become 1, others 0
				MOV			R6,#2			;R6 row number
				BL			column_checker
				
;Dont Use row4			
;				LDR			R1,=rows			
;				MOV			R2,#0x4C		;0111
;				STRB		R2,[R1]			;fourth row become 1, others 0
;				MOV			R6,#3			;R6 row number
;				BL			column_checker
				B			last
				
column_checker				
				LDR			R3,=cols		;use column to read
				LDR			R0,[R3]
				AND			R4,R0,#0x17
				EOR			R4,R4,#0x17		;bitwise complement XOR, it is for reading easily.
				CMP			R4,#0			;check if there is any zero in inputs/pushed button
				BNE			ID_finder		;If there is not any pressed key in this row, R0 should give 1111 and R4 gives 0000
				BX			LR				;So if it is not 0000, then we understand that pressed key is here (in this row).



ID_finder		MOV			R1,#4			;To find ID we use this part.
				MUL			R6,R6,R1		;R6 row multiplier for ID
				CMP 		R4,#0x10			;If R4(actually R0) is 10,then it means it is 4.column
				ADDEQ		R6,#3			;R7 returns the ID number
				BEQ			releasing
				CMP			R4,#0x04			;If R4(actually R0) is 04,then it means it is 3.column
				ADDEQ		R6,#2			;These are column equivalent.
				BEQ			releasing
				CMP 		R4,#0x02			;If R4(actually R0) is 02,then it means it is 1.column
				ADDEQ		R6,#1
				BEQ			releasing
				CMP			R4,#0x01			;If R4(actually R0) is 01,then it means it is 0.column
				ADDEQ		R6,#0	
				BEQ			releasing
				

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
				BEQ			writing		;then we are sure the key is released.
			

writing			
				
				CMP			R6,#10		;10 and 11 is invalid digits
				SUBEQ		R12,#1
				BEQ			last
				CMP			R6,#11
				SUBEQ		R12,#1
				BEQ			last
				
				BL			clear_screen_lcd	 ;Used to clean the screen of LCD panel
				BL			write_measure		 ;Used to write "Meas(mm):"
				BL			write_star			 ;Used to write "***"
				
				;Write threshold value to LCD
				BL			write_threshold_for_lcd ;it writes "Thre(mm):"
										
				CMP			R12,#1		;the first input is accepted as hundreds
				MOVEQ		R1,#100
				MULEQ		R7,R6,R1
										
				CMP			R12,#2		;the second input is accepted as tens
				MOVEQ		R1,#10
				MULEQ		R6,R6,R1
				ADDEQ		R7,R6
										
				CMP			R12,#3		;the third input is accepted as ones
				ADDEQ		R7,R6
				
										;write each digit of threshold
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
				LDR			R5,=MSG		;Explanation of results is written onto termite.
				BL			OutStr
				LDR			R5,=0x20000400
				MOV			R4,R7			;R4 is input for CONVRT
				BL			CONVRT
				LDR			R5,=0x20000400	;R5 is given for the OutStr adress to write.
				BL			OutStr
				
				LDR			R5,=EMPTYMES		;Endline for termite.
				BL			OutStr
				
last			B			new_start

finish_3_digit_taken
				
				POP		{R8-R12}
				POP		{R0-R6}
				POP		{LR}
				BX		LR
				
				ENDP
				END
					
					
