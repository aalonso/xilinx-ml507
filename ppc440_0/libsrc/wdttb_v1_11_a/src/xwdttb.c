/* $Id: xwdttb.c,v 1.1 2008/08/27 12:42:16 sadanan Exp $ */
/*****************************************************************************
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
*       (c) Copyright 2002-2007 Xilinx Inc.
*       All rights reserved.
*
*****************************************************************************/
/****************************************************************************/
/**
*
* @file xwdttb.c
*
* Contains the required functions of the XWdtTb driver component. See
* xwdttb.h for a description of the driver.
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- -----------------------------------------------
* 1.00a ecm  08/16/01 First release
* 1.00b jhl  02/21/02 Repartitioned the driver for smaller files
* 1.00b rpm  04/26/02 Made LookupConfig public
* 1.10b mta  03/23/07 Updated to new coding style
* </pre>
*
******************************************************************************/

/***************************** Include Files *********************************/

#include "xbasic_types.h"
#include "xparameters.h"
#include "xio.h"
#include "xwdttb.h"


/************************** Constant Definitions *****************************/


/**************************** Type Definitions *******************************/


/***************** Macros (Inline Functions) Definitions *********************/


/************************** Function Prototypes ******************************/


/************************** Variable Definitions *****************************/

extern XWdtTb_Config XWdtTb_ConfigTable[];

/****************************************************************************/
/**
*
* Initialize a specific watchdog timer/timebase instance/driver. This function
* must be called before other functions of the driver are called.
*
* @param	InstancePtr is a pointer to the XWdtTb instance to be worked on.
* @param	DeviceId is the unique id of the device controlled by this
*		XWdtTb instance. Passing in a device id associates the generic
*		XWdtTb instance to a specific device, as chosen by the caller or
*		application developer.
*
* @return
* 		- XST_SUCCESS if initialization was successful
* 		- XST_DEVICE_IS_STARTED if the device has already been started
* 		- XST_DEVICE_NOT_FOUND if the configuration for device ID was
*		not found
*
* @note		None.
*
******************************************************************************/
int XWdtTb_Initialize(XWdtTb * InstancePtr, u16 DeviceId)
{
	XWdtTb_Config *ConfigPtr;

	XASSERT_NONVOID(InstancePtr != NULL);

	/*
	 * If the device is started, disallow the initialize and return a status
	 * indicating it is started.  This allows the user to stop the device
	 * and reinitialize, but prevents a user from inadvertently initializing
	 */
	if (InstancePtr->IsStarted == XCOMPONENT_IS_STARTED) {
		return XST_DEVICE_IS_STARTED;
	}

	/*
	 * Lookup the device configuration Use this info below when initializing
	 * this component.
	 */
	ConfigPtr = XWdtTb_LookupConfig(DeviceId);
	if (ConfigPtr == NULL) {
		return XST_DEVICE_NOT_FOUND;
	}

	/* save the base address pointer such that the registers of the block
	 * can be accessed and indicate it has not been started yet
	 */
	InstancePtr->RegBaseAddress = ConfigPtr->BaseAddr;
	InstancePtr->IsStarted = 0;

	/*
	 * Indicate the instance is ready to use, successfully initialized
	 */
	InstancePtr->IsReady = XCOMPONENT_IS_READY;

	return XST_SUCCESS;
}

/****************************************************************************/
/**
*
* Start the watchdog timer of the device.
*
* @param	InstancePtr is a pointer to the XWdtTb instance to be worked on.
*
* @return	None.
*
* @note		The Timebase is reset to 0 when the Watchdog Timer is started.
*		The Timebase is always incrementing
*
******************************************************************************/
void XWdtTb_Start(XWdtTb * InstancePtr)
{
	u32 ControlStatusRegister0;

	XASSERT_VOID(InstancePtr != NULL);
	XASSERT_VOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);

	/*
	 * Read the current contents of TCSR0 so that subsequent writes to the
	 * register won't destroy any other bits
	 */
	ControlStatusRegister0 = XIo_In32(InstancePtr->RegBaseAddress +
					  XWT_TWCSR0_OFFSET);
	/*
	 * Clear the bit that indicates the reason for the last
	 * system reset, WRS and the WDS bit, if set, by writing
	 * 1's to TCSR0
	 */
	ControlStatusRegister0 |= (XWT_CSR0_WRS_MASK | XWT_CSR0_WDS_MASK);

	/*
	 * Indicate that the device is started before we enable it
	 */
	InstancePtr->IsStarted = XCOMPONENT_IS_STARTED;

	/*
	 * Set the registers to enable the watchdog timer, both enable bits
	 * in TCSR0 and TCSR1 need to be set to enable it
	 */
	XIo_Out32(InstancePtr->RegBaseAddress + XWT_TWCSR0_OFFSET,
		  (ControlStatusRegister0 | XWT_CSR0_EWDT1_MASK));

	XIo_Out32(InstancePtr->RegBaseAddress + XWT_TWCSR1_OFFSET,
		  XWT_CSRX_EWDT2_MASK);

}

