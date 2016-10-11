;	  Laboratorio de microprocesadores y microcontroladores
;			PRÁCTICA 4. Interrupciones del Puerto
;Se simulan dos "semáforos" de LEDs que funcionan normalmente, además se tienen
;dos push buttons, uno para el semáforo principal y otro para el semáforo 2.
;Cuando el push button 1 se oprime el semáforo 1 se pone en verde y el semáforo 2
; en rojo. Mientras que cuando se oprime el push-button 2 se pone en verde el
;semáforo 2 y el semáforo 1 en rojo. Si se oprimen los dos botones simultáneamente
;primero se efectúan las acciones para el semáforo 1 y después las del semáforo 2.

			.cdecls C,LIST,"msp430g2553.h"
			.global RESET
			.text

RESET       mov.w   #0400h,SP               ;Inicialización del StackPointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ;Detener el WatchDog
;******************************************************************************
;				CONFIGURACIÓN DE PUERTO 1
;******************************************************************************
			mov.b	#00111111b,&P1DIR		;P1.0,P1.1,P1.2,P1.3,P1.4,P1.5 como
											;salidas, P1.6 y P1.7 como entradas.
			mov.b	#11000000b,&P1OUT		;Configuración para resistencias
											;internas de pull-up, limpia salidas.
			bis.b	#11000000b,&P1REN		;Configuración de resitencia pull-up
											;interna de P1.6 y P1.7
			bis.b	#BIT7+BIT6,&P1IES		;Interrupciones en P1.6 y P1.7
											;por flanco de bajada.
			bic.b	#BIT7+BIT6,&P1IFG		;Limpia banderas de interrupción del
											;puerto 1.
			bis.b	#BIT7+BIT6,&P1IE		;Habilita las Interrupciones de
											;puerto en P1.6 y P1.7
			mov		#GIE,SR					;Se habilitan interrupciónes globales.
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
;			Rutina de servicio de Interrupción (ISR)
;****************************************************************************************
ISR_P1		and.w	#0x00FF,&P1IFG		;Se enmascara sólo a 8 bits.
			bit.b	#BIT6,&P1IFG		;¿Interrupción por push-button 1? Prioridad de
										;switch 1.
			jnz		switch_1			;Si lo es brinca a etiqueta switch_1.
			bit.b	#BIT7,&P1IFG		;¿Interrupción por push-button 2?
			jnz		switch_2			;Si lo es brinca a etiqueta switch_2.
			bic.b	#BIT7+BIT6,&P1IFG	;Limpia banderas de interrupción
			jmp		Fin					;Sino suceden ninguna de las condiciones anteriores
										;Sale de la ISR.
switch_1	bic.b 	#BIT6,&P1IFG		;Limpia Bandera de interrupción de P1.6
			mov		#0xCC,&P1OUT		;Se pone en verde semáforo 1 y en rojo semáforo 2.
Ret3s		mov		#0x12,R10			;Retardo de 1
Ret250ms2	mov		#0xf41F,R7			;Data=0xf41F para un tiempo de retardo de 250ms											;250mili-segundos.
Loop12		dec		R7					;Se decrementa el registro R7
			jnz		Loop12
			dec		R10
			jnz		Ret250ms2			;Permanece en el ciclo hasta que R10 sea cero.
			jmp		Fin
switch_2	bic.b 	#BIT7,&P1IFG		;Limpia bandera de interrupción de P1.7.
			mov		#0xE1,&P1OUT		;Se pone e verde semáforo 1 y en rojo semáforo 2.
			jmp		Ret3s				;Retardo de  3 segundos.
Fin			reti						;Retorno de interrupción.
;*****************************************************************************
;						Vectores de interrupción
;*****************************************************************************
			.sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET

 			.sect	".int02"				;Vector de Interrupción Puerto 1
			.short	ISR_P1					;ISR_P1 nombre de la rutina de
											;servicio de interrupción (ISR).
			.end

