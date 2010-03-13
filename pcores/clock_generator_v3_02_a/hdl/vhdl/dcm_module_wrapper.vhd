-------------------------------------------------------------------------------
-- $Id: dcm_module_wrapper.vhd,v 1.1.2.1 2009/10/06 18:11:14 xic Exp $
-------------------------------------------------------------------------------
-- dcm_module.vhd - Entity and architecture
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
-- Filename:        dcm_module.vhd
--
-- Description:     
--                  
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:   
--              dcm_module.vhd
--
-------------------------------------------------------------------------------
-- Author:          goran
-- Revision:        $Revision: 1.1.2.1 $
-- Date:            $Date: 2009/10/06 18:11:14 $
--
-- History:
--   goran  2003-06-05    First Version
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
-- dcm module v1.00.c
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- dcm module wrapper for clock generator
-------------------------------------------------------------------------------

entity dcm_module_wrapper is
  generic (
    -- module
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
    C_EXT_RESET_HIGH        : integer := 1;
    C_FAMILY                : string  := "virtex2";
    -- wrapper
    C_CLK0_BUF              : boolean := false; -- trun on/off bufg for CLK0B only
    C_CLK90_BUF             : boolean := false; --
    C_CLK180_BUF            : boolean := false; --
    C_CLK270_BUF            : boolean := false; --
    C_CLKDV_BUF             : boolean := false; --
    C_CLKDV180_BUF          : boolean := false; --
    C_CLK2X_BUF             : boolean := false; --
    C_CLK2X180_BUF          : boolean := false; --
    C_CLKFX_BUF             : boolean := false; --
    C_CLKFX180_BUF          : boolean := false  --
    );
  port (
    -- module
    RST       : in  std_logic;
    CLKIN     : in  std_logic;
    CLKFB     : in  std_logic;
    PSEN      : in  std_logic;
    PSINCDEC  : in  std_logic;
    PSCLK     : in  std_logic;
    DSSEN     : in  std_logic;
    CLK0      : out std_logic;
    CLK90     : out std_logic;
    CLK180    : out std_logic;
    CLK270    : out std_logic;
    CLKDV     : out std_logic;
    CLK2X     : out std_logic;
    CLK2X180  : out std_logic;
    CLKFX     : out std_logic;
    CLKFX180  : out std_logic;
    STATUS    : out std_logic_vector(7 downto 0);
    LOCKED    : out std_logic;
    PSDONE    : out std_logic;
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
end dcm_module_wrapper;

architecture STRUCT of dcm_module_wrapper is

  ----------------------------------------------------------------------------
  -- Components ( copy from entity )
  ----------------------------------------------------------------------------

  component dcm_module is
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
      PSDONE   : out std_logic
      );
  end component;

  ----------------------------------------------------------------------------
  -- Functions
  ----------------------------------------------------------------------------

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

  signal CLK0_DCM     : std_logic;
  signal CLK90_DCM    : std_logic;
  signal CLK180_DCM   : std_logic;
  signal CLK270_DCM   : std_logic;
  signal CLKDV_DCM    : std_logic;
  signal CLKDV180_DCM : std_logic;
  signal CLK2X_DCM    : std_logic;
  signal CLK2X180_DCM : std_logic;
  signal CLKFX_DCM    : std_logic;
  signal CLKFX180_DCM : std_logic;

  signal CLK0_BUF     : std_logic;
  signal CLK90_BUF    : std_logic;
  signal CLK180_BUF   : std_logic;
  signal CLK270_BUF   : std_logic;
  signal CLKDV_BUF    : std_logic;
  signal CLKDV180_BUF : std_logic;
  signal CLK2X_BUF    : std_logic;
  signal CLK2X180_BUF : std_logic;
  signal CLKFX_BUF    : std_logic;
  signal CLKFX180_BUF : std_logic;

  -- signals: gnd

  signal net_gnd0  : std_logic;
  signal net_gnd1  : std_logic_vector(0 to 0);
  signal net_gnd16 : std_logic_vector(0 to 15);

  -- signals: vdd

  signal net_vdd0  : std_logic;
                                  
