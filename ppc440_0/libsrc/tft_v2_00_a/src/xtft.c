/* $Id: xtft.c,v 1.1.2.2 2009/07/20 09:45:12 svemula Exp $ */
/******************************************************************************
*
* (c) Copyright 2008-2009 Xilinx, Inc. All rights reserved.
*
* This file contains confidential and proprietary information of Xilinx, Inc.
* and is protected under U.S. and international copyright and other
* intellectual property laws.
*
* DISCLAIMER
* This disclaimer is not a license and does not grant any rights to the
* materials distributed herewith. Except as otherwise provided in a valid
* license issued to you by Xilinx, and to the maximum extent permitted by
* applicable law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL
* FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS,
* IMPLIED, OR STATUTORY, INCLUDING BUT NOT LIMITED TO WARRANTIES OF
* MERCHANTABILITY, NON-INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE;
* and (2) Xilinx shall not be liable (whether in contract or tort, including
* negligence, or under any other theory of liability) for any loss or damage
* of any kind or nature related to, arising under or in connection with these
* materials, including for any direct, or any indirect, special, incidental,
* or consequential loss or damage (including loss of data, profits, goodwill,
* or any type of loss or damage suffered as a result of any action brought by
* a third party) even if such damage or loss was reasonably foreseeable or
* Xilinx had been advised of the possibility of the same.
*
* CRITICAL APPLICATIONS
* Xilinx products are not designed or intended to be fail-safe, or for use in
* any application requiring fail-safe performance, such as life-support or
* safety devices or systems, Class III medical devices, nuclear facilities,
* applications related to the deployment of airbags, or any other applications
* that could lead to death, personal injury, or severe property or
* environmental damage (individually and collectively, "Critical
* Applications"). Customer assumes the sole risk and liability of any use of
* Xilinx products in Critical Applications, subject only to applicable laws
* and regulations governing limitations on product liability.
*
* THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE
* AT ALL TIMES.
*
******************************************************************************/
/***************************************************************************/
/**
*
* @file xtft.c
*
* This file defines all the functions for the XTft driver. See the xtft.h
* header file for more details on this driver.
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver    Who   Date      Changes
* -----  ----  --------  -----------------------------------------------
* 1.00a  sg    03/24/08  First release
* 2.00a	 ktn   07/06/09	 Added XTft_IntrEnable(), XTft_IntrDisable()and,
*			 XTft_GetVsyncStatus() functions to access newly added
*			 Interrupt Enable and Status Register.
* </pre>
*
****************************************************************************/

/***************************** Include Files *******************************/
#include "xtft.h"
#include "xtft_charcode.h"

/************************** Constant Definitions ***************************/

/**************************** Type Definitions *****************************/

/***************** Macros (Inline Functions) Definitions *******************/

/************************** Function Prototypes ****************************/
static void XTft_WriteChar(XTft* InstancePtr, u8 CharValue,
				u32 ColStartVal, u32 RowStartVal, u32 FgColor,
				u32 BgColor);

/************************** Variable Definitions ***************************/

/************************** Function Definitions ***************************/

