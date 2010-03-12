/* $Id: xwdttb.h,v 1.1 2008/08/27 12:42:16 sadanan Exp $ */
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
*       (c) Copyright 2002-2008 Xilinx Inc.
*       All rights reserved.
*
*****************************************************************************/
/****************************************************************************/
/**
*
* @file xwdttb.h
*
* The Xilinx watchdog timer/timebase component supports the Xilinx watchdog
* timer/timebase hardware. More detailed description of the driver operation
* for each function can be found in the xwdttb.c file.
*
* The Xilinx watchdog timer/timebase driver supports the following features:
*   - Polled mode
*   - enabling and disabling (if allowed by the hardware) the watchdog timer
*   - restarting the watchdog.
*   - reading the timebase.
*
* It is the responsibility of the application to provide an interrupt handler
* for the timebase and the watchdog and connect them to the interrupt
* system if interrupt driven mode is desired.
*
* The watchdog timer/timebase component ALWAYS generates an interrupt output
* when:
*   - the watchdog expires the first time
*   - the timebase rolls over
*
* and ALWAYS generates a reset output when the watchdog timer expires a second
* time. This is not configurable in any way from the software driver's
* perspective.
*
* The Timebase is reset to 0 when the Watchdog Timer is enabled.
*
* If the hardware interrupt signal is not connected, polled mode is the only
* option (using IsWdtExpired) for the watchdog. Reset output will occur for the
* second watchdog timeout regardless. Polled mode for the timebase rollover is
* just reading the contents of the register and seeing if the MSB has
* transitioned from 1 to 0.
*
* The IsWdtExpired function is used for polling the watchdog timer and it is
* also used to check if the watchdog was the cause of the last reset. In this
* situation, call Initialize then call WdtIsExpired. If the result is true
* watchdog timeout caused the last system reset. It is then acceptable to
* further initialize the component which will reset this bit.
*
* This driver is intended to be RTOS and processor independent. It works with
* physical addresses only.  Any needs for dynamic memory management, threads
* or thread mutual exclusion, virtual memory, or cache control must be
* satisfied by the layer above this driver.
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- -----------------------------------------------
* 1.00a ecm  08/16/01 First release
* 1.00b jhl  02/21/02 Repartitioned driver for smaller files
* 1.00b rpm  04/26/02 Made LookupConfig public and added XWdtTb_Config
* 1.10b mta  03/23/07 Updated to new coding style
* 1.11a sdm  08/22/08 Removed support for static interrupt handlers from the MDD
*		      file
* </pre>
*
******************************************************************************/

#ifndef XWDTTB_H		/* prevent circular inclusions */
#define XWDTTB_H		/* by using protection macros */

/***************************** Include Files *********************************/

#include "xbasic_types.h"
#include "xstatus.h"
#include "xwdttb_l.h"

#ifdef __cplusplus
extern "C" {
#endif

/************************** Constant Definitions *****************************/


/**************************** Type Definitions *******************************/

/**
 * This typedef contains configuration information for the device.
 */
typedef struct {
	u16 DeviceId;	 /**< Unique ID of device */
	u32 BaseAddr;	 /**< Base address of the device */
} XWdtTb_Config;


/**
 * The XWdtTb driver instance data. The user is required to allocate a
 * variable of this type for every watchdog/timer device in the system.
 * A pointer to a variable of this type is then passed to the driver API
 * functions.
 */
typedef struct {
	u32 RegBaseAddress;	/* Base address of registers */
	u32 IsReady;		/* Device is initialized and ready */
	u32 IsStarted;		/* Device watchdog timer is running */
} XWdtTb;

/***************** Macros (Inline Functions) Definitions *********************/


/************************** Function Prototypes ******************************/

/*
 * Required functions in xwdttb.c
 */
int XWdtTb_Initialize(XWdtTb * InstancePtr, u16 DeviceId);

void XWdtTb_Start(XWdtTb * InstancePtr);

int XWdtTb_Stop(XWdtTb * InstancePtr);

int XWdtTb_IsWdtExpired(XWdtTb * InstancePtr);

void XWdtTb_RestartWdt(XWdtTb * InstancePtr);

u32 XWdtTb_GetTbValue(XWdtTb * InstancePtr);

XWdtTb_Config *XWdtTb_LookupConfig(u16 DeviceId);

/*
 * Self-test functions in xwdttb_selftest.c
 */
int XWdtTb_SelfTest(XWdtTb * InstancePtr);

#ifdef __cplusplus
}
#endif

#endif /* end of protection macro */
