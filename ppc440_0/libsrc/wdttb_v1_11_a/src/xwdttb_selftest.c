/* $Id: xwdttb_selftest.c,v 1.1 2008/08/27 12:42:16 sadanan Exp $ */
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
* @file xwdttb_selftest.c
*
* Contains diagnostic self-test functions for the XWdtTb component.
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- -----------------------------------------------
* 1.00b jhl  02/06/02 First release
* 1.10b mta  03/23/07 Updated to new coding style
* </pre>
*
******************************************************************************/

/***************************** Include Files *********************************/

#include "xbasic_types.h"
#include "xio.h"
#include "xwdttb.h"

/************************** Constant Definitions *****************************/

#define XWT_MAX_SELFTEST_LOOP_COUNT 0x00010000

/**************************** Type Definitions *******************************/


/***************** Macros (Inline Functions) Definitions *********************/


/************************** Function Prototypes ******************************/


/************************** Variable Definitions *****************************/


/****************************************************************************/
/**
*
* Run a self-test on the timebase. This test verifies that the timebase is
* incrementing. The watchdog timer is not tested due to the time required
* to wait for the watchdog timer to expire. The time consumed by this test
* is dependant on the system clock and the configuration of the dividers in
* for the input clock of the timebase.
*
* @param	InstancePtr is a pointer to the XWdtTb instance to be worked on.
*
* @return
* 		- XST_SUCCESS if self-test was successful
* 		- XST_WDTTB_TIMER_FAILED if the timebase is not incrementing
*
* @note		None.
*
******************************************************************************/
int XWdtTb_SelfTest(XWdtTb * InstancePtr)
{
	int LoopCount;
	u32 TbrValue1;
	u32 TbrValue2;

	/*
	 * Assert to ensure the inputs are valid and the instance has been
	 * initialized
	 */
	XASSERT_NONVOID(InstancePtr != NULL);
	XASSERT_NONVOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);

	/*
	 * Read the timebase register twice to start the test
	 */
	TbrValue1 = XIo_In32(InstancePtr->RegBaseAddress + XWT_TBR_OFFSET);
	TbrValue2 = XIo_In32(InstancePtr->RegBaseAddress + XWT_TBR_OFFSET);

	/*
	 * Read the timebase register for a number of iterations or until it
	 * increments, which ever occurs first
	 */
	for (LoopCount = 0;
	     ((LoopCount <= XWT_MAX_SELFTEST_LOOP_COUNT) &&
	      (TbrValue2 == TbrValue1)); LoopCount++) {
		TbrValue2 = XIo_In32(InstancePtr->RegBaseAddress +
				     XWT_TBR_OFFSET);
	}

	/* if the timebase register changed the test is successful, otherwise it
	 * failed
	 */
	if (TbrValue2 != TbrValue1) {
		return XST_SUCCESS;
	}
	else {
		return XST_WDTTB_TIMER_FAILED;
	}
}