/****************************************************************************/
/**
*
* Disable the watchdog timer.
*
* It is the caller's responsibility to disconnect the interrupt handler
* of the watchdog timer from the interrupt source, typically an interrupt
* controller, and disable the interrupt in the interrupt controller.
*
* @param	InstancePtr is a pointer to the XWdtTb instance to be worked on.
*
* @return
* 		- XST_SUCCESS if the watchdog was stopped successfully
* 		- XST_NO_FEATURE if the watchdog cannot be stopped
*
* @note
*
* The hardware configuration controls this functionality. If it is not
* allowed by the hardware the failure will be returned and the timer
* will continue without interruption.
*
******************************************************************************/
int XWdtTb_Stop(XWdtTb * InstancePtr)
{
	u32 ControlStatusRegister0;

	XASSERT_NONVOID(InstancePtr != NULL);
	XASSERT_NONVOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);

	/*
	 * Check if the disable of the watchdog timer is possible by writing a 0
	 * to TCSR1 to clear the 2nd enable. If the Enable does not clear in
	 * TCSR0, the watchdog cannot be disabled. Return a NO_FEATURE to
	 * indicate this.
	 */
	XIo_Out32(InstancePtr->RegBaseAddress + XWT_TWCSR1_OFFSET, 0);

	/*
	 * Read the contents of TCSR0 so that the writes to the register
	 * that follow are not destructive to other bits and to check if
	 * the second enable was set to zero
	 */
	ControlStatusRegister0 =
		XIo_In32(InstancePtr->RegBaseAddress + XWT_TWCSR0_OFFSET);

	/*
	 * If the second enable was not set to zero, the feature is not
	 * allowed in the hardware. Return with NO_FEATURE status
	 */
	if ((ControlStatusRegister0 & XWT_CSRX_EWDT2_MASK) != 0) {
		return XST_NO_FEATURE;
	}

	/*
	 * Disable the watchdog timer by performing 2 writes, 1st to
	 * TCSR0 to clear the enable 1 and then to TCSR1 to clear the 2nd enable
	 */
	XIo_Out32(InstancePtr->RegBaseAddress + XWT_TWCSR0_OFFSET,
		  (ControlStatusRegister0 & ~XWT_CSR0_EWDT1_MASK));

	XIo_Out32(InstancePtr->RegBaseAddress + XWT_TWCSR1_OFFSET, 0);


	InstancePtr->IsStarted = 0;

	return XST_SUCCESS;
}

/****************************************************************************/
/**
*
* Check if the watchdog timer has expired. This function is used for polled
* mode and it is also used to check if the last reset was caused by the
* watchdog timer.
*
* @param	InstancePtr is a pointer to the XWdtTb instance to be worked on.
*
* @return	TRUE if the watchdog has expired, and FALSE otherwise.
*
* @note		None.
*
******************************************************************************/
int XWdtTb_IsWdtExpired(XWdtTb * InstancePtr)
{
	u32 ControlStatusRegister0;
	u32 Mask;

	XASSERT_NONVOID(InstancePtr != NULL);
	XASSERT_NONVOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);

	/*
	 * Read the current contents
	 */
	ControlStatusRegister0 = XIo_In32(InstancePtr->RegBaseAddress +
					  XWT_TWCSR0_OFFSET);
	/*
	 * The watchdog has expired if either of the bits are set
	 */
	Mask = XWT_CSR0_WRS_MASK | XWT_CSR0_WDS_MASK;

	return ((ControlStatusRegister0 & Mask) != 0);
}

/****************************************************************************/
/**
*
* Restart the watchdog timer. An application needs to call this function
* periodically to keep the timer from asserting the reset output.
*
* @param	InstancePtr is a pointer to the XWdtTb instance to be worked on.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
void XWdtTb_RestartWdt(XWdtTb * InstancePtr)
{
	u32 ControlStatusRegister0;

	XASSERT_VOID(InstancePtr != NULL);
	XASSERT_VOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);

	/*
	 * Read the current contents of TCSR0 so that subsequent writes won't
	 * destroy any other bits
	 */
	ControlStatusRegister0 = XIo_In32(InstancePtr->RegBaseAddress +
					  XWT_TWCSR0_OFFSET);
	/*
	 * Clear the bit that indicates the reason for the last
	 * system reset, WRS and the WDS bit, if set, by writing
	 * 1's to TCSR0
	 */
	ControlStatusRegister0 |= (XWT_CSR0_WRS_MASK | XWT_CSR0_WDS_MASK);

	XIo_Out32(InstancePtr->RegBaseAddress + XWT_TWCSR0_OFFSET,
		  ControlStatusRegister0);
}

/****************************************************************************/
/**
*
* Returns the current contents of the timebase.
*
* @param	InstancePtr is a pointer to the XWdtTb instance to be worked on.
*
* @return	The contents of the timebase.
*
* @note		None.
*
******************************************************************************/
u32 XWdtTb_GetTbValue(XWdtTb * InstancePtr)
{
	u32 CurrentTBR;

	XASSERT_NONVOID(InstancePtr != NULL);
	XASSERT_NONVOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);

	/*
	 * Return the contents of the timebase register
	 */
	CurrentTBR = XIo_In32(InstancePtr->RegBaseAddress + XWT_TBR_OFFSET);

	return CurrentTBR;
}

/****************************************************************************
*
* Lookup the device configuration based on the unique device ID.
*
* @param	DeviceId The unique device ID to search on in the configuration
*		table.
*
* @return	A pointer to the configuration data for the given device, or
*		NULL if no match is found.
*
* @note		None.
*
******************************************************************************/
XWdtTb_Config *XWdtTb_LookupConfig(u16 DeviceId)
{
	XWdtTb_Config *CfgPtr = NULL;
	int i;

	for (i = 0; i < XPAR_XWDTTB_NUM_INSTANCES; i++) {
		if (XWdtTb_ConfigTable[i].DeviceId == DeviceId) {
			CfgPtr = &XWdtTb_ConfigTable[i];
			break;
		}
	}

	return CfgPtr;
}
