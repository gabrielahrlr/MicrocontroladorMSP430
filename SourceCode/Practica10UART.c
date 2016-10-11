//Pr�ctica 10: M�dulo USCI en modo UART
// C�digo para MSP430G2553 para efectuar comunicaci�n serial as�ncrona
// con el m�dulo USCI en modo UART a unda tasa de baudaje (Baud Rate) de
// 128000 bauds.

#include <msp430G2553.h>
int main(void)
{
  WDTCTL = WDTPW + WDTHOLD;				// Detiene Perro Guardi�n.
  BCSCTL1= CALBC1_1MHZ;					// Calibraci�n del SMCLK a 1MHz
  DCOCTL= CALDCO_1MHZ;
  UCA0CTL1 |=UCSWRST;					// UCSWRST=1  para Inicializaci�n
  	  	  	  	  	  	  	  	  	  	// del m�dulo USCI.
  P1OUT = 0x00;                      	// Limpia salidas del puerto 1
  	  	  	  	  	  	  	  	  	    // (P1.0 y P1.6)
  P1DIR |= BIT0 + BIT6;					// BIT0 y BIT 1 de puerto 1 como salidas.
  P1SEL = BIT1 + BIT2;					// Selecci�n de funci�n USCI_A0 en modo
  	  	  	  	  	  	  	  	  	    // UART: UCA0TXD y UCA0RXD.
  P1SEL2 = BIT1 + BIT2;					// Selecci�n de funci�n USCI_A0 en modo
  	  	  	  	  	  	  	  	  	  	// UART: UCA0TXD y UCA0RXD.
  P2DIR=0x00;							// Puerto 2 como entrada.
  P2REN |= BIT0 + BIT1;					// Configuraci�n de resistencias
  P2OUT |= BIT0 + BIT1;					// internas de pull-up en P2.0 y P2.1
  UCA0CTL1 |= UCSSEL_2;                 // BCLK = SMCLK (1MHz).
  UCA0BR0 = 0x07;                       // 1MHz/128000 = 7.81 (redondeado 7).
  	  	  	  	  	  	  	  	  	  	// Baud Rate=128000bauds.
  UCA0BR1 = 0x00;
  UCA0MCTL = UCBRS2+ UCBRS1 + UCBRS0;   // Modulaci�n tipo UCBRSx = 7 (111b).
  	  	  	  	  	  	  	  	  	  	// Baus Rate=128000 bauds.
  UCA0CTL1 &= ~UCSWRST;                 // Habilita operaci�n del m�dulo USCI.
  IE2 |= UCA0RXIE + UCA0TXIE;           // Habilita Interrupci�n de transmisi�n y
  	  	  	  	  	  	  	  	  	  	// recepci�n.
  __bis_SR_register(LPM3_bits + GIE);   // Modo de consumo LPM3 y habilitaci�n
  	  	  	  	  	  	  	  	  	  	// global de interrupciones.
}
// Rutina de Servicio de Interrupci�n (ISR) del Transmisor.
#pragma vector=USCIAB0TX_VECTOR
__interrupt void USCI0TX_ISR(void)
{
  unsigned char TxByte=0;
  if (P2IN == 0x02)						// Si el switch 1 est� presionado el dato a
    TxByte |= BIT0;						// transmitir es 0x01 para que encienda el LED1
  	  	  	  	  	  	  	  	  	  	// conectado internamente a P1.0 del receptor.
  if (P2IN== 0x01)						// Si el switch 2 est� presionado el dato a
    TxByte |= BIT6;						// transmitir es 0x40 para que encienda el LED2
  	  	  	  	  	  	  	  	  	  	// conectado internamente a P1.6 del receptro.

  UCA0TXBUF = TxByte;                   // Lee UCA0TXBUF para limpiar la bandera de
  	  	  	  	  	  	  	  	  	  	// interrupci�n y escribe el siguiente dato a
  	  	  	  	  	  	  	  	  	  	// enviar.
}

// Rutina de Servicio de Interrupci�n (ISR) del Receptor.
#pragma vector=USCIAB0RX_VECTOR
__interrupt void USCI0RX_ISR(void)
{
  P1OUT = UCA0RXBUF;                     // P1OUT toma el valor recibido a trav�s del
  	  	  	  	  	  	  	  	  	  	 // registro UCA0RXBUF, de este modo se conoce
  	  	  	  	  	  	  	  	  	  	 // cual switch fue oprimido seg�n el LED (LED1 o
  	  	  	  	  	  	  	  	  	  	 // LED2) que encienda.
}
