;***************************************************************
; Program section					      
;***************************************************************
;LABEL		DIRECTIVE	VALUE		COMMENT
			AREA    	routines, READONLY, CODE
			THUMB
				
			EXTERN		__main	; Reference external subroutine	
			EXPORT  	CONVRT	; Make available

CONVRT 		PROC
			
			PUSH		{R0-R8}
			
			 
			MOV			R6,R5		;Take the adress not to lose
			MOV			R3,#10
			MOV			R0,#0x04	;It is a need for finish of OutStr 

			CMP			R4,#10
			BLO			first
			BHS			second
			
first		ADD			R4,#48
			STR			R4,[R5],#1		;If it is one digit
			STR			R0,[R5]
			B			exit

second
			UDIV		R1,R4,R3
									;take digits of our number and store them into memory in reverse order.
loop		MUL			R2,R1,R3
			SUB			R2,R4,R2
			MOV			R4,R1
			ADD			R2,R2,#48 	;we should add this for decimal to ascii conversion
			STR			R2,[R6],#1
			UDIV		R1,R4,R3
			SUBS		R1,R1,#0
			BNE			loop
			
			ADD			R4,R4,#48 	;we should add this for decimal to ascii conversion
			STR			R4,[R6],#1
			STR			R0,[R6]
			SUB			R6,R6,#1
			
			MOV			R8,R6
			MOV			R6,R5
									;When we are finding the digits of numbers, we store them in reverse order, 
									;so we must correct them.
loop2		LDRB		R7,[R8]		;to change place of first and last elements
			LDRB		R0,[R6]
			STRB		R7,[R6]
			STRB		R0,[R8]
			SUB			R8,R8,#1
			ADD			R6,R6,#1
			
			CMP			R8,R6		;It gives the point when interchanging should be stop.
			BHI			loop2		;unsigned greater than /higher than
			
exit		
			
			POP			{R0-R8}
			BX 			LR			;Return the step where we stay in main function
			ENDP