-------------------------------------------------------------------------------
-- xps_timer - entity/architecture pair
-------------------------------------------------------------------------------
--
-- ***************************************************************************
-- DISCLAIMER OF LIABILITY
--
-- This file contains proprietary and confidential information of
-- Xilinx, Inc. ("Xilinx"), that is distributed under a license
-- from Xilinx, and may be used, copied and/or disclosed only
-- pursuant to the terms of a valid license agreement with Xilinx.
--
-- XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION
-- ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
-- EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT
-- LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,
-- MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx
-- does not warrant that functions included in the Materials will
-- meet the requirements of Licensee, or that the operation of the
-- Materials will be uninterrupted or error-free, or that defects
-- in the Materials will be corrected. Furthermore, Xilinx does
-- not warrant or make any representations regarding use, or the
-- results of the use, of the Materials in terms of correctness,
-- accuracy, reliability or otherwise.
--
-- Xilinx products are not designed or intended to be fail-safe,
-- or for use in any application requiring fail-safe performance,
-- such as life-support or safety devices or systems, Class III
-- medical devices, nuclear facilities, applications related to
-- the deployment of airbags, or any other applications that could
-- lead to death, personal injury or severe property or
-- environmental damage (individually and collectively, "critical
-- applications"). Customer assumes the sole risk and liability
-- of any use of Xilinx products in critical applications,
-- subject only to applicable laws and regulations governing
-- limitations on product liability.
--
-- Copyright 2001, 2002, 2003, 2004, 2008, 2009 Xilinx, Inc.
-- All rights reserved.
--
-- This disclaimer and copyright notice must be retained as part
-- of this file at all times.
-- ***************************************************************************
--
-------------------------------------------------------------------------------
-- Filename        :xps_timer.vhd
-- Company         :Xilinx
-- Version         :v1.01.b
-- Description     :Timer/Counter for PLB bus
-- Standard        :VHDL-93
-------------------------------------------------------------------------------
-- Structure:   This section shows the hierarchical structure of xps_timer.
--
--              xps_timer.vhd
--                 --plbv46_slave_single.vhd
--                    --plb_slave_attachment.vhd
--                       --plb_address_decoder.vhd
--                 --common_types_pkg.vhd
--                 --family.vhd
--                 --tc_types.vhd
--                 --tc_core.vhd
--                    --mux_onehot_f.vhd
--                      --family_support.vhd     
--                     --timer_control.vhd
--                     --count_module.vhd
--                        --counter_f.vhd
--                        --family_support.vhd     
--                                 
--                 
-------------------------------------------------------------------------------
-- Author:      AT
-- History:
-- AT             9/28/2006      
--     Initial release of v1.00.a
-- ^^^^^^
-- Author:      BSB
-- History:
--  AT     07/05/2009      -- Ceated the version  v1.01.b
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
--      combinatorial signals:                  "*_cmb"
--      pipelined or register delay signals:    "*_d#"
--      counter signals:                        "*cnt*"
--      clock enable signals:                   "*_ce"
--      internal version of output port         "*_i"
--      device pins:                            "*_pin"
--      ports:                                  - Names begin with Uppercase
--      processes:                              "*_PROCESS"
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--                     Definition of Generics
-------------------------------------------------------------------------------
-- C_BASEADDR               -- User logic base address
-- C_HIGHADDR               -- User logic high address
-- C_SPLB_AWIDTH            -- PLB address bus width
-- C_SPLB_DWIDTH            -- PLB data bus width
-- C_FAMILY                 -- Default family
-- C_SPLB_P2P               -- Selects point-to-point or shared plb topology
-- C_SPLB_MID_WIDTH         -- PLB Master ID Bus Width
-- C_SPLB_NUM_MASTERS       -- Number of PLB Masters
-- C_SPLB_SUPPORT_BURSTS    -- Include Burst support
-- C_SPLB_NATIVE_DWIDTH     -- Width of the slave data bus
-------------------------------------------------------------------------------

-- C_COUNT_WIDTH            -- Width in the bits of the counter
-- C_ONE_TIMER_ONLY         -- Number of the Timer 
-- C_TRIG0_ASSERT           -- Assertion Level of captureTrig0  
-- C_TRIG1_ASSERT           -- Assertion Level of captureTrig1  
-- C_GEN0_ASSERT            -- Assertion Level for GenerateOut0
-- C_GEN1_ASSERT            -- Assertion Level for GenerateOut1

-------------------------------------------------------------------------------
--                  Definition of Ports
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- SPLB_Clk             -- PLB Clock  
-- SPLB_Rst             -- PLB Reset
-------------------------------------------------------------------------------
-- PLB_ABus             -- Each master is required to provide a valid 32-bit
--                      -- address when its request signal is asserted. The PLB
--                      -- will then arbitrate the requests and allow the highest
--                      -- priority master’s address to be gated onto the PLB_ABus
-- PLB_PAValid          -- This signal is asserted by the PLB arbiter in response
--                      -- to the assertion of Mn_request and to indicate
--                      -- that there is a valid primary address and transfer
--                      -- qualifiers on the PLB outputs
-- PLB_masterID         -- These signals indicate to the slaves the identification
--                      -- of the master of the current transfer
-- PLB_RNW              -- This signal is driven by the master and is used to
--                      -- indicate whether the request is for a read or a write
--                      -- transfer
-- PLB_BE               -- These signals are driven by the master. For a non-line
--                      -- and non-burst transfer they identify which
--                      -- bytes of the target being addressed are to be read
--                      -- from or written to. Each bit corresponds to a byte
--                      -- lane on the read or write data bus
-- PLB_size             -- The PLB_size(0:3) signals are driven by the master
--                      -- to indicate the size of the requested transfer.
-- PLB_type             -- The Mn_type signals are driven by the master and are
--                      -- used to indicate to the slave, via the PLB_type
--                      -- signals, the type of transfer being requested
-- PLB_wrDBus           -- This data bus is used to transfer data between a
--                      -- master and a slave during a PLB write transfer
-------------------------------------------------------------------------------
-- == SLAVE RESPONSE SIGNALS ==
-------------------------------------------------------------------------------
-- Sl_addrAck           -- This signal is asserted to indicate that the
--                      -- slave has acknowledged the address and will
--                      -- latch the address
-- Sl_SSize             -- The Sl_SSize(0:1) signals are outputs of all
--                      -- non 32-bit PLB slaves. These signals are
--                      -- activated by the slave with the assertion of
--                      -- PLB_PAValid or SAValid and a valid slave
--                      -- address decode and must remain negated at
--                      -- all other times.
-- Sl_wait              -- This signal is asserted to indicate that the
--                      -- slave has recognized the PLB address as a valid address
-- Sl_rearbitrate       -- This signal is asserted to indicate that the
--                      -- slave is unable to perform the currently
--                      -- requested transfer and require the PLB arbiter
--                      -- to re-arbitrate the bus
-- Sl_wrDAck            -- This signal is driven by the slave for a write
--                      -- transfer to indicate that the data currently on the
--                      -- PLB_wrDBus bus is no longer required by the slave
--                      -- i.e. data is latched
-- Sl_wrComp            -- This signal is asserted by the slave to
--                      -- indicate the end of the current write transfer.
-- Sl_rdDBus            -- Slave read bus
-- Sl_rdDAck            -- This signal is driven by the slave to indicate
--                      -- that the data on the Sl_rdDBus bus is valid and
--                      -- must be latched at the end of the current clock cycle
-- Sl_rdComp            -- This signal is driven by the slave and is used
--                      -- to indicate to the PLB arbiter that the read
--                      -- transfer is either complete, or will be complete
--                      -- by the end of the next clock cycle
-- Sl_MBusy             -- These signals are driven by the slave and
--                      -- are used to indicate that the slave is either
--                      -- busy performing a read or a write transfer, or
--                      -- has a read or write transfer pending
-- Sl_MWrErr            -- These signals are driven by the slave and
--                      -- are used to indicate that the slave has encountered an
--                      -- error during a write transfer that was initiated
--                      -- by this master
-- Sl_MRdErr            -- These signals are driven by the slave and are
--                      -- used to indicate that the slave has encountered an
--                      -- error during a read transfer that was initiated
--                      -- by this master
-------------------------------------------------------------------------------
-- Timer/Counter signals 
-------------------------------------------------------------------------------
-- CaptureTrig0         -- Capture Trigger 0
-- CaptureTrig1         -- Capture Trigger 1
-- GenerateOut0         -- Generate Output 0
-- GenerateOut1         -- Generate Output 1
-- PWM0                 -- Pulse Width Modulation Ouput 0
-- Interrupt            -- Interrupt 
-- Freeze               -- Freeze count value
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

library xps_timer_v1_01_b;

library xps_timer_v1_01_b_plbv46_slave_single_v1_01_a;

library xps_timer_v1_01_b_proc_common_v3_00_a;
use xps_timer_v1_01_b_proc_common_v3_00_a.ipif_pkg.calc_num_ce;
use xps_timer_v1_01_b_proc_common_v3_00_a.ipif_pkg.SLV64_ARRAY_TYPE;
use xps_timer_v1_01_b_proc_common_v3_00_a.ipif_pkg.INTEGER_ARRAY_TYPE;

-------------------------------------------------------------------------------
-- Entity declarations
-------------------------------------------------------------------------------
entity xps_timer is
    generic (
        C_FAMILY             : string    := "virtex5";
        C_COUNT_WIDTH        : integer   := 32;
        C_ONE_TIMER_ONLY     : integer   := 0;
        C_TRIG0_ASSERT       : std_logic := '1';
        C_TRIG1_ASSERT       : std_logic := '1';
        C_GEN0_ASSERT        : std_logic := '1';
        C_GEN1_ASSERT        : std_logic := '1';
        --PLBv46 slave single block generics
        C_BASEADDR           : std_logic_vector       := X"ffffffff";
        C_HIGHADDR           : std_logic_vector       := X"00000000";
        C_SPLB_AWIDTH        : integer range 32 to 32 := 32;
        C_SPLB_DWIDTH        : integer range 32 to 128:= 32;
        C_SPLB_P2P           : integer range 0 to 1   := 0;
        C_SPLB_MID_WIDTH     : integer range 0 to 4   := 3;
        C_SPLB_NUM_MASTERS   : integer range 1 to 16  := 8;
        C_SPLB_SUPPORT_BURSTS: integer range 0 to 1   := 0;
        C_SPLB_NATIVE_DWIDTH : integer range 32 to 32 := 32       
    );
    port 
    (
    --Timer/Counter signals
    CaptureTrig0     : in  std_logic;
    CaptureTrig1     : in  std_logic;
    GenerateOut0     : out std_logic;
    GenerateOut1     : out std_logic;
    PWM0             : out std_logic;
    Interrupt        : out std_logic;
    Freeze           : in  std_logic;
    --PLBv46 SLAVE SINGLE INTERFACE
        --system signals
    SPLB_Clk         : in  std_logic;
    SPLB_Rst         : in  std_logic;
        --Bus slave signals
    PLB_ABus         : in  std_logic_vector(0 to C_SPLB_AWIDTH-1);
    PLB_PAValid      : in  std_logic;
    PLB_masterID     : in  std_logic_vector(0 to C_SPLB_MID_WIDTH-1);
    PLB_RNW          : in  std_logic;
    PLB_BE           : in  std_logic_vector(0 to (C_SPLB_DWIDTH/8)-1);
    PLB_size         : in  std_logic_vector(0 to 3);
    PLB_type         : in  std_logic_vector(0 to 2);
    PLB_wrDBus       : in  std_logic_vector(0 to C_SPLB_DWIDTH-1);
        --Slave response signals
    Sl_addrAck       : out std_logic;
    Sl_SSize         : out std_logic_vector(0 to 1);
    Sl_wait          : out std_logic;
    Sl_rearbitrate   : out std_logic;
    Sl_wrDAck        : out std_logic;
    Sl_wrComp        : out std_logic;
    Sl_rdDBus        : out std_logic_vector(0 to C_SPLB_DWIDTH-1);
    Sl_rdDAck        : out std_logic;
    Sl_rdComp        : out std_logic;
    Sl_MBusy         : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);
    Sl_MWrErr        : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);
    Sl_MRdErr        : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);
        --Unused Bus slave signals
    PLB_UABus        : in  std_logic_vector(0 to C_SPLB_AWIDTH-1);
    PLB_SAValid      : in  std_logic;
    PLB_rdPrim       : in  std_logic;
    PLB_wrPrim       : in  std_logic;
    PLB_abort        : in  std_logic;
    PLB_busLock      : in  std_logic;
    PLB_MSize        : in  std_logic_vector(0 to 1);
    PLB_lockErr      : in  std_logic;
    PLB_wrBurst      : in  std_logic;
    PLB_rdBurst      : in  std_logic;   
    PLB_wrPendReq    : in  std_logic; 
    PLB_rdPendReq    : in  std_logic; 
    PLB_wrPendPri    : in  std_logic_vector(0 to 1);
    PLB_rdPendPri    : in  std_logic_vector(0 to 1);
    PLB_reqPri       : in  std_logic_vector(0 to 1);
    PLB_TAttribute   : in  std_logic_vector(0 to 15);
        --Unused Slave Response Signals
    Sl_wrBTerm       : out std_logic;
    Sl_rdWdAddr      : out std_logic_vector(0 to 3);
    Sl_rdBTerm       : out std_logic;
    Sl_MIRQ          : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1)     
    );

    -- Fan-out attributes for XST
    attribute MAX_FANOUT                : string;
    attribute MAX_FANOUT of SPLB_Clk    : signal is "10000";
    attribute MAX_FANOUT of SPLB_Rst    : signal is "10000";

    -- PSFUtil MPD attributes
    attribute IP_GROUP                  : string;
    attribute IP_GROUP of xps_timer     : entity is "LOGICORE";
    attribute MIN_SIZE                  : string;
    attribute MIN_SIZE of C_BASEADDR    : constant is "0x10";
    attribute SIGIS                     : string;
    attribute SIGIS of SPLB_Clk         : signal is "Clk";
    attribute SIGIS of SPLB_Rst         : signal is "Rst";
    attribute SIGIS of Interrupt        : signal is "INTR_LEVEL_HIGH";
    
