-------------------------------------------------------------------------------
-- $Id: plb_address_decoder.vhd,v 1.2 2008/05/13 20:38:17 gburch Exp $
-------------------------------------------------------------------------------
-- plb_address_decoder - entity/architecture pair
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
-- Filename:        plb_address_decoder.vhd
-- Version:         v1.00a
-- Description:     Address decoder utilizing unconstrained arrays for Base
--                  Address specification and ce number.
--
-------------------------------------------------------------------------------
--
--                  -- plb_address_decoder.vhd
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
--  GAB     11/8/06
-- ~~~~~~
--  - Fixed Point-to-Point issue where address used to decode CE's was
-- a clock too late causing wrong CE to be driven.
-- ^^^^^^
--  GAB     1/21/07
-- ~~~~~~
--  Pulled addr_out_s_h out of MEM_DECODE_GEN generate loop to prevent multiple
--  driving of addr_out_s_h.
-- ^^^^^^
--  GAB     7/13/07
-- ~~~~~~
--  - Fixed issue where plb address was not getting sampled correctly in
-- the point to point mode.
-- ^^^^^^
--  GAB     7/24/07
-- ~~~~~~
--  - Fixed issue where wrong signal was being used to reset wrce in 
-- BKEND_WRCE_REG process for p2p mode.
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
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library xps_timer_v1_01_b_proc_common_v3_00_a;
use xps_timer_v1_01_b_proc_common_v3_00_a.proc_common_pkg.all;
use xps_timer_v1_01_b_proc_common_v3_00_a.pselect_f;
use xps_timer_v1_01_b_proc_common_v3_00_a.or_gate128;
use xps_timer_v1_01_b_proc_common_v3_00_a.ipif_pkg.all;
use xps_timer_v1_01_b_proc_common_v3_00_a.family_support.all;

library unisim;
use unisim.vcomponents.all;

-------------------------------------------------------------------------------
-- Port declarations
-------------------------------------------------------------------------------

