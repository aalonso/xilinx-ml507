-------------------------------------------------------------------------------
-- plbv46_slave.vhd -  Version v1.00a
-------------------------------------------------------------------------------
--  ***************************************************************************
--  ** DISCLAIMER OF LIABILITY                                               **
--  **                                                                       **
--  **  This text/file contains proprietary, confidential                    **
--  **  information of Xilinx, Inc., is distributed under                    **
--  **  license from Xilinx, Inc., and may be used, copied                   **
--  **  and/or disclosed only pursuant to the terms of a valid               **
--  **  license agreement with Xilinx, Inc. Xilinx hereby                    **
--  **  grants you a license to use this text/file solely for                **
--  **  design, simulation, implementation and creation of                   **
--  **  design files limited to Xilinx devices or technologies.              **
--  **  Use with non-Xilinx devices or technologies is expressly             **
--  **  prohibited and immediately terminates your license unless            **
--  **  covered by a separate agreement.                                     **
--  **                                                                       **
--  **  Xilinx is providing this design, code, or information                **
--  **  "as-is" solely for use in developing programs and                    **
--  **  solutions for Xilinx devices, with no obligation on the              **
--  **  part of Xilinx to provide support. By providing this design,         **
--  **  code, or information as one possible implementation of               **
--  **  this feature, application or standard, Xilinx is making no           **
--  **  representation that this implementation is free from any             **
--  **  claims of infringement. You are responsible for obtaining            **
--  **  any rights you may require for your implementation.                  **
--  **  Xilinx expressly disclaims any warranty whatsoever with              **
--  **  respect to the adequacy of the implementation, including             **
--  **  but not limited to any warranties or representations that this       **
--  **  implementation is free from claims of infringement, implied          **
--  **  warranties of merchantability or fitness for a particular            **
--  **  purpose.                                                             **
--  **                                                                       **
--  **  Xilinx products are not intended for use in life support             **
--  **  appliances, devices, or systems. Use in such applications is         **
--  **  expressly prohibited.                                                **
--  **                                                                       **
--  **  Any modifications that are made to the Source Code are               **
--  **  done at the user’s sole risk and will be unsupported.                **
--  **  The Xilinx Support Hotline does not have access to source            **
--  **  code and therefore cannot answer specific questions related          **
--  **  to source HDL. The Xilinx Hotline support of original source         **
--  **  code IP shall only address issues and questions related              **
--  **  to the standard Netlist version of the core (and thus                **
--  **  indirectly, the original core source).                               **
--  **                                                                       **
--  **  Copyright (c) 2008 Xilinx, Inc. All rights reserved.                 **
--  **                                                                       **
--  **  This copyright and support notice must be retained as part           **
--  **  of this text at all times.                                           **
--  ***************************************************************************
-------------------------------------------------------------------------------
-- Filename:        plbv46_slave_single.vhd
-- Version:         v1_00_a
-- Description:     This is the top level design file for the plbv46_slave_single
--                  function. It provides a standardized slave interface
--                  between the IP and the PLB Bus. This version supports
--                  single beat transfers only.  It does not provide address
--                  pipelining or simultaneous read and write operations.
--
-------------------------------------------------------------------------------
-- Structure:
--                  plbv46_slave_single
--                  |
--                  |-plb_slave_attachment
--                    |
--                    |-plb_address_decoder
--
-------------------------------------------------------------------------------
-- BEGIN_CHANGELOG EDK_J
--
--  Initial release of plbv46_slave_single_v1_00_a
--
-- END_CHANGELOG
-------------------------------------------------------------------------------
-- BEGIN_CHANGELOG EDK_J_SP1
--
-- Fixed issue with addr_out_s_h
--
-- END_CHANGELOG
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- BEGIN_CHANGELOG EDK_Jm
--
-- Modified generic defaults and ranges to match specification
--
-- Added Dataphase timeout timer.
--
-- END_CHANGELOG
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- BEGIN_CHANGELOG EDK_K_SP3
--
--  Updated to use xps_timer_v1_01_b_proc_common_v3_00_a library.  This is the
--  intial version 1.01.a.
--
-- END_CHANGELOG
-------------------------------------------------------------------------------
-- Author:      <Gary Burch>
--
-- History:
--
--  GAB     8/3/06
-- ~~~~~~
--  - Initial release of v1.00.a
-- ^^^^^^
--  GAB     8/3/06
-- ~~~~~~
--  - Initial release of v1.00.a
-- ^^^^^^
--  GAB     6/1/07
-- ~~~~~~
--  - Modified generic defaults and ranges to match specification
-- ^^^^^^
--  GAB     7/13/07
-- ~~~~~~
--  - Fixed issue where plb address was not getting sampled correctly in
-- the point to point mode under certain conditions.  Modified
-- plb_address_decoder.vhd
-- ^^^^^^
--  GAB     7/20/07
-- ~~~~~~
--  - Added dataphase timeout timer.  A timeout will terminate the plb cycle
-- normally (driving zeros during reads) and will remove IPIC signal
-- assertion.  Timeout value is set via a constant in this file.
-- ^^^^^^
--  GAB     7/24/07
-- ~~~~~~
--  - Fixed issue where plb_abus, plb_rnw, and plb_be where not getting
--  sampled and held correctly causing bus2ip_abus, bus2ip_rnw, and bus2ip_be
--  to potentially be inaccurate depending on the PLB bus stimulus.
--  Modified plb_slave_attachment.vhd
--  - Fixed issue where wrong signal was being used to reset wrce in
--  BKEND_WRCE_REG process for p2p mode. Modified plb_address_decoder.vhd
-- ^^^^^^
--  GAB     8/16/07
-- ~~~~~~
--  - Added generic to include or exclude dataphase timeout timer.
-- ^^^^^^
--  GAB     4/24/08     v1.01.a
-- ~~~~~~
--  - Updated to xps_timer_v1_01_b_proc_common_v3_00_a
-- ^^^^^^
--  GAB     5/13/08
-- ~~~~~~
--  - Incorperated modifications for code coverage
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
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