end entity xps_timer;

-------------------------------------------------------------------------------
-- Architecture section
-------------------------------------------------------------------------------
architecture imp of xps_timer is

    constant ZEROES                 : std_logic_vector(0 to 31) := X"00000000";
    constant C_ARD_ADDR_RANGE_ARRAY : SLV64_ARRAY_TYPE :=
        (
          -- Timer registers Base Address
          ZEROES & C_BASEADDR,
          ZEROES & (C_BASEADDR or X"00000018")
         );

    constant C_ARD_NUM_CE_ARRAY     : INTEGER_ARRAY_TYPE :=
        (
          0 => 7          
        );

    --Signal declaration --------------------------------
    signal bus2ip_clk      : std_logic;                    
    signal bus2ip_reset    : std_logic;               
    signal ip2bus_data     : std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH-1)
                             :=(others  => '0');
    signal ip2bus_error    : std_logic := '0';
    signal ip2bus_wrack    : std_logic := '0';
    signal ip2bus_rdack    : std_logic := '0';
    -----------------------------------------------------------------------
    signal bus2ip_data     : std_logic_vector
                             (0 to C_SPLB_NATIVE_DWIDTH-1);
    signal bus2ip_addr     : std_logic_vector(0 to C_SPLB_AWIDTH-1 );
    signal bus2ip_be       : std_logic_vector
                             (0 to C_SPLB_NATIVE_DWIDTH/8-1 );
    signal bus2ip_rdce     : std_logic_vector
                             (0 to calc_num_ce(C_ARD_NUM_CE_ARRAY)-1);
    signal bus2ip_wrce     : std_logic_vector
                             (0 to calc_num_ce(C_ARD_NUM_CE_ARRAY)-1);
