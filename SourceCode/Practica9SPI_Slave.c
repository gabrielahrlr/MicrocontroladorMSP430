//Práctica 9: Módulo USCI modo SPI
// Código para MSP430G2553 configurado como Slave SPI
#include <msp430g2553.h>

int main(void)
{
  WDTCTL = WDTPW + WDTHOLD;         //Detiene Perro guardián.
  UCA0CTL1=UCSWRST;					//UCSWRST=1
  P1OUT = 0x00;                     //Limpia salidas de puerto 1.
  P1DIR |= BIT0 + BIT6;				//BIT0 y BIT 1 de puerto 1 como salidas.
  P1SEL = BIT1 + BIT2 + BIT4;		//Selección de función de UCA0SOMI,
  	  	  	  	  	  	  	  	  	//UCA0SIMO y UCA0CLK.
  P1SEL2 = BIT1 + BIT2 + BIT4;		//Selección de función de UCA0SOMI,
  	  	  	  	  	  	  	  	  	//UCA0SIMO y UCA0CLK.
  P2DIR=0x00;						//Puerto 2 como entrada.
  P2REN |= BIT0 + BIT1;				//Configuración de resistencias
  P2OUT |= BIT0 + BIT1;				//internas de pull-up en P2.0 y P2.1
  UCA0CTL0 |= UCCKPL + UCMODE_0+ UCSYNC+UCMSB;  // Modo 3-pin, SPI Slave
  	  	  	  	  	  	  	  	  	  	  	  	//Enviar primero MSB,
  	  	  	  	  	  	  	  	  	  	  	  	//Modo Síncrono.
  UCA0MCTL = 0;                     // No hay modulación.
  UCA0CTL1 &= ~UCSWRST;        		// Desbloqueo del Módulo USCI para poder operar.
  IE2 |= UCA0RXIE;           	    // Habilitación de interrupción de Recepción.

  __delay_cycles(7500);             // Retardo de tiempo para que el Esclavo se
  	  	  	  	  	  	  	  	  	//Inicialice.

  UCA0TXBUF = P2IN;					//Transmisión del dato generado por el switch 1
  	  	  	  	  	  	  	  	  	// y el switch 2.
  __bis_SR_register(LPM0_bits + GIE); // CPU off, Habilitación Global de Interrupciones.
}

//Rutina de Servicio de Interrupción (ISR)
#pragma vector=USCIAB0RX_VECTOR
__interrupt void USCIA0RX_ISR(void)
{
  while (UCB0RXIFG ==0);		//Espera que todo el dato sea recibido.

  if (UCA0RXBUF == 0x01)       	//Compara el dato recibido con 0x01
    P1OUT |= BIT0;              //Si es correcto el switch 2 está presionado y
  	  	  	  	  	  	  	  	//enciende el LED1 rojo conectado internamente a P1.0
  else if (UCA0RXBUF==0x02){	//Compara el dato recibido con 0x02
	  	  	  	  	  	  	  	//Si es correcto el swtich 1 esta presionado y
  	  P1OUT |= BIT6;			//Enciende el LED2 verde conectado internamente a P1.6.

  }else{						//Si el dato recibido no es ninguna de las opciones
	  P1OUT=0x00;				//anteriores limpia la salida del puerto 1.
  }

  UCA0TXBUF =P2IN;              // Envía siguente dato.

  __delay_cycles(7500);         //Añade un retardo de tiempo entre las transmisiones.
}

