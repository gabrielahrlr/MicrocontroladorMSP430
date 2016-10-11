;Práctica 1
;Programa que lee el push-button conectado a p1.3 del puerto 1, y enciende un LED externo por
;un determinado tiempo y después lo apaga.

			.cdecls C,LIST,"msp430g2553.h"
			.global RESET
			.text

RESET       mov.w   #0400h,SP               ;Inicialización del StackPointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ;Detener el WatchDog
;******************************************************************************
;				CONFIGURACIÓN DE PUERTO 1
;******************************************************************************
			bis.b	#00010000b,&P1DIR		; P1.3 entrada (push buttor), P1.4 salida.
;******************************************************************************
;				PROGRAMA PRINCIPAL
;******************************************************************************
Mainloop 	bit.b	#00001000b,&P1IN 		;Lee switch en P1.3
			clr		P1OUT
			jnc	 	OnLED					;Si está oprimido brinca a etiqueta OnLED.
			jmp		Mainloop
OnLED		bis.b	#00010000b,&P1OUT		;Enciende LED externo
			mov		#0x04,R6
			call 	#Ret1s					;Llamado a subrutina Retardo
			bic.b	#00010000b,&P1OUT		;Apaga LED externo
			jmp		Mainloop				;Brinca a etiqueta Mainloop para volver
											;a preguntar por pushbutton.
;******************************************************************************
;				SUBRUTINA DE RETARDO
;En esta subrutina se genera un tiempo "muerto" deseado
;******************************************************************************
Ret250ms	mov		#0xf41F,R7				;Data=0xf41F para un tiempo de retardo de
											;250mili-segundos.
Loop1		dec		R7						;Se decrementa el registro R7
			jnz		Loop1					;Permanece en el ciclo hasta que R7 sea cero.
			ret								;Retorno de subrutina.

Ret1s		mov		#0x0404,R6				;R6<-0x04
Loop2		call	#Ret250ms				;Llamado a subrutina de retardo de 250ms.
			dec		R6						;Se decrementa R6.
			jnz		Loop2					;Si R6 no es cero permanece en la subrutina.
			ret

			.sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            .end


