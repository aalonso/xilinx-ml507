/* $Id: xtft.h,v 1.1.2.1 2009/07/18 09:11:32 svemula Exp $ */
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
* @file xtft.h
*
* This header file contains the definitions and declarations for the
* high level driver to access the Xilinx TFT Controller Device.
*
* The device has the capability of displaying data onto a 640*480 VGA TFT
* screen. It can take up to 256K colors. There is no interrupt mode.
*
* The functions XTft_Setpixel and XTft_Getpixel are provided in the driver
* to write to and read from the individual pixels, the color values.
*
* These are generally stored in the assigned 2MB Video Memory which is
* configurable.
*
* Video Memory stores each pixel value in 32bits. Out of this 2MB memory which
* can hold 1024 pixels per line and 512 lines per frame data, only 640 pixels
* per line and 480 lines per frame are used.
*
* Each base color Red, Green, Blue is encoded using 6 bits which sums up to
* 18bits which is stored in the Dual port BRAM.
*
* The constant XPAR_TFT_USE_DCR_BRIDGE is used to inform the driver that
* the Control Register Interface of the TFT device is on a DCR BUS connected
* to a PLB2DCR bridge.
* XPAR_TFT_USE_DCR_BRIDGE must be manually defined in xparameters.h or
* as a compiler option used in the Makefile BEFORE this driver is compiled.
* This constant should not be defined if the Control Register Interface of
* the TFT core is connected directly to a DCR bus or a PLB bus - The driver
* takes care of this.
*
* <b>Initialization & Configuration</b>
*
* The XTft_Config structure is used by the driver to configure itself. This
* configuration structure is typically created by the tool-chain based on HW
* build properties.
*
* To support multiple runtime loading and initialization strategies employed
* by various operating systems, the driver instance can be initialized as
* follows:
*
*   - XTft_CfgInitialize(InstancePtr, CfgPtr, BaseAddress) - Uses a
*	configuration structure provided by the caller. If running in a system
*	with address translation, the provided virtual memory base address
*	replaces the physical address present in the configuration structure.
*
* <b>Interrupts</b>
*
* The TFT device supports a single interrupt which is generated for a Vsync
* pulse.
*
* This driver does not provide a Interrupt Service Routine (ISR) for the device.
* It is the responsibility of the application to provide one if needed.
*
* <b>RTOS Independence</b>
*
* This driver is intended to be RTOS and processor independent. It works
* with physical addresses only. Any needs for dynamic memory management,
* threads or thread mutual exclusion, virtual memory, or cache control must
* be satisfied by the layer above this driver.
*
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver    Who   Date      Changes
* -----  ----  --------  -----------------------------------------------
* 1.00a  sg    03/24/08  First release
* 2.00a	 ktn   07/06/09	 Added XTft_IntrEnable(), XTft_IntrDisable()and,
*			 XTft_GetVsyncStatus() functions to access newly added
*			 Interrupt Enable and Status Register.
*</pre>
*
****************************************************************************/
#ifndef XTFT_H /* prevent circular inclusions */
#define XTFT_H /* by using protection macros */

#ifdef __cplusplus
extern "C" {
#endif

/***************************** Include Files *******************************/
#include "xstatus.h"
#include "xtft_hw.h"

/************************** Constant Definitions ***************************/
/**
 * As the first bitmap available in the Character Bitmap array is "space"
 * whose value is 32 in the ASCII character table, this offset enables us to
 * move to this first character in the array. To achieve this we subtract
 * this offset from the char value actually received to the XTft_WriteChar
 * function. Similarly to move to any other character this offset must be
 * subtracted.
 */
#define XTFT_ASCIICHAR_OFFSET 32

/**
 * The default color is white for foreground and black for background.
 * These values can range from 0 to 0xFFFFFFFF as each color is ranging
 * from 0 to 3F. The default value for column and row is 0.
 */
#define XTFT_DEF_FGCOLOR 0x00FFFFFF	/**< Foreground Color - White */
#define XTFT_DEF_BGCOLOR 0x0		/**< Background Color - Black */
#define XTFT_DEF_COLVAL  0x0		/**< Default Column Value */
#define XTFT_DEF_ROWVAL	 0x0		/**< Default Row Value */

/**************************** Type Definitions *****************************/

/**
 * This structure holds the Device base address, video memory base address
 * and Unique identifier of the device.
 */
typedef struct {

	u16 DeviceId;		/**< Unique ID of device */
	u32 BaseAddress;	/**< Base address of device */
	u32 VideoMemBaseAddr;	/**< Video Memory Base address */
	u16 PlbAccess;		/**< Access to the control registers */
	u32 DcrBaseAddr;	/**< Address when connected to a DCR Bus */
} XTft_Config;


/**
 * This structure is the base for whole of the operations that are to be
 * performed  on the TFT screen. With this we will get a handle to the driver
 * through which we access different members  like  base address, deviceID
 * and using them we navigate, fill colors etc.
 */
typedef struct {

	XTft_Config TftConfig;	/**< Instance of Config Structure */
	u32 IsReady;		/**< Status of Instance */
	u32 ColVal;		/**< Column position */
	u32 RowVal;		/**< Row position */
	u32 FgColor;		/**< Foreground Color */
	u32 BgColor;		/**< Background Color */

} XTft;

/***************** Macros (Inline Functions) Definitions *******************/

/************************** Function Prototypes ****************************/

/*
 * Initialization function in xtft_sinit.c.
 */
XTft_Config *XTft_LookupConfig(u16 DeviceId);

/*
 * Functions for basic driver operations in xtft.c.
 */
int XTft_CfgInitialize(XTft *InstancePtr, XTft_Config *ConfigPtr,
			 u32 EffectiveAddr);

void XTft_SetPos(XTft *InstancePtr, u32 ColVal, u32 RowVal);
void XTft_SetPosChar(XTft *InstancePtr, u32 ColVal, u32 RowVal);
void XTft_SetColor(XTft *InstancePtr, u32 FgColor, u32 BgColor);
void XTft_SetPixel(XTft *InstancePtr, u32 ColVal, u32 RowVal, u32 PixelVal);
void XTft_GetPixel(XTft *InstancePtr, u32 ColVal, u32 RowVal, u32* PixelVal);

void XTft_Write(XTft *InstancePtr, u8 CharValue);

void XTft_Scroll(XTft *InstancePtr);
void XTft_ClearScreen(XTft *InstancePtr);
void XTft_FillScreen(XTft* InstancePtr, u32 ColStartVal,
			 u32 RowStartVal,u32 ColEndVal, u32 RowEndVal,
			 u32 PixelVal);

void XTft_EnableDisplay(XTft *InstancePtr);
void XTft_DisableDisplay(XTft *InstancePtr);
void XTft_ScanReverse(XTft* InstancePtr);
void XTft_ScanNormal(XTft* InstancePtr);
void XTft_SetFrameBaseAddr(XTft *InstancePtr, u32 NewFrameBaseAddr);
void XTft_WriteReg(XTft* InstancePtr, u32 RegOffset, u32 Data);
u32 XTft_ReadReg(XTft* InstancePtr, u32 RegOffset);
void XTft_IntrEnable(XTft* InstancePtr);
void XTft_IntrDisable(XTft* InstancePtr);
int XTft_GetVsyncStatus(XTft* InstancePtr);

/************************** Variable Definitions ***************************/

/************************** Function Definitions ***************************/

#ifdef __cplusplus
}
#endif

#endif /* XTFT_H */

