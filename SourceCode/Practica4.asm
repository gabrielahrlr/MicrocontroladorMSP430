;	  Laboratorio de microprocesadores y microcontroladores
;			PR�CTICA 4. Interrupciones del Puerto
;Se simulan dos "sem�foros" de LEDs que funcionan normalmente, adem�s se tienen
;dos push buttons, uno para el sem�foro principal y otro para el sem�foro 2.
;Cuando el push button 1 se oprime el sem�foro 1 se pone en verde y el sem�foro 2
; en rojo. Mientras que cuando se oprime el push-button 2 se pone en verde el
;sem�foro 2 y el sem�foro 1 en rojo. Si se oprimen los dos botones simult�neamente
;primero se efect�an las acciones para el sem�foro 1 y despu�s las del sem�foro 2.

			.cdecls C,LIST,"msp430g2553.h"
			.global RESET
			.text

RESET       mov.w   #0400h,SP               ;Inicializaci�n del StackPointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ;Detener el WatchDog
;******************************************************************************
;				CONFIGURACI�N DE PUERTO 1
;******************************************************************************
			mov.b	#00111111b,&P1DIR		;P1.0,P1.1,P1.2,P1.3,P1.4,P1.5 como
											;salidas, P1.6 y P1.7 como entradas.
			mov.b	#11000000b,&P1OUT		;Configuraci�n para resistencias
											;internas de pull-up, limpia salidas.
			bis.b	#11000000b,&P1REN		;Configuraci�n de resitencia pull-up
											;interna de P1.6 y P1.7
			bis.b	#BIT7+BIT6,&P1IES		;Interrupciones en P1.6 y P1.7
											;por flanco de bajada.
			bic.b	#BIT7+BIT6,&P1IFG		;Limpia banderas de interrupci�n del
											;puerto 1.
			bis.b	#BIT7+BIT6,&P1IE		;Habilita las Interrupciones de
											;puerto en P1.6 y P1.7
			mov		#GIE,SR					;Se habilitan interrupci�nes globales.
;******************************************************************************
;				PROGRAMA PRINCIPAL
;******************************************************************************

Estado1		mov		#0xE1,&P1OUT			;Estado 1.
			call	#Ret2s					;Llama a subrutina de retardo de 2s.
Estado2		mov		#0xE2,P1OUT				;Estado 2.
			call	#Ret1s					;Llama a subrutina de retardo de 1s.
Estado3		mov		#0xCC,&P1OUT			;Estado 3.
			call	#Ret2s					;Llama a subrutina de retardo de 2s.
Estado4		mov		#0xD4,&P1OUT			;Estado 4
			call	#Ret1s					;Llama a subrutina de retardo de 1s.
			jmp		Estado1					;Brinca a etiqueta Semaforo para
											;regresar al Estado 1.

;******************************************************************************
;				SUBRUTINAS DE RETARDO
;******************************************************************************

;Retardo de 250 mili-segundos.
Ret250ms	mov		#0xf41F,R7				;Data=0xf41F para un tiempo de retardo de
											;250mili-segundos.
Loop1		dec		R7						;Se decrementa el registro R7
			jnz		Loop1					;Permanece en el ciclo hasta que R7 sea cero.
			ret								;Retorno de subrutina.

;Retardo de 1 segundo.
Ret1s		mov		#0x04,R6				;R6<-0x04
Loop2		call	#Ret250ms				;Llamado a subrutina de retardo de 250ms.
			dec		R6						;Se decrementa R6.
			jnz		Loop2					;Si R6 no es cero permanece en la subrutina.
			ret

;Retardo de 2 segundos.
Ret2s		mov		#0x02,R5				;R6<-0x04
Loop3		call	#Ret1s					;Llamado a subrutina de retardo de 250ms.
			dec		R5						;Se decrementa R6.
			jnz		Loop3					;Si R6 no es cero permanece en la subrutina.
			ret
;****************************************************************************************
;			Rutina de servicio de Interrupci�n (ISR)
;****************************************************************************************
ISR_P1		and.w	#0x00FF,&P1IFG		;Se enmascara s�lo a 8 bits.
			bit.b	#BIT6,&P1IFG		;�Interrupci�n por push-button 1? Prioridad de
										;switch 1.
			jnz		switch_1			;Si lo es brinca a etiqueta switch_1.
			bit.b	#BIT7,&P1IFG		;�Interrupci�n por push-button 2?
			jnz		switch_2			;Si lo es brinca a etiqueta switch_2.
			bic.b	#BIT7+BIT6,&P1IFG	;Limpia banderas de interrupci�n
			jmp		Fin					;Sino suceden ninguna de las condiciones anteriores
										;Sale de la ISR.
switch_1	bic.b 	#BIT6,&P1IFG		;Limpia Bandera de interrupci�n de P1.6
			mov		#0xCC,&P1OUT		;Se pone en verde sem�foro 1 y en rojo sem�foro 2.
Ret3s		mov		#0x12,R10			;Retardo de 1
Ret250ms2	mov		#0xf41F,R7			;Data=0xf41F para un tiempo de retardo de 250ms											;250mili-segundos.
Loop12		dec		R7					;Se decrementa el registro R7
			jnz		Loop12
			dec		R10
			jnz		Ret250ms2			;Permanece en el ciclo hasta que R10 sea cero.
			jmp		Fin
switch_2	bic.b 	#BIT7,&P1IFG		;Limpia bandera de interrupci�n de P1.7.
			mov		#0xE1,&P1OUT		;Se pone e verde sem�foro 1 y en rojo sem�foro 2.
			jmp		Ret3s				;Retardo de  3 segundos.
Fin			reti						;Retorno de interrupci�n.
;*****************************************************************************
;						Vectores de interrupci�n
;*****************************************************************************
			.sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET

 			.sect	".int02"				;Vector de Interrupci�n Puerto 1
			.short	ISR_P1					;ISR_P1 nombre de la rutina de
											;servicio de interrupci�n (ISR).
			.end

