#include "pwm.h"

// Global variables
unsigned char PWM_1 = 0;	  // It can have a value from 0 (0% duty cycle) to 255 (100% duty cycle)
unsigned char PWM_2 = 0;	  // It can have a value from 0 (0% duty cycle) to 255 (100% duty cycle)
unsigned int temp_1 = 0;    // Used inside Timer0 ISR
unsigned int temp_2 = 0;    // Used inside Timer0 ISR

// Init CCT function
void cct_init(void)
{
	P0 = 0x00;  
	P2 = 0x00;   
	P3 = 0x00;  

	return;
}

// Timer0 initialize
void InitTimer(void)
{
	TMOD |= 0x11;    // Set timer0 in mode 1 = 16bit mode

	TH0 = 0x00;      // First time value
	TL0 = 0x00;      // Set arbitrarily zero

	TH1 = 0x00;      // First time value
	TL1 = 0x00;      // Set arbitrarily zero

	ET0 = 1;         // Enable Timer0 interrupts
	ET1 = 1;
	EA  = 1;         // Global interrupt enable

	TR1 = 1;
	TR0 = 1;         // Start Timer 0
	
	return;
}

// PWM initialize
void InitPWM(void)
{
	PWM_1 = 0;         // Initialize with 0% duty cycle
	PWM_2 = 0;         // Initialize with 0% duty cycle
	
	InitTimer();    // Initialize timer0 to start generating interrupts
					 // PWM generation code is written inside the Timer0 ISR
	
	return;
}

// Timer0 ISR
void Timer0_ISR (void) interrupt 1   
{
	TR0 = 0;    // Stop Timer 0
	
	if(PWM_1_Pin)	// if PWM_Pin is high
	{
		if(PWM_1 != 0)
		{
			PWM_1_Pin = 0;
		}
		
		temp_1 = (255-PWM_1) * PWM_Freq_Num;
		TH0  = 0xFF - (temp_1>>8)&0xFF;
		TL0  = 0xFF - temp_1&0xFF;	
	}
	else	     // if PWM_Pin is low
	{
		if(PWM_1 != 0)
		{
			PWM_1_Pin = 1;
		}
		
		temp_1 = PWM_1 * PWM_Freq_Num;
		TH0  = 0xFF - (temp_1>>8)&0xFF;
		TL0  = 0xFF - temp_1&0xFF;
	}

	TF0 = 0;     // Clear the interrupt flag
	TR0 = 1;     // Start Timer 0
	
	return;
}

// Timer1 ISR
void Timer1_ISR (void) interrupt 3   
{
	TR1 = 0;    // Stop Timer 0

	if(PWM_2_Pin)	// if PWM_Pin is high
	{
		if(PWM_2 != 0)
		{
			PWM_2_Pin = 0;
		}
		
		temp_2 = (255 - PWM_2) * PWM_Freq_Num;
		TH1  = 0xFF - (temp_2 >> 8) & 0xFF;
		TL1  = 0xFF - temp_2 & 0xFF;	
	}
	else	     // if PWM_Pin is low
	{
		if(PWM_2 != 0)
		{
			PWM_2_Pin = 1;
		}
		
		temp_2 = PWM_2 * PWM_Freq_Num;
		TH1  = 0xFF - (temp_2>>8)&0xFF;
		TL1  = 0xFF - temp_2&0xFF;
	}

	TF1 = 0;     // Clear the interrupt flag
	TR1 = 1;     // Start Timer 0
	
	return;
}