/***************************************************************************/
/**
*
* This function initializes a TFT Driver Instance.
*
* @param	InstancePtr is a pointer to the XTft instance.
* @param	ConfigPtr is a pointer to a XTft_Config configuration
*		structure.This structure will contain the requested
*		configuration for the device. Typically, this is a local
*		structure and the content of which will be copied into the
*		configuration structure within XTft.
* @param	EffectiveAddr is the device base address in the virtual
*		memory address space. If the address translation is not used
*		then the physical address is passed. Unexpected errors may
*		occur if the address mapping is changed after this function
*		is invoked.
*		This address is taken into consideration only if the
*		the TFT controller Register interface is connected to the
*		PLB bus.
*
* @return
*		- XST_SUCCESS if successful.
*		- XST_FAILURE if unsuccessful.
*
* @note		None.
*
****************************************************************************/
int XTft_CfgInitialize(XTft *InstancePtr, XTft_Config *ConfigPtr,
			 u32 EffectiveAddr)
{
	/*
	 * Assert validates the input arguments.
	 */
	XASSERT_NONVOID(InstancePtr != NULL);
	XASSERT_NONVOID(ConfigPtr != NULL);

	/*
	 * Setup the DeviceId, Video Memory Address and Base Address
	 * and Plb Access from the configuration structure.
	 */
	InstancePtr->TftConfig.DeviceId = ConfigPtr->DeviceId;
	InstancePtr->TftConfig.BaseAddress = EffectiveAddr;
	InstancePtr->TftConfig.VideoMemBaseAddr =
				ConfigPtr->VideoMemBaseAddr;
	InstancePtr->TftConfig.PlbAccess = ConfigPtr->PlbAccess;
	InstancePtr->TftConfig.DcrBaseAddr = ConfigPtr->DcrBaseAddr;

	/*
	 * Initialize the XTft Instance members to default values.
	 */
	InstancePtr->ColVal = XTFT_DEF_COLVAL;
	InstancePtr->RowVal = XTFT_DEF_ROWVAL;
	InstancePtr->FgColor = XTFT_DEF_FGCOLOR;
	InstancePtr->BgColor = XTFT_DEF_BGCOLOR;

	/*
	 * Indicate the XTft Instance is now ready to use, initialized
	 * without error.
	 */
	InstancePtr->IsReady = XCOMPONENT_IS_READY;

	/*
	 * Fills the screen with the default background color.
	 */
	XTft_FillScreen(InstancePtr, XTFT_DEF_COLVAL, XTFT_DEF_ROWVAL,
			(XTFT_DISPLAY_WIDTH - 1), (XTFT_DISPLAY_HEIGHT - 1),
			InstancePtr->BgColor);

	return XST_SUCCESS;
}

/***************************************************************************/
/**
*
* This function updates the column, row position in the Instance structure
* of driver.
*
* @param	InstancePtr is a pointer to the XTft instance.
* @param	ColVal is the column number to which ColVal member of
*		Instance structure is updated. The valid values are
*		0 to (XTFT_DISPLAY_WIDTH - 1).
* @param	RowVal is the row number to which RowVal member of
*		Instance structure is updated. The valid values are
*		0 to (XTFT_DISPLAY_HEIGHT - 1).
*
* @return	None.
*
* @note		None.
*
****************************************************************************/
void XTft_SetPos(XTft *InstancePtr, u32 ColVal, u32 RowVal)
{
	/*
	 * Assert validates the input arguments.
	 */
	XASSERT_VOID(InstancePtr != NULL);
	XASSERT_VOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);
	XASSERT_VOID(ColVal <= (XTFT_DISPLAY_WIDTH - 1) && ColVal >= 0);
	XASSERT_VOID(RowVal <= (XTFT_DISPLAY_HEIGHT - 1) && RowVal >= 0);

	/*
	 * Update the column, row position values.
	 */
	InstancePtr->ColVal = ColVal;
	InstancePtr->RowVal = RowVal;

}

/***************************************************************************/
/**
*
* This function changes the column, row position in the Instance structure
* of driver. It is used to correct the position for the next character to
* be written if column and row position cross limits.
*
* @param	InstancePtr is a pointer to the XTft instance.
* @param	ColVal is the column number to which ColVal member of
*		Instance structure is updated. If ColVal crosses
*		(XTFT_DISPLAY_WIDTH - 1) -  XTFT_CHAR_WIDTH, position is
*		moved to next line. The valid values are 0 to
*		(XTFT_DISPLAY_WIDTH - 1).
* @param	RowVal is the row number to which RowVal member of
*		Instance structure is updated. If RowVal crosses
*		(XTFT_DISPLAY_HEIGHT - 1)- XTFT_CHAR_HEIGHT, the first line
*		will be deleted. The valid values are 0 to
*		(XTFT_DISPLAY_HEIGHT - 1).
*
* @return	None.
*
* @note		This function differs from the function XTft_SetPos because
*		you cannot move to any position on the screen as we have
*		to check for enough space for a character to be written.
*
****************************************************************************/
void XTft_SetPosChar(XTft *InstancePtr, u32 ColVal, u32 RowVal)
{
	/*
	 * Assert validates the input arguments.
	 */
	XASSERT_VOID(InstancePtr != NULL);
	XASSERT_VOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);
	XASSERT_VOID(ColVal <= (XTFT_DISPLAY_WIDTH - 1) && ColVal >= 0);
	XASSERT_VOID(RowVal <= (XTFT_DISPLAY_HEIGHT - 1) && RowVal >= 0);

	/*
	 * If there is no space in the current line for the next char
	 * go to next line.
	 */
	if (ColVal > (XTFT_DISPLAY_WIDTH - 1) - XTFT_CHAR_WIDTH) {
		ColVal = XTFT_DEF_COLVAL;
		RowVal += XTFT_CHAR_HEIGHT;
	}

	/*
	 * If there is no space in the current line for the next char
	 * go to next line by deleting the first line.
	 */
	while (RowVal > (XTFT_DISPLAY_HEIGHT - 1) - XTFT_CHAR_HEIGHT) {
		XTft_Scroll(InstancePtr);
		RowVal -= XTFT_CHAR_HEIGHT;
	}

	/*
	 * Update the column, row position values.
	 */
	InstancePtr->ColVal = ColVal;
	InstancePtr->RowVal = RowVal;

}

