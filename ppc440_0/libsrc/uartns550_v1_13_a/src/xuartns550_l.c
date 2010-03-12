/* $Id: xuartns550_l.c,v 1.1.4.1 2009/07/14 07:13:57 svemula Exp $ */
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
/*****************************************************************************/
/**
*
* @file xuartns550_l.c
*
* This file contains low-level driver functions that can be used to access the
* device.  The user should refer to the hardware device specification for more
* details of the device operation.
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- -----------------------------------------------
* 1.00b jhl  04/24/02 First release
* 1.11a sv   03/20/07 Updated to use the new coding guidelines.
* </pre>
*
******************************************************************************/


/***************************** Include Files *********************************/

#include "xuartns550_l.h"

/************************** Constant Definitions *****************************/


/**************************** Type Definitions *******************************/


/***************** Macros (Inline Functions) Definitions *********************/


/************************** Function Prototypes ******************************/


/************************** Variable Definitions *****************************/


/****************************************************************************/
/**
*
* This function sends a data byte with the UART. This function operates in the
* polling mode and blocks until the data has been put into the UART transmit
* holding register.
*
* @param	BaseAddress contains the base address of the UART.
* @param	Data contains the data byte to be sent.
*
* @return	None.
*
* @note		None.
*
*****************************************************************************/
void XUartNs550_SendByte(u32 BaseAddress, u8 Data)
{
	/*
	 * Wait til we know that the byte can be sent, the 550 does not have any
	 * way to tell how much room is in the FIFO such that we must wait for
	 * it to be empty
	 */
	while (!XUartNs550_mIsTransmitEmpty(BaseAddress));

	/*
	 * Write the data byte to the UART to be transmitted
	 */
	XUartNs550_mWriteReg(BaseAddress, XUN_THR_OFFSET, Data);
}

/****************************************************************************/
/**
*
* This function receives a byte from the UART. It operates in a polling mode
* and blocks until a byte of data is received.
*
* @param	BaseAddress contains the base address of the UART.
*
* @return	The data byte received by the UART.
*
* @note		None.
*
*****************************************************************************/
u8 XUartNs550_RecvByte(u32 BaseAddress)
{
	/*
	 * Wait for there to be data received
	 */

	while (!XUartNs550_mIsReceiveData(BaseAddress));

	/*
	 * Return the next data byte the UART received
	 */

	return XUartNs550_mReadReg(BaseAddress, XUN_RBR_OFFSET);
}


/****************************************************************************/
/**
*
* Set the baud rate for the UART.
*
* @param	BaseAddress contains the base address of the UART.
* @param	InputClockHz is the frequency of the input clock to the device
*		in Hertz.
* @param	BaudRate is the baud rate to be set.
*
* @return	None.
*
* @note		None.
*
*****************************************************************************/
void XUartNs550_SetBaud(u32 BaseAddress, u32 InputClockHz, u32 BaudRate)
{

	u8 BaudLSB;
	u8 BaudMSB;
	u8 LcrRegister;
	u32 Divisor;

	/*
	 * Determine what the divisor should be to get the specified baud
	 * rater based upon the input clock frequency and a baud clock prescaler
	 * of 16
	 */
	Divisor = InputClockHz / (BaudRate * 16UL);

	/*
	 * Get the least significant and most significant bytes of the divisor
	 * so they can be written to 2 byte registers
	 */
	BaudLSB = Divisor & XUN_DIVISOR_BYTE_MASK;
	BaudMSB = (Divisor >> 8) & XUN_DIVISOR_BYTE_MASK;

	/*
	 * Get the line control register contents and set the divisor latch
	 * access bit so the baud rate can be set
	 */
	LcrRegister = XUartNs550_mReadReg(BaseAddress, XUN_LCR_OFFSET);
	XUartNs550_mWriteReg(BaseAddress, XUN_LCR_OFFSET,
				LcrRegister | XUN_LCR_DLAB);

	/*
	 * Set the baud Divisors to set rate, the initial write of 0xFF is to
	 * keep the divisor from being 0 which is not recommended as per the
	 * NS16550D spec sheet
	 */
	XUartNs550_mWriteReg(BaseAddress, XUN_DRLS_OFFSET, 0xFF);
	XUartNs550_mWriteReg(BaseAddress, XUN_DRLM_OFFSET, BaudMSB);
	XUartNs550_mWriteReg(BaseAddress, XUN_DRLS_OFFSET, BaudLSB);

	/*
	 * Clear the Divisor latch access bit, DLAB to allow nornal
	 * operation and write to the line control register
	 */
	XUartNs550_mWriteReg(BaseAddress, XUN_LCR_OFFSET, LcrRegister);
}

