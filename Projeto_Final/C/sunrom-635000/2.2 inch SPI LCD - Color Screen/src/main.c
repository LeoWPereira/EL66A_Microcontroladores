#include <REG51.H>

#include <intrins.h>
#include <sys\sys.h>
#include <lcd-2.2\lcd.h>
#include <font\font.h>

/*
Example: Color Screens - Draw different color screens every 3 seconds

Hardware Setup: 
	Microchip SST89V516RD
	Crystal 22.1184 Mhz 
	Operating voltage of 3.3V

IO connections between MCU and LCD:
	Data: 
		LCD(DB8-DB15) = P2^0-P2^7;
	Control: 
		LCD_RS = P3^5; 
		LCD_WR = P3^6;
		LCD_RD = P3^7;
		LCD_CS = P1^0;
		LCD_RESET = P1^2;
*/

void main()
{
	Lcd_Init();

	LCD_Clear(WHITE);
	BACK_COLOR=BLACK;
	POINT_COLOR=WHITE; 

	while(1)
	{
	     LCD_Clear(RED);
		 delayms(3000);
		 LCD_Clear(GREEN);
		 delayms(3000);
		 LCD_Clear(BLUE);
		 delayms(3000);
    }
}
