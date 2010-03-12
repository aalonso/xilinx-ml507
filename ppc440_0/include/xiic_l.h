/* $Id: xiic_l.h,v 1.1.2.2 2009/10/16 09:47:33 svemula Exp $ */
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
* @file xiic_l.h
*
* This header file contains identifiers and driver functions (or
* macros) that can be used to access the device in normal and dynamic
* controller mode.  High-level driver functions are defined in xiic.h.
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- -----------------------------------------------
* 1.00b jhl  05/07/02 First release
* 1.01c ecm  12/05/02 new rev
* 1.01d jhl  10/08/03 Added general purpose output feature
* 1.02a mta  03/09/06 Implemented Repeated Start in the Low Level Driver.
* 1.03a mta  04/04/06 Implemented Dynamic IIC core routines.
* 1.03a rpm  09/08/06 Added include of xstatus.h for completeness
* 1.13a wgr  03/22/07 Converted to new coding style.
* 1.16a ktn  07/18/09 Updated the notes in XIIC_RESET macro to clearly indicate
*                     that only the Interrupt Registers are reset.
* 1.16a ktn  10/16/09 Updated the notes in the XIIC_RESET macro to mention
*                     that the complete IIC core is Reset on giving a software
*                     reset to the IIC core. Some previous versions of the
*                     core only reset the Interrupt Logic/Registers, please
*                     refer to the HW specification for futher details.
* </pre>
*
*****************************************************************************/

#ifndef XIIC_L_H		/* prevent circular inclusions */
#define XIIC_L_H		/* by using protection macros */

