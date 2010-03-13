/* $Id: xuartns550_intr.c,v 1.1.4.1 2009/07/14 07:13:56 svemula Exp $ */
/******************************************************************************
*
* (c) Copyright 2002-2009 Xilinx, Inc. All rights reserved.
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
/****************************************************************************/
/**
*
* @file xuartns550_intr.c
*
* This file contains the functions that are related to interrupt processing
* for the 16450/16550 UART driver.
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- -----------------------------------------------
* 1.00b jhl  03/11/02 Repartitioned driver for smaller files.
* 1.11a sv   03/20/07 Updated to use the new coding guidelines.
* </pre>
*
*****************************************************************************/

/***************************** Include Files ********************************/

#include "xuartns550.h"
#include "xuartns550_i.h"
#include "xio.h"

/************************** Constant Definitions ****************************/

/**************************** Type Definitions ******************************/

/***************** Macros (Inline Functions) Definitions ********************/

/************************** Function Prototypes *****************************/

static void NoInterruptHandler(XUartNs550 *InstancePtr);
static void ReceiveStatusHandler(XUartNs550 *InstancePtr);
static void ReceiveTimeoutHandler(XUartNs550 *InstancePtr);
static void ReceiveDataHandler(XUartNs550 *InstancePtr);
static void SendDataHandler(XUartNs550 *InstancePtr);
static void ModemHandler(XUartNs550 *InstancePtr);

/************************** Variable Definitions ****************************/

typedef void (*Handler)(XUartNs550 *InstancePtr);

/* The following tables is a function pointer table that contains pointers
 * to each of the handlers for specific kinds of interrupts. The table is
 * indexed by the value read from the interrupt ID register.
 */
static Handler HandlerTable[13] = {
	ModemHandler,		/* 0 */
	NoInterruptHandler,	/* 1 */
	SendDataHandler,	/* 2 */
	NULL,			/* 3 */
	ReceiveDataHandler,	/* 4 */
	NULL,			/* 5 */
	ReceiveStatusHandler,	/* 6 */
	NULL,			/* 7 */
	NULL,			/* 8 */
	NULL,			/* 9 */
	NULL,			/* 10 */
	NULL,			/* 11 */
	ReceiveTimeoutHandler	/* 12 */
};

/****************************************************************************/
/**
*
* This function sets the handler that will be called when an event (interrupt)
* occurs in the driver. The purpose of the handler is to allow application
* specific processing to be performed.
*
* @param	InstancePtr is a pointer to the XUartNs550 instance .
* @param	FuncPtr is the pointer to the callback function.
* @param	CallBackRef is the upper layer callback reference passed back
*		when the callback function is invoked.
*
* @return	None.
*
* @notes
*
* There is no assert on the CallBackRef since the driver doesn't know what it
* is (nor should it)
*
*****************************************************************************/
void XUartNs550_SetHandler(XUartNs550 *InstancePtr,
				XUartNs550_Handler FuncPtr, void *CallBackRef)
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
* This function is the interrupt handler for the 16450/16550 UART driver.
* It must be connected to an interrupt system by the user such that it is
* called when an interrupt for any 16450/16550 UART occurs. This function
* does not save or restore the processor context such that the user must
* ensure this occurs.
*
* @param	InstancePtr contains a pointer to the instance of the UART that
*		the interrupt is for.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
void XUartNs550_InterruptHandler(XUartNs550 *InstancePtr)
{
	u8 IsrStatus;

	XASSERT_VOID(InstancePtr != NULL);

	/*
	 * Read the interrupt ID register to determine which, only one,
	 * interrupt is active
	 */
	IsrStatus = XIo_In8(InstancePtr->BaseAddress + XUN_IIR_OFFSET) &
						XUN_INT_ID_MASK;

	/*
	 * Make sure the handler table has a handler defined for the interrupt
	 * that is active, and then call the handler
	 */
	XASSERT_VOID(HandlerTable[IsrStatus] != NULL);

	HandlerTable[IsrStatus](InstancePtr);
}

