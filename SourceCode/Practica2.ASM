;Práctica 2. Programa que sincroniza dos semáforos.

			.cdecls C,LIST,"msp430g2553.h"
			.global RESET
			.text

RESET       mov.w   #0400h,SP               ;Inicialización del StackPointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ;Detener el WatchDog
;******************************************************************************
;				CONFIGURACIÓN DE PUERTO 1
;******************************************************************************
			bis.b	#00111111b,&P1DIR		;P1.0,P1.1,P1.2,P1.3,P1.4,P1.5
											;como salidas.
;******************************************************************************
;				PROGRAMA PRINCIPAL
;******************************************************************************
			clr		P1OUT					;Limpia puerto 1.
Semaforo	mov		#0x21,&P1OUT			;Estado 1.
			call	#Ret2s					;Llama a subrutina de retardo de 2s.
			mov		#0x22,P1OUT				;Estado 2.
			call	#Ret1s					;Llama a subrutina de retardo de 1s.
			mov		#0x0c,&P1OUT			;Estado 3.
			call	#Ret2s					;Llama a subrutina de retardo de 2s.
			mov		#0x14,&P1OUT			;Estado 4
			call	#Ret1s					;Llama a subrutina de retardo de 1s.
			jmp		Semaforo				;Brinca a etiqueta Semaforo para 
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
			
			.sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            .end


