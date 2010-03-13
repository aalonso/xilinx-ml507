-------------------------------------------------------------------------------
-- $Id: pll_module_wrapper.vhd,v 1.1.2.1 2009/10/06 18:11:14 xic Exp $
-------------------------------------------------------------------------------
-- pll_module.vhd - Entity and architecture
--
--  ***************************************************************************
--  **  Copyright(C) 2007 by Xilinx, Inc. All rights reserved.               **
--  **                                                                       **
--  ***************************************************************************
--
-------------------------------------------------------------------------------
-- Filename:        pll_module.vhd
--
-- Description:     
--                  
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:   
--              pll_module.vhd
--
-------------------------------------------------------------------------------
-- Revision:        $Revision: 1.1.2.1 $
-- Date:            $Date: 2009/10/06 18:11:14 $
--
-- History:

--
-------------------------------------------------------------------------------
-- Naming Conventions:
-- active low signals: "*_n"
-- clock signals: "clk", "clk_div#", "clk_#x"
-- reset signals: "rst", "rst_n"
-- generics: "C_*"
-- user defined types: "*_TYPE"
-- state machine next state: "*_ns"
-- state machine current state: "*_cs"
-- combinatorial signals: "*_com"
-- pipelined or register delay signals: "*_d#"
-- counter signals: "*cnt*"
-- clock enable signals: "*_ce"
-- internal version of output port "*_i"
-- device pins: "*_pin"
-- ports: - Names begin with Uppercase
-- processes: "*_PROCESS"
-- component instantiations: "<ENTITY_>I_<#|FUNC>
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library Unisim;
use Unisim.vcomponents.all;

-------------------------------------------------------------------------------
-- pll module v1.00.a
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- dcm module wrapper for clock generator
-------------------------------------------------------------------------------

entity pll_module_wrapper is
  generic (
    -- (1) module
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
    --
    C_EXT_RESET_HIGH :     integer := 1;
    C_FAMILY         :     string  := "virtex5";
    -- (2) wrapper
    C_CLKOUT0_BUF           : boolean := false; -- turn on/off bufg for CLKOUT0B
    C_CLKOUT1_BUF           : boolean := false; --
    C_CLKOUT2_BUF           : boolean := false; --
    C_CLKOUT3_BUF           : boolean := false; --
    C_CLKOUT4_BUF           : boolean := false; --
    C_CLKOUT5_BUF           : boolean := false  --
    );
  port (
    -- (1) module
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
    -- DO            : out std_logic_vector (15 downto 0);
    -- DRDY          : out std_logic;
    LOCKED           : out std_logic;
    CLKFBIN          : in  std_logic;
    CLKIN1           : in  std_logic;
    -- CLKIN2        : in  std_logic;
    -- CLKINSEL      : in  std_logic;
    -- DADDR         : in  std_logic_vector (4 downto 0);
    -- DCLK          : in  std_logic;
    -- DEN           : in  std_logic;
    -- DI            : in  std_logic_vector (15 downto 0);
    -- DWE           : in  std_logic;
    -- REL           : in  std_logic;
    RST              : in  std_logic;
    -- (2) wrapper
    CLKOUT0B         : out std_logic;
    CLKOUT1B         : out std_logic;
    CLKOUT2B         : out std_logic;
    CLKOUT3B         : out std_logic;
    CLKOUT4B         : out std_logic;
    CLKOUT5B         : out std_logic
    );
end pll_module_wrapper;

architecture STRUCT of pll_module_wrapper is
  ----------------------------------------------------------------------------
  -- Components ( copy from entity )
  ----------------------------------------------------------------------------

  component pll_module is
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
      C_CLKOUT0_BUF           : boolean := false;
      C_CLKOUT1_BUF           : boolean := false;
      C_CLKOUT2_BUF           : boolean := false;
      C_CLKOUT3_BUF           : boolean := false;
      C_CLKOUT4_BUF           : boolean := false;
      C_CLKOUT5_BUF           : boolean := false;

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
      RST              : in  std_logic
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

  signal CLKOUT0_PLL : std_logic;
  signal CLKOUT1_PLL : std_logic;
  signal CLKOUT2_PLL : std_logic;
  signal CLKOUT3_PLL : std_logic;
  signal CLKOUT4_PLL : std_logic;
  signal CLKOUT5_PLL : std_logic;

