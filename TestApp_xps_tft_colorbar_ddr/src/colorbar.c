/*$Id: xtft_example.c,v 1.1.2.2 2008/06/09 10:54:36 suneelg Exp $ */
/*****************************************************************************
*
*	XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"
*	AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND
*	SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE,
*	OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,
*	APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION
*	THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,
*	AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE
*	FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY
*	WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE
*	IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR
*	REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF
*	INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
*	FOR A PARTICULAR PURPOSE.
*
*	(c) Copyright 2008 Xilinx Inc.
*	All rights reserved.
*
*****************************************************************************/
/****************************************************************************/
/**
*
* @file colorbar.c
*
* TGenerates a colorbar pattern
*
******************************************************************************/

/***************************** Include Files ********************************/

#include <stdio.h>
#include <xio.h>
#include <sleep.h>
#include "xbasic_types.h"
#include "xstatus.h"
#include "xuartns550_l.h"
#include "xparameters.h"
#include "xtft.h"
/*#include "memory_map.h"*/

#ifdef PPC440CACHE
#include "xcache_l.h"
#endif

/************************** Constant Definitions ****************************/
#define DISPLAY_COLUMNS  640
#define DISPLAY_ROWS     480

/**************************** Type Definitions ******************************/

/***************** Macros (Inline Functions) Definitions ********************/

/************************** Function Prototypes *****************************/

static int XTft_DrawSolidBox(XTft *Tft, u32 Left, u32 Top, u32 Right, 
			u32 Bottom, u32 PixelVal);
int TftExample(u32 TftDeviceId);

/************************** Variable Definitions ****************************/

static XTft TftInstance;

