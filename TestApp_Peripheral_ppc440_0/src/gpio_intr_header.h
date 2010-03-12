#define TESTAPP_GEN

/* $Id: gpio_intr_header.h,v 1.1 2008/09/01 10:16:46 sadanan Exp $ */


#include "xbasic_types.h"
#include "xstatus.h"


XStatus GpioIntrExample(XIntc* IntcInstancePtr,
                        XGpio* InstancePtr,
                        Xuint16 DeviceId,
                        Xuint16 IntrId,
                        Xuint16 IntrMask,
                        Xuint32 *DataRead);



