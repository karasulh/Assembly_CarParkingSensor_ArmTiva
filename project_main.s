ADC0_SSFIFO3 	EQU 		0x400380A8 ; Channel 3 results/Sample Sequence Result
ADC0_RIS		EQU			0x40038004	;Raw Interrupt Status
ADC0_PSSI 		EQU 		0x40038028 ; Initiate sample/Processor Sample Sequence Initiate
ADC0_ISC		EQU			0x4003800C ; Interrupt Status Clear Register

Count_SW1 		EQU			0x20000760	;Use it to follow of the first push of SW1 or second push of SW1	

TIMER0_RIS		EQU			0x4003001C		;Timer Raw Interrupt Status
TIMER0_MIS		EQU			0x40030020		;Timer Masked Interrupt Status
TIMER0_ICR		EQU			0x40030024		;Timer Interrupt Clear
TIMER0_TAR		EQU			0x40030048		;Timer A Register
TIMER0_TAPR		EQU			0x40030038		;Timer A Prescale Register
echo_pin		EQU			0x40005100		;input pin for event ;B6 pin
TIMER1_TAMATCHR		EQU		0x40031030 ; Timer Match


DC_A6_pin			EQU			0x40004100	;Data/Command		;A6	pin
RST_A7_pin			EQU			0x40004200	;RST				;A7 pin


;;USE FOR TRIGGER F2
;;USE FOR ECHO	 B6 pins



;LABEL			DIRECTIVE	VALUE		COMMENT
				AREA        sdata, DATA, READONLY
				THUMB
MSG1     		DCB     	"Period(us):"
				;DCB			0x0D		; carriage return
				DCB			0x04		;end of transmission

MSG2			DCB     	"Pulse Width(us):"
				;DCB			0x0D		; carriage return
				DCB			0x04		;end of transmission

MSG3			DCB     	"Duty Cycle(%):"
				;DCB			0x0D		; carriage return
				DCB			0x04		;end of transmission

MSG4			DCB     	"Distance(mm):"
				;DCB			0x0D		; carriage return
				DCB			0x04		;end of transmission

EMPTYMES		DCB			0x0D		;carriage return
				DCB			0x04		;end of transmission
			
			
MSG     		DCB     	"Analog Input Voltage(V):"
				DCB			0x0D		; carriage return
				DCB			0x04		;end of transmission

				
point			DCB			"."			;carriage return
				DCB			0x04		;end of transmission


;LABEL			DIRECTIVE		VALUE		COMMENT
				AREA		main,CODE,READONLY
				THUMB
				
				EXPORT		__main
				EXTERN		PortF_Init
				EXTERN		PortB_Init_Alternate	;FOR EDGE CAPTURE PIN	;PIN B6
				EXTERN		pwm_pulse				;FOR PWM 				;PIN F2    	;Timer1
				EXTERN		PortF_Interrupt_Init
				EXTERN		ADC_INIT				;Port E3 and ADC initializing
				EXTERN		Edge_Time_Init			;Timer0
				EXTERN		OutStr
				EXTERN		CONVRT
				EXTERN		DELAY1
				EXTERN		Periodic_Time_Init
				EXTERN		SPI_Configuration
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
				EXTERN		write_distanceX
				EXTERN		write_distance_obstacle
				EXTERN		PortE_D_Init
				EXTERN		keypad_control
					

__main			PROC
;READ ANALOG FROM E3 Pin
;R7 register is threshold value
;R10 register is the indicator whether the system is in Preventative Breaking Mode.
;R9 is the flag to count the number of detected edges of distance sensor to measure.
;R8 is the distance in mm

				
				MOV			R7,#100				 ;Initially threshold is 300 before any settings
				MOV			R8,#101			     ;Initially make distance more than threshold to prevent enter brake mode when the distance high
				
				BL			PortF_Init			 ;Used to control SW1 and SW2
				BL			PortF_Interrupt_Init ;Used to understand the time when SW1 and SW2 are pushed and read potentiometer.
				BL			ADC_INIT			 ;Used to start ADC
				BL			PortB_Init_Alternate ;Used to adjust B6 pin for echo pin of distance sensor, Used to drive motor via B output pins 
				BL			pwm_pulse			 ;Which creates input signal PWM
				BL			Edge_Time_Init		 ;Used to measure time of distance sensor outputs echo pin of distance sensor
				BL			Periodic_Time_Init   ;Used to drive a motor with periodic timer
				BL			SPI_Configuration	 ;Used to initialize A port and SPI 
				BL			clear_screen_lcd	 ;Used to clean the screen of LCD panel
				BL			PortE_D_Init		 ;Used to activate GPIO for keypad.
				
				LDR			R2,=Count_SW1        ;A flag to follow the sw1 push times (first or second push)
				MOV			R3,#0
				STRB		R3,[R2]
				

				MOV			R9,#0			;Initializations
				MOV			R2,#0
				MOV			R3,#0
				MOV			R4,#0
				MOV			R5,#0
				MOV			R10,#0

				

			