/***************************************************************************/
/**
*
* This function changes the color values in the instance structure of driver.
*
* @param	InstancePtr is a pointer to the XTft instance.
* @param 	FgColor is the color with which member FgColor of Instance
*		structure is updated.
* @param 	BgColor is the color with which member BgColor of Instance
*		structure is updated.
*
* @return	None.
*
* @note		Color Values must be 32bit. They can range from 0x0 to
*		0xFFFFFFFF, out of these only 18 bits are valid data. These
*		18 bits contain the Red, Green, Blue color values with
*		6 bits each and bit positions as Red[8-13], Green[16-21],
*		Blue[24-29].
****************************************************************************/
void XTft_SetColor(XTft *InstancePtr, u32 FgColor, u32 BgColor)
{
	/*
	 * Assert validates the input arguments.
	 */
	XASSERT_VOID(InstancePtr != NULL);
	XASSERT_VOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);

	/*
	 * Update the values in the instance structure.
	 */
	InstancePtr->BgColor = BgColor;
	InstancePtr->FgColor = FgColor;

}

/***************************************************************************/
/**
*
* This function sets the pixel with the given color at the given column, row
* position.
*
* @param	InstancePtr is a pointer to the XTft instance.
* @param	ColVal represents the column on the screen. The valid
*		values are 0 to (XTFT_DISPLAY_WIDTH - 1).
* @param	RowVal represents the row on the screen. The valid
*		values are 0 to (XTFT_DISPLAY_HEIGHT - 1).
* @param	PixelVal represents the color with which it will be
*		filled on screen.
*
* @return	None.
*
* @note		None.
*
****************************************************************************/
void XTft_SetPixel(XTft *InstancePtr, u32 ColVal, u32 RowVal, u32 PixelVal)
{
	/*
	 * Assert validates the input arguments.
	 */
	XASSERT_VOID(InstancePtr != NULL);
	XASSERT_VOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);
	XASSERT_VOID(ColVal <= (XTFT_DISPLAY_WIDTH - 1) && ColVal >= 0);
	XASSERT_VOID(RowVal <= (XTFT_DISPLAY_HEIGHT - 1) && RowVal >= 0);

	/*
	 * Set the pixel at the given position with the color value.
	 */
	XTft_mSetPixel(InstancePtr->TftConfig.VideoMemBaseAddr,
				 ColVal, RowVal, PixelVal);

}

/***************************************************************************/
/**
*
* This function gets the color of the pixel at the given column, row
* position.
*
* @param	InstancePtr is a pointer to the XTft instance.
* @param	ColVal represents the column on the screen. The valid
*		values are 0 to (XTFT_DISPLAY_WIDTH - 1).
* @param	RowVal represents the row on the screen. The valid
*		values are 0 to (XTFT_DISPLAY_HEIGHT - 1).
* @param	PixelVal stores the color value on the screen pointed by
*		given Column and Row position.
*
* @return	None.
*
* @note		None.
*
****************************************************************************/
void XTft_GetPixel(XTft *InstancePtr, u32 ColVal, u32 RowVal, u32 *PixelVal)
{
	/*
	 * Assert validates the input arguments.
	 */
	XASSERT_VOID(InstancePtr != NULL);
	XASSERT_VOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);
	XASSERT_VOID(ColVal <= (XTFT_DISPLAY_WIDTH - 1) && ColVal >= 0);
	XASSERT_VOID(RowVal <= (XTFT_DISPLAY_HEIGHT - 1) && RowVal >= 0);

	/*
	 * Get the color of the pixel at the given position.
	 */
	*PixelVal = XTft_mGetPixel(InstancePtr->TftConfig.VideoMemBaseAddr,
					ColVal, RowVal);

}