/****************************************************************************/
/**
*
* This function handles the case when the value read from the interrupt ID
* register indicates no interrupt is to be serviced.
*
* @param	InstancePtr is a pointer to the XUartNs550 instance .
*
* @return	None.
*
* @note		None.
*
* @internal
*
* The LsrRegister is volatile to ensure that optimization will not cause the
* statement to be optimized away.
*
*****************************************************************************/
static void NoInterruptHandler(XUartNs550 *InstancePtr)
{
	volatile u8 LsrRegister;

	/*
	 * Reading the ID register clears the currently asserted interrupts
	 */
	LsrRegister = XIo_In8(InstancePtr->BaseAddress + XUN_LSR_OFFSET);

	/*
	 * Update the stats to reflect any errors that might be read
	 */
	XUartNs550_mUpdateStats(InstancePtr, LsrRegister);
}

/****************************************************************************/
/**
*
* This function handles interrupts for receive status updates which include
* overrun errors, framing errors, parity errors, and the break interrupt.
*
* @param	InstancePtr is a pointer to the XUartNs550 instance.
*
* @return	None.
*
* @note
*
* If this handler executes and data is not supposed to be received, then
* this probably means data is being received that contains errors and the
* the user may need to clear the receive FIFOs to dump the data.
*
*****************************************************************************/
static void ReceiveStatusHandler(XUartNs550 *InstancePtr)
{
	u8 LsrRegister;

	/*
	 * If there are bytes still to be received in the specified buffer
	 * go ahead and receive them
	 */
	if (InstancePtr->ReceiveBuffer.RemainingBytes != 0) {
		XUartNs550_ReceiveBuffer(InstancePtr);
	} else {
		/*
		 * Reading the ID register clears the currently asserted
		 * interrupts and this must be done since there was no data
		 * to receive, update the status for the status read
		 */
		LsrRegister = XIo_In8(InstancePtr->BaseAddress +
		XUN_LSR_OFFSET);
		XUartNs550_mUpdateStats(InstancePtr, LsrRegister);
	}

	/*
	 * Call the application handler to indicate that there is a receive
	 * error or a break interrupt, if the application cares about the
	 * error it call a function to get the last errors
	 */
	InstancePtr->Handler(InstancePtr->CallBackRef, XUN_EVENT_RECV_ERROR,
				InstancePtr->ReceiveBuffer.RequestedBytes -
				InstancePtr->ReceiveBuffer.RemainingBytes);

	/*
	 * Update the receive stats to reflect the receive interrupt
	 */
	InstancePtr->Stats.StatusInterrupts++;
}
/****************************************************************************/
/**
*
* This function handles the receive timeout interrupt. This interrupt occurs
* whenever a number of bytes have been present in the FIFO for 4 character
* times, the receiver is not receiving any data, and the number of bytes
* present is less than the FIFO threshold.
*
* @param	InstancePtr is a pointer to the XUartNs550 instance .
*
* @return	None.
*
* @note		None.
*
*****************************************************************************/
static void ReceiveTimeoutHandler(XUartNs550 *InstancePtr)
{
	u32 Event;

	/*
	 * If there are bytes still to be received in the specified buffer
	 * go ahead and receive them
	 */
	if (InstancePtr->ReceiveBuffer.RemainingBytes != 0) {
		XUartNs550_ReceiveBuffer(InstancePtr);
	}

	/*
	 * If there are no more bytes to receive then indicate that this is
	 * not a receive timeout but the end of the buffer reached, a timeout
	 * normally occurs if # of bytes is not divisible by FIFO threshold,
	 * don't rely on previous test of remaining bytes since receive function
	 * updates it
	 */
	if (InstancePtr->ReceiveBuffer.RemainingBytes != 0) {
		Event = XUN_EVENT_RECV_TIMEOUT;
	} else {
		Event = XUN_EVENT_RECV_DATA;
	}

	/*
	 * Call the application handler to indicate that there is a receive
	 * timeout or data event
	 */
	InstancePtr->Handler(InstancePtr->CallBackRef, Event,
			 InstancePtr->ReceiveBuffer.RequestedBytes -
			 InstancePtr->ReceiveBuffer.RemainingBytes);

	/*
	 * Update the receive stats to reflect the receive interrupt
	 */
	InstancePtr->Stats.ReceiveInterrupts++;
}
/****************************************************************************/
/**
*
* This function handles the interrupt when data is received, either a single
* byte when FIFOs are not enabled, or multiple bytes with the FIFO.
*
* @param	InstancePtr is a pointer to the XUartNs550 instance.
*
* @return	None.
*
* @note		None.
*
*****************************************************************************/
static void ReceiveDataHandler(XUartNs550 *InstancePtr)
{
	/*
	 * If there are bytes still to be received in the specified buffer
	 * go ahead and receive them
	 */
	if (InstancePtr->ReceiveBuffer.RemainingBytes != 0) {
		XUartNs550_ReceiveBuffer(InstancePtr);
	}

	/*
	 * If the last byte of a message was received then call the application
	 * handler, this code should not use an else from the previous check of
	 * the number of bytes to receive because the call to receive the buffer
	 * updates the bytes to receive
	 */
	if (InstancePtr->ReceiveBuffer.RemainingBytes == 0) {
		InstancePtr->Handler(InstancePtr->CallBackRef,
				XUN_EVENT_RECV_DATA,
				InstancePtr->ReceiveBuffer.RequestedBytes -
				InstancePtr->ReceiveBuffer.RemainingBytes);
	}

	/*
	 * Update the receive stats to reflect the receive interrupt
	 */
	InstancePtr->Stats.ReceiveInterrupts++;
}