;To measure the distance, we poll it the distance sensor.				
loop			LDR			R1,=TIMER0_RIS	;Check if the event occurs
				LDR			R0,[R1]
				ANDS		R0,#0x04		;To look only CAERIS bit to check event occurring
				BEQ			loop
					
				ADD			R9,#1			;R9 is our flag to count edge
				
				LDR			R1,=TIMER0_TAR
				LDR			R0,[R1]			;To get timer register value
				
				
				CMP			R9,#1
				MOVEQ		R2,R0			;If it is the first edge,then copy the timer value to R2
				BEQ			check_edge
				BNE			second_edge
				
check_edge
				LDR			R1,=echo_pin
				LDR			R0,[R1]
				CMP			R0,#0x40		;If the input is 1 after first edge detection(POSEDGE)
				MOVEQ		R5,#1			;Make R5 as 1 for POSEDGE
				MOVNE		R5,#0			;Make R5 as 0 for NEGEDGE
				
second_edge				
				CMP			R9,#2
				MOVEQ		R3,R0			;If it is the second edge,then copy the timer value to R3
				BEQ			calculation
				
clear			
				LDR			R1,=TIMER0_ICR	 ;Clear the interrupt
				LDR			R0,[R1]
				ORR			R0,#0x04		;To clear CAECINT bit,write 1 to second bit
				STR			R0,[R1]
				B			loop


calculation
				CMP			R2,R3			;Result should be positive, so we checked this.
				BHS			continue_calculation	
				MOVLO		R9,#0			;If R5 is not high POSEDGE, it returns to initial poisiton and try to find high value
				BLO			loop
				
continue_calculation				
				CMP			R5,#1
				SUBEQ		R8,R2,R3		;R8 is the pulse width
				MOVNE		R9,#0			;If R5 is not high POSEDGE, it returns to initial poisiton and try to find high value
				BNE			loop
				
				
				MOV			R1,#10
				UDIV		R8,R1
				MOV			R1,#625			;for 1 clock=62.5 ns
				MUL			R8,R1			;To find in terms of microsecond
				MOV			R1,#1000
				UDIV		R8,R1			;R8 in terms of microsecond
				MOV			R1,#170			;340/2 speed of sound
				MUL			R8,R1
				MOV			R1,#1000
				UDIV		R8,R1			;R8 is distance in mm
				
				
				MOV			R1,#999			;Max is 999
				CMP			R8,R1
				MOVHI		R8,R1
				
				
				BL			clear_screen_lcd	 ;Used to clean the screen of LCD panel
				;Write the distance to LCD
				BL			write_measure		 ;Used to write "Meas:" to screen
				MOV			R1,#100
				UDIV		R11,R8,R1
				BL			Numbers_for_LCD		;first digit
				MOV			R1,#100
				MUL			R11,R1
				SUB			R11,R8,R11
				MOV			R1,#10
				UDIV		R11,R11,R1
				BL			Numbers_for_LCD		;second digit
				MOV			R1,#10
				UDIV		R11,R8,R1
				MUL			R11,R1
				SUB			R11,R8,R11
				BL			Numbers_for_LCD		;third digit
				
				;Write threshold value to LCD
				BL			write_threshold_for_lcd ;it write "Thre(mm):"	
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
				BL			write_car			;to write the car "Car"
				BL			write_distanceX		;to show the location "X" and "-"
				BL			write_distance_obstacle ;;to show the locations of "|"
				
				CMP			R10,#0
				BLEQ		write_normal_operation ;To show the operation mode:Normal Mode
				
				CMP			R10,#1      ;Flag of Brake
				BLEQ		write_brake ;To show the operation mode:Brake Mode
				
				;Write to termite
				LDR			R5,=MSG4		;Explanation of results is written onto termite.
				BL			OutStr
				LDR			R5,=0x20000500	;R5 is the adress for storing elements of CONVRT.
				MOV			R4,R8
				BL			CONVRT
				NOP
				BL			OutStr
				
				LDR			R5,=EMPTYMES	;For end line
				BL			OutStr
				

				
endd			
				MOV		R9,#0			;Initializations
				MOV		R2,#0
				MOV		R3,#0
				MOV		R4,#0
				MOV		R5,#0
				
						
				
				LDR		R1,=TIMER0_ICR	 ;Clear the interrupt
				LDR		R0,[R1]
				ORR		R0,#0x04		;To clear CAECINT bit,write 1 to second bit
				STR		R0,[R1]
				
				BL		DELAY1
				
				B		loop				
				
				
				
				
				
				ENDP
				END