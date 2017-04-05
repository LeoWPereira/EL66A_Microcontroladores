// Copyright 2015 @ Sunrom Electronics www.sunrom.com
#include <reg51.h>
#include <intrins.h>
#include "sys.h"

// uncomment below as per your freq of operation

/* void delayms(unsigned int x)	 // delays x msec (at fosc=11.0592MHz)
{
	unsigned char j=0;
	while(x-- > 0)
	{
		for (j=0; j<125; j++){;}
	}
} */
void delayms(unsigned int x)	 // delays x msec (at fosc=22.1184MHz)
{
	unsigned char j=0;
	while(x-- > 0)
	{
		for (j=0; j<62; j++){;}
	}
}
/* void delayms(unsigned int count)  // x1ms @ 33Mhz
{
        int i,j;
        for(i=0;i<count;i++)
                for(j=0;j<1000;j++);
} */