INs				EQU			0x4000503C		;PORTB all IN pins of motor driver bit masked 0-1-2-3 pins
TIMER3_ICR		EQU			0x40033024		;Timer Interrupt Clear
TIMER3_CTL		EQU			0x4003300C		;Timer Control
TIMER3_TAILR	EQU			0x40033028		;Timer Interval Load
speed_flag		EQU			0x20000790		;to speed up or down the motor according to distance		
TIMER3_TAPR		EQU			0x40033038		;Timer A Prescale Register
	
;LABEL			DIRECTIVE		VALUE		COMMENTS
				AREA		isr,CODE,READONLY
				THUMB
			
				EXPORT		motor_drive_periodic_handler
				EXTERN		write_brake

			
motor_drive_periodic_handler		PROC
				PUSH		{LR}
				PUSH		{R0-R9}			


;If threshold is smaller than distance, then control speed. If not, no control because it is in brake.				
				CMP			R7,R8   ;If distance is higher than threshold, check the waiting time for speed up or down of motor
				BLO			update_speed	
				BHS			control_for_stop

;Changing Speed Control Part
update_speed
;Add This part if we want TAILR should control changing time interval for speed
;BUT NOW, INSTEAD OF TAILR, USE TAPR, due to limitation of 5ms rule.
;				SUB			R1,R8,R7 ;R1: difference of threshold and distance ;an algorithm to speed up or down
;				MOV			R0,#0x0FFF
;				MUL			R1,R0
;				MOV			R2,#1000 ;1000 is the max difference and equal to 0x0FFF
;				UDIV		R1,R2	 
;				SUB			R1,R0,R1 ;R1:Will be added part to Prescaler Interval Register
;				LDR 		R0,=TIMER3_TAILR	
;				MOV			R3,#0xF000
;				ADD			R1,R3
;				STR 		R1,[R0] 			;load reload value for prescale register


;BONUS//BONUS//BONUS
;FIRST WAY
;BY CHANGING PRESCALE REGISTER VALUE, I adjust the speed of motor according to distance, because I should not be under 5ms period for driving motor.
;So, I use Prescale register as timer extension, I change its value according to difference between threshold and distance.
				SUB			R1,R8,R7 ;R1: difference of threshold and distance ;an algorithm to speed up or down
				MOV			R0,#0x0E ;ADD MAX 0x0E+0x01 to TAPR
				MUL			R1,R0
				MOV			R2,#1000 ;1000 is the max difference and equal to 0x0FFF
				UDIV		R1,R2	 
				SUB			R1,R0,R1 ;R1:Will be added part to Prescaler Interval Register
				LDR 		R0,=TIMER3_TAPR	
				MOV			R3,#0x01
				ADD			R1,R3
				STR 		R1,[R0] 			;load reload value for prescale register
				
;ADD THIS PART FOR 2nd Way, DONT USE NOW
;//2. way to change speed: Use flag to count waiting time			
;;Changing Speed Increment Flag Part 
;				LDR			R1,=speed_flag
;				LDR			R0,[R1]
;				ADD			R0,#1	;increment the count of waiting time
;				STR			R0,[R1]
;;If threshold is smaller than distance, then control the waiting time. If not, no control				
;				CMP			R7,R8   ;If distance is higher than threshold, check the waiting time for speed up or down of motor
;				BLO			count_check_wait_speed	
;				BHS			control_for_stop
;				SUB			R8,R7
;				
;;Changing Speed Control Part 
;count_check_wait_speed		
;				SUB			R1,R8,R7 ;an algorithm to speed up or down
;				MOV			R0,#1000
;				SUB			R0,R1
;				MOV			R2,#200
;				UDIV		R0,R2
;				
;				LDR			R1,=speed_flag ;Use this adress to count a flag to increase speed or decrease speed by changing waiting time
;				LDR			R2,[R1]
;				CMP			R2,R0		   ;To check the flag of speed, if the waiting is enough then turn the motor
;				BLO			exit		   ;If not, then wait without turn the motor
;				BEQ			control_for_stop
;				BHI			control_for_stop

;Control R10 flag, if it is 1, then it will be in break mode.
control_for_stop	
				CMP			R10,#1    	   ;R10 flag shows the brake mode
				BEQ			stop
				
				CMP			R7,R8          ;distance should not exceed threshold.
				BLO			SW1_cw
				BHS			stop
				
;break mode
stop	

;ADD THIS PART FOR 2nd Way
;				LDR			R1,=speed_flag ;Use this adress to count a flag to increase speed or decrease speed by changing waiting time
;				LDR			R0,[R1]
;				MOV			R0,#0			;start from 0 again the count of waiting time
;				STR			R0,[R1] 
				
				
				LDR 		R1,=TIMER3_CTL 		;firstly disable timer to stop motor
				LDR 		R0,[R1]
				BIC 		R0,#0x01			;clear bit 0 to disable timer3
				STR 		R0,[R1]
				
				LDR			R1,=INs			 ;Make motors input to 0 to cut power of motor
				AND			R0,#0xF0
				STR			R0,[R1]
				
				MOV			R10,#1			;R10 register is the indicator whether the system is in Preventative Breaking Mode. 
				B			exit

;Driving Motor Mode/Normal Mode
SW1_cw		

;ADD THIS PART FOR 2nd Way
;				LDR			R1,=speed_flag ;Use this adress to count a flag to increase speed or decrease speed by changing waiting time
;				LDR			R0,[R1]
;				MOV			R0,#0			;start from 0 again the count of waiting time
;				STR			R0,[R1]  
				
				LDR			R1,=INs		
				LDR			R0,[R1]
				AND			R0,#0x0F	;Make 0 other pins except output pins
				CMP			R0,#0x00		;If initially all output is 0
				MOVEQ		R0,#0x01	;Only IN1 is 1
				BEQ			store1
				CMP			R0,#0x08		;If IN4 was activ, then goes to IN1
				MOVEQ		R0,#0x01	;Only IN1 is 1
				LSLNE		R0,#1		;Left shift for change poles of motor driver
				
store1			STR			R0,[R1]
				
				B 			exit

;IF other direction is intended to turn motor
;SW2_ccw			
;				MOV			R8,#0	;If it waited for period, then make it 0 again to count again period.
;				
;				LDR			R1,=INs		
;				LDR			R0,[R1]
;				AND			R0,#0x0F	;Make 0 other pins except output pins
;				CMP			R0,#0x00		;If initially all output is 0
;				MOVEQ		R0,#0x08	;Only IN4 is 1
;				BEQ			store2
;				CMP			R0,#0x01		;If IN1 was activ, then goes to IN4
;				MOVEQ		R0,#0x08	;Only IN4 is 1
;				LSRNE		R0,#1		;Left shift for change poles of motor driver

;store2			STR			R0,[R1]
;				
;				B 			exit
			
			
			
exit			
				LDR			R1,=TIMER3_ICR		
				MOV			R0,#0x01 ;clear the interrupt
				STR			R0,[R1] ;clear all interrupt flags

				
				POP			{R0-R9}
				POP			{LR}
				BX			LR
				ENDP
				END