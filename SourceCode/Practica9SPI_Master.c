//Pr�ctica 9: M�dulo USCI modo SPI
// C�digo para MSP430G2553 configurado como Master SPI
#include <msp430g2553.h>
int main(void)
{
  WDTCTL = WDTPW + WDTHOLD;		//Detiene Perro Guardi�n.
  BCSCTL1= CALBC1_1MHZ;			//Calibraci�n del SMCLK a 1MHz
  DCOCTL= CALDCO_1MHZ;
  UCA0CTL1=UCSWRST;				// UCSWRST=1
  P1OUT = 0x00;               	// Limpia salidas de Puerto 1.
  P1DIR |= BIT0 + BIT5 + BIT6;	//Configura el BIT0,BIT5 y BIT6
  	  	  	  	  	  	  	  	//de puerto 1 como salidas.
  P1SEL = BIT1 + BIT2 + BIT4;	//Selecci�n de funci�n de UCA0SOMI,
  	  	  	  	  	  	  	  	//UCA0SIMO y UCA0CLK.
  P1SEL2 = BIT1 + BIT2 + BIT4;	//Selecci�n de funci�n de UCA0SOMI,
  	  	  	  	  	  	  	  	//UCA0SIMO y UCA0CLK.
  P2DIR=0x00;					//Puerto 2 como entrada.
  P2REN |= BIT0 + BIT1;			//Configuraci�n de resistencias
  P2OUT |= BIT0 + BIT1;			//internas de pull-up en P2.0 y P2.1
  UCA0CTL0 |= UCCKPL + UCMST + UCMODE_0+ UCSYNC+UCMSB;  // Modo 3-pin, SPI master
  	  	  	  	  	  	  	  	  	  	  	  	  	  	//Enviar primero MSB,
  	  	  	  	  	  	  	  	  	  	  	  	  	  	//Modo S�ncrono.
  UCA0CTL1 |= UCSSEL_2;        // Selecci�n de reloj SMCLK
  UCA0BR0 |= 0x02;             // Preescalado de reloj entre 2.
  UCA0BR1 = 0;
  UCA0MCTL = 0;                // No hay modulaci�n
  UCA0CTL1 &= ~UCSWRST;        // Desbloqueo del M�dulo USCI
  IE2 |= UCA0RXIE;             // Habilitaci�n de interrupci�n de Recepci�n.


  P1OUT &= ~BIT5;				// Reseta Esclavo
  P1OUT |= BIT5;                //Se�ales de SPI inicializadas.


  __delay_cycles(7500);         //Retardo de espera para que el esclavo se
  	  	  	  	  	  	  	  	//Inicialice.


  UCA0TXBUF = P2IN;				//Transmisi�n del dato generado por el switch 1
  	  	  	  	  	  	  	  	// y el switch 2.

  __bis_SR_register(LPM0_bits + GIE);	//CPU off, y habilitaci�n general de
  	  	  	  	  	  	  	  	  	  	//interrupciones.

}

//Rutina de Servicio de Interrupci�n (ISR)
#pragma vector=USCIAB0RX_VECTOR
__interrupt void USCIA0RX_ISR(void)
{
  while (UCB0RXIFG ==0);		//Espera que todo el dato sea recibido.

  if (UCA0RXBUF == 0x01)       	//Compara el dato recibido con 0x01
    P1OUT |= BIT0;              //Si es correcto el switch 2 est� presionado y
  	  	  	  	  	  	  	  	//enciende el LED1 rojo conectado internamente a P1.0
  else if (UCA0RXBUF==0x02){	//Compara el dato recibido con 0x02
	  	  	  	  	  	  	  	//Si es correcto el swtich 1 esta presionado y
  	  P1OUT |= BIT6;			//Enciende el LED2 verde conectado internamente a P1.6.

  }else{						//Si el dato recibido no es ninguna de las opciones
	  P1OUT=0x00;				//anteriores limpia la salida del puerto 1.
  }

  UCA0TXBUF =P2IN;              // Env�a siguente dato.

  __delay_cycles(7500);         //A�ade un retardo de tiempo entre las transmisiones.
}