entity plb_address_decoder is
    generic (
        C_BUS_AWIDTH            : integer := 32;

        C_ARD_ADDR_RANGE_ARRAY  : SLV64_ARRAY_TYPE :=                              
                (                                                            
                 X"0000_0000_1000_0000", --  IP user0 base address       
                 X"0000_0000_1000_01FF", --  IP user0 high address       
                 X"0000_0000_1000_0200", --  IP user1 base address       
                 X"0000_0000_1000_02FF"  --  IP user1 high address       
                );                                                                    


        C_ARD_NUM_CE_ARRAY      : INTEGER_ARRAY_TYPE :=
                (
                 8,     -- User0 CE Number
                 1      -- User1 CE Number
                );
        C_SPLB_P2P              : integer := 0;
        C_FAMILY                : string  := "virtex4"
    );   
  port (
        Bus_clk             : in  std_logic;
        Bus_rst             : in  std_logic;

        -- PLB Interface signals
        Address_In          : in  std_logic_vector(0 to C_BUS_AWIDTH-1)     ;
        Address_In_Erly     : in  std_logic_vector(0 to C_BUS_AWIDTH-1)     ;
        Address_Valid       : in  std_logic                                 ;
        Address_Valid_Erly  : in  std_logic                                 ;
        Bus_RNW             : in  std_logic                                 ;
        Bus_RNW_Erly        : in  std_logic                                 ;

        -- Registering control signals
        cs_sample_hold_n    : in  std_logic                                 ;
        cs_sample_hold_clr  : in  std_logic                                 ;
        CS_CE_ld_enable     : in  std_logic                                 ;
        Clear_CS_CE_Reg     : in  std_logic                                 ;
        RW_CE_ld_enable     : in  std_logic                                 ;
        Clear_RW_CE_Reg     : in  std_logic                                 ;
        Clear_addr_match    : in  std_logic                                 ;
    
        -- Decode output signals
        Addr_Match_early    : out std_logic                                 ; 
        Addr_Match          : out std_logic                                 ; 
        CS_Out              : out std_logic_vector
                                (0 to ((C_ARD_ADDR_RANGE_ARRAY'LENGTH)/2)-1);
        RdCE_Out            : out std_logic_vector
                                (0 to calc_num_ce(C_ARD_NUM_CE_ARRAY)-1)    ;
        WrCE_Out            : out std_logic_vector
                                (0 to calc_num_ce(C_ARD_NUM_CE_ARRAY)-1)
    );
end entity plb_address_decoder;

-------------------------------------------------------------------------------
-- Architecture section
-------------------------------------------------------------------------------

architecture IMP of plb_address_decoder is

-- local type declarations ----------------------------------------------------
type decode_bit_array_type is Array(natural range 0 to (
                           (C_ARD_ADDR_RANGE_ARRAY'LENGTH)/2)-1) of 
                           integer;

type short_addr_array_type is Array(natural range 0 to 
                           C_ARD_ADDR_RANGE_ARRAY'LENGTH-1) of 
                           std_logic_vector(0 to C_BUS_AWIDTH-1);
-------------------------------------------------------------------------------
-- Function Declarations
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- This function converts a 64 bit address range array to a AWIDTH bit 
-- address range array.
-------------------------------------------------------------------------------
function slv64_2_slv_awidth(slv64_addr_array   : SLV64_ARRAY_TYPE;
                            awidth             : integer) 
                        return short_addr_array_type is

    variable temp_addr   : std_logic_vector(0 to 63);
    variable slv_array   : short_addr_array_type;
    begin
        for array_index in 0 to slv64_addr_array'length-1 loop
            temp_addr := slv64_addr_array(array_index);
            slv_array(array_index) := temp_addr((64-awidth) to 63);
        end loop; 
        return(slv_array);
    end function slv64_2_slv_awidth;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function Addr_Bits (x,y : std_logic_vector(0 to C_BUS_AWIDTH-1)) 
                    return integer is
    variable addr_nor : std_logic_vector(0 to C_BUS_AWIDTH-1);
    begin
        addr_nor := x xor y;
        for i in 0 to C_BUS_AWIDTH-1 loop
            if addr_nor(i)='1' then 
                return i;
            end if;
        end loop;
--coverage off
        return(C_BUS_AWIDTH);
--coverage on
    end function Addr_Bits;

 
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function Get_Addr_Bits (baseaddrs : short_addr_array_type) 
                        return decode_bit_array_type is
 
    variable num_bits : decode_bit_array_type;
    begin
        for i in 0 to ((baseaddrs'length)/2)-1 loop
   
            num_bits(i) :=  Addr_Bits (baseaddrs(i*2), 
                                       baseaddrs(i*2+1));
        end loop;
        return(num_bits);
    end function Get_Addr_Bits;
 
 
-------------------------------------------------------------------------------
-- NEEDED_ADDR_BITS
--
-- Function Description:
--  This function calculates the number of address bits required 
-- to support the CE generation logic. This is determined by 
-- multiplying the number of CEs for an address space by the 
-- data width of the address space (in bytes). Each address
-- space entry is processed and the biggest of the spaces is 
-- used to set the number of address bits required to be latched
-- and used for CE decoding. A minimum value of 1 is returned by
-- this function.
--
-------------------------------------------------------------------------------
function needed_addr_bits (ce_array   : INTEGER_ARRAY_TYPE) 
                            return integer is

    constant NUM_CE_ENTRIES     : integer := CE_ARRAY'length;
    variable biggest            : integer := 2; 
    variable req_ce_addr_size   : integer := 0;
    variable num_addr_bits      : integer := 0;
    begin

        for i in 0 to NUM_CE_ENTRIES-1 loop
            req_ce_addr_size := ce_array(i) * 4;                                  
            if (req_ce_addr_size > biggest) Then
                biggest := req_ce_addr_size;
            end if;
        end loop;
        num_addr_bits := log2(biggest);
        return(num_addr_bits);
    end function NEEDED_ADDR_BITS;

-------------------------------------------------------------------------------
-- Constant Declarations
-------------------------------------------------------------------------------
constant ARD_ADDR_RANGE_ARRAY   : short_addr_array_type :=
                                    slv64_2_slv_awidth(C_ARD_ADDR_RANGE_ARRAY,
                                                       C_BUS_AWIDTH);

constant NUM_BASE_ADDRS         : integer := (C_ARD_ADDR_RANGE_ARRAY'length)/2;

constant DECODE_BITS            : decode_bit_array_type := 
                                    Get_Addr_Bits(ARD_ADDR_RANGE_ARRAY);

constant NUM_CE_SIGNALS         : integer := 
                                    calc_num_ce(C_ARD_NUM_CE_ARRAY);

constant NUM_S_H_ADDR_BITS      : integer := 
                                    needed_addr_bits(C_ARD_NUM_CE_ARRAY);


-------------------------------------------------------------------------------
-- Signal Declarations
-------------------------------------------------------------------------------
signal pselect_hit_i    : std_logic_vector
                            (0 to ((C_ARD_ADDR_RANGE_ARRAY'LENGTH)/2)-1);
signal cs_out_i         : std_logic_vector
                            (0 to ((C_ARD_ADDR_RANGE_ARRAY'LENGTH)/2)-1);
signal ce_expnd_i       : std_logic_vector(0 to NUM_CE_SIGNALS-1);  
signal rdce_out_i       : std_logic_vector(0 to NUM_CE_SIGNALS-1);  
signal wrce_out_i       : std_logic_vector(0 to NUM_CE_SIGNALS-1);
Signal decode_hit       : std_logic_vector(0 to 0);
Signal decode_hit_reg   : std_logic;

Signal cs_s_h_clr       : std_logic;
Signal cs_ce_clr        : std_logic;
Signal rdce_clr         : std_logic;
Signal wrce_clr         : std_logic;
Signal addr_match_clr   : std_logic;
Signal rnw_s_h          : std_logic;
Signal addr_out_s_h     : std_logic_vector(0 to NUM_S_H_ADDR_BITS-1);

-------------------------------------------------------------------------------
-- Begin architecture
-------------------------------------------------------------------------------
begin -- architecture IMP
  
   
-- Register clears
cs_s_h_clr      <= Bus_rst or cs_sample_hold_clr;
cs_ce_clr       <= Bus_rst or Clear_CS_CE_Reg;
rdce_clr        <= Bus_rst or Clear_RW_CE_Reg or not(rnw_s_h);
wrce_clr        <= Bus_rst or Clear_RW_CE_Reg or rnw_s_h;
addr_match_clr  <= Bus_rst or Clear_addr_match; 
  
---------------------------------------------------------------------------------
---- GEN_S_H_ADDR_REG
---- This ForGen implements the Sample and Hold 
---- register for the input PLB address. Only those LS address 
---- bits needed for CE generation are registered. 
---------------------------------------------------------------------------------
--S_H_ADDR_REG : process(Bus_clk)
--    begin
--        if(Bus_clk'EVENT and Bus_clk = '1')then
--            if(Bus_rst='1' or cs_sample_hold_clr='1')then
--                addr_out_s_h <= (others => '0');
--            elsif(cs_sample_hold_n='1')then
--                addr_out_s_h <= Address_In(C_BUS_AWIDTH-NUM_S_H_ADDR_BITS 
--                                            to C_BUS_AWIDTH-1);
--            end if;
--        end if;
--    end process S_H_ADDR_REG;



GEN_RNW_FOR_SHARED : if C_SPLB_P2P = 0 generate

    -- Instantate sample and hold register for the PLB RNW 
   S_H_RNW_REG  :   process(Bus_Clk)
    begin
        if(Bus_Clk'EVENT and Bus_Clk = '1')then
            if(Bus_Rst = '1' or cs_sample_hold_clr = '1')then
                rnw_s_h <= '0';
            elsif(cs_sample_hold_n = '1')then
                rnw_s_h <= Bus_RNW;
            end if;
        end if;
    end process S_H_RNW_REG;
        
    -------------------------------------------------------------------------------
    -- GEN_S_H_ADDR_REG
    -- This ForGen implements the Sample and Hold 
    -- register for the input PLB address. Only those LS address 
    -- bits needed for CE generation are registered. 
    -------------------------------------------------------------------------------
    S_H_ADDR_REG : process(Bus_clk)
        begin
            if(Bus_clk'EVENT and Bus_clk = '1')then
                if(Bus_rst='1' or cs_sample_hold_clr='1')then
                    addr_out_s_h <= (others => '0');
                elsif(cs_sample_hold_n='1')then
                    addr_out_s_h <= Address_In(C_BUS_AWIDTH-NUM_S_H_ADDR_BITS 
                                                to C_BUS_AWIDTH-1);
                end if;
            end if;
            end process S_H_ADDR_REG;

end generate GEN_RNW_FOR_SHARED;      




GEN_RNW_FOR_P2P : if  C_SPLB_P2P = 1 generate
    rnw_s_h <= '0';
--    addr_out_s_h <= Address_In(C_BUS_AWIDTH-NUM_S_H_ADDR_BITS 
--                                to C_BUS_AWIDTH-1);
    addr_out_s_h <= Address_In_Erly(C_BUS_AWIDTH-NUM_S_H_ADDR_BITS 
                                to C_BUS_AWIDTH-1);


end generate GEN_RNW_FOR_P2P;      

-------------------------------------------------------------------------------
-- Universal Address Decode Block
-------------------------------------------------------------------------------
MEM_DECODE_GEN: for bar_index in 0 to NUM_BASE_ADDRS-1 generate
constant CE_INDEX_START : integer
                        := calc_start_ce_index(C_ARD_NUM_CE_ARRAY,bar_index);
constant CE_ADDR_SIZE   : Integer range 0 to 15
                        := log2(C_ARD_NUM_CE_ARRAY(bar_index));    
--      constant OFFSET         : integer := log2(C_ARD_DWIDTH_ARRAY(bar_index)/8);
constant OFFSET         : integer := 2;


begin  

    GEN_PLB_SHARED : if C_SPLB_P2P = 0 generate
    signal cs_out_s_h       : std_logic_vector
                                (0 to ((C_ARD_ADDR_RANGE_ARRAY'LENGTH)/2)-1);
    begin
        -- Instantiate the basic Base Address Decoders
        MEM_SELECT_I: entity xps_timer_v1_01_b_proc_common_v3_00_a.pselect_f
            generic map 
            (
                C_AB     => DECODE_BITS(bar_index),
                C_AW     => C_BUS_AWIDTH,
                C_BAR    => ARD_ADDR_RANGE_ARRAY(bar_index*2),
                C_FAMILY => C_FAMILY
            )
            port map 
            (
                A        => Address_In,                 -- [in]
                AValid   => Address_Valid,              -- [in]
                CS       => pselect_hit_i(bar_index)    -- [out]
            );        

        -- Instantate sample and hold registers for the Chip Selects
        CS_S_H_REG : process(Bus_Clk)
            begin
                if(Bus_Clk'EVENT and Bus_Clk = '1')then
                    if(Bus_Rst='1' or cs_sample_hold_clr = '1')then
                        cs_out_s_h(bar_index) <= '0';
                    elsif(cs_sample_hold_n='1')then
                        cs_out_s_h(bar_index) <= pselect_hit_i(bar_index);
                    end if;
                end if;
            end process CS_S_H_REG;


        -- Instantate backend registers for the Chip Selects
        BKEND_CS_REG : process(Bus_Clk)
            begin
                if(Bus_Clk'EVENT and Bus_Clk = '1')then
                    if(Bus_Rst='1' or Clear_CS_CE_Reg = '1')then
                        cs_out_i(bar_index) <= '0';
                    elsif(CS_CE_ld_enable='1')then
                        cs_out_i(bar_index) <= cs_out_s_h(bar_index);
                    end if;
                end if;
            end process BKEND_CS_REG;

    end generate GEN_PLB_SHARED;


    GEN_PLB_P2P : if  C_SPLB_P2P = 1 generate

        GEN_FOR_MULTI_CS : if C_ARD_ADDR_RANGE_ARRAY'length > 2 generate
            -- Instantiate the basic Base Address Decoders
            MEM_SELECT_I: entity xps_timer_v1_01_b_proc_common_v3_00_a.pselect_f
                generic map 
                (
                    C_AB     => DECODE_BITS(bar_index),
                    C_AW     => C_BUS_AWIDTH,
                    C_BAR    => ARD_ADDR_RANGE_ARRAY(bar_index*2),
                    C_FAMILY => C_FAMILY
                )
                port map 
                (
                    A        => Address_In_Erly,            -- [in]
                    AValid   => Address_Valid_Erly,         -- [in]
                    CS       => pselect_hit_i(bar_index)    -- [out]
                );        
        end generate GEN_FOR_MULTI_CS;
        
        GEN_FOR_ONE_CS : if C_ARD_ADDR_RANGE_ARRAY'length = 2 generate
            pselect_hit_i(bar_index) <= Address_Valid_Erly;
        end generate GEN_FOR_ONE_CS;


        -- Instantate backend registers for the Chip Selects
        BKEND_CS_REG : process(Bus_Clk)
            begin
                if(Bus_Clk'EVENT and Bus_Clk = '1')then
                    if(Bus_Rst='1' or Clear_CS_CE_Reg = '1')then
                        cs_out_i(bar_index) <= '0';
                    elsif(CS_CE_ld_enable='1')then
                        cs_out_i(bar_index) <= pselect_hit_i(bar_index);
                    end if;
                end if;
            end process BKEND_CS_REG;



       
    end generate GEN_PLB_P2P;
    
    -------------------------------------------------------------------------
    -- Now expand the individual CEs for each base address.
    -------------------------------------------------------------------------
    PER_CE_GEN: for j in 0 to C_ARD_NUM_CE_ARRAY(bar_index) - 1 generate
    begin
        ----------------------------------------------------------------------
        -- CE decoders for multiple CE's
        ----------------------------------------------------------------------
        MULTIPLE_CES_THIS_CS_GEN : if CE_ADDR_SIZE > 0 generate
        constant BAR    : std_logic_vector(0 to CE_ADDR_SIZE-1) := 
                            std_logic_vector(to_unsigned(j,CE_ADDR_SIZE));
        begin
            CE_I : entity xps_timer_v1_01_b_proc_common_v3_00_a.pselect_f   
                generic map (
                    C_AB        => CE_ADDR_SIZE                             ,
                    C_AW        => CE_ADDR_SIZE                             ,
                    C_BAR       => BAR                                      ,
                    C_FAMILY    => C_FAMILY
                )
                port map (
                    A           => addr_out_s_h
                                    (NUM_S_H_ADDR_BITS-OFFSET-CE_ADDR_SIZE 
                                    to NUM_S_H_ADDR_BITS - OFFSET - 1)      ,
                    AValid      => pselect_hit_i(bar_index)                 ,
                    CS          => ce_expnd_i(CE_INDEX_START+j)
                );
            end generate MULTIPLE_CES_THIS_CS_GEN;

        ----------------------------------------------------------------------
        -- CE decoders for single CE
        ----------------------------------------------------------------------
        SINGLE_CE_THIS_CS_GEN : if CE_ADDR_SIZE = 0 generate
            ce_expnd_i(CE_INDEX_START+j) <= pselect_hit_i(bar_index);
        end generate;

    end generate PER_CE_GEN;

    
end generate MEM_DECODE_GEN;    


I_OR_CS :  entity xps_timer_v1_01_b_proc_common_v3_00_a.or_gate128
    generic map(
        C_OR_WIDTH   => NUM_BASE_ADDRS,
        C_BUS_WIDTH  => 1,
        C_USE_LUT_OR => FALSE
    )
    port map(
        A => pselect_hit_i,
        Y => decode_hit
    );

                       
                       
-- Instantate Address Match register
ADDR_MATCH_REG : process(Bus_Clk)
    begin
        if(Bus_Clk'EVENT and Bus_Clk = '1')then
            if(Bus_Rst='1' or Clear_addr_match = '1')then
                decode_hit_reg <= '0';
            else
                decode_hit_reg <= decode_hit(0);
            end if;
        end if;
    end process ADDR_MATCH_REG;


GEN_CE_FOR_SHARED : if C_SPLB_P2P = 0 generate
    ---------------------------------------------------------------------------
    -- GEN_BKEND_CE_REGISTERS
    -- This ForGen implements the backend registering for
    -- the CE, RdCE, and WrCE output buses.
    ---------------------------------------------------------------------------
    GEN_BKEND_CE_REGISTERS : for ce_index in 0 to NUM_CE_SIGNALS-1 generate

        -- Instantate Backend RdCE register
        BKEND_RDCE_REG : process(Bus_Clk)
            begin
                if(Bus_Clk'EVENT and Bus_Clk = '1')then
                    if(rdce_clr='1')then
                        rdce_out_i(ce_index) <= '0';
                    elsif(RW_CE_ld_enable='1')then
                        rdce_out_i(ce_index) <= ce_expnd_i(ce_index);
                    end if;
                end if;
            end process BKEND_RDCE_REG;


        -- Instantate Backend WrCE register
        BKEND_WRCE_REG : process(Bus_Clk)
            begin
                if(Bus_Clk'EVENT and Bus_Clk = '1')then
                    if(wrce_clr='1')then
                        wrce_out_i(ce_index) <= '0';
                    elsif(RW_CE_ld_enable='1')then
                        wrce_out_i(ce_index) <= ce_expnd_i(ce_index);
                    end if;
                end if;
            end process BKEND_WRCE_REG;


    end generate GEN_BKEND_CE_REGISTERS;
end generate GEN_CE_FOR_SHARED;     


GEN_CE_FOR_P2P : if C_SPLB_P2P = 1 generate

    ---------------------------------------------------------------------------
    -- GEN_BKEND_CE_REGISTERS
    -- This ForGen implements the backend registering for
    -- the CE, RdCE, and WrCE output buses.
    ---------------------------------------------------------------------------
    GEN_BKEND_CE_REGISTERS : for ce_index in 0 to NUM_CE_SIGNALS-1 generate
    signal rdce_expnd_i : std_logic_vector(0 to NUM_CE_SIGNALS-1);  
    signal wrce_expnd_i : std_logic_vector(0 to NUM_CE_SIGNALS-1);  
    begin

        rdce_expnd_i(ce_index)    <= ce_expnd_i(ce_index) and Bus_RNW_Erly;
        -- Instantate Backend RdCE register
        BKEND_RDCE_REG : process(Bus_Clk)
            begin
                if(Bus_Clk'EVENT and Bus_Clk = '1')then
                    if(cs_ce_clr='1')then
                        rdce_out_i(ce_index) <= '0';
                    elsif(RW_CE_ld_enable='1')then
                        rdce_out_i(ce_index) <= rdce_expnd_i(ce_index);
                    end if;
                end if;
            end process BKEND_RDCE_REG;


        wrce_expnd_i(ce_index)    <= ce_expnd_i(ce_index) and not Bus_RNW_Erly;
        -- Instantate Backend WrCE register
        BKEND_WRCE_REG : process(Bus_Clk)
            begin
                if(Bus_Clk'EVENT and Bus_Clk = '1')then
--                    if(wrce_clr='1')then
                    if(cs_ce_clr='1')then
                        wrce_out_i(ce_index) <= '0';
                    elsif(RW_CE_ld_enable='1')then
                        wrce_out_i(ce_index) <= wrce_expnd_i(ce_index);
                    end if;
                end if;
            end process BKEND_WRCE_REG;

    end generate GEN_BKEND_CE_REGISTERS;

end generate GEN_CE_FOR_P2P;     
 
-- Assign registered output signals
Addr_Match   <= decode_hit_reg ;
CS_Out       <= cs_out_i   ;
RdCE_Out     <= rdce_out_i ;
WrCE_Out     <= wrce_out_i ;

-- Assign early timing output for Address Match.
-- This is unregistered so it occurs 1 clock early
-- but may induce large Fmax timing paths
Addr_Match_early   <= decode_hit(0) ;  
                       
-------------------------------------------------------------------------------
-- end of decoder block
-------------------------------------------------------------------------------
        
end architecture IMP;
