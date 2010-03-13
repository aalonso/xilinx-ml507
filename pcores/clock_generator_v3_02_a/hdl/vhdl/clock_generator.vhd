-------------------------------------------------------------------------------
-- $Id: clock_generator.vhd,v 1.1.2.1 2009/10/06 18:11:14 xic Exp $
-------------------------------------------------------------------------------
-- clock_generator.vhd - Entity and architecture
--
--  ***************************************************************************
--  **  Copyright(C) 2003 by Xilinx, Inc. All rights reserved.               **
--  **                                                                       **
--  **  This text contains proprietary, confidential                         **
--  **  information of Xilinx, Inc. , is distributed by                      **
--  **  under license from Xilinx, Inc., and may be used,                    **
--  **  copied and/or disclosed only pursuant to the terms                   **
--  **  of a valid license agreement with Xilinx, Inc.                       **
--  **                                                                       **
--  **  Unmodified source code is guaranteed to place and route,             **
--  **  function and run at speed according to the datasheet                 **
--  **  specification. Source code is provided "as-is", with no              **
--  **  obligation on the part of Xilinx to provide support.                 **
--  **                                                                       **
--  **  Xilinx Hotline support of source code IP shall only include          **
--  **  standard level Xilinx Hotline support, and will only address         **
--  **  issues and questions related to the standard released Netlist        **
--  **  version of the core (and thus indirectly, the original core source). **
--  **                                                                       **
--  **  The Xilinx Support Hotline does not have access to source            **
--  **  code and therefore cannot answer specific questions related          **
--  **  to source HDL. The Xilinx Support Hotline will only be able          **
--  **  to confirm the problem in the Netlist version of the core.           **
--  **                                                                       **
--  **  This copyright and support notice must be retained as part           **
--  **  of this text at all times.                                           **
--  ***************************************************************************
--
-------------------------------------------------------------------------------
-- Filename:        clock_generator.vhd
--
-- Description:     
--                  
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:   
--              clock_generator.vhd
--
-------------------------------------------------------------------------------
-- Author:          xic
-- Revision:        $Revision: 1.1.2.1 $
-- Date:            $Date: 2009/10/06 18:11:14 $
--
-- History:
--   xic  2007-03-12    First Version
--
-------------------------------------------------------------------------------
-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "clk", "clk_div#", "clk_#x" 
--      reset signals:                          "rst", "rst_n" 
--      generics:                               "C_*" 
--      user defined types:                     "*_TYPE" 
--      state machine next state:               "*_ns" 
--      state machine current state:            "*_cs" 
--      combinatorial signals:                  "*_com" 
--      pipelined or register delay signals:    "*_d#" 
--      counter signals:                        "*cnt*"
--      clock enable signals:                   "*_ce" 
--      internal version of output port         "*_i"
--      device pins:                            "*_pin" 
--      ports:                                  - Names begin with Uppercase 
--      processes:                              "*_PROCESS" 
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library Unisim;
use Unisim.vcomponents.all;

-------------------------------------------------------------------------------
-- clock selection
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- reset selection
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- clock generator
-------------------------------------------------------------------------------

