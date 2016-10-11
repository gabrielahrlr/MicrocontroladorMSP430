//Práctica 7 Parte II. Generar una señal PWM con una frecuencia de 1KHz
// y un ciclo de trabajo de 25%, posteriormente cambiar el ciclo de
// trabajo por uno de 50% y finalmente por uno de 75%.
#include "msp430g2553.h"
void main (void)
{
    WDTCTL = WDTPW + WDTHOLD; //Detiene el Perro Guardián.
    BCSCTL1 = CALBC1_1MHZ;	  // Calibra el reloj a 1MHz
    DCOCTL = CALDCO_1MHZ;	  // Calibra reloj a 1Mhz
    P1DIR  |=BIT2;			  // P1.2 se configura como salida.
    P1SEL|= BIT2;			  // P1.2 salida de Timer0_A1
    TA0CCR0=1000-1;			  // frecuencia de 1KHz (periodo de 1ms)
    TA0CCTL1=OUTMOD_7;		  // Modo de Salida Reset/Set
    TA0CCR1=250;			  // Ciclo de Trabajo 25%, cambiarlo al 50%
    						  // y al 75%.
    TA0CTL=TASSEL_2+ID_0+MC_1+TACLR; //Reloj de Timer=SMCLK (1MHz),
    								 // Modo Ascendente.
}



