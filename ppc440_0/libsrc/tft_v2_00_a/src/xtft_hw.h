/* $Id: xtft_hw.h,v 1.1.2.1 2009/07/18 09:11:32 svemula Exp $ */
/******************************************************************************
*
* (c) Copyright 2008-2009 Xilinx, Inc. All rights reserved.
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
/***************************************************************************/
/**
*
* @file xtft_hw.h
*
* This file defines the macros and definitions for the Xilinx TFT Controller
* device.
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver    Who   Date      Changes
* -----  ----  --------  -----------------------------------------------
* 1.00a  sg    03/24/08  First release
* 2.00a	 ktn   07/06/09	 Added Interrupt Enable and Status Register Offset and,
*			 bit masks.
*
* </pre>
*
****************************************************************************/
#ifndef XTFT_HW_H  /* prevent circular inclusions */
#define XTFT_HW_H  /* by using protection macros  */

#ifdef __cplusplus
extern "C" {
#endif

/***************************** Include Files *******************************/
#include "xbasic_types.h"
#include "xio.h"
#ifdef __PPC__
#include "xio_dcr.h"
#endif

/************************** Constant Definitions ***************************/

/**
 * @name TFT Register offsets
 *
 * The following definitions provide access to each of the registers of the
 * TFT device. These are defined for access through a PLB Bus. They need to be
 * divided by 4 for access through the DCR Bus.
 * @{
 */
#define XTFT_AR_OFFSET		0 /**< Address Reg (Video memory) Offset */
#define XTFT_CR_OFFSET		4 /**< Control Register Offset */
#define XTFT_IESR_OFFSET	8 /**< Interrupt Enable and Status Reg Offset */

/*@}*/

/**
 * @name TFT Control Register (CR) mask(s)
 * @{
 */
#define XTFT_CR_TDE_MASK	0x01 /**< TFT Display Enable Bit Mask */
#define XTFT_CR_DPS_MASK	0x02 /**< TFT Display Scan Control Bit Mask */

/*@}*/

/**
 * @name TFT Interrupt Enable and Status Register (IESR) mask(s)
 * @{
 */
#define XTFT_IESR_VADDRLATCH_STATUS_MASK 0x01 /**< TFT Video Address Latch
							Status Bit Mask */
#define XTFT_IESR_IE_MASK		0x08 /**< TFT Interrupt Enable Mask */

/*@}*/

/**
 * Dimension Definitions
 */
#define XTFT_CHAR_WIDTH			8    /**< Character width */
#define XTFT_CHAR_HEIGHT		12   /**< Character height */
#define XTFT_DISPLAY_WIDTH		640  /**< Width of the screen */
#define XTFT_DISPLAY_HEIGHT		480  /**< Height of the screen */
#define XTFT_DISPLAY_BUFFER_WIDTH	1024 /**< Buffer width of a line */

/*
 * This shift is used for accessing the TFT registers through DCR bus.
 */
#define XTFT_DCR_REG_SHIFT		2    /**< Reg Shift for DCR Access */

/**************************** Type Definitions *****************************/

/***************** Macros (Inline Functions) Definitions *******************/

/***************************************************************************/
/**
*
* To fill a particular pixel with the given 32bit color value.
*
* @param	VideoMemBaseAddr is the video memory base address.
* @param	ColVal represents the column on the screen. The valid values
*		are 0 to (XTFT_DISPLAY_WIDTH - 1).
* @param	RowVal represents the row on the screen. The valid values
*		are 0 to (XTFT_DISPLAY_HEIGHT - 1).
* @param	PixelVal represents the color with which it will be
*		filled on screen.
*
* @return	None.
*
* @note		This macro is independent of the interface the TFT
*		Controller is connected to.
*		C-style signature:
*		void XTft_mSetPixel(u32 VideoMemBaseAddr, u32 ColVal,
*			u32 RowVal, u32 PixelVal).
*
****************************************************************************/
#define XTft_mSetPixel(VideoMemBaseAddr, ColVal, RowVal, PixelVal) \
	XIo_Out32((VideoMemBaseAddr) + \
	4 * ((RowVal) * XTFT_DISPLAY_BUFFER_WIDTH + ColVal), PixelVal)

/***************************************************************************/
/**
*
* To obtain the color value at the given row and column position.
*
* @param	VideoMemBaseAddr is the video memory base address.
* @param	ColVal represents the column on the screen. The valid values
*		are 0 to (XTFT_DISPLAY_WIDTH - 1).
* @param	RowVal represents the row on the screen. The valid values
*		are 0 to (XTFT_DISPLAY_HEIGHT - 1).
*
* @return	A 32 bit color value from the given column and row position.
*
* @note		This macro is independent of the interface the TFT
*		Controller is connected to.
*		C-style signature:
*		u32 XTft_mGetPixel(u32 VideoMemBaseAddr, u32 ColVal,
*					u32 RowVal)
*
****************************************************************************/
#define XTft_mGetPixel(VideoMemBaseAddr, ColVal, RowVal) \
	XIo_In32((VideoMemBaseAddr) + 4 * \
	((RowVal) * XTFT_DISPLAY_BUFFER_WIDTH + ColVal))

/************************** Function Prototypes ****************************/

/************************** Variable Definitions ***************************/

/************************** Function Definitions ****************************/

#ifdef __cplusplus
}
#endif

#endif /* XTFT_HW_H */
