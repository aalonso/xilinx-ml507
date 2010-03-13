################################################################################
##
## Copyright (c) 2005 Xilinx, Inc. All Rights Reserved.
## You may copy and modify these files for your own internal use solely with
## Xilinx programmable logic devices and Xilinx EDK system or create IP
## modules solely for Xilinx programmable logic devices and Xilinx EDK system.
## No rights are granted to distribute any files unless they are distributed in
## Xilinx programmable logic devices.
##
## clock_generator_v2_1_0.tcl
##
################################################################################

# load clock generator library according to the operating system running
proc load_core_libs {} {
  global tcl_platform env tcl_library

  if [ info exists ::env(MY_XILINX_EDK) ]   {
    set basedir $env(MY_XILINX_EDK)
  } elseif [ info exists ::env(XILINX_EDK) ] {
    set basedir $env(XILINX_EDK)
  } else {
    error "Neither MY_XILINX_EDK nor XILINX_EDK defined.\n" "" "mdt_error"
  }

  switch -glob $tcl_platform(os) {
    "Windows*" {
      set plat_os nt
      set libfile libMdtClkGen.dll
    }
    "Linux" {
      switch -glob $tcl_platform(wordSize) {
        "4" {
          set plat_os lin
          set libfile libMdtClkGen.so
        }
        "8" {
          set plat_os lin64
          set libfile libMdtClkGen.so
        }
        default {
          error "Word length is not 4 or 8.\n" "" "mdt_error"
        }
      }
    }
    "SunOS" {
      set plat_os sol
      set libfile libMdtClkGen.so
    }
    default {
      error "Unknown platform.\n" "" "mdt_error"
    }
  }
  
  if { [file exists $basedir/bin/$plat_os/$libfile] } {
    if { [catch {load $basedir/bin/$plat_os/$libfile} err_msg] } {
      error " $err_msg\n" "" "mdt_error"
    }
  } elseif { [file exists $basedir/lib/$plat_os/$libfile] } {
    if { [catch {load $basedir/lib/$plat_os/$libfile} err_msg] } {
      error " $err_msg\n" "" "mdt_error"
    }
  } else {
    error " Failed to load $libfile.\n" "" "mdt_error"
  }
}

proc update_clock_circuit {mhsinst} {

  #puts "---------- Update Clock Circuit ----------"

  load_core_libs
  #puts "---------- Clock Libraty loaded ----------"

  set caller_name [xget_nameofexecutable]
  if { ! ( [string match "platgen" $caller_name] == 1 || [string match "simgen" $caller_name] == 1 ) } {
    return 0;
  }
  #puts "---------- Check Caller passed ----------"

  set clk_gen [xget_hw_parameter_value $mhsinst "C_CLK_GEN"]
  if { ($clk_gen != "UPDATE") && ($clk_gen != "update") } {
    return 0;
  }
  #puts "---------- Check C_CLK_GEN set ----------"
  #puts $clk_gen
  
  set family [xget_hw_parameter_value $mhsinst "C_FAMILY"]
  if {$family != ""} {
  } else {
    error " Clock generator requires C_FAMILY to be set.\n" "" "mdt_error"
  }
  #puts "---------- Check C_FAMILY set ----------"
  #puts $family

  set res [xgen_clock_circuit $mhsinst 6]
  #puts "---------- Run clock generation ----------"

  set clk_gen [xget_hw_parameter_value $mhsinst "C_CLK_GEN"]
  if {$clk_gen != "PASSED"} {
    error " Clock generator failed to generate, please refer to the log file for details.\n" "" "mdt_error"
  }
  #puts "---------- Check C_CLK_GEN set ----------"
  #puts $clk_gen

  set mhs_handle   [xget_hw_parent_handle $mhsinst]  
  #puts "---------- get the MHS handle ----------"

  set caller_name [xget_nameofexecutable]
  if { ! ( [string match "platgen" $caller_name] == 1 ) } {
    return $res;
  }
  #puts "---------- Check Caller for SysLevel update passed ----------"

  set res [xgen_system_update $mhs_handle 8]
  #puts "---------- Run system update ----------"

  return $res
}
