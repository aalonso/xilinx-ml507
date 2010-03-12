/* $Id: xwdttb_l.h,v 1.1 2008/08/27 12:42:16 sadanan Exp $ */
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
* @file xwdttb_l.h
*
* This header file contains identifiers and basic driver functions (or
* macros) that can be used to access the device.
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- -----------------------------------------------
* 1.00b rpm  04/26/02 First release
* 1.10b mta  03/23/07 Updated to new coding style
* </pre>
*
******************************************************************************/

#ifndef XWDTTB_L_H		/* prevent circular inclusions */
#define XWDTTB_L_H		/* by using protection macros */

#ifdef __cplusplus
extern "C" {
#endif

/***************************** Include Files *********************************/

#include "xbasic_types.h"
#include "xio.h"

/************************** Constant Definitions *****************************/

/* Offsets of registers from the start of the device */

#define XWT_TWCSR0_OFFSET		0x0
#define XWT_TWCSR1_OFFSET		0x4
#define XWT_TBR_OFFSET			0x8

/* TWCSR0 Control/Status Register 0 bits */

#define XWT_CSR0_WRS_MASK		0x00000008	/* reset status */
#define XWT_CSR0_WDS_MASK		0x00000004	/* timer state  */
#define XWT_CSR0_EWDT1_MASK		0x00000002	/* enable bit 1 */

/* TWCSR0/1 Control/Status Register 0/1 bits */

#define XWT_CSRX_EWDT2_MASK		0x00000001	/* enable bit 2 */


/**************************** Type Definitions *******************************/


/***************** Macros (Inline Functions) Definitions *********************/

/****************************************************************************/
/**
*
* Get the contents of the timebase register.
*
* @param	BaseAddress is the  base address of the device
*
* @return	A 32-bit value representing the timebase.
*
* @note		C-style signature:
*		u32 XWdtTb_mGetTimebaseReg(u32 BaseAddress)
*
*****************************************************************************/
#define XWdtTb_mGetTimebaseReg(BaseAddress)		\
		XIo_In32((BaseAddress) + XWT_TBR_OFFSET)


/****************************************************************************/
/**
*
* Enable the watchdog timer. Clear previous expirations. The timebase is
* reset to 0.
*
* @param	BaseAddress is the  base address of the device
*
* @return	None.
*
* @note		C-style signature:
* 		void XWdtTb_mEnableWdt(u32 BaseAddress)
*
*****************************************************************************/
#define XWdtTb_mEnableWdt(BaseAddress)					   \
{									   \
	XIo_Out32((BaseAddress) + XWT_TWCSR0_OFFSET, XWT_CSR0_EWDT1_MASK | \
					XWT_CSR0_WRS_MASK | XWT_CSR0_WDS_MASK);\
	XIo_Out32((BaseAddress) + XWT_TWCSR1_OFFSET, XWT_CSRX_EWDT2_MASK); \
}


/****************************************************************************/
/**
*
* Disable the watchdog timer.
*
* @param	BaseAddress is the  base address of the device
*
* @return	None.
*
* @note		C-style signature:
* 		void XWdtTb_mDisableWdt(u32 BaseAddress)
*
*****************************************************************************/
#define XWdtTb_mDisableWdt(BaseAddress)					\
{									\
	XIo_Out32((BaseAddress) + XWT_TWCSR0_OFFSET, 0);		\
	XIo_Out32((BaseAddress) + XWT_TWCSR1_OFFSET, 0);		\
}


/****************************************************************************/
/**
*
* Restart the watchdog timer.
*
* @param	BaseAddress is the  base address of the device
*
* @return	None.
*
* @note		C-style signature:
* 		void XWdtTb_mRestartWdt(u32 BaseAddress)
*
*****************************************************************************/
#define XWdtTb_mRestartWdt(BaseAddress)					\
	XIo_Out32((BaseAddress) + XWT_TWCSR0_OFFSET,			\
	XWT_CSR0_EWDT1_MASK | XWT_CSR0_WRS_MASK	| XWT_CSR0_WDS_MASK)


/****************************************************************************/
/**
*
* Check to see if the last system reset was caused by the timer expiring.
*
* @param	BaseAddress is the  base address of the device
*
* @return	TRUE if the watchdog did cause the last reset, FALSE otherwise.
*
* @note		C-style signature:
* 		int XWdtTb_mHasReset(u32 BaseAddress)
*****************************************************************************/
#define XWdtTb_mHasReset(BaseAddress)					\
	((XIo_In32((BaseAddress) + XWT_TWCSR0_OFFSET) &			\
	XWT_CSR0_WRS_MASK) == XWT_CSR0_WRS_MASK)


/****************************************************************************/
/**
*
* Check to see if the watchdog timer has expired.
*
* @param	BaseAddress is the  base address of the device
*
* @return	TRUE if the watchdog did expire, FALSE otherwise.
*
* @note		C-style signature:
* 		int XWdtTb_mHasExpired(u32 BaseAddress)
*
*****************************************************************************/
#define XWdtTb_mHasExpired(BaseAddress) \
	((XIo_In32((BaseAddress) + XWT_TWCSR0_OFFSET) & \
	XWT_CSR0_WDS_MASK) == XWT_CSR0_WDS_MASK)


/************************** Function Prototypes ******************************/


/************************** Variable Definitions *****************************/

#ifdef __cplusplus
}
#endif

#endif
