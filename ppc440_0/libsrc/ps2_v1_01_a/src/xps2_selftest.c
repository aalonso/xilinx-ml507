/* $Id: xps2_selftest.c,v 1.1 2008/08/27 10:45:27 sadanan Exp $ */
/******************************************************************************
*
*       XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"
*       AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND
*       SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE,
*       OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,
*       APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION
*       THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,
*       AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE
*       FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY
*       WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE
*       IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR
*       REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF
*       INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
*       FOR A PARTICULAR PURPOSE.
*
*       (c) Copyright 2008 Xilinx Inc.
*       All rights reserved.
*
******************************************************************************/
/*****************************************************************************/
/**
*
* @file xps2_selftest.c
*
* This file contains a diagnostic self test function for the XPs2 driver.
*
* See xps2.h for more information.
*
* @note	None.
*
* <pre>
*
* MODIFICATION HISTORY:
*
* Ver   Who      Date     Changes
* ----- ------   -------- -----------------------------------------------
* 1.00a sv/sdm   01/25/08 First release
*
* </pre>
*
*****************************************************************************/

/***************************** Include Files ********************************/

#include "xps2.h"

/************************** Constant Definitions ****************************/

/**************************** Type Definitions ******************************/

/***************** Macros (Inline Functions) Definitions ********************/

/************************** Variable Definitions ****************************/

/************************** Function Prototypes *****************************/

/*****************************************************************************/
/**
*
* Run a self-test on the driver/device. The test
*	- Writes a value into the Interrupt Enable register and reads it back
*	for comparison.
*
* @param	InstancePtr is a pointer to the XPs2 instance.
*
* @return
*		- XST_SUCCESS if the value read from the Interrupt Enable
*		register is the same as the value written.
*		- XST_FAILURE otherwise
*
* @note		None.
*
******************************************************************************/
int XPs2_SelfTest(XPs2 *InstancePtr)
{
	int Status = XST_SUCCESS;
	u32 IeRegister;
	u32 GieRegister;

	/*
	 * Assert the argument
	 */
	XASSERT_NONVOID(InstancePtr != NULL);
	XASSERT_NONVOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);


	/*
	 * Save a copy of the Global Interrupt Enable register
	 * and Interrupt Enable register before writing them so
	 * that they can be restored.
	 */
	GieRegister = XPs2_ReadReg(InstancePtr->Ps2Config.BaseAddress,
					XPS2_GIER_OFFSET);
	IeRegister = XPs2_IntrGetEnabled(InstancePtr);

	/*
	 * Disable the Global Interrupt so that enabling the interrupts
	 * won't affect the user.
	 */
	XPs2_IntrGlobalDisable(InstancePtr);

	/*
	 * Enable the Transmit interrupts and then verify that the
	 * register reads back correctly.
	 */
	XPs2_WriteReg(InstancePtr->Ps2Config.BaseAddress,
				XPS2_IPIER_OFFSET, XPS2_IPIXR_TX_ALL);
	if (XPs2_ReadReg(InstancePtr->Ps2Config.BaseAddress,
					XPS2_IPIER_OFFSET) !=
			   		XPS2_IPIXR_TX_ALL) {
		Status = XST_FAILURE;
	}

	/*
	 * Restore the IP Interrupt Enable Register to the value before
	 * the test.
	 */
	XPs2_WriteReg(InstancePtr->Ps2Config.BaseAddress,
			XPS2_IPIER_OFFSET, IeRegister);

	/*
	 * Restore the Global Interrupt Register to the value before the
	 * test.
	 */
	XPs2_WriteReg(InstancePtr->Ps2Config.BaseAddress,
				XPS2_GIER_OFFSET, GieRegister);

	/*
	 * Return the test result.
	 */
	return Status;
}