/***************************************************************************/
/**
*
* This function performs one of the following three operations based on the
* CharValue passed :
* - Move the position to the next line at the same position.
* - Move the position to the next line.
* - Write a particular character and update the column position by the
*   width of the character.
*
* @param	InstancePtr is a pointer to the XTft instance.
* @param	CharValue is the ASCII code value of the character to be
*		written.
*
* @return	None.
*
* @note		As the character bitmap array does not support some of the
*		ASCII values, to support some of those which carry
*		significance in display are added in the switch case. If
*		there is a necessity for any other characters, it can be
*		added here.
*
****************************************************************************/
void XTft_Write(XTft *InstancePtr, u8 CharValue)
{
	/*
	 * Assert validates the input arguments.
	 */
	XASSERT_VOID(InstancePtr != NULL);
	XASSERT_VOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);

	/*
	 * First two cases handle the special input values
	 * and default case performs a character write operation
	 * and it updates the column position in the instance structure.
	 */
	switch (CharValue) {
		case 0xd:
			/*
			 * Action to be taken for carriage return.
			 */
			XTft_SetPos(InstancePtr, XTFT_DEF_COLVAL,
					InstancePtr->RowVal);
			break;
		case 0xa:
			/*
			 * Action to be taken for line feed.
			 */
			XTft_SetPos(InstancePtr, XTFT_DEF_COLVAL,
				InstancePtr->RowVal + XTFT_CHAR_HEIGHT);
			break;
		default:
			/*
			 * Set the position and write the character and
			 * update the column position by width of
			 * character.
			 */
			XTft_SetPosChar(InstancePtr, InstancePtr->ColVal,
					InstancePtr->RowVal);
			XTft_WriteChar(
				InstancePtr, CharValue,
				InstancePtr->ColVal, InstancePtr->RowVal,
				InstancePtr->FgColor, InstancePtr->BgColor);

			InstancePtr->ColVal += XTFT_CHAR_WIDTH;
			break;
	}

}

/***************************************************************************/
/**
*
* This function inserts a new blank line at the bottom of the screen, it
* deletes the first line and moves the remaining lines up by one line.
*
* @param	InstancePtr is a pointer to the XTft instance.
*
* @return	None.
*
* @note		None.
*
****************************************************************************/
void XTft_Scroll(XTft *InstancePtr)
{
	u32 PixelVal;
	u32 ColIndex;
	u32 RowIndex;

	/*
	 * Assert validates the input arguments.
	 */
	XASSERT_VOID(InstancePtr != NULL);
	XASSERT_VOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);

	/*
	 * Takes each pixel value from the second line and puts in the first
	 * line. This process is repeated till the second line
	 * from bottom.
	 */
	for (RowIndex = 0;
		RowIndex < (XTFT_DISPLAY_HEIGHT - 1) - XTFT_CHAR_HEIGHT;
		RowIndex++) {
		for (ColIndex = 0; ColIndex < (XTFT_DISPLAY_WIDTH - 1);
					ColIndex++) {
			XTft_GetPixel(InstancePtr, ColIndex,
				RowIndex + XTFT_CHAR_HEIGHT, &PixelVal);
			XTft_SetPixel(
				InstancePtr, ColIndex, RowIndex, PixelVal);
		}
	}

	/*
	 * Fills the last line with the background color.
	 */
	XTft_FillScreen(InstancePtr,
			 XTFT_DEF_COLVAL,
			 (XTFT_DISPLAY_HEIGHT - 1)-XTFT_CHAR_HEIGHT,
			 (XTFT_DISPLAY_WIDTH - 1), (XTFT_DISPLAY_HEIGHT - 1),
			 InstancePtr->BgColor);

}

/***************************************************************************/
/**
*
* This function re-initializes all the pixels to the default background color.
*
* @param	InstancePtr is a pointer to the XTft instance.
*
* @return	None.
*
* @note		None.
*
****************************************************************************/
void XTft_ClearScreen(XTft *InstancePtr)
{
	/*
	 * Assert validates the input arguments.
	 */
	XASSERT_VOID(InstancePtr != NULL);
	XASSERT_VOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);

	/*
	 * Fills the screen with the background color of Instance structure.
	 */
	XTft_FillScreen(InstancePtr, XTFT_DEF_COLVAL, XTFT_DEF_ROWVAL,
			(XTFT_DISPLAY_WIDTH - 1), (XTFT_DISPLAY_HEIGHT - 1),
			InstancePtr->BgColor);

	/*
	 * Initialize the column, row positions to (0, 0)origin.
	 */
	InstancePtr->ColVal = XTFT_DEF_COLVAL;
	InstancePtr->RowVal = XTFT_DEF_ROWVAL;

}

