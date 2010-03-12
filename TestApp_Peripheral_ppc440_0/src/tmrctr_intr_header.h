#define TESTAPP_GEN

/* $Id: tmrctr_intr_header.h,v 1.1 2008/08/27 11:34:05 sadanan Exp $ */


#include "xbasic_types.h"
#include "xstatus.h"


XStatus TmrCtrIntrExample(XIntc* IntcInstancePtr,
                          XTmrCtr* InstancePtr,
                          Xuint16 DeviceId,
                          Xuint16 IntrId,
                          Xuint8 TmrCtrNumber);


