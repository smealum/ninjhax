#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctr/types.h>
#include "text.h"
#include "font_bin.h"

#define CHAR_SIZE_X (8)
#define CHAR_SIZE_Y (8)

int _strlen(char* str);

void drawCharacter(u8* fb, char c, u16 x, u16 y)
{
	if(c<32)return;
	c-=32;
	u8* charData=(u8*)&font_bin[(CHAR_SIZE_X*CHAR_SIZE_Y*c)/8];
	fb+=(x*240+y)*3;
	int i, j;
	for(i=0;i<CHAR_SIZE_X;i++)
	{
		u8 v=*(charData++);
		for(j=0;j<CHAR_SIZE_Y;j++)
		{
			if(v&1)fb[0]=fb[1]=fb[2]=0x00;
			else fb[0]=fb[1]=fb[2]=0xFF;
			fb+=3;
			v>>=1;
		}
		fb+=(240-CHAR_SIZE_Y)*3;
	}
}

void drawString(u8* fb, char* str, u16 x, u16 y)
{
	if(!str)return;
	y=232-y;
	int k;
	int dx=0, dy=0;
	for(k=0;k<_strlen(str);k++)
	{
		if(str[k]>=32 && str[k]<128)drawCharacter(fb,str[k],x+dx,y+dy);
		dx+=8;
		if(str[k]=='\n'){dx=0;dy-=8;}
	}
}
