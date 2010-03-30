/* $Id: xps2_intr.c,v 1.1 2008/08/27 10:45:27 sadanan Exp $ */
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
*       (c) Copyright 2008 Xilinx Inc.
*       All rights reserved.
*
*****************************************************************************/
/****************************************************************************/
/**
*
* @file xps2_intr.c
*
* This file contains the functions that are related to interrupt processing
* for the PS/2 driver.
*
* <pre>
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

extern u32 XPs2_SendBuffer(XPs2 *InstancePtr);
extern u32 XPs2_ReceiveBuffer(XPs2 *InstancePtr);

/****************************************************************************/
/**
*
* This function sets the handler that will be called when an interrupt
* occurs in the driver. The purpose of the handler is to allow application
* specific processing to be performed.
*
* @param	InstancePtr is a pointer to the XPs2 instance to be worked on.
* @param	FuncPtr is the pointer to the callback function.
* @param	CallBackRef is the upper layer callback reference passed back
*		when the callback function is invoked.
*
* @return	None.
*
* @note
*
* There is no assert on the CallBackRef since the driver doesn't know what it
* is (nor should it)
*
*****************************************************************************/
void XPs2_SetHandler(XPs2 *InstancePtr, XPs2_Handler FuncPtr,
					 void *CallBackRef)
{
	/*
	 * Assert validates the input arguments
	 * CallBackRef not checked, no way to know what is valid
	 */
	XASSERT_VOID(InstancePtr != NULL);
	XASSERT_VOID(FuncPtr != NULL);
	XASSERT_VOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);

	InstancePtr->Handler = FuncPtr;
	InstancePtr->CallBackRef = CallBackRef;
}

/****************************************************************************/
/**
*
* This function is the interrupt handler for the PS/2 driver.
* It must be connected to an interrupt system by the user such that it is
* called when an interrupt for any PS/2 port occurs. This function does
* not save or restore the processor context such that the user must
* ensure this occurs.
*
* @param	InstancePtr contains a pointer to the instance of the PS/2 port
*		that the interrupt is for.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
void XPs2_IntrHandler(XPs2 *InstancePtr)
{
	u32 IntrStatus;

	XASSERT_VOID(InstancePtr != NULL);

	/*
	 * Read the interrupt status register to determine which
	 * interrupt is active.
	 */
	IntrStatus = XPs2_IntrGetStatus(InstancePtr);

	if (IntrStatus & (XPS2_IPIXR_RX_ERR | XPS2_IPIXR_RX_OVF)) {

		/*
		 * Call the application handler with the error code
		 */
		InstancePtr->Handler(InstancePtr->CallBackRef,
			IntrStatus & (XPS2_IPIXR_RX_ERR | XPS2_IPIXR_RX_OVF),
			InstancePtr->ReceiveBuffer.RequestedBytes -
			InstancePtr->ReceiveBuffer.RemainingBytes);
	}


	if (IntrStatus & (XPS2_IPIXR_TX_NOACK | XPS2_IPIXR_WDT_TOUT)) {

		/*
		 * Call the application handler with the error code
		 */
		InstancePtr->Handler(InstancePtr->CallBackRef,
			IntrStatus & (XPS2_IPIXR_TX_NOACK |
					XPS2_IPIXR_WDT_TOUT),
			InstancePtr->SendBuffer.RequestedBytes -
			InstancePtr->SendBuffer.RemainingBytes);
	}

	if (IntrStatus & XPS2_IPIXR_RX_FULL) {

		/*
		 * If there are bytes still to be received in the specified
		 * buffer go ahead and receive them
		 */
		if (InstancePtr->ReceiveBuffer.RemainingBytes != 0) {
				XPs2_ReceiveBuffer(InstancePtr);
		}

		/*
		 * If the last byte of a message was received then call the
		 * application handler, this code should not use an else from
		 * the previous check of the number of bytes to receive because
		 * the call to receive the buffer updates the bytes to receive
		 */
		if (InstancePtr->ReceiveBuffer.RemainingBytes == 0) {
				InstancePtr->Handler(InstancePtr->CallBackRef,
				    XPS2_IPIXR_RX_FULL,
				    InstancePtr->ReceiveBuffer.RequestedBytes -
				    InstancePtr->ReceiveBuffer.RemainingBytes);
		}
	}

	if (IntrStatus & XPS2_IPIXR_TX_ACK) {

		/*
		 * If there are no bytes to be sent from the specified buffer
		 * then disable the transmit interrupt
		 */
		if (InstancePtr->SendBuffer.RemainingBytes == 0) {
			XPs2_IntrDisable(InstancePtr, XPS2_IPIXR_TX_ACK);

		/*
		 * Call the application handler to indicate the data has been
		 * sent
		 */
		InstancePtr->Handler(InstancePtr->CallBackRef,
					XPS2_IPIXR_TX_ACK,
					InstancePtr->SendBuffer.RequestedBytes -
					InstancePtr->SendBuffer.RemainingBytes);
		}

		/*
		 * Otherwise there is still more data to send in the specified
		 * buffer so go ahead and send it
		 */
		else {
			XPs2_SendBuffer(InstancePtr);
		}

	}

	/*
	 * Clear the Interrupt Status Register
	 */
	XPs2_IntrClear(InstancePtr, IntrStatus);

}

