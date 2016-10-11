//Laboratorio de Microprocesadores y Microcontroladores
//Práctica 8. Se configura al Timer_A0 en modo captura y al
//Timer_A1  en comparación para generar una señal PWM, esta señal
// es leía por el Timer_A0 modo captura y se despliega el valor en
//el LCD.
#include  "msp430g2553.h"

#define     LCD_DIR               P1DIR
#define     LCD_OUT               P1OUT

//
//Mapeo de los pines para el LCD
#define     LCD_PIN_RS            BIT0          // P1.0
#define     LCD_PIN_EN            BIT1          // P1.1
#define     LCD_PIN_D7            BIT7          // P1.7
#define     LCD_PIN_D6            BIT6          // P1.6
#define     LCD_PIN_D5            BIT5          // P1.5
#define     LCD_PIN_D4            BIT4          // P1.4


#define     LCD_PIN_MASK  ((LCD_PIN_RS | LCD_PIN_EN | LCD_PIN_D7| LCD_PIN_D6 | LCD_PIN_D5 | LCD_PIN_D4))

#define     COMANDO			0
#define     DATO			1
unsigned char d1= 0x00 | 0x30,d2= 0x00 | 0x30,d3= 0x00 | 0x30,d4= 0x00 | 0x30,d5= 0x00 | 0x30;
unsigned char samplestate=0;
unsigned char sampleok=0;
unsigned int  sample1, sample2, bynbyte;
unsigned int aux;

unsigned int bynbyte, v, xx, xxx;
// Función de parpadeo de cursor.
// Esta función se llamará cuando se requiera
// enviar un dato o un comando.
void PulseLCD()
{
    // Desactiva el bit EN
    LCD_OUT &= ~LCD_PIN_EN;
    __delay_cycles(200);
    //Activa el bit En
    LCD_OUT |= LCD_PIN_EN;
    __delay_cycles(200);
    //Vuelve a desactivar el bit EN
    LCD_OUT &= (~LCD_PIN_EN);
    __delay_cycles(200);
}

// Función para enviar un byte:
// Esta función envía un byte al LCD ya sea
// un comando o un dato, se utilizan sólo cuatro
// bits para enviarlo, por lo que es necesario
// mandar el byte en dos partes. Primero el nibble
// alto y luego el nibble bajo.
//
// Parámetros:
//
//    ByteParaenviar - El byte que se quiere enviar el
//						LCD
//
//    DatCom -  Se pone DATO si el byte es un caracter o
//				dato y se pone COMANDO si es un comando.
void EnviarByte(char ByteParaEnviar, int DatCom)
{
	//Limpiar todos los pines de salida.
    LCD_OUT &= (~LCD_PIN_MASK);
    //

    //Activa el Nibble Alto enmascarando
    //sólo los bits P1.7-P1.4 (DB7-DB4)
    LCD_OUT |= (ByteParaEnviar & 0xF0);

    if (DatCom == DATO)
    {
    //Si es dato manda un '1' al pin 4 del LCD
    //para decirle que es un dato.
        LCD_OUT |= LCD_PIN_RS;
    }
    else
    {
    //Si es comando manda un '0' al pin 4 del LCD
    //para decirle que es un comando.
        LCD_OUT &= ~LCD_PIN_RS;
    }

    //Una vez que ya se configuró el pin 4 del LCD (RS)
    //como dato ó comando, es momento de leer el byte.
    PulseLCD();
     //
    //Limpia todos los bits de salida
    LCD_OUT &= (~LCD_PIN_MASK);
    //Activa el nibble bajo, enmascarando los 4 bits menos
    //significativos y haciendo 4 corrimientos a la izquierda.
    LCD_OUT |= ((ByteParaEnviar & 0x0F) << 4);

    if (DatCom == DATO)
    {
        LCD_OUT |= LCD_PIN_RS;
    }
    else
    {
        LCD_OUT &= ~LCD_PIN_RS;
    }


    PulseLCD();
}

//
// Función para poner el cursor en una posición específica.
// Parámetros:
//
//     Fila- Si Fila es cero la posición es la primer fila.
//			 Si Fila es uno la posición del cursor es la
//			 segunda fila.
//
//     Col - Poner el número de la columna en que se quiera
//			 posicionar el cursor, desde la columna cero
//			 hasta 15. (0-15).

void LCDPosicionCursor(char Fila, char Col)
{
    char address;
    //la variable adress se forma con el valor de Fila y Col.
    if (Fila == 0)
    {
        address = 0;
    }
    else
    {
        address = 0x40;
    }

    address |= Col;

    EnviarByte(0x80 | address, COMANDO);
}
// Función Para limpiar Pantalla.
//Limpia la pantalla y pone al cursor en su posición base.

