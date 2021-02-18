;NUM				EQU			0x61A80		;for 100msec	
NUM				EQU				0x30D40		;for 10 msec
;NUM				EQU				0x186A0		;for 1 msec	
;NUM					EQU			0x1312D00		;for 5sec

;LABEL			DIRECTIVE			VALUE		COMMENTS
				AREA		subroutines,CODE,READONLY
				THUMB
					
				EXPORT		DELAY10
				EXTERN		__main
				

DELAY10			PROC
				
				LDR			R1,=NUM
													;1 cycle time :1/16*10^-6
loop			SUBS		R1,#1		;1 cycle		 
				NOP						;1 cycle
				BNE			loop		;2 cycle
				
				BX			LR
				
				
				ENDP
				END