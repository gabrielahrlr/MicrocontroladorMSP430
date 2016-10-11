;*******************************************************************************
;Práctica 5. Laboratorio de Microprocesadores y Microcontroladores.
; En esta práctica se hace uso del Convertidor Analógico-Digital
;Cuando el voltaje de entrada es menor 0.25Vcc se enciende el LED externo AZUL
;si la entrada es menor a 0.5Vcc pero mayor a 0.25Vcc se enciende el LED externo
;VERDE, si la entrada es menor a 0.75Vcc pero mayor a 0.5Vcc se enciende el LED
;externo NARANJA, finalmente si la entrada es menor a 1Vcc pero mayor a 0.75Vcc
;el LED externo  color ROJO se encenderá.
;*******************************************************************************
 			.cdecls C,LIST,  "msp430g2553.h"
 			.global RESET
;------------------------------------------------------------------------------
            .text                           ;Inicio de Programa
;------------------------------------------------------------------------------
RESET       mov.w   #400h,SP               ;Inicialización del StackPointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ;Detiene Perro Guardian.
;--------------------------------------------------------------------------------
;			Configuración del ADC10
;Se configura con el tiempo de muestreo  16xADC10CLKs, se habilita el convertidor
;se habilita la interrupción del convertidor y se elige al Canal 1 (P1.1) para
;entrada analógica.
;--------------------------------------------------------------------------------
SetupADC10  mov.w   #ADC10SHT_2+ADC10ON+ADC10IE,&ADC10CTL0 ;16x tiempo de muesreo
														   ;Habilita ADC10
														   ;Habilita interrupción
            mov.w   #INCH_1, &ADC10CTL1		;Selecciona P1.1 como entrada analógica
SetupP1     bis.b   #00111100b,&P1DIR       ;Configura P1.1 como entrada y P1.2,
											;P1.3, P1.4 y P1.5 como salidas.
;----------------------------------------------------------------------------------
;			Programa Principal
;---------------------------------------------------------------------------------
Mainloop    bis.w   #ENC+ADC10SC,&ADC10CTL0 ; Comienzo del muestreo y conversión.
            bis.w   #CPUOFF+GIE,SR          ;Se configura el modo de bajo consumo
            								;Se habilitan interrupciones globales.

            bic.b   #00111100b,&P1OUT       ;Se limplian los bits 2,3,4 y 5 de puerto1.
           	cmp.w	#00FFh,&ADC10MEM		;Pregunta si ADC10MEM = A1 > 0.25AVcc
           	jlo		LED1					;Si A1 NO es mayor a 0.25Vcc brinca a
            								;etiqueta LED1.
           	cmp.w   #01FFh,&ADC10MEM        ; Pregunta si ADC10MEM = A1 > 0.5AVcc.
            jlo     LED2					;Si A1 NO es mayor a 0.5Vcc brinca a
            								;etiqueta LED2.
            cmp.w	#02FFh,&ADC10MEM		;Pregunta si ADC10MEM = A1 > 0.75AVcc
            jlo		LED3					;Si A1 NO es mayor a 0.75Vcc brinca a
            								;etiqueta LED3.
            cmp.w	#03FFh,&ADC10MEM		;Pregunta si ADC10MEM = A1 =1Vcc
            jlo		LED4					;Si A1 NO es mayor a 1Vcc brinca a
            								;etiqueta LED4.
            jmp		Fin
LED1		bis.b	#00000100b,&P1OUT		;Enciende LED1 conectado externamente a
											;P1.2.
            jmp		Fin						;Brinca a etiqueta Fin para volver a
            								;comenzar el ciclo.
LED2		bis.b   #00001000b,&P1OUT		;Enciende LED2 conectado externamente a
											;P1.3.
            jmp     Fin               		;Brinca a etiqueta Fin para volver a
            								;comenzar el ciclo.
LED3		bis.b	#00010000b,&P1OUT		;Enciende LED3 conectado externamente a
											;P1.4.
			jmp		Fin						;Brinca a etiqueta Fin para volver a
            								;comenzar el ciclo.
LED4		bis.b	#00100000b,&P1OUT      	;Enciende LED4 conectado externamente a
											;P1.5.                               ;
Fin			jmp		Mainloop				;Brinca nuevamente al ciclo principal.
;-------------------------------------------------------------------------------

ADC10_ISR;  Rutina de servicio de interrupción.
;-------------------------------------------------------------------------------
            bic.w   #CPUOFF,0(SP)           ;Salida del modo de bajo consumo
            reti                            ;Retorno de interrupción
                                            ;
;------------------------------------------------------------------------------
;           Interrupt Vectors
;------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET                   ;

            .sect   ".int05"                ; ADC10 Vector
            .short  ADC10_ISR               ;
            .end