entity clock_generator is
  generic (
    --------------------------------------------------------------------------
    -- CLKGEN parameters
    --------------------------------------------------------------------------
    C_FAMILY                      : string  := "virtex5"; 
    C_SPEEDGRADE                  : string  := "0"; 
    C_EXT_RESET_HIGH              : integer := 1;
    C_CLK_GEN                     : string  := "update";
    -- clkout connection parameters
    C_CLKOUT0_MODULE              : string  := "NONE"; -- CLKGEN|DCM0-3|PLL0-1
    C_CLKOUT0_PORT                : string  := "NONE"; -- CLKGEN_IN|DCMPLL_OUT
    C_CLKOUT1_MODULE              : string  := "NONE"; 
    C_CLKOUT1_PORT                : string  := "NONE";
    C_CLKOUT2_MODULE              : string  := "NONE"; 
    C_CLKOUT2_PORT                : string  := "NONE"; 
    C_CLKOUT3_MODULE              : string  := "NONE"; 
    C_CLKOUT3_PORT                : string  := "NONE"; 
    C_CLKOUT4_MODULE              : string  := "NONE"; 
    C_CLKOUT4_PORT                : string  := "NONE"; 
    C_CLKOUT5_MODULE              : string  := "NONE"; 
    C_CLKOUT5_PORT                : string  := "NONE"; 
    C_CLKOUT6_MODULE              : string  := "NONE"; 
    C_CLKOUT6_PORT                : string  := "NONE"; 
    C_CLKOUT7_MODULE              : string  := "NONE"; 
    C_CLKOUT7_PORT                : string  := "NONE"; 
    C_CLKOUT8_MODULE              : string  := "NONE"; 
    C_CLKOUT8_PORT                : string  := "NONE"; 
    C_CLKOUT9_MODULE              : string  := "NONE"; 
    C_CLKOUT9_PORT                : string  := "NONE"; 
    C_CLKOUT10_MODULE             : string  := "NONE"; 
    C_CLKOUT10_PORT               : string  := "NONE"; 
    C_CLKOUT11_MODULE             : string  := "NONE"; 
    C_CLKOUT11_PORT               : string  := "NONE"; 
    C_CLKOUT12_MODULE             : string  := "NONE"; 
    C_CLKOUT12_PORT               : string  := "NONE"; 
    C_CLKOUT13_MODULE             : string  := "NONE"; 
    C_CLKOUT13_PORT               : string  := "NONE"; 
    C_CLKOUT14_MODULE             : string  := "NONE"; 
    C_CLKOUT14_PORT               : string  := "NONE"; 
    C_CLKOUT15_MODULE             : string  := "NONE"; 
    C_CLKOUT15_PORT               : string  := "NONE"; 
    C_CLKFBOUT_MODULE             : string  := "NONE"; 
    C_CLKFBOUT_PORT               : string  := "NONE"; 
    C_PSDONE_MODULE               : string  := "NONE"; 
    -- C_PSDONE_PORT              : string  := "NONE"; 
    --------------------------------------------------------------------------
    -- PLL0 parameters
    --------------------------------------------------------------------------
    -- pll module parameters
    C_PLL0_DIVCLK_DIVIDE          : integer := 1;          -- D 
    C_PLL0_CLKFBOUT_MULT          : integer := 1;          -- M
    C_PLL0_CLKFBOUT_PHASE         : real    := 0.0;  
    C_PLL0_CLKIN1_PERIOD          : real    := 0.000;  
    -- C_PLL0_CLKIN2_PERIOD       : real    := 0.000;  
    C_PLL0_CLKOUT0_DIVIDE         : integer := 1;          -- Do0
    C_PLL0_CLKOUT0_DUTY_CYCLE     : real    := 0.5;  
    C_PLL0_CLKOUT0_PHASE          : real    := 0.0;  
    C_PLL0_CLKOUT1_DIVIDE         : integer := 1;          -- Do1
    C_PLL0_CLKOUT1_DUTY_CYCLE     : real    := 0.5;  
    C_PLL0_CLKOUT1_PHASE          : real    := 0.0;  
    C_PLL0_CLKOUT2_DIVIDE         : integer := 1;          -- Do2
    C_PLL0_CLKOUT2_DUTY_CYCLE     : real    := 0.5;  
    C_PLL0_CLKOUT2_PHASE          : real    := 0.0;  
    C_PLL0_CLKOUT3_DIVIDE         : integer := 1;          -- Do3
    C_PLL0_CLKOUT3_DUTY_CYCLE     : real    := 0.5;  
    C_PLL0_CLKOUT3_PHASE          : real    := 0.0;  
    C_PLL0_CLKOUT4_DIVIDE         : integer := 1;          -- Do4
    C_PLL0_CLKOUT4_DUTY_CYCLE     : real    := 0.5;  
    C_PLL0_CLKOUT4_PHASE          : real    := 0.0;  
    C_PLL0_CLKOUT5_DIVIDE         : integer := 1;          -- Do5
    C_PLL0_CLKOUT5_DUTY_CYCLE     : real    := 0.5;  
    C_PLL0_CLKOUT5_PHASE          : real    := 0.0;  
    -- C_PLL0_EN_REL              : boolean := false;  
    -- C_PLL0_PLL_PMCD_MODE       : boolean := false; 
    C_PLL0_BANDWIDTH              : string  := "OPTIMIZED";  
    C_PLL0_COMPENSATION           : string  := "SYSTEM_SYNCHRONOUS";  
    C_PLL0_REF_JITTER             : real    := 0.100; 
    C_PLL0_RESET_ON_LOSS_OF_LOCK  : boolean := false;  
    C_PLL0_RST_DEASSERT_CLK       : string  := "CLKIN1";
    C_PLL0_EXT_RESET_HIGH         : integer := 1;
    C_PLL0_FAMILY                 : string  := "virtex5";
    -- parameters for pcore
    C_PLL0_CLKOUT0_DESKEW_ADJUST  : string  := "NONE";     -- For PPC
    C_PLL0_CLKOUT1_DESKEW_ADJUST  : string  := "NONE";     -- For CrossBar
    C_PLL0_CLKOUT2_DESKEW_ADJUST  : string  := "NONE";     -- Since EDK_L.18, "PPC";      -- For others
    C_PLL0_CLKOUT3_DESKEW_ADJUST  : string  := "NONE"; 
    C_PLL0_CLKOUT4_DESKEW_ADJUST  : string  := "NONE"; 
    C_PLL0_CLKOUT5_DESKEW_ADJUST  : string  := "NONE"; 
    C_PLL0_CLKFBOUT_DESKEW_ADJUST : string  := "NONE"; 
    C_PLL0_CLKIN1_BUF             : boolean := false;
    -- C_PLL0_CLKIN2_BUF          : boolean := false;
    C_PLL0_CLKFBOUT_BUF           : boolean := false;
    C_PLL0_CLKOUT0_BUF            : boolean := false;  -- wrapper
    C_PLL0_CLKOUT1_BUF            : boolean := false;  --
    C_PLL0_CLKOUT2_BUF            : boolean := false;  --
    C_PLL0_CLKOUT3_BUF            : boolean := false;  --
    C_PLL0_CLKOUT4_BUF            : boolean := false;  --
    C_PLL0_CLKOUT5_BUF            : boolean := false;  --
    -- pll connection parameters
    C_PLL0_CLKIN1_MODULE          : string  := "NONE"; -- CLKGEN|DCM0-3|PLL0-1 
    C_PLL0_CLKIN1_PORT            : string  := "NONE"; -- CLKGEN_IN|DCMPLL_OUT
    C_PLL0_CLKFBIN_MODULE         : string  := "NONE"; 
    C_PLL0_CLKFBIN_PORT           : string  := "NONE";
    C_PLL0_RST_MODULE             : string  := "NONE"; -- CLKGEN|DCM0-3|PLL0-1  
    --------------------------------------------------------------------------
    -- PLL1 parameters
    --------------------------------------------------------------------------
    -- pll module parameters
    C_PLL1_DIVCLK_DIVIDE          : integer := 1;          -- D 
    C_PLL1_CLKFBOUT_MULT          : integer := 1;          -- M
    C_PLL1_CLKFBOUT_PHASE         : real    := 0.0;  
    C_PLL1_CLKIN1_PERIOD          : real    := 0.000;  
    -- C_PLL1_CLKIN2_PERIOD       : real    := 0.000;  
    C_PLL1_CLKOUT0_DIVIDE         : integer := 1;          -- Do0
    C_PLL1_CLKOUT0_DUTY_CYCLE     : real    := 0.5;  
    C_PLL1_CLKOUT0_PHASE          : real    := 0.0;  
    C_PLL1_CLKOUT1_DIVIDE         : integer := 1;          -- Do1
    C_PLL1_CLKOUT1_DUTY_CYCLE     : real    := 0.5;  
    C_PLL1_CLKOUT1_PHASE          : real    := 0.0;  
    C_PLL1_CLKOUT2_DIVIDE         : integer := 1;          -- Do2
    C_PLL1_CLKOUT2_DUTY_CYCLE     : real    := 0.5;  
    C_PLL1_CLKOUT2_PHASE          : real    := 0.0;  
    C_PLL1_CLKOUT3_DIVIDE         : integer := 1;          -- Do3
    C_PLL1_CLKOUT3_DUTY_CYCLE     : real    := 0.5;  
    C_PLL1_CLKOUT3_PHASE          : real    := 0.0;  
    C_PLL1_CLKOUT4_DIVIDE         : integer := 1;          -- Do4
    C_PLL1_CLKOUT4_DUTY_CYCLE     : real    := 0.5;  
    C_PLL1_CLKOUT4_PHASE          : real    := 0.0;  
    C_PLL1_CLKOUT5_DIVIDE         : integer := 1;          -- Do5
    C_PLL1_CLKOUT5_DUTY_CYCLE     : real    := 0.5;  
    C_PLL1_CLKOUT5_PHASE          : real    := 0.0;  
    -- C_PLL1_EN_REL              : boolean := false;  
    -- C_PLL1_PLL_PMCD_MODE       : boolean := false; 
    C_PLL1_BANDWIDTH              : string  := "OPTIMIZED";  
    C_PLL1_COMPENSATION           : string  := "SYSTEM_SYNCHRONOUS";  
    C_PLL1_REF_JITTER             : real    := 0.100; 
    C_PLL1_RESET_ON_LOSS_OF_LOCK  : boolean := false;  
    C_PLL1_RST_DEASSERT_CLK       : string  := "CLKIN1";
    C_PLL1_EXT_RESET_HIGH         : integer := 1;
    C_PLL1_FAMILY                 : string  := "virtex5";
    -- parameters for pcore
    C_PLL1_CLKOUT0_DESKEW_ADJUST  : string  := "NONE";     -- For PPC
    C_PLL1_CLKOUT1_DESKEW_ADJUST  : string  := "NONE";     -- For CrossBar
    C_PLL1_CLKOUT2_DESKEW_ADJUST  : string  := "NONE";     -- Since EDK_L.18, "PPC";      -- For others
    C_PLL1_CLKOUT3_DESKEW_ADJUST  : string  := "NONE"; 
    C_PLL1_CLKOUT4_DESKEW_ADJUST  : string  := "NONE"; 
    C_PLL1_CLKOUT5_DESKEW_ADJUST  : string  := "NONE"; 
    C_PLL1_CLKFBOUT_DESKEW_ADJUST : string  := "NONE"; 
    C_PLL1_CLKIN1_BUF             : boolean := false;
    -- C_PLL1_CLKIN2_BUF          : boolean := false;
    C_PLL1_CLKFBOUT_BUF           : boolean := false;
    C_PLL1_CLKOUT0_BUF            : boolean := false;  -- wrapper
    C_PLL1_CLKOUT1_BUF            : boolean := false;  --
    C_PLL1_CLKOUT2_BUF            : boolean := false;  --
    C_PLL1_CLKOUT3_BUF            : boolean := false;  --
    C_PLL1_CLKOUT4_BUF            : boolean := false;  --
    C_PLL1_CLKOUT5_BUF            : boolean := false;  --
    -- pll connection parameters
    C_PLL1_CLKIN1_MODULE          : string  := "NONE"; -- CLKGEN|DCM0-3|PLL0-1 
    C_PLL1_CLKIN1_PORT            : string  := "NONE"; -- CLKGEN_IN|DCMPLL_OUT
    C_PLL1_CLKFBIN_MODULE         : string  := "NONE"; 
    C_PLL1_CLKFBIN_PORT           : string  := "NONE";
    C_PLL1_RST_MODULE             : string  := "NONE"; -- CLKGEN|DCM0-3|PLL0-1    
    --------------------------------------------------------------------------
    -- DCM0 parameters
    --------------------------------------------------------------------------
    -- dcm module parameters
    C_DCM0_DFS_FREQUENCY_MODE     : string  := "LOW";                  -- ( 0) 
    C_DCM0_DLL_FREQUENCY_MODE     : string  := "LOW";                  -- ( 1) 
    C_DCM0_DUTY_CYCLE_CORRECTION  : boolean := true;                   -- ( 2) 
    C_DCM0_CLKIN_DIVIDE_BY_2      : boolean := false;                  -- ( 3)
    C_DCM0_CLK_FEEDBACK           : string  := "1X";                   -- ( 4)
    C_DCM0_CLKOUT_PHASE_SHIFT     : string  := "NONE";                 -- ( 5)
    C_DCM0_DSS_MODE               : string  := "NONE";                 -- ( 6) 
    C_DCM0_STARTUP_WAIT           : boolean := false;                  -- ( 7) 
    C_DCM0_PHASE_SHIFT            : integer := 0;                      -- ( 8)           
    C_DCM0_CLKFX_MULTIPLY         : integer := 4;                      -- ( 9)
    C_DCM0_CLKFX_DIVIDE           : integer := 1;                      -- (10)
    C_DCM0_CLKDV_DIVIDE           : real    := 2.0;                    -- (11)
    C_DCM0_CLKIN_PERIOD           : real    := 0.0;                    -- (12) 
    C_DCM0_DESKEW_ADJUST          : string  := "SYSTEM_SYNCHRONOUS";   -- (13) 
    C_DCM0_CLKIN_BUF              : boolean := false;                  -- (14) 
    C_DCM0_CLKFB_BUF              : boolean := false;                  -- (15) 
    C_DCM0_CLK0_BUF               : boolean := false;                  -- (16) -- wrapper
    C_DCM0_CLK90_BUF              : boolean := false;                  -- (17) --
    C_DCM0_CLK180_BUF             : boolean := false;                  -- (18) --
    C_DCM0_CLK270_BUF             : boolean := false;                  -- (19) --
    C_DCM0_CLKDV_BUF              : boolean := false;                  -- (20) --
    C_DCM0_CLKDV180_BUF           : boolean := false;                          --
    C_DCM0_CLK2X_BUF              : boolean := false;                  -- (21) --
    C_DCM0_CLK2X180_BUF           : boolean := false;                  -- (22) --
    C_DCM0_CLKFX_BUF              : boolean := false;                  -- (23) --
    C_DCM0_CLKFX180_BUF           : boolean := false;                  -- (24) --
    C_DCM0_EXT_RESET_HIGH         : integer := 1;                      -- (25) 
    C_DCM0_FAMILY                 : string  := "virtex5";              -- (26) 
    -- dcm connection parameters
    C_DCM0_CLKIN_MODULE           : string  := "NONE"; -- CLKGEN|DCM0-3|PLL0-1 
    C_DCM0_CLKIN_PORT             : string  := "NONE"; -- CLKGEN_IN|DCMPLL_OUT
    C_DCM0_CLKFB_MODULE           : string  := "NONE";
    C_DCM0_CLKFB_PORT             : string  := "NONE";
    C_DCM0_RST_MODULE             : string  := "NONE"; -- CLKGEN|DCM0-3|PLL0-1    
    --------------------------------------------------------------------------
    -- DCM1 parameters
    --------------------------------------------------------------------------
    -- dcm module parameters
    C_DCM1_DFS_FREQUENCY_MODE     : string  := "LOW";                  -- ( 0) 
    C_DCM1_DLL_FREQUENCY_MODE     : string  := "LOW";                  -- ( 1) 
    C_DCM1_DUTY_CYCLE_CORRECTION  : boolean := true;                   -- ( 2) 
    C_DCM1_CLKIN_DIVIDE_BY_2      : boolean := false;                  -- ( 3)
    C_DCM1_CLK_FEEDBACK           : string  := "1X";                   -- ( 4)
    C_DCM1_CLKOUT_PHASE_SHIFT     : string  := "NONE";                 -- ( 5)
    C_DCM1_DSS_MODE               : string  := "NONE";                 -- ( 6) 
    C_DCM1_STARTUP_WAIT           : boolean := false;                  -- ( 7) 
    C_DCM1_PHASE_SHIFT            : integer := 0;                      -- ( 8)           
    C_DCM1_CLKFX_MULTIPLY         : integer := 4;                      -- ( 9)
    C_DCM1_CLKFX_DIVIDE           : integer := 1;                      -- (10)
    C_DCM1_CLKDV_DIVIDE           : real    := 2.0;                    -- (11)
    C_DCM1_CLKIN_PERIOD           : real    := 0.0;                    -- (12) 
    C_DCM1_DESKEW_ADJUST          : string  := "SYSTEM_SYNCHRONOUS";   -- (13) 
    C_DCM1_CLKIN_BUF              : boolean := false;                  -- (14) 
    C_DCM1_CLKFB_BUF              : boolean := false;                  -- (15) 
    C_DCM1_CLK0_BUF               : boolean := false;                  -- (16) -- wrapper
    C_DCM1_CLK90_BUF              : boolean := false;                  -- (17) -- 
    C_DCM1_CLK180_BUF             : boolean := false;                  -- (18) --
    C_DCM1_CLK270_BUF             : boolean := false;                  -- (19) --
    C_DCM1_CLKDV_BUF              : boolean := false;                  -- (20) --
    C_DCM1_CLKDV180_BUF           : boolean := false;                          --
    C_DCM1_CLK2X_BUF              : boolean := false;                  -- (21) --
    C_DCM1_CLK2X180_BUF           : boolean := false;                  -- (22) --
    C_DCM1_CLKFX_BUF              : boolean := false;                  -- (23)--
    C_DCM1_CLKFX180_BUF           : boolean := false;                  -- (24) --
    C_DCM1_EXT_RESET_HIGH         : integer := 1;                      -- (25) 
    C_DCM1_FAMILY                 : string  := "virtex5";              -- (26) 
    -- dcm connection parameters
    C_DCM1_CLKIN_MODULE           : string  := "NONE"; -- CLKGEN|DCM0-3|PLL0-1 
    C_DCM1_CLKIN_PORT             : string  := "NONE"; -- CLKGEN_IN|DCMPLL_OUT
    C_DCM1_CLKFB_MODULE           : string  := "NONE";
    C_DCM1_CLKFB_PORT             : string  := "NONE";
    C_DCM1_RST_MODULE             : string  := "NONE"; -- CLKGEN|DCM0-3|PLL0-1    
    --------------------------------------------------------------------------
    -- DCM2 parameters
    --------------------------------------------------------------------------
    -- dcm module parameters
    C_DCM2_DFS_FREQUENCY_MODE     : string  := "LOW";                  -- ( 0) 
    C_DCM2_DLL_FREQUENCY_MODE     : string  := "LOW";                  -- ( 1) 
    C_DCM2_DUTY_CYCLE_CORRECTION  : boolean := true;                   -- ( 2) 
    C_DCM2_CLKIN_DIVIDE_BY_2      : boolean := false;                  -- ( 3)
    C_DCM2_CLK_FEEDBACK           : string  := "1X";                   -- ( 4)
    C_DCM2_CLKOUT_PHASE_SHIFT     : string  := "NONE";                 -- ( 5)
    C_DCM2_DSS_MODE               : string  := "NONE";                 -- ( 6) 
    C_DCM2_STARTUP_WAIT           : boolean := false;                  -- ( 7) 
    C_DCM2_PHASE_SHIFT            : integer := 0;                      -- ( 8)           
    C_DCM2_CLKFX_MULTIPLY         : integer := 4;                      -- ( 9)
    C_DCM2_CLKFX_DIVIDE           : integer := 1;                      -- (10)
    C_DCM2_CLKDV_DIVIDE           : real    := 2.0;                    -- (11)
    C_DCM2_CLKIN_PERIOD           : real    := 0.0;                    -- (12) 
    C_DCM2_DESKEW_ADJUST          : string  := "SYSTEM_SYNCHRONOUS";   -- (13) 
    C_DCM2_CLKIN_BUF              : boolean := false;                  -- (14) 
    C_DCM2_CLKFB_BUF              : boolean := false;                  -- (15) 
    C_DCM2_CLK0_BUF               : boolean := false;                  -- (16) -- wrapper
    C_DCM2_CLK90_BUF              : boolean := false;                  -- (17) --
    C_DCM2_CLK180_BUF             : boolean := false;                  -- (18) --
    C_DCM2_CLK270_BUF             : boolean := false;                  -- (19) --
    C_DCM2_CLKDV_BUF              : boolean := false;                  -- (20) --
    C_DCM2_CLKDV180_BUF           : boolean := false;                          --
    C_DCM2_CLK2X_BUF              : boolean := false;                  -- (21) --
    C_DCM2_CLK2X180_BUF           : boolean := false;                  -- (22) --
    C_DCM2_CLKFX_BUF              : boolean := false;                  -- (23) --
    C_DCM2_CLKFX180_BUF           : boolean := false;                  -- (24) --
    C_DCM2_EXT_RESET_HIGH         : integer := 1;                      -- (25) 
    C_DCM2_FAMILY                 : string  := "virtex5";              -- (26) 
    -- dcm connection parameters
    C_DCM2_CLKIN_MODULE           : string  := "NONE"; -- CLKGEN|DCM0-3|PLL0-1 
    C_DCM2_CLKIN_PORT             : string  := "NONE"; -- CLKGEN_IN|DCMPLL_OUT
    C_DCM2_CLKFB_MODULE           : string  := "NONE";
    C_DCM2_CLKFB_PORT             : string  := "NONE";
    C_DCM2_RST_MODULE             : string  := "NONE"; -- CLKGEN|DCM0-3|PLL0-1    
    --------------------------------------------------------------------------
    -- DCM3 parameters
    --------------------------------------------------------------------------
    -- dcm module parameters
    C_DCM3_DFS_FREQUENCY_MODE     : string  := "LOW";                  -- ( 0) 
    C_DCM3_DLL_FREQUENCY_MODE     : string  := "LOW";                  -- ( 1) 
    C_DCM3_DUTY_CYCLE_CORRECTION  : boolean := true;                   -- ( 2) 
    C_DCM3_CLKIN_DIVIDE_BY_2      : boolean := false;                  -- ( 3)
    C_DCM3_CLK_FEEDBACK           : string  := "1X";                   -- ( 4)
    C_DCM3_CLKOUT_PHASE_SHIFT     : string  := "NONE";                 -- ( 5)
    C_DCM3_DSS_MODE               : string  := "NONE";                 -- ( 6) 
    C_DCM3_STARTUP_WAIT           : boolean := false;                  -- ( 7) 
    C_DCM3_PHASE_SHIFT            : integer := 0;                      -- ( 8)           
    C_DCM3_CLKFX_MULTIPLY         : integer := 4;                      -- ( 9)
    C_DCM3_CLKFX_DIVIDE           : integer := 1;                      -- (10)
    C_DCM3_CLKDV_DIVIDE           : real    := 2.0;                    -- (11)
    C_DCM3_CLKIN_PERIOD           : real    := 0.0;                    -- (12) 
    C_DCM3_DESKEW_ADJUST          : string  := "SYSTEM_SYNCHRONOUS";   -- (13) 
    C_DCM3_CLKIN_BUF              : boolean := false;                  -- (14) 
    C_DCM3_CLKFB_BUF              : boolean := false;                  -- (15) 
    C_DCM3_CLK0_BUF               : boolean := false;                  -- (16) -- wrapper
    C_DCM3_CLK90_BUF              : boolean := false;                  -- (17) --
    C_DCM3_CLK180_BUF             : boolean := false;                  -- (18) --
    C_DCM3_CLK270_BUF             : boolean := false;                  -- (19) --
    C_DCM3_CLKDV_BUF              : boolean := false;                  -- (20) --
    C_DCM3_CLKDV180_BUF           : boolean := false;                  -- (20) --
    C_DCM3_CLK2X_BUF              : boolean := false;                  -- (21) --
    C_DCM3_CLK2X180_BUF           : boolean := false;                  -- (22) --
    C_DCM3_CLKFX_BUF              : boolean := false;                  -- (23) --
    C_DCM3_CLKFX180_BUF           : boolean := false;                  -- (24) --
    C_DCM3_EXT_RESET_HIGH         : integer := 1;                      -- (25) 
    C_DCM3_FAMILY                 : string  := "virtex5";              -- (26) 
    -- dcm connection parameters
    C_DCM3_CLKIN_MODULE           : string  := "NONE"; -- CLKGEN|DCM0-3|PLL0-1 
    C_DCM3_CLKIN_PORT             : string  := "NONE"; -- CLKGEN_IN|DCMPLL_OUT
    C_DCM3_CLKFB_MODULE           : string  := "NONE";
    C_DCM3_CLKFB_PORT             : string  := "NONE";
    C_DCM3_RST_MODULE             : string  := "NONE"; -- CLKGEN|DCM0-3|PLL0-1    
    --------------------------------------------------------------------------
    -- MMCM0 parameters
    --------------------------------------------------------------------------
    -- mmcm module parameters
    C_MMCM0_BANDWIDTH             : string  := "OPTIMIZED"; 
    C_MMCM0_CLKFBOUT_MULT_F       : real    := 1.0;
    C_MMCM0_CLKFBOUT_PHASE        : real    := 0.0;
    C_MMCM0_CLKFBOUT_USE_FINE_PS  : boolean := false;
    C_MMCM0_CLKIN1_PERIOD         : real    := 0.000;
    C_MMCM0_CLKOUT0_DIVIDE_F      : real    := 1.0;
    C_MMCM0_CLKOUT0_DUTY_CYCLE    : real    := 0.5;
    C_MMCM0_CLKOUT0_PHASE         : real    := 0.0;
    C_MMCM0_CLKOUT1_DIVIDE        : integer := 1;
    C_MMCM0_CLKOUT1_DUTY_CYCLE    : real    := 0.5;
    C_MMCM0_CLKOUT1_PHASE         : real    := 0.0;
    C_MMCM0_CLKOUT2_DIVIDE        : integer := 1;
    C_MMCM0_CLKOUT2_DUTY_CYCLE    : real    := 0.5;
    C_MMCM0_CLKOUT2_PHASE         : real    := 0.0;
    C_MMCM0_CLKOUT3_DIVIDE        : integer := 1;
    C_MMCM0_CLKOUT3_DUTY_CYCLE    : real    := 0.5;
    C_MMCM0_CLKOUT3_PHASE         : real    := 0.0;
    C_MMCM0_CLKOUT4_DIVIDE        : integer := 1;
    C_MMCM0_CLKOUT4_DUTY_CYCLE    : real    := 0.5;
    C_MMCM0_CLKOUT4_PHASE         : real    := 0.0;
    C_MMCM0_CLKOUT4_CASCADE       : boolean := false;
    C_MMCM0_CLKOUT5_DIVIDE        : integer := 1;
    C_MMCM0_CLKOUT5_DUTY_CYCLE    : real    := 0.5;
    C_MMCM0_CLKOUT5_PHASE         : real    := 0.0;
    C_MMCM0_CLKOUT6_DIVIDE        : integer := 1;
    C_MMCM0_CLKOUT6_DUTY_CYCLE    : real    := 0.5;
    C_MMCM0_CLKOUT6_PHASE         : real    := 0.0;
    C_MMCM0_CLKOUT0_USE_FINE_PS   : boolean := false;
    C_MMCM0_CLKOUT1_USE_FINE_PS   : boolean := false;
    C_MMCM0_CLKOUT2_USE_FINE_PS   : boolean := false;
    C_MMCM0_CLKOUT3_USE_FINE_PS   : boolean := false;
    C_MMCM0_CLKOUT4_USE_FINE_PS   : boolean := false;
    C_MMCM0_CLKOUT5_USE_FINE_PS   : boolean := false;
    C_MMCM0_CLKOUT6_USE_FINE_PS   : boolean := false;
    C_MMCM0_COMPENSATION          : string  := "ZHOLD";  
    C_MMCM0_DIVCLK_DIVIDE         : integer := 1;
    C_MMCM0_REF_JITTER1           : real    := 0.010;
    C_MMCM0_CLKIN1_BUF            : boolean := false;
    C_MMCM0_CLKFBOUT_BUF          : boolean := false;
    -- C_MMCM0_CLKOUT0_BUF        : boolean := false;
    -- C_MMCM0_CLKOUT1_BUF        : boolean := false;
    -- C_MMCM0_CLKOUT2_BUF        : boolean := false;
    -- C_MMCM0_CLKOUT3_BUF        : boolean := false;
    -- C_MMCM0_CLKOUT4_BUF        : boolean := false;
    -- C_MMCM0_CLKOUT5_BUF        : boolean := false;
    -- C_MMCM0_CLKOUT6_BUF        : boolean := false;
    C_MMCM0_CLOCK_HOLD            : boolean := false;
    C_MMCM0_STARTUP_WAIT          : boolean := false;
    C_MMCM0_EXT_RESET_HIGH        : integer := 1;
    C_MMCM0_FAMILY                : string  := "virtex6";
    C_MMCM0_CLKOUT0_BUF           : boolean := false; -- turn on/off bufg for CLKOUT0B
    C_MMCM0_CLKOUT1_BUF           : boolean := false; --
    C_MMCM0_CLKOUT2_BUF           : boolean := false; --
    C_MMCM0_CLKOUT3_BUF           : boolean := false; --
    C_MMCM0_CLKOUT4_BUF           : boolean := false; --
    C_MMCM0_CLKOUT5_BUF           : boolean := false; --
    C_MMCM0_CLKOUT6_BUF           : boolean := false; --
    -- mmcm connection parameters
    C_MMCM0_CLKIN1_MODULE         : string  := "NONE"; -- CLKGEN|MMCM0-3
    C_MMCM0_CLKIN1_PORT           : string  := "NONE"; -- CLKGEN_IN|MMCM_OUT
    C_MMCM0_CLKFBIN_MODULE        : string  := "NONE"; 
    C_MMCM0_CLKFBIN_PORT          : string  := "NONE";
    C_MMCM0_RST_MODULE            : string  := "NONE"; -- CLKGEN|MMCM0-3
    --------------------------------------------------------------------------
    -- MMCM1 parameters
    --------------------------------------------------------------------------
    -- mmcm module parameters
    C_MMCM1_BANDWIDTH             : string  := "OPTIMIZED"; 
    C_MMCM1_CLKFBOUT_MULT_F       : real    := 1.0;
    C_MMCM1_CLKFBOUT_PHASE        : real    := 0.0;
    C_MMCM1_CLKFBOUT_USE_FINE_PS  : boolean := false;
    C_MMCM1_CLKIN1_PERIOD         : real    := 0.000;
    C_MMCM1_CLKOUT0_DIVIDE_F      : real    := 1.0;
    C_MMCM1_CLKOUT0_DUTY_CYCLE    : real    := 0.5;
    C_MMCM1_CLKOUT0_PHASE         : real    := 0.0;
    C_MMCM1_CLKOUT1_DIVIDE        : integer := 1;
    C_MMCM1_CLKOUT1_DUTY_CYCLE    : real    := 0.5;
    C_MMCM1_CLKOUT1_PHASE         : real    := 0.0;
    C_MMCM1_CLKOUT2_DIVIDE        : integer := 1;
    C_MMCM1_CLKOUT2_DUTY_CYCLE    : real    := 0.5;
    C_MMCM1_CLKOUT2_PHASE         : real    := 0.0;
    C_MMCM1_CLKOUT3_DIVIDE        : integer := 1;
    C_MMCM1_CLKOUT3_DUTY_CYCLE    : real    := 0.5;
    C_MMCM1_CLKOUT3_PHASE         : real    := 0.0;
    C_MMCM1_CLKOUT4_DIVIDE        : integer := 1;
    C_MMCM1_CLKOUT4_DUTY_CYCLE    : real    := 0.5;
    C_MMCM1_CLKOUT4_PHASE         : real    := 0.0;
    C_MMCM1_CLKOUT4_CASCADE       : boolean := false;
    C_MMCM1_CLKOUT5_DIVIDE        : integer := 1;
    C_MMCM1_CLKOUT5_DUTY_CYCLE    : real    := 0.5;
    C_MMCM1_CLKOUT5_PHASE         : real    := 0.0;
    C_MMCM1_CLKOUT6_DIVIDE        : integer := 1;
    C_MMCM1_CLKOUT6_DUTY_CYCLE    : real    := 0.5;
    C_MMCM1_CLKOUT6_PHASE         : real    := 0.0;
    C_MMCM1_CLKOUT0_USE_FINE_PS   : boolean := false;
    C_MMCM1_CLKOUT1_USE_FINE_PS   : boolean := false;
    C_MMCM1_CLKOUT2_USE_FINE_PS   : boolean := false;
    C_MMCM1_CLKOUT3_USE_FINE_PS   : boolean := false;
    C_MMCM1_CLKOUT4_USE_FINE_PS   : boolean := false;
    C_MMCM1_CLKOUT5_USE_FINE_PS   : boolean := false;
    C_MMCM1_CLKOUT6_USE_FINE_PS   : boolean := false;
    C_MMCM1_COMPENSATION          : string  := "ZHOLD";  
    C_MMCM1_DIVCLK_DIVIDE         : integer := 1;
    C_MMCM1_REF_JITTER1           : real    := 0.010;
    C_MMCM1_CLKIN1_BUF            : boolean := false;
    C_MMCM1_CLKFBOUT_BUF          : boolean := false;
    -- C_MMCM1_CLKOUT0_BUF        : boolean := false;
    -- C_MMCM1_CLKOUT1_BUF        : boolean := false;
    -- C_MMCM1_CLKOUT2_BUF        : boolean := false;
    -- C_MMCM1_CLKOUT3_BUF        : boolean := false;
    -- C_MMCM1_CLKOUT4_BUF        : boolean := false;
    -- C_MMCM1_CLKOUT5_BUF        : boolean := false;
    -- C_MMCM1_CLKOUT6_BUF        : boolean := false;
    C_MMCM1_CLOCK_HOLD            : boolean := false;
    C_MMCM1_STARTUP_WAIT          : boolean := false;
    C_MMCM1_EXT_RESET_HIGH        : integer := 1;
    C_MMCM1_FAMILY                : string  := "virtex6";
    C_MMCM1_CLKOUT0_BUF           : boolean := false; -- turn on/off bufg for CLKOUT0B
    C_MMCM1_CLKOUT1_BUF           : boolean := false; --
    C_MMCM1_CLKOUT2_BUF           : boolean := false; --
    C_MMCM1_CLKOUT3_BUF           : boolean := false; --
    C_MMCM1_CLKOUT4_BUF           : boolean := false; --
    C_MMCM1_CLKOUT5_BUF           : boolean := false; --
    C_MMCM1_CLKOUT6_BUF           : boolean := false; --
    -- mmcm connection parameters
    C_MMCM1_CLKIN1_MODULE         : string  := "NONE"; -- CLKGEN|MMCM0-3
    C_MMCM1_CLKIN1_PORT           : string  := "NONE"; -- CLKGEN_IN|MMCM_OUT
    C_MMCM1_CLKFBIN_MODULE        : string  := "NONE"; 
    C_MMCM1_CLKFBIN_PORT          : string  := "NONE";
    C_MMCM1_RST_MODULE            : string  := "NONE"; -- CLKGEN|MMCM0-3
    --------------------------------------------------------------------------
    -- MMCM2 parameters
    --------------------------------------------------------------------------
    -- mmcm module parameters
    C_MMCM2_BANDWIDTH             : string  := "OPTIMIZED"; 
    C_MMCM2_CLKFBOUT_MULT_F       : real    := 1.0;
    C_MMCM2_CLKFBOUT_PHASE        : real    := 0.0;
    C_MMCM2_CLKFBOUT_USE_FINE_PS  : boolean := false;
    C_MMCM2_CLKIN1_PERIOD         : real    := 0.000;
    C_MMCM2_CLKOUT0_DIVIDE_F      : real    := 1.0;
    C_MMCM2_CLKOUT0_DUTY_CYCLE    : real    := 0.5;
    C_MMCM2_CLKOUT0_PHASE         : real    := 0.0;
    C_MMCM2_CLKOUT1_DIVIDE        : integer := 1;
    C_MMCM2_CLKOUT1_DUTY_CYCLE    : real    := 0.5;
    C_MMCM2_CLKOUT1_PHASE         : real    := 0.0;
    C_MMCM2_CLKOUT2_DIVIDE        : integer := 1;
    C_MMCM2_CLKOUT2_DUTY_CYCLE    : real    := 0.5;
    C_MMCM2_CLKOUT2_PHASE         : real    := 0.0;
    C_MMCM2_CLKOUT3_DIVIDE        : integer := 1;
    C_MMCM2_CLKOUT3_DUTY_CYCLE    : real    := 0.5;
    C_MMCM2_CLKOUT3_PHASE         : real    := 0.0;
    C_MMCM2_CLKOUT4_DIVIDE        : integer := 1;
    C_MMCM2_CLKOUT4_DUTY_CYCLE    : real    := 0.5;
    C_MMCM2_CLKOUT4_PHASE         : real    := 0.0;
    C_MMCM2_CLKOUT4_CASCADE       : boolean := false;
    C_MMCM2_CLKOUT5_DIVIDE        : integer := 1;
    C_MMCM2_CLKOUT5_DUTY_CYCLE    : real    := 0.5;
    C_MMCM2_CLKOUT5_PHASE         : real    := 0.0;
    C_MMCM2_CLKOUT6_DIVIDE        : integer := 1;
    C_MMCM2_CLKOUT6_DUTY_CYCLE    : real    := 0.5;
    C_MMCM2_CLKOUT6_PHASE         : real    := 0.0;
    C_MMCM2_CLKOUT0_USE_FINE_PS   : boolean := false;
    C_MMCM2_CLKOUT1_USE_FINE_PS   : boolean := false;
    C_MMCM2_CLKOUT2_USE_FINE_PS   : boolean := false;
    C_MMCM2_CLKOUT3_USE_FINE_PS   : boolean := false;
    C_MMCM2_CLKOUT4_USE_FINE_PS   : boolean := false;
    C_MMCM2_CLKOUT5_USE_FINE_PS   : boolean := false;
    C_MMCM2_CLKOUT6_USE_FINE_PS   : boolean := false;
    C_MMCM2_COMPENSATION          : string  := "ZHOLD";  
    C_MMCM2_DIVCLK_DIVIDE         : integer := 1;
    C_MMCM2_REF_JITTER1           : real    := 0.010;
    C_MMCM2_CLKIN1_BUF            : boolean := false;
    C_MMCM2_CLKFBOUT_BUF          : boolean := false;
    -- C_MMCM2_CLKOUT0_BUF        : boolean := false;
    -- C_MMCM2_CLKOUT1_BUF        : boolean := false;
    -- C_MMCM2_CLKOUT2_BUF        : boolean := false;
    -- C_MMCM2_CLKOUT3_BUF        : boolean := false;
    -- C_MMCM2_CLKOUT4_BUF        : boolean := false;
    -- C_MMCM2_CLKOUT5_BUF        : boolean := false;
    -- C_MMCM2_CLKOUT6_BUF        : boolean := false;
    C_MMCM2_CLOCK_HOLD            : boolean := false;
    C_MMCM2_STARTUP_WAIT          : boolean := false;
    C_MMCM2_EXT_RESET_HIGH        : integer := 1;
    C_MMCM2_FAMILY                : string  := "virtex6";
    C_MMCM2_CLKOUT0_BUF           : boolean := false; -- turn on/off bufg for CLKOUT0B
    C_MMCM2_CLKOUT1_BUF           : boolean := false; --
    C_MMCM2_CLKOUT2_BUF           : boolean := false; --
    C_MMCM2_CLKOUT3_BUF           : boolean := false; --
    C_MMCM2_CLKOUT4_BUF           : boolean := false; --
    C_MMCM2_CLKOUT5_BUF           : boolean := false; --
    C_MMCM2_CLKOUT6_BUF           : boolean := false; --
    -- mmcm connection parameters
    C_MMCM2_CLKIN1_MODULE         : string  := "NONE"; -- CLKGEN|MMCM0-3
    C_MMCM2_CLKIN1_PORT           : string  := "NONE"; -- CLKGEN_IN|MMCM_OUT
    C_MMCM2_CLKFBIN_MODULE        : string  := "NONE"; 
    C_MMCM2_CLKFBIN_PORT          : string  := "NONE";
    C_MMCM2_RST_MODULE            : string  := "NONE"; -- CLKGEN|MMCM0-3
    --------------------------------------------------------------------------
    -- MMCM3 parameters
    --------------------------------------------------------------------------
    -- mmcm module parameters
    C_MMCM3_BANDWIDTH             : string  := "OPTIMIZED"; 
    C_MMCM3_CLKFBOUT_MULT_F       : real    := 1.0;
    C_MMCM3_CLKFBOUT_PHASE        : real    := 0.0;
    C_MMCM3_CLKFBOUT_USE_FINE_PS  : boolean := false;
    C_MMCM3_CLKIN1_PERIOD         : real    := 0.000;
    C_MMCM3_CLKOUT0_DIVIDE_F      : real    := 1.0;
    C_MMCM3_CLKOUT0_DUTY_CYCLE    : real    := 0.5;
    C_MMCM3_CLKOUT0_PHASE         : real    := 0.0;
    C_MMCM3_CLKOUT1_DIVIDE        : integer := 1;
    C_MMCM3_CLKOUT1_DUTY_CYCLE    : real    := 0.5;
    C_MMCM3_CLKOUT1_PHASE         : real    := 0.0;
    C_MMCM3_CLKOUT2_DIVIDE        : integer := 1;
    C_MMCM3_CLKOUT2_DUTY_CYCLE    : real    := 0.5;
    C_MMCM3_CLKOUT2_PHASE         : real    := 0.0;
    C_MMCM3_CLKOUT3_DIVIDE        : integer := 1;
    C_MMCM3_CLKOUT3_DUTY_CYCLE    : real    := 0.5;
    C_MMCM3_CLKOUT3_PHASE         : real    := 0.0;
    C_MMCM3_CLKOUT4_DIVIDE        : integer := 1;
    C_MMCM3_CLKOUT4_DUTY_CYCLE    : real    := 0.5;
    C_MMCM3_CLKOUT4_PHASE         : real    := 0.0;
    C_MMCM3_CLKOUT4_CASCADE       : boolean := false;
    C_MMCM3_CLKOUT5_DIVIDE        : integer := 1;
    C_MMCM3_CLKOUT5_DUTY_CYCLE    : real    := 0.5;
    C_MMCM3_CLKOUT5_PHASE         : real    := 0.0;
    C_MMCM3_CLKOUT6_DIVIDE        : integer := 1;
    C_MMCM3_CLKOUT6_DUTY_CYCLE    : real    := 0.5;
    C_MMCM3_CLKOUT6_PHASE         : real    := 0.0;
    C_MMCM3_CLKOUT0_USE_FINE_PS   : boolean := false;
    C_MMCM3_CLKOUT1_USE_FINE_PS   : boolean := false;
    C_MMCM3_CLKOUT2_USE_FINE_PS   : boolean := false;
    C_MMCM3_CLKOUT3_USE_FINE_PS   : boolean := false;
    C_MMCM3_CLKOUT4_USE_FINE_PS   : boolean := false;
    C_MMCM3_CLKOUT5_USE_FINE_PS   : boolean := false;
    C_MMCM3_CLKOUT6_USE_FINE_PS   : boolean := false;
    C_MMCM3_COMPENSATION          : string  := "ZHOLD";  
    C_MMCM3_DIVCLK_DIVIDE         : integer := 1;
    C_MMCM3_REF_JITTER1           : real    := 0.010;
    C_MMCM3_CLKIN1_BUF            : boolean := false;
    C_MMCM3_CLKFBOUT_BUF          : boolean := false;
    -- C_MMCM3_CLKOUT0_BUF        : boolean := false;
    -- C_MMCM3_CLKOUT1_BUF        : boolean := false;
    -- C_MMCM3_CLKOUT2_BUF        : boolean := false;
    -- C_MMCM3_CLKOUT3_BUF        : boolean := false;
    -- C_MMCM3_CLKOUT4_BUF        : boolean := false;
    -- C_MMCM3_CLKOUT5_BUF        : boolean := false;
    -- C_MMCM3_CLKOUT6_BUF        : boolean := false;
    C_MMCM3_CLOCK_HOLD            : boolean := false;
    C_MMCM3_STARTUP_WAIT          : boolean := false;
    C_MMCM3_EXT_RESET_HIGH        : integer := 1;
    C_MMCM3_FAMILY                : string  := "virtex6";
    C_MMCM3_CLKOUT0_BUF           : boolean := false; -- turn on/off bufg for CLKOUT0B
    C_MMCM3_CLKOUT1_BUF           : boolean := false; --
    C_MMCM3_CLKOUT2_BUF           : boolean := false; --
    C_MMCM3_CLKOUT3_BUF           : boolean := false; --
    C_MMCM3_CLKOUT4_BUF           : boolean := false; --
    C_MMCM3_CLKOUT5_BUF           : boolean := false; --
    C_MMCM3_CLKOUT6_BUF           : boolean := false; --
    -- mmcm connection parameters
    C_MMCM3_CLKIN1_MODULE         : string  := "NONE"; -- CLKGEN|MMCM0-3
    C_MMCM3_CLKIN1_PORT           : string  := "NONE"; -- CLKGEN_IN|MMCM_OUT
    C_MMCM3_CLKFBIN_MODULE        : string  := "NONE"; 
    C_MMCM3_CLKFBIN_PORT          : string  := "NONE";
    C_MMCM3_RST_MODULE            : string  := "NONE"  -- CLKGEN|MMCM0-3
  );
  port (
    -- clock
    CLKIN                         : in  std_logic;
    CLKFBIN                       : in  std_logic;
    CLKOUT0                       : out std_logic;
    CLKOUT1                       : out std_logic;
    CLKOUT2                       : out std_logic;
    CLKOUT3                       : out std_logic;
    CLKOUT4                       : out std_logic;
    CLKOUT5                       : out std_logic;
    CLKOUT6                       : out std_logic;
    CLKOUT7                       : out std_logic;
    CLKOUT8                       : out std_logic;
    CLKOUT9                       : out std_logic;
    CLKOUT10                      : out std_logic;
    CLKOUT11                      : out std_logic;
    CLKOUT12                      : out std_logic;
    CLKOUT13                      : out std_logic;
    CLKOUT14                      : out std_logic;
    CLKOUT15                      : out std_logic;
    CLKFBOUT                      : out std_logic;
    -- phase
    PSCLK                         : in  std_logic;
    PSEN                          : in  std_logic;
    PSINCDEC                      : in  std_logic;
    PSDONE                        : out std_logic;
    -- reset
    RST                           : in  std_logic;
    LOCKED                        : out std_logic
  );