begin

  DCM_INST : dcm_module
    generic map (
      C_DFS_FREQUENCY_MODE    => C_DFS_FREQUENCY_MODE,
      C_DLL_FREQUENCY_MODE    => C_DLL_FREQUENCY_MODE,
      C_DUTY_CYCLE_CORRECTION => C_DUTY_CYCLE_CORRECTION,
      C_CLKIN_DIVIDE_BY_2     => C_CLKIN_DIVIDE_BY_2,
      C_CLK_FEEDBACK          => C_CLK_FEEDBACK,
      C_CLKOUT_PHASE_SHIFT    => C_CLKOUT_PHASE_SHIFT,
      C_DSS_MODE              => C_DSS_MODE,
      C_STARTUP_WAIT          => C_STARTUP_WAIT,
      C_PHASE_SHIFT           => C_PHASE_SHIFT,
      C_CLKFX_MULTIPLY        => C_CLKFX_MULTIPLY,
      C_CLKFX_DIVIDE          => C_CLKFX_DIVIDE,
      C_CLKDV_DIVIDE          => C_CLKDV_DIVIDE,
      C_CLKIN_PERIOD          => C_CLKIN_PERIOD,
      C_DESKEW_ADJUST         => C_DESKEW_ADJUST,
      C_CLKIN_BUF             => C_CLKIN_BUF,
      C_CLKFB_BUF             => C_CLKFB_BUF,
      C_CLK0_BUF              => false,
      C_CLK90_BUF             => false,
      C_CLK180_BUF            => false,
      C_CLK270_BUF            => false,
      C_CLKDV_BUF             => false,
      C_CLK2X_BUF             => false,
      C_CLK2X180_BUF          => false,
      C_CLKFX_BUF             => false,
      C_CLKFX180_BUF          => false,
      C_EXT_RESET_HIGH        => C_EXT_RESET_HIGH,
      C_FAMILY                => C_FAMILY
      )
    port map (
      RST                     => RST,
      CLKIN                   => CLKIN,
      CLKFB                   => CLKFB,
      PSEN                    => net_gnd0,
      PSINCDEC                => net_gnd0,
      PSCLK                   => net_gnd0,
      DSSEN                   => net_gnd0,
      CLK0                    => CLK0_DCM,
      CLK90                   => CLK90_DCM,
      CLK180                  => CLK180_DCM,
      CLK270                  => CLK270_DCM,
      CLKDV                   => CLKDV_DCM,
      CLK2X                   => CLK2X_DCM,
      CLK2X180                => CLK2X180_DCM,
      CLKFX                   => CLKFX_DCM,
      CLKFX180                => CLKFX180_DCM,
      STATUS                  => STATUS,
      LOCKED                  => LOCKED,
      PSDONE                  => PSDONE
      );      

  -----------------------------------------------------------------------------
  -- CLK0 
  -----------------------------------------------------------------------------
  CLK0 <= CLK0_DCM;

  -----------------------------------------------------------------------------
  -- CLK0B 
  -----------------------------------------------------------------------------
  Using_BUFG_for_CLK0 : if (C_CLK0_BUF) generate
    CLK0_BUFG_INST : BUFG
      port map (
        I => CLK0_DCM,
        O => CLK0_BUF);
  end generate Using_BUFG_for_CLK0;

  No_BUFG_for_CLK0 : if (not C_CLK0_BUF) generate
    CLK0_BUF <= CLK0_DCM;
  end generate No_BUFG_for_CLK0;

  CLK0B <= CLK0_BUF;

  -----------------------------------------------------------------------------
  -- CLK90 
  -----------------------------------------------------------------------------
  CLK90 <= CLK90_DCM;

  -----------------------------------------------------------------------------
  -- CLK90B
  -----------------------------------------------------------------------------
  Using_BUFG_for_CLK90 : if (C_CLK90_BUF) generate
    CLK90_BUFG_INST : BUFG
      port map (
        I => CLK90_DCM,
        O => CLK90_BUF);
  end generate Using_BUFG_for_CLK90;

  No_BUFG_for_CLK90 : if (not C_CLK90_BUF) generate
    CLK90_BUF <= CLK90_DCM;
  end generate No_BUFG_for_CLK90;

  CLK90B <= CLK90_BUF;

  -----------------------------------------------------------------------------
  -- CLK180 
  -----------------------------------------------------------------------------
  CLK180 <= NOT CLK0_DCM;

  -----------------------------------------------------------------------------
  -- CLK180B 
  -----------------------------------------------------------------------------
  Using_BUFG_for_CLK180 : if (C_CLK180_BUF and (not C_CLK0_BUF)) generate
    CLK180_BUFG_INST : BUFG
      port map (
        I => CLK0_DCM,
        O => CLK180_BUF);
  end generate Using_BUFG_for_CLK180;

  Share_BUFG_for_CLK180 : if (C_CLK180_BUF and C_CLK0_BUF) generate
    CLK180_BUF <= CLK0_BUF;
  end generate Share_BUFG_for_CLK180;

  No_BUFG_for_CLK180 : if (not C_CLK180_BUF) generate
    CLK180_BUF <= CLK0_DCM;
  end generate No_BUFG_for_CLK180; 

  CLK180B <= NOT CLK180_BUF;

  -----------------------------------------------------------------------------
  -- CLK270 
  -----------------------------------------------------------------------------
  CLK270 <= NOT CLK90_DCM;

  -----------------------------------------------------------------------------
  -- CLK270B 
  -----------------------------------------------------------------------------
  Using_BUFG_for_CLK270 : if (C_CLK270_BUF and (not C_CLK90_BUF)) generate
    CLK270B_BUFG_INST : BUFG
      port map (
        I => CLK90_DCM,
        O => CLK270_BUF);
  end generate Using_BUFG_for_CLK270;

  Share_BUFG_for_CLK270 : if (C_CLK270_BUF and C_CLK90_BUF) generate
    CLK270_BUF <= CLK90_BUF;
  end generate Share_BUFG_for_CLK270;

  No_BUFG_for_CLK270 : if (not C_CLK270_BUF) generate
    CLK270_BUF <= CLK90_DCM;
  end generate No_BUFG_for_CLK270; 

  CLK270B <= NOT CLK270_BUF;

  -----------------------------------------------------------------------------
  -- CLKDV 
  -----------------------------------------------------------------------------
  CLKDV <= CLKDV_DCM;

  -----------------------------------------------------------------------------
  -- CLKDVB 
  -----------------------------------------------------------------------------
  Using_BUFG_for_CLKDV : if (C_CLKDV_BUF) generate
    CLKDV_BUFG_INST : BUFG
      port map (
        I => CLKDV_DCM,
        O => CLKDV_BUF);
  end generate Using_BUFG_for_CLKDV;

  No_BUFG_for_CLKDV : if (not C_CLKDV_BUF) generate
    CLKDV_BUF <= CLKDV_DCM;
  end generate No_BUFG_for_CLKDV;

  CLKDVB <= CLKDV_BUF;

  -----------------------------------------------------------------------------
  -- CLKDV180 
  -----------------------------------------------------------------------------
  CLKDV180 <= NOT CLKDV_DCM;

  -----------------------------------------------------------------------------
  -- CLKDV180B 
  -----------------------------------------------------------------------------
  Using_BUFG_for_CLKDV180 : if (C_CLKDV180_BUF and (not C_CLKDV_BUF)) generate
    CLKDV180_BUFG_INST : BUFG
      port map (
        I => CLKDV_DCM,
        O => CLKDV180_BUF);
  end generate Using_BUFG_for_CLKDV180;

  Share_BUFG_for_CLKDV180 : if (C_CLKDV180_BUF and C_CLKDV_BUF) generate
    CLKDV180_BUF <= CLKDV_BUF;
  end generate Share_BUFG_for_CLKDV180;

  No_BUFG_for_CLKDV180 : if (not C_CLKDV180_BUF) generate
    CLKDV180_BUF <= CLKDV_DCM;
  end generate No_BUFG_for_CLKDV180; 

  CLKDV180B <= NOT CLKDV180_BUF;

  -----------------------------------------------------------------------------
  -- CLK2X 
  -----------------------------------------------------------------------------
  CLK2X <= CLK2X_DCM;

  -----------------------------------------------------------------------------
  -- CLK2XB 
  -----------------------------------------------------------------------------
  Using_BUFG_for_CLK2X : if (C_CLK2X_BUF) generate
    CLK2X_BUFG_INST : BUFG
      port map (
        I => CLK2X_DCM,
        O => CLK2X_BUF);
  end generate Using_BUFG_for_CLK2X;

  No_BUFG_for_CLK2X : if (not C_CLK2X_BUF) generate
    CLK2X_BUF <= CLK2X_DCM;
  end generate No_BUFG_for_CLK2X;

  CLK2XB <= CLK2X_BUF;

  -----------------------------------------------------------------------------
  -- CLK2X180 
  -----------------------------------------------------------------------------
  CLK2X180 <= NOT CLK2X_DCM;

  -----------------------------------------------------------------------------
  -- CLK2X180B 
  -----------------------------------------------------------------------------
  Using_BUFG_for_CLK2X180 : if (C_CLK2X180_BUF and (not C_CLK2X_BUF)) generate
    CLK2X180_BUFG_INST : BUFG
      port map (
        I => CLK2X_DCM,
        O => CLK2X180_BUF);
  end generate Using_BUFG_for_CLK2X180;

  Share_BUFG_for_CLK2X180 : if (C_CLK2X180_BUF and C_CLK2X_BUF) generate
    CLK2X180_BUF <= CLK2X_BUF;
  end generate Share_BUFG_for_CLK2X180;

  No_BUFG_for_CLK2X180 : if (not C_CLK2X180_BUF) generate
    CLK2X180_BUF <= CLK2X_DCM;
  end generate No_BUFG_for_CLK2X180; 

  CLK2X180B <= NOT CLK2X180_BUF;

  -----------------------------------------------------------------------------
  -- CLKFX 
  -----------------------------------------------------------------------------
  CLKFX <= CLKFX_DCM;

  -----------------------------------------------------------------------------
  -- CLKFXB 
  -----------------------------------------------------------------------------
  Using_BUFG_for_CLKFX : if (C_CLKFX_BUF) generate
    CLKFX_BUFG_INST : BUFG
      port map (
        I => CLKFX_DCM,
        O => CLKFX_BUF);
  end generate Using_BUFG_for_CLKFX;

  No_BUFG_for_CLKFX : if (not C_CLKFX_BUF) generate
    CLKFX_BUF <= CLKFX_DCM;
  end generate No_BUFG_for_CLKFX;

  CLKFXB <= CLKFX_BUF;

  -----------------------------------------------------------------------------
  -- CLKFX180 
  -----------------------------------------------------------------------------
  CLKFX180 <= NOT CLKFX_DCM;

  -----------------------------------------------------------------------------
  -- CLKFX180B 
  -----------------------------------------------------------------------------
  Using_BUFG_for_CLKFX180 : if (C_CLKFX180_BUF and (not C_CLKFX_BUF)) generate
    CLKFX180_BUFG_INST : BUFG
      port map (
        I => CLKFX_DCM,
        O => CLKFX180_BUF);
  end generate Using_BUFG_for_CLKFX180;

  Share_BUFG_for_CLKFX180 : if (C_CLKFX180_BUF and C_CLKFX_BUF) generate
    CLKFX180_BUF <= CLKFX_BUF;
  end generate Share_BUFG_for_CLKFX180;

  No_BUFG_for_CLKFX180 : if (not C_CLKFX180_BUF) generate
    CLKFX180_BUF <= CLKFX_DCM;
  end generate No_BUFG_for_CLKFX180; 

  CLKFX180B <= NOT CLKFX180_BUF;

end STRUCT;