begin

  PLL_INST : pll_module
    generic map (
      -- base pll_adv parameters
      C_BANDWIDTH                 => C_BANDWIDTH,
      C_CLKFBOUT_MULT             => C_CLKFBOUT_MULT,
      C_CLKFBOUT_PHASE            => C_CLKFBOUT_PHASE,
      C_CLKIN1_PERIOD             => C_CLKIN1_PERIOD,
      -- C_CLKIN2_PERIOD          => 
      C_CLKOUT0_DIVIDE            => C_CLKOUT0_DIVIDE,
      C_CLKOUT0_DUTY_CYCLE        => C_CLKOUT0_DUTY_CYCLE,
      C_CLKOUT0_PHASE             => C_CLKOUT0_PHASE,
      C_CLKOUT1_DIVIDE            => C_CLKOUT1_DIVIDE,
      C_CLKOUT1_DUTY_CYCLE        => C_CLKOUT1_DUTY_CYCLE, 
      C_CLKOUT1_PHASE             => C_CLKOUT1_PHASE,
      C_CLKOUT2_DIVIDE            => C_CLKOUT2_DIVIDE,
      C_CLKOUT2_DUTY_CYCLE        => C_CLKOUT2_DUTY_CYCLE,
      C_CLKOUT2_PHASE             => C_CLKOUT2_PHASE,
      C_CLKOUT3_DIVIDE            => C_CLKOUT3_DIVIDE,
      C_CLKOUT3_DUTY_CYCLE        => C_CLKOUT3_DUTY_CYCLE,
      C_CLKOUT3_PHASE             => C_CLKOUT3_PHASE,
      C_CLKOUT4_DIVIDE            => C_CLKOUT4_DIVIDE,
      C_CLKOUT4_DUTY_CYCLE        => C_CLKOUT4_DUTY_CYCLE,
      C_CLKOUT4_PHASE             => C_CLKOUT4_PHASE,
      C_CLKOUT5_DIVIDE            => C_CLKOUT5_DIVIDE,
      C_CLKOUT5_DUTY_CYCLE        => C_CLKOUT5_DUTY_CYCLE,
      C_CLKOUT5_PHASE             => C_CLKOUT5_PHASE,
      C_COMPENSATION              => C_COMPENSATION,
      C_DIVCLK_DIVIDE             => C_DIVCLK_DIVIDE,
      -- C_EN_REL                 => 
      -- C_PLL_PMCD_MODE          => 
      C_REF_JITTER                => C_REF_JITTER,
      C_RESET_ON_LOSS_OF_LOCK     => C_RESET_ON_LOSS_OF_LOCK,
      C_RST_DEASSERT_CLK          => C_RST_DEASSERT_CLK,
      C_CLKOUT0_DESKEW_ADJUST     => C_CLKOUT0_DESKEW_ADJUST,
      C_CLKOUT1_DESKEW_ADJUST     => C_CLKOUT1_DESKEW_ADJUST,
      C_CLKOUT2_DESKEW_ADJUST     => C_CLKOUT2_DESKEW_ADJUST,
      C_CLKOUT3_DESKEW_ADJUST     => C_CLKOUT3_DESKEW_ADJUST,
      C_CLKOUT4_DESKEW_ADJUST     => C_CLKOUT4_DESKEW_ADJUST,
      C_CLKOUT5_DESKEW_ADJUST     => C_CLKOUT5_DESKEW_ADJUST,
      C_CLKFBOUT_DESKEW_ADJUST    => C_CLKFBOUT_DESKEW_ADJUST,
      -- parameters for pcore
      C_CLKIN1_BUF                => C_CLKIN1_BUF,
      -- C_CLKIN2_BUF             => 
      C_CLKFBOUT_BUF              => C_CLKFBOUT_BUF,
      C_CLKOUT0_BUF               => false,
      C_CLKOUT1_BUF               => false,
      C_CLKOUT2_BUF               => false,
      C_CLKOUT3_BUF               => false,
      C_CLKOUT4_BUF               => false,
      C_CLKOUT5_BUF               => false,
      C_EXT_RESET_HIGH            => C_EXT_RESET_HIGH,
      C_FAMILY                    => C_FAMILY
      )
    port map (
      CLKFBDCM                    => CLKFBDCM,
      CLKFBOUT                    => CLKFBOUT,
      CLKOUT0                     => CLKOUT0_PLL,
      CLKOUT1                     => CLKOUT1_PLL,
      CLKOUT2                     => CLKOUT2_PLL,
      CLKOUT3                     => CLKOUT3_PLL,
      CLKOUT4                     => CLKOUT4_PLL,
      CLKOUT5                     => CLKOUT5_PLL,
      CLKOUTDCM0                  => CLKOUTDCM0,
      CLKOUTDCM1                  => CLKOUTDCM1,
      CLKOUTDCM2                  => CLKOUTDCM2,
      CLKOUTDCM3                  => CLKOUTDCM3,
      CLKOUTDCM4                  => CLKOUTDCM4,
      CLKOUTDCM5                  => CLKOUTDCM5,
      -- DO                       =>
      -- DRDY                     =>
      LOCKED                      => LOCKED,
      CLKFBIN                     => CLKFBIN,
      CLKIN1                      => CLKIN1,
      -- CLKIN2                   =>
      -- CLKINSEL                 =>
      -- DADDR                    =>
      -- DCLK                     =>
      -- DEN                      =>
      -- DI                       =>
      -- DWE                      =>
      -- REL                      =>
      RST                         => RST
      );

  -----------------------------------------------------------------------------
  -- CLKOUT0 
  -----------------------------------------------------------------------------
  CLKOUT0 <= CLKOUT0_PLL;

  -----------------------------------------------------------------------------
  -- CLKOUT0B 
  -----------------------------------------------------------------------------
  Using_BUFG_for_CLKOUT0 : if (C_CLKOUT0_BUF) generate
    CLKOUT0_BUFG_INST : BUFG
      port map (
        I => CLKOUT0_PLL,
        O => CLKOUT0B);
  end generate Using_BUFG_for_CLKOUT0;

  No_BUFG_for_CLKOUT0 : if (not C_CLKOUT0_BUF) generate
    CLKOUT0B <= CLKOUT0_PLL;
  end generate No_BUFG_for_CLKOUT0;

  -----------------------------------------------------------------------------
  -- CLKOUT1 
  -----------------------------------------------------------------------------
  CLKOUT1 <= CLKOUT1_PLL;

  -----------------------------------------------------------------------------
  -- CLKOUT1B 
  -----------------------------------------------------------------------------
  Using_BUFG_for_CLKOUT1 : if (C_CLKOUT1_BUF) generate
    CLKOUT1_BUFG_INST : BUFG
      port map (
        I => CLKOUT1_PLL,
        O => CLKOUT1B);
  end generate Using_BUFG_for_CLKOUT1;

  No_BUFG_for_CLKOUT1 : if (not C_CLKOUT1_BUF) generate
    CLKOUT1B <= CLKOUT1_PLL;
  end generate No_BUFG_for_CLKOUT1;

  -----------------------------------------------------------------------------
  -- CLKOUT2 
  -----------------------------------------------------------------------------
  CLKOUT2 <= CLKOUT2_PLL;

  -----------------------------------------------------------------------------
  -- CLKOUT2B 
  -----------------------------------------------------------------------------
  Using_BUFG_for_CLKOUT2 : if (C_CLKOUT2_BUF) generate
    CLKOUT2_BUFG_INST : BUFG
      port map (
        I => CLKOUT2_PLL,
        O => CLKOUT2B);
  end generate Using_BUFG_for_CLKOUT2;

  No_BUFG_for_CLKOUT2 : if (not C_CLKOUT2_BUF) generate
    CLKOUT2B <= CLKOUT2_PLL;
  end generate No_BUFG_for_CLKOUT2;

  -----------------------------------------------------------------------------
  -- CLKOUT3 
  -----------------------------------------------------------------------------
  CLKOUT3 <= CLKOUT3_PLL;

  -----------------------------------------------------------------------------
  -- CLKOUT3B 
  -----------------------------------------------------------------------------
  Using_BUFG_for_CLKOUT3 : if (C_CLKOUT3_BUF) generate
    CLKOUT3_BUFG_INST : BUFG
      port map (
        I => CLKOUT3_PLL,
        O => CLKOUT3B);
  end generate Using_BUFG_for_CLKOUT3;

  No_BUFG_for_CLKOUT3 : if (not C_CLKOUT3_BUF) generate
    CLKOUT3B <= CLKOUT3_PLL;
  end generate No_BUFG_for_CLKOUT3;

  -----------------------------------------------------------------------------
  -- CLKOUT4 
  -----------------------------------------------------------------------------
  CLKOUT4 <= CLKOUT4_PLL;

  -----------------------------------------------------------------------------
  -- CLKOUT4B 
  -----------------------------------------------------------------------------
  Using_BUFG_for_CLKOUT4 : if (C_CLKOUT4_BUF) generate
    CLKOUT4_BUFG_INST : BUFG
      port map (
        I => CLKOUT4_PLL,
        O => CLKOUT4B);
  end generate Using_BUFG_for_CLKOUT4;

  No_BUFG_for_CLKOUT4 : if (not C_CLKOUT4_BUF) generate
    CLKOUT4B <= CLKOUT4_PLL;
  end generate No_BUFG_for_CLKOUT4;

  -----------------------------------------------------------------------------
  -- CLKOUT5 
  -----------------------------------------------------------------------------
  CLKOUT5 <= CLKOUT5_PLL;

  -----------------------------------------------------------------------------
  -- CLKOUT5B 
  -----------------------------------------------------------------------------
  Using_BUFG_for_CLKOUT5 : if (C_CLKOUT5_BUF) generate
    CLKOUT5_BUFG_INST : BUFG
      port map (
        I => CLKOUT5_PLL,
        O => CLKOUT5B);
  end generate Using_BUFG_for_CLKOUT5;

  No_BUFG_for_CLKOUT5 : if (not C_CLKOUT5_BUF) generate
    CLKOUT5B <= CLKOUT5_PLL;
  end generate No_BUFG_for_CLKOUT5;

end STRUCT;
