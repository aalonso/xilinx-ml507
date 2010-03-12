#define TESTAPP_GEN

/* $Id: wdttb_intr_header.h,v 1.1 2008/08/27 12:42:16 sadanan Exp $ */


#include "xbasic_types.h"
#include "xstatus.h"

XStatus WdtTbIntrExample(XIntc *IntcInstancePtr, \
                         XWdtTb *WdtTbInstancePtr, \
                         Xuint16 WdtTbDeviceId, \
                         Xuint16 WdtTbIntrId);