/***************************************************************************/
/**
*
* This function fills the screen with the range defined by the start and end
* values of column and row with the color passed as argument.
*
* @param	InstancePtr is a pointer to the XTft instance.
* @param	ColStartVal is the value of the starting column. The valid
*		values are 0 to (XTFT_DISPLAY_WIDTH - 1).
* @param	RowStartVal is the value of the starting row. The valid
*		values are 0 to (XTFT_DISPLAY_HEIGHT - 1).
* @param	ColEndVal is the value of the ending column. The valid
*		values are 0 to (XTFT_DISPLAY_WIDTH - 1).
* @param	RowEndVal is the value of the ending row. The valid
*		values are 0 to (XTFT_DISPLAY_HEIGHT - 1).
* @param	PixelVal represents the color with which it will be
*		filled on screen.
*
* @return	None.
*
* @note		It must be taken care to pass values such that column start
*		position should not exceed column end position, same is the
*		case with row position.
*
****************************************************************************/
void XTft_FillScreen(XTft* InstancePtr, u32 ColStartVal, u32 RowStartVal,
			u32 ColEndVal, u32 RowEndVal, u32 PixelVal)
{
	u32 ColIndex;
	u32 RowIndex;

	/*
	 * Assert validates the input arguments.
	 */
	XASSERT_VOID(InstancePtr != NULL);
	XASSERT_VOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);
	XASSERT_VOID(ColStartVal <= (XTFT_DISPLAY_WIDTH - 1) &&
				ColStartVal >= 0);
	XASSERT_VOID(RowStartVal <= (XTFT_DISPLAY_HEIGHT - 1) &&
				RowStartVal >= 0);
	XASSERT_VOID(ColEndVal <= (XTFT_DISPLAY_WIDTH - 1) &&
				ColEndVal >= 0);
	XASSERT_VOID(RowEndVal <= (XTFT_DISPLAY_HEIGHT - 1) &&
				RowEndVal >= 0);

	/*
	 * Fills each pixel on the screen with the value of PixelVal.
	 */
	for (ColIndex = ColStartVal; ColIndex <= ColEndVal; ColIndex++) {
		for (RowIndex = RowStartVal; RowIndex <= RowEndVal;
			RowIndex++) {
			XTft_SetPixel(InstancePtr, ColIndex, RowIndex,
					PixelVal);
		}
	}

}

/***************************************************************************/
/**
*
* This function enables the TFT display by setting the Display Enable bit in
* the Control register.
*
* @param	InstancePtr is a pointer to the XTft instance.
*
* @return	None.
*
* @note		None.
*
****************************************************************************/
void XTft_EnableDisplay(XTft* InstancePtr)
{
	u32 CtrlReg;

	/*
	 * Assert validates the input arguments.
	 */
	XASSERT_VOID(InstancePtr != NULL);
	XASSERT_VOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);

	/*
	 * Read the Control Register.
	 */
	CtrlReg = XTft_ReadReg(InstancePtr, XTFT_CR_OFFSET);

	/*
	 * Set the Display Enable bit.
	 */
	CtrlReg |= XTFT_CR_TDE_MASK;

	/*
	 * Write to the Control Register.
	 */
	XTft_WriteReg(InstancePtr, XTFT_CR_OFFSET, CtrlReg);

}

/***************************************************************************/
/**
*
* This function disables the TFT display by clearing the Display Enable bit
* in the Control register.
*
* @param	InstancePtr is a pointer to the XTft instance.
*
* @return	None.
*
* @note		None.
*
****************************************************************************/
void XTft_DisableDisplay(XTft* InstancePtr)
{
	u32 CtrlReg;

	/*
	 * Assert validates the input arguments.
	 */
	XASSERT_VOID(InstancePtr != NULL);
	XASSERT_VOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);

	/*
	 * Read the Control Register.
	 */
	CtrlReg = XTft_ReadReg(InstancePtr, XTFT_CR_OFFSET);

	/*
	 * Clear the Display Enable bit.
	 */
	CtrlReg &= (~XTFT_CR_TDE_MASK);

	/*
	 * Write to the Control Register.
	 */
	XTft_WriteReg(InstancePtr, XTFT_CR_OFFSET, CtrlReg);

}