library xps_timer_v1_01_b_proc_common_v3_00_a;
use xps_timer_v1_01_b_proc_common_v3_00_a.proc_common_pkg.all;
use xps_timer_v1_01_b_proc_common_v3_00_a.proc_common_pkg.log2;
use xps_timer_v1_01_b_proc_common_v3_00_a.proc_common_pkg.max2;
use xps_timer_v1_01_b_proc_common_v3_00_a.family_support.all;
use xps_timer_v1_01_b_proc_common_v3_00_a.ipif_pkg.all;
use xps_timer_v1_01_b_proc_common_v3_00_a.or_gate128;

library unisim;
use unisim.vcomponents.all;

library xps_timer_v1_01_b_plbv46_slave_single_v1_01_a;
use xps_timer_v1_01_b_plbv46_slave_single_v1_01_a.all;

-------------------------------------------------------------------------------

entity plbv46_slave_single is
    generic (

        C_ARD_ADDR_RANGE_ARRAY      : SLV64_ARRAY_TYPE :=
            -- Base address and high address pairs.
            (
             X"0000_0000_7000_0000", -- IP user0 base address
             X"0000_0000_7000_00FF", -- IP user0 high address
             X"0000_0000_7000_0100", -- IP user1 base address
             X"0000_0000_7000_01FF"  -- IP user1 high address
            );

        C_ARD_NUM_CE_ARRAY          : INTEGER_ARRAY_TYPE :=
            -- This array spcifies the number of Chip Enables (CE) that is
            -- required by the cooresponding baseaddr pair.
            (
             1,         -- User0 CE Number
             8          -- User1 CE Number
            );


        C_SPLB_P2P                  : integer range 0 to 1 := 0;
            -- Optimize slave interface for a point to point connection

        C_BUS2CORE_CLK_RATIO        : integer range 1 to 2 := 1;
            -- Specifies the clock ratio from BUS to Core allowing
            -- the core to operate at a slower than the bus clock rate
            -- A value of 1 represents 1:1 and a value of 2 represents
            -- 2:1 where the bus clock is twice as fast as the core
            -- clock.

        C_INCLUDE_DPHASE_TIMER      : integer range 0 to 1 := 1;
            -- Include or exclude the data phase timeout timer
            -- 0 = exclude data phase timeout timer
            -- 1 = include data phase timeout timer

        C_SPLB_MID_WIDTH            : integer range 1 to 4:= 2;
            -- The width of the Master ID bus
            -- This is set to log2(C_SPLB_NUM_MASTERS)

        C_SPLB_NUM_MASTERS          : integer range 1 to 16 := 8;
            -- The number of Master Devices connected to the PLB bus
            -- Research this to find out default value

        C_SPLB_AWIDTH               : integer range 32 to 32  := 32;
            --  width of the PLB Address Bus (in bits)

        C_SPLB_DWIDTH               : integer range 32 to 128 := 32;
            --  Width of the PLB Data Bus (in bits)

        C_SIPIF_DWIDTH               : integer range 32 to 32  := 32;
            --  Width of IPIF Data Bus (in bits)

        C_FAMILY                    : string := "virtex4"
            -- Select the target architecture type
            -- see the family.vhd package in the proc_common
            -- library
           );
    port (

    -- System signals ---------------------------------------------------------

        SPLB_Clk                : in std_logic;

        SPLB_Rst                : in std_logic;

    -- Bus Slave signals ------------------------------------------------------

        PLB_ABus                : in  std_logic_vector(0 to 31);

        PLB_UABus               : in  std_logic_vector(0 to 31);

        PLB_PAValid             : in  std_logic;

        PLB_SAValid             : in  std_logic;

        PLB_rdPrim              : in  std_logic;

        PLB_wrPrim              : in  std_logic;

        PLB_masterID            : in  std_logic_vector(0 to C_SPLB_MID_WIDTH-1);

        PLB_abort               : in  std_logic;

        PLB_busLock             : in  std_logic;

        PLB_RNW                 : in  std_logic;

        PLB_BE                  : in  std_logic_vector(0 to
                                                     (C_SPLB_DWIDTH/8) - 1);

        PLB_MSize               : in  std_logic_vector(0 to 1);

        PLB_size                : in  std_logic_vector(0 to 3);

        PLB_type                : in  std_logic_vector(0 to 2);

        PLB_lockErr             : in  std_logic;

        PLB_wrDBus              : in  std_logic_vector(0 to
                                                       C_SPLB_DWIDTH-1);

        PLB_wrBurst             : in  std_logic;

        PLB_rdBurst             : in  std_logic;

        PLB_wrPendReq           : in  std_logic;

        PLB_rdPendReq           : in  std_logic;

        PLB_wrPendPri           : in  std_logic_vector(0 to 1);

        PLB_rdPendPri           : in  std_logic_vector(0 to 1);

        PLB_reqPri              : in  std_logic_vector(0 to 1);

        PLB_TAttribute          : in  std_logic_vector(0 to 15);


        -- Slave Responce Signals
        Sl_addrAck              : out std_logic;

        Sl_SSize                : out std_logic_vector(0 to 1);

        Sl_wait                 : out std_logic;

        Sl_rearbitrate          : out std_logic;

        Sl_wrDAck               : out std_logic;

        Sl_wrComp               : out std_logic;

        Sl_wrBTerm              : out std_logic;

        Sl_rdDBus               : out std_logic_vector(0 to
                                                       C_SPLB_DWIDTH-1);

        Sl_rdWdAddr             : out std_logic_vector(0 to 3);

        Sl_rdDAck               : out std_logic;

        Sl_rdComp               : out std_logic;

        Sl_rdBTerm              : out std_logic;

        Sl_MBusy                : out std_logic_vector
                                    (0 to C_SPLB_NUM_MASTERS-1);

        Sl_MWrErr               : out std_logic_vector
                                    (0 to C_SPLB_NUM_MASTERS-1);

        Sl_MRdErr               : out std_logic_vector
                                    (0 to C_SPLB_NUM_MASTERS-1);

        Sl_MIRQ                 : out std_logic_vector
                                    (0 to C_SPLB_NUM_MASTERS-1);

    -- IP Interconnect (IPIC) port signals -----------------------------------------
        Bus2IP_Clk              : out std_logic;

        Bus2IP_Reset            : out std_logic;
        IP2Bus_Data             : in  std_logic_vector
                                    (0 to C_SIPIF_DWIDTH - 1 );

        IP2Bus_WrAck            : in  std_logic;

        IP2Bus_RdAck            : in  std_logic;

        IP2Bus_Error            : in  std_logic;


        Bus2IP_Addr             : out std_logic_vector
                                    (0 to C_SPLB_AWIDTH - 1 );

        Bus2IP_Data             : out std_logic_vector
                                    (0 to C_SIPIF_DWIDTH - 1 );

        Bus2IP_RNW              : out std_logic;

        Bus2IP_BE               : out std_logic_vector
                                    (0 to (C_SIPIF_DWIDTH/8) - 1 );

        Bus2IP_CS               : Out std_logic_vector
                                    (0 to ((C_ARD_ADDR_RANGE_ARRAY'LENGTH)/2)-1);

        Bus2IP_RdCE             : out std_logic_vector
                                    (0 to calc_num_ce(C_ARD_NUM_CE_ARRAY)-1);

        Bus2IP_WrCE             : out std_logic_vector
                                    (0 to calc_num_ce(C_ARD_NUM_CE_ARRAY)-1)

       );

end plbv46_slave_single;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------

architecture implementation of plbv46_slave_single is

-------------------------------------------------------------------------------
-- Function Declarations
-- (also see ipif_pkg and proc_common_pkg for other functions)
-------------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Function set_ssize
--
-- This function is used to set the value of size based
-- on the size of the input bus width parameter.
-----------------------------------------------------------------------------
function set_ssize (bus_width : integer) return integer is

   Variable size : Integer := 0;

begin

   case bus_width is
     when 32 =>
         size := 0;
--coverage off
     when 64 =>
         size := 1;
     when 128 =>
         size := 2;
     when 256 =>
         size := 3;
     when others =>
         size := 0;
--coverage on
   end case;

   return(size);

end function set_ssize;

-------------------------------------------------------------------------------
-- Constant Declarations
-------------------------------------------------------------------------------

-- The integer value of the encoded PLB Bus size to be returned
-- on the Sl_Ssize output bus.
constant SSIZE_RESPONSE : integer := set_ssize(C_SIPIF_DWIDTH);


-- Unconstrained generic array size calculations
constant NUM_BASEADDRS        : integer := (C_ARD_ADDR_RANGE_ARRAY'LENGTH)/2;
constant NUM_CE               : integer := calc_num_ce(C_ARD_NUM_CE_ARRAY);


-- Dataphase timeout value, a value of zero will remove the timer.
constant DPHASE_TIMEOUT       : integer := 128;

-------------------------------------------------------------------------------
-- Signal and Type Declarations
-------------------------------------------------------------------------------
signal sl_addrack_i           : std_logic;
signal sl_ssize_i             : std_logic_vector(0 to 1);
signal sl_wrdack_i            : std_logic;
signal sl_wrcomp_i            : std_logic;
signal sl_rddbus_i            : std_logic_vector(0 to C_SIPIF_DWIDTH-1);
signal sl_rddack_i            : std_logic;
signal sl_rdcomp_i            : std_logic;
signal sl_rearbitrate_i       : std_logic;
signal sl_wait_i              : std_logic;
signal sl_mbusy_i             : std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);
signal sl_mrderr_i            : std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);
signal sl_mwrerr_i            : std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);

signal bus2ip_addr_i          : std_logic_vector(0 to C_SPLB_AWIDTH - 1);
signal bus2ip_be_i            : std_logic_vector(0 to C_SIPIF_DWIDTH/8 - 1);
signal bus2ip_data_i          : std_logic_vector(0 to C_SIPIF_DWIDTH - 1);
signal bus2ip_rnw_i           : std_logic;
signal bus2ip_cs_i            : std_logic_vector(0 to NUM_BASEADDRS-1);
signal bus2ip_rdce_i          : std_logic_vector(0 to NUM_CE-1);
signal bus2ip_wrce_i          : std_logic_vector(0 to NUM_CE-1);
signal plb_be_muxed           : std_logic_vector(0 to C_SIPIF_DWIDTH/8 - 1);

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin

Sl_MIRQ         <= (others => '0');

-------------------------------------------------------------------------------
-- Mux/Steer data/be's correctly for connect 64-bit slave to 128-bit plb
-------------------------------------------------------------------------------
GEN_128_TO_64_SLAVE : if C_SIPIF_DWIDTH = 64 and C_SPLB_DWIDTH = 128 generate

    ---------------------------------------------------------------------------
    -- BE Mux - For addresses 0x0 to 0x7 use PLB_BE's 0 to 7
    --          For addresses 0x8 to 0xF use PLB_BE's 8 to 15
    ---------------------------------------------------------------------------
    MUX_BE_PROCESS : process(PLB_BE,PLB_ABus)
        begin
            -- If address offset is
            -- between 0x8 and 0xF then map upper BE's to lower bytelanes.
            if(PLB_ABus(28) = '1')then
                plb_be_muxed <= PLB_BE(8 to 15);

            -- If address offset is
            -- between 0x0 and 0x7 then map lower BE's to lower bytelanes
            else
                plb_be_muxed <= PLB_BE(0 to 7);
            end if;
        end process MUX_BE_PROCESS;

    ---------------------------------------------------------------------------
    -- Map lower rd data to upper and lower halves of plb slave read bus
    ---------------------------------------------------------------------------
    Sl_rdDBus(0 to 63)      <=  sl_rddbus_i(0 to C_SIPIF_DWIDTH-1);
    Sl_rdDBus(64 to 127)    <=  sl_rddbus_i(0 to C_SIPIF_DWIDTH-1);

end generate GEN_128_TO_64_SLAVE;

-------------------------------------------------------------------------------
-- Mux/Steer data/be's correctly for connect 32-bit slave to 128-bit plb
-------------------------------------------------------------------------------
GEN_128_TO_32_SLAVE : if C_SIPIF_DWIDTH = 32 and C_SPLB_DWIDTH = 128 generate
signal be_select   : std_logic_vector(0 to 1);

    begin
        be_select <= PLB_ABus(28 to 29);

        -----------------------------------------------------------------------
        -- BE Mux - For addresses 0x0 to 0x3 use PLB_BE's 0 to 3
        --          For addresses 0x4 to 0x7 use PLB_BE's 4 to 7
        --          For addresses 0x8 to 0xB use PLB_BE's 8 to 11
        --          For addresses 0xC to 0xF use PLB_BE's 12 to 15
        -----------------------------------------------------------------------
        MUX_BE_PROCESS : process(PLB_BE,be_select)
            begin
                case be_select is
                    when "00" =>    -- Addresses 0, 1, 2, to 3
                        plb_be_muxed <= PLB_BE(0 to 3);

                    when "01" =>    -- Addresses 4, 5, 6, to 7
                        plb_be_muxed <= PLB_BE(4 to 7);

                    when "10" =>    -- Addresses 8, 9, A, to B
                        plb_be_muxed <= PLB_BE(8 to 11);

                    when "11" =>    -- Addresses C, D, E, to F
                        plb_be_muxed <= PLB_BE(12 to 15);

                    when others =>
                        plb_be_muxed <= PLB_BE(0 to 3);
                end case;

            end process MUX_BE_PROCESS;

        -----------------------------------------------------------------------
        -- Map lower rd data to each quarter of the plb slave read bus
        -----------------------------------------------------------------------
        Sl_rdDBus(0 to 31)      <=  sl_rddbus_i(0 to C_SIPIF_DWIDTH-1);

        Sl_rdDBus(32 to 63)     <=  sl_rddbus_i(0 to C_SIPIF_DWIDTH-1);

        Sl_rdDBus(64 to 95)     <=  sl_rddbus_i(0 to C_SIPIF_DWIDTH-1);

        Sl_rdDBus(96 to 127)    <=  sl_rddbus_i(0 to C_SIPIF_DWIDTH-1);

end generate GEN_128_TO_32_SLAVE;

-------------------------------------------------------------------------------
-- Mux/Steer data/be's correctly for connect 32-bit slave to 64-bit plb
-------------------------------------------------------------------------------
GEN_64_TO_32_SLAVE : if C_SIPIF_DWIDTH = 32 and C_SPLB_DWIDTH = 64 generate
    begin

    ---------------------------------------------------------------------------
    -- BE Mux - For addresses 0x0 to 0x3 use PLB_BE's 0 to 3
    --          For addresses 0x4 to 0x7 use PLB_BE's 4 to 7
    ---------------------------------------------------------------------------
    MUX_BE_PROCESS : process(PLB_BE,PLB_ABus)
        begin
            -- If address offset is
            -- between 0x4 and 0x7 then map upper BE's to lower bytelanes
            if(PLB_ABus(29) = '1' )then
                plb_be_muxed <= PLB_BE(4 to 7);

            -- If transfer type is burst or address offset is
            -- between 0x0 and 0x3 then map lower BE's to lower bytelanes
            else
                plb_be_muxed <= PLB_BE(0 to 3);
            end if;

        end process MUX_BE_PROCESS;

    ---------------------------------------------------------------------------
    -- Map lower rd data to upper and lower halves of plb slave read bus
    ---------------------------------------------------------------------------
    Sl_rdDBus(0 to 31)      <=  sl_rddbus_i(0 to C_SIPIF_DWIDTH-1);
    Sl_rdDBus(32 to 63)     <=  sl_rddbus_i(0 to C_SIPIF_DWIDTH-1);

end generate GEN_64_TO_32_SLAVE;

-------------------------------------------------------------------------------
-- IPIF DWidth = PLB DWidth
-- If IPIF Slave Data width is equal to the PLB Bus Data Width
-- Then BE and Read Data Bus map directly to eachother.
-------------------------------------------------------------------------------
GEN_FOR_EQUAL_SLAVE : if C_SIPIF_DWIDTH = C_SPLB_DWIDTH generate

    plb_be_muxed <= PLB_BE;
    Sl_rdDBus    <= sl_rddbus_i;

end generate GEN_FOR_EQUAL_SLAVE;

-------------------------------------------------------------------------------
-- Slave Attachment
-------------------------------------------------------------------------------

I_SLAVE_ATTACHMENT:  entity xps_timer_v1_01_b_plbv46_slave_single_v1_01_a.plb_slave_attachment
    generic map(
        C_ARD_ADDR_RANGE_ARRAY    => C_ARD_ADDR_RANGE_ARRAY           ,
        C_ARD_NUM_CE_ARRAY        => C_ARD_NUM_CE_ARRAY               ,
        C_SPLB_P2P                => C_SPLB_P2P                       ,
        C_BUS2CORE_CLK_RATIO      => C_BUS2CORE_CLK_RATIO             ,
        C_PLB_NUM_MASTERS         => C_SPLB_NUM_MASTERS               ,
        C_PLB_MID_WIDTH           => C_SPLB_MID_WIDTH                 ,
        C_IPIF_ABUS_WIDTH         => C_SPLB_AWIDTH                    ,
        C_IPIF_DBUS_WIDTH         => C_SIPIF_DWIDTH                   ,
        C_DPHASE_TIMEOUT          => DPHASE_TIMEOUT                   ,
        C_INCLUDE_DPHASE_TIMER    => C_INCLUDE_DPHASE_TIMER           ,
        C_FAMILY                  => C_FAMILY
    )
    port map(
        --System signals
        Bus_Reset             =>  SPLB_Rst                            ,
        Bus_Clk               =>  SPLB_Clk                            ,

        -- PLB Bus signals
        PLB_ABus              =>  PLB_ABus                            ,
        PLB_UABus             =>  PLB_UABus                           ,
        PLB_PAValid           =>  PLB_PAValid                         ,
        PLB_masterID          =>  PLB_masterID                        ,
        PLB_RNW               =>  PLB_RNW                             ,
        PLB_BE                =>  plb_be_muxed                        ,
        PLB_size              =>  PLB_size                            ,
        PLB_type              =>  PLB_type                            ,
        PLB_wrDBus            =>  PLB_wrDBus(0 to C_SIPIF_DWIDTH-1)   ,

        Sl_addrAck            =>  sl_addrack_i                        ,
        Sl_rearbitrate        =>  sl_rearbitrate_i                    ,
        Sl_wait               =>  sl_wait_i                           ,
        Sl_wrDAck             =>  sl_wrdack_i                         ,
        Sl_wrComp             =>  sl_wrcomp_i                         ,
        Sl_rdDBus             =>  sl_rddbus_i                         ,
        Sl_rdDAck             =>  sl_rddack_i                         ,
        Sl_rdComp             =>  sl_rdcomp_i                         ,
        Sl_MBusy              =>  sl_mbusy_i                          ,
        Sl_MRdErr             =>  sl_mrderr_i                         ,
        Sl_MWrErr             =>  sl_mwrerr_i                         ,

        Bus2IP_Addr           =>  bus2ip_addr_i                       ,
        Bus2IP_RNW            =>  bus2ip_rnw_i                        ,
        Bus2IP_BE             =>  bus2ip_be_i                         ,
        Bus2IP_CS             =>  bus2ip_cs_i                         ,
        Bus2IP_RdCE           =>  bus2ip_rdce_i                       ,
        Bus2IP_WrCE           =>  bus2ip_wrce_i                       ,
        Bus2IP_Data           =>  bus2ip_data_i                       ,

        --Read Data Inputs from the Byte Steering Block
        IP2Bus_Data           =>  IP2Bus_Data                         ,
        IP2Bus_WrAck          =>  IP2Bus_WrAck                        ,
        IP2Bus_RdAck          =>  IP2Bus_RdAck                        ,
        IP2Bus_Error          =>  IP2Bus_Error
    );

-------------------------------------------------------------------------------
-- Misc logic assignments

Sl_addrAck                <= sl_addrack_i    ;
Sl_SSize                  <= sl_ssize_i      ;
Sl_wait                   <= sl_wait_i       ;
Sl_rearbitrate            <= sl_rearbitrate_i;
Sl_wrDAck                 <= sl_wrdack_i     ;
Sl_wrComp                 <= sl_wrcomp_i     ;
Sl_wrBTerm                <= '0'             ;
Sl_rdWdAddr               <= (others => '0') ;
Sl_rdDAck                 <= sl_rddack_i     ;
Sl_rdComp                 <= sl_rdcomp_i     ;
Sl_rdBTerm                <= '0'             ;
Sl_MBusy                  <= sl_mbusy_i      ;
Sl_MRdErr                 <= sl_mrderr_i     ;
Sl_MWrErr                 <= sl_mwrerr_i     ;
sl_ssize_i                <= std_logic_vector(to_unsigned(SSIZE_RESPONSE,2));

Bus2IP_RNW                <= bus2ip_rnw_i;
Bus2IP_Addr               <= bus2ip_addr_i;
Bus2IP_Data               <= bus2ip_data_i(0 to C_SIPIF_DWIDTH-1);
Bus2IP_BE                 <= bus2ip_be_i;
Bus2IP_CS                 <= bus2ip_cs_i;
Bus2IP_RdCE               <= bus2ip_rdce_i;
Bus2IP_WrCE               <= bus2ip_wrce_i;
Bus2IP_Clk                <= SPLB_Clk;
Bus2IP_Reset              <= SPLB_Rst;



end implementation;