#ifdef __cplusplus
extern "C" {
#endif

/***************************** Include Files ********************************/

#include "xbasic_types.h"
#include "xstatus.h"

/************************** Constant Definitions ****************************/

#define XIIC_MSB_OFFSET                3

#define XIIC_REG_OFFSET 0x100 + XIIC_MSB_OFFSET

/*
 * Register offsets in bytes from RegisterBase. Three is added to the
 * base offset to access LSB (IBM style) of the word
 */
#define XIIC_CR_REG_OFFSET   0x00+XIIC_REG_OFFSET	/* Control Register   */
#define XIIC_SR_REG_OFFSET   0x04+XIIC_REG_OFFSET	/* Status Register    */
#define XIIC_DTR_REG_OFFSET  0x08+XIIC_REG_OFFSET	/* Data Tx Register   */
#define XIIC_DRR_REG_OFFSET  0x0C+XIIC_REG_OFFSET	/* Data Rx Register   */
#define XIIC_ADR_REG_OFFSET  0x10+XIIC_REG_OFFSET	/* Address Register   */
#define XIIC_TFO_REG_OFFSET  0x14+XIIC_REG_OFFSET	/* Tx FIFO Occupancy  */
#define XIIC_RFO_REG_OFFSET  0x18+XIIC_REG_OFFSET	/* Rx FIFO Occupancy  */
#define XIIC_TBA_REG_OFFSET  0x1C+XIIC_REG_OFFSET	/* 10 Bit Address reg */
#define XIIC_RFD_REG_OFFSET  0x20+XIIC_REG_OFFSET	/* Rx FIFO Depth reg  */
#define XIIC_GPO_REG_OFFSET  0x24+XIIC_REG_OFFSET	/* Output Register    */

/* Control Register masks */

#define XIIC_CR_ENABLE_DEVICE_MASK        0x01	/* Device enable = 1      */
#define XIIC_CR_TX_FIFO_RESET_MASK        0x02	/* Transmit FIFO reset=1  */
#define XIIC_CR_MSMS_MASK                 0x04	/* Master starts Txing=1  */
#define XIIC_CR_DIR_IS_TX_MASK            0x08	/* Dir of tx. Txing=1     */
#define XIIC_CR_NO_ACK_MASK               0x10	/* Tx Ack. NO ack = 1     */
#define XIIC_CR_REPEATED_START_MASK       0x20	/* Repeated start = 1     */
#define XIIC_CR_GENERAL_CALL_MASK         0x40	/* Gen Call enabled = 1   */

/* Status Register masks */

#define XIIC_SR_GEN_CALL_MASK             0x01	/* 1=a mstr issued a GC   */
#define XIIC_SR_ADDR_AS_SLAVE_MASK        0x02	/* 1=when addr as slave   */
#define XIIC_SR_BUS_BUSY_MASK             0x04	/* 1 = bus is busy        */
#define XIIC_SR_MSTR_RDING_SLAVE_MASK     0x08	/* 1=Dir: mstr <-- slave  */
#define XIIC_SR_TX_FIFO_FULL_MASK         0x10	/* 1 = Tx FIFO full       */
#define XIIC_SR_RX_FIFO_FULL_MASK         0x20	/* 1 = Rx FIFO full       */
#define XIIC_SR_RX_FIFO_EMPTY_MASK        0x40	/* 1 = Rx FIFO empty      */
#define XIIC_SR_TX_FIFO_EMPTY_MASK        0x80	/* 1 = Tx FIFO empty      */

/* Interrupt Status Register masks    Interrupt occurs when...       */

#define XIIC_INTR_ARB_LOST_MASK           0x01	/* 1 = arbitration lost   */
#define XIIC_INTR_TX_ERROR_MASK           0x02	/* 1=Tx error/msg complete */
#define XIIC_INTR_TX_EMPTY_MASK           0x04	/* 1 = Tx FIFO/reg empty  */
#define XIIC_INTR_RX_FULL_MASK            0x08	/* 1=Rx FIFO/reg=OCY level */
#define XIIC_INTR_BNB_MASK                0x10	/* 1 = Bus not busy       */
#define XIIC_INTR_AAS_MASK                0x20	/* 1 = when addr as slave */
#define XIIC_INTR_NAAS_MASK               0x40	/* 1 = not addr as slave  */
#define XIIC_INTR_TX_HALF_MASK            0x80	/* 1 = TX FIFO half empty */

#define XIIC_TX_ADDR_SENT             0x00
#define XIIC_TX_ADDR_MSTR_RECV_MASK   0x02

/* The following constants specify the depth of the FIFOs */

#define IIC_RX_FIFO_DEPTH         16	/* Rx fifo capacity               */
#define IIC_TX_FIFO_DEPTH         16	/* Tx fifo capacity               */

/* The following constants specify groups of interrupts that are typically
 * enabled or disables at the same time
 */
#define XIIC_TX_INTERRUPTS                                          \
            (XIIC_INTR_TX_ERROR_MASK | XIIC_INTR_TX_EMPTY_MASK |    \
             XIIC_INTR_TX_HALF_MASK)

#define XIIC_TX_RX_INTERRUPTS (XIIC_INTR_RX_FULL_MASK | XIIC_TX_INTERRUPTS)

/* The following constants are used with the following macros to specify the
 * operation, a read or write operation.
 */
#define XIIC_READ_OPERATION  1
#define XIIC_WRITE_OPERATION 0

/* The following constants are used with the transmit FIFO fill function to
 * specify the role which the IIC device is acting as, a master or a slave.
 */
#define XIIC_MASTER_ROLE     1
#define XIIC_SLAVE_ROLE      0

/*
 * The following constants are used with Transmit Function (XIic_Send) to
 * specify whether to STOP after the current transfer of data or own the bus
 * with a Repeated start.
 */
#define XIIC_STOP		0x00
#define XIIC_REPEATED_START	0x01

 /*
  * Tx Fifo upper bit masks.
  */

#define XIIC_TX_DYN_START_MASK            0x0100 /* 1 = Set dynamic start */
#define XIIC_TX_DYN_STOP_MASK             0x0200 /* 1 = Set dynamic stop */


/**************************** Type Definitions ******************************/


/***************** Macros (Inline Functions) Definitions ********************/

/************************** Constant Definitions *****************************/

/*
 * The following constants define the register offsets for the Interrupt
 * registers. There are some holes in the memory map for reserved addresses
 * to allow other registers to be added and still match the memory map of the
 * interrupt controller registers
 */
#define XIIC_DGIER_OFFSET    0x1C /* Device Global Interrupt Enable Register */
#define XIIC_IISR_OFFSET     0x20 /* Interrupt Status Register */
#define XIIC_IIER_OFFSET     0x28 /* Interrupt Enable Register */
#define XIIC_RESETR_OFFSET   0x40 /* Reset Register */


#define XIIC_RESET_MASK             0xAUL

/*
 * The following constant is used for the device global interrupt enable
 * register, to enable all interrupts for the device, this is the only bit
 * in the register
 */
#define XIIC_GINTR_ENABLE_MASK      0x80000000UL


/**************************** Type Definitions *******************************/


/***************** Macros (Inline Functions) Definitions *********************/


/******************************************************************************
*
* This macro resets the IIC device.
*
* @param	RegBaseAddress is the base address of the IIC device.
*
* @return	None.
*
* @note		C-Style signature:
*		void XIIC_RESET(u32 RegBaseAddress);
*
*		The complete IIC core is Reset on giving a software reset to
*		the IIC core. Some previous versions of the core only reset
*		the Interrupt Logic/Registers, please refer to the HW
*		specification for futher details.
*
******************************************************************************/
#define XIIC_RESET(RegBaseAddress) \
	XIo_Out32(RegBaseAddress + XIIC_RESETR_OFFSET, XIIC_RESET_MASK)

/******************************************************************************
*
* This macro disables all interrupts for the device by writing to the Global
* interrupt enable register.  This register provides the ability to disable
* interrupts without any modifications to the interrupt enable register such
* that it is minimal effort to restore the interrupts to the previous enabled
* state.  The corresponding function, XIIC_GINTR_ENABLE, is provided to
* restore the interrupts to the previous enabled state.  This function is
* designed to be used in critical sections of device drivers such that it is
* not necessary to disable other device interrupts.
*
* @param	RegBaseAddress is the base address of the IIC device.
*
* @return	None.
*
* @note		C-Style signature:
*		void XIIC_GINTR_DISABLE(u32 RegBaseAddress);
*
******************************************************************************/
#define XIIC_GINTR_DISABLE(RegBaseAddress)				\
	XIo_Out32((RegBaseAddress) + XIIC_DGIER_OFFSET, 0)

/******************************************************************************
*
* This macro writes to the global interrupt enable register to enable
* interrupts from the device.  This register provides the ability to enable
* interrupts without any modifications to the interrupt enable register such
* that it is minimal effort to restore the interrupts to the previous enabled
* state. This function does not enable individual interrupts as the interrupt
* enable register must be set appropriately.  This function is designed to be
* used in critical sections of device drivers such that it is not necessary to
* disable other device interrupts.
*
* @param	RegBaseAddress is the base address of the IIC device.
*
* @return	None.
*
* @note		C-Style signature:
*		void XIIC_GINTR_ENABLE(u32 RegBaseAddress);
*
******************************************************************************/
#define XIIC_GINTR_ENABLE(RegBaseAddress)				\
	XIo_Out32((RegBaseAddress) + XIIC_DGIER_OFFSET, XIIC_GINTR_ENABLE_MASK)

/******************************************************************************
*
* This function determines if interrupts are enabled at the global level by
* reading the gloabl interrupt register. This register provides the ability to
* disable interrupts without any modifications to the interrupt enable register
* such that it is minimal effort to restore the interrupts to the previous
* enabled state.
*
* @param	RegBaseAddress is the base address of the IIC device.
*
* @return
*		- TRUE if global interrupts are enabled.
*		- FALSE if global interrupts are disabled.
*
* @note		C-Style signature:
*		int XIIC_IS_GINTR_ENABLED(u32 RegBaseAddress);
*
******************************************************************************/
#define XIIC_IS_GINTR_ENABLED(RegBaseAddress)				\
	(XIo_In32((RegBaseAddress) + XIIC_DGIER_OFFSET) ==		\
		XIIC_GINTR_ENABLE_MASK)

/******************************************************************************
*
*
* This function sets the Interrupt status register to the specified value.
* This register indicates the status of interrupt sources for the device.
* The status is independent of whether interrupts are enabled such that
* the status register may also be polled when interrupts are not enabled.
*
* Each bit of the register correlates to a specific interrupt source within the
* IIC device.  All bits of this register are latched. Setting a bit which is zero
* within this register causes an interrupt to be generated.  The device global
* interrupt enable register and the device interrupt enable register must be set
* appropriately to allow an interrupt to be passed out of the device. The
* interrupt is cleared by writing to this register with the bits to be
* cleared set to a one and all others to zero.  This register implements a
* toggle on write functionality meaning any bits which are set in the value
* written cause the bits in the register to change to the opposite state.
*
* This function writes only the specified value to the register such that
* some status bits may be set and others cleared.  It is the caller's
* responsibility to get the value of the register prior to setting the value
* to prevent an destructive behavior.
*
* @param	RegBaseAddress is the base address of the IIC device.
* @param	Status contains the value to be written to the Interrupt
*		status register.
*
* @return	None.
*
* @note		C-Style signature:
*		void XIIC_WRITE_IISR(u32 RegBaseAddress, u32 Status);
*
******************************************************************************/
#define XIIC_WRITE_IISR(RegBaseAddress, Status)				\
	XIo_Out32((RegBaseAddress) + XIIC_IISR_OFFSET, (Status))

/******************************************************************************
*
*
* This function gets the contents of the Interrupt Status Register.
* This register indicates the status of interrupt sources for the device.
* The status is independent of whether interrupts are enabled such
* that the status register may also be polled when interrupts are not enabled.
*
* Each bit of the register correlates to a specific interrupt source within the
* device.  All bits of this register are latched.  Writing a 1 to a bit within
* this register causes an interrupt to be generated if enabled in the interrupt
* enable register and the global interrupt enable is set.  Since the status is
* latched, each status bit must be acknowledged in order for the bit in the
* status register to be updated.  Each bit can be acknowledged by writing a
* 0 to the bit in the status register.

* @param	RegBaseAddress is the base address of the IIC device.
*
* @return	A status which contains the value read from the Interrupt
*		Status Register.
*
* @note		C-Style signature:
*		u32 XIIC_READ_IISR(u32 RegBaseAddress);
*
******************************************************************************/
#define XIIC_READ_IISR(RegBaseAddress) 					\
	XIo_In32((RegBaseAddress) + XIIC_IISR_OFFSET)

/******************************************************************************
*
* This function sets the contents of the Interrupt Enable Register . This
* register controls which interrupt sources of the IIC device are allowed to
* generate an interrupt. The global interrupt enable register and the device
* interrupt enable register must also be set appropriately for an interrupt to be
* passed out of the device.
*
* Each bit of the register correlates to a specific interrupt source within the
* device.  Setting a bit in this register enables the interrupt source to generate
* an interrupt.  Clearing a bit in this register disables interrupt generation
* for that interrupt source.
*
* This function writes only the specified value to the register such that
* some interrupt sources may be enabled and others disabled.  It is the
* caller's responsibility to get the value of the interrupt enable register
* prior to setting the value to prevent a destructive behavior.
*
* @param	RegBaseAddress is the base address of the IIC device.
* @param	Enable contains the value to be written to the Interrupt Enable
*		Register.
*
* @return 	None
*
* @note		C-Style signature:
*		void XIIC_WRITE_IIER(u32 RegBaseAddress, u32 Enable);
*
******************************************************************************/
#define XIIC_WRITE_IIER(RegBaseAddress, Enable)				\
	XIo_Out32((RegBaseAddress) + XIIC_IIER_OFFSET, (Enable))

/******************************************************************************
*
*
* This function gets the Interrupt enable register contents.  This register
* controls which interrupt sources of the device are allowed to generate an
* interrupt.  The global interrupt enable register and the device interrupt
* enable register must also be set appropriately for an interrupt to be
* passed out of the IIC device.
*
* Each bit of the register correlates to a specific interrupt source within the
* IIC device. Setting a bit in this register enables the interrupt source to
* generate an interrupt.  Clearing a bit in this register disables interrupt
* generation for that interrupt source.
*
* @param	RegBaseAddress is the base address of the IIC device.
*
* @return	The contents read from the Interrupt Enable Register.
*
* @note		C-Style signature:
*		u32 XIIC_READ_IIER(u32 RegBaseAddress)
*
******************************************************************************/
#define XIIC_READ_IIER(RegBaseAddress)					\
	XIo_In32((RegBaseAddress) + XIIC_IIER_OFFSET)

/************************** Function Prototypes ******************************/


/******************************************************************************
*
* This macro reads a register in the IIC device using an 8 bit read operation.
* This macro does not do any checking to ensure that the register exists if the
* register may be excluded due to parameterization, such as the GPO Register.
*
* @param	BaseAddress of the IIC device.
* @param	RegisterOffset contains the offset of the register from the
*		device base address.
*
* @return	The value read from the register.
*
* @note		C-Style signature:
* 		u8 XIic_mReadReg(u32 BaseAddress, int RegisterOffset);
*
******************************************************************************/
#define XIic_mReadReg(BaseAddress, RegisterOffset) 			\
	XIo_In8((BaseAddress) + (RegisterOffset))

/******************************************************************************
*
* This macro writes a register in the IIC device using an 8 bit write
* operation. This macro does not do any checking to ensure that the register
* exists if the register may be excluded due to parameterization, such as the
* GPO Register.
*
* @param	BaseAddress of the IIC device.
* @param	RegisterOffset contains the offset of the register from the
*		device base address.
* @param	Data contains the data to be written to the register.
*
* @return	None.
*
* @note		C-Style signature:
*		void XIic_mWriteReg(u32 BaseAddress, int RegisterOffset,
					u8 Data);
*
******************************************************************************/
#define XIic_mWriteReg(BaseAddress, RegisterOffset, Data) 		\
	XIo_Out8((BaseAddress) + (RegisterOffset), (Data))

/******************************************************************************
*
* This macro clears the specified interrupt in the Interrupt status
* register.  It is non-destructive in that the register is read and only the
* interrupt specified is cleared.  Clearing an interrupt acknowledges it.
*
* @param	BaseAddress contains the IIC registers base address.
* @param	InterruptMask contains the interrupts to be disabled
*
* @return	None.
*
* @note		C-Style signature:
*		void XIic_mClearIisr(u32 BaseAddress, u32 InterruptMask);
*
******************************************************************************/
#define XIic_mClearIisr(BaseAddress, InterruptMask)			\
	XIIC_WRITE_IISR((BaseAddress),					\
	XIIC_READ_IISR(BaseAddress) & (InterruptMask))

/******************************************************************************
*
* This macro sends the address for a 7 bit address during both read and write
* operations. It takes care of the details to format the address correctly.
* This macro is designed to be called internally to the drivers.
*
* @param	BaseAddress contains the base address of the IIC Device.
* @param	SlaveAddress contains the address of the slave to send to.
* @param	Operation indicates XIIC_READ_OPERATION or XIIC_WRITE_OPERATION
*
* @return	None.
*
* @note		C-Style signature:
* 		void XIic_mSend7BitAddress(u32 BaseAddress, u8 SlaveAddress,
*						u8 Operation);
*
******************************************************************************/
#define XIic_mSend7BitAddress(BaseAddress, SlaveAddress, Operation)	\
{									\
	u8 LocalAddr = (u8)(SlaveAddress << 1);				\
	LocalAddr = (LocalAddr & 0xFE) | (Operation);			\
	XIo_Out8(BaseAddress + XIIC_DTR_REG_OFFSET, LocalAddr);		\
}

/******************************************************************************
*
* This macro sends the address for a 7 bit address during both read and write
* operations. It takes care of the details to format the address correctly.
* This macro is designed to be called internally to the drivers.
*
* @param	BaseAddress contains the base address of the IIC Device.
* @param	SlaveAddress contains the address of the slave to send to.
* @param	Operation indicates XIIC_READ_OPERATION or XIIC_WRITE_OPERATION.
*
* @return	None.
*
* @note		C-Style signature:
* 		void XIic_mDynSend7BitAddress(u32 BaseAddress, u8 SlaveAddress,
*						u8 Operation);
*
******************************************************************************/
#define XIic_mDynSend7BitAddress(BaseAddress, SlaveAddress, Operation)	\
{									\
	u8 LocalAddr = (u8)(SlaveAddress << 1);				\
	LocalAddr = (LocalAddr & 0xFE) | (Operation);			\
	XIo_Out16(BaseAddress + XIIC_DTR_REG_OFFSET - 1,		\
			XIIC_TX_DYN_START_MASK | LocalAddr);		\
}

/******************************************************************************
*
* This macro sends the address, start and stop for a 7 bit address during both
* write operations. It takes care of the details to format the address
* correctly.
* This macro is designed to be called internally to the drivers.
*
* @param	BaseAddress contains the base address of the IIC Device.
* @param	SlaveAddress contains the address of the slave to send to.
* @param	Operation indicates XIIC_WRITE_OPERATION.
*
* @return	None.
*
* @note		C-Style signature:
* 		void XIic_mDynSendStartStopAddress(u32 BaseAddress,
*							u8 SlaveAddress,
*							u8 Operation);
*
******************************************************************************/
#define XIic_mDynSendStartStopAddress(BaseAddress, SlaveAddress, Operation)  \
{									     \
	u8 LocalAddr = (u8)(SlaveAddress << 1);				     \
	LocalAddr = (LocalAddr & 0xFE) | (Operation);			     \
	XIo_Out16(BaseAddress + XIIC_DTR_REG_OFFSET - 1,		     \
		XIIC_TX_DYN_START_MASK | XIIC_TX_DYN_STOP_MASK | LocalAddr); \
}

/******************************************************************************
*
* This macro sends a stop condition on IIC bus for Dynamic logic.
*
* @param	BaseAddress contains the base address of the IIC Device.
* @param	ByteCount is the number of Rx bytes received before the master.
*		doesn't respond with ACK.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
#define XIic_mDynSendStop(BaseAddress, ByteCount)			       \
{									       \
	XIo_Out16(BaseAddress + XIIC_DTR_REG_OFFSET-1, XIIC_TX_DYN_STOP_MASK | \
    		  ByteCount); 						       \
}

/************************** Function Prototypes *****************************/

unsigned XIic_Recv(u32 BaseAddress, u8 Address,
		   u8 *BufferPtr, unsigned ByteCount, u8 Option);

unsigned XIic_Send(u32 BaseAddress, u8 Address,
		   u8 *BufferPtr, unsigned ByteCount, u8 Option);

unsigned XIic_DynRecv(u32 BaseAddress, u8 Address, u8 *BufferPtr, u8 ByteCount);

unsigned XIic_DynSend(u32 BaseAddress, u16 Address, u8 *BufferPtr,
		      u8 ByteCount, u8 Option);

int XIic_DynInit(u32 BaseAddress);


#ifdef __cplusplus
}
#endif

#endif /* end of protection macro */