/***************************************************************************/
/**
*
* This function enables reverse scan by setting the Display Scan Control(DPS)
* bit in the Control register.
*
* @param	InstancePtr is a pointer to the XTft instance.
*
* @return	None.
*
* @note		By default the scan direction is reverse, the image we see in
* 		reverse scan mode is the horizontal and vertical mirror image
*		of the image in normal scan mode.
*
****************************************************************************/
void XTft_ScanReverse(XTft* InstancePtr)
{
	u32 CtrlReg;

	/*
	 * Assert validates the input arguments.
	 */
	XASSERT_VOID(InstancePtr != NULL);
	XASSERT_VOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);

	/*
	 * Read the Control Register.
	 */
	CtrlReg = XTft_ReadReg(InstancePtr, XTFT_CR_OFFSET);

	/*
	 * Set the Display Scan Control bit.
	 */
	CtrlReg |= XTFT_CR_DPS_MASK;

	/*
	 * Write to the Control Register.
	 */
	XTft_WriteReg(InstancePtr, XTFT_CR_OFFSET, CtrlReg);

}

/***************************************************************************/
/**
*
* This function enables normal scan by clearing the Display Scan Control(DPS)
* bit in the Control register.
*
* @param	InstancePtr is a pointer to the XTft instance.
*
* @return	None.
*
* @note		None.
*
****************************************************************************/
void XTft_ScanNormal(XTft* InstancePtr)
{
	u32 CtrlReg;

	/*
	 * Assert validates the input arguments.
	 */
	XASSERT_VOID(InstancePtr != NULL);
	XASSERT_VOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);

	/*
	 * Read the Control Register.
	 */
	CtrlReg = XTft_ReadReg(InstancePtr, XTFT_CR_OFFSET);

	/*
	 * Clear the Display Scan Control bit.
	 */
	CtrlReg &= (~XTFT_CR_DPS_MASK);

	/*
	 * Write to the Control Register.
	 */
	XTft_WriteReg(InstancePtr, XTFT_CR_OFFSET, CtrlReg);

}

/***************************************************************************/
/**
*
* This function changes the Video Memory Base address stored in the Address
* Register.
*
* @param	InstancePtr is a pointer to the XTft instance.
* @param 	NewFrameBaseAddr is the new memory address value to be
*		written to the Address register.
*
* @return	None.
*
* @note		The new memory address must be in the address range of
*		external memory and it must be taken care that 2MB memory is
*		available from this new address so that frame data to 640*480
*		screen can be written.
*
****************************************************************************/
void XTft_SetFrameBaseAddr(XTft* InstancePtr, u32 NewFrameBaseAddr)
{
	/*
	 * Assert validates the input arguments.
	 */
	XASSERT_VOID(InstancePtr != NULL);
	XASSERT_VOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);
	XASSERT_VOID((NewFrameBaseAddr & 0x1FFFFF) == 0x0);

	/*
	 * Write to the Control Register.
	 */
	XTft_WriteReg(InstancePtr, XTFT_AR_OFFSET, NewFrameBaseAddr);

	/*
	 * Update the Instance structure member.
	 */
	InstancePtr->TftConfig.VideoMemBaseAddr =  NewFrameBaseAddr;

}