/************************** Function Definitions ****************************/
/*****************************************************************************/
/**
*
* Main function that invokes the Tft example.
*
* @param	None.
*
* @return
*		- XST_SUCCESS if successful.
*		- XST_FAILURE if unsuccessful.
*
* @note		None.
*
******************************************************************************/
int main()
{
	int Status;

	Status = TftExample(XPAR_TFT_0_DEVICE_ID);
	if ( Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
	return XST_SUCCESS;
}

/*****************************************************************************/
/**
*
* This is the example function which performs the following operations on
* the TFT device -
* - Write numeric characters (0-9) one after another
* - Writes a Color Bar Pattern
* - fills the framebuffer with three colors
*
* @param	TftDeviceId is the unique Id of the device.
*
* @return
*		- XST_SUCCESS if successful.
*		- XST_FAILURE if unsuccessful.
*
* @note		None.
*
******************************************************************************/
int TftExample(u32 TftDeviceId)
{
	int Status;
	u8 VarChar;
	u32 Color;
	u32 Address;
	XTft_Config *TftConfigPtr;
	unsigned int *framebuf_ptr;
	unsigned int i;
	/*
	XUartNs550_SetBaud(UART_BASEADDR, UART_CLOCK, UART_BAUDRATE);
	XUartNs550_mSetLineControlReg(UART_BASEADDR, XUN_LCR_8_DATA_BITS);
	*/
	/* Initialize RS232_Uart_1 - Set baudrate and number of stop bits */
    XUartNs550_SetBaud(XPAR_RS232_UART_1_BASEADDR, XPAR_XUARTNS550_CLOCK_HZ, 9600);
    XUartNs550_mSetLineControlReg(XPAR_RS232_UART_1_BASEADDR, XUN_LCR_8_DATA_BITS);
	
	/*
	 * Get address of the XTft_Config structure for the given device id.
	 */
	
	TftConfigPtr = XTft_LookupConfig(TftDeviceId);
	if (TftConfigPtr == (XTft_Config *)NULL) {
		return XST_FAILURE;
	}
	
	/*
	 * Initialize all the TftInstance members and fills the screen with
	 * default background color.
	 */
	Status = XTft_CfgInitialize(&TftInstance, TftConfigPtr,
				 	TftConfigPtr->BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
	
	
	xil_printf("\r\n");
	xil_printf("  Display color\r\n");
	XTft_SetColor(&TftInstance, 0, 0);
	XTft_ClearScreen(&TftInstance);
	usleep(2000000);
	XTft_SetColor(&TftInstance, 0x00FF0000, 0x0);
	XTft_Write(&TftInstance, 0x30);
	XTft_Write(&TftInstance, 0x31);
	XTft_Write(&TftInstance, 0x32);
	XTft_Write(&TftInstance, 0x33);
	XTft_Write(&TftInstance, 0x34);
	XTft_Write(&TftInstance, 0x35);
	XTft_Write(&TftInstance, 0x36);
	XTft_Write(&TftInstance, 0x37);
	XTft_Write(&TftInstance, 0x38);
	XTft_Write(&TftInstance, 0x39);
	usleep(3000000);
	
	framebuf_ptr = (int*)XPAR_DDR2_SDRAM_MEM_BASEADDR;
	xil_printf("  Painting Screen RED\r\n");
	for( i = 0; i < 512*1024; i++)
	{
	   *framebuf_ptr++ = 0x00FF0000;
	}
	usleep(1000000);
	
	xil_printf("  Painting Screen GREEN\r\n");
	framebuf_ptr = (int*)XPAR_DDR2_SDRAM_MEM_BASEADDR;
	for( i = 0; i < 512*1024; i++)
	{
	   *framebuf_ptr++ = 0x0000FF00;
	}
	usleep(1000000);
	
	xil_printf("  Painting Screen BLUE\r\n");
	framebuf_ptr = (int*)XPAR_DDR2_SDRAM_MEM_BASEADDR;
	for( i = 0; i < 512*1024; i++)
	{
	   *framebuf_ptr++ = 0x000000FF;
	}
	usleep(3000000);
	xil_printf("  Writing Color Bar Pattern\r\n");
	
	XTft_DrawSolidBox(&TftInstance,   0, 0, 79,479,0x00ffffff); // white
	XTft_DrawSolidBox(&TftInstance,  80, 0,159,479,0x00ff0000); // red
	XTft_DrawSolidBox(&TftInstance, 160, 0,239,479,0x0000ff00); // green
	XTft_DrawSolidBox(&TftInstance, 240, 0,319,479,0x000000ff); // blue
	XTft_DrawSolidBox(&TftInstance, 320, 0,399,479,0x00ffffff); // white
	XTft_DrawSolidBox(&TftInstance, 400, 0,479,479,0x00AAAAAA); // grey
	XTft_DrawSolidBox(&TftInstance, 480, 0,559,479,0x00777777); // not-so-grey
	XTft_DrawSolidBox(&TftInstance, 560, 0,639,479,0x00333333); // lite grey

	xil_printf("  TFT test completed!\r\n");
	xil_printf("  You should see vertical color and grayscale bars\r\n");
	xil_printf("  across your VGA Output Monitor\r\n\r\n");

	return XST_SUCCESS;
}

/*****************************************************************************/
/**
* Draws a solid box with the specified color between two points.
*
* @param	InstancePtr is a pointer to the XTft instance.
* @param	Left, Top, Right, Bottom are the edges of the box
* @param	PixelVal is the Color Value to be put at pixel.
*
* @return
*		- XST_SUCCESS if successful.
*		- XST_FAILURE if unsuccessful.
*
* @note		None.
*
******************************************************************************/
static int XTft_DrawSolidBox(XTft *InstancePtr, u32 Left, u32 Top, u32 Right, 
			u32 Bottom, u32 PixelVal)
{
   u32 xmin,xmax,ymin,ymax,i,j;

   if (Left >= 0 &&
		Left <= DISPLAY_COLUMNS-1 &&
		Right >= 0 &&
		Right <= DISPLAY_COLUMNS-1 &&
		Top >= 0 &&
		Top <= DISPLAY_ROWS-1 &&
		Bottom >= 0 &&
		Bottom <= DISPLAY_ROWS-1) {
		if (Right < Left) {
			xmin = Right;
			xmax = Left;
		}
		else {
			xmin = Left;
			xmax = Right;
		}
		if (Bottom < Top) {
			ymin = Bottom;
			ymax = Top;
		}
		else {
			ymin = Top;
			ymax = Bottom;
		}

		for (i=xmin; i<=xmax; i++) {
			for (j=ymin; j<=ymax; j++) {
				XTft_SetPixel(InstancePtr, i, j, PixelVal);
			}
		}
		return XST_SUCCESS;
	}
	return XST_FAILURE;
}

