/* $Id: xps2_l.h,v 1.1 2008/08/27 10:45:27 sadanan Exp $ */
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
* @file xps2_l.h
*
* This header file contains identifiers and low-level driver functions (or
* macros) that can be used to access the device. The user should refer to the
* hardware device specification for more details of the device operation.
* High-level driver functions are defined in xps2.h.
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who      Date     Changes
* ----- ------   -------- -----------------------------------------------
* 1.00a sv/sdm   01/25/08 First release
* </pre>
*
******************************************************************************/
#ifndef XPS2_L_H /* prevent circular inclusions */
#define XPS2_L_H /* by using protection macros */

#ifdef __cplusplus
extern "C" {
#endif

/***************************** Include Files ********************************/

#include "xbasic_types.h"
#include "xio.h"

/************************** Constant Definitions ****************************/

/**
 * PS/2 register offsets
 */
/** @name Register Map
 *
 * Register offsets for the XPs2 device.
 * @{
 */
#define XPS2_SRST_OFFSET	0x00000000 /**< Software Reset register */
#define XPS2_STATUS_OFFSET	0x00000004 /**< Status register */
#define XPS2_RX_DATA_OFFSET	0x00000008 /**< Receive Data register */
#define XPS2_TX_DATA_OFFSET	0x0000000C /**< Transmit Data register */
#define XPS2_GIER_OFFSET	0x0000002C /**< Global Interrupt Enable reg */
#define XPS2_IPISR_OFFSET	0x00000030 /**< Interrupt Status register */
#define XPS2_IPIER_OFFSET	0x00000038 /**< Interrupt Enable register */

/* @} */

/** @name Reset Register Bit Definitions
 *
 * @{
 */
#define XPS2_SRST_RESET		0x0000000A /**< Software Reset  */

/* @} */


/** @name Status Register Bit Positions
 *
 * @{
 */
#define XPS2_STATUS_RX_FULL	0x00000001 /**< Receive Full  */
#define XPS2_STATUS_TX_FULL	0x00000002 /**< Transmit Full  */

/* @} */


/** @name PS/2 Device Interrupt Status/Enable Registers
 *
 * <b> Interrupt Status Register (IPISR) </b>
 *
 * This register holds the interrupt status flags for the PS/2 device.
 *
 * <b> Interrupt Enable Register (IPIER) </b>
 *
 * This register is used to enable interrupt sources for the PS/2 device.
 * Writing a '1' to a bit in this register enables the corresponding Interrupt.
 * Writing a '0' to a bit in this register disables the corresponding Interrupt.
 *
 * ISR/IER registers have the same bit definitions and are only defined once.
 * @{
 */
#define XPS2_IPIXR_WDT_TOUT	0x00000001 /**< Watchdog Timeout Interrupt */
#define XPS2_IPIXR_TX_NOACK	0x00000002 /**< Transmit No ACK Interrupt */
#define XPS2_IPIXR_TX_ACK	0x00000004 /**< Transmit ACK (Data) Interrupt */
#define XPS2_IPIXR_RX_OVF	0x00000008 /**< Receive Overflow Interrupt */
#define XPS2_IPIXR_RX_ERR	0x00000010 /**< Receive Error Interrupt */
#define XPS2_IPIXR_RX_FULL	0x00000020 /**< Receive Data Interrupt */

/**
 * Mask for all the Transmit Interrupts
 */
#define XPS2_IPIXR_TX_ALL	(XPS2_IPIXR_TX_NOACK | XPS2_IPIXR_TX_ACK)

/**
 * Mask for all the Receive Interrupts
 */
#define XPS2_IPIXR_RX_ALL	(XPS2_IPIXR_RX_OVF | XPS2_IPIXR_RX_ERR |  \
					XPS2_IPIXR_RX_FULL)

/**
 * Mask for all the Interrupts
 */
#define XPS2_IPIXR_ALL		(XPS2_IPIXR_TX_ALL | XPS2_IPIXR_RX_ALL |  \
					XPS2_IPIXR_WDT_TOUT)
/* @} */


/**
 * @name Global Interrupt Enable Register (GIER) mask(s)
 * @{
 */
#define XPS2_GIER_GIE_MASK	0x80000000 /**< Global interrupt enable */
/*@}*/

/**************************** Type Definitions ******************************/

/***************** Macros (Inline Functions) Definitions ********************/

#define XPs2_In32  XIo_In32
#define XPs2_Out32 XIo_Out32

/****************************************************************************/
/**
* Read from the specified PS/2 device register.
*
* @param	BaseAddress contains the base address of the device.
* @param	RegOffset contains the offset from the 1st register of the
*		device to select the specific register.
*
* @return	The value read from the register.
*
* @note		C-Style signature:
*		u32 XPs2_ReadReg(u32 BaseAddress, u32 RegOffset);
*
******************************************************************************/
#define XPs2_ReadReg(BaseAddress, RegOffset) \
	XPs2_In32((BaseAddress) + (RegOffset))

/***************************************************************************/
/**
* Write to the specified PS/2 device register.
*
* @param	BaseAddress contains the base address of the device.
* @param	RegOffset contains the offset from the 1st register of the
*		device to select the specific register.
* @param	RegisterValue is the value to be written to the register.
*
* @return	None.
*
* @note		C-Style signature:
*		void XPs2_WriteReg(u32 BaseAddress, u32 RegOffset,
*				u32 RegisterValue);
******************************************************************************/
#define XPs2_WriteReg(BaseAddress, RegOffset, RegisterValue) \
	XPs2_Out32((BaseAddress) + (RegOffset), (RegisterValue))

/****************************************************************************/
/**
* This macro checks if the receiver is full (There is data in the receive data
* register).
*
* @param	BaseAddress contains the base address of the device.
*
* @return
*		- TRUE if there is receive data.
*		- FALSE if there is no receive data.
*
* @note		C-Style signature:
*		int XPs2_IsRxFull(u32 BaseAddress);
*
******************************************************************************/
#define XPs2_IsRxFull(BaseAddress) 					\
	(((XPs2_ReadReg(BaseAddress, XPS2_STATUS_OFFSET) & 		\
			XPS2_STATUS_RX_FULL)) ? TRUE : FALSE)

/****************************************************************************/
/**
* This macro checks if the transmitter is empty.
*
* @param	BaseAddress contains the base address of the device.
*
* @return
*		- TRUE if the transmitter is not full and data can be sent.
*		- FALSE if the transmitter is full.
*
* @note		C-Style signature:
*		int XPs2_IsTxEmpty(u32 BaseAddress);
*
******************************************************************************/
#define XPs2_IsTxEmpty(BaseAddress) 				     \
	((XPs2_ReadReg(BaseAddress, XPS2_STATUS_OFFSET ) & 		     \
			XPS2_STATUS_TX_FULL) ? FALSE: TRUE)

/************************** Variable Definitions ****************************/

/************************** Function Prototypes *****************************/

void XPs2_SendByte(u32 BaseAddress, u8 Data);
u32 XPs2_RecvByte(u32 BaseAddress);

/****************************************************************************/

#ifdef __cplusplus
}
#endif

#endif

