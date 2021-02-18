;NUM				EQU			0x61A80		;for 10msec	
;NUM					EQU			0x190		;for 10 usec
;NUM					EQU			0x1312D00		;for 5sec
NUM					EQU			0x3D0900			;for 1 sec


;LABEL			DIRECTIVE			VALUE		COMMENTS
				AREA		subroutines,CODE,READONLY
				THUMB
					
				EXPORT		DELAY1
				EXTERN		__main
				

DELAY1			PROC
				
				LDR			R1,=NUM

loop			SUBS		R1,#1		;1 cycle
				NOP						;1 cycle
				BNE			loop		;2 cycle
				
				BX			LR
				
				
				ENDP
				END