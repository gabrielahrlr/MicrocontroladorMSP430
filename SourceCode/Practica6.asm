;Práctica 6. Laboratorio de Microprocesadores y Microcontroladores
;En esta práctica se trabaja con el Timer_A como temporizador, haciendo un
;Contador de 0-99, cada que pase un segundo el contador se incrementa.
 			.cdecls C,LIST,  "msp430g2553.h"
 			.global RESET
;------------------------------------------------------------------------------
            .text                           ;Inicio de Programa
;------------------------------------------------------------------------------
RESET       mov.w   #400h,SP             	  ;Inicialización del StackPointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ;Detiene Perro Guardian.
			mov.b   &CALBC1_1MHZ,&BCSCTL1   ; Calibracion del
			mov.b   &CALDCO_1MHZ,&DCOCTL    ; oscilador a 1MHz
;--------------------------------------------------------------------------------
;			Configuración de puertos
;--------------------------------------------------------------------------------
SetupP1P2   bis.b   #0xFF,&P1DIR            ; Puerto 1 como Salida.
			bis.b	#0xFF,&P2DIR			;Puerto 2 como salida.
			clr		&P1OUT
			clr		&P2OUT
;--------------------------------------------------------------------------------
;			Configuración del TimerA_0
;El timer A canal 0 se configura con un reloj de 1MHz (SMCLK) y éste se divide
;en 8  (125kHz). El valor en TA0CCR0 es de 62500 lo que da un valor de
;0.5 segundos (62500*(1/125kHz))=0.5.
;Se configra con Modo Up/Down, cuenta hasta el valor en TA0CCR0 (62500)
;y despues del valor de TA0CCR0	hasta cero (62500) con una cuenta total de 125000
;lo cual es un segundo, cada que la cuenta se reinicie se genera una interrupción,
;es decir se genera una interrupción cada 1 segundo.
;*********************************************************************************
SetupC0     mov.w   #CCIE,&TA0CCTL0            	; Se habilita interrupción de
												; TA0CCR0.
            mov.w   #62500,&TA0CCR0            	;Número de cuentas para 5 segundos

SetupTA     mov.w   #TASSEL_2+ID_3+MC_3,&TA0CTL	;SMCLK reloj(1MHZ),división del
											   	;reloj en 8 (1MHz/8=125kHz),
											   	;Modo Up/Down, Cuenta hasta
											   	;62500(Valor de TA0CCR0) y luego
											   	;de regreso desde 62500 hasta 0.
											   	;para tener una base de tiempo
											   	;de 1 segundo.
;**********************************************************************************
;						Programa principal
;*********************************************************************************
Mainloop    bis.w   #CPUOFF+GIE,SR          ; CPU off, modo de bajo consumo de
											;potencia. Habilita interrupciones
											;globales
            nop                             ;No operación.

;-------------------------------------------------------------------------------

TA0_ISR;    Rutina de servicio de interrupción. Contador 0-99

;-------------------------------------------------------------------------------
Unidades	inc	&P1OUT					;Se incrementa el Puerto 1.
			mov	&P1OUT,R6				;Se transfiere contenido de P1OUT a R6
			and.b #0x00FF,R6			;Se enmascara sólo 8 bits de R6.
			cmp	#0x0A,R6				;Se compara R6 con 0x0A (10 decimal)
			jz	Decenas					;Si es 0x0A brinca a etiqueta decenas.
			jmp	Fin						;Si no es brinca a etiqueta Fin.
Decenas		clr	&P1OUT					;Se limpia unidades (limpia puerto 1).
			inc	&P2OUT					;Incrementa decenas. (incrementa puerto2).
			mov	&P2OUT,R7				;Se transfiere contenido de P2OUT a R7.
			and.b #0x00FF,R7			;Se enmascara los 8 bits de R7.
			cmp	#0x0A,R7				;Se compara con 0x0A (10 decimal).
			jz	Reset					;Si es 0x0A brinca a etiqueta reset.
			jmp	Fin						;Sino es 0x0A brina a etiqueta Fin.
Reset		clr	&P2OUT					;Limpia decenas (limpia puerto 2).
Fin         reti                        ;Retorno de interrupción.

;------------------------------------------------------------------------------
;          Vectores de interrupción.
;------------------------------------------------------------------------------

            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET                   ;

            .sect   ".int09"                ; Timer_A0 Vector
            .short  TA0_ISR                 ;

            .end							;Fin.