-------------------------------------------------------------------------------
-- Begin architecture
-------------------------------------------------------------------------------
begin -- architecture imp

  TC_CORE_I: entity xps_timer_v1_01_b.tc_core
    generic map (
      C_FAMILY           => C_FAMILY,
      C_COUNT_WIDTH      => C_COUNT_WIDTH,
      C_ONE_TIMER_ONLY   => C_ONE_TIMER_ONLY,
      C_PLB_DWIDTH       => C_SPLB_NATIVE_DWIDTH,
      C_PLB_AWIDTH       => C_SPLB_AWIDTH,
      C_TRIG0_ASSERT     => C_TRIG0_ASSERT,
      C_TRIG1_ASSERT     => C_TRIG1_ASSERT,
      C_GEN0_ASSERT      => C_GEN0_ASSERT,
      C_GEN1_ASSERT      => C_GEN1_ASSERT,
      C_ARD_NUM_CE_ARRAY => C_ARD_NUM_CE_ARRAY
      )

    port map (
      -- PLB IPIF signals
      Clk                => bus2ip_clk,     --[in]
      Rst                => bus2ip_reset,   --[in]
      Bus2ip_addr        => bus2ip_addr,    --[in]
      Bus2ip_be          => bus2ip_be,      --[in]
      Bus2ip_data        => bus2ip_data,    --[in]
      TC_DBus            => ip2bus_data,    --[out]
      bus2ip_rdce        => bus2ip_rdce,    --[in]
      bus2ip_wrce        => bus2ip_wrce,    --[in]
      ip2bus_rdack       => ip2bus_rdack,   --[out]
      ip2bus_wrack       => ip2bus_wrack,   --[out]
      TC_errAck          => ip2bus_error,   --[out]
      -- Timer/Counter signals
      CaptureTrig0       => CaptureTrig0,   --[in]
      CaptureTrig1       => CaptureTrig1,   --[in]
      GenerateOut0       => GenerateOut0,   --[out]
      GenerateOut1       => GenerateOut1,   --[out]
      PWM0               => PWM0,           --[out]
      Interrupt          => Interrupt,      --[out]
      Freeze             => Freeze          --[in]      
      );
     
    ---------------------------------------------------------------------
    -- INSTANTIATE PLBv46 SLAVE SINGLE
    ---------------------------------------------------------------------
    PLBv46_I : entity xps_timer_v1_01_b_plbv46_slave_single_v1_01_a.plbv46_slave_single
      generic map
           (
            C_ARD_ADDR_RANGE_ARRAY      => C_ARD_ADDR_RANGE_ARRAY,
            C_ARD_NUM_CE_ARRAY          => C_ARD_NUM_CE_ARRAY,
            C_SPLB_P2P                  => C_SPLB_P2P,
            C_SPLB_MID_WIDTH            => C_SPLB_MID_WIDTH,
            C_SPLB_NUM_MASTERS          => C_SPLB_NUM_MASTERS,
            C_SPLB_AWIDTH               => C_SPLB_AWIDTH,
            C_SPLB_DWIDTH               => C_SPLB_DWIDTH,
            C_SIPIF_DWIDTH              => C_SPLB_NATIVE_DWIDTH,
            C_FAMILY                    => C_FAMILY
           )
     port map
        (
         -- System signals -----------------------------------------------------
         SPLB_Clk                       => SPLB_Clk,
         SPLB_Rst                       => SPLB_Rst,
         -- Bus Slave signals -------------------------------------------------- 
         PLB_ABus                       => PLB_ABus,
         PLB_UABus                      => PLB_UABus,
         PLB_PAValid                    => PLB_PAValid,
         PLB_SAValid                    => PLB_SAValid,
         PLB_rdPrim                     => PLB_rdPrim,
         PLB_wrPrim                     => PLB_wrPrim,
         PLB_masterID                   => PLB_masterID,
         PLB_abort                      => PLB_abort,
         PLB_busLock                    => PLB_busLock,
         PLB_RNW                        => PLB_RNW,
         PLB_BE                         => PLB_BE,
         PLB_MSize                      => PLB_MSize,
         PLB_size                       => PLB_size,
         PLB_type                       => PLB_type,
         PLB_lockErr                    => PLB_lockErr,
         PLB_wrDBus                     => PLB_wrDBus,                                      
         PLB_wrBurst                    => PLB_wrBurst,
         PLB_rdBurst                    => PLB_rdBurst,
         PLB_wrPendReq                  => PLB_wrPendReq,
         PLB_rdPendReq                  => PLB_rdPendReq,
         PLB_wrPendPri                  => PLB_wrPendPri,
         PLB_rdPendPri                  => PLB_rdPendPri,
         PLB_reqPri                     => PLB_reqPri,
         PLB_TAttribute                 => PLB_TAttribute,
         -- Slave Response Signals ---------------------------------------------
         Sl_addrAck                     => Sl_addrAck,
         Sl_SSize                       => Sl_SSize,
         Sl_wait                        => Sl_wait,
         Sl_rearbitrate                 => Sl_rearbitrate,
         Sl_wrDAck                      => Sl_wrDAck,
         Sl_wrComp                      => Sl_wrComp,
         Sl_wrBTerm                     => Sl_wrBTerm,
         Sl_rdDBus                      => Sl_rdDBus,
         Sl_rdWdAddr                    => Sl_rdWdAddr,
         Sl_rdDAck                      => Sl_rdDAck,
         Sl_rdComp                      => Sl_rdComp,
         Sl_rdBTerm                     => Sl_rdBTerm,
         Sl_MBusy                       => Sl_MBusy,
         Sl_MWrErr                      => Sl_MWrErr,                                      
         Sl_MRdErr                      => Sl_MRdErr,
         Sl_MIRQ                        => Sl_MIRQ,
         -- IP Interconnect (IPIC) port signals --------------------------------
         Bus2IP_Clk                     => bus2ip_clk,
         Bus2IP_Reset                   => bus2ip_reset,
         IP2Bus_Data                    => ip2bus_data,
         IP2Bus_WrAck                   => ip2bus_wrack,
         IP2Bus_RdAck                   => ip2bus_rdack,
         IP2Bus_Error                   => ip2bus_error,
         Bus2IP_Addr                    => bus2ip_addr,
         Bus2IP_Data                    => bus2ip_data,
         Bus2IP_RNW                     => open,
         Bus2IP_BE                      => bus2ip_be,
         Bus2IP_CS                      => open,
         Bus2IP_RdCE                    => bus2ip_rdce,
         Bus2IP_WrCE                    => bus2ip_wrce                                
    );
end architecture imp;