end entity clock_generator;

architecture STRUCT of clock_generator is

  ----------------------------------------------------------------------------
  -- Components ( copy from entity )
  ----------------------------------------------------------------------------

  component pll_module_wrapper is
    generic (
      -- base pll_adv parameters
      C_BANDWIDTH             : string  := "OPTIMIZED";  -- "HIGH", "LOW" or "OPTIMIZED"
      C_CLKFBOUT_MULT         : integer := 1;  -- Multiplication factor for all output clocks
      C_CLKFBOUT_PHASE        : real    := 0.0;  -- Phase shift (degrees) of all output clocks
      C_CLKIN1_PERIOD         : real    := 0.000;  -- Clock period (ns) of input clock on CLKIN1
      -- C_CLKIN2_PERIOD         : real    := 0.000;  -- Clock period (ns) of input clock on CLKIN2
      C_CLKOUT0_DIVIDE        : integer := 1;  -- Division factor for CLKOUT0 (1 to 128)
      C_CLKOUT0_DUTY_CYCLE    : real    := 0.5;  -- Duty cycle for CLKOUT0 (0.01 to 0.99)
      C_CLKOUT0_PHASE         : real    := 0.0;  -- Phase shift (degrees) for CLKOUT0 (0.0 to 360.0)
      C_CLKOUT1_DIVIDE        : integer := 1;  -- Division factor for CLKOUT1 (1 to 128)
      C_CLKOUT1_DUTY_CYCLE    : real    := 0.5;  -- Duty cycle for CLKOUT1 (0.01 to 0.99)
      C_CLKOUT1_PHASE         : real    := 0.0;  -- Phase shift (degrees) for CLKOUT1 (0.0 to 360.0)
      C_CLKOUT2_DIVIDE        : integer := 1;  -- Division factor for CLKOUT2 (1 to 128)
      C_CLKOUT2_DUTY_CYCLE    : real    := 0.5;  -- Duty cycle for CLKOUT2 (0.01 to 0.99)
      C_CLKOUT2_PHASE         : real    := 0.0;  -- Phase shift (degrees) for CLKOUT2 (0.0 to 360.0)
      C_CLKOUT3_DIVIDE        : integer := 1;  -- Division factor for CLKOUT3 (1 to 128)
      C_CLKOUT3_DUTY_CYCLE    : real    := 0.5;  -- Duty cycle for CLKOUT3 (0.01 to 0.99)
      C_CLKOUT3_PHASE         : real    := 0.0;  -- Phase shift (degrees) for CLKOUT3 (0.0 to 360.0)
      C_CLKOUT4_DIVIDE        : integer := 1;  -- Division factor for CLKOUT4 (1 to 128)
      C_CLKOUT4_DUTY_CYCLE    : real    := 0.5;  -- Duty cycle for CLKOUT4 (0.01 to 0.99)
      C_CLKOUT4_PHASE         : real    := 0.0;  -- Phase shift (degrees) for CLKOUT4 (0.0 to 360.0)
      C_CLKOUT5_DIVIDE        : integer := 1;  -- Division factor for CLKOUT5 (1 to 128)
      C_CLKOUT5_DUTY_CYCLE    : real    := 0.5;  -- Duty cycle for CLKOUT5 (0.01 to 0.99)
      C_CLKOUT5_PHASE         : real    := 0.0;  -- Phase shift (degrees) for CLKOUT5 (0.0 to 360.0)
      C_COMPENSATION          : string  := "SYSTEM_SYNCHRONOUS";  -- "SYSTEM_SYNCHRNOUS", "SOURCE_SYNCHRNOUS", "
                                          -- INTERNAL", "EXTERNAL", "DCM2PLL", "PLL2DCM"
      C_DIVCLK_DIVIDE         : integer := 1;  -- Division factor for all clocks (1 to 52)
      -- C_EN_REL                : boolean := false;  -- Enable release (PMCD mode only)
      -- C_PLL_PMCD_MODE         : boolean := false;  -- PMCD Mode, TRUE/FASLE
      C_REF_JITTER            : real    := 0.100;  -- Input reference jitter (0.000 to 0.999 UI%)
      C_RESET_ON_LOSS_OF_LOCK : boolean := false;  -- Auto reset when LOCK is lost, TRUE/FALSE
      C_RST_DEASSERT_CLK      : string  := "CLKIN1";  -- In PMCD mode, clock to synchronize RST relea

      C_CLKOUT0_DESKEW_ADJUST : string  := "NONE";  -- "NONE" for PPC core and crossbar
                                          -- clocks,"PPC" for all others
      C_CLKOUT1_DESKEW_ADJUST : string  := "NONE";  
      C_CLKOUT2_DESKEW_ADJUST : string  := "PPC"; 
      C_CLKOUT3_DESKEW_ADJUST : string  := "PPC"; 
      C_CLKOUT4_DESKEW_ADJUST : string  := "PPC"; 
      C_CLKOUT5_DESKEW_ADJUST : string  := "PPC"; 
      C_CLKFBOUT_DESKEW_ADJUST : string  := "PPC"; 
      -- parameters for pcore
      C_CLKIN1_BUF            : boolean := false;
      -- C_CLKIN2_BUF          : boolean := false;
      C_CLKFBOUT_BUF          : boolean := false;
      C_CLKOUT0_BUF           : boolean := false; -- wrapper
      C_CLKOUT1_BUF           : boolean := false; --
      C_CLKOUT2_BUF           : boolean := false; --
      C_CLKOUT3_BUF           : boolean := false; --
      C_CLKOUT4_BUF           : boolean := false; --
      C_CLKOUT5_BUF           : boolean := false; --

      C_EXT_RESET_HIGH :     integer := 1;
      C_FAMILY         :     string  := "virtex5"
      );
    port (
      CLKFBDCM         : out std_logic;
      CLKFBOUT         : out std_logic;
      CLKOUT0          : out std_logic;
      CLKOUT1          : out std_logic;
      CLKOUT2          : out std_logic;
      CLKOUT3          : out std_logic;
      CLKOUT4          : out std_logic;
      CLKOUT5          : out std_logic;
      CLKOUTDCM0       : out std_logic;
      CLKOUTDCM1       : out std_logic;
      CLKOUTDCM2       : out std_logic;
      CLKOUTDCM3       : out std_logic;
      CLKOUTDCM4       : out std_logic;
      CLKOUTDCM5       : out std_logic;
      -- DO               : out std_logic_vector (15 downto 0);
      -- DRDY             : out std_logic;
      LOCKED           : out std_logic;
      CLKFBIN          : in  std_logic;
      CLKIN1           : in  std_logic;
      -- CLKIN2           : in  std_logic;
      -- CLKINSEL         : in  std_logic;
      -- DADDR            : in  std_logic_vector (4 downto 0);
      -- DCLK             : in  std_logic;
      -- DEN              : in  std_logic;
      -- DI               : in  std_logic_vector (15 downto 0);
      -- DWE              : in  std_logic;
      -- REL              : in  std_logic;
      RST              : in  std_logic;
      -- wrapper
      CLKOUT0B         : out std_logic;
      CLKOUT1B         : out std_logic;
      CLKOUT2B         : out std_logic;
      CLKOUT3B         : out std_logic;
      CLKOUT4B         : out std_logic;
      CLKOUT5B         : out std_logic
      );
  end component;

  component dcm_module_wrapper is
    generic (
      C_DFS_FREQUENCY_MODE    : string  := "LOW";
      C_DLL_FREQUENCY_MODE    : string  := "LOW";
      C_DUTY_CYCLE_CORRECTION : boolean := true;
      C_CLKIN_DIVIDE_BY_2     : boolean := false;
      C_CLK_FEEDBACK          : string  := "1X";
      C_CLKOUT_PHASE_SHIFT    : string  := "NONE";
      C_DSS_MODE              : string  := "NONE";
      C_STARTUP_WAIT          : boolean := false;
      C_PHASE_SHIFT           : integer := 0;
      C_CLKFX_MULTIPLY        : integer := 4;
      C_CLKFX_DIVIDE          : integer := 1;
      C_CLKDV_DIVIDE          : real    := 2.0;
      C_CLKIN_PERIOD          : real    := 41.6666666;
      C_DESKEW_ADJUST         : string  := "SYSTEM_SYNCHRONOUS";
      C_CLKIN_BUF             : boolean := false;
      C_CLKFB_BUF             : boolean := false;
      C_CLK0_BUF              : boolean := false;
      C_CLK90_BUF             : boolean := false;
      C_CLK180_BUF            : boolean := false;
      C_CLK270_BUF            : boolean := false;
      C_CLKDV_BUF             : boolean := false;
      C_CLKDV180_BUF          : boolean := false; --
      C_CLK2X_BUF             : boolean := false;
      C_CLK2X180_BUF          : boolean := false;
      C_CLKFX_BUF             : boolean := false;
      C_CLKFX180_BUF          : boolean := false;
      C_EXT_RESET_HIGH        : integer := 1;
      C_FAMILY                : string  := "virtex2"
      );
    port (
      RST      : in  std_logic;
      CLKIN    : in  std_logic;
      CLKFB    : in  std_logic;
      PSEN     : in  std_logic;
      PSINCDEC : in  std_logic;
      PSCLK    : in  std_logic;
      DSSEN    : in  std_logic;
      CLK0     : out std_logic;
      CLK90    : out std_logic;
      CLK180   : out std_logic;
      CLK270   : out std_logic;
      CLKDV    : out std_logic;
      CLK2X    : out std_logic;
      CLK2X180 : out std_logic;
      CLKFX    : out std_logic;
      CLKFX180 : out std_logic;
      STATUS   : out std_logic_vector(7 downto 0);
      LOCKED   : out std_logic;
      PSDONE   : out std_logic;
      -- wrapper
      CLKDV180  : out std_logic;
      CLK0B     : out std_logic;
      CLK90B    : out std_logic;
      CLK180B   : out std_logic;
      CLK270B   : out std_logic;
      CLKDVB    : out std_logic;
      CLKDV180B : out std_logic;
      CLK2XB    : out std_logic;
      CLK2X180B : out std_logic;
      CLKFXB    : out std_logic;
      CLKFX180B : out std_logic
      );
  end component;

  component mmcm_module_wrapper is
    generic (
      -- (1) module
      -- base mmcm_adv parameters
      C_BANDWIDTH             : string  := "OPTIMIZED"; 
      C_CLKFBOUT_MULT_F       : real    := 1.0;  -- Multiplication factor for all output clocks
      C_CLKFBOUT_PHASE        : real    := 0.0;  -- Phase shift (degrees) of all output clocks
      C_CLKFBOUT_USE_FINE_PS  : boolean := false;
      C_CLKIN1_PERIOD         : real    := 0.000;  -- Clock period (ns) of input clock on CLKIN1
      C_CLKOUT0_DIVIDE_F      : real    := 1.0;  -- Division factor for CLKOUT0
      C_CLKOUT0_DUTY_CYCLE    : real    := 0.5;  -- Duty cycle for CLKOUT0 (0.01 to 0.99)
      C_CLKOUT0_PHASE         : real    := 0.0;  -- Phase shift (degrees) for CLKOUT0 (0.0 to 360.0)
      C_CLKOUT1_DIVIDE        : integer := 1;  -- Division factor for CLKOUT1 (1 to 128)
      C_CLKOUT1_DUTY_CYCLE    : real    := 0.5;  -- Duty cycle for CLKOUT1 (0.01 to 0.99)
      C_CLKOUT1_PHASE         : real    := 0.0;  -- Phase shift (degrees) for CLKOUT1 (0.0 to 360.0)
      C_CLKOUT2_DIVIDE        : integer := 1;  -- Division factor for CLKOUT2 (1 to 128)
      C_CLKOUT2_DUTY_CYCLE    : real    := 0.5;  -- Duty cycle for CLKOUT2 (0.01 to 0.99)
      C_CLKOUT2_PHASE         : real    := 0.0;  -- Phase shift (degrees) for CLKOUT2 (0.0 to 360.0)
      C_CLKOUT3_DIVIDE        : integer := 1;  -- Division factor for CLKOUT3 (1 to 128)
      C_CLKOUT3_DUTY_CYCLE    : real    := 0.5;  -- Duty cycle for CLKOUT3 (0.01 to 0.99)
      C_CLKOUT3_PHASE         : real    := 0.0;  -- Phase shift (degrees) for CLKOUT3 (0.0 to 360.0)
      C_CLKOUT4_DIVIDE        : integer := 1;  -- Division factor for CLKOUT4 (1 to 128)
      C_CLKOUT4_DUTY_CYCLE    : real    := 0.5;  -- Duty cycle for CLKOUT4 (0.01 to 0.99)
      C_CLKOUT4_PHASE         : real    := 0.0;  -- Phase shift (degrees) for CLKOUT4 (0.0 to 360.0)
      C_CLKOUT4_CASCADE       : boolean := false;
      C_CLKOUT5_DIVIDE        : integer := 1;  -- Division factor for CLKOUT5 (1 to 128)
      C_CLKOUT5_DUTY_CYCLE    : real    := 0.5;  -- Duty cycle for CLKOUT5 (0.01 to 0.99)
      C_CLKOUT5_PHASE         : real    := 0.0;  -- Phase shift (degrees) for CLKOUT5 (0.0 to 360.0)
      C_CLKOUT6_DIVIDE        : integer := 1;  -- Division factor for CLKOUT5 (1 to 128)
      C_CLKOUT6_DUTY_CYCLE    : real    := 0.5;  -- Duty cycle for CLKOUT5 (0.01 to 0.99)
      C_CLKOUT6_PHASE         : real    := 0.0;  -- Phase shift (degrees) for CLKOUT5 (0.0 to 360.0)
      C_CLKOUT0_USE_FINE_PS   : boolean := false;
      C_CLKOUT1_USE_FINE_PS   : boolean := false;
      C_CLKOUT2_USE_FINE_PS   : boolean := false;
      C_CLKOUT3_USE_FINE_PS   : boolean := false;
      C_CLKOUT4_USE_FINE_PS   : boolean := false;
      C_CLKOUT5_USE_FINE_PS   : boolean := false;
      C_CLKOUT6_USE_FINE_PS   : boolean := false;
      C_COMPENSATION          : string  := "ZHOLD";  
      C_DIVCLK_DIVIDE         : integer := 1;  -- Division factor for all clocks (1 to 52)
      C_REF_JITTER1           : real    := 0.010;  -- Input reference jitter
      C_CLKIN1_BUF            : boolean := false;
      C_CLKFBOUT_BUF          : boolean := false;
      -- C_CLKOUT0_BUF        : boolean := false;
      -- C_CLKOUT1_BUF        : boolean := false;
      -- C_CLKOUT2_BUF        : boolean := false;
      -- C_CLKOUT3_BUF        : boolean := false;
      -- C_CLKOUT4_BUF        : boolean := false;
      -- C_CLKOUT5_BUF        : boolean := false;
      -- C_CLKOUT6_BUF        : boolean := false;
      C_CLOCK_HOLD            : boolean := false;
      C_STARTUP_WAIT          : boolean := false;
      C_EXT_RESET_HIGH        : integer := 1;
      C_FAMILY                : string  := "virtex6";
      -- (2) wrapper
      C_CLKOUT0_BUF           : boolean := false; -- turn on/off bufg for CLKOUT0B
      C_CLKOUT1_BUF           : boolean := false; --
      C_CLKOUT2_BUF           : boolean := false; --
      C_CLKOUT3_BUF           : boolean := false; --
      C_CLKOUT4_BUF           : boolean := false; --
      C_CLKOUT5_BUF           : boolean := false; --
      C_CLKOUT6_BUF           : boolean := false  --
      );
    port (
      -- (1) module
      CLKFBOUT         : out std_logic;
      -- CLKFBOUTB     : out std_logic;
      CLKOUT0          : out std_logic;
      CLKOUT1          : out std_logic;
      CLKOUT2          : out std_logic;
      CLKOUT3          : out std_logic;
      CLKOUT4          : out std_logic;
      CLKOUT5          : out std_logic;
      CLKOUT6          : out std_logic;
      -- CLKOUT0B      : out std_logic;
      -- CLKOUT1B      : out std_logic;
      -- CLKOUT2B      : out std_logic;
      -- CLKOUT3B      : out std_logic;
      LOCKED           : out std_logic;
      -- CLKFBSTOPPED  : out std_logic;
      -- CLKINSTOPPED  : out std_logic;
      PSDONE           : out std_logic;
      CLKFBIN          : in  std_logic;
      CLKIN1           : in  std_logic;
      -- PWRDWN        : in  std_logic;
      PSCLK            : in  std_logic;
      PSEN             : in  std_logic;
      PSINCDEC         : in  std_logic;
      RST              : in  std_logic;
      -- (2) wrapper
      CLKOUT0B         : out std_logic;
      CLKOUT1B         : out std_logic;
      CLKOUT2B         : out std_logic;
      CLKOUT3B         : out std_logic;
      CLKOUT4B         : out std_logic;
      CLKOUT5B         : out std_logic;
      CLKOUT6B         : out std_logic
      );
  end component;
  
  component clock_selection is
    generic (
      C_MODULE                      : string := "NONE";
      C_PORT                        : string := "NONE"
      );
    port (
      CLKGEN                        : in std_logic_vector(0 to 1);
      PLL0                          : in std_logic_vector(0 to 19);
      PLL1                          : in std_logic_vector(0 to 19);
      DCM0                          : in std_logic_vector(0 to 19);
      DCM1                          : in std_logic_vector(0 to 19);
      DCM2                          : in std_logic_vector(0 to 19);
      DCM3                          : in std_logic_vector(0 to 19);
      MMCM0                         : in std_logic_vector(0 to 14);
      MMCM1                         : in std_logic_vector(0 to 14);
      MMCM2                         : in std_logic_vector(0 to 14);
      MMCM3                         : in std_logic_vector(0 to 14);
      CLKOUT                        : out std_logic
      );
  end component;

  component reset_selection is
    generic (
      C_MODULE                      : string := "NONE"
      );
    port (
      CLKGEN                        : in std_logic;
      PLL0                          : in std_logic;
      PLL1                          : in std_logic;
      DCM0                          : in std_logic;
      DCM1                          : in std_logic;
      DCM2                          : in std_logic;
      DCM3                          : in std_logic;
      MMCM0                         : in std_logic;
      MMCM1                         : in std_logic;
      MMCM2                         : in std_logic;
      MMCM3                         : in std_logic;
      RST                           : out std_logic
      );
  end component;

  ----------------------------------------------------------------------------
  -- Functions
  ----------------------------------------------------------------------------

  -- Note : The string functions are put here to remove dependency to other pcore level libraries

  function UpperCase_Char(char : character) return character is
  begin
    -- If char is not an upper case letter then return char
    if char < 'a' or char > 'z' then
      return char;
    end if;
    -- Otherwise map char to its corresponding lower case character and
    -- return that
    case char is
      when 'a'    => return 'A'; when 'b' => return 'B'; when 'c' => return 'C'; when 'd' => return 'D';
      when 'e'    => return 'E'; when 'f' => return 'F'; when 'g' => return 'G'; when 'h' => return 'H';
      when 'i'    => return 'I'; when 'j' => return 'J'; when 'k' => return 'K'; when 'l' => return 'L';
      when 'm'    => return 'M'; when 'n' => return 'N'; when 'o' => return 'O'; when 'p' => return 'P';
      when 'q'    => return 'Q'; when 'r' => return 'R'; when 's' => return 'S'; when 't' => return 'T';
      when 'u'    => return 'U'; when 'v' => return 'V'; when 'w' => return 'W'; when 'x' => return 'X';
      when 'y'    => return 'Y'; when 'z' => return 'Z';
      when others => return char;
    end case;
  end UpperCase_Char;

  function UpperCase_String (s : string) return string is
    variable res               : string(s'range);
  begin  -- function LoweerCase_String
    for I in s'range loop
      res(I) := UpperCase_Char(s(I));
    end loop;  -- I
    return res;
  end function UpperCase_String;

  -- Returns true if case insensitive string comparison determines that
  -- str1 and str2 are equal
  function equalString( str1, str2 : string ) return boolean is
    constant len1                  : integer := str1'length;
    constant len2                  : integer := str2'length;
    variable equal                 : boolean := true;
  begin
    if not (len1 = len2) then
      equal                                  := false;
    else
      for i in str1'range loop
        if not (UpperCase_Char(str1(i)) = UpperCase_Char(str2(i))) then
          equal                              := false;
        end if;
      end loop;
    end if;

    return equal;
  end equalString;

  ----------------------------------------------------------------------------
  -- Signals
  ----------------------------------------------------------------------------

  -- signals: output clocks

  signal CLKGEN_CLK_IN             : std_logic_vector(0 to 1);
  signal PLL0_CLK_OUT              : std_logic_vector(0 to 19);
  signal PLL1_CLK_OUT              : std_logic_vector(0 to 19);
  signal DCM0_CLK_OUT              : std_logic_vector(0 to 19);
  signal DCM1_CLK_OUT              : std_logic_vector(0 to 19);
  signal DCM2_CLK_OUT              : std_logic_vector(0 to 19);
  signal DCM3_CLK_OUT              : std_logic_vector(0 to 19);
  signal MMCM0_CLK_OUT             : std_logic_vector(0 to 14);
  signal MMCM1_CLK_OUT             : std_logic_vector(0 to 14);
  signal MMCM2_CLK_OUT             : std_logic_vector(0 to 14);
  signal MMCM3_CLK_OUT             : std_logic_vector(0 to 14);

  -- signals: input clocks

  signal CLKGEN_CLK_OUT            : std_logic_vector(0 to 15);
  signal CLKGEN_CLK_FBOUT          : std_logic;
  signal PLL0_CLK_IN               : std_logic;
  signal PLL0_CLK_FBIN             : std_logic;
  signal PLL1_CLK_IN               : std_logic;
  signal PLL1_CLK_FBIN             : std_logic;
  signal DCM0_CLK_IN               : std_logic;
  signal DCM0_CLK_FBIN             : std_logic;
  signal DCM1_CLK_IN               : std_logic;
  signal DCM1_CLK_FBIN             : std_logic;
  signal DCM2_CLK_IN               : std_logic;
  signal DCM2_CLK_FBIN             : std_logic;
  signal DCM3_CLK_IN               : std_logic;
  signal DCM3_CLK_FBIN             : std_logic;
  signal MMCM0_CLK_IN              : std_logic;
  signal MMCM0_CLK_FBIN            : std_logic;
  signal MMCM1_CLK_IN              : std_logic;
  signal MMCM1_CLK_FBIN            : std_logic;
  signal MMCM2_CLK_IN              : std_logic;
  signal MMCM2_CLK_FBIN            : std_logic;
  signal MMCM3_CLK_IN              : std_logic;
  signal MMCM3_CLK_FBIN            : std_logic;

  -- signals: reset and locked

  --signal CLKGEN_RST_IN           : std_logic;
  signal PLL0_RST                  : std_logic;
  signal PLL0_LOCKED               : std_logic;
  signal PLL1_RST                  : std_logic;
  signal PLL1_LOCKED               : std_logic;
  signal DCM0_RST                  : std_logic;
  signal DCM0_LOCKED               : std_logic;
  signal DCM1_RST                  : std_logic;
  signal DCM1_LOCKED               : std_logic;
  signal DCM2_RST                  : std_logic;
  signal DCM2_LOCKED               : std_logic;
  signal DCM3_RST                  : std_logic;
  signal DCM3_LOCKED               : std_logic;
  signal MMCM0_RST                 : std_logic;
  signal MMCM0_LOCKED              : std_logic;
  signal MMCM1_RST                 : std_logic;
  signal MMCM1_LOCKED              : std_logic;
  signal MMCM2_RST                 : std_logic;
  signal MMCM2_LOCKED              : std_logic;
  signal MMCM3_RST                 : std_logic;
  signal MMCM3_LOCKED              : std_logic;

  -- signals: variable phase control signals

  signal MMCM0_PSEN                : std_logic;
  signal MMCM0_PSCLK               : std_logic;
  signal MMCM0_PSINCDEC            : std_logic;
  signal MMCM0_PSDONE              : std_logic;
  signal MMCM1_PSEN                : std_logic;
  signal MMCM1_PSCLK               : std_logic;
  signal MMCM1_PSINCDEC            : std_logic;
  signal MMCM1_PSDONE              : std_logic;
  signal MMCM2_PSEN                : std_logic;
  signal MMCM2_PSCLK               : std_logic;
  signal MMCM2_PSINCDEC            : std_logic;
  signal MMCM2_PSDONE              : std_logic;
  signal MMCM3_PSEN                : std_logic;
  signal MMCM3_PSCLK               : std_logic;
  signal MMCM3_PSINCDEC            : std_logic;
  signal MMCM3_PSDONE              : std_logic;

  -- signals: gnd

  signal net_gnd0  : std_logic;
  signal net_gnd1  : std_logic_vector(0 to 0);
  signal net_gnd16 : std_logic_vector(0 to 15);

  -- signals: vdd

  signal net_vdd0  : std_logic;

begin

  ----------------------------------------------------------------------------
  -- GND and VCC signals
  ----------------------------------------------------------------------------

  net_gnd0           <= '0';
  net_gnd1(0 to 0)   <= B"0";
  net_gnd16(0 to 15) <= B"0000000000000000";

  net_vdd0           <= '1';

  ----------------------------------------------------------------------------
  -- PLL and DCM module wrapper instance
  ----------------------------------------------------------------------------

  Using_PLL0 : if ( equalString(C_PLL0_CLKIN1_MODULE, "NONE") = false ) generate
    PLL0_INST : pll_module_wrapper
      generic map (
        -- base pll_adv parameters
        C_BANDWIDTH                => C_PLL0_BANDWIDTH,
        C_CLKFBOUT_MULT            => C_PLL0_CLKFBOUT_MULT,
        C_CLKFBOUT_PHASE           => C_PLL0_CLKFBOUT_PHASE,
        C_CLKIN1_PERIOD            => C_PLL0_CLKIN1_PERIOD,
        -- C_CLKIN2_PERIOD         => 
        C_CLKOUT0_DIVIDE           => C_PLL0_CLKOUT0_DIVIDE,
        C_CLKOUT0_DUTY_CYCLE       => C_PLL0_CLKOUT0_DUTY_CYCLE,
        C_CLKOUT0_PHASE            => C_PLL0_CLKOUT0_PHASE,
        C_CLKOUT1_DIVIDE           => C_PLL0_CLKOUT1_DIVIDE,
        C_CLKOUT1_DUTY_CYCLE       => C_PLL0_CLKOUT1_DUTY_CYCLE, 
        C_CLKOUT1_PHASE            => C_PLL0_CLKOUT1_PHASE,
        C_CLKOUT2_DIVIDE           => C_PLL0_CLKOUT2_DIVIDE,
        C_CLKOUT2_DUTY_CYCLE       => C_PLL0_CLKOUT2_DUTY_CYCLE,
        C_CLKOUT2_PHASE            => C_PLL0_CLKOUT2_PHASE,
        C_CLKOUT3_DIVIDE           => C_PLL0_CLKOUT3_DIVIDE,
        C_CLKOUT3_DUTY_CYCLE       => C_PLL0_CLKOUT3_DUTY_CYCLE,
        C_CLKOUT3_PHASE            => C_PLL0_CLKOUT3_PHASE,
        C_CLKOUT4_DIVIDE           => C_PLL0_CLKOUT4_DIVIDE,
        C_CLKOUT4_DUTY_CYCLE       => C_PLL0_CLKOUT4_DUTY_CYCLE,
        C_CLKOUT4_PHASE            => C_PLL0_CLKOUT4_PHASE,
        C_CLKOUT5_DIVIDE           => C_PLL0_CLKOUT5_DIVIDE,
        C_CLKOUT5_DUTY_CYCLE       => C_PLL0_CLKOUT5_DUTY_CYCLE,
        C_CLKOUT5_PHASE            => C_PLL0_CLKOUT5_PHASE,
        C_COMPENSATION             => C_PLL0_COMPENSATION,
        C_DIVCLK_DIVIDE            => C_PLL0_DIVCLK_DIVIDE,
        -- C_EN_REL                => 
        -- C_PLL_PMCD_MODE         => 
        C_REF_JITTER               => C_PLL0_REF_JITTER,
        C_RESET_ON_LOSS_OF_LOCK    => C_PLL0_RESET_ON_LOSS_OF_LOCK,
        C_RST_DEASSERT_CLK         => C_PLL0_RST_DEASSERT_CLK,
        C_CLKOUT0_DESKEW_ADJUST    => C_PLL0_CLKOUT0_DESKEW_ADJUST,
        C_CLKOUT1_DESKEW_ADJUST    => C_PLL0_CLKOUT1_DESKEW_ADJUST,
        C_CLKOUT2_DESKEW_ADJUST    => C_PLL0_CLKOUT2_DESKEW_ADJUST,
        C_CLKOUT3_DESKEW_ADJUST    => C_PLL0_CLKOUT3_DESKEW_ADJUST,
        C_CLKOUT4_DESKEW_ADJUST    => C_PLL0_CLKOUT4_DESKEW_ADJUST,
        C_CLKOUT5_DESKEW_ADJUST    => C_PLL0_CLKOUT5_DESKEW_ADJUST,
        C_CLKFBOUT_DESKEW_ADJUST   => C_PLL0_CLKFBOUT_DESKEW_ADJUST,
        -- parameters for pcore
        C_CLKIN1_BUF               => C_PLL0_CLKIN1_BUF,
        -- C_CLKIN2_BUF            => 
        C_CLKFBOUT_BUF             => C_PLL0_CLKFBOUT_BUF,
        C_CLKOUT0_BUF              => C_PLL0_CLKOUT0_BUF,
        C_CLKOUT1_BUF              => C_PLL0_CLKOUT1_BUF,
        C_CLKOUT2_BUF              => C_PLL0_CLKOUT2_BUF,
        C_CLKOUT3_BUF              => C_PLL0_CLKOUT3_BUF,
        C_CLKOUT4_BUF              => C_PLL0_CLKOUT4_BUF,
        C_CLKOUT5_BUF              => C_PLL0_CLKOUT5_BUF,
        C_EXT_RESET_HIGH           => C_PLL0_EXT_RESET_HIGH,
        C_FAMILY                   => C_PLL0_FAMILY
        )
      port map (
        CLKFBDCM                   => PLL0_CLK_OUT(13),
        CLKFBOUT                   => PLL0_CLK_OUT(6),
        CLKOUT0                    => PLL0_CLK_OUT(0),
        CLKOUT1                    => PLL0_CLK_OUT(1),
        CLKOUT2                    => PLL0_CLK_OUT(2),
        CLKOUT3                    => PLL0_CLK_OUT(3),
        CLKOUT4                    => PLL0_CLK_OUT(4),
        CLKOUT5                    => PLL0_CLK_OUT(5),
        CLKOUTDCM0                 => PLL0_CLK_OUT(7),
        CLKOUTDCM1                 => PLL0_CLK_OUT(8),
        CLKOUTDCM2                 => PLL0_CLK_OUT(9),
        CLKOUTDCM3                 => PLL0_CLK_OUT(10),
        CLKOUTDCM4                 => PLL0_CLK_OUT(11),
        CLKOUTDCM5                 => PLL0_CLK_OUT(12),
        -- DO                      =>
        -- DRDY                    =>
        LOCKED                     => PLL0_LOCKED,
        CLKFBIN                    => PLL0_CLK_FBIN,
        CLKIN1                     => PLL0_CLK_IN,
        -- CLKIN2                  =>
        -- CLKINSEL                =>
        -- DADDR                   =>
        -- DCLK                    =>
        -- DEN                     =>
        -- DI                      =>
        -- DWE                     =>
        -- REL                     =>
        RST                        => PLL0_RST,
        -- wrapper
        CLKOUT0B                   => PLL0_CLK_OUT(14),
        CLKOUT1B                   => PLL0_CLK_OUT(15),
        CLKOUT2B                   => PLL0_CLK_OUT(16),
        CLKOUT3B                   => PLL0_CLK_OUT(17),
        CLKOUT4B                   => PLL0_CLK_OUT(18),
        CLKOUT5B                   => PLL0_CLK_OUT(19)
        );
  end generate Using_PLL0;

  Using_PLL1 : if ( equalString(C_PLL1_CLKIN1_MODULE, "NONE") = false ) generate
    PLL1_INST : pll_module_wrapper
      generic map (
        -- base pll_adv parameters
        C_BANDWIDTH                => C_PLL1_BANDWIDTH,
        C_CLKFBOUT_MULT            => C_PLL1_CLKFBOUT_MULT,
        C_CLKFBOUT_PHASE           => C_PLL1_CLKFBOUT_PHASE,
        C_CLKIN1_PERIOD            => C_PLL1_CLKIN1_PERIOD,
        -- C_CLKIN2_PERIOD         => 
        C_CLKOUT0_DIVIDE           => C_PLL1_CLKOUT0_DIVIDE,
        C_CLKOUT0_DUTY_CYCLE       => C_PLL1_CLKOUT0_DUTY_CYCLE,
        C_CLKOUT0_PHASE            => C_PLL1_CLKOUT0_PHASE,
        C_CLKOUT1_DIVIDE           => C_PLL1_CLKOUT1_DIVIDE,
        C_CLKOUT1_DUTY_CYCLE       => C_PLL1_CLKOUT1_DUTY_CYCLE, 
        C_CLKOUT1_PHASE            => C_PLL1_CLKOUT1_PHASE,
        C_CLKOUT2_DIVIDE           => C_PLL1_CLKOUT2_DIVIDE,
        C_CLKOUT2_DUTY_CYCLE       => C_PLL1_CLKOUT2_DUTY_CYCLE,
        C_CLKOUT2_PHASE            => C_PLL1_CLKOUT2_PHASE,
        C_CLKOUT3_DIVIDE           => C_PLL1_CLKOUT3_DIVIDE,
        C_CLKOUT3_DUTY_CYCLE       => C_PLL1_CLKOUT3_DUTY_CYCLE,
        C_CLKOUT3_PHASE            => C_PLL1_CLKOUT3_PHASE,
        C_CLKOUT4_DIVIDE           => C_PLL1_CLKOUT4_DIVIDE,
        C_CLKOUT4_DUTY_CYCLE       => C_PLL1_CLKOUT4_DUTY_CYCLE,
        C_CLKOUT4_PHASE            => C_PLL1_CLKOUT4_PHASE,
        C_CLKOUT5_DIVIDE           => C_PLL1_CLKOUT5_DIVIDE,
        C_CLKOUT5_DUTY_CYCLE       => C_PLL1_CLKOUT5_DUTY_CYCLE,
        C_CLKOUT5_PHASE            => C_PLL1_CLKOUT5_PHASE,
        C_COMPENSATION             => C_PLL1_COMPENSATION,
        C_DIVCLK_DIVIDE            => C_PLL1_DIVCLK_DIVIDE,
        -- C_EN_REL                => 
        -- C_PLL_PMCD_MODE         => 
        C_REF_JITTER               => C_PLL1_REF_JITTER,
        C_RESET_ON_LOSS_OF_LOCK    => C_PLL1_RESET_ON_LOSS_OF_LOCK,
        C_RST_DEASSERT_CLK         => C_PLL1_RST_DEASSERT_CLK,
        C_CLKOUT0_DESKEW_ADJUST    => C_PLL1_CLKOUT0_DESKEW_ADJUST,
        C_CLKOUT1_DESKEW_ADJUST    => C_PLL1_CLKOUT1_DESKEW_ADJUST,
        C_CLKOUT2_DESKEW_ADJUST    => C_PLL1_CLKOUT2_DESKEW_ADJUST,
        C_CLKOUT3_DESKEW_ADJUST    => C_PLL1_CLKOUT3_DESKEW_ADJUST,
        C_CLKOUT4_DESKEW_ADJUST    => C_PLL1_CLKOUT4_DESKEW_ADJUST,
        C_CLKOUT5_DESKEW_ADJUST    => C_PLL1_CLKOUT5_DESKEW_ADJUST,
        C_CLKFBOUT_DESKEW_ADJUST   => C_PLL1_CLKFBOUT_DESKEW_ADJUST,
        -- parameters for pcore
        C_CLKIN1_BUF               => C_PLL1_CLKIN1_BUF,
        -- C_CLKIN2_BUF            => 
        C_CLKFBOUT_BUF             => C_PLL1_CLKFBOUT_BUF,
        C_CLKOUT0_BUF              => C_PLL1_CLKOUT0_BUF,
        C_CLKOUT1_BUF              => C_PLL1_CLKOUT1_BUF,
        C_CLKOUT2_BUF              => C_PLL1_CLKOUT2_BUF,
        C_CLKOUT3_BUF              => C_PLL1_CLKOUT3_BUF,
        C_CLKOUT4_BUF              => C_PLL1_CLKOUT4_BUF,
        C_CLKOUT5_BUF              => C_PLL1_CLKOUT5_BUF,
        C_EXT_RESET_HIGH           => C_PLL1_EXT_RESET_HIGH,
        C_FAMILY                   => C_PLL1_FAMILY
        )
      port map (
        CLKFBDCM                   => PLL1_CLK_OUT(13),
        CLKFBOUT                   => PLL1_CLK_OUT(6),
        CLKOUT0                    => PLL1_CLK_OUT(0),
        CLKOUT1                    => PLL1_CLK_OUT(1),
        CLKOUT2                    => PLL1_CLK_OUT(2),
        CLKOUT3                    => PLL1_CLK_OUT(3),
        CLKOUT4                    => PLL1_CLK_OUT(4),
        CLKOUT5                    => PLL1_CLK_OUT(5),
        CLKOUTDCM0                 => PLL1_CLK_OUT(7),
        CLKOUTDCM1                 => PLL1_CLK_OUT(8),
        CLKOUTDCM2                 => PLL1_CLK_OUT(9),
        CLKOUTDCM3                 => PLL1_CLK_OUT(10),
        CLKOUTDCM4                 => PLL1_CLK_OUT(11),
        CLKOUTDCM5                 => PLL1_CLK_OUT(12),
        -- DO                      =>
        -- DRDY                    =>
        LOCKED                     => PLL1_LOCKED,
        CLKFBIN                    => PLL1_CLK_FBIN,
        CLKIN1                     => PLL1_CLK_IN,
        -- CLKIN2                  =>
        -- CLKINSEL                =>
        -- DADDR                   =>
        -- DCLK                    =>
        -- DEN                     =>
        -- DI                      =>
        -- DWE                     =>
        -- REL                     =>
        RST                        => PLL1_RST,
        -- wrapper
        CLKOUT0B                   => PLL1_CLK_OUT(14),
        CLKOUT1B                   => PLL1_CLK_OUT(15),
        CLKOUT2B                   => PLL1_CLK_OUT(16),
        CLKOUT3B                   => PLL1_CLK_OUT(17),
        CLKOUT4B                   => PLL1_CLK_OUT(18),
        CLKOUT5B                   => PLL1_CLK_OUT(19)
        );
  end generate Using_PLL1;

  Using_DCM0 : if ( equalString(C_DCM0_CLKIN_MODULE, "NONE") = false ) generate
    DCM0_INST : dcm_module_wrapper
      generic map (
        C_DFS_FREQUENCY_MODE       => C_DCM0_DFS_FREQUENCY_MODE,
        C_DLL_FREQUENCY_MODE       => C_DCM0_DLL_FREQUENCY_MODE,
        C_DUTY_CYCLE_CORRECTION    => C_DCM0_DUTY_CYCLE_CORRECTION,
        C_CLKIN_DIVIDE_BY_2        => C_DCM0_CLKIN_DIVIDE_BY_2,
        C_CLK_FEEDBACK             => C_DCM0_CLK_FEEDBACK,
        C_CLKOUT_PHASE_SHIFT       => C_DCM0_CLKOUT_PHASE_SHIFT,
        C_DSS_MODE                 => C_DCM0_DSS_MODE,
        C_STARTUP_WAIT             => C_DCM0_STARTUP_WAIT,
        C_PHASE_SHIFT              => C_DCM0_PHASE_SHIFT,
        C_CLKFX_MULTIPLY           => C_DCM0_CLKFX_MULTIPLY,
        C_CLKFX_DIVIDE             => C_DCM0_CLKFX_DIVIDE,
        C_CLKDV_DIVIDE             => C_DCM0_CLKDV_DIVIDE,
        C_CLKIN_PERIOD             => C_DCM0_CLKIN_PERIOD,
        C_DESKEW_ADJUST            => C_DCM0_DESKEW_ADJUST,
        C_CLKIN_BUF                => C_DCM0_CLKIN_BUF,
        C_CLKFB_BUF                => C_DCM0_CLKFB_BUF,
        C_CLK0_BUF                 => C_DCM0_CLK0_BUF,
        C_CLK90_BUF                => C_DCM0_CLK90_BUF,
        C_CLK180_BUF               => C_DCM0_CLK180_BUF,
        C_CLK270_BUF               => C_DCM0_CLK270_BUF,
        C_CLKDV_BUF                => C_DCM0_CLKDV_BUF,
        C_CLKDV180_BUF             => C_DCM0_CLKDV180_BUF,
        C_CLK2X_BUF                => C_DCM0_CLK2X_BUF,
        C_CLK2X180_BUF             => C_DCM0_CLK2X180_BUF,
        C_CLKFX_BUF                => C_DCM0_CLKFX_BUF,
        C_CLKFX180_BUF             => C_DCM0_CLKFX180_BUF,
        C_EXT_RESET_HIGH           => C_DCM0_EXT_RESET_HIGH,
        C_FAMILY                   => C_DCM0_FAMILY
        )
      port map (
        RST                        => DCM0_RST,
        CLKIN                      => DCM0_CLK_IN,
        CLKFB                      => DCM0_CLK_FBIN,
        PSEN                       => net_gnd0,
        PSINCDEC                   => net_gnd0,
        PSCLK                      => net_gnd0,
        DSSEN                      => net_gnd0,
        CLK0                       => DCM0_CLK_OUT(0),
        CLK90                      => DCM0_CLK_OUT(1),
        CLK180                     => DCM0_CLK_OUT(2),
        CLK270                     => DCM0_CLK_OUT(3),
        CLKDV                      => DCM0_CLK_OUT(4),
        CLK2X                      => DCM0_CLK_OUT(5),
        CLK2X180                   => DCM0_CLK_OUT(6),
        CLKFX                      => DCM0_CLK_OUT(7),
        CLKFX180                   => DCM0_CLK_OUT(8),
        STATUS                     => open,
        LOCKED                     => DCM0_LOCKED,
        PSDONE                     => open,
        -- wrapper
        CLKDV180                   => DCM0_CLK_OUT(9),
        CLK0B                      => DCM0_CLK_OUT(10),
        CLK90B                     => DCM0_CLK_OUT(11),
        CLK180B                    => DCM0_CLK_OUT(12),
        CLK270B                    => DCM0_CLK_OUT(13),
        CLKDVB                     => DCM0_CLK_OUT(14),
        CLKDV180B                  => DCM0_CLK_OUT(15),
        CLK2XB                     => DCM0_CLK_OUT(16),
        CLK2X180B                  => DCM0_CLK_OUT(17),
        CLKFXB                     => DCM0_CLK_OUT(18),
        CLKFX180B                  => DCM0_CLK_OUT(19)
        );
  end generate Using_DCM0;

  Using_DCM1 : if ( equalString(C_DCM1_CLKIN_MODULE, "NONE") = false ) generate
    DCM1_INST : dcm_module_wrapper
      generic map (
        C_DFS_FREQUENCY_MODE       => C_DCM1_DFS_FREQUENCY_MODE,
        C_DLL_FREQUENCY_MODE       => C_DCM1_DLL_FREQUENCY_MODE,
        C_DUTY_CYCLE_CORRECTION    => C_DCM1_DUTY_CYCLE_CORRECTION,
        C_CLKIN_DIVIDE_BY_2        => C_DCM1_CLKIN_DIVIDE_BY_2,
        C_CLK_FEEDBACK             => C_DCM1_CLK_FEEDBACK,
        C_CLKOUT_PHASE_SHIFT       => C_DCM1_CLKOUT_PHASE_SHIFT,
        C_DSS_MODE                 => C_DCM1_DSS_MODE,
        C_STARTUP_WAIT             => C_DCM1_STARTUP_WAIT,
        C_PHASE_SHIFT              => C_DCM1_PHASE_SHIFT,
        C_CLKFX_MULTIPLY           => C_DCM1_CLKFX_MULTIPLY,
        C_CLKFX_DIVIDE             => C_DCM1_CLKFX_DIVIDE,
        C_CLKDV_DIVIDE             => C_DCM1_CLKDV_DIVIDE,
        C_CLKIN_PERIOD             => C_DCM1_CLKIN_PERIOD,
        C_DESKEW_ADJUST            => C_DCM1_DESKEW_ADJUST,
        C_CLKIN_BUF                => C_DCM1_CLKIN_BUF,
        C_CLKFB_BUF                => C_DCM1_CLKFB_BUF,
        C_CLK0_BUF                 => C_DCM1_CLK0_BUF,
        C_CLK90_BUF                => C_DCM1_CLK90_BUF,
        C_CLK180_BUF               => C_DCM1_CLK180_BUF,
        C_CLK270_BUF               => C_DCM1_CLK270_BUF,
        C_CLKDV_BUF                => C_DCM1_CLKDV_BUF,
        C_CLKDV180_BUF             => C_DCM1_CLKDV180_BUF,
        C_CLK2X_BUF                => C_DCM1_CLK2X_BUF,
        C_CLK2X180_BUF             => C_DCM1_CLK2X180_BUF,
        C_CLKFX_BUF                => C_DCM1_CLKFX_BUF,
        C_CLKFX180_BUF             => C_DCM1_CLKFX180_BUF,
        C_EXT_RESET_HIGH           => C_DCM1_EXT_RESET_HIGH,
        C_FAMILY                   => C_DCM1_FAMILY
        )
      port map (
        RST                        => DCM1_RST,
        CLKIN                      => DCM1_CLK_IN,
        CLKFB                      => DCM1_CLK_FBIN,
        PSEN                       => net_gnd0,
        PSINCDEC                   => net_gnd0,
        PSCLK                      => net_gnd0,
        DSSEN                      => net_gnd0,
        CLK0                       => DCM1_CLK_OUT(0),
        CLK90                      => DCM1_CLK_OUT(1),
        CLK180                     => DCM1_CLK_OUT(2),
        CLK270                     => DCM1_CLK_OUT(3),
        CLKDV                      => DCM1_CLK_OUT(4),
        CLK2X                      => DCM1_CLK_OUT(5),
        CLK2X180                   => DCM1_CLK_OUT(6),
        CLKFX                      => DCM1_CLK_OUT(7),
        CLKFX180                   => DCM1_CLK_OUT(8),
        STATUS                     => open,
        LOCKED                     => DCM1_LOCKED,
        PSDONE                     => open,
        -- wrapper
        CLKDV180                   => DCM1_CLK_OUT(9),
        CLK0B                      => DCM1_CLK_OUT(10),
        CLK90B                     => DCM1_CLK_OUT(11),
        CLK180B                    => DCM1_CLK_OUT(12),
        CLK270B                    => DCM1_CLK_OUT(13),
        CLKDVB                     => DCM1_CLK_OUT(14),
        CLKDV180B                  => DCM1_CLK_OUT(15),
        CLK2XB                     => DCM1_CLK_OUT(16),
        CLK2X180B                  => DCM1_CLK_OUT(17),
        CLKFXB                     => DCM1_CLK_OUT(18),
        CLKFX180B                  => DCM1_CLK_OUT(19)
        );
  end generate Using_DCM1;

  Using_DCM2 : if ( equalString(C_DCM2_CLKIN_MODULE, "NONE") = false ) generate
    DCM2_INST : dcm_module_wrapper
      generic map (
        C_DFS_FREQUENCY_MODE       => C_DCM2_DFS_FREQUENCY_MODE,
        C_DLL_FREQUENCY_MODE       => C_DCM2_DLL_FREQUENCY_MODE,
        C_DUTY_CYCLE_CORRECTION    => C_DCM2_DUTY_CYCLE_CORRECTION,
        C_CLKIN_DIVIDE_BY_2        => C_DCM2_CLKIN_DIVIDE_BY_2,
        C_CLK_FEEDBACK             => C_DCM2_CLK_FEEDBACK,
        C_CLKOUT_PHASE_SHIFT       => C_DCM2_CLKOUT_PHASE_SHIFT,
        C_DSS_MODE                 => C_DCM2_DSS_MODE,
        C_STARTUP_WAIT             => C_DCM2_STARTUP_WAIT,
        C_PHASE_SHIFT              => C_DCM2_PHASE_SHIFT,
        C_CLKFX_MULTIPLY           => C_DCM2_CLKFX_MULTIPLY,
        C_CLKFX_DIVIDE             => C_DCM2_CLKFX_DIVIDE,
        C_CLKDV_DIVIDE             => C_DCM2_CLKDV_DIVIDE,
        C_CLKIN_PERIOD             => C_DCM2_CLKIN_PERIOD,
        C_DESKEW_ADJUST            => C_DCM2_DESKEW_ADJUST,
        C_CLKIN_BUF                => C_DCM2_CLKIN_BUF,
        C_CLKFB_BUF                => C_DCM2_CLKFB_BUF,
        C_CLK0_BUF                 => C_DCM2_CLK0_BUF,
        C_CLK90_BUF                => C_DCM2_CLK90_BUF,
        C_CLK180_BUF               => C_DCM2_CLK180_BUF,
        C_CLK270_BUF               => C_DCM2_CLK270_BUF,
        C_CLKDV_BUF                => C_DCM2_CLKDV_BUF,
        C_CLKDV180_BUF             => C_DCM2_CLKDV180_BUF,
        C_CLK2X_BUF                => C_DCM2_CLK2X_BUF,
        C_CLK2X180_BUF             => C_DCM2_CLK2X180_BUF,
        C_CLKFX_BUF                => C_DCM2_CLKFX_BUF,
        C_CLKFX180_BUF             => C_DCM2_CLKFX180_BUF,
        C_EXT_RESET_HIGH           => C_DCM2_EXT_RESET_HIGH,
        C_FAMILY                   => C_DCM2_FAMILY
        )
      port map (
        RST                        => DCM2_RST,
        CLKIN                      => DCM2_CLK_IN,
        CLKFB                      => DCM2_CLK_FBIN,
        PSEN                       => net_gnd0,
        PSINCDEC                   => net_gnd0,
        PSCLK                      => net_gnd0,
        DSSEN                      => net_gnd0,
        CLK0                       => DCM2_CLK_OUT(0),
        CLK90                      => DCM2_CLK_OUT(1),
        CLK180                     => DCM2_CLK_OUT(2),
        CLK270                     => DCM2_CLK_OUT(3),
        CLKDV                      => DCM2_CLK_OUT(4),
        CLK2X                      => DCM2_CLK_OUT(5),
        CLK2X180                   => DCM2_CLK_OUT(6),
        CLKFX                      => DCM2_CLK_OUT(7),
        CLKFX180                   => DCM2_CLK_OUT(8),
        STATUS                     => open,
        LOCKED                     => DCM2_LOCKED,
        PSDONE                     => open,
        -- wrapper
        CLKDV180                   => DCM2_CLK_OUT(9),
        CLK0B                      => DCM2_CLK_OUT(10),
        CLK90B                     => DCM2_CLK_OUT(11),
        CLK180B                    => DCM2_CLK_OUT(12),
        CLK270B                    => DCM2_CLK_OUT(13),
        CLKDVB                     => DCM2_CLK_OUT(14),
        CLKDV180B                  => DCM2_CLK_OUT(15),
        CLK2XB                     => DCM2_CLK_OUT(16),
        CLK2X180B                  => DCM2_CLK_OUT(17),
        CLKFXB                     => DCM2_CLK_OUT(18),
        CLKFX180B                  => DCM2_CLK_OUT(19)
        );
  end generate Using_DCM2;

  Using_DCM3 : if ( equalString(C_DCM3_CLKIN_MODULE, "NONE") = false ) generate
    DCM3_INST : dcm_module_wrapper
      generic map (
        C_DFS_FREQUENCY_MODE       => C_DCM3_DFS_FREQUENCY_MODE,
        C_DLL_FREQUENCY_MODE       => C_DCM3_DLL_FREQUENCY_MODE,
        C_DUTY_CYCLE_CORRECTION    => C_DCM3_DUTY_CYCLE_CORRECTION,
        C_CLKIN_DIVIDE_BY_2        => C_DCM3_CLKIN_DIVIDE_BY_2,
        C_CLK_FEEDBACK             => C_DCM3_CLK_FEEDBACK,
        C_CLKOUT_PHASE_SHIFT       => C_DCM3_CLKOUT_PHASE_SHIFT,
        C_DSS_MODE                 => C_DCM3_DSS_MODE,
        C_STARTUP_WAIT             => C_DCM3_STARTUP_WAIT,
        C_PHASE_SHIFT              => C_DCM3_PHASE_SHIFT,
        C_CLKFX_MULTIPLY           => C_DCM3_CLKFX_MULTIPLY,
        C_CLKFX_DIVIDE             => C_DCM3_CLKFX_DIVIDE,
        C_CLKDV_DIVIDE             => C_DCM3_CLKDV_DIVIDE,
        C_CLKIN_PERIOD             => C_DCM3_CLKIN_PERIOD,
        C_DESKEW_ADJUST            => C_DCM3_DESKEW_ADJUST,
        C_CLKIN_BUF                => C_DCM3_CLKIN_BUF,
        C_CLKFB_BUF                => C_DCM3_CLKFB_BUF,
        C_CLK0_BUF                 => C_DCM3_CLK0_BUF,
        C_CLK90_BUF                => C_DCM3_CLK90_BUF,
        C_CLK180_BUF               => C_DCM3_CLK180_BUF,
        C_CLK270_BUF               => C_DCM3_CLK270_BUF,
        C_CLKDV_BUF                => C_DCM3_CLKDV_BUF,
        C_CLKDV180_BUF             => C_DCM3_CLKDV180_BUF,
        C_CLK2X_BUF                => C_DCM3_CLK2X_BUF,
        C_CLK2X180_BUF             => C_DCM3_CLK2X180_BUF,
        C_CLKFX_BUF                => C_DCM3_CLKFX_BUF,
        C_CLKFX180_BUF             => C_DCM3_CLKFX180_BUF,
        C_EXT_RESET_HIGH           => C_DCM3_EXT_RESET_HIGH,
        C_FAMILY                   => C_DCM3_FAMILY
        )
      port map (
        RST                        => DCM3_RST,
        CLKIN                      => DCM3_CLK_IN,
        CLKFB                      => DCM3_CLK_FBIN,
        PSEN                       => net_gnd0,
        PSINCDEC                   => net_gnd0,
        PSCLK                      => net_gnd0,
        DSSEN                      => net_gnd0,
        CLK0                       => DCM3_CLK_OUT(0),
        CLK90                      => DCM3_CLK_OUT(1),
        CLK180                     => DCM3_CLK_OUT(2),
        CLK270                     => DCM3_CLK_OUT(3),
        CLKDV                      => DCM3_CLK_OUT(4),
        CLK2X                      => DCM3_CLK_OUT(5),
        CLK2X180                   => DCM3_CLK_OUT(6),
        CLKFX                      => DCM3_CLK_OUT(7),
        CLKFX180                   => DCM3_CLK_OUT(8),
        STATUS                     => open,
        LOCKED                     => DCM3_LOCKED,
        PSDONE                     => open,
        -- wrapper
        CLKDV180                   => DCM3_CLK_OUT(9),
        CLK0B                      => DCM3_CLK_OUT(10),
        CLK90B                     => DCM3_CLK_OUT(11),
        CLK180B                    => DCM3_CLK_OUT(12),
        CLK270B                    => DCM3_CLK_OUT(13),
        CLKDVB                     => DCM3_CLK_OUT(14),
        CLKDV180B                  => DCM3_CLK_OUT(15),
        CLK2XB                     => DCM3_CLK_OUT(16),
        CLK2X180B                  => DCM3_CLK_OUT(17),
        CLKFXB                     => DCM3_CLK_OUT(18),
        CLKFX180B                  => DCM3_CLK_OUT(19)
        );
  end generate Using_DCM3;

  Using_MMCM0 : if ( equalString(C_MMCM0_CLKIN1_MODULE, "NONE") = false ) generate
    MMCM0_INST : mmcm_module_wrapper
      generic map (
        -- (1) module
        C_BANDWIDTH                => C_MMCM0_BANDWIDTH,
        C_CLKFBOUT_MULT_F          => C_MMCM0_CLKFBOUT_MULT_F,
        C_CLKFBOUT_PHASE           => C_MMCM0_CLKFBOUT_PHASE,
        C_CLKFBOUT_USE_FINE_PS     => C_MMCM0_CLKFBOUT_USE_FINE_PS,
        C_CLKIN1_PERIOD            => C_MMCM0_CLKIN1_PERIOD,
        C_CLKOUT0_DIVIDE_F         => C_MMCM0_CLKOUT0_DIVIDE_F,
        C_CLKOUT0_DUTY_CYCLE       => C_MMCM0_CLKOUT0_DUTY_CYCLE,
        C_CLKOUT0_PHASE            => C_MMCM0_CLKOUT0_PHASE,
        C_CLKOUT1_DIVIDE           => C_MMCM0_CLKOUT1_DIVIDE,
        C_CLKOUT1_DUTY_CYCLE       => C_MMCM0_CLKOUT1_DUTY_CYCLE,
        C_CLKOUT1_PHASE            => C_MMCM0_CLKOUT1_PHASE,
        C_CLKOUT2_DIVIDE           => C_MMCM0_CLKOUT2_DIVIDE,
        C_CLKOUT2_DUTY_CYCLE       => C_MMCM0_CLKOUT2_DUTY_CYCLE,
        C_CLKOUT2_PHASE            => C_MMCM0_CLKOUT2_PHASE,
        C_CLKOUT3_DIVIDE           => C_MMCM0_CLKOUT3_DIVIDE,
        C_CLKOUT3_DUTY_CYCLE       => C_MMCM0_CLKOUT3_DUTY_CYCLE,
        C_CLKOUT3_PHASE            => C_MMCM0_CLKOUT3_PHASE,
        C_CLKOUT4_DIVIDE           => C_MMCM0_CLKOUT4_DIVIDE,
        C_CLKOUT4_DUTY_CYCLE       => C_MMCM0_CLKOUT4_DUTY_CYCLE,
        C_CLKOUT4_PHASE            => C_MMCM0_CLKOUT4_PHASE,
        C_CLKOUT4_CASCADE          => C_MMCM0_CLKOUT4_CASCADE,
        C_CLKOUT5_DIVIDE           => C_MMCM0_CLKOUT5_DIVIDE,
        C_CLKOUT5_DUTY_CYCLE       => C_MMCM0_CLKOUT5_DUTY_CYCLE,
        C_CLKOUT5_PHASE            => C_MMCM0_CLKOUT5_PHASE,
        C_CLKOUT6_DIVIDE           => C_MMCM0_CLKOUT6_DIVIDE,
        C_CLKOUT6_DUTY_CYCLE       => C_MMCM0_CLKOUT6_DUTY_CYCLE,
        C_CLKOUT6_PHASE            => C_MMCM0_CLKOUT6_PHASE,
        C_CLKOUT0_USE_FINE_PS      => C_MMCM0_CLKOUT0_USE_FINE_PS,
        C_CLKOUT1_USE_FINE_PS      => C_MMCM0_CLKOUT1_USE_FINE_PS,
        C_CLKOUT2_USE_FINE_PS      => C_MMCM0_CLKOUT2_USE_FINE_PS,
        C_CLKOUT3_USE_FINE_PS      => C_MMCM0_CLKOUT3_USE_FINE_PS,
        C_CLKOUT4_USE_FINE_PS      => C_MMCM0_CLKOUT4_USE_FINE_PS,
        C_CLKOUT5_USE_FINE_PS      => C_MMCM0_CLKOUT5_USE_FINE_PS,
        C_CLKOUT6_USE_FINE_PS      => C_MMCM0_CLKOUT6_USE_FINE_PS,
        C_COMPENSATION             => C_MMCM0_COMPENSATION,
        C_DIVCLK_DIVIDE            => C_MMCM0_DIVCLK_DIVIDE,
        C_REF_JITTER1              => C_MMCM0_REF_JITTER1,
        C_CLKIN1_BUF               => C_MMCM0_CLKIN1_BUF,
        C_CLKFBOUT_BUF             => C_MMCM0_CLKFBOUT_BUF,
        -- C_CLKOUT0_BUF           => 
        -- C_CLKOUT1_BUF           => 
        -- C_CLKOUT2_BUF           => 
        -- C_CLKOUT3_BUF           => 
        -- C_CLKOUT4_BUF           => 
        -- C_CLKOUT5_BUF           => 
        -- C_CLKOUT6_BUF           => 
        C_CLOCK_HOLD               => C_MMCM0_CLOCK_HOLD,
        C_STARTUP_WAIT             => C_MMCM0_STARTUP_WAIT,
        C_EXT_RESET_HIGH           => C_MMCM0_EXT_RESET_HIGH,
        C_FAMILY                   => C_MMCM0_FAMILY,
        -- (2) wrapper
        C_CLKOUT0_BUF              => C_MMCM0_CLKOUT0_BUF,
        C_CLKOUT1_BUF              => C_MMCM0_CLKOUT1_BUF,
        C_CLKOUT2_BUF              => C_MMCM0_CLKOUT2_BUF,
        C_CLKOUT3_BUF              => C_MMCM0_CLKOUT3_BUF,
        C_CLKOUT4_BUF              => C_MMCM0_CLKOUT4_BUF,
        C_CLKOUT5_BUF              => C_MMCM0_CLKOUT5_BUF,
        C_CLKOUT6_BUF              => C_MMCM0_CLKOUT6_BUF
        )
      port map (
        -- (1) module
        CLKFBOUT                   => MMCM0_CLK_OUT(7),
        -- CLKFBOUTB               => 
        CLKOUT0                    => MMCM0_CLK_OUT(0),
        CLKOUT1                    => MMCM0_CLK_OUT(1),
        CLKOUT2                    => MMCM0_CLK_OUT(2),
        CLKOUT3                    => MMCM0_CLK_OUT(3),
        CLKOUT4                    => MMCM0_CLK_OUT(4),
        CLKOUT5                    => MMCM0_CLK_OUT(5),
        CLKOUT6                    => MMCM0_CLK_OUT(6),
        -- CLKOUT0B                => 
        -- CLKOUT1B                => 
        -- CLKOUT2B                => 
        -- CLKOUT3B                => 
        LOCKED                     => MMCM0_LOCKED,
        -- CLKFBSTOPPED            => 
        -- CLKINSTOPPED            => 
        PSDONE                     => MMCM0_PSDONE,
        CLKFBIN                    => MMCM0_CLK_FBIN,
        CLKIN1                     => MMCM0_CLK_IN,
        -- PWRDWN                  => 
        PSCLK                      => MMCM0_PSCLK,
        PSEN                       => MMCM0_PSEN,
        PSINCDEC                   => MMCM0_PSINCDEC,
        RST                        => MMCM0_RST,
        -- (2) wrapper
        CLKOUT0B                   => MMCM0_CLK_OUT(8),
        CLKOUT1B                   => MMCM0_CLK_OUT(9),
        CLKOUT2B                   => MMCM0_CLK_OUT(10),
        CLKOUT3B                   => MMCM0_CLK_OUT(11),
        CLKOUT4B                   => MMCM0_CLK_OUT(12),
        CLKOUT5B                   => MMCM0_CLK_OUT(13),
        CLKOUT6B                   => MMCM0_CLK_OUT(14)
        );
  end generate Using_MMCM0;


  Using_MMCM1 : if ( equalString(C_MMCM1_CLKIN1_MODULE, "NONE") = false ) generate
    MMCM1_INST : mmcm_module_wrapper
      generic map (
        -- (1) module
        C_BANDWIDTH                => C_MMCM1_BANDWIDTH,
        C_CLKFBOUT_MULT_F          => C_MMCM1_CLKFBOUT_MULT_F,
        C_CLKFBOUT_PHASE           => C_MMCM1_CLKFBOUT_PHASE,
        C_CLKFBOUT_USE_FINE_PS     => C_MMCM1_CLKFBOUT_USE_FINE_PS,
        C_CLKIN1_PERIOD            => C_MMCM1_CLKIN1_PERIOD,
        C_CLKOUT0_DIVIDE_F         => C_MMCM1_CLKOUT0_DIVIDE_F,
        C_CLKOUT0_DUTY_CYCLE       => C_MMCM1_CLKOUT0_DUTY_CYCLE,
        C_CLKOUT0_PHASE            => C_MMCM1_CLKOUT0_PHASE,
        C_CLKOUT1_DIVIDE           => C_MMCM1_CLKOUT1_DIVIDE,
        C_CLKOUT1_DUTY_CYCLE       => C_MMCM1_CLKOUT1_DUTY_CYCLE,
        C_CLKOUT1_PHASE            => C_MMCM1_CLKOUT1_PHASE,
        C_CLKOUT2_DIVIDE           => C_MMCM1_CLKOUT2_DIVIDE,
        C_CLKOUT2_DUTY_CYCLE       => C_MMCM1_CLKOUT2_DUTY_CYCLE,
        C_CLKOUT2_PHASE            => C_MMCM1_CLKOUT2_PHASE,
        C_CLKOUT3_DIVIDE           => C_MMCM1_CLKOUT3_DIVIDE,
        C_CLKOUT3_DUTY_CYCLE       => C_MMCM1_CLKOUT3_DUTY_CYCLE,
        C_CLKOUT3_PHASE            => C_MMCM1_CLKOUT3_PHASE,
        C_CLKOUT4_DIVIDE           => C_MMCM1_CLKOUT4_DIVIDE,
        C_CLKOUT4_DUTY_CYCLE       => C_MMCM1_CLKOUT4_DUTY_CYCLE,
        C_CLKOUT4_PHASE            => C_MMCM1_CLKOUT4_PHASE,
        C_CLKOUT4_CASCADE          => C_MMCM1_CLKOUT4_CASCADE,
        C_CLKOUT5_DIVIDE           => C_MMCM1_CLKOUT5_DIVIDE,
        C_CLKOUT5_DUTY_CYCLE       => C_MMCM1_CLKOUT5_DUTY_CYCLE,
        C_CLKOUT5_PHASE            => C_MMCM1_CLKOUT5_PHASE,
        C_CLKOUT6_DIVIDE           => C_MMCM1_CLKOUT6_DIVIDE,
        C_CLKOUT6_DUTY_CYCLE       => C_MMCM1_CLKOUT6_DUTY_CYCLE,
        C_CLKOUT6_PHASE            => C_MMCM1_CLKOUT6_PHASE,
        C_CLKOUT0_USE_FINE_PS      => C_MMCM1_CLKOUT0_USE_FINE_PS,
        C_CLKOUT1_USE_FINE_PS      => C_MMCM1_CLKOUT1_USE_FINE_PS,
        C_CLKOUT2_USE_FINE_PS      => C_MMCM1_CLKOUT2_USE_FINE_PS,
        C_CLKOUT3_USE_FINE_PS      => C_MMCM1_CLKOUT3_USE_FINE_PS,
        C_CLKOUT4_USE_FINE_PS      => C_MMCM1_CLKOUT4_USE_FINE_PS,
        C_CLKOUT5_USE_FINE_PS      => C_MMCM1_CLKOUT5_USE_FINE_PS,
        C_CLKOUT6_USE_FINE_PS      => C_MMCM1_CLKOUT6_USE_FINE_PS,
        C_COMPENSATION             => C_MMCM1_COMPENSATION,
        C_DIVCLK_DIVIDE            => C_MMCM1_DIVCLK_DIVIDE,
        C_REF_JITTER1              => C_MMCM1_REF_JITTER1,
        C_CLKIN1_BUF               => C_MMCM1_CLKIN1_BUF,
        C_CLKFBOUT_BUF             => C_MMCM1_CLKFBOUT_BUF,
        -- C_CLKOUT0_BUF           => ,
        -- C_CLKOUT1_BUF           => ,
        -- C_CLKOUT2_BUF           => ,
        -- C_CLKOUT3_BUF           => ,
        -- C_CLKOUT4_BUF           => ,
        -- C_CLKOUT5_BUF           => ,
        -- C_CLKOUT6_BUF           => ,
        C_CLOCK_HOLD               => C_MMCM1_CLOCK_HOLD,
        C_STARTUP_WAIT             => C_MMCM1_STARTUP_WAIT,
        C_EXT_RESET_HIGH           => C_MMCM1_EXT_RESET_HIGH,
        C_FAMILY                   => C_MMCM1_FAMILY,
        -- (2) wrapper
        C_CLKOUT0_BUF              => C_MMCM1_CLKOUT0_BUF,
        C_CLKOUT1_BUF              => C_MMCM1_CLKOUT1_BUF,
        C_CLKOUT2_BUF              => C_MMCM1_CLKOUT2_BUF,
        C_CLKOUT3_BUF              => C_MMCM1_CLKOUT3_BUF,
        C_CLKOUT4_BUF              => C_MMCM1_CLKOUT4_BUF,
        C_CLKOUT5_BUF              => C_MMCM1_CLKOUT5_BUF,
        C_CLKOUT6_BUF              => C_MMCM1_CLKOUT6_BUF
        )
      port map (
        -- (1) module
        CLKFBOUT                   => MMCM1_CLK_OUT(7),
        -- CLKFBOUTB               => ,
        CLKOUT0                    => MMCM1_CLK_OUT(0),
        CLKOUT1                    => MMCM1_CLK_OUT(1),
        CLKOUT2                    => MMCM1_CLK_OUT(2),
        CLKOUT3                    => MMCM1_CLK_OUT(3),
        CLKOUT4                    => MMCM1_CLK_OUT(4),
        CLKOUT5                    => MMCM1_CLK_OUT(5),
        CLKOUT6                    => MMCM1_CLK_OUT(6),
        -- CLKOUT0B                => ,
        -- CLKOUT1B                => ,
        -- CLKOUT2B                => ,
        -- CLKOUT3B                => ,
        LOCKED                     => MMCM1_LOCKED,
        -- CLKFBSTOPPED            => ,
        -- CLKINSTOPPED            => ,
        PSDONE                     => MMCM1_PSDONE,
        CLKFBIN                    => MMCM1_CLK_FBIN,
        CLKIN1                     => MMCM1_CLK_IN,
        -- PWRDWN                  => ,
        PSCLK                      => MMCM1_PSCLK,
        PSEN                       => MMCM1_PSEN,
        PSINCDEC                   => MMCM1_PSINCDEC,
        RST                        => MMCM1_RST,
        -- (2) wrapper
        CLKOUT0B                   => MMCM1_CLK_OUT(8),
        CLKOUT1B                   => MMCM1_CLK_OUT(9),
        CLKOUT2B                   => MMCM1_CLK_OUT(10),
        CLKOUT3B                   => MMCM1_CLK_OUT(11),
        CLKOUT4B                   => MMCM1_CLK_OUT(12),
        CLKOUT5B                   => MMCM1_CLK_OUT(13),
        CLKOUT6B                   => MMCM1_CLK_OUT(14)
        );
  end generate Using_MMCM1;

  --------
  -- Note: MMCM2 used only for external feedback
  --------
  Using_MMCM2 : if ( equalString(C_MMCM2_CLKIN1_MODULE, "NONE") = false ) generate
    MMCM2_INST : mmcm_module_wrapper
      generic map (
        -- (1) module
        C_BANDWIDTH                => C_MMCM2_BANDWIDTH,
        C_CLKFBOUT_MULT_F          => C_MMCM2_CLKFBOUT_MULT_F,
        C_CLKFBOUT_PHASE           => C_MMCM2_CLKFBOUT_PHASE,
        C_CLKFBOUT_USE_FINE_PS     => C_MMCM2_CLKFBOUT_USE_FINE_PS,
        C_CLKIN1_PERIOD            => C_MMCM2_CLKIN1_PERIOD,
        C_CLKOUT0_DIVIDE_F         => C_MMCM2_CLKOUT0_DIVIDE_F,
        C_CLKOUT0_DUTY_CYCLE       => C_MMCM2_CLKOUT0_DUTY_CYCLE,
        C_CLKOUT0_PHASE            => C_MMCM2_CLKOUT0_PHASE,
        C_CLKOUT1_DIVIDE           => C_MMCM2_CLKOUT1_DIVIDE,
        C_CLKOUT1_DUTY_CYCLE       => C_MMCM2_CLKOUT1_DUTY_CYCLE,
        C_CLKOUT1_PHASE            => C_MMCM2_CLKOUT1_PHASE,
        C_CLKOUT2_DIVIDE           => C_MMCM2_CLKOUT2_DIVIDE,
        C_CLKOUT2_DUTY_CYCLE       => C_MMCM2_CLKOUT2_DUTY_CYCLE,
        C_CLKOUT2_PHASE            => C_MMCM2_CLKOUT2_PHASE,
        C_CLKOUT3_DIVIDE           => C_MMCM2_CLKOUT3_DIVIDE,
        C_CLKOUT3_DUTY_CYCLE       => C_MMCM2_CLKOUT3_DUTY_CYCLE,
        C_CLKOUT3_PHASE            => C_MMCM2_CLKOUT3_PHASE,
        C_CLKOUT4_DIVIDE           => C_MMCM2_CLKOUT4_DIVIDE,
        C_CLKOUT4_DUTY_CYCLE       => C_MMCM2_CLKOUT4_DUTY_CYCLE,
        C_CLKOUT4_PHASE            => C_MMCM2_CLKOUT4_PHASE,
        C_CLKOUT4_CASCADE          => C_MMCM2_CLKOUT4_CASCADE,
        C_CLKOUT5_DIVIDE           => C_MMCM2_CLKOUT5_DIVIDE,
        C_CLKOUT5_DUTY_CYCLE       => C_MMCM2_CLKOUT5_DUTY_CYCLE,
        C_CLKOUT5_PHASE            => C_MMCM2_CLKOUT5_PHASE,
        C_CLKOUT6_DIVIDE           => C_MMCM2_CLKOUT6_DIVIDE,
        C_CLKOUT6_DUTY_CYCLE       => C_MMCM2_CLKOUT6_DUTY_CYCLE,
        C_CLKOUT6_PHASE            => C_MMCM2_CLKOUT6_PHASE,
        C_CLKOUT0_USE_FINE_PS      => C_MMCM2_CLKOUT0_USE_FINE_PS,
        C_CLKOUT1_USE_FINE_PS      => C_MMCM2_CLKOUT1_USE_FINE_PS,
        C_CLKOUT2_USE_FINE_PS      => C_MMCM2_CLKOUT2_USE_FINE_PS,
        C_CLKOUT3_USE_FINE_PS      => C_MMCM2_CLKOUT3_USE_FINE_PS,
        C_CLKOUT4_USE_FINE_PS      => C_MMCM2_CLKOUT4_USE_FINE_PS,
        C_CLKOUT5_USE_FINE_PS      => C_MMCM2_CLKOUT5_USE_FINE_PS,
        C_CLKOUT6_USE_FINE_PS      => C_MMCM2_CLKOUT6_USE_FINE_PS,
        C_COMPENSATION             => C_MMCM2_COMPENSATION,
        C_DIVCLK_DIVIDE            => C_MMCM2_DIVCLK_DIVIDE,
        C_REF_JITTER1              => C_MMCM2_REF_JITTER1,
        C_CLKIN1_BUF               => C_MMCM2_CLKIN1_BUF,
        C_CLKFBOUT_BUF             => C_MMCM2_CLKFBOUT_BUF,
        -- C_CLKOUT0_BUF           => ,
        -- C_CLKOUT1_BUF           => ,
        -- C_CLKOUT2_BUF           => ,
        -- C_CLKOUT3_BUF           => ,
        -- C_CLKOUT4_BUF           => ,
        -- C_CLKOUT5_BUF           => ,
        -- C_CLKOUT6_BUF           => ,
        C_CLOCK_HOLD               => C_MMCM2_CLOCK_HOLD,
        C_STARTUP_WAIT             => C_MMCM2_STARTUP_WAIT,
        C_EXT_RESET_HIGH           => C_MMCM2_EXT_RESET_HIGH,
        C_FAMILY                   => C_MMCM2_FAMILY,
        -- (2) wrapper
        C_CLKOUT0_BUF              => C_MMCM2_CLKOUT0_BUF,
        C_CLKOUT1_BUF              => C_MMCM2_CLKOUT1_BUF,
        C_CLKOUT2_BUF              => C_MMCM2_CLKOUT2_BUF,
        C_CLKOUT3_BUF              => C_MMCM2_CLKOUT3_BUF,
        C_CLKOUT4_BUF              => C_MMCM2_CLKOUT4_BUF,
        C_CLKOUT5_BUF              => C_MMCM2_CLKOUT5_BUF,
        C_CLKOUT6_BUF              => C_MMCM2_CLKOUT6_BUF
        )
      port map (
        -- (1) module
        CLKFBOUT                   => MMCM2_CLK_OUT(7), -- or top CLKFBOUT
        -- CLKFBOUTB               => ,
        CLKOUT0                    => MMCM2_CLK_OUT(0),
        CLKOUT1                    => MMCM2_CLK_OUT(1),
        CLKOUT2                    => MMCM2_CLK_OUT(2),
        CLKOUT3                    => MMCM2_CLK_OUT(3),
        CLKOUT4                    => MMCM2_CLK_OUT(4),
        CLKOUT5                    => MMCM2_CLK_OUT(5),
        CLKOUT6                    => MMCM2_CLK_OUT(6),
        -- CLKOUT0B                => ,
        -- CLKOUT1B                => ,
        -- CLKOUT2B                => ,
        -- CLKOUT3B                => ,
        LOCKED                     => MMCM2_LOCKED,
        -- CLKFBSTOPPED            => ,
        -- CLKINSTOPPED            => ,
        PSDONE                     => MMCM2_PSDONE,
        CLKFBIN                    => MMCM2_CLK_FBIN, -- or top CLKFBIN
        CLKIN1                     => MMCM2_CLK_IN,
        -- PWRDWN                  => ,
        PSCLK                      => MMCM2_PSCLK,
        PSEN                       => MMCM2_PSEN,
        PSINCDEC                   => MMCM2_PSINCDEC,
        RST                        => MMCM2_RST,
        -- (2) wrapper
        CLKOUT0B                   => MMCM2_CLK_OUT(8),
        CLKOUT1B                   => MMCM2_CLK_OUT(9),
        CLKOUT2B                   => MMCM2_CLK_OUT(10),
        CLKOUT3B                   => MMCM2_CLK_OUT(11),
        CLKOUT4B                   => MMCM2_CLK_OUT(12),
        CLKOUT5B                   => MMCM2_CLK_OUT(13),
        CLKOUT6B                   => MMCM2_CLK_OUT(14)
        );
  end generate Using_MMCM2;

  --------
  -- Note: MMCM3 used only for dynamic phase shift
  --------
  Using_MMCM3 : if ( equalString(C_MMCM3_CLKIN1_MODULE, "NONE") = false ) generate
    MMCM3_INST : mmcm_module_wrapper
      generic map (
        -- (1) module
        C_BANDWIDTH                => C_MMCM3_BANDWIDTH,
        C_CLKFBOUT_MULT_F          => C_MMCM3_CLKFBOUT_MULT_F,
        C_CLKFBOUT_PHASE           => C_MMCM3_CLKFBOUT_PHASE,
        C_CLKFBOUT_USE_FINE_PS     => C_MMCM3_CLKFBOUT_USE_FINE_PS,
        C_CLKIN1_PERIOD            => C_MMCM3_CLKIN1_PERIOD,
        C_CLKOUT0_DIVIDE_F         => C_MMCM3_CLKOUT0_DIVIDE_F,
        C_CLKOUT0_DUTY_CYCLE       => C_MMCM3_CLKOUT0_DUTY_CYCLE,
        C_CLKOUT0_PHASE            => C_MMCM3_CLKOUT0_PHASE,
        C_CLKOUT1_DIVIDE           => C_MMCM3_CLKOUT1_DIVIDE,
        C_CLKOUT1_DUTY_CYCLE       => C_MMCM3_CLKOUT1_DUTY_CYCLE,
        C_CLKOUT1_PHASE            => C_MMCM3_CLKOUT1_PHASE,
        C_CLKOUT2_DIVIDE           => C_MMCM3_CLKOUT2_DIVIDE,
        C_CLKOUT2_DUTY_CYCLE       => C_MMCM3_CLKOUT2_DUTY_CYCLE,
        C_CLKOUT2_PHASE            => C_MMCM3_CLKOUT2_PHASE,
        C_CLKOUT3_DIVIDE           => C_MMCM3_CLKOUT3_DIVIDE,
        C_CLKOUT3_DUTY_CYCLE       => C_MMCM3_CLKOUT3_DUTY_CYCLE,
        C_CLKOUT3_PHASE            => C_MMCM3_CLKOUT3_PHASE,
        C_CLKOUT4_DIVIDE           => C_MMCM3_CLKOUT4_DIVIDE,
        C_CLKOUT4_DUTY_CYCLE       => C_MMCM3_CLKOUT4_DUTY_CYCLE,
        C_CLKOUT4_PHASE            => C_MMCM3_CLKOUT4_PHASE,
        C_CLKOUT4_CASCADE          => C_MMCM3_CLKOUT4_CASCADE,
        C_CLKOUT5_DIVIDE           => C_MMCM3_CLKOUT5_DIVIDE,
        C_CLKOUT5_DUTY_CYCLE       => C_MMCM3_CLKOUT5_DUTY_CYCLE,
        C_CLKOUT5_PHASE            => C_MMCM3_CLKOUT5_PHASE,
        C_CLKOUT6_DIVIDE           => C_MMCM3_CLKOUT6_DIVIDE,
        C_CLKOUT6_DUTY_CYCLE       => C_MMCM3_CLKOUT6_DUTY_CYCLE,
        C_CLKOUT6_PHASE            => C_MMCM3_CLKOUT6_PHASE,
        C_CLKOUT0_USE_FINE_PS      => C_MMCM3_CLKOUT0_USE_FINE_PS,
        C_CLKOUT1_USE_FINE_PS      => C_MMCM3_CLKOUT1_USE_FINE_PS,
        C_CLKOUT2_USE_FINE_PS      => C_MMCM3_CLKOUT2_USE_FINE_PS,
        C_CLKOUT3_USE_FINE_PS      => C_MMCM3_CLKOUT3_USE_FINE_PS,
        C_CLKOUT4_USE_FINE_PS      => C_MMCM3_CLKOUT4_USE_FINE_PS,
        C_CLKOUT5_USE_FINE_PS      => C_MMCM3_CLKOUT5_USE_FINE_PS,
        C_CLKOUT6_USE_FINE_PS      => C_MMCM3_CLKOUT6_USE_FINE_PS,
        C_COMPENSATION             => C_MMCM3_COMPENSATION,
        C_DIVCLK_DIVIDE            => C_MMCM3_DIVCLK_DIVIDE,
        C_REF_JITTER1              => C_MMCM3_REF_JITTER1,
        C_CLKIN1_BUF               => C_MMCM3_CLKIN1_BUF,
        C_CLKFBOUT_BUF             => C_MMCM3_CLKFBOUT_BUF,
        -- C_CLKOUT0_BUF           => ,
        -- C_CLKOUT1_BUF           => ,
        -- C_CLKOUT2_BUF           => ,
        -- C_CLKOUT3_BUF           => ,
        -- C_CLKOUT4_BUF           => ,
        -- C_CLKOUT5_BUF           => ,
        -- C_CLKOUT6_BUF           => ,
        C_CLOCK_HOLD               => C_MMCM3_CLOCK_HOLD,
        C_STARTUP_WAIT             => C_MMCM3_STARTUP_WAIT,
        C_EXT_RESET_HIGH           => C_MMCM3_EXT_RESET_HIGH,
        C_FAMILY                   => C_MMCM3_FAMILY,
        -- (2) wrapper
        C_CLKOUT0_BUF              => C_MMCM3_CLKOUT0_BUF,
        C_CLKOUT1_BUF              => C_MMCM3_CLKOUT1_BUF,
        C_CLKOUT2_BUF              => C_MMCM3_CLKOUT2_BUF,
        C_CLKOUT3_BUF              => C_MMCM3_CLKOUT3_BUF,
        C_CLKOUT4_BUF              => C_MMCM3_CLKOUT4_BUF,
        C_CLKOUT5_BUF              => C_MMCM3_CLKOUT5_BUF,
        C_CLKOUT6_BUF              => C_MMCM3_CLKOUT6_BUF
        )
      port map (
        -- (1) module
        CLKFBOUT                   => MMCM3_CLK_OUT(7),
        -- CLKFBOUTB               => ,
        CLKOUT0                    => MMCM3_CLK_OUT(0),
        CLKOUT1                    => MMCM3_CLK_OUT(1),
        CLKOUT2                    => MMCM3_CLK_OUT(2),
        CLKOUT3                    => MMCM3_CLK_OUT(3),
        CLKOUT4                    => MMCM3_CLK_OUT(4),
        CLKOUT5                    => MMCM3_CLK_OUT(5),
        CLKOUT6                    => MMCM3_CLK_OUT(6),
        -- CLKOUT0B                => ,
        -- CLKOUT1B                => ,
        -- CLKOUT2B                => ,
        -- CLKOUT3B                => ,
        LOCKED                     => MMCM3_LOCKED,
        -- CLKFBSTOPPED            => ,
        -- CLKINSTOPPED            => ,
        PSDONE                     => MMCM3_PSDONE,   -- phase, to clkgen top
        CLKFBIN                    => MMCM3_CLK_FBIN,
        CLKIN1                     => MMCM3_CLK_IN,
        -- PWRDWN                  => ,
        PSCLK                      => MMCM3_PSCLK,    -- phase, to clkgen top
        PSEN                       => MMCM3_PSEN,     -- phase, to clkgen top
        PSINCDEC                   => MMCM3_PSINCDEC, -- phase, to clkgen top
        RST                        => MMCM3_RST,
        -- (2) wrapper
        CLKOUT0B                   => MMCM3_CLK_OUT(8),
        CLKOUT1B                   => MMCM3_CLK_OUT(9),
        CLKOUT2B                   => MMCM3_CLK_OUT(10),
        CLKOUT3B                   => MMCM3_CLK_OUT(11),
        CLKOUT4B                   => MMCM3_CLK_OUT(12),
        CLKOUT5B                   => MMCM3_CLK_OUT(13),
        CLKOUT6B                   => MMCM3_CLK_OUT(14)
        );
  end generate Using_MMCM3;

  ----------------------------------------------------------------------------
  -- CLKGEN CLKIN signal connection
  ----------------------------------------------------------------------------

  CLKGEN_CLK_IN(0) <= CLKIN;
  CLKGEN_CLK_IN(1) <= CLKFBIN;

  -- C_EXT_RESET_HIGH

  --USE_EXT_RESET_HIGH : if (C_EXT_RESET_HIGH = 1) generate
  --  CLKGEN_RST_IN <= RST;
  --end generate USE_EXT_RESET_HIGH;

  --USE_EXT_RESET_LOW : if (C_EXT_RESET_HIGH /= 1) generate
  --  CLKGEN_RST_IN <= NOT RST;
  --end generate USE_EXT_RESET_LOW;

  ----------------------------------------------------------------------------
  -- CLKGEN CLKOUT connection
  ----------------------------------------------------------------------------

  CLKGEN_CLKOUT0_INST : clock_selection
    generic map (
      C_MODULE                     => C_CLKOUT0_MODULE,
      C_PORT                       => C_CLKOUT0_PORT
    )
    port map (
      CLKGEN                       => CLKGEN_CLK_IN,
      PLL0                         => PLL0_CLK_OUT,
      PLL1                         => PLL1_CLK_OUT,
      DCM0                         => DCM0_CLK_OUT,
      DCM1                         => DCM1_CLK_OUT,
      DCM2                         => DCM2_CLK_OUT,
      DCM3                         => DCM3_CLK_OUT,
      MMCM0                        => MMCM0_CLK_OUT,
      MMCM1                        => MMCM1_CLK_OUT,
      MMCM2                        => MMCM2_CLK_OUT,
      MMCM3                        => MMCM3_CLK_OUT,
      CLKOUT                       => CLKOUT0
    );

  CLKGEN_CLKOUT1_INST : clock_selection
    generic map (
      C_MODULE                     => C_CLKOUT1_MODULE,
      C_PORT                       => C_CLKOUT1_PORT
    )
    port map (
      CLKGEN                       => CLKGEN_CLK_IN,
      PLL0                         => PLL0_CLK_OUT,
      PLL1                         => PLL1_CLK_OUT,
      DCM0                         => DCM0_CLK_OUT,
      DCM1                         => DCM1_CLK_OUT,
      DCM2                         => DCM2_CLK_OUT,
      DCM3                         => DCM3_CLK_OUT,
      MMCM0                        => MMCM0_CLK_OUT,
      MMCM1                        => MMCM1_CLK_OUT,
      MMCM2                        => MMCM2_CLK_OUT,
      MMCM3                        => MMCM3_CLK_OUT,
      CLKOUT                       => CLKOUT1
    );

  CLKGEN_CLKOUT2_INST : clock_selection
    generic map (
      C_MODULE                     => C_CLKOUT2_MODULE,
      C_PORT                       => C_CLKOUT2_PORT
    )
    port map (
      CLKGEN                       => CLKGEN_CLK_IN,
      PLL0                         => PLL0_CLK_OUT,
      PLL1                         => PLL1_CLK_OUT,
      DCM0                         => DCM0_CLK_OUT,
      DCM1                         => DCM1_CLK_OUT,
      DCM2                         => DCM2_CLK_OUT,
      DCM3                         => DCM3_CLK_OUT,
      MMCM0                        => MMCM0_CLK_OUT,
      MMCM1                        => MMCM1_CLK_OUT,
      MMCM2                        => MMCM2_CLK_OUT,
      MMCM3                        => MMCM3_CLK_OUT,
      CLKOUT                       => CLKOUT2
    );

  CLKGEN_CLKOUT3_INST : clock_selection
    generic map (
      C_MODULE                     => C_CLKOUT3_MODULE,
      C_PORT                       => C_CLKOUT3_PORT
    )
    port map (
      CLKGEN                       => CLKGEN_CLK_IN,
      PLL0                         => PLL0_CLK_OUT,
      PLL1                         => PLL1_CLK_OUT,
      DCM0                         => DCM0_CLK_OUT,
      DCM1                         => DCM1_CLK_OUT,
      DCM2                         => DCM2_CLK_OUT,
      DCM3                         => DCM3_CLK_OUT,
      MMCM0                        => MMCM0_CLK_OUT,
      MMCM1                        => MMCM1_CLK_OUT,
      MMCM2                        => MMCM2_CLK_OUT,
      MMCM3                        => MMCM3_CLK_OUT,
      CLKOUT                       => CLKOUT3
    );

  CLKGEN_CLKOUT4_INST : clock_selection
    generic map (
      C_MODULE                     => C_CLKOUT4_MODULE,
      C_PORT                       => C_CLKOUT4_PORT
    )
    port map (
      CLKGEN                       => CLKGEN_CLK_IN,
      PLL0                         => PLL0_CLK_OUT,
      PLL1                         => PLL1_CLK_OUT,
      DCM0                         => DCM0_CLK_OUT,
      DCM1                         => DCM1_CLK_OUT,
      DCM2                         => DCM2_CLK_OUT,
      DCM3                         => DCM3_CLK_OUT,
      MMCM0                        => MMCM0_CLK_OUT,
      MMCM1                        => MMCM1_CLK_OUT,
      MMCM2                        => MMCM2_CLK_OUT,
      MMCM3                        => MMCM3_CLK_OUT,
      CLKOUT                       => CLKOUT4
    );

  CLKGEN_CLKOUT5_INST : clock_selection
    generic map (
      C_MODULE                     => C_CLKOUT5_MODULE,
      C_PORT                       => C_CLKOUT5_PORT
    )
    port map (
      CLKGEN                       => CLKGEN_CLK_IN,
      PLL0                         => PLL0_CLK_OUT,
      PLL1                         => PLL1_CLK_OUT,
      DCM0                         => DCM0_CLK_OUT,
      DCM1                         => DCM1_CLK_OUT,
      DCM2                         => DCM2_CLK_OUT,
      DCM3                         => DCM3_CLK_OUT,
      MMCM0                        => MMCM0_CLK_OUT,
      MMCM1                        => MMCM1_CLK_OUT,
      MMCM2                        => MMCM2_CLK_OUT,
      MMCM3                        => MMCM3_CLK_OUT,
      CLKOUT                       => CLKOUT5
    );

  CLKGEN_CLKOUT6_INST : clock_selection
    generic map (
      C_MODULE                     => C_CLKOUT6_MODULE,
      C_PORT                       => C_CLKOUT6_PORT
    )
    port map (
      CLKGEN                       => CLKGEN_CLK_IN,
      PLL0                         => PLL0_CLK_OUT,
      PLL1                         => PLL1_CLK_OUT,
      DCM0                         => DCM0_CLK_OUT,
      DCM1                         => DCM1_CLK_OUT,
      DCM2                         => DCM2_CLK_OUT,
      DCM3                         => DCM3_CLK_OUT,
      MMCM0                        => MMCM0_CLK_OUT,
      MMCM1                        => MMCM1_CLK_OUT,
      MMCM2                        => MMCM2_CLK_OUT,
      MMCM3                        => MMCM3_CLK_OUT,
      CLKOUT                       => CLKOUT6
    );

  CLKGEN_CLKOUT7_INST : clock_selection
    generic map (
      C_MODULE                     => C_CLKOUT7_MODULE,
      C_PORT                       => C_CLKOUT7_PORT
    )
    port map (
      CLKGEN                       => CLKGEN_CLK_IN,
      PLL0                         => PLL0_CLK_OUT,
      PLL1                         => PLL1_CLK_OUT,
      DCM0                         => DCM0_CLK_OUT,
      DCM1                         => DCM1_CLK_OUT,
      DCM2                         => DCM2_CLK_OUT,
      DCM3                         => DCM3_CLK_OUT,
      MMCM0                        => MMCM0_CLK_OUT,
      MMCM1                        => MMCM1_CLK_OUT,
      MMCM2                        => MMCM2_CLK_OUT,
      MMCM3                        => MMCM3_CLK_OUT,
      CLKOUT                       => CLKOUT7
    );

  CLKGEN_CLKOUT8_INST : clock_selection
    generic map (
      C_MODULE                     => C_CLKOUT8_MODULE,
      C_PORT                       => C_CLKOUT8_PORT
    )
    port map (
      CLKGEN                       => CLKGEN_CLK_IN,
      PLL0                         => PLL0_CLK_OUT,
      PLL1                         => PLL1_CLK_OUT,
      DCM0                         => DCM0_CLK_OUT,
      DCM1                         => DCM1_CLK_OUT,
      DCM2                         => DCM2_CLK_OUT,
      DCM3                         => DCM3_CLK_OUT,
      MMCM0                        => MMCM0_CLK_OUT,
      MMCM1                        => MMCM1_CLK_OUT,
      MMCM2                        => MMCM2_CLK_OUT,
      MMCM3                        => MMCM3_CLK_OUT,
      CLKOUT                       => CLKOUT8
    );

  CLKGEN_CLKOUT9_INST : clock_selection
    generic map (
      C_MODULE                     => C_CLKOUT9_MODULE,
      C_PORT                       => C_CLKOUT9_PORT
    )
    port map (
      CLKGEN                       => CLKGEN_CLK_IN,
      PLL0                         => PLL0_CLK_OUT,
      PLL1                         => PLL1_CLK_OUT,
      DCM0                         => DCM0_CLK_OUT,
      DCM1                         => DCM1_CLK_OUT,
      DCM2                         => DCM2_CLK_OUT,
      DCM3                         => DCM3_CLK_OUT,
      MMCM0                        => MMCM0_CLK_OUT,
      MMCM1                        => MMCM1_CLK_OUT,
      MMCM2                        => MMCM2_CLK_OUT,
      MMCM3                        => MMCM3_CLK_OUT,
      CLKOUT                       => CLKOUT9
    );

  CLKGEN_CLKOUT10_INST : clock_selection
    generic map (
      C_MODULE                     => C_CLKOUT10_MODULE,
      C_PORT                       => C_CLKOUT10_PORT
    )
    port map (
      CLKGEN                       => CLKGEN_CLK_IN,
      PLL0                         => PLL0_CLK_OUT,
      PLL1                         => PLL1_CLK_OUT,
      DCM0                         => DCM0_CLK_OUT,
      DCM1                         => DCM1_CLK_OUT,
      DCM2                         => DCM2_CLK_OUT,
      DCM3                         => DCM3_CLK_OUT,
      MMCM0                        => MMCM0_CLK_OUT,
      MMCM1                        => MMCM1_CLK_OUT,
      MMCM2                        => MMCM2_CLK_OUT,
      MMCM3                        => MMCM3_CLK_OUT,
      CLKOUT                       => CLKOUT10
    );

  CLKGEN_CLKOUT11_INST : clock_selection
    generic map (
      C_MODULE                     => C_CLKOUT11_MODULE,
      C_PORT                       => C_CLKOUT11_PORT
    )
    port map (
      CLKGEN                       => CLKGEN_CLK_IN,
      PLL0                         => PLL0_CLK_OUT,
      PLL1                         => PLL1_CLK_OUT,
      DCM0                         => DCM0_CLK_OUT,
      DCM1                         => DCM1_CLK_OUT,
      DCM2                         => DCM2_CLK_OUT,
      DCM3                         => DCM3_CLK_OUT,
      MMCM0                        => MMCM0_CLK_OUT,
      MMCM1                        => MMCM1_CLK_OUT,
      MMCM2                        => MMCM2_CLK_OUT,
      MMCM3                        => MMCM3_CLK_OUT,
      CLKOUT                       => CLKOUT11
    );

  CLKGEN_CLKOUT12_INST : clock_selection
    generic map (
      C_MODULE                     => C_CLKOUT12_MODULE,
      C_PORT                       => C_CLKOUT12_PORT
    )
    port map (
      CLKGEN                       => CLKGEN_CLK_IN,
      PLL0                         => PLL0_CLK_OUT,
      PLL1                         => PLL1_CLK_OUT,
      DCM0                         => DCM0_CLK_OUT,
      DCM1                         => DCM1_CLK_OUT,
      DCM2                         => DCM2_CLK_OUT,
      DCM3                         => DCM3_CLK_OUT,
      MMCM0                        => MMCM0_CLK_OUT,
      MMCM1                        => MMCM1_CLK_OUT,
      MMCM2                        => MMCM2_CLK_OUT,
      MMCM3                        => MMCM3_CLK_OUT,
      CLKOUT                       => CLKOUT12
    );

  CLKGEN_CLKOUT13_INST : clock_selection
    generic map (
      C_MODULE                     => C_CLKOUT13_MODULE,
      C_PORT                       => C_CLKOUT13_PORT
    )
    port map (
      CLKGEN                       => CLKGEN_CLK_IN,
      PLL0                         => PLL0_CLK_OUT,
      PLL1                         => PLL1_CLK_OUT,
      DCM0                         => DCM0_CLK_OUT,
      DCM1                         => DCM1_CLK_OUT,
      DCM2                         => DCM2_CLK_OUT,
      DCM3                         => DCM3_CLK_OUT,
      MMCM0                        => MMCM0_CLK_OUT,
      MMCM1                        => MMCM1_CLK_OUT,
      MMCM2                        => MMCM2_CLK_OUT,
      MMCM3                        => MMCM3_CLK_OUT,
      CLKOUT                       => CLKOUT13
    );

  CLKGEN_CLKOUT14_INST : clock_selection
    generic map (
      C_MODULE                     => C_CLKOUT14_MODULE,
      C_PORT                       => C_CLKOUT14_PORT
    )
    port map (
      CLKGEN                       => CLKGEN_CLK_IN,
      PLL0                         => PLL0_CLK_OUT,
      PLL1                         => PLL1_CLK_OUT,
      DCM0                         => DCM0_CLK_OUT,
      DCM1                         => DCM1_CLK_OUT,
      DCM2                         => DCM2_CLK_OUT,
      DCM3                         => DCM3_CLK_OUT,
      MMCM0                        => MMCM0_CLK_OUT,
      MMCM1                        => MMCM1_CLK_OUT,
      MMCM2                        => MMCM2_CLK_OUT,
      MMCM3                        => MMCM3_CLK_OUT,
      CLKOUT                       => CLKOUT14
    );

  CLKGEN_CLKOUT15_INST : clock_selection
    generic map (
      C_MODULE                     => C_CLKOUT15_MODULE,
      C_PORT                       => C_CLKOUT15_PORT
    )
    port map (
      CLKGEN                       => CLKGEN_CLK_IN,
      PLL0                         => PLL0_CLK_OUT,
      PLL1                         => PLL1_CLK_OUT,
      DCM0                         => DCM0_CLK_OUT,
      DCM1                         => DCM1_CLK_OUT,
      DCM2                         => DCM2_CLK_OUT,
      DCM3                         => DCM3_CLK_OUT,
      MMCM0                        => MMCM0_CLK_OUT,
      MMCM1                        => MMCM1_CLK_OUT,
      MMCM2                        => MMCM2_CLK_OUT,
      MMCM3                        => MMCM3_CLK_OUT,
      CLKOUT                       => CLKOUT15
    );

  CLKGEN_CLKFBOUT_INST : clock_selection
    generic map (
      C_MODULE                     => C_CLKFBOUT_MODULE,
      C_PORT                       => C_CLKFBOUT_PORT
    )
    port map (
      CLKGEN                       => CLKGEN_CLK_IN,
      PLL0                         => PLL0_CLK_OUT,
      PLL1                         => PLL1_CLK_OUT,
      DCM0                         => DCM0_CLK_OUT,
      DCM1                         => DCM1_CLK_OUT,
      DCM2                         => DCM2_CLK_OUT,
      DCM3                         => DCM3_CLK_OUT,
      MMCM0                        => MMCM0_CLK_OUT,
      MMCM1                        => MMCM1_CLK_OUT,
      MMCM2                        => MMCM2_CLK_OUT,
      MMCM3                        => MMCM3_CLK_OUT,
      CLKOUT                       => CLKFBOUT
    );  

  ----------------------------------------------------------------------------
  -- PLL CLKIN connection
  ----------------------------------------------------------------------------

  -- PLL0

  PLL0_CLKIN_INST : clock_selection
    generic map (
      C_MODULE                     => C_PLL0_CLKIN1_MODULE,
      C_PORT                       => C_PLL0_CLKIN1_PORT
    )
    port map (
      CLKGEN                       => CLKGEN_CLK_IN,
      PLL0                         => PLL0_CLK_OUT,
      PLL1                         => PLL1_CLK_OUT,
      DCM0                         => DCM0_CLK_OUT,
      DCM1                         => DCM1_CLK_OUT,
      DCM2                         => DCM2_CLK_OUT,
      DCM3                         => DCM3_CLK_OUT,
      MMCM0                        => MMCM0_CLK_OUT,
      MMCM1                        => MMCM1_CLK_OUT,
      MMCM2                        => MMCM2_CLK_OUT,
      MMCM3                        => MMCM3_CLK_OUT,
      CLKOUT                       => PLL0_CLK_IN
    );

  PLL0_CLKFBIN_INST : clock_selection
    generic map (
      C_MODULE                     => C_PLL0_CLKFBIN_MODULE,
      C_PORT                       => C_PLL0_CLKFBIN_PORT
    )
    port map (
      CLKGEN                       => CLKGEN_CLK_IN,
      PLL0                         => PLL0_CLK_OUT,
      PLL1                         => PLL1_CLK_OUT,
      DCM0                         => DCM0_CLK_OUT,
      DCM1                         => DCM1_CLK_OUT,
      DCM2                         => DCM2_CLK_OUT,
      DCM3                         => DCM3_CLK_OUT,
      MMCM0                        => MMCM0_CLK_OUT,
      MMCM1                        => MMCM1_CLK_OUT,
      MMCM2                        => MMCM2_CLK_OUT,
      MMCM3                        => MMCM3_CLK_OUT,
      CLKOUT                       => PLL0_CLK_FBIN
    );  

  -- PLL1

  PLL1_CLKIN_INST : clock_selection
    generic map (
      C_MODULE                     => C_PLL1_CLKIN1_MODULE,
      C_PORT                       => C_PLL1_CLKIN1_PORT
    )
    port map (
      CLKGEN                       => CLKGEN_CLK_IN,
      PLL0                         => PLL0_CLK_OUT,
      PLL1                         => PLL1_CLK_OUT,
      DCM0                         => DCM0_CLK_OUT,
      DCM1                         => DCM1_CLK_OUT,
      DCM2                         => DCM2_CLK_OUT,
      DCM3                         => DCM3_CLK_OUT,
      MMCM0                        => MMCM0_CLK_OUT,
      MMCM1                        => MMCM1_CLK_OUT,
      MMCM2                        => MMCM2_CLK_OUT,
      MMCM3                        => MMCM3_CLK_OUT,
      CLKOUT                       => PLL1_CLK_IN
    );

  PLL1_CLKFBIN_INST : clock_selection
    generic map (
      C_MODULE                     => C_PLL1_CLKFBIN_MODULE,
      C_PORT                       => C_PLL1_CLKFBIN_PORT
    )
    port map (
      CLKGEN                       => CLKGEN_CLK_IN,
      PLL0                         => PLL0_CLK_OUT,
      PLL1                         => PLL1_CLK_OUT,
      DCM0                         => DCM0_CLK_OUT,
      DCM1                         => DCM1_CLK_OUT,
      DCM2                         => DCM2_CLK_OUT,
      DCM3                         => DCM3_CLK_OUT,
      MMCM0                        => MMCM0_CLK_OUT,
      MMCM1                        => MMCM1_CLK_OUT,
      MMCM2                        => MMCM2_CLK_OUT,
      MMCM3                        => MMCM3_CLK_OUT,
      CLKOUT                       => PLL1_CLK_FBIN
    );  

  ----------------------------------------------------------------------------
  -- DCM CLKIN connection
  ----------------------------------------------------------------------------

  -- DCM0

  DCM0_CLKIN_INST : clock_selection
    generic map (
      C_MODULE                     => C_DCM0_CLKIN_MODULE,
      C_PORT                       => C_DCM0_CLKIN_PORT
    )
    port map (
      CLKGEN                       => CLKGEN_CLK_IN,
      PLL0                         => PLL0_CLK_OUT,
      PLL1                         => PLL1_CLK_OUT,
      DCM0                         => DCM0_CLK_OUT,
      DCM1                         => DCM1_CLK_OUT,
      DCM2                         => DCM2_CLK_OUT,
      DCM3                         => DCM3_CLK_OUT,
      MMCM0                        => MMCM0_CLK_OUT,
      MMCM1                        => MMCM1_CLK_OUT,
      MMCM2                        => MMCM2_CLK_OUT,
      MMCM3                        => MMCM3_CLK_OUT,
      CLKOUT                       => DCM0_CLK_IN
    );  

  DCM0_CLKFB_INST : clock_selection
    generic map (
      C_MODULE                     => C_DCM0_CLKFB_MODULE,
      C_PORT                       => C_DCM0_CLKFB_PORT
    )
    port map (
      CLKGEN                       => CLKGEN_CLK_IN,
      PLL0                         => PLL0_CLK_OUT,
      PLL1                         => PLL1_CLK_OUT,
      DCM0                         => DCM0_CLK_OUT,
      DCM1                         => DCM1_CLK_OUT,
      DCM2                         => DCM2_CLK_OUT,
      DCM3                         => DCM3_CLK_OUT,
      MMCM0                        => MMCM0_CLK_OUT,
      MMCM1                        => MMCM1_CLK_OUT,
      MMCM2                        => MMCM2_CLK_OUT,
      MMCM3                        => MMCM3_CLK_OUT,
      CLKOUT                       => DCM0_CLK_FBIN
    );  

  -- DCM1

  DCM1_CLKIN_INST : clock_selection
    generic map (
      C_MODULE                     => C_DCM1_CLKIN_MODULE,
      C_PORT                       => C_DCM1_CLKIN_PORT
    )
    port map (
      CLKGEN                       => CLKGEN_CLK_IN,
      PLL0                         => PLL0_CLK_OUT,
      PLL1                         => PLL1_CLK_OUT,
      DCM0                         => DCM0_CLK_OUT,
      DCM1                         => DCM1_CLK_OUT,
      DCM2                         => DCM2_CLK_OUT,
      DCM3                         => DCM3_CLK_OUT,
      MMCM0                        => MMCM0_CLK_OUT,
      MMCM1                        => MMCM1_CLK_OUT,
      MMCM2                        => MMCM2_CLK_OUT,
      MMCM3                        => MMCM3_CLK_OUT,
      CLKOUT                       => DCM1_CLK_IN
    );  

  DCM1_CLKFB_INST : clock_selection
    generic map (
      C_MODULE                     => C_DCM1_CLKFB_MODULE,
      C_PORT                       => C_DCM1_CLKFB_PORT
    )
    port map (
      CLKGEN                       => CLKGEN_CLK_IN,
      PLL0                         => PLL0_CLK_OUT,
      PLL1                         => PLL1_CLK_OUT,
      DCM0                         => DCM0_CLK_OUT,
      DCM1                         => DCM1_CLK_OUT,
      DCM2                         => DCM2_CLK_OUT,
      DCM3                         => DCM3_CLK_OUT,
      MMCM0                        => MMCM0_CLK_OUT,
      MMCM1                        => MMCM1_CLK_OUT,
      MMCM2                        => MMCM2_CLK_OUT,
      MMCM3                        => MMCM3_CLK_OUT,
      CLKOUT                       => DCM1_CLK_FBIN
    );  

  -- DCM2

  DCM2_CLKIN_INST : clock_selection
    generic map (
      C_MODULE                     => C_DCM2_CLKIN_MODULE,
      C_PORT                       => C_DCM2_CLKIN_PORT
    )
    port map (
      CLKGEN                       => CLKGEN_CLK_IN,
      PLL0                         => PLL0_CLK_OUT,
      PLL1                         => PLL1_CLK_OUT,
      DCM0                         => DCM0_CLK_OUT,
      DCM1                         => DCM1_CLK_OUT,
      DCM2                         => DCM2_CLK_OUT,
      DCM3                         => DCM3_CLK_OUT,
      MMCM0                        => MMCM0_CLK_OUT,
      MMCM1                        => MMCM1_CLK_OUT,
      MMCM2                        => MMCM2_CLK_OUT,
      MMCM3                        => MMCM3_CLK_OUT,
      CLKOUT                       => DCM2_CLK_IN
    );  

  DCM2_CLKFB_INST : clock_selection
    generic map (
      C_MODULE                     => C_DCM2_CLKFB_MODULE,
      C_PORT                       => C_DCM2_CLKFB_PORT
    )
    port map (
      CLKGEN                       => CLKGEN_CLK_IN,
      PLL0                         => PLL0_CLK_OUT,
      PLL1                         => PLL1_CLK_OUT,
      DCM0                         => DCM0_CLK_OUT,
      DCM1                         => DCM1_CLK_OUT,
      DCM2                         => DCM2_CLK_OUT,
      DCM3                         => DCM3_CLK_OUT,
      MMCM0                        => MMCM0_CLK_OUT,
      MMCM1                        => MMCM1_CLK_OUT,
      MMCM2                        => MMCM2_CLK_OUT,
      MMCM3                        => MMCM3_CLK_OUT,
      CLKOUT                       => DCM2_CLK_FBIN
    );  

  -- DCM3

  DCM3_CLKIN_INST : clock_selection
    generic map (
      C_MODULE                     => C_DCM3_CLKIN_MODULE,
      C_PORT                       => C_DCM3_CLKIN_PORT
    )
    port map (
      CLKGEN                       => CLKGEN_CLK_IN,
      PLL0                         => PLL0_CLK_OUT,
      PLL1                         => PLL1_CLK_OUT,
      DCM0                         => DCM0_CLK_OUT,
      DCM1                         => DCM1_CLK_OUT,
      DCM2                         => DCM2_CLK_OUT,
      DCM3                         => DCM3_CLK_OUT,
      MMCM0                        => MMCM0_CLK_OUT,
      MMCM1                        => MMCM1_CLK_OUT,
      MMCM2                        => MMCM2_CLK_OUT,
      MMCM3                        => MMCM3_CLK_OUT,
      CLKOUT                       => DCM3_CLK_IN
    );  

  DCM3_CLKFB_INST : clock_selection
    generic map (
      C_MODULE                     => C_DCM3_CLKFB_MODULE,
      C_PORT                       => C_DCM3_CLKFB_PORT
    )
    port map (
      CLKGEN                       => CLKGEN_CLK_IN,
      PLL0                         => PLL0_CLK_OUT,
      PLL1                         => PLL1_CLK_OUT,
      DCM0                         => DCM0_CLK_OUT,
      DCM1                         => DCM1_CLK_OUT,
      DCM2                         => DCM2_CLK_OUT,
      DCM3                         => DCM3_CLK_OUT,
      MMCM0                        => MMCM0_CLK_OUT,
      MMCM1                        => MMCM1_CLK_OUT,
      MMCM2                        => MMCM2_CLK_OUT,
      MMCM3                        => MMCM3_CLK_OUT,
      CLKOUT                       => DCM3_CLK_FBIN
    );  

  ----------------------------------------------------------------------------
  -- MMCM CLKIN connection
  ----------------------------------------------------------------------------

  -- MMCM0

  MMCM0_CLKIN_INST : clock_selection
    generic map (
      C_MODULE                     => C_MMCM0_CLKIN1_MODULE,
      C_PORT                       => C_MMCM0_CLKIN1_PORT
    )
    port map (
      CLKGEN                       => CLKGEN_CLK_IN,
      PLL0                         => PLL0_CLK_OUT,
      PLL1                         => PLL1_CLK_OUT,
      DCM0                         => DCM0_CLK_OUT,
      DCM1                         => DCM1_CLK_OUT,
      DCM2                         => DCM2_CLK_OUT,
      DCM3                         => DCM3_CLK_OUT,
      MMCM0                        => MMCM0_CLK_OUT,
      MMCM1                        => MMCM1_CLK_OUT,
      MMCM2                        => MMCM2_CLK_OUT,
      MMCM3                        => MMCM3_CLK_OUT,
      CLKOUT                       => MMCM0_CLK_IN
    );

  MMCM0_CLKFBIN_INST : clock_selection
    generic map (
      C_MODULE                     => C_MMCM0_CLKFBIN_MODULE,
      C_PORT                       => C_MMCM0_CLKFBIN_PORT
    )
    port map (
      CLKGEN                       => CLKGEN_CLK_IN,
      PLL0                         => PLL0_CLK_OUT,
      PLL1                         => PLL1_CLK_OUT,
      DCM0                         => DCM0_CLK_OUT,
      DCM1                         => DCM1_CLK_OUT,
      DCM2                         => DCM2_CLK_OUT,
      DCM3                         => DCM3_CLK_OUT,
      MMCM0                        => MMCM0_CLK_OUT,
      MMCM1                        => MMCM1_CLK_OUT,
      MMCM2                        => MMCM2_CLK_OUT,
      MMCM3                        => MMCM3_CLK_OUT,
      CLKOUT                       => MMCM0_CLK_FBIN
    );  

  -- MMCM1

  MMCM1_CLKIN_INST : clock_selection
    generic map (
      C_MODULE                     => C_MMCM1_CLKIN1_MODULE,
      C_PORT                       => C_MMCM1_CLKIN1_PORT
    )
    port map (
      CLKGEN                       => CLKGEN_CLK_IN,
      PLL0                         => PLL0_CLK_OUT,
      PLL1                         => PLL1_CLK_OUT,
      DCM0                         => DCM0_CLK_OUT,
      DCM1                         => DCM1_CLK_OUT,
      DCM2                         => DCM2_CLK_OUT,
      DCM3                         => DCM3_CLK_OUT,
      MMCM0                        => MMCM0_CLK_OUT,
      MMCM1                        => MMCM1_CLK_OUT,
      MMCM2                        => MMCM2_CLK_OUT,
      MMCM3                        => MMCM3_CLK_OUT,
      CLKOUT                       => MMCM1_CLK_IN
    );

  MMCM1_CLKFBIN_INST : clock_selection
    generic map (
      C_MODULE                     => C_MMCM1_CLKFBIN_MODULE,
      C_PORT                       => C_MMCM1_CLKFBIN_PORT
    )
    port map (
      CLKGEN                       => CLKGEN_CLK_IN,
      PLL0                         => PLL0_CLK_OUT,
      PLL1                         => PLL1_CLK_OUT,
      DCM0                         => DCM0_CLK_OUT,
      DCM1                         => DCM1_CLK_OUT,
      DCM2                         => DCM2_CLK_OUT,
      DCM3                         => DCM3_CLK_OUT,
      MMCM0                        => MMCM0_CLK_OUT,
      MMCM1                        => MMCM1_CLK_OUT,
      MMCM2                        => MMCM2_CLK_OUT,
      MMCM3                        => MMCM3_CLK_OUT,
      CLKOUT                       => MMCM1_CLK_FBIN
    );  

  -- MMCM2

  MMCM2_CLKIN_INST : clock_selection
    generic map (
      C_MODULE                     => C_MMCM2_CLKIN1_MODULE,
      C_PORT                       => C_MMCM2_CLKIN1_PORT
    )
    port map (
      CLKGEN                       => CLKGEN_CLK_IN,
      PLL0                         => PLL0_CLK_OUT,
      PLL1                         => PLL1_CLK_OUT,
      DCM0                         => DCM0_CLK_OUT,
      DCM1                         => DCM1_CLK_OUT,
      DCM2                         => DCM2_CLK_OUT,
      DCM3                         => DCM3_CLK_OUT,
      MMCM0                        => MMCM0_CLK_OUT,
      MMCM1                        => MMCM1_CLK_OUT,
      MMCM2                        => MMCM2_CLK_OUT,
      MMCM3                        => MMCM3_CLK_OUT,
      CLKOUT                       => MMCM2_CLK_IN
    );

  MMCM2_CLKFBIN_INST : clock_selection
    generic map (
      C_MODULE                     => C_MMCM2_CLKFBIN_MODULE,
      C_PORT                       => C_MMCM2_CLKFBIN_PORT
    )
    port map (
      CLKGEN                       => CLKGEN_CLK_IN,
      PLL0                         => PLL0_CLK_OUT,
      PLL1                         => PLL1_CLK_OUT,
      DCM0                         => DCM0_CLK_OUT,
      DCM1                         => DCM1_CLK_OUT,
      DCM2                         => DCM2_CLK_OUT,
      DCM3                         => DCM3_CLK_OUT,
      MMCM0                        => MMCM0_CLK_OUT,
      MMCM1                        => MMCM1_CLK_OUT,
      MMCM2                        => MMCM2_CLK_OUT,
      MMCM3                        => MMCM3_CLK_OUT,
      CLKOUT                       => MMCM2_CLK_FBIN
    );  

  -- MMCM3

  MMCM3_CLKIN_INST : clock_selection
    generic map (
      C_MODULE                     => C_MMCM3_CLKIN1_MODULE,
      C_PORT                       => C_MMCM3_CLKIN1_PORT
    )
    port map (
      CLKGEN                       => CLKGEN_CLK_IN,
      PLL0                         => PLL0_CLK_OUT,
      PLL1                         => PLL1_CLK_OUT,
      DCM0                         => DCM0_CLK_OUT,
      DCM1                         => DCM1_CLK_OUT,
      DCM2                         => DCM2_CLK_OUT,
      DCM3                         => DCM3_CLK_OUT,
      MMCM0                        => MMCM0_CLK_OUT,
      MMCM1                        => MMCM1_CLK_OUT,
      MMCM2                        => MMCM2_CLK_OUT,
      MMCM3                        => MMCM3_CLK_OUT,
      CLKOUT                       => MMCM3_CLK_IN
    );

  MMCM3_CLKFBIN_INST : clock_selection
    generic map (
      C_MODULE                     => C_MMCM3_CLKFBIN_MODULE,
      C_PORT                       => C_MMCM3_CLKFBIN_PORT
    )
    port map (
      CLKGEN                       => CLKGEN_CLK_IN,
      PLL0                         => PLL0_CLK_OUT,
      PLL1                         => PLL1_CLK_OUT,
      DCM0                         => DCM0_CLK_OUT,
      DCM1                         => DCM1_CLK_OUT,
      DCM2                         => DCM2_CLK_OUT,
      DCM3                         => DCM3_CLK_OUT,
      MMCM0                        => MMCM0_CLK_OUT,
      MMCM1                        => MMCM1_CLK_OUT,
      MMCM2                        => MMCM2_CLK_OUT,
      MMCM3                        => MMCM3_CLK_OUT,
      CLKOUT                       => MMCM3_CLK_FBIN
    );  

  ----------------------------------------------------------------------------
  -- Reset connection
  ----------------------------------------------------------------------------

  -- PLL

  PLL0_RST_INST : reset_selection
    generic map (
      C_MODULE                     => C_PLL0_RST_MODULE
    )
    port map (
      CLKGEN                       => RST,
      PLL0                         => PLL0_LOCKED,
      PLL1                         => PLL1_LOCKED,
      DCM0                         => DCM0_LOCKED,
      DCM1                         => DCM1_LOCKED,
      DCM2                         => DCM2_LOCKED,
      DCM3                         => DCM3_LOCKED,
      MMCM0                        => MMCM0_LOCKED,
      MMCM1                        => MMCM1_LOCKED,
      MMCM2                        => MMCM2_LOCKED,
      MMCM3                        => MMCM3_LOCKED,
      RST                          => PLL0_RST
    ); 

  PLL1_RST_INST : reset_selection
    generic map (
      C_MODULE                     => C_PLL1_RST_MODULE
    )
    port map (
      CLKGEN                       => RST,
      PLL0                         => PLL0_LOCKED,
      PLL1                         => PLL1_LOCKED,
      DCM0                         => DCM0_LOCKED,
      DCM1                         => DCM1_LOCKED,
      DCM2                         => DCM2_LOCKED,
      DCM3                         => DCM3_LOCKED,
      MMCM0                        => MMCM0_LOCKED,
      MMCM1                        => MMCM1_LOCKED,
      MMCM2                        => MMCM2_LOCKED,
      MMCM3                        => MMCM3_LOCKED,
      RST                          => PLL1_RST
    ); 

  -- DCM

  DCM0_RST_INST : reset_selection
    generic map (
      C_MODULE                     => C_DCM0_RST_MODULE
    )
    port map (
      CLKGEN                       => RST,
      PLL0                         => PLL0_LOCKED,
      PLL1                         => PLL1_LOCKED,
      DCM0                         => DCM0_LOCKED,
      DCM1                         => DCM1_LOCKED,
      DCM2                         => DCM2_LOCKED,
      DCM3                         => DCM3_LOCKED,
      MMCM0                        => MMCM0_LOCKED,
      MMCM1                        => MMCM1_LOCKED,
      MMCM2                        => MMCM2_LOCKED,
      MMCM3                        => MMCM3_LOCKED,
      RST                          => DCM0_RST
    ); 

  DCM1_RST_INST : reset_selection
    generic map (
      C_MODULE                     => C_DCM1_RST_MODULE
    )
    port map (
      CLKGEN                       => RST,
      PLL0                         => PLL0_LOCKED,
      PLL1                         => PLL1_LOCKED,
      DCM0                         => DCM0_LOCKED,
      DCM1                         => DCM1_LOCKED,
      DCM2                         => DCM2_LOCKED,
      DCM3                         => DCM3_LOCKED,
      MMCM0                        => MMCM0_LOCKED,
      MMCM1                        => MMCM1_LOCKED,
      MMCM2                        => MMCM2_LOCKED,
      MMCM3                        => MMCM3_LOCKED,
      RST                          => DCM1_RST
    ); 

  DCM2_RST_INST : reset_selection
    generic map (
      C_MODULE                     => C_DCM2_RST_MODULE
    )
    port map (
      CLKGEN                       => RST,
      PLL0                         => PLL0_LOCKED,
      PLL1                         => PLL1_LOCKED,
      DCM0                         => DCM0_LOCKED,
      DCM1                         => DCM1_LOCKED,
      DCM2                         => DCM2_LOCKED,
      DCM3                         => DCM3_LOCKED,
      MMCM0                        => MMCM0_LOCKED,
      MMCM1                        => MMCM1_LOCKED,
      MMCM2                        => MMCM2_LOCKED,
      MMCM3                        => MMCM3_LOCKED,
      RST                          => DCM2_RST
    ); 

  DCM3_RST_INST : reset_selection
    generic map (
      C_MODULE                     => C_DCM3_RST_MODULE
    )
    port map (
      CLKGEN                       => RST,
      PLL0                         => PLL0_LOCKED,
      PLL1                         => PLL1_LOCKED,
      DCM0                         => DCM0_LOCKED,
      DCM1                         => DCM1_LOCKED,
      DCM2                         => DCM2_LOCKED,
      DCM3                         => DCM3_LOCKED,
      MMCM0                        => MMCM0_LOCKED,
      MMCM1                        => MMCM1_LOCKED,
      MMCM2                        => MMCM2_LOCKED,
      MMCM3                        => MMCM3_LOCKED,
      RST                          => DCM3_RST
    ); 

  MMCM0_RST_INST : reset_selection
    generic map (
      C_MODULE                     => C_MMCM0_RST_MODULE
    )
    port map (
      CLKGEN                       => RST,
      PLL0                         => PLL0_LOCKED,
      PLL1                         => PLL1_LOCKED,
      DCM0                         => DCM0_LOCKED,
      DCM1                         => DCM1_LOCKED,
      DCM2                         => DCM2_LOCKED,
      DCM3                         => DCM3_LOCKED,
      MMCM0                        => MMCM0_LOCKED,
      MMCM1                        => MMCM1_LOCKED,
      MMCM2                        => MMCM2_LOCKED,
      MMCM3                        => MMCM3_LOCKED,
      RST                          => MMCM0_RST
    ); 

  MMCM1_RST_INST : reset_selection
    generic map (
      C_MODULE                     => C_MMCM1_RST_MODULE
    )
    port map (
      CLKGEN                       => RST,
      PLL0                         => PLL0_LOCKED,
      PLL1                         => PLL1_LOCKED,
      DCM0                         => DCM0_LOCKED,
      DCM1                         => DCM1_LOCKED,
      DCM2                         => DCM2_LOCKED,
      DCM3                         => DCM3_LOCKED,
      MMCM0                        => MMCM0_LOCKED,
      MMCM1                        => MMCM1_LOCKED,
      MMCM2                        => MMCM2_LOCKED,
      MMCM3                        => MMCM3_LOCKED,
      RST                          => MMCM1_RST
    ); 

  MMCM2_RST_INST : reset_selection
    generic map (
      C_MODULE                     => C_MMCM2_RST_MODULE
    )
    port map (
      CLKGEN                       => RST,
      PLL0                         => PLL0_LOCKED,
      PLL1                         => PLL1_LOCKED,
      DCM0                         => DCM0_LOCKED,
      DCM1                         => DCM1_LOCKED,
      DCM2                         => DCM2_LOCKED,
      DCM3                         => DCM3_LOCKED,
      MMCM0                        => MMCM0_LOCKED,
      MMCM1                        => MMCM1_LOCKED,
      MMCM2                        => MMCM2_LOCKED,
      MMCM3                        => MMCM3_LOCKED,
      RST                          => MMCM2_RST
    ); 

  MMCM3_RST_INST : reset_selection
    generic map (
      C_MODULE                     => C_MMCM3_RST_MODULE
    )
    port map (
      CLKGEN                       => RST,
      PLL0                         => PLL0_LOCKED,
      PLL1                         => PLL1_LOCKED,
      DCM0                         => DCM0_LOCKED,
      DCM1                         => DCM1_LOCKED,
      DCM2                         => DCM2_LOCKED,
      DCM3                         => DCM3_LOCKED,
      MMCM0                        => MMCM0_LOCKED,
      MMCM1                        => MMCM1_LOCKED,
      MMCM2                        => MMCM2_LOCKED,
      MMCM3                        => MMCM3_LOCKED,
      RST                          => MMCM3_RST
    ); 

  -- CLKGEN

  CLKGEN_LOCKED_PROC : process (      PLL0_LOCKED, 
                                      PLL1_LOCKED, 
                                      DCM0_LOCKED, 
                                      DCM1_LOCKED, 
                                      DCM2_LOCKED, 
                                      DCM3_LOCKED, 
                                      MMCM0_LOCKED, 
                                      MMCM1_LOCKED, 
                                      MMCM2_LOCKED, 
                                      MMCM3_LOCKED        ) is
      variable temp  : std_logic;
    begin 
      temp := '1';
      if ( equalString(C_PLL0_RST_MODULE, "NONE") = false ) then
        temp := temp and PLL0_LOCKED;
      end if;
      if ( equalString(C_PLL1_RST_MODULE, "NONE") = false ) then
        temp := temp and PLL1_LOCKED;
      end if;
      if ( equalString(C_DCM0_RST_MODULE, "NONE") = false ) then
        temp := temp and DCM0_LOCKED;
      end if;
      if ( equalString(C_DCM1_RST_MODULE, "NONE") = false ) then
        temp := temp and DCM1_LOCKED;
      end if;
      if ( equalString(C_DCM2_RST_MODULE, "NONE") = false ) then
        temp := temp and DCM2_LOCKED;
      end if;
      if ( equalString(C_DCM3_RST_MODULE, "NONE") = false ) then
        temp := temp and DCM3_LOCKED;
      end if;
      if ( equalString(C_MMCM0_RST_MODULE, "NONE") = false ) then
        temp := temp and MMCM0_LOCKED;
      end if;
      if ( equalString(C_MMCM1_RST_MODULE, "NONE") = false ) then
        temp := temp and MMCM1_LOCKED;
      end if;
      if ( equalString(C_MMCM2_RST_MODULE, "NONE") = false ) then
        temp := temp and MMCM2_LOCKED;
      end if;
      if ( equalString(C_MMCM3_RST_MODULE, "NONE") = false ) then
        temp := temp and MMCM3_LOCKED;
      end if;
      LOCKED <= temp;
    end process CLKGEN_LOCKED_PROC;

  ----------------------------------------------------------------------------
  -- VARIABLE_PHASE control signal connection
  ----------------------------------------------------------------------------

  -- MMCM0

  MMCM0_VPS : if ( equalString(C_PSDONE_MODULE, "MMCM0") = true ) generate
    MMCM0_PSEN     <= PSEN;
    MMCM0_PSCLK    <= PSCLK;
    MMCM0_PSINCDEC <= PSINCDEC;
    PSDONE         <= MMCM0_PSDONE;
  end generate MMCM0_VPS;

  MMCM0_NO_VPS : if ( not equalString(C_PSDONE_MODULE, "MMCM0") ) generate
    MMCM0_PSEN     <= net_gnd0;
    MMCM0_PSCLK    <= net_gnd0;
    MMCM0_PSINCDEC <= net_gnd0;
  end generate MMCM0_NO_VPS;

  -- MMCM1

  MMCM1_VPS : if ( equalString(C_PSDONE_MODULE, "MMCM1") = true ) generate
    MMCM1_PSEN     <= PSEN;
    MMCM1_PSCLK    <= PSCLK;
    MMCM1_PSINCDEC <= PSINCDEC;
    PSDONE         <= MMCM1_PSDONE;
  end generate MMCM1_VPS;

  MMCM1_NO_VPS : if ( not equalString(C_PSDONE_MODULE, "MMCM1") ) generate
    MMCM1_PSEN     <= net_gnd0;
    MMCM1_PSCLK    <= net_gnd0;
    MMCM1_PSINCDEC <= net_gnd0;
  end generate MMCM1_NO_VPS;

  -- MMCM2

  MMCM2_VPS : if ( equalString(C_PSDONE_MODULE, "MMCM2") = true ) generate
    MMCM2_PSEN     <= PSEN;
    MMCM2_PSCLK    <= PSCLK;
    MMCM2_PSINCDEC <= PSINCDEC;
    PSDONE         <= MMCM2_PSDONE;
  end generate MMCM2_VPS;

  MMCM2_NO_VPS : if ( not equalString(C_PSDONE_MODULE, "MMCM2") ) generate
    MMCM2_PSEN     <= net_gnd0;
    MMCM2_PSCLK    <= net_gnd0;
    MMCM2_PSINCDEC <= net_gnd0;
  end generate MMCM2_NO_VPS;

  -- MMCM3

  MMCM3_VPS : if ( equalString(C_PSDONE_MODULE, "MMCM3") = true ) generate
    MMCM3_PSEN     <= PSEN;
    MMCM3_PSCLK    <= PSCLK;
    MMCM3_PSINCDEC <= PSINCDEC;
    PSDONE         <= MMCM3_PSDONE;
  end generate MMCM3_VPS;

  MMCM3_NO_VPS : if ( not equalString(C_PSDONE_MODULE, "MMCM3")  ) generate
    MMCM3_PSEN     <= net_gnd0;
    MMCM3_PSCLK    <= net_gnd0;
    MMCM3_PSINCDEC <= net_gnd0;
  end generate MMCM3_NO_VPS;

end STRUCT;

