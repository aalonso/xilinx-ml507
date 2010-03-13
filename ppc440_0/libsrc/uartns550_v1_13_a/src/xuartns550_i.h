/* $Id: xuartns550_i.h,v 1.1.4.1 2009/07/14 07:13:56 svemula Exp $ */
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
* @file xuartns550_i.h
*
* This header file contains internal identifiers, which are those shared
* between the files of the driver. It is intended for internal use only.
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- -----------------------------------------------
* 1.00a ecm  08/16/01 First release
* 1.00b jhl  03/11/02 Repartitioned driver for smaller files.
* 1.11a sv   03/20/07 Updated to use the new coding guidelines.
* </pre>
*
******************************************************************************/

#ifndef XUARTNS550_I_H /* prevent circular inclusions */
#define XUARTNS550_I_H /* by using protection macros */

#ifdef __cplusplus
extern "C" {
#endif

/***************************** Include Files *********************************/

#include "xuartns550.h"

/************************** Constant Definitions *****************************/


/************************** Constant Definitions *****************************/


/**************************** Type Definitions *******************************/


/***************** Macros (Inline Functions) Definitions *********************/


/****************************************************************************
*
* This macro updates the status based upon a specified line status register
* value. The stats that are updated are based upon bits in this register. It
* also keeps the last errors instance variable updated. The purpose of this
* macro is to allow common processing between the modules of the component
* with less overhead than a function in the required module.
*
* @param	InstancePtr is a pointer to the XUartNs550 instance .
* @param	CurrentLsr contains the Line Status Register value to
*		be used for the update.
*
* @return 	None.
*
* @note
*
* Signature:
* void XUartNs550_mUpdateStats(XUartNs550 *InstancePtr, u8 CurrentLsr)
*
*****************************************************************************/
#define XUartNs550_mUpdateStats(InstancePtr, CurrentLsr)	\
{								\
	InstancePtr->LastErrors |= CurrentLsr;			\
								\
	if (CurrentLsr & XUN_LSR_OVERRUN_ERROR) {		\
		InstancePtr->Stats.ReceiveOverrunErrors++;	\
	}							\
	if (CurrentLsr & XUN_LSR_PARITY_ERROR) {		\
		InstancePtr->Stats.ReceiveParityErrors++;	\
	}							\
	if (CurrentLsr & XUN_LSR_FRAMING_ERROR) {		\
		InstancePtr->Stats.ReceiveFramingErrors++;	\
	}							\
	if (CurrentLsr & XUN_LSR_BREAK_INT) {			\
		InstancePtr->Stats.ReceiveBreakDetected++;	\
	}							\
}

/****************************************************************************
*
* This macro clears the statistics of the component instance. The purpose of
* this macro is to allow common processing between the modules of the
* component with less overhead than a function in the required module.
*
* @param	InstancePtr is a pointer to the XUartNs550 instance .
*
* @return	None.
*
* @note
*
* Signature: void XUartNs550_mClearStats(XUartNs550 *InstancePtr)
*
*****************************************************************************/
#define XUartNs550_mClearStats(InstancePtr)			\
{								\
	InstancePtr->Stats.TransmitInterrupts = 0UL;		\
	InstancePtr->Stats.ReceiveInterrupts = 0UL;		\
	InstancePtr->Stats.StatusInterrupts = 0UL;		\
	InstancePtr->Stats.ModemInterrupts = 0UL;		\
	InstancePtr->Stats.CharactersTransmitted = 0UL;		\
	InstancePtr->Stats.CharactersReceived = 0UL;		\
	InstancePtr->Stats.ReceiveOverrunErrors = 0UL;		\
	InstancePtr->Stats.ReceiveFramingErrors = 0UL;		\
	InstancePtr->Stats.ReceiveParityErrors = 0UL;		\
	InstancePtr->Stats.ReceiveBreakDetected = 0UL;		\
}

/************************** Function Prototypes ******************************/

int XUartNs550_SetBaudRate(XUartNs550 *InstancePtr, u32 BaudRate);

unsigned int XUartNs550_SendBuffer(XUartNs550 *InstancePtr);

unsigned int XUartNs550_ReceiveBuffer(XUartNs550 *InstancePtr);

/************************** Variable Definitions ****************************/

extern XUartNs550_Config XUartNs550_ConfigTable[];

#ifdef __cplusplus
}
#endif

#endif /* end of protection macro */

