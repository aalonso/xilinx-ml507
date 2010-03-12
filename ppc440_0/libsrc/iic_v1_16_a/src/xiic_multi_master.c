/* $Id: xiic_multi_master.c,v 1.1.2.1 2009/07/18 05:51:06 svemula Exp $ */
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
* @file xiic_multi_master.c
*
* Contains multi-master functions for the XIic component. This file is
* necessary if multiple masters are on the IIC bus such that arbitration can
* be lost or the bus can be busy.
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- --- ------- -----------------------------------------------
* 1.01b jhl 3/27/02 Reparitioned the driver
* 1.01c ecm 12/05/02 new rev
* 1.13a wgr  03/22/07 Converted to new coding style.
* </pre>
*
****************************************************************************/

/***************************** Include Files *******************************/

#include "xiic.h"
#include "xiic_i.h"
#include "xio.h"

/************************** Constant Definitions ***************************/


/**************************** Type Definitions *****************************/


/***************** Macros (Inline Functions) Definitions *******************/


/************************** Function Prototypes ****************************/

static void BusNotBusyHandler(XIic * InstancePtr);
static void ArbitrationLostHandler(XIic * InstancePtr);

/************************** Variable Definitions **************************/


/****************************************************************************/
/**
* This function includes multi-master code such that multi-master events are
* handled properly. Multi-master events include a loss of arbitration and
* the bus transitioning from busy to not busy.  This function allows the
* multi-master processing to be optional.  This function must be called prior
* to allowing any multi-master events to occur, such as after the driver is
* initialized.
*
* @note
*
* None
*
******************************************************************************/
void XIic_MultiMasterInclude()
{
	XIic_ArbLostFuncPtr = ArbitrationLostHandler;
	XIic_BusNotBusyFuncPtr = BusNotBusyHandler;
}

/*****************************************************************************/
/**
*
* The IIC bus busy signals when a master has control of the bus. Until the bus
* is released, i.e. not busy, other devices must wait to use it.
*
* When this interrupt occurs, it signals that the previous master has released
* the bus for another user.
*
* This interrupt is only enabled when the master Tx is waiting for the bus.
*
* This interrupt causes the following tasks:
* - Disable Bus not busy interrupt
* - Enable bus Ack
*     Should the slave receive have disabled acknowledgement, enable to allow
*     acknowledgment of the sending of our address to again be addresed as slave
* - Flush Rx FIFO
*     Should the slave receive have disabled acknowledgement, a few bytes may
*     be in FIFO if Rx full did not occur because of not enough byte in FIFO
*     to have caused an interrupt.
* - Send status to user via status callback with the value:
*    XII_BUS_NOT_BUSY_EVENT
*
* @param    InstancePtr is a pointer to the XIic instance to be worked on.
*
* @return
*
* None.
*
* @note
*
* None.
*
******************************************************************************/
static void BusNotBusyHandler(XIic * InstancePtr)
{
	u32 Status;
	u8 CntlReg;

	/* Should the slave receive have disabled acknowledgement,
	 * enable to allow acknowledgment of the sending of our address to
	 * again be addresed as slave
	 */
	CntlReg = XIo_In8(InstancePtr->BaseAddress + XIIC_CR_REG_OFFSET);
	XIo_Out8(InstancePtr->BaseAddress + XIIC_CR_REG_OFFSET,
		 (CntlReg & ~XIIC_CR_NO_ACK_MASK));

	/* Flush Tx FIFO by toggling TxFIFOResetBit. FIFO runs normally at 0
	 * Do this incase needed to Tx FIFO with more than expected if what
	 * was set to Tx was less than what the Master expected - read more
	 * from this slave so FIFO had junk in it
	 */
	XIic_mFlushTxFifo(InstancePtr);

	/* Flush Rx FIFO should slave rx had a problem, sent No ack but
	 * still received a few bytes. Should the slave receive have disabled
	 * acknowledgement, clear rx FIFO
	 */
	XIic_mFlushRxFifo(InstancePtr);

	/* Send Application messaging status via callbacks. Disable either Tx or
	 * Receive interrupt. Which callback depends on messaging direction.
	 */
	Status = XIIC_READ_IIER(InstancePtr->BaseAddress);
	if (InstancePtr->RecvBufferPtr == NULL) {
		/* Slave was sending data (master was reading), disable
		 * all the transmit interrupts
		 */
		XIIC_WRITE_IIER(InstancePtr->BaseAddress,
				      (Status & ~XIIC_TX_INTERRUPTS));
	}
	else {
		/* Slave was receiving data (master was writing) disable receive
		 * interrupts
		 */
		XIIC_WRITE_IIER(InstancePtr->BaseAddress,
				      (Status & ~XIIC_INTR_RX_FULL_MASK));
	}

	/* Send Status in StatusHandler callback
	 */
	InstancePtr->StatusHandler(InstancePtr->StatusCallBackRef,
				   XII_BUS_NOT_BUSY_EVENT);
}

/*****************************************************************************/
/**
*
* When multiple IIC devices attempt to use the bus simultaneously, only
* a single device will be able to keep control as a master. Those devices
* that didn't retain control over the bus are said to have lost arbitration.
* When arbitration is lost, this interrupt occurs sigaling the user that
* the message did not get sent as expected.
*
* This function, at arbitration lost:
*   - Disables tx empty, � empty and Tx error interrupts
*   - Clears any tx empty, � empty Rx Full or tx error interrupts
*   - Clears Arbitration lost interrupt,
*   - Flush Tx FIFO
*   - Call StatusHandler callback with the value: XII_ARB_LOST_EVENT
*
* @param    InstancePtr is a pointer to the XIic instance to be worked on.
*
* @return
*
* None.
*
* @note
*
* None.
*
******************************************************************************/
static void ArbitrationLostHandler(XIic * InstancePtr)
{
	/* Disable tx empty and � empty and Tx error interrupts before clearing them
	 * so they won't occur again
	 */
	XIic_mDisableIntr(InstancePtr->BaseAddress, XIIC_TX_INTERRUPTS);

	/* Clear any tx empty, � empty Rx Full or tx error interrupts
	 */
	XIic_mClearIntr(InstancePtr->BaseAddress, XIIC_TX_INTERRUPTS);

	XIic_mFlushTxFifo(InstancePtr);

	/* Update Status via StatusHandler callback
	 */
	InstancePtr->StatusHandler(InstancePtr->StatusCallBackRef,
				   XII_ARB_LOST_EVENT);
}