/****************************************************************************/
/**
*
* This function handles the interrupt when data has been sent, the transmit
* FIFO is empty (transmitter holding register).
*
* @param	InstancePtr is a pointer to the XUartNs550 instance.
*
* @return	None.
*
* @note		None.
*
*****************************************************************************/
static void SendDataHandler(XUartNs550 *InstancePtr)
{
	u8 IerRegister;

	/*
	 * If there are not bytes to be sent from the specified buffer then
	 * disable the transmit interrupt so it will stop interrupting as it
	 * interrupts any time the FIFO is empty
	 */
	if (InstancePtr->SendBuffer.RemainingBytes == 0) {
		IerRegister = XIo_In8(InstancePtr->BaseAddress +
		XUN_IER_OFFSET);
		XIo_Out8(InstancePtr->BaseAddress + XUN_IER_OFFSET,
				 IerRegister & ~XUN_IER_TX_EMPTY);

		/*
		 * Call the application handler to indicate the data
		 * has been sent
		 */
		InstancePtr->Handler(InstancePtr->CallBackRef,
				XUN_EVENT_SENT_DATA,
				InstancePtr->SendBuffer.RequestedBytes -
				InstancePtr->SendBuffer.RemainingBytes);
	}

	/*
	 * Otherwise there is still more data to send in the specified buffer
	 * so go ahead and send it
	 */
	else {
		XUartNs550_SendBuffer(InstancePtr);
	}

	/*
	 * Update the transmit stats to reflect the transmit interrupt
	 */
	InstancePtr->Stats.TransmitInterrupts++;
}

/****************************************************************************/
/**
*
* This function handles modem interrupts. It does not do any processing
* except to call the application handler to indicate a modem event.
*
* @param	InstancePtr is a pointer to the XUartNs550 instance.
*
* @return	None.
*
* @note		None.
*
*****************************************************************************/
static void ModemHandler(XUartNs550 *InstancePtr)
{
	u8 MsrRegister;

	/*
	 * Read the modem status register so that the interrupt is acknowledged
	 * and so that it can be passed to the callback handler with the event
	 */
	MsrRegister = XIo_In8(InstancePtr->BaseAddress + XUN_MSR_OFFSET);

	/*
	 * Call the application handler to indicate the modem status changed,
	 * passing the modem status and the event data in the call
	 */
	InstancePtr->Handler(InstancePtr->CallBackRef, XUN_EVENT_MODEM,
						 MsrRegister);

	/*
	 * Update the modem stats to reflect the modem interrupt
	 */
	InstancePtr->Stats.ModemInterrupts++;
}


