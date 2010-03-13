-------------------------------------------------------------------------------
-- $Id: plb_slave_attachment.vhd,v 1.3 2008/05/13 21:29:18 gburch Exp $
-------------------------------------------------------------------------------
-- PLB Slave attachment entity and architecture
-------------------------------------------------------------------------------
--
--  ***************************************************************************
--  **  Copyright(C) 2006 by Xilinx, Inc. All rights reserved.               **
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
-- Filename:        plb_slave_attachment.vhd
-- Version:         v1_00_a
-- Description:     PLB slave attachment supporting single beat transfers.
--
-------------------------------------------------------------------------------
-- Structure:
--
--              plb_slave_attachment.vhd
--                   |
--                   |- plb_address_decoder.vhd
--
--
-------------------------------------------------------------------------------
-- Author:      <Gary Burch>
--
-- History:
--
--  GAB     8/3/06
-- ~~~~~~
--  - Initial release of v1.00.a
-- ^^^^^^
--  GAB     10/31/06
-- ~~~~~~
--  - Removed integer range from master_id signal decleration to fix issue
--  found during formal verification. This fixes CR424860.
-- ^^^^^^
--  GAB     11/28/06
-- ~~~~~~
--  - Added master_id to sensitiviy list to GENERATE_SL_WRERR and 
--  GENERATE_SL_RDERR processes.  This fixes CR429978.
-- ^^^^^^
--  GAB     12/14/06
-- ~~~~~~
--  - Fixed issue with Point to Point reads when UserIP immediatly ack'ed the
--  read.
-- ^^^^^^
--  GAB     01/03/07
-- ~~~~~~
--  - Qualified assertion warning with ip2bus_rdack and ip2bus_wrack so that
--  warning is only generated if accomponied by a data acknowledge.
-- ^^^^^^
--  GAB     6/22/07
-- ~~~~~~
--  - Changed address_decode family generic to "nofamily" to provide
--  better timing in spartan3 device.  ToDo, only select nofamily if
--  C_FAMILY generic equals spartan3 else pass C_FAMILY.
-- ^^^^^^
--  GAB     7/20/07
-- ~~~~~~
--  - Added dataphase timeout timer.  A timeout will terminate the plb cycle
-- normally (driving zeros during reads) and will remove IPIC signal 
-- assertion.
-- ^^^^^^
--  GAB     7/24/07
-- ~~~~~~
--  - Fixed issue where plb_abus, plb_rnw, and plb_be where not getting
--  sampled and held correctly causing bus2ip_abus, bus2ip_rnw, and bus2ip_be
--  to potentially be inaccurate depending on the PLB bus stimulus.
-- ^^^^^^
--  GAB     8/16/07
-- ~~~~~~
--  - Added generic to include or exclude dataphase timeout timer.
-- ^^^^^^
--  GAB     4/24/08 v1.01.a
-- ~~~~~~
--  - Updated to xps_timer_v1_01_b_proc_common_v3_00_a
-- ^^^^^^
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
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;

library xps_timer_v1_01_b_proc_common_v3_00_a;
use xps_timer_v1_01_b_proc_common_v3_00_a.proc_common_pkg.all;
use xps_timer_v1_01_b_proc_common_v3_00_a.proc_common_pkg.log2;
use xps_timer_v1_01_b_proc_common_v3_00_a.proc_common_pkg.max2;
use xps_timer_v1_01_b_proc_common_v3_00_a.ipif_pkg.all;
use xps_timer_v1_01_b_proc_common_v3_00_a.family_support.all;
use xps_timer_v1_01_b_proc_common_v3_00_a.counter_f;

-- Xilinx Primitive Library
library unisim;
use unisim.vcomponents.all;

library xps_timer_v1_01_b_plbv46_slave_single_v1_01_a;