/***************************************************************************/
/**
*
* Write a value to a TFT register. A 32 bit write is performed.
*
* @param	InstancePtr is a pointer to the XTft instance.
* @param	RegOffset is the register offset from the base to write to.
* @param	Data is the data written to the register.
*
* @return	None.
*
* @note
*
* The constant XPAR_TFT_USE_DCR_BRIDGE is used to inform the driver that
* the Control Register Interface of the TFT device is on a DCR BUS connected
* to a PLB2DCR bridge.
* XPAR_TFT_USE_DCR_BRIDGE must be defined in xparameters.h or as a compiler
* option used in the Makefile BEFORE this driver is compiled.
* This constant should not be defined if the Control Register Interface of
* the TFT core is connected driectly to a DCR bus or a PLB bus - The driver
* takes care of this.
*
****************************************************************************/
void XTft_WriteReg(XTft* InstancePtr, u32 RegOffset, u32 Data)
{
	/*
	 * Assert validates the input arguments.
	 */
	XASSERT_VOID(InstancePtr != NULL);
	XASSERT_VOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);

	/*
	 * To check if the TFT controller is accessed through DCR bus
	 * directly or PLB bus directly.
	 */
	if (InstancePtr->TftConfig.PlbAccess) {
		/*
		 * Write to Register.
		 */
		XIo_Out32(InstancePtr->TftConfig.BaseAddress +
					RegOffset, Data);
	} else {
#ifdef XPAR_TFT_USE_DCR_BRIDGE
		/*
		 * Write to Register.
		 */
		XIo_Out32(InstancePtr->TftConfig.DcrBaseAddr +
					RegOffset, Data);
#else
		/*
		 * Write to Register.
		 */
#ifdef __PPC__
		XIo_DcrOut((InstancePtr->TftConfig.DcrBaseAddr +
			(RegOffset >> XTFT_DCR_REG_SHIFT)) & 0xFFF, Data);
#endif /*__PPC__*/
#endif /* XPAR_TFT_USE_DCR_BRIDGE */
	}

}

/***************************************************************************/
/**
*
* Read a value from a TFT register. A 32 bit read is performed.
*
* @param	InstancePtr is a pointer to the XTft instance.
* @param	RegOffset is the register offset from the base to read from.
*
* @return	Data read from the register.
*
* @note
*
* The constant XPAR_TFT_USE_DCR_BRIDGE is used to inform the driver that
* the Control Register Interface of the TFT device is on a DCR BUS connected
* to a PLB2DCR bridge.
* XPAR_TFT_USE_DCR_BRIDGE must be defined in xparameters.h or as a compiler
* option used in the Makefile BEFORE this driver is compiled.
* This constant should not be defined if the Control Register Interface of
* the TFT core is connected directly to a DCR bus or a PLB bus - The driver
* takes care of this.
*
****************************************************************************/
u32 XTft_ReadReg(XTft* InstancePtr, u32 RegOffset)
{
	u32 Data = 0;
	/*
	 * Assert validates the input arguments.
	 */
	XASSERT_NONVOID(InstancePtr != NULL);
	XASSERT_NONVOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);

	/*
	 * To check if the TFT controller is accessed through DCR bus
	 * directly or PLB bus directly.
	 */
	if (InstancePtr->TftConfig.PlbAccess) {
		/*
		 * Read the Register.
		 */
		Data = XIo_In32(InstancePtr->TftConfig.BaseAddress +
					RegOffset);

	} else {
#ifdef XPAR_TFT_USE_DCR_BRIDGE
		/*
		 * Read the Register.
		 */
		Data = XIo_In32(InstancePtr->TftConfig.DcrBaseAddr +
					RegOffset);
#else
		/*
		 * Read the Register.
		 */
#ifdef __PPC__
		Data = XIo_DcrIn((InstancePtr->TftConfig.DcrBaseAddr +
			(RegOffset >> XTFT_DCR_REG_SHIFT)) & 0xFFF);
#endif /*__PPC__*/
#endif /* XPAR_TFT_USE_DCR_BRIDGE */
	}
	return Data;

}

