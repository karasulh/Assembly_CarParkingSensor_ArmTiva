NUM				EQU			0x61A80		;for 100msec	
;NUM					EQU			0x1312D00		;for 5sec

;LABEL			DIRECTIVE			VALUE		COMMENTS
				AREA		subroutines,CODE,READONLY
				THUMB
					
				EXPORT		DELAY100
				EXTERN		__main
				

DELAY100		PROC
				
				LDR			R1,=NUM
													;1 cycle time :1/16*10^-6
loop			SUBS		R1,#1		;1 cycle		 
				NOP						;1 cycle
				BNE			loop		;2 cycle
				
				BX			LR
				
				
				ENDP
				END