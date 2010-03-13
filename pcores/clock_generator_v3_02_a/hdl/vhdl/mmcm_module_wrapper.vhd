-------------------------------------------------------------------------------
-- $Id: mmcm_module_wrapper.vhd,v 1.1.2.1 2009/10/06 18:11:14 xic Exp $
-------------------------------------------------------------------------------
-- mmcm_module.vhd - Entity and architecture
--
--  ***************************************************************************
--  **  Copyright(C) 2007 by Xilinx, Inc. All rights reserved.               **
--  **                                                                       **
--  ***************************************************************************
--
-------------------------------------------------------------------------------
-- Filename:        mmcm_module.vhd
--
-- Description:     
--                  
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:   
--              mmcm_module.vhd
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
-- mmcm module v1.00.a
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- dcm module wrapper for clock generator
-------------------------------------------------------------------------------

entity mmcm_module_wrapper is
  generic (
    -- (1) module
    -- base mmcm_adv parameters
    C_BANDWIDTH             : string  := "OPTIMIZED"; 
    C_CLKFBOUT_MULT_F       : real := 1.0;  -- Multiplication factor for all output clocks
    C_CLKFBOUT_PHASE        : real    := 0.0;  -- Phase shift (degrees) of all output clocks
    C_CLKFBOUT_USE_FINE_PS  : boolean := false;
    C_CLKIN1_PERIOD         : real    := 0.000;  -- Clock period (ns) of input clock on CLKIN1
    C_CLKOUT0_DIVIDE_F      : real := 1.0;  -- Division factor for CLKOUT0
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
end mmcm_module_wrapper;

architecture STRUCT of mmcm_module_wrapper is
  ----------------------------------------------------------------------------
  -- Components ( copy from entity )
  ----------------------------------------------------------------------------

  component mmcm_module is
    generic (
      -- base mmcm_adv parameters
      C_BANDWIDTH             : string  := "OPTIMIZED"; 
      C_CLKFBOUT_MULT_F       : real := 1.0;  -- Multiplication factor for all output clocks
      C_CLKFBOUT_PHASE        : real    := 0.0;  -- Phase shift (degrees) of all output clocks
      C_CLKFBOUT_USE_FINE_PS  : boolean := false;
      C_CLKIN1_PERIOD         : real    := 0.000;  -- Clock period (ns) of input clock on CLKIN1
      C_CLKOUT0_DIVIDE_F      : real := 1.0;  -- Division factor for CLKOUT0
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
      C_CLKOUT0_BUF           : boolean := false;
      C_CLKOUT1_BUF           : boolean := false;
      C_CLKOUT2_BUF           : boolean := false;
      C_CLKOUT3_BUF           : boolean := false;
      C_CLKOUT4_BUF           : boolean := false;
      C_CLKOUT5_BUF           : boolean := false;
      C_CLKOUT6_BUF           : boolean := false;
      C_CLOCK_HOLD            : boolean := false;
      C_STARTUP_WAIT          : boolean := false;
      C_EXT_RESET_HIGH        : integer := 1;
      C_FAMILY                : string  := "virtex6"
      );
    port (
      CLKFBOUT         : out std_logic;
      CLKFBOUTB        : out std_logic;
      CLKOUT0          : out std_logic;
      CLKOUT1          : out std_logic;
      CLKOUT2          : out std_logic;
      CLKOUT3          : out std_logic;
      CLKOUT4          : out std_logic;
      CLKOUT5          : out std_logic;
      CLKOUT6          : out std_logic;
      CLKOUT0B         : out std_logic;
      CLKOUT1B         : out std_logic;
      CLKOUT2B         : out std_logic;
      CLKOUT3B         : out std_logic;
      LOCKED           : out std_logic;
      CLKFBSTOPPED     : out std_logic;
      CLKINSTOPPED     : out std_logic;
      PSDONE           : out std_logic;
      CLKFBIN          : in  std_logic;
      CLKIN1           : in  std_logic;
      PWRDWN           : in  std_logic;
      PSCLK            : in  std_logic;
      PSEN             : in  std_logic;
      PSINCDEC         : in  std_logic;
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

  signal CLKOUT0_MMCM : std_logic;
  signal CLKOUT1_MMCM : std_logic;
  signal CLKOUT2_MMCM : std_logic;
  signal CLKOUT3_MMCM : std_logic;
  signal CLKOUT4_MMCM : std_logic;
  signal CLKOUT5_MMCM : std_logic;
  signal CLKOUT6_MMCM : std_logic;

begin

  MMCM_INST : mmcm_module
    generic map (
      -- base pll_adv parameters
      C_BANDWIDTH                => C_BANDWIDTH,
      C_CLKFBOUT_MULT_F          => C_CLKFBOUT_MULT_F,
      C_CLKFBOUT_PHASE           => C_CLKFBOUT_PHASE,
      C_CLKFBOUT_USE_FINE_PS     => C_CLKFBOUT_USE_FINE_PS,
      C_CLKIN1_PERIOD            => C_CLKIN1_PERIOD,
      C_CLKOUT0_DIVIDE_F         => C_CLKOUT0_DIVIDE_F,
      C_CLKOUT0_DUTY_CYCLE       => C_CLKOUT0_DUTY_CYCLE,
      C_CLKOUT0_PHASE            => C_CLKOUT0_PHASE,
      C_CLKOUT1_DIVIDE           => C_CLKOUT1_DIVIDE,
      C_CLKOUT1_DUTY_CYCLE       => C_CLKOUT1_DUTY_CYCLE,
      C_CLKOUT1_PHASE            => C_CLKOUT1_PHASE,
      C_CLKOUT2_DIVIDE           => C_CLKOUT2_DIVIDE,
      C_CLKOUT2_DUTY_CYCLE       => C_CLKOUT2_DUTY_CYCLE,
      C_CLKOUT2_PHASE            => C_CLKOUT2_PHASE,
      C_CLKOUT3_DIVIDE           => C_CLKOUT3_DIVIDE,
      C_CLKOUT3_DUTY_CYCLE       => C_CLKOUT3_DUTY_CYCLE,
      C_CLKOUT3_PHASE            => C_CLKOUT3_PHASE,
      C_CLKOUT4_DIVIDE           => C_CLKOUT4_DIVIDE,
      C_CLKOUT4_DUTY_CYCLE       => C_CLKOUT4_DUTY_CYCLE,
      C_CLKOUT4_PHASE            => C_CLKOUT4_PHASE,
      C_CLKOUT4_CASCADE          => C_CLKOUT4_CASCADE,
      C_CLKOUT5_DIVIDE           => C_CLKOUT5_DIVIDE,
      C_CLKOUT5_DUTY_CYCLE       => C_CLKOUT5_DUTY_CYCLE,
      C_CLKOUT5_PHASE            => C_CLKOUT5_PHASE,
      C_CLKOUT6_DIVIDE           => C_CLKOUT6_DIVIDE,
      C_CLKOUT6_DUTY_CYCLE       => C_CLKOUT6_DUTY_CYCLE,
      C_CLKOUT6_PHASE            => C_CLKOUT6_PHASE,
      C_CLKOUT0_USE_FINE_PS      => C_CLKOUT0_USE_FINE_PS,
      C_CLKOUT1_USE_FINE_PS      => C_CLKOUT1_USE_FINE_PS,
      C_CLKOUT2_USE_FINE_PS      => C_CLKOUT2_USE_FINE_PS,
      C_CLKOUT3_USE_FINE_PS      => C_CLKOUT3_USE_FINE_PS,
      C_CLKOUT4_USE_FINE_PS      => C_CLKOUT4_USE_FINE_PS,
      C_CLKOUT5_USE_FINE_PS      => C_CLKOUT5_USE_FINE_PS,
      C_CLKOUT6_USE_FINE_PS      => C_CLKOUT6_USE_FINE_PS,
      C_COMPENSATION             => C_COMPENSATION,
      C_DIVCLK_DIVIDE            => C_DIVCLK_DIVIDE,
      C_REF_JITTER1              => C_REF_JITTER1,
      C_CLKIN1_BUF               => C_CLKIN1_BUF,
      C_CLKFBOUT_BUF             => C_CLKFBOUT_BUF,
      C_CLKOUT0_BUF              => false,
      C_CLKOUT1_BUF              => false,
      C_CLKOUT2_BUF              => false,
      C_CLKOUT3_BUF              => false,
      C_CLKOUT4_BUF              => false,
      C_CLKOUT5_BUF              => false,
      C_CLKOUT6_BUF              => false,
      C_CLOCK_HOLD               => C_CLOCK_HOLD,
      C_STARTUP_WAIT             => C_STARTUP_WAIT,
      C_EXT_RESET_HIGH           => C_EXT_RESET_HIGH,
      C_FAMILY                   => C_FAMILY
      )
    port map (
      CLKFBOUT                   => CLKFBOUT,
      -- CLKFBOUTB               => 
      CLKOUT0                    => CLKOUT0_MMCM,
      CLKOUT1                    => CLKOUT1_MMCM,
      CLKOUT2                    => CLKOUT2_MMCM,
      CLKOUT3                    => CLKOUT3_MMCM,
      CLKOUT4                    => CLKOUT4_MMCM,  
      CLKOUT5                    => CLKOUT5_MMCM,
      CLKOUT6                    => CLKOUT6_MMCM,
      -- CLKOUT0B                =>  
      -- CLKOUT1B                =>  
      -- CLKOUT2B                =>  
      -- CLKOUT3B                =>  
      LOCKED                     => LOCKED,
      -- CLKFBSTOPPED            => 
      -- CLKINSTOPPED            =>
      PSDONE                     => PSDONE,
      CLKFBIN                    => CLKFBIN,
      CLKIN1                     => CLKIN1,
      PWRDWN                     => '0', -- wrapper setting
      PSCLK                      => PSCLK, 
      PSEN                       => PSEN,
      PSINCDEC                   => PSINCDEC,
      RST                        => RST
      );

  -----------------------------------------------------------------------------
  -- CLKOUT0 
  -----------------------------------------------------------------------------
  CLKOUT0 <= CLKOUT0_MMCM;

  -----------------------------------------------------------------------------
  -- CLKOUT0B 
  -----------------------------------------------------------------------------
  Using_BUFG_for_CLKOUT0 : if (C_CLKOUT0_BUF) generate
    CLKOUT0_BUFG_INST : BUFG
      port map (
        I => CLKOUT0_MMCM,
        O => CLKOUT0B);
  end generate Using_BUFG_for_CLKOUT0;

  No_BUFG_for_CLKOUT0 : if (not C_CLKOUT0_BUF) generate
    CLKOUT0B <= CLKOUT0_MMCM;
  end generate No_BUFG_for_CLKOUT0;

  -----------------------------------------------------------------------------
  -- CLKOUT1 
  -----------------------------------------------------------------------------
  CLKOUT1 <= CLKOUT1_MMCM;

  -----------------------------------------------------------------------------
  -- CLKOUT1B 
  -----------------------------------------------------------------------------
  Using_BUFG_for_CLKOUT1 : if (C_CLKOUT1_BUF) generate
    CLKOUT1_BUFG_INST : BUFG
      port map (
        I => CLKOUT1_MMCM,
        O => CLKOUT1B);
  end generate Using_BUFG_for_CLKOUT1;

  No_BUFG_for_CLKOUT1 : if (not C_CLKOUT1_BUF) generate
    CLKOUT1B <= CLKOUT1_MMCM;
  end generate No_BUFG_for_CLKOUT1;

  -----------------------------------------------------------------------------
  -- CLKOUT2 
  -----------------------------------------------------------------------------
  CLKOUT2 <= CLKOUT2_MMCM;

  -----------------------------------------------------------------------------
  -- CLKOUT2B 
  -----------------------------------------------------------------------------
  Using_BUFG_for_CLKOUT2 : if (C_CLKOUT2_BUF) generate
    CLKOUT2_BUFG_INST : BUFG
      port map (
        I => CLKOUT2_MMCM,
        O => CLKOUT2B);
  end generate Using_BUFG_for_CLKOUT2;

  No_BUFG_for_CLKOUT2 : if (not C_CLKOUT2_BUF) generate
    CLKOUT2B <= CLKOUT2_MMCM;
  end generate No_BUFG_for_CLKOUT2;

  -----------------------------------------------------------------------------
  -- CLKOUT3 
  -----------------------------------------------------------------------------
  CLKOUT3 <= CLKOUT3_MMCM;

  -----------------------------------------------------------------------------
  -- CLKOUT3B 
  -----------------------------------------------------------------------------
  Using_BUFG_for_CLKOUT3 : if (C_CLKOUT3_BUF) generate
    CLKOUT3_BUFG_INST : BUFG
      port map (
        I => CLKOUT3_MMCM,
        O => CLKOUT3B);
  end generate Using_BUFG_for_CLKOUT3;

  No_BUFG_for_CLKOUT3 : if (not C_CLKOUT3_BUF) generate
    CLKOUT3B <= CLKOUT3_MMCM;
  end generate No_BUFG_for_CLKOUT3;

  -----------------------------------------------------------------------------
  -- CLKOUT4 
  -----------------------------------------------------------------------------
  CLKOUT4 <= CLKOUT4_MMCM;

  -----------------------------------------------------------------------------
  -- CLKOUT4B 
  -----------------------------------------------------------------------------
  Using_BUFG_for_CLKOUT4 : if (C_CLKOUT4_BUF) generate
    CLKOUT4_BUFG_INST : BUFG
      port map (
        I => CLKOUT4_MMCM,
        O => CLKOUT4B);
  end generate Using_BUFG_for_CLKOUT4;

  No_BUFG_for_CLKOUT4 : if (not C_CLKOUT4_BUF) generate
    CLKOUT4B <= CLKOUT4_MMCM;
  end generate No_BUFG_for_CLKOUT4;

  -----------------------------------------------------------------------------
  -- CLKOUT5 
  -----------------------------------------------------------------------------
  CLKOUT5 <= CLKOUT5_MMCM;

  -----------------------------------------------------------------------------
  -- CLKOUT5B 
  -----------------------------------------------------------------------------
  Using_BUFG_for_CLKOUT5 : if (C_CLKOUT5_BUF) generate
    CLKOUT5_BUFG_INST : BUFG
      port map (
        I => CLKOUT5_MMCM,
        O => CLKOUT5B);
  end generate Using_BUFG_for_CLKOUT5;

  No_BUFG_for_CLKOUT5 : if (not C_CLKOUT5_BUF) generate
    CLKOUT5B <= CLKOUT5_MMCM;
  end generate No_BUFG_for_CLKOUT5;

  -----------------------------------------------------------------------------
  -- CLKOUT6 
  -----------------------------------------------------------------------------
  CLKOUT6 <= CLKOUT6_MMCM;

  -----------------------------------------------------------------------------
  -- CLKOUT6B 
  -----------------------------------------------------------------------------
  Using_BUFG_for_CLKOUT6 : if (C_CLKOUT6_BUF) generate
    CLKOUT6_BUFG_INST : BUFG
      port map (
        I => CLKOUT6_MMCM,
        O => CLKOUT6B);
  end generate Using_BUFG_for_CLKOUT6;

  No_BUFG_for_CLKOUT6 : if (not C_CLKOUT6_BUF) generate
    CLKOUT6B <= CLKOUT6_MMCM;
  end generate No_BUFG_for_CLKOUT6;

end STRUCT;
