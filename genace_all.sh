#!/bin/sh
# Generate ace files
# Adrian Alonso <aalonso00@gmail.com>

# Set Xilinx edk tools
if [ -z ${XILINX_EDK} ]; then
    source xlnx-env
fi

# Remove existing ace files
if [ -d ML50X ]; then
    rm -fr ML50X
fi

for i in {0..7}
do
    mkdir -p ML50X/cfg${i}
done


xmd -tcl genace.tcl -hw implementation/download.bit -ace ml507_bsp_bootloop.ace -board ml507
cp -p ml507_bsp_bootloop.ace ML50X/cfg0

if [ -f u-boot ]; then
    xmd -tcl genace.tcl -hw implementation/system.bit -elf u-boot \
    -ace ml507_sys_u-boot.ace -board ml507
    cp -p ml507_sys_u-boot.ace ML50X/cfg1
    xmd -tcl genace.tcl -hw implementation/download.bit -elf u-boot \
    -ace ml507_bsp_u-boot.ace -board ml507
    cp -p ml507_bsp_u-boot.ace ML50X/cfg2
else
    xmd -tcl genace.tcl -hw implementation/download.bit -elf TestApp_Memory_ppc440_0/executable.elf \
    -ace ml507_bsp_testapp_mem.ace -board ml507
    xmd -tcl genace.tcl -hw implementation/download.bit -elf TestApp_Peripheral_ppc440_0/executable.elf \
    -ace ml507_bsp_testapp_periph.ace -board ml507

    cp -p ml507_bsp_testapp_mem.ace ML50X/cfg1
    cp -p ml507_bsp_testapp_periph.ace ML50X/cfg2
fi

rm ml507_bsp_* 
rm ml507_sys_* 

echo "Done"