-------------------------------------------------------------------------------
entity plb_slave_attachment is
    generic (

        C_ARD_ADDR_RANGE_ARRAY  : SLV64_ARRAY_TYPE :=
           (
             X"0000_0000_7000_0000", -- IP user0 base address
             X"0000_0000_7000_00FF", -- IP user0 high address
             X"0000_0000_7000_0100", -- IP user1 base address
             X"0000_0000_7000_01FF"  -- IP user1 high address
           );

        C_ARD_NUM_CE_ARRAY   : INTEGER_ARRAY_TYPE :=
           (
             1,         -- User0 CE Number
             8          -- User1 CE Number
           );
        C_PLB_NUM_MASTERS       : integer := 8;
        C_PLB_MID_WIDTH         : integer := 3;
        C_SPLB_P2P              : integer := 0;
        C_BUS2CORE_CLK_RATIO    : integer := 1;
        C_IPIF_ABUS_WIDTH       : integer := 32;
        C_IPIF_DBUS_WIDTH       : integer := 32;
        C_DPHASE_TIMEOUT        : integer := 64;
        C_INCLUDE_DPHASE_TIMER  : integer := 1;
        C_FAMILY                : string  := "virtex4"
        );
    port(
        --System signals
        Bus_Reset           : in  std_logic;
        Bus_Clk             : in  std_logic;

        -- PLB Bus signals
        PLB_ABus            : in  std_logic_vector(0 to 31);
        PLB_UABus           : in  std_logic_vector(0 to 31);
        PLB_PAValid         : in  std_logic;
        PLB_masterID        : in  std_logic_vector
                                (0 to C_PLB_MID_WIDTH - 1);
        PLB_RNW             : in  std_logic;
        PLB_BE              : in  std_logic_vector
                                (0 to (C_IPIF_DBUS_WIDTH/8) - 1);
        PLB_size            : in  std_logic_vector(0 to 3);
        PLB_type            : in  std_logic_vector(0 to 2);
        PLB_wrDBus          : in  std_logic_vector(0 to C_IPIF_DBUS_WIDTH-1);
        Sl_addrAck          : out std_logic;
        Sl_rearbitrate      : out std_logic;
        Sl_wait             : out std_logic;
        Sl_wrDAck           : out std_logic;
        Sl_wrComp           : out std_logic;
        Sl_rdDBus           : out std_logic_vector(0 to C_IPIF_DBUS_WIDTH-1);
        Sl_rdDAck           : out std_logic;
        Sl_rdComp           : out std_logic;
        Sl_MBusy            : out std_logic_vector(0 to C_PLB_NUM_MASTERS-1);
        Sl_MRdErr           : out std_logic_vector(0 to C_PLB_NUM_MASTERS-1);   
        Sl_MWrErr           : out std_logic_vector(0 to C_PLB_NUM_MASTERS-1);   

        -- Controls to the IP/IPIF modules
        Bus2IP_Addr         : out std_logic_vector(0 to C_IPIF_ABUS_WIDTH-1);
        Bus2IP_RNW          : out std_logic;
        Bus2IP_BE           : out std_logic_vector
                                (0 to (C_IPIF_DBUS_WIDTH/8) - 1);
        Bus2IP_CS           : out std_logic_vector(0 to 
                                ((C_ARD_ADDR_RANGE_ARRAY'LENGTH)/2) - 1);
        Bus2IP_RdCE         : out std_logic_vector
                                (0 to calc_num_ce(C_ARD_NUM_CE_ARRAY) - 1);
        Bus2IP_WrCE         : out std_logic_vector
                                (0 to calc_num_ce(C_ARD_NUM_CE_ARRAY) - 1);

        -- Write Data bus output to the IP/IPIF modules
        Bus2IP_Data         : out std_logic_vector (0 to C_IPIF_DBUS_WIDTH-1);

        --Inputs from the Read Data Bus Mux
        IP2Bus_Data         : in  std_logic_vector (0 to C_IPIF_DBUS_WIDTH-1);

        -- Inputs from the Status Reply Mux
        IP2Bus_WrAck        : in  std_logic;
        IP2Bus_RdAck        : in  std_logic;
        IP2Bus_Error        : in  std_logic

       
    );
end entity plb_slave_attachment;

-------------------------------------------------------------------------------
architecture implementation of plb_slave_attachment is

-------------------------------------------------------------------------------
-- Function Declarations
-------------------------------------------------------------------------------
  -------------------------------------------------------------------
  -- Function
  --
  -- Function Name: check_to_value
  --
  -- Function Description:
  --  This function makes sure a minimum timeout value is passed to
  -- the WDT logic for the Data Phase timeout if the User specifies
  -- one that is too small. Currently, this is minimum is 8 clocks.
  --
  -------------------------------------------------------------------
  function check_to_value (timeout_value: integer) return integer is

     Constant MIN_VALUE_ALLOWED : integer := 8; -- 8 PLB clocks
     Variable to_value : Integer;

  begin

-- removed for code coverage
-- timeout_value is hardcoded in top level
--     if (timeout_value < MIN_VALUE_ALLOWED) then
--       to_value :=  MIN_VALUE_ALLOWED;
--     else
       to_value := timeout_value;
--     end if;

     return(to_value);

  end function check_to_value;

-------------------------------------------------------------------------------
-- Constant Declarations
-------------------------------------------------------------------------------

constant CS_BUS_SIZE    : integer := C_ARD_ADDR_RANGE_ARRAY'length/2;
constant CE_BUS_SIZE    : integer := calc_num_ce(C_ARD_NUM_CE_ARRAY);

-- Total number of possible address bits (32 for ABUS + 32 for UABUS)
constant TTL_AWIDTH     : integer := 64;

-------------------------------------------------------------------------------
-- Signal and Type Declarations
-------------------------------------------------------------------------------

-- Intermediate Slave Reply output signals (to PLB)
signal sl_addrack_i             : std_logic;
signal sl_rearbitrate_i         : std_logic;
signal sl_wait_i                : std_logic;
signal sl_wrdack_i              : std_logic;
signal sl_wrcomp_i              : std_logic;
signal sl_rddbus_i              : std_logic_vector(0 to C_IPIF_DBUS_WIDTH-1);
signal sl_rddack_i              : std_logic;
signal sl_rdcomp_i              : std_logic;
signal sl_mbusy_i               : std_logic_vector(0 to C_PLB_NUM_MASTERS-1);
signal sl_mrderr_i              : std_logic_vector(0 to C_PLB_NUM_MASTERS-1);
signal sl_mwrerr_i              : std_logic_vector(0 to C_PLB_NUM_MASTERS-1);

signal addr_cycle_flush         : std_logic;

-- PLB Read State Machine
signal sl_rddack_ns             : std_logic;
signal sl_rdcomp_ns             : std_logic;
signal sl_rearbitrate_ns        : std_logic;
signal sl_wait_ns               : std_logic;
signal clear_rd_ce              : std_logic;
signal rd_ce_ld_enable          : std_logic;
signal clear_sl_rd_busy         : std_logic;
signal clear_sl_rd_busy_ns      : std_logic;

-- PLB Write State Machine
signal sl_wrdack_ns             : std_logic;
signal sl_wrcomp_ns             : std_logic;

-- Registered PLB input signals
signal plb_abus_reg             : std_logic_vector(0 to C_IPIF_ABUS_WIDTH-1);
signal plb_abus_early           : std_logic_vector(0 to C_IPIF_ABUS_WIDTH-1);
signal plb_pavalid_reg          : std_logic;
signal plb_masterid_reg         : std_logic_vector(0 to C_PLB_MID_WIDTH -1);
signal plb_rnw_reg              : std_logic;
signal plb_be_reg               : std_logic_vector(0 to (C_IPIF_DBUS_WIDTH/8)-1);
signal plb_size_reg             : std_logic_vector(0 to 3);
signal plb_type_reg             : std_logic_vector(0 to 2);
signal plb_wrdbus_reg           : std_logic_vector(0 to C_IPIF_DBUS_WIDTH-1);

-- Intermediate IPIC signals
signal bus2ip_data_i            : std_logic_vector(0 to C_IPIF_DBUS_WIDTH-1);
signal bus2ip_addr_i            : std_logic_vector(0 to C_IPIF_ABUS_WIDTH-1);
signal bus2ip_rnw_i             : std_logic;
signal bus2ip_be_i              : std_logic_vector(0 to C_IPIF_DBUS_WIDTH/8-1);

-- new internal signals
signal master_id                : integer;
signal start_data_phase         : std_logic;
signal data_ack                 : std_logic;
signal sl_data_ack              : std_logic;

-- Combined transfer validation signals
signal valid_request            : std_logic;
signal valid_plb_size           : boolean;
signal valid_plb_type           : boolean;
signal do_the_cmd               : std_logic;

-- Combined decoder signals
signal address_match            : std_logic;
signal address_match_early      : std_logic;
signal decode_cs_ce_clr         : std_logic;
signal decode_ld_rw_ce          : std_logic;
signal decode_clr_rw_ce         : std_logic;
signal decode_s_h_cs            : std_logic;
signal decode_cs_clr            : std_logic;
signal bus2ip_cs_i              : std_logic_vector(0 to CS_BUS_SIZE-1);
signal bus2ip_rdce_i            : std_logic_vector(0 to CE_BUS_SIZE-1);
signal bus2ip_wrce_i            : std_logic_vector(0 to CE_BUS_SIZE-1);


signal set_sl_busy              : std_logic;
signal clear_sl_busy            : std_logic;
signal sl_busy                  : std_logic;

signal addr_cycle_flush_ns      : std_logic;
signal addr_cntr_load_en        : std_logic;

signal clear_sl_busy_ns         : std_logic;

signal ip2bus_wrack_i           : std_logic;
signal ip2bus_rdack_i           : std_logic;
signal ip2bus_data_i            : std_logic_vector(0 to C_IPIF_DBUS_WIDTH-1);
signal ip2bus_error_i           : std_logic;

signal rd_clear_sl_busy         : std_logic;
signal wr_clear_sl_busy         : std_logic;
signal data_timeout             : std_logic; -- GAB 7/20/07
-------------------------------------------------------------------------------
-- begin the architecture logic
-------------------------------------------------------------------------------
begin

-- synthesis translate_off

-------------------------------------------------------------------------------
-- REPORT_WARNINGS
-- This process is used only during simulation to generate user warnings.
-------------------------------------------------------------------------------
REPORT_WARNINGS : process (bus_clk)

variable newline            : Character := cr;
variable report_inhibit_cnt : integer := 5; -- 5 Bus_Clk clocks

begin

    if (Bus_clk'event and Bus_clk = '1') then

        -- Inhibit warnings during sim initialization
        if (report_inhibit_cnt = 0) then
            null; -- stop down count
        else
            report_inhibit_cnt := report_inhibit_cnt-1;
        end if;


        if (Bus_Reset = '1' or report_inhibit_cnt > 0 
        or (ip2bus_rdack_i='0' and ip2bus_wrack_i='0') ) then
            null; -- do nothing
        else
            Assert (ip2bus_error_i = '0')
            Report "Addressed target asserted Error signal!"
            Severity warning;
            
            Assert (data_timeout = '0')
            Report "Data phase timeout assertion....  Addressed Target did not respond!"
            Severity warning;

        end if;
    end if;
end process REPORT_WARNINGS;

-- synthesis translate_on


-------------------------------------------------------------------------------
-- Misc. Logic Assignments

-- PLB Output port connections
Sl_addrAck       <= sl_addrack_i        ;
Sl_rearbitrate   <= sl_rearbitrate_i    ;
Sl_wait          <= sl_wait_i           ;
Sl_wrDAck        <= sl_wrdack_i         ;
Sl_wrComp        <= sl_wrcomp_i         ;
Sl_rdDBus        <= sl_rddbus_i         ;
Sl_rdDAck        <= sl_rddack_i         ;
Sl_rdComp        <= sl_rdcomp_i         ;
Sl_MBusy         <= sl_mbusy_i          ;
Sl_MRdErr        <= sl_mrderr_i         ;
Sl_MWrErr        <= sl_mwrerr_i         ;

-- IPIF output signals
Bus2IP_Addr      <= bus2ip_addr_i       ;
Bus2IP_RNW       <= bus2ip_rnw_i        ;
Bus2IP_BE        <= bus2ip_be_i         ;
Bus2IP_Data      <= bus2ip_data_i       ;
Bus2IP_CS        <= bus2ip_cs_i         ;
Bus2IP_RdCE      <= bus2ip_rdce_i       ;
Bus2IP_WrCE      <= bus2ip_wrce_i       ;


------------------------------------------------------------------------------
-- Dual Clock Support
------------------------------------------------------------------------------
DUAL_CLOCK_SUPPORT : if C_BUS2CORE_CLK_RATIO /= 1 generate
signal ip2bus_wrack_d1          : std_logic;
signal ip2bus_rdack_d1          : std_logic;
signal ip2bus_wrack_d2          : std_logic;
signal ip2bus_rdack_d2          : std_logic;
signal ip2bus_wrack_strb        : std_logic;
signal ip2bus_rdack_strb        : std_logic;
signal ip2bus_data_d1           : std_logic_vector(0 to C_IPIF_DBUS_WIDTH-1);
signal ip2bus_error_d1          : std_logic;
begin
    -- Register to sync with bus clock.  This is only valid
    -- if the core clock is slower than the bus clock and
    -- is edge synchronous with bus clock.
    REG_IPIC_IN : process(Bus_clk)
        begin
            if(Bus_Clk'EVENT and Bus_Clk='1')then
                if(Bus_Reset = '1')then
                    ip2bus_wrack_d1 <= '0';
                    ip2bus_wrack_d2 <= '0';
                    ip2bus_rdack_d1 <= '0';
                    ip2bus_rdack_d2 <= '0';
                    ip2bus_data_d1  <= (others => '0');
                    ip2bus_error_d1 <= '0';
                else
                    ip2bus_wrack_d1 <= IP2Bus_WrAck;
                    ip2bus_wrack_d2 <= ip2bus_wrack_d1;
                    ip2bus_rdack_d1 <= IP2Bus_RdAck;
                    ip2bus_rdack_d2 <= ip2bus_rdack_d1;
                    ip2bus_data_d1  <= IP2Bus_Data;
                    ip2bus_error_d1 <= IP2Bus_Error;
                end if;
            end if;
        end process REG_IPIC_IN;
                    
    -- generate edge detect off of wrack and rdack
    ip2bus_wrack_strb <= ip2bus_wrack_d1 and not ip2bus_wrack_d2;
    ip2bus_rdack_strb <= ip2bus_rdack_d1 and not ip2bus_rdack_d2;

    
    ip2bus_wrack_i  <= ip2bus_wrack_strb or (data_timeout and not bus2ip_rnw_i);
    ip2bus_rdack_i  <= ip2bus_rdack_strb or (data_timeout and bus2ip_rnw_i);
    ip2bus_data_i   <= ip2bus_data_d1;
    ip2bus_error_i  <= ip2bus_error_d1;

end generate DUAL_CLOCK_SUPPORT;


SINGLE_CLOCK_SUPPORT : if C_BUS2CORE_CLK_RATIO = 1 generate
    ip2bus_wrack_i  <= IP2Bus_WrAck or (data_timeout and not bus2ip_rnw_i);
    ip2bus_rdack_i  <= IP2Bus_RdAck or (data_timeout and bus2ip_rnw_i);
    ip2bus_data_i   <= IP2Bus_Data;
    ip2bus_error_i  <= IP2Bus_Error;
end generate SINGLE_CLOCK_SUPPORT;


-------------------------------------------------------------------------------
-- Register PLB Inputs
-- Register all PLB input signals
-------------------------------------------------------------------------------
REG_PLB_INPUTS : Process (Bus_clk)
   begin
      if (Bus_clk'EVENT and Bus_clk = '1')  then
         if (Bus_reset = '1') Then
            plb_be_reg          <= (others => '0')  ;
            plb_wrdbus_reg      <= (others => '0')  ;
            plb_masterid_reg    <= (others => '0')  ;
            plb_rnw_reg         <= '0'              ;
            plb_size_reg        <= (others => '0')  ;
            plb_type_reg        <= (others => '0')  ;
         else
            -- Register these signals continously
            plb_wrdbus_reg      <=  PLB_wrDBus      ;
            plb_be_reg          <=  PLB_BE          ;
            plb_masterid_reg    <=  PLB_masterID    ;
            plb_rnw_reg         <=  PLB_RNW         ;
            plb_size_reg        <=  PLB_size        ;
            plb_type_reg        <=  PLB_type        ;

         end if;
      end if;
   end process REG_PLB_INPUTS;

REG_PAVALID : process(Bus_clk)
    begin
        if (Bus_clk'EVENT and Bus_clk = '1')  then
            if (Bus_reset = '1' or addr_cycle_flush = '1') Then
                plb_pavalid_reg     <= '0'              ;
            else
                plb_pavalid_reg     <=  PLB_PAValid;
            end if;
        end if;
    end process REG_PAVALID;
    
-------------------------------------------------------------------------------
-- Concatinate Address buses for PLB AWIDTH's greater than 32 bits
-------------------------------------------------------------------------------
GEN_GRTR_THAN_32_ADDR : if C_IPIF_ABUS_WIDTH > 32 generate

    REG_ADDR_INPUT : process(Bus_Clk)
        begin
            if(Bus_Clk'EVENT and Bus_Clk = '1')then
                if(Bus_Reset = '1')then
                    plb_abus_reg    <= (others => '0');
                else
                    plb_abus_reg    <=  PLB_UABUS(TTL_AWIDTH-C_IPIF_ABUS_WIDTH
                                                    to  (TTL_AWIDTH/2)-1)
                                        & PLB_ABus;
                end if;
            end if;
        end process REG_ADDR_INPUT;

    plb_abus_early  <= PLB_UABUS(TTL_AWIDTH-C_IPIF_ABUS_WIDTH
                                                    to  (TTL_AWIDTH/2)-1)
                                        & PLB_ABus;

end generate GEN_GRTR_THAN_32_ADDR;
                    
-------------------------------------------------------------------------------
-- Simply pass input address bus to out for PLB AWIDTH's equal to 32 bits
-------------------------------------------------------------------------------
GEN_EQL_TO_32_ADDR : if C_IPIF_ABUS_WIDTH = 32 generate

    REG_ADDR_INPUT : process(Bus_Clk)
        begin
            if(Bus_Clk'EVENT and Bus_Clk = '1')then
                if(Bus_Reset = '1')then
                    plb_abus_reg    <= (others => '0');
                else
                    plb_abus_reg    <=  PLB_ABus;
                end if;
            end if;
        end process REG_ADDR_INPUT;
    
    plb_abus_early <=  PLB_ABus;

end generate GEN_EQL_TO_32_ADDR;

--------------------------------------------------------------------------------
---- Access Validation
---- This combinatorial process validates the PLB request attributes that are
---- supported by this slave.
--------------------------------------------------------------------------------
VALIDATE_REQUEST : process (plb_pavalid_reg,plb_size_reg,plb_type_reg)
    begin
        if (plb_pavalid_reg = '1')          -- Address Request
        and (plb_size_reg="0000")           -- and a valid plb_size
        and (plb_type_reg="000") then       -- and a memory xfer
            valid_request <= '1';
        else
            valid_request <= '0';
        end if;
  end process VALIDATE_REQUEST;

------------------------------------------------------------------------------
-- Address Decoder Component Instance
--
-- This component decodes the specified base address pairs and outputs the
-- specified number of chip enables and the target bus size.
------------------------------------------------------------------------------
I_DECODER : entity xps_timer_v1_01_b_plbv46_slave_single_v1_01_a.plb_address_decoder
    generic map
    (
        C_BUS_AWIDTH            => C_IPIF_ABUS_WIDTH        ,
        C_ARD_ADDR_RANGE_ARRAY  => C_ARD_ADDR_RANGE_ARRAY   ,
        C_ARD_NUM_CE_ARRAY      => C_ARD_NUM_CE_ARRAY       ,
        C_SPLB_P2P              => C_SPLB_P2P               ,
-- GAB 6/22/07 modified to provide better timing in spartan3 devices,
-- carry chain logic in spartan is slow
--        C_FAMILY                => C_FAMILY
        C_FAMILY                => "nofamily"
    )
    port map
    (
      Bus_clk            =>  Bus_clk                        ,
      Bus_rst            =>  Bus_reset                      ,

      -- PLB Interface signals
      Address_In         =>  plb_abus_reg                   ,
      Address_In_Erly    =>  plb_abus_early                 ,
      Address_Valid      =>  plb_pavalid_reg                ,
      Address_Valid_Erly =>  PLB_PAValid                    ,
      Bus_RNW            =>  plb_rnw_reg                    ,
      Bus_RNW_Erly       =>  PLB_RNW                        ,
      -- Registering control signals
      cs_sample_hold_n   =>  decode_s_h_cs                  ,
      cs_sample_hold_clr =>  decode_cs_clr                  ,
      CS_CE_ld_enable    =>  Addr_cntr_load_en              ,
      Clear_CS_CE_Reg    =>  decode_cs_ce_clr               ,
      RW_CE_ld_enable    =>  decode_ld_rw_ce                ,
      Clear_RW_CE_Reg    =>  decode_clr_rw_ce               ,
      Clear_addr_match   =>  addr_cycle_flush               ,

      -- Decode output signals
      Addr_Match_early   =>  address_match_early            ,
      Addr_Match         =>  address_match                  ,
      CS_Out             =>  Bus2IP_CS_i                    ,
      RdCE_Out           =>  Bus2IP_RdCE_i                  ,
      WrCE_Out           =>  Bus2IP_WrCE_i
      );

-------------------------------------------------------------------------------
-- Generate Address Phase Control State Machine for a Shared PLB configuration.
-------------------------------------------------------------------------------
GEN_FOR_SHARED : if C_SPLB_P2P = 0 generate
type PLB_ADDR_CNTRL_STATES is (
                    VALIDATE_REQ,
                    WAIT_ONE_CLOCK
                    );
signal addr_cntl_cs             : PLB_ADDR_CNTRL_STATES;
signal addr_cntl_ns             : PLB_ADDR_CNTRL_STATES;
signal rearbitrate_condition    : std_logic;
signal sl_addrack_i_ns          : std_logic;
signal set_sl_busy_ns           : std_logic;

begin
    decode_s_h_cs       <=  not(sl_busy)
                            or (address_match and clear_sl_busy);

    decode_cs_clr       <=  clear_sl_busy; 
                         --   and not(address_match);

    decode_ld_rw_ce     <= set_sl_busy;

    Addr_cntr_load_en   <= set_sl_busy;


    -- detect a command execute condition and set a flag if it exists
    do_the_cmd              <=  valid_request
                            and address_match_early
                            and not(sl_busy);

    -- Rearbitrate if another address hit occurs and slave is busy
    rearbitrate_condition   <=  valid_request       
                            and address_match_early
                            and sl_busy             
                            and not(clear_sl_busy);

    ------------------------------------------------------------------------------
    -- Address Controller State Machine
    -- This state machine controls the validation and address acknowledge
    -- of the incoming PLB bus requests. The local Slave
    -- Attachment decoder will reply with an address match signal should
    -- the incoming address match the assigned address ranges.
    ------------------------------------------------------------------------------
    ADDRESS_CONTROLLER : Process (addr_cntl_cs,do_the_cmd,rearbitrate_condition)
        begin
            sl_addrack_i_ns             <= '0';
            addr_cycle_flush_ns         <= '0';
            sl_rearbitrate_ns           <= '0';
            addr_cntl_ns                <= VALIDATE_REQ;

            case addr_cntl_cs is

                when VALIDATE_REQ =>
                       -- Rearbitrate condition
                    if (rearbitrate_condition = '1') Then 
                        sl_rearbitrate_ns           <= '1';
                        addr_cycle_flush_ns         <= '1';
                        addr_cntl_ns                <= WAIT_ONE_CLOCK;

                    -- Do the command
                    elsif (do_the_cmd = '1') then
                       sl_addrack_i_ns              <= '1';
                       addr_cycle_flush_ns          <= '1';
                       addr_cntl_ns                 <= WAIT_ONE_CLOCK;
                    else
                       addr_cntl_ns    <= VALIDATE_REQ;
                    end if;

                when WAIT_ONE_CLOCK =>
                    addr_cntl_ns    <= VALIDATE_REQ;
--coverage off
                when others   =>
                    addr_cntl_ns    <= VALIDATE_REQ;
--coverage on
            end case;
        end process ADDRESS_CONTROLLER;
    
    -- Register Address Controller States
    REG_STATES_PROCESS : process(Bus_Clk)
        begin
            if(Bus_Clk'EVENT and Bus_Clk = '1')then
                if(Bus_Reset = '1')then
                    addr_cntl_cs        <= VALIDATE_REQ;
                else
                    addr_cntl_cs        <= addr_cntl_ns;
                end if;
            end if;
        end process REG_STATES_PROCESS;

    -- Register Address Controller Signals
    REG_STATE_SIGNALS : process(Bus_Clk)
        begin
            if(Bus_Clk'EVENT and Bus_Clk = '1')then
                if(Bus_Reset = '1')then
                    sl_addrack_i        <= '0'                      ;
                    sl_rearbitrate_i    <= '0'                      ;
                    set_sl_busy         <= '0'                      ;
                    addr_cycle_flush    <= '0'                      ;
                else
                    sl_addrack_i        <= sl_addrack_i_ns          ;
                    sl_rearbitrate_i    <= sl_rearbitrate_ns        ;
                    set_sl_busy         <= sl_addrack_i_ns          ;
                    addr_cycle_flush    <= addr_cycle_flush_ns      ;
                end if;
            end if;
        end process REG_STATE_SIGNALS;

    -- Always inactive in a shared bus configuration
    sl_wait_i                  <= '0';

end generate GEN_FOR_SHARED;

-------------------------------------------------------------------------------
-- Generate Address Phase Control State Machine for a Point 2 Point PLB
-- configuration.
-------------------------------------------------------------------------------
GEN_FOR_P2P : if C_SPLB_P2P = 1 generate

type PLB_ADDR_CNTRL_STATES is ( VALIDATE_REQ,
                                GEN_WAIT,
                                GEN_ADDRACK
                                );

signal addr_cntl_cs             : PLB_ADDR_CNTRL_STATES;
signal addr_cntl_ns             : PLB_ADDR_CNTRL_STATES;
signal end_busy                 : std_logic;
signal wait_condition           : std_logic;
signal wait_state               : std_logic;

begin
    decode_s_h_cs       <=  not(sl_busy)
                            or (address_match_early and clear_sl_busy);

    decode_cs_clr       <=  clear_sl_busy; 
                       --     and not(PLB_PAValid);


    -- detect a command execute condition and set a flag if it exists
    do_the_cmd              <=  PLB_PAValid
                            and not(sl_busy);

    --- detect a wait condition and set a flag if it exists
    wait_condition          <=  PLB_PAValid
                            and sl_busy; 

    ------------------------------------------------------------------------------
    -- Address Controller State Machine
    -- This state machine controls the validation and address acknowledge
    -- of the incoming PLB bus requests. The local Slave
    -- Attachment decoder will reply with an address match signal should
    -- the incoming address match the assigned address ranges.
    ------------------------------------------------------------------------------
    ADDRESS_CONTROLLER : Process (addr_cntl_cs,do_the_cmd,wait_condition,
                                    end_busy)
        begin
            addr_cycle_flush_ns         <= '0';
            sl_wait_ns                  <= '0';
            wait_state                  <= '0';
            addr_cntl_ns                <= addr_cntl_cs;


            -- States
            case addr_cntl_cs is

                when VALIDATE_REQ =>
                       -- Wait condition
                    if (wait_condition = '1') Then 
                        sl_wait_ns                  <= '1';
                        addr_cycle_flush_ns         <= '1';
                        addr_cntl_ns                <= GEN_WAIT;

                    -- Do the command
                    elsif (do_the_cmd = '1') then
                        addr_cycle_flush_ns         <= '1';
                        addr_cntl_ns                <= GEN_ADDRACK;
                    end if;

                when GEN_WAIT =>
                    wait_state                      <= '1';
                    if (end_busy = '1') then
                        addr_cycle_flush_ns         <= '1';
                        addr_cntl_ns                <= GEN_ADDRACK;

                    else
                        sl_wait_ns                  <= '1';

                    end if;

                when GEN_ADDRACK =>
                    addr_cntl_ns    <= VALIDATE_REQ;

--coverage off
                when others   =>
                    addr_cntl_ns    <= VALIDATE_REQ;
--coverage on
            end case;
        end process ADDRESS_CONTROLLER;

    -- Register Address Controller states    
    REG_STATES_PROCESS : process(Bus_Clk)
        begin
            if(Bus_Clk'EVENT and Bus_Clk = '1')then
                if(Bus_Reset = '1')then
                    addr_cntl_cs        <= VALIDATE_REQ;
                else
                    addr_cntl_cs        <= addr_cntl_ns;
                end if;
            end if;
        end process REG_STATES_PROCESS;

    -- Register Address Controller signals
    REG_STATE_SIGNALS : process(Bus_Clk)
        begin
            if(Bus_Clk'EVENT and Bus_Clk = '1')then
                if(Bus_Reset = '1')then
                    addr_cycle_flush    <= '0';
                    end_busy            <= '0';
                else
                    addr_cycle_flush    <= addr_cycle_flush_ns      ;
                    end_busy            <= clear_sl_busy;
                end if;
            end if;
        end process REG_STATE_SIGNALS;


    -- Drive combinatorially in a Point2Point configuration
--    set_sl_busy             <= '1' when (PLB_PAValid='1' and wait_condition = '0')
--                                     or (end_busy='1' and wait_state='1')
--                         else  '0';

    set_sl_busy             <= '1' when (do_the_cmd='1')
                                     or (end_busy='1' and wait_state='1')
                         else  '0';

                            
    sl_addrack_i            <= set_sl_busy;
    sl_wait_i               <= sl_wait_ns;
    Addr_cntr_load_en       <= set_sl_busy;
    decode_ld_rw_ce         <= set_sl_busy;
    
    -- Always inactive in a Point2Point configuration
    sl_rearbitrate_i    <= '0';

end generate GEN_FOR_P2P;

------------------------------------------------------------------------------
-- Register Master ID
-- This process controls the registering of the PLB Master ID signals
------------------------------------------------------------------------------
REGISTER_MID : process (Bus_clk)
    begin
        if (Bus_clk'EVENT and Bus_clk = '1') Then
            if (Bus_reset = '1') Then
                master_id         <= 0;
            elsif (decode_s_h_cs = '1') Then
                master_id         <= to_integer(unsigned(plb_masterid_reg));
            end if;
        end if;
    end process REGISTER_MID;

------------------------------------------------------------------------------
-- Generate the Slave Busy
-- This process controls the registering and output of the Slave Busy signals
-- onto the PLB Bus.
------------------------------------------------------------------------------
GENERATE_SL_BUSY : process (Bus_clk)
    begin
        if (Bus_clk'EVENT and Bus_clk = '1') Then
                if (Bus_reset = '1' or clear_sl_busy='1') then
                    sl_busy         <= '0';
                elsif (set_sl_busy = '1') Then
                    sl_busy         <= '1';
                end if;
            end if;
    end process GENERATE_SL_BUSY;

GEN_SL_MBUSY : process(Bus_clk)
    begin
        if (Bus_clk'EVENT and Bus_clk = '1') Then
            for i in 0 to C_PLB_NUM_MASTERS - 1 loop
                if (Bus_reset = '1' or clear_sl_busy = '1') then
                    sl_mbusy_i      <= (others => '0');
                -- Set specific busy bit for req master
                elsif (i=master_id and set_sl_busy = '1') Then
                    sl_mbusy_i(i)   <= '1';  
                end if;
            end loop;
        end if;
    end process GEN_SL_MBUSY;


------------------------------------------------------------------------------
-- Generate the Slave Error Reply
-- This process controls the registering and output of the Slave MRdErr signals
-- onto the PLB Bus.
------------------------------------------------------------------------------
GENERATE_SL_RDERR : process (Bus_clk)
    begin
        if (Bus_clk'EVENT and Bus_clk = '1') Then
            for i in 0 to C_PLB_NUM_MASTERS - 1 loop
                if (Bus_reset = '1') Then
                    sl_mrderr_i(i) <= '0';
                elsif (master_id = i
                and ip2bus_rdack_i = '1') Then
                    sl_mrderr_i(i) <= ip2bus_error_i;
                else
                    sl_mrderr_i(i) <= '0'; -- no error
                end if;
            end loop;
        end if;
    end process GENERATE_SL_RDERR;

GEN_ERROR_SHARED : if C_SPLB_P2P = 0 generate

    ------------------------------------------------------------------------------
    -- Generate the Slave Error Reply
    -- This process controls the registering and output of the Slave MRdErr signals
    -- onto the PLB Bus.
    ------------------------------------------------------------------------------
    GENERATE_SL_WRERR : process (Bus_clk)
        begin
            if (Bus_clk'EVENT and Bus_clk = '1') Then
                for i in 0 to C_PLB_NUM_MASTERS - 1 loop
                    if (Bus_reset = '1') Then
                        sl_mwrerr_i(i) <= '0';
                    elsif (master_id = i 
                    and ip2bus_wrack_i = '1') Then
                        sl_mwrerr_i(i) <= ip2bus_error_i;
                    else
                        sl_mwrerr_i(i) <= '0'; -- no error
                    end if;
                end loop;
            end if;
        end process GENERATE_SL_WRERR;
end generate GEN_ERROR_SHARED;

GEN_ERROR_P2P : if C_SPLB_P2P = 1 generate
--    ------------------------------------------------------------------------------
--    -- Generate the Slave Error Reply
--    -- This process controls the registering and output of the Slave MRdErr signals
--    -- onto the PLB Bus.
--    ------------------------------------------------------------------------------
--    GENERATE_SL_RDERR : process (ip2bus_rdack_i,ip2bus_error_i,master_id)
--        begin
--            for i in 0 to C_PLB_NUM_MASTERS - 1 loop
--                if (master_id = i
--                and ip2bus_rdack_i = '1') Then
--                    sl_mrderr_i(i) <= ip2bus_error_i;
--                else
--                    sl_mrderr_i(i) <= '0'; -- no error
--                end if;
--            end loop;
--        end process GENERATE_SL_RDERR;

    ------------------------------------------------------------------------------
    -- Generate the Slave Error Reply
    -- This process controls the registering and output of the Slave MRdErr signals
    -- onto the PLB Bus.
    ------------------------------------------------------------------------------
    GENERATE_SL_WRERR : process (ip2bus_wrack_i,ip2bus_error_i,master_id)
        begin
            for i in 0 to C_PLB_NUM_MASTERS - 1 loop
                if (master_id = i 
                and ip2bus_wrack_i = '1') Then
                    sl_mwrerr_i(i) <= ip2bus_error_i;
                else
                    sl_mwrerr_i(i) <= '0'; -- no error
                end if;
            end loop;
        end process GENERATE_SL_WRERR;
end generate GEN_ERROR_P2P;

------------------------------------------------------------------------------
-- Create the load enables and clears for the address decoder for
-- non-burst support operation mode
------------------------------------------------------------------------------

decode_clr_rw_ce  <=  data_ack;

decode_cs_ce_clr  <=  data_ack;

-------------------------------------------------------------------------------
-- Data Phase Support
------------------------------------------------------------------------------

start_data_phase    <=  set_sl_busy;

data_ack            <=  ip2bus_rdack_i    -- Read acknowledge
                     or ip2bus_wrack_i;   -- Write acknowledge


clear_sl_busy       <= rd_clear_sl_busy or wr_clear_sl_busy;

-------------------------------------------------------------------------------
--  DATA_CONTROLLER
-- This process handles the data phase or the plb cycle
-------------------------------------------------------------------------------
GEN_DATACNTRL_FOR_SHARED : if C_SPLB_P2P = 0 generate
    REG_WRITE_CONTROL : process (bus_clk)
        begin
            if (Bus_Clk'event and Bus_Clk = '1') then
                if (Bus_reset = '1') then
                    sl_wrdack_i         <= '0'                  ;
                    sl_wrcomp_i         <= '0'                  ;
                    wr_clear_sl_busy    <= '0'                  ;
                else
                    sl_wrdack_i         <= ip2bus_wrack_i       ;
                    sl_wrcomp_i         <= ip2bus_wrack_i       ;
                    wr_clear_sl_busy    <= ip2bus_wrack_i       ;

                end if;
            end if;
        end process REG_WRITE_CONTROL;

    Bus2IP_Data_i     <=  plb_wrdbus_reg ;

end generate GEN_DATACNTRL_FOR_SHARED;

GEN_DATACNTRL_FOR_P2P : if C_SPLB_P2P = 1 generate

    Bus2IP_Data_i       <= PLB_wrDBus             ;
    sl_wrdack_i         <= ip2bus_wrack_i         ;
    sl_wrcomp_i         <= ip2bus_wrack_i         ;
    wr_clear_sl_busy    <= ip2bus_wrack_i         ;
end generate GEN_DATACNTRL_FOR_P2P;

REG_READ_CONTROL : process (bus_clk)
    begin
        if (Bus_Clk'event and Bus_Clk = '1') then
            if (Bus_reset = '1') then
                rd_clear_sl_busy    <= '0'                  ;
                sl_rddack_i         <= '0'                  ;
                sl_rdcomp_i         <= '0'                  ;
            else
                rd_clear_sl_busy    <= ip2bus_rdack_i       ;
                sl_rddack_i         <= ip2bus_rdack_i       ;
                sl_rdcomp_i         <= ip2bus_rdack_i       ;

            end if;
        end if;
    end process REG_READ_CONTROL;

READ_DATA_REGISTER : process (Bus_clk)
    begin

        if (Bus_clk'EVENT and Bus_clk = '1') then
            if (Bus_reset = '1') then
                sl_rddbus_i <= (others => '0');
            elsif (ip2bus_rdack_i = '1' and data_timeout ='0') then
                sl_rddbus_i <= ip2bus_data_i;
            else
                sl_rddbus_i <= (others => '0');
            end if;
        end if;
    end process READ_DATA_REGISTER;

-------------------------------------------------------------------------------
-- Sample and hold the transfer qualifer signals to be output to the IPIF
-- during the data phase of a bus transfer. In single only mode, these
-- qualifiers are cleared upon the recept of the data acknowledge from the
-- target or a data phase timeout occurs.
-------------------------------------------------------------------------------
GEN_XFER_QUAL_SHRD : if C_SPLB_P2P = 0 generate
    S_AND_H_XFER_QUAL : process (Bus_clk)
        begin
            if (Bus_clk'EVENT and Bus_clk = '1') then
                if (Bus_reset = '1' or data_ack = '1') then
                    bus2ip_rnw_i            <= '0';
                    bus2ip_be_i             <= (others => '0');
                    bus2ip_addr_i           <= (others => '0');
                elsif (Addr_cntr_load_en = '1') then
                    bus2ip_rnw_i            <=  plb_rnw_reg;
                    bus2ip_be_i             <=  plb_be_reg;
                    bus2ip_addr_i           <=  plb_abus_reg;
                end if;
            end if;
        end process S_AND_H_XFER_QUAL;
end generate GEN_XFER_QUAL_SHRD;

GEN_XFER_QUAL_P2P : if C_SPLB_P2P = 1 generate
    S_AND_H_XFER_QUAL : process (Bus_clk)
        begin
            if (Bus_clk'EVENT and Bus_clk = '1') then
                if (Bus_reset = '1' or data_ack = '1') then
                    bus2ip_rnw_i            <= '0';
                    bus2ip_be_i             <= (others => '0');
                    bus2ip_addr_i           <= (others => '0');
                elsif (Addr_cntr_load_en = '1') then
                    bus2ip_rnw_i            <=  PLB_RNW;
                    bus2ip_be_i             <=  PLB_BE;
                    bus2ip_addr_i           <=  plb_abus_early;
                end if;
            end if;
        end process S_AND_H_XFER_QUAL;

end generate GEN_XFER_QUAL_P2P;


--/////////////////////////////////////////////////////////////////////////////
------------------------------------------------------------
-- if Generate
--
-- Label: OMIT_DATA_PHASE_WDT
--
-- if Generate Description:
--  This ifGEN omits the dataphase watchdog timeout function.
--
--
------------------------------------------------------------
 OMIT_DATA_PHASE_WDT : if (C_DPHASE_TIMEOUT = 0 or C_INCLUDE_DPHASE_TIMER = 0) generate


   begin

       data_timeout  <= '0';


   end generate OMIT_DATA_PHASE_WDT;
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\



--/////////////////////////////////////////////////////////////////////////////
------------------------------------------------------------
-- if Generate
--
-- Label: INCLUDE_DATA_PHASE_WDT
--
-- if Generate Description:
--  This ifGEN implements the dataphase watchdog timeout
-- function. The counter is allowed to count down when an active
-- IPIF operation is ongoing. A data acknowledge from the target
-- address space forces the counter to reload.
--
--
------------------------------------------------------------
 INCLUDE_DATA_PHASE_WDT : if (C_DPHASE_TIMEOUT > 0 and C_INCLUDE_DPHASE_TIMER = 1) generate


    constant TIMEOUT_VALUE_TO_USE : integer := check_to_value(C_DPHASE_TIMEOUT);
    constant COUNTER_WIDTH  : Integer := log2(TIMEOUT_VALUE_TO_USE-2)+1;
    constant DPTO_LD_VALUE  : std_logic_vector(COUNTER_WIDTH-1 downto 0)
                              := std_logic_vector(to_unsigned(TIMEOUT_VALUE_TO_USE-2,
                                                       COUNTER_WIDTH));
    signal dpto_cntr_ld_en  : std_logic;

    signal dpto_cnt_en      : std_logic;

    signal timeout_i        : std_logic;

   begin


    dpto_cntr_ld_en <= '1'
      when  sl_busy        = '0'
      else  data_ack;

    dpto_cnt_en <= '1'; -- always enabled, load suppresses counting



    I_DPTO_COUNTER : entity xps_timer_v1_01_b_proc_common_v3_00_a.counter_f
      generic map(
        C_NUM_BITS    =>  COUNTER_WIDTH,     --: Integer := 9
        C_FAMILY      => "nofamily"          -- set to "no family" to force inferred logic.
          )
      port map(
        Clk           =>  bus_clk,          --: in  std_logic;
        Rst           =>  '0',              --: in  std_logic;
        Load_In       =>  DPTO_LD_VALUE,    --: in  std_logic_vector(C_NUM_BITS - 1 downto 0);
        Count_Enable  =>  dpto_cnt_en,      --: in  std_logic;
        Count_Load    =>  dpto_cntr_ld_en,  --: in  std_logic;
        Count_Down    =>  '1',              --: in  std_logic;
        Count_Out     =>  open,             --: out std_logic_vector(C_NUM_BITS - 1 downto 0);
        Carry_Out     =>  timeout_i         --: out std_logic
        );
    REG_TIMEOUT : process(bus_clk)
        begin
            if(bus_clk'EVENT and bus_clk='1')then
                if(Bus_reset='1')then
                    data_timeout <= '0';
                else
                    data_timeout <= timeout_i;
                end if;
            end if;
        end process REG_TIMEOUT;


    end generate INCLUDE_DATA_PHASE_WDT;
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- end of Combined HDL
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\










end implementation;
