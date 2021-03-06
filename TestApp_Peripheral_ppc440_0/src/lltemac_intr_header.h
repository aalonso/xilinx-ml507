#define TESTAPP_GEN

/* $Id: lltemac_intr_header.h,v 1.1 2008/09/08 22:03:11 wyang Exp $ */


#include "xbasic_types.h"
#include "xstatus.h"

int TemacFifoIntrExample(XIntc * IntcInstancePtr,
                         XLlTemac * TemacInstancePtr,
                         XLlFifo * FifoInstancePtr,
                         u16 TemacDeviceId,
                         u16 FifoDeviceId, u16 TemacIntrId, u16 FifoIntrId);


int TemacSgDmaIntrExample(XIntc * IntcInstancePtr,
                          XLlTemac * TemacInstancePtr,
                          XLlDma * DmaInstancePtr,
                          u16 TemacDeviceId,
                          u16 TemacIntrId, u16 DmaRxIntrId, u16 DmaTxIntrId);