/***************************************************************************/
/**
*
* This function writes a particular character onto the screen using
* the character bitmap values.
*
* @param	InstancePtr is a pointer to the XTft instance.
* @param	CharValue is the value of the ASCII character.
* @param	ColStartVal is the value of the starting column. The valid
*		values are 0 to (XTFT_DISPLAY_WIDTH - 1).
* @param	RowStartVal is the value of the starting row. The valid
*		values are 0 to (XTFT_DISPLAY_HEIGHT - 1).
* @param	FgColor is the value with which the pixels will be filled
*		to highlight the character.
* @param	BgColor is the value with which the pixels will be filled
*		with a different color from foreground.
*
* @return	None.
*
* @note		It must be taken care that the ASCII character which is to
*		be written has value greater than 31 as character bitmap
*		array starts with space as its first character.
*
****************************************************************************/
static void XTft_WriteChar(XTft* InstancePtr,
			u8 CharValue,
			u32 ColStartVal,
			u32 RowStartVal,
			u32 FgColor,
			u32 BgColor)
{
	u32 PixelVal;
	u32 ColIndex;
	u32 RowIndex;
	u8 BitMapVal;

	/*
	 * Assert validates the input arguments.
	 */
	XASSERT_VOID(InstancePtr != NULL);
	XASSERT_VOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);
	XASSERT_VOID(ColStartVal <= (XTFT_DISPLAY_WIDTH - 1) &&
					ColStartVal >= 0);
	XASSERT_VOID(RowStartVal <= (XTFT_DISPLAY_HEIGHT - 1) &&
					RowStartVal >= 0);

	/*
	 * Checks whether the given character value is more than or equal to
	 * space character value, as our character array starts with space.
	 */
	XASSERT_VOID((u32) CharValue >= XTFT_ASCIICHAR_OFFSET);

	/*
	 * Gets the 12 bit value from the character array defined in
	 * charcode.c file and regenerates the bitmap of that character.
	 * It draws that character on screen by setting the pixel either
	 * with the foreground or background color depending on
	 * whether value is 1 or 0.
	 */
	for (RowIndex = 0; RowIndex < XTFT_CHAR_HEIGHT; RowIndex++) {
		BitMapVal = XTft_VidChars[(u32) CharValue -
					XTFT_ASCIICHAR_OFFSET][RowIndex];
		for (ColIndex = 0; ColIndex < XTFT_CHAR_WIDTH; ColIndex++) {
			if (BitMapVal &
				(1 << (XTFT_CHAR_WIDTH - ColIndex - 1))) {
				PixelVal = FgColor;
			} else {
				PixelVal = BgColor;
			}

			/*
			 * Sets the color value to pixel.
			 */
			XTft_SetPixel(InstancePtr, ColStartVal+ColIndex,
					RowStartVal+RowIndex, PixelVal);
		}
	}

}

/***************************************************************************/
/**
*
* This function enables the Vsync Interrupt in the Interrupt Enable and Status
* Register.
*
* @param	InstancePtr is a pointer to the XTft instance.
*
* @return	None.
*
* @note		None.
*
****************************************************************************/
void XTft_IntrEnable(XTft* InstancePtr)
{
	u32 RegValue;

	/*
	 * Assert validates the input arguments.
	 */
	XASSERT_VOID(InstancePtr != NULL);
	XASSERT_VOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);

	/*
	 * Enable interrupts by setting interrupt enable bit.
	 */
	RegValue = XTft_ReadReg(InstancePtr, XTFT_IESR_OFFSET);
	XTft_WriteReg(InstancePtr, XTFT_IESR_OFFSET, RegValue |
			XTFT_IESR_IE_MASK);

}
/***************************************************************************/
/**
*
* This function disables the Vsync Interrupt in the Interrupt Enable and Status
* Register.
*
* @param	InstancePtr is a pointer to the XTft instance.
*
* @return	None.
*
* @note		None.
*
****************************************************************************/
void XTft_IntrDisable(XTft* InstancePtr)
{
	u32 RegValue;

	/*
	 * Assert validates the input arguments.
	 */
	XASSERT_VOID(InstancePtr != NULL);
	XASSERT_VOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);

	/*
	 * Disable interrupts by clearing interrupt enable bit.
	 */
	RegValue = XTft_ReadReg(InstancePtr, XTFT_IESR_OFFSET);
	XTft_WriteReg(InstancePtr, XTFT_IESR_OFFSET,
				RegValue & (~XTFT_IESR_IE_MASK));

}

/***************************************************************************/
/**
*
* This function gets the Vsync(Video address latch) status from the Interrupt
* Enable and Status Register.
*
* @param	InstancePtr is a pointer to the XTft instance.
*
* @return
*		- TRUE if Vsync pulse has occurred after displaying the
*		  current frame.
*		- FALSE if the TFT core has not completed displaying the
*		  current frame.
*
* @note		Vsync(Video address latch) Status bit will be cleared by the HW
*		after it loads the address from the Address Register and starts
*		displaying the Frame.
*
****************************************************************************/
int XTft_GetVsyncStatus(XTft* InstancePtr)
{
	/*
	 * Assert validates the input arguments.
	 */
	XASSERT_NONVOID(InstancePtr != NULL);
	XASSERT_NONVOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);

	/*
	 * Read the contents of Interrupt Enable and Status Register.
	 */
	return((XTft_ReadReg(InstancePtr, XTFT_IESR_OFFSET) &
		XTFT_IESR_VADDRLATCH_STATUS_MASK)? TRUE : FALSE);
}
