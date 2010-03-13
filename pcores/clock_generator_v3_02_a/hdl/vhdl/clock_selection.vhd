-------------------------------------------------------------------------------
-- $Id: clock_selection.vhd,v 1.1.2.1 2009/10/06 18:11:14 xic Exp $
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

entity clock_selection is
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
end clock_selection;

architecture STRUCT of clock_selection is

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

begin

  Using_CLKGEN : if ( equalString(C_MODULE, "CLKGEN") = true ) generate 
    Using_CLKIN : if ( equalString(C_PORT, "CLKIN") = true ) generate
      CLKOUT <= CLKGEN(0);
    end generate Using_CLKIN;
    Using_CLKFBIN : if ( equalString(C_PORT, "CLKFBIN") = true ) generate
      CLKOUT <= CLKGEN(1);
    end generate Using_CLKFBIN;
  end generate Using_CLKGEN;

  Using_PLL0 : if ( equalString(C_MODULE, "PLL0") = true ) generate
    Using_CLKOUT0 : if ( equalString(C_PORT, "CLKOUT0") = true ) generate
      CLKOUT <= PLL0(0);
    end generate Using_CLKOUT0;
    Using_CLKOUT1 : if ( equalString(C_PORT, "CLKOUT1") = true ) generate
      CLKOUT <= PLL0(1);
    end generate Using_CLKOUT1;
    Using_CLKOUT2 : if ( equalString(C_PORT, "CLKOUT2") = true ) generate
      CLKOUT <= PLL0(2);
    end generate Using_CLKOUT2;
    Using_CLKOUT3 : if ( equalString(C_PORT, "CLKOUT3") = true ) generate
      CLKOUT <= PLL0(3);
    end generate Using_CLKOUT3;
    Using_CLKOUT4 : if ( equalString(C_PORT, "CLKOUT4") = true ) generate
      CLKOUT <= PLL0(4);
    end generate Using_CLKOUT4;
    Using_CLKOUT5 : if ( equalString(C_PORT, "CLKOUT5") = true ) generate
      CLKOUT <= PLL0(5);
    end generate Using_CLKOUT5;
    Using_CLKFBOUT : if ( equalString(C_PORT, "CLKFBOUT") = true ) generate
      CLKOUT <= PLL0(6);
    end generate Using_CLKFBOUT;
    Using_CLKOUTDCM0 : if ( equalString(C_PORT, "CLKOUTDCM0") = true ) generate
      CLKOUT <= PLL0(7);
    end generate Using_CLKOUTDCM0;
    Using_CLKOUTDCM1 : if ( equalString(C_PORT, "CLKOUTDCM1") = true ) generate
      CLKOUT <= PLL0(8);
    end generate Using_CLKOUTDCM1;
    Using_CLKOUTDCM2 : if ( equalString(C_PORT, "CLKOUTDCM2") = true ) generate
      CLKOUT <= PLL0(9);
    end generate Using_CLKOUTDCM2;
    Using_CLKOUTDCM3 : if ( equalString(C_PORT, "CLKOUTDCM3") = true ) generate
      CLKOUT <= PLL0(10);
    end generate Using_CLKOUTDCM3;
    Using_CLKOUTDCM4 : if ( equalString(C_PORT, "CLKOUTDCM4") = true ) generate
      CLKOUT <= PLL0(11);
    end generate Using_CLKOUTDCM4;
    Using_CLKOUTDCM5 : if ( equalString(C_PORT, "CLKOUTDCM5") = true ) generate
      CLKOUT <= PLL0(12);
    end generate Using_CLKOUTDCM5;
    Using_CLKFBDCM : if ( equalString(C_PORT, "CLKFBDCM") = true ) generate
      CLKOUT <= PLL0(13);
    end generate Using_CLKFBDCM;
    -- wrapper
    Using_CLKOUT0B : if ( equalString(C_PORT, "CLKOUT0B") = true ) generate
      CLKOUT <= PLL0(14);
    end generate Using_CLKOUT0B;
    Using_CLKOUT1B : if ( equalString(C_PORT, "CLKOUT1B") = true ) generate
      CLKOUT <= PLL0(15);
    end generate Using_CLKOUT1B;
    Using_CLKOUT2B : if ( equalString(C_PORT, "CLKOUT2B") = true ) generate
      CLKOUT <= PLL0(16);
    end generate Using_CLKOUT2B;
    Using_CLKOUT3B : if ( equalString(C_PORT, "CLKOUT3B") = true ) generate
      CLKOUT <= PLL0(17);
    end generate Using_CLKOUT3B;
    Using_CLKOUT4B : if ( equalString(C_PORT, "CLKOUT4B") = true ) generate
      CLKOUT <= PLL0(18);
    end generate Using_CLKOUT4B;
    Using_CLKOUT5B : if ( equalString(C_PORT, "CLKOUT5B") = true ) generate
      CLKOUT <= PLL0(19);
    end generate Using_CLKOUT5B;
  end generate Using_PLL0;

  Using_PLL1 : if ( equalString(C_MODULE, "PLL1") = true ) generate
    Using_CLKOUT0 : if ( equalString(C_PORT, "CLKOUT0") = true ) generate
      CLKOUT <= PLL1(0);
    end generate Using_CLKOUT0;
    Using_CLKOUT1 : if ( equalString(C_PORT, "CLKOUT1") = true ) generate
      CLKOUT <= PLL1(1);
    end generate Using_CLKOUT1;
    Using_CLKOUT2 : if ( equalString(C_PORT, "CLKOUT2") = true ) generate
      CLKOUT <= PLL1(2);
    end generate Using_CLKOUT2;
    Using_CLKOUT3 : if ( equalString(C_PORT, "CLKOUT3") = true ) generate
      CLKOUT <= PLL1(3);
    end generate Using_CLKOUT3;
    Using_CLKOUT4 : if ( equalString(C_PORT, "CLKOUT4") = true ) generate
      CLKOUT <= PLL1(4);
    end generate Using_CLKOUT4;
    Using_CLKOUT5 : if ( equalString(C_PORT, "CLKOUT5") = true ) generate
      CLKOUT <= PLL1(5);
    end generate Using_CLKOUT5;
    Using_CLKFBOUT : if ( equalString(C_PORT, "CLKFBOUT") = true ) generate
      CLKOUT <= PLL1(6);
    end generate Using_CLKFBOUT;
    Using_CLKOUTDCM0 : if ( equalString(C_PORT, "CLKOUTDCM0") = true ) generate
      CLKOUT <= PLL1(7);
    end generate Using_CLKOUTDCM0;
    Using_CLKOUTDCM1 : if ( equalString(C_PORT, "CLKOUTDCM1") = true ) generate
      CLKOUT <= PLL1(8);
    end generate Using_CLKOUTDCM1;
    Using_CLKOUTDCM2 : if ( equalString(C_PORT, "CLKOUTDCM2") = true ) generate
      CLKOUT <= PLL1(9);
    end generate Using_CLKOUTDCM2;
    Using_CLKOUTDCM3 : if ( equalString(C_PORT, "CLKOUTDCM3") = true ) generate
      CLKOUT <= PLL1(10);
    end generate Using_CLKOUTDCM3;
    Using_CLKOUTDCM4 : if ( equalString(C_PORT, "CLKOUTDCM4") = true ) generate
      CLKOUT <= PLL1(11);
    end generate Using_CLKOUTDCM4;
    Using_CLKOUTDCM5 : if ( equalString(C_PORT, "CLKOUTDCM5") = true ) generate
      CLKOUT <= PLL1(12);
    end generate Using_CLKOUTDCM5;
    Using_CLKFBDCM : if ( equalString(C_PORT, "CLKFBDCM") = true ) generate
      CLKOUT <= PLL1(13);
    end generate Using_CLKFBDCM;
    -- wrapper
    Using_CLKOUT0B : if ( equalString(C_PORT, "CLKOUT0B") = true ) generate
      CLKOUT <= PLL1(14);
    end generate Using_CLKOUT0B;
    Using_CLKOUT1B : if ( equalString(C_PORT, "CLKOUT1B") = true ) generate
      CLKOUT <= PLL1(15);
    end generate Using_CLKOUT1B;
    Using_CLKOUT2B : if ( equalString(C_PORT, "CLKOUT2B") = true ) generate
      CLKOUT <= PLL1(16);
    end generate Using_CLKOUT2B;
    Using_CLKOUT3B : if ( equalString(C_PORT, "CLKOUT3B") = true ) generate
      CLKOUT <= PLL1(17);
    end generate Using_CLKOUT3B;
    Using_CLKOUT4B : if ( equalString(C_PORT, "CLKOUT4B") = true ) generate
      CLKOUT <= PLL1(18);
    end generate Using_CLKOUT4B;
    Using_CLKOUT5B : if ( equalString(C_PORT, "CLKOUT5B") = true ) generate
      CLKOUT <= PLL1(19);
    end generate Using_CLKOUT5B;
  end generate Using_PLL1;

  Using_DCM0 : if ( equalString(C_MODULE, "DCM0") = true ) generate
    Using_CLK0 : if ( equalString(C_PORT, "CLK0") = true ) generate
      CLKOUT <= DCM0(0);
    end generate Using_CLK0;
    Using_CLK90 : if ( equalString(C_PORT, "CLK90") = true ) generate
      CLKOUT <= DCM0(1);
    end generate Using_CLK90;
    Using_CLK180 : if ( equalString(C_PORT, "CLK180") = true ) generate
      CLKOUT <= DCM0(2);
    end generate Using_CLK180;
    Using_CLK270 : if ( equalString(C_PORT, "CLK270") = true ) generate
      CLKOUT <= DCM0(3);
    end generate Using_CLK270;
    Using_CLKDV : if ( equalString(C_PORT, "CLKDV") = true ) generate
      CLKOUT <= DCM0(4);
    end generate Using_CLKDV;
    Using_CLK2X : if ( equalString(C_PORT, "CLK2X") = true ) generate
      CLKOUT <= DCM0(5);
    end generate Using_CLK2X;
    Using_CLK2X180 : if ( equalString(C_PORT, "CLK2X180") = true ) generate
      CLKOUT <= DCM0(6);
    end generate Using_CLK2X180;
    Using_CLKFX : if ( equalString(C_PORT, "CLKFX") = true ) generate
      CLKOUT <= DCM0(7);
    end generate Using_CLKFX;
    Using_CLKFX180 : if ( equalString(C_PORT, "CLKFX180") = true ) generate
      CLKOUT <= DCM0(8);
    end generate Using_CLKFX180;
    -- wrapper
    Using_CLKDV180 : if ( equalString(C_PORT, "CLKDV180") = true ) generate
      CLKOUT <= DCM0(9);
    end generate Using_CLKDV180;
    Using_CLK0B : if ( equalString(C_PORT, "CLK0B") = true ) generate
      CLKOUT <= DCM0(10);
    end generate Using_CLK0B;
    Using_CLK90B : if ( equalString(C_PORT, "CLK90B") = true ) generate
      CLKOUT <= DCM0(11);
    end generate Using_CLK90B;
    Using_CLK180B : if ( equalString(C_PORT, "CLK180B") = true ) generate
      CLKOUT <= DCM0(12);
    end generate Using_CLK180B;
    Using_CLK270B : if ( equalString(C_PORT, "CLK270B") = true ) generate
      CLKOUT <= DCM0(13);
    end generate Using_CLK270B;
    Using_CLKDVB : if ( equalString(C_PORT, "CLKDVB") = true ) generate
      CLKOUT <= DCM0(14);
    end generate Using_CLKDVB;
    Using_CLKDV180B : if ( equalString(C_PORT, "CLKDV180B") = true ) generate
      CLKOUT <= DCM0(15);
    end generate Using_CLKDV180B;
    Using_CLK2XB : if ( equalString(C_PORT, "CLK2XB") = true ) generate
      CLKOUT <= DCM0(16);
    end generate Using_CLK2XB;
    Using_CLK2X180B : if ( equalString(C_PORT, "CLK2X180B") = true ) generate
      CLKOUT <= DCM0(17);
    end generate Using_CLK2X180B;
    Using_CLKFXB : if ( equalString(C_PORT, "CLKFXB") = true ) generate
      CLKOUT <= DCM0(18);
    end generate Using_CLKFXB;
    Using_CLKFX180B : if ( equalString(C_PORT, "CLKFX180B") = true ) generate
      CLKOUT <= DCM0(19);
    end generate Using_CLKFX180B;
  end generate Using_DCM0;

  Using_DCM1 : if ( equalString(C_MODULE, "DCM1") = true ) generate
    Using_CLK0 : if ( equalString(C_PORT, "CLK0") = true ) generate
      CLKOUT <= DCM1(0);
    end generate Using_CLK0;
    Using_CLK90 : if ( equalString(C_PORT, "CLK90") = true ) generate
      CLKOUT <= DCM1(1);
    end generate Using_CLK90;
    Using_CLK180 : if ( equalString(C_PORT, "CLK180") = true ) generate
      CLKOUT <= DCM1(2);
    end generate Using_CLK180;
    Using_CLK270 : if ( equalString(C_PORT, "CLK270") = true ) generate
      CLKOUT <= DCM1(3);
    end generate Using_CLK270;
    Using_CLKDV : if ( equalString(C_PORT, "CLKDV") = true ) generate
      CLKOUT <= DCM1(4);
    end generate Using_CLKDV;
    Using_CLK2X : if ( equalString(C_PORT, "CLK2X") = true ) generate
      CLKOUT <= DCM1(5);
    end generate Using_CLK2X;
    Using_CLK2X180 : if ( equalString(C_PORT, "CLK2X180") = true ) generate
      CLKOUT <= DCM1(6);
    end generate Using_CLK2X180;
    Using_CLKFX : if ( equalString(C_PORT, "CLKFX") = true ) generate
      CLKOUT <= DCM1(7);
    end generate Using_CLKFX;
    Using_CLKFX180 : if ( equalString(C_PORT, "CLKFX180") = true ) generate
      CLKOUT <= DCM1(8);
    end generate Using_CLKFX180;
    -- wrapper
    Using_CLKDV180 : if ( equalString(C_PORT, "CLKDV180") = true ) generate
      CLKOUT <= DCM1(9);
    end generate Using_CLKDV180;
    Using_CLK0B : if ( equalString(C_PORT, "CLK0B") = true ) generate
      CLKOUT <= DCM1(10);
    end generate Using_CLK0B;
    Using_CLK90B : if ( equalString(C_PORT, "CLK90B") = true ) generate
      CLKOUT <= DCM1(11);
    end generate Using_CLK90B;
    Using_CLK180B : if ( equalString(C_PORT, "CLK180B") = true ) generate
      CLKOUT <= DCM1(12);
    end generate Using_CLK180B;
    Using_CLK270B : if ( equalString(C_PORT, "CLK270B") = true ) generate
      CLKOUT <= DCM1(13);
    end generate Using_CLK270B;
    Using_CLKDVB : if ( equalString(C_PORT, "CLKDVB") = true ) generate
      CLKOUT <= DCM1(14);
    end generate Using_CLKDVB;
    Using_CLKDV180B : if ( equalString(C_PORT, "CLKDV180B") = true ) generate
      CLKOUT <= DCM1(15);
    end generate Using_CLKDV180B;
    Using_CLK2XB : if ( equalString(C_PORT, "CLK2XB") = true ) generate
      CLKOUT <= DCM1(16);
    end generate Using_CLK2XB;
    Using_CLK2X180B : if ( equalString(C_PORT, "CLK2X180B") = true ) generate
      CLKOUT <= DCM1(17);
    end generate Using_CLK2X180B;
    Using_CLKFXB : if ( equalString(C_PORT, "CLKFXB") = true ) generate
      CLKOUT <= DCM1(18);
    end generate Using_CLKFXB;
    Using_CLKFX180B : if ( equalString(C_PORT, "CLKFX180B") = true ) generate
      CLKOUT <= DCM1(19);
    end generate Using_CLKFX180B;
  end generate Using_DCM1;

  Using_DCM2 : if ( equalString(C_MODULE, "DCM2") = true ) generate
    Using_CLK0 : if ( equalString(C_PORT, "CLK0") = true ) generate
      CLKOUT <= DCM2(0);
    end generate Using_CLK0;
    Using_CLK90 : if ( equalString(C_PORT, "CLK90") = true ) generate
      CLKOUT <= DCM2(1);
    end generate Using_CLK90;
    Using_CLK180 : if ( equalString(C_PORT, "CLK180") = true ) generate
      CLKOUT <= DCM2(2);
    end generate Using_CLK180;
    Using_CLK270 : if ( equalString(C_PORT, "CLK270") = true ) generate
      CLKOUT <= DCM2(3);
    end generate Using_CLK270;
    Using_CLKDV : if ( equalString(C_PORT, "CLKDV") = true ) generate
      CLKOUT <= DCM2(4);
    end generate Using_CLKDV;
    Using_CLK2X : if ( equalString(C_PORT, "CLK2X") = true ) generate
      CLKOUT <= DCM2(5);
    end generate Using_CLK2X;
    Using_CLK2X180 : if ( equalString(C_PORT, "CLK2X180") = true ) generate
      CLKOUT <= DCM2(6);
    end generate Using_CLK2X180;
    Using_CLKFX : if ( equalString(C_PORT, "CLKFX") = true ) generate
      CLKOUT <= DCM2(7);
    end generate Using_CLKFX;
    Using_CLKFX180 : if ( equalString(C_PORT, "CLKFX180") = true ) generate
      CLKOUT <= DCM2(8);
    end generate Using_CLKFX180;
    -- wrapper
    Using_CLKDV180 : if ( equalString(C_PORT, "CLKDV180") = true ) generate
      CLKOUT <= DCM2(9);
    end generate Using_CLKDV180;
    Using_CLK0B : if ( equalString(C_PORT, "CLK0B") = true ) generate
      CLKOUT <= DCM2(10);
    end generate Using_CLK0B;
    Using_CLK90B : if ( equalString(C_PORT, "CLK90B") = true ) generate
      CLKOUT <= DCM2(11);
    end generate Using_CLK90B;
    Using_CLK180B : if ( equalString(C_PORT, "CLK180B") = true ) generate
      CLKOUT <= DCM2(12);
    end generate Using_CLK180B;
    Using_CLK270B : if ( equalString(C_PORT, "CLK270B") = true ) generate
      CLKOUT <= DCM2(13);
    end generate Using_CLK270B;
    Using_CLKDVB : if ( equalString(C_PORT, "CLKDVB") = true ) generate
      CLKOUT <= DCM2(14);
    end generate Using_CLKDVB;
    Using_CLKDV180B : if ( equalString(C_PORT, "CLKDV180B") = true ) generate
      CLKOUT <= DCM2(15);
    end generate Using_CLKDV180B;
    Using_CLK2XB : if ( equalString(C_PORT, "CLK2XB") = true ) generate
      CLKOUT <= DCM2(16);
    end generate Using_CLK2XB;
    Using_CLK2X180B : if ( equalString(C_PORT, "CLK2X180B") = true ) generate
      CLKOUT <= DCM2(17);
    end generate Using_CLK2X180B;
    Using_CLKFXB : if ( equalString(C_PORT, "CLKFXB") = true ) generate
      CLKOUT <= DCM2(18);
    end generate Using_CLKFXB;
    Using_CLKFX180B : if ( equalString(C_PORT, "CLKFX180B") = true ) generate
      CLKOUT <= DCM2(19);
    end generate Using_CLKFX180B;
  end generate Using_DCM2;

  Using_DCM3 : if ( equalString(C_MODULE, "DCM3") = true ) generate
    Using_CLK0 : if ( equalString(C_PORT, "CLK0") = true ) generate
      CLKOUT <= DCM3(0);
    end generate Using_CLK0;
    Using_CLK90 : if ( equalString(C_PORT, "CLK90") = true ) generate
      CLKOUT <= DCM3(1);
    end generate Using_CLK90;
    Using_CLK180 : if ( equalString(C_PORT, "CLK180") = true ) generate
      CLKOUT <= DCM3(2);
    end generate Using_CLK180;
    Using_CLK270 : if ( equalString(C_PORT, "CLK270") = true ) generate
      CLKOUT <= DCM3(3);
    end generate Using_CLK270;
    Using_CLKDV : if ( equalString(C_PORT, "CLKDV") = true ) generate
      CLKOUT <= DCM3(4);
    end generate Using_CLKDV;
    Using_CLK2X : if ( equalString(C_PORT, "CLK2X") = true ) generate
      CLKOUT <= DCM3(5);
    end generate Using_CLK2X;
    Using_CLK2X180 : if ( equalString(C_PORT, "CLK2X180") = true ) generate
      CLKOUT <= DCM3(6);
    end generate Using_CLK2X180;
    Using_CLKFX : if ( equalString(C_PORT, "CLKFX") = true ) generate
      CLKOUT <= DCM3(7);
    end generate Using_CLKFX;
    Using_CLKFX180 : if ( equalString(C_PORT, "CLKFX180") = true ) generate
      CLKOUT <= DCM3(8);
    end generate Using_CLKFX180;
    -- wrapper
    Using_CLKDV180 : if ( equalString(C_PORT, "CLKDV180") = true ) generate
      CLKOUT <= DCM3(9);
    end generate Using_CLKDV180;
    Using_CLK0B : if ( equalString(C_PORT, "CLK0B") = true ) generate
      CLKOUT <= DCM3(10);
    end generate Using_CLK0B;
    Using_CLK90B : if ( equalString(C_PORT, "CLK90B") = true ) generate
      CLKOUT <= DCM3(11);
    end generate Using_CLK90B;
    Using_CLK180B : if ( equalString(C_PORT, "CLK180B") = true ) generate
      CLKOUT <= DCM3(12);
    end generate Using_CLK180B;
    Using_CLK270B : if ( equalString(C_PORT, "CLK270B") = true ) generate
      CLKOUT <= DCM3(13);
    end generate Using_CLK270B;
    Using_CLKDVB : if ( equalString(C_PORT, "CLKDVB") = true ) generate
      CLKOUT <= DCM3(14);
    end generate Using_CLKDVB;
    Using_CLKDV180B : if ( equalString(C_PORT, "CLKDV180B") = true ) generate
      CLKOUT <= DCM3(15);
    end generate Using_CLKDV180B;
    Using_CLK2XB : if ( equalString(C_PORT, "CLK2XB") = true ) generate
      CLKOUT <= DCM3(16);
    end generate Using_CLK2XB;
    Using_CLK2X180B : if ( equalString(C_PORT, "CLK2X180B") = true ) generate
      CLKOUT <= DCM3(17);
    end generate Using_CLK2X180B;
    Using_CLKFXB : if ( equalString(C_PORT, "CLKFXB") = true ) generate
      CLKOUT <= DCM3(18);
    end generate Using_CLKFXB;
    Using_CLKFX180B : if ( equalString(C_PORT, "CLKFX180B") = true ) generate
      CLKOUT <= DCM3(19);
    end generate Using_CLKFX180B;
  end generate Using_DCM3;

  Using_MMCM0 : if ( equalString(C_MODULE, "MMCM0") = true ) generate
    Using_CLKOUT0 : if ( equalString(C_PORT, "CLKOUT0") = true ) generate
      CLKOUT <= MMCM0(0);
    end generate Using_CLKOUT0;
    Using_CLKOUT1 : if ( equalString(C_PORT, "CLKOUT1") = true ) generate
      CLKOUT <= MMCM0(1);
    end generate Using_CLKOUT1;
    Using_CLKOUT2 : if ( equalString(C_PORT, "CLKOUT2") = true ) generate
      CLKOUT <= MMCM0(2);
    end generate Using_CLKOUT2;
    Using_CLKOUT3 : if ( equalString(C_PORT, "CLKOUT3") = true ) generate
      CLKOUT <= MMCM0(3);
    end generate Using_CLKOUT3;
    Using_CLKOUT4 : if ( equalString(C_PORT, "CLKOUT4") = true ) generate
      CLKOUT <= MMCM0(4);
    end generate Using_CLKOUT4;
    Using_CLKOUT5 : if ( equalString(C_PORT, "CLKOUT5") = true ) generate
      CLKOUT <= MMCM0(5);
    end generate Using_CLKOUT5;
    Using_CLKOUT6 : if ( equalString(C_PORT, "CLKOUT6") = true ) generate
      CLKOUT <= MMCM0(6);
    end generate Using_CLKOUT6;
    Using_CLKFBOUT : if ( equalString(C_PORT, "CLKFBOUT") = true ) generate
      CLKOUT <= MMCM0(7);
    end generate Using_CLKFBOUT;
    -- wrapper
    Using_CLKOUT0B : if ( equalString(C_PORT, "CLKOUT0B") = true ) generate
      CLKOUT <= MMCM0(8);
    end generate Using_CLKOUT0B;
    Using_CLKOUT1B : if ( equalString(C_PORT, "CLKOUT1B") = true ) generate
      CLKOUT <= MMCM0(9);
    end generate Using_CLKOUT1B;
    Using_CLKOUT2B : if ( equalString(C_PORT, "CLKOUT2B") = true ) generate
      CLKOUT <= MMCM0(10);
    end generate Using_CLKOUT2B;
    Using_CLKOUT3B : if ( equalString(C_PORT, "CLKOUT3B") = true ) generate
      CLKOUT <= MMCM0(11);
    end generate Using_CLKOUT3B;
    Using_CLKOUT4B : if ( equalString(C_PORT, "CLKOUT4B") = true ) generate
      CLKOUT <= MMCM0(12);
    end generate Using_CLKOUT4B;
    Using_CLKOUT5B : if ( equalString(C_PORT, "CLKOUT5B") = true ) generate
      CLKOUT <= MMCM0(13);
    end generate Using_CLKOUT5B;
    Using_CLKOUT6B : if ( equalString(C_PORT, "CLKOUT6B") = true ) generate
      CLKOUT <= MMCM0(14);
    end generate Using_CLKOUT6B;
  end generate Using_MMCM0;

  Using_MMCM1 : if ( equalString(C_MODULE, "MMCM1") = true ) generate
    Using_CLKOUT0 : if ( equalString(C_PORT, "CLKOUT0") = true ) generate
      CLKOUT <= MMCM1(0);
    end generate Using_CLKOUT0;
    Using_CLKOUT1 : if ( equalString(C_PORT, "CLKOUT1") = true ) generate
      CLKOUT <= MMCM1(1);
    end generate Using_CLKOUT1;
    Using_CLKOUT2 : if ( equalString(C_PORT, "CLKOUT2") = true ) generate
      CLKOUT <= MMCM1(2);
    end generate Using_CLKOUT2;
    Using_CLKOUT3 : if ( equalString(C_PORT, "CLKOUT3") = true ) generate
      CLKOUT <= MMCM1(3);
    end generate Using_CLKOUT3;
    Using_CLKOUT4 : if ( equalString(C_PORT, "CLKOUT4") = true ) generate
      CLKOUT <= MMCM1(4);
    end generate Using_CLKOUT4;
    Using_CLKOUT5 : if ( equalString(C_PORT, "CLKOUT5") = true ) generate
      CLKOUT <= MMCM1(5);
    end generate Using_CLKOUT5;
    Using_CLKOUT6 : if ( equalString(C_PORT, "CLKOUT6") = true ) generate
      CLKOUT <= MMCM1(6);
    end generate Using_CLKOUT6;
    Using_CLKFBOUT : if ( equalString(C_PORT, "CLKFBOUT") = true ) generate
      CLKOUT <= MMCM1(7);
    end generate Using_CLKFBOUT;
    -- wrapper
    Using_CLKOUT0B : if ( equalString(C_PORT, "CLKOUT0B") = true ) generate
      CLKOUT <= MMCM1(8);
    end generate Using_CLKOUT0B;
    Using_CLKOUT1B : if ( equalString(C_PORT, "CLKOUT1B") = true ) generate
      CLKOUT <= MMCM1(9);
    end generate Using_CLKOUT1B;
    Using_CLKOUT2B : if ( equalString(C_PORT, "CLKOUT2B") = true ) generate
      CLKOUT <= MMCM1(10);
    end generate Using_CLKOUT2B;
    Using_CLKOUT3B : if ( equalString(C_PORT, "CLKOUT3B") = true ) generate
      CLKOUT <= MMCM1(11);
    end generate Using_CLKOUT3B;
    Using_CLKOUT4B : if ( equalString(C_PORT, "CLKOUT4B") = true ) generate
      CLKOUT <= MMCM1(12);
    end generate Using_CLKOUT4B;
    Using_CLKOUT5B : if ( equalString(C_PORT, "CLKOUT5B") = true ) generate
      CLKOUT <= MMCM1(13);
    end generate Using_CLKOUT5B;
    Using_CLKOUT6B : if ( equalString(C_PORT, "CLKOUT6B") = true ) generate
      CLKOUT <= MMCM1(14);
    end generate Using_CLKOUT6B;
  end generate Using_MMCM1;


  Using_MMCM2 : if ( equalString(C_MODULE, "MMCM2") = true ) generate
    Using_CLKOUT0 : if ( equalString(C_PORT, "CLKOUT0") = true ) generate
      CLKOUT <= MMCM2(0);
    end generate Using_CLKOUT0;
    Using_CLKOUT1 : if ( equalString(C_PORT, "CLKOUT1") = true ) generate
      CLKOUT <= MMCM2(1);
    end generate Using_CLKOUT1;
    Using_CLKOUT2 : if ( equalString(C_PORT, "CLKOUT2") = true ) generate
      CLKOUT <= MMCM2(2);
    end generate Using_CLKOUT2;
    Using_CLKOUT3 : if ( equalString(C_PORT, "CLKOUT3") = true ) generate
      CLKOUT <= MMCM2(3);
    end generate Using_CLKOUT3;
    Using_CLKOUT4 : if ( equalString(C_PORT, "CLKOUT4") = true ) generate
      CLKOUT <= MMCM2(4);
    end generate Using_CLKOUT4;
    Using_CLKOUT5 : if ( equalString(C_PORT, "CLKOUT5") = true ) generate
      CLKOUT <= MMCM2(5);
    end generate Using_CLKOUT5;
    Using_CLKOUT6 : if ( equalString(C_PORT, "CLKOUT6") = true ) generate
      CLKOUT <= MMCM2(6);
    end generate Using_CLKOUT6;
    Using_CLKFBOUT : if ( equalString(C_PORT, "CLKFBOUT") = true ) generate
      CLKOUT <= MMCM2(7);
    end generate Using_CLKFBOUT;
    -- wrapper
    Using_CLKOUT0B : if ( equalString(C_PORT, "CLKOUT0B") = true ) generate
      CLKOUT <= MMCM2(8);
    end generate Using_CLKOUT0B;
    Using_CLKOUT1B : if ( equalString(C_PORT, "CLKOUT1B") = true ) generate
      CLKOUT <= MMCM2(9);
    end generate Using_CLKOUT1B;
    Using_CLKOUT2B : if ( equalString(C_PORT, "CLKOUT2B") = true ) generate
      CLKOUT <= MMCM2(10);
    end generate Using_CLKOUT2B;
    Using_CLKOUT3B : if ( equalString(C_PORT, "CLKOUT3B") = true ) generate
      CLKOUT <= MMCM2(11);
    end generate Using_CLKOUT3B;
    Using_CLKOUT4B : if ( equalString(C_PORT, "CLKOUT4B") = true ) generate
      CLKOUT <= MMCM2(12);
    end generate Using_CLKOUT4B;
    Using_CLKOUT5B : if ( equalString(C_PORT, "CLKOUT5B") = true ) generate
      CLKOUT <= MMCM2(13);
    end generate Using_CLKOUT5B;
    Using_CLKOUT6B : if ( equalString(C_PORT, "CLKOUT6B") = true ) generate
      CLKOUT <= MMCM2(14);
    end generate Using_CLKOUT6B;
  end generate Using_MMCM2;


  Using_MMCM3 : if ( equalString(C_MODULE, "MMCM3") = true ) generate
    Using_CLKOUT0 : if ( equalString(C_PORT, "CLKOUT0") = true ) generate
      CLKOUT <= MMCM3(0);
    end generate Using_CLKOUT0;
    Using_CLKOUT1 : if ( equalString(C_PORT, "CLKOUT1") = true ) generate
      CLKOUT <= MMCM3(1);
    end generate Using_CLKOUT1;
    Using_CLKOUT2 : if ( equalString(C_PORT, "CLKOUT2") = true ) generate
      CLKOUT <= MMCM3(2);
    end generate Using_CLKOUT2;
    Using_CLKOUT3 : if ( equalString(C_PORT, "CLKOUT3") = true ) generate
      CLKOUT <= MMCM3(3);
    end generate Using_CLKOUT3;
    Using_CLKOUT4 : if ( equalString(C_PORT, "CLKOUT4") = true ) generate
      CLKOUT <= MMCM3(4);
    end generate Using_CLKOUT4;
    Using_CLKOUT5 : if ( equalString(C_PORT, "CLKOUT5") = true ) generate
      CLKOUT <= MMCM3(5);
    end generate Using_CLKOUT5;
    Using_CLKOUT6 : if ( equalString(C_PORT, "CLKOUT6") = true ) generate
      CLKOUT <= MMCM3(6);
    end generate Using_CLKOUT6;
    Using_CLKFBOUT : if ( equalString(C_PORT, "CLKFBOUT") = true ) generate
      CLKOUT <= MMCM3(7);
    end generate Using_CLKFBOUT;
    -- wrapper
    Using_CLKOUT0B : if ( equalString(C_PORT, "CLKOUT0B") = true ) generate
      CLKOUT <= MMCM3(8);
    end generate Using_CLKOUT0B;
    Using_CLKOUT1B : if ( equalString(C_PORT, "CLKOUT1B") = true ) generate
      CLKOUT <= MMCM3(9);
    end generate Using_CLKOUT1B;
    Using_CLKOUT2B : if ( equalString(C_PORT, "CLKOUT2B") = true ) generate
      CLKOUT <= MMCM3(10);
    end generate Using_CLKOUT2B;
    Using_CLKOUT3B : if ( equalString(C_PORT, "CLKOUT3B") = true ) generate
      CLKOUT <= MMCM3(11);
    end generate Using_CLKOUT3B;
    Using_CLKOUT4B : if ( equalString(C_PORT, "CLKOUT4B") = true ) generate
      CLKOUT <= MMCM3(12);
    end generate Using_CLKOUT4B;
    Using_CLKOUT5B : if ( equalString(C_PORT, "CLKOUT5B") = true ) generate
      CLKOUT <= MMCM3(13);
    end generate Using_CLKOUT5B;
    Using_CLKOUT6B : if ( equalString(C_PORT, "CLKOUT6B") = true ) generate
      CLKOUT <= MMCM3(14);
    end generate Using_CLKOUT6B;
  end generate Using_MMCM3;


end STRUCT;

-------------------------------------------------------------------------------
-- reset selection
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- clock generator
-------------------------------------------------------------------------------
