
#include <msp430g2553.h>

void main(void)

{
  WDTCTL = WDTPW + WDTHOLD;                 // Detiene Perro Guardian.
  BCSCTL1= CALBC1_1MHZ;						// Calibración del reloj a 1MHz.
  DCOCTL= CALDCO_1MHZ;						// Calibración del reloj a 1MHz.
  P1DIR |= 0xFF;                            // Puerto 1 como salida (Unidades).
  P2DIR |= 0xFF;                            // Puerto 2 como salida (Decenas).
  P1OUT=0x00;
  P2OUT=0x00;
  TA0CCTL0 = CCIE;                          // Habilita interrupción en TA0CCR0
  TACCR0 = 62500;							// Número de cuentas para 0.5 segundos.
  TA0CTL = TASSEL_2 +ID_3+ MC_3;            // SMCLK (1MHz), divide reloj /8=1MHz/8=125Khz
  	  	  	  	  	  	  	  	  	  	  	// Modo Up/Down
  _BIS_SR(LPM0_bits + GIE);                 // Habilita modo LPM0 e interrupciones globales

}


// Timer A0 Rutina de Servicio de Interrupción (ISR)
#pragma vector=TIMER0_A0_VECTOR

__interrupt void Timer_A (void)

{

  P1OUT += 0x01;                            // Toggle P1.0
  if(P1OUT==10){
	P1OUT=0;
	P2OUT+=0x01;
	if(P2OUT==10){
	P2OUT=0;
	}
  }
}
