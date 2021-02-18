;SSI0: 0x4000.8000
;SSI1: 0x4000.9000
;SSI2: 0x4000.A000
;SSI3: 0x4000.B000

;LABEL				DIRECTIVE	VALUE		COMMENT
GPIO_PORTA_DATA		EQU			0x400043FC	;accesible all pins of A to write and read
GPIO_PORTA_DIR		EQU			0x40004400	;input output choose of pins	
GPIO_PORTA_AFSEL	EQU			0x40004420	;specific function selection, now no selection
GPIO_PORTA_DEN		EQU			0x4000451C	;digital enable of pins
;IOA					EQU			0xCB		;0:inputs,1:outputs
SYSCTL_RCGCGPIO		EQU			0x400FE608	;use it open and close ports
GPIO_PORTA_AMSEL	EQU			0x40004528  ;analog enable
GPIO_PORTA_PCTL		EQU			0x4000452C  ;port function control if alternative function selected
GPIO_PORTA_PUR		EQU			0x40004510	;Pull up resistors

;LABEL			DIRECTIVE	VALUE		COMMENT
RCGCSSI			EQU			0x400FE61C	;SSI Run Mode Clock Gating Control	;OPEN CLOCK	
SSI0_CR0		EQU			0x40008000	;SSI Control 0
SSI0_CR1		EQU			0x40008004	;SSI Control 1 ;Enable SSI
SSI0_DR			EQU			0x40008008	;SSI Data Register
SSI0_SR			EQU			0x4000800C	;SSI Status Register
SSI0_CPSR		EQU			0x40008010	;SSI Clock Prescale
SSI0_IM			EQU			0x40008014	;SSI Interrupt Mask
SSI0_RIS		EQU			0x40008018	;SSI Raw Interrup Status
SSI0_MIS		EQU			0x4000801C	;SSI Masked Interrupt Status
SSI0_ICR		EQU			0x40008020	;SSI Interrupt Clear
SSI0_CC			EQU			0x40008FC8	;SSI Clock Configuration


;A0_pin				EQU			0x40004004	;					;A0 pin
;A1_pin				EQU			0x40004008	;					;A1 pin
CLK_A2_pin			EQU			0x40004010 	;SSICLK				;A2 pin
CE_Fss_A3_pin		EQU			0x40004020 	;Fss/CE/Chip Enable	;A3 pin
;A4_pin				EQU			0x40004040 	;					;A4 pin
TX_A5_pin			EQU			0x40004080 	;SsiTx /DIN			;A5 pin
DC_A6_pin			EQU			0x40004100	;Data/Command		;A6	pin
RST_A7_pin			EQU			0x40004200	;RST				;A7 pin

;LABEL			DIRECTIVE		VALUE		COMMENT
				AREA		subroutines,CODE,READONLY
				THUMB
				
				EXPORT		SPI_Configuration
				EXTERN 		DELAY100
;2Mhz
;SSInClk = SysClk / (CPSDVSR * (1 + SCR))
;2x10^6 = 16x10^6 / (CPSDVSR * (1 + SCR))
;;2x10^6 = 16x10^6 / (2* (3 + 1))
;LCD max:4Mbit/s
					
SPI_Configuration	PROC	
				PUSH		{LR}
				
				
				LDR			R1,=RCGCSSI
				LDR			R0,[R1]
				ORR			R0,R0,#0x01			;Open SSI0 clock
				STR			R0,[R1]
				NOP
				NOP
				NOP								;For Clock Run Waiting Time
			
				

				LDR			R1,=SYSCTL_RCGCGPIO
				LDR			R0,[R1]
				ORR			R0,R0,#0x01			;Open A port
				STR			R0,[R1]
				NOP
				NOP
				NOP								;For Clock Run Waiting Time
				
				
				LDR			R1,=GPIO_PORTA_DEN
				LDR			R0,[R1]
				ORR			R0,#0xFF
				STR			R0,[R1]
				
				LDR			R1,=GPIO_PORTA_DIR
				LDR			R0,[R1]
				ORR			R0,#0xD0					;4.6.7. pins out
				STR			R0,[R1]
				
				LDR			R1,=GPIO_PORTA_AFSEL
				LDR			R0,[R1]
				BIC			R0,#0xFF
				ORR			R0,#0x2C				;Use 2.3.5. bit for SSI
				STR			R0,[R1]
				
				LDR			R1,=GPIO_PORTA_PCTL
				LDR			R0,[R1]
				LDR			R2,=0x00202200
				ORR			R0,R0,R2				;Use 2.3.5. bit for SSI
				STR			R0,[R1]
				
				
				LDR			R1,=SSI0_CR1
				LDR			R0,[R1]
				BIC			R0,#0x02			;Disable SSI
				STR			R0,[R1]
				
				LDR			R1,=SSI0_CC			;Choose clock source as 2MHz
				LDR			R0,[R1]
				ORR			R0,#0x5				;0x5:Use PIOSC as 16MHz for clock source
				STR			R0,[R1]

