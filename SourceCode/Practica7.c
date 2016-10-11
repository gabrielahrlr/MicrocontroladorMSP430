// Laboratorio de Microprocesadores y Microcotroladores
// Pr�ctica 7. Timer_A.En modo de comparaci�n. En esta pr�ctica se genera una
// se�al de PWM utilizando el  canal 0 y canal 1 del TIMER0_A, esta se�al se
//conecta al cable de control de un Servo-Motor. Para cambiar la posici�n del
//servo se cambia el ciclo de trabajo de la se�al de PWM con un TRIMPOT.
#include "msp430g2553.h"
//Conectar el cable de la se�al del servo a P1.2 a trav�s de una resistencia de 1k-ohm.
#define MCU_Reloj          1000000		//Reloj del Microcontrolador que alimenta el
										// Timer_A-
#define PWM_FREQUENCIA     50     		// Frecuencia de la se�al de PWM deseada.
										// Periodo de 20ms
unsigned int PWM_Periodo= (MCU_Reloj / PWM_FREQUENCIA);  //Periodo en cuentas del PWM,
														//Este valor se coloca en el
														//registro TACCR0.
unsigned int PWM_Duty = 0;                            // Se limpia el valor del ciclo
													  // de trabajo.
//Programa Principal
void main (void){
    // Configuraci�n del Timer0_A (PWM) y del ADC.
    WDTCTL  = WDTPW + WDTHOLD;		// Detiene el Perro Guardi�n.
    BCSCTL1= CALBC1_1MHZ;			//Calibraci�n del reloj del CPU a 1MHz
    DCOCTL= CALDCO_1MHZ;
    TA0CCTL1 = OUTMOD_7;            //Se configura TACCR1 con modo de salida reset/set
    TA0CTL   = TASSEL_2 + MC_1;     //Se elige el reloj SMCLK(1MHz) y modo de cuenta Up.
    TA0CCR0  = PWM_Periodo-1;        //Se pone el valor del periodo en cuentas en TA0CCR0.
    TA0CCR1  = PWM_Duty;            //Se pone el ciclo de trabajo en TA0CCR1.
    P1DIR   |= BIT2;				// Se configura P1.2 como salida.
    P1SEL   |= BIT2;              	// Se selecciona P1.2 como salida TA1
    ADC10CTL0 = ADC10SHT_2 + ADC10ON; // Tiempo de muestreo 16xADC10Clocks,habilita ADC10.
    ADC10CTL1 = INCH_1; 			// Se configura P1.1 como entrada anal�gica.
    for (;;)
     {
     ADC10CTL0 |= ENC + ADC10SC; 	// Inicio de muestreo y conversi�n.
     while (ADC10CTL1 & ADC10BUSY); // Pregunta si se est� realizando una conversi�n.
     TA0CCR1 = ADC10MEM << 2;		// Se toma el valor de la entrada anal�gica ADC10MEM y se
     	 	 	 	 	 	 	 	// hace dos corrimientos hacia la izquierda, es decir, se
     	 	 	 	 	 	 	 	// se multiplica dos veces por dos el valor del ADC10MEM
     __delay_cycles(10000);			// Retardo
      }
}