void LimpiaPantallaLCD()
{
// Limpia Pantalla
    EnviarByte(0x01, COMANDO);
// Pone Cursor en posición base.
    EnviarByte(0x02, COMANDO);
}

// Función para inicializar el LCD.
// Initialize the LCM after power-up.
// Esta función no debe ser llamada dos veces por
// el programa principal.

void InicializarLCD(void)
{
	//Limpia todos los bits del LCD.
    LCD_DIR |= LCD_PIN_MASK;
    LCD_OUT &= ~(LCD_PIN_MASK);


    //Retardo para que el LCD active sus pines.
    __delay_cycles(100000);
    //Inicialización del LCD
    // Activar la entrada de 4-bits
    LCD_OUT &= ~LCD_PIN_RS;
    LCD_OUT &= ~LCD_PIN_EN;

    LCD_OUT = 0x20;
    PulseLCD();

    EnviarByte(0x28, COMANDO);

    //Activar LCD y Cursor
    EnviarByte(0x0E, COMANDO);

    //Posición de cursor se auto-incremente.

    EnviarByte(0x06, COMANDO);
}


// Función para Imprimir un String
// Imprime una cadena de caracteres en la
// pantalla
void ImprimirStr(char *Texto)
{
    char *c;

    c = Texto;

    while ((c != 0) && (*c != 0))
    {
        EnviarByte(*c, DATO);
        c++;
    }
}

// Función para Imprimir un entero
// En esta función un número entero se convierte
// a ASCII para poder imprimirlo en el LCD.
//Primero se separa el número en unidades y se
// le suman 0x30 para convertirlo en ASCII y así hasta
// llegar a diezmiles.
void ImprimirEntero(unsigned int entero)
{

	bynbyte=entero;
  	v = bynbyte/10;
  	d1 = bynbyte % 10; //unidades
  	d1 = d1 | 0x30;
  	d2 = v % 10;	 //decenas
  	d2 = d2 |0x30;
  	xx = v / 10;
  	d3 = xx % 10;	// centenas
  	d3 = d3 | 0x30;
  	xxx= xx/10;
  	d4= xxx%10;		//miles
  	d4= d4  | 0x30;
  	d5=xxx/10;
  	d5= d5  | 0x30; //diezmiles

  	EnviarByte(d5, DATO);
  	EnviarByte(d4, DATO);
  	EnviarByte(d3, DATO);
	EnviarByte(d2,DATO);
	EnviarByte(d1,DATO);
}


// Programa principal
void main(void)
{
    WDTCTL = WDTPW + WDTHOLD;      	 // Detiene perro guardián.
    InicializarLCD();
    LimpiaPantallaLCD();
    ImprimirStr("PRACTICA 8:");
    //Configuración de los puertos
    P2DIR |= BIT1;
    P2SEL |= BIT1;
    P1DIR =0xFF&~(BIT2);
    P1SEL|= BIT2;
    //Configuración de la señal de PWM
    TA1CCR0=10000-1;					//Periodo de la señal de PWM.
    TA1CCTL1=OUTMOD_7;					//Modo de salida en comparación
    									// reset/set
    TA1CCR1=5000;						//50% Ciclo de trabajo.
    TA1CTL=TASSEL_2+ID_0+MC_1+TACLR;	// Reloj=SMCLK, Modo de cuenta Up.
    // COnfiguración de la Captura
    TA0CCTL1=CM_1+CCIS_0+SCS+CAP+CCIE;	//Captura en Flanco de subida, entrada
    									//captura CCI1A, fuente de captura
    									//Sincronizada e interrupciones.
    TA0CTL=TASSEL_2+ID_0+MC_2+TACLR;	//Reloj=SMCLK, Modo de cuenta continuo.
    _BIS_SR(LPM0_bits + GIE);			//Habilitar interrupciones globales.

    while (1)
    {
    	__delay_cycles(100000);
    }

}

//Rutina de servicio de interrupción (ISR)

#pragma vector=TIMER0_A1_VECTOR
__interrupt void InterruptCapture (void)
{
	if(samplestate==0){
		sample1=TA0CCR1;		//Muestra 1
		samplestate=1;
	} else if(samplestate==1){
		sample2=TA0CCR1;		// Muestra 2
		samplestate=0;
        aux=sample2-sample1;	//Muestra2-Muestra 1
        aux=1/(aux*0.000001);	//Obtener frecuencia
        LimpiaPantallaLCD();
        ImprimirStr("Frecuencia:");
        LCDPosicionCursor(2,0);
        ImprimirEntero(aux);	//Imprimir frecuencia medida.
        ImprimirStr(" Hertz");
        __delay_cycles(1000000);

	}
	TA0CCTL1 &=~CCIFG;

}