;Make bit rate 4Mbps					
				LDR			R1,=SSI0_CPSR
				MOV			R0,#2				;CPSDVR=2;	;min can be 2 and even			
				STR			R0,[R1]
												
				LDR			R1,=SSI0_CR0
				MOV			R0,#0x0307			;SCR=1,SPH=0,SPO=0,Freescale Format,8 bit data				
				STR			R0,[R1]				
				
				LDR			R1,=SSI0_CR1
				LDR			R0,[R1]
				ORR			R0,#0x02			;Enable SSI
				STR			R0,[R1]
				
				
				
;Initialize Screen				
				LDR			R1,=RST_A7_pin
				MOV			R0,#0x00		;Make RST enable
				STR			R0,[R1]
				BL			DELAY100		;Wait 100ms
				LDR			R1,=RST_A7_pin
				MOV			R0,#0x80		;Make RST disable
				STR			R0,[R1]

				LDR			R1,=CE_Fss_A3_pin
				LDR			R0,[R1]
				BIC			R0,#0xFF		;Make Chip enable
				STR			R0,[R1]
				
				
;Choose Command Part
Command_LCD
				LDR			R1,=DC_A6_pin	;Choose Data/Command
				LDR			R0,[R1]
				BIC			R0,#0x40		;Choose Command with A6 pin
				STR			R0,[R1]
				
wait_until_not_busy
				LDR			R1,=SSI0_SR		;Status Register
				LDR			R0,[R1]
				AND			R0,#0x10		;BSY flag is obtained.
				CMP			R0,#0x10		
				BEQ			wait_until_not_busy
				
assign_command	
				LDR			R1,=SSI0_DR		;Write Command
				MOV			R0,#0x21		;Chip active,horizontal addressing mode (V = 0); use extended instruction set (H = 1)
				STR			R0,[R1]	

wait_until_not_busy2
				LDR			R1,=SSI0_SR		;Status Register
				LDR			R0,[R1]
				AND			R0,#0x10		;BSY flag is obtained.
				CMP			R0,#0x10		
				BEQ			wait_until_not_busy2

assign_command2	
				LDR			R1,=SSI0_DR		;Write Command
				MOV			R0,#0xB1		;LCD Vopset contrast configuration
				STR			R0,[R1]	

wait_until_not_busy3
				LDR			R1,=SSI0_SR		;Status Register
				LDR			R0,[R1]
				AND			R0,#0x10		;BSY flag is obtained.
				CMP			R0,#0x10		
				BEQ			wait_until_not_busy3
				
assign_command3	
				LDR			R1,=SSI0_DR		;Write Command
				MOV			R0,#0x04		;temperature control value setting
				STR			R0,[R1]	

wait_until_not_busy4
				LDR			R1,=SSI0_SR		;Status Register
				LDR			R0,[R1]
				AND			R0,#0x10		;BSY flag is obtained.
				CMP			R0,#0x10		
				BEQ			wait_until_not_busy4
				
assign_command4	
				LDR			R1,=SSI0_DR		;Write Command
				MOV			R0,#0x13		;LCD Bias Mode setting
				STR			R0,[R1]	
				
wait_until_not_busy5
				LDR			R1,=SSI0_SR		;Status Register
				LDR			R0,[R1]
				AND			R0,#0x10		;BSY flag is obtained.
				CMP			R0,#0x10		
				BEQ			wait_until_not_busy5
				
assign_command5	
				LDR			R1,=SSI0_DR		;Write Command
				MOV			R0,#0x20		;take it to Basic Command Mode/Basic Display Control Mode
				STR			R0,[R1]			;we must send 0x20 before modifying display control mode


wait_until_not_busy6
				LDR			R1,=SSI0_SR		;Status Register
				LDR			R0,[R1]
				AND			R0,#0x10		;BSY flag is obtained.
				CMP			R0,#0x10		
				BEQ			wait_until_not_busy6
				
assign_command6	
				LDR			R1,=SSI0_DR		;Write Command
				MOV			R0,#0x0C		;set display control to normal mode	
				STR			R0,[R1]			

wait_until_not_busy7
				LDR			R1,=SSI0_SR		;Status Register
				LDR			R0,[R1]
				AND			R0,#0x10		;BSY flag is obtained.
				CMP			R0,#0x10		
				BEQ			wait_until_not_busy7


assign_command7	
				LDR			R1,=SSI0_DR		;Write Command
				MOV			R0,#0x80		;Set cursor X: 0	
				STR			R0,[R1]			

wait_until_not_busy8
				LDR			R1,=SSI0_SR		;Status Register
				LDR			R0,[R1]
				AND			R0,#0x10		;BSY flag is obtained.
				CMP			R0,#0x10		
				BEQ			wait_until_not_busy8

assign_command8	
				LDR			R1,=SSI0_DR		;Write Command
				MOV			R0,#0x40		;Set cursor Y: 0
				STR			R0,[R1]			

wait_until_not_busy9
				LDR			R1,=SSI0_SR		;Status Register
				LDR			R0,[R1]
				AND			R0,#0x10		;BSY flag is obtained.
				CMP			R0,#0x10		
				BEQ			wait_until_not_busy9

				POP			{LR}		
				BX			LR
				
				ENDP
				END