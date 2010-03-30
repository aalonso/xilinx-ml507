#!/bin/sh
# Start xmd debug console
# Adrian Alonso <aalonso00@gmail.com>

# Set Xilinx edk tools
if [ -z ${XILINX_EDK} ]; then
    source xlnx-env
fi

xmd -xmp system.xmp -opt etc/xmd_ppc440_0.opt
