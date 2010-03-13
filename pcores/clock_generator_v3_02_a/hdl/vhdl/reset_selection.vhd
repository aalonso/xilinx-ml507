-------------------------------------------------------------------------------
-- $Id: reset_selection.vhd,v 1.1.2.1 2009/10/06 18:11:14 xic Exp $
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

entity reset_selection is
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
end reset_selection;

architecture STRUCT of reset_selection is

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
    RST <= CLKGEN;
  end generate Using_CLKGEN;

  Using_PLL0 : if ( equalString(C_MODULE, "PLL0") = true ) generate
    RST <= PLL0;
  end generate Using_PLL0;

  Using_PLL1 : if ( equalString(C_MODULE, "PLL1") = true ) generate
    RST <= PLL1;
  end generate Using_PLL1;

  Using_DCM0 : if ( equalString(C_MODULE, "DCM0") = true ) generate
    RST <= DCM0;
  end generate Using_DCM0;

  Using_DCM1 : if ( equalString(C_MODULE, "DCM1") = true ) generate
    RST <= DCM1;
  end generate Using_DCM1;

  Using_DCM2 : if ( equalString(C_MODULE, "DCM2") = true ) generate
    RST <= DCM2;
  end generate Using_DCM2;

  Using_DCM3 : if ( equalString(C_MODULE, "DCM3") = true ) generate
    RST <= DCM3;
  end generate Using_DCM3;

  Using_MMCM0 : if ( equalString(C_MODULE, "MMCM0") = true ) generate
    RST <= MMCM0;
  end generate Using_MMCM0;

  Using_MMCM1 : if ( equalString(C_MODULE, "MMCM1") = true ) generate
    RST <= MMCM1;
  end generate Using_MMCM1;

  Using_MMCM2 : if ( equalString(C_MODULE, "MMCM2") = true ) generate
    RST <= MMCM2;
  end generate Using_MMCM2;

  Using_MMCM3 : if ( equalString(C_MODULE, "MMCM3") = true ) generate
    RST <= MMCM3;
  end generate Using_MMCM3;

end STRUCT;

-------------------------------------------------------------------------------
-- clock generator
-------------------------------------------------------------------------------
