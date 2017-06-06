#include<reg51.h>

// PWM_Pin
sbit PWM_1_Pin = P2^2;		   // Pin P2.3 is named as PWM_Pin
sbit PWM_2_Pin = P2^3;		   // Pin P2.3 is named as PWM_Pin

sbit  PWM_1_in1 = P3^0;
sbit  PWM_1_in2 = P3^1;
sbit  PWM_2_in3 = P3^2;
sbit  PWM_2_in4 = P3^3;

// PWM frequency selector
/* PWM_Freq_Num can have values in between 1 to 257	only
 * When PWM_Freq_Num is equal to 1, then it means highest PWM frequency
 * which is approximately 1000000/(1*255) = 3.9kHz
 * When PWM_Freq_Num is equal to 257, then it means lowest PWM frequency
 * which is approximately 1000000/(257*255) = 15Hz
 *
 * So, in general you can calculate PWM frequency by using the formula
 *     PWM Frequency = 1000000/(PWM_Freq_Num*255)
 */
#define PWM_Freq_Num   100	 // Highest possible PWM Frequency
#define SENTIDO_FRENTE		0
#define SENTIDO_TRAS			1

// Extern variables
extern unsigned char PWM_1;
extern unsigned char PWM_2;
extern unsigned int temp_1;
extern unsigned int temp_2;

extern unsigned char PWM_1_SENTIDO;
extern unsigned char PWM_2_SENTIDO;

// Function declarations
extern void cct_init(void);

extern void InitTimer(void);

extern void InitPWM(void);

extern void Timer0_ISR (void);   
	
extern void Timer1_ISR (void);