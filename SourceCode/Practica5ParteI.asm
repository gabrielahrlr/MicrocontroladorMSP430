;*******************************************************************************
;Práctica 5. Laboratorio de Microprocesadores y Microcontroladores.
; En esta práctica se hace uso del Convertidor Analógico-Digital
;Cuando el voltaje de entrada es mayor 0.5Vcc se enciende el LED rojo
;del MSP530 conectado al puerto P1.0 y se apaga el LED verde conectado
;al puerto P1.6, mientras que cuando el voltaje de entrada es menor a
;0.5Vcc el LED verde de P1.6 se enciende y el LED rojo de P1.0 se apaga.
;Se habilita la interrupción del convertidor para utilizar la característica de
;bajo consumo de potencia. Cuando entra la interrupción (es decir, cuando se
;termina de efectuar la conversión) el modo de bajo consumo se desactiva en la
;Rutina de servicio de Interrupción del ADC10.
;*******************************************************************************
 			.cdecls C,LIST,  "msp430g2553.h"
 			.global RESET
;--------------------------------------------------------------------------------
            .text                           ;Inicio de Programa
;--------------------------------------------------------------------------------
RESET       mov.w   #400h,SP               ;Inicialización del StackPointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL ;Detiene Perro Guardian.
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

SetupP1     bis.b   #01000001b,&P1DIR       ;Configura P1.1 como entrada y
											;P1.0 y P1.6 como salida.
;----------------------------------------------------------------------------------
;			Programa Principal
;---------------------------------------------------------------------------------
Mainloop    bis.w   #ENC+ADC10SC,&ADC10CTL0 ; Comienzo del muestreo y conversión.
            bis.w   #CPUOFF+GIE,SR          ;Se configura el modo de bajo consumo
            								;Se habilitan interrupciones.
            bic.b   #BIT0+BIT6,&P1OUT       ;Se limpia la salida de P1.0 y P1.6.
            cmp.w   #01FFh,&ADC10MEM        ; Pregunta si ADC10MEM = A1 > 0.5AVcc
            jlo     Verde					;Si A1 NO es mayor a 0.5Vcc brinca a
            								;etiqueta Verde. Si A1 es mayor a
            								;0.5Vcc efectúa lo correpondiente para
            								;encender LED rojo.
Rojo		bis.b	#000000001b,&P1OUT		;Enciende LED rojo del microcontrolador
											;conectado a P1.0.
			bic.b	#010000000b,&P1OUT		;Apaga LED verde del microcontrolador
											;Conectado a P1.6.
            jmp		Fin						;Brinca a etiqueta fin para volver a
            								;comenzar el ciclo.
Verde		bis.b   #01000000b,&P1OUT		;Enciende LED verde del microcontrolador
											;conectado a P1.6.
			bic.b	#00000001b,&P1OUT		;Apaga LED rojo del microcontrolador
											;Conectado a P1.0.
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



