-------------------------------------------------------------------------------
-- xps_tft_0_wrapper.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

library xps_tft_v2_01_a;
use xps_tft_v2_01_a.all;

entity xps_tft_0_wrapper is
  port (
    SPLB_Clk : in std_logic;
    SPLB_Rst : in std_logic;
    MPLB_Clk : in std_logic;
    MPLB_Rst : in std_logic;
    MD_error : out std_logic;
    IP2INTC_Irpt : out std_logic;
    M_request : out std_logic;
    M_priority : out std_logic_vector(0 to 1);
    M_busLock : out std_logic;
    M_RNW : out std_logic;
    M_BE : out std_logic_vector(0 to 15);
    M_MSize : out std_logic_vector(0 to 1);
    M_size : out std_logic_vector(0 to 3);
    M_type : out std_logic_vector(0 to 2);
    M_ABus : out std_logic_vector(0 to 31);
    M_wrBurst : out std_logic;
    M_rdBurst : out std_logic;
    M_wrDBus : out std_logic_vector(0 to 127);
    PLB_MSSize : in std_logic_vector(0 to 1);
    PLB_MAddrAck : in std_logic;
    PLB_MRearbitrate : in std_logic;
    PLB_MTimeout : in std_logic;
    PLB_MRdErr : in std_logic;
    PLB_MWrErr : in std_logic;
    PLB_MRdDBus : in std_logic_vector(0 to 127);
    PLB_MRdDAck : in std_logic;
    PLB_MWrDAck : in std_logic;
    PLB_MRdBTerm : in std_logic;
    PLB_MWrBTerm : in std_logic;
    M_TAttribute : out std_logic_vector(0 to 15);
    M_lockErr : out std_logic;
    M_abort : out std_logic;
    M_UABus : out std_logic_vector(0 to 31);
    PLB_MBusy : in std_logic;
    PLB_MIRQ : in std_logic;
    PLB_MRdWdAddr : in std_logic_vector(0 to 3);
    PLB_ABus : in std_logic_vector(0 to 31);
    PLB_PAValid : in std_logic;
    PLB_masterID : in std_logic_vector(0 to 0);
    PLB_RNW : in std_logic;
    PLB_BE : in std_logic_vector(0 to 15);
    PLB_size : in std_logic_vector(0 to 3);
    PLB_type : in std_logic_vector(0 to 2);
    PLB_wrDBus : in std_logic_vector(0 to 127);
    Sl_addrAck : out std_logic;
    Sl_SSize : out std_logic_vector(0 to 1);
    Sl_wait : out std_logic;
    Sl_rearbitrate : out std_logic;
    Sl_wrDAck : out std_logic;
    Sl_wrComp : out std_logic;
    Sl_rdDBus : out std_logic_vector(0 to 127);
    Sl_rdDAck : out std_logic;
    Sl_rdComp : out std_logic;
    Sl_MBusy : out std_logic_vector(0 to 1);
    Sl_MWrErr : out std_logic_vector(0 to 1);
    Sl_MRdErr : out std_logic_vector(0 to 1);
    PLB_UABus : in std_logic_vector(0 to 31);
    PLB_SAValid : in std_logic;
    PLB_rdPrim : in std_logic;
    PLB_wrPrim : in std_logic;
    PLB_abort : in std_logic;
    PLB_busLock : in std_logic;
    PLB_MSize : in std_logic_vector(0 to 1);
    PLB_lockErr : in std_logic;
    PLB_wrBurst : in std_logic;
    PLB_rdBurst : in std_logic;
    PLB_wrPendReq : in std_logic;
    PLB_rdPendReq : in std_logic;
    PLB_wrPendPri : in std_logic_vector(0 to 1);
    PLB_rdPendPri : in std_logic_vector(0 to 1);
    PLB_reqPri : in std_logic_vector(0 to 1);
    PLB_TAttribute : in std_logic_vector(0 to 15);
    Sl_wrBTerm : out std_logic;
    Sl_rdWdAddr : out std_logic_vector(0 to 3);
    Sl_rdBTerm : out std_logic;
    Sl_MIRQ : out std_logic_vector(0 to 1);
    DCR_Clk : in std_logic;
    DCR_Rst : in std_logic;
    DCR_Read : in std_logic;
    DCR_Write : in std_logic;
    DCR_ABus : in std_logic_vector(0 to 9);
    DCR_Sl_DBus : in std_logic_vector(0 to 31);
    Sl_DCRDBus : out std_logic_vector(0 to 31);
    Sl_DCRAck : out std_logic;
    SYS_TFT_Clk : in std_logic;
    TFT_HSYNC : out std_logic;
    TFT_VSYNC : out std_logic;
    TFT_DE : out std_logic;
    TFT_DPS : out std_logic;
    TFT_VGA_CLK : out std_logic;
    TFT_VGA_R : out std_logic_vector(5 downto 0);
    TFT_VGA_G : out std_logic_vector(5 downto 0);
    TFT_VGA_B : out std_logic_vector(5 downto 0);
    TFT_DVI_CLK_P : out std_logic;
    TFT_DVI_CLK_N : out std_logic;
    TFT_DVI_DATA : out std_logic_vector(11 downto 0);
    TFT_IIC_SCL_I : in std_logic;
    TFT_IIC_SCL_O : out std_logic;
    TFT_IIC_SCL_T : out std_logic;
    TFT_IIC_SDA_I : in std_logic;
    TFT_IIC_SDA_O : out std_logic;
    TFT_IIC_SDA_T : out std_logic
  );

  attribute x_core_info : STRING;
  attribute x_core_info of xps_tft_0_wrapper : entity is "xps_tft_v2_01_a";

end xps_tft_0_wrapper;

architecture STRUCTURE of xps_tft_0_wrapper is

  component xps_tft is
    generic (
      C_FAMILY : STRING;
      C_DCR_SPLB_SLAVE_IF : INTEGER;
      C_TFT_INTERFACE : INTEGER;
      C_I2C_SLAVE_ADDR : std_logic_vector;
      C_DEFAULT_TFT_BASE_ADDR : std_logic_vector;
      C_DCR_BASEADDR : std_logic_vector;
      C_DCR_HIGHADDR : std_logic_vector;
      C_MPLB_AWIDTH : INTEGER;
      C_MPLB_DWIDTH : INTEGER;
      C_MPLB_NATIVE_DWIDTH : INTEGER;
      C_MPLB_SMALLEST_SLAVE : INTEGER;
      C_SPLB_AWIDTH : INTEGER;
      C_SPLB_DWIDTH : INTEGER;
      C_SPLB_P2P : INTEGER;
      C_SPLB_MID_WIDTH : INTEGER;
      C_SPLB_NUM_MASTERS : INTEGER;
      C_SPLB_NATIVE_DWIDTH : INTEGER;
      C_SPLB_BASEADDR : std_logic_vector;
      C_SPLB_HIGHADDR : std_logic_vector
    );
    port (
      SPLB_Clk : in std_logic;
      SPLB_Rst : in std_logic;
      MPLB_Clk : in std_logic;
      MPLB_Rst : in std_logic;
      MD_error : out std_logic;
      IP2INTC_Irpt : out std_logic;
      M_request : out std_logic;
      M_priority : out std_logic_vector(0 to 1);
      M_busLock : out std_logic;
      M_RNW : out std_logic;
      M_BE : out std_logic_vector(0 to ((C_MPLB_DWIDTH/8)-1));
      M_MSize : out std_logic_vector(0 to 1);
      M_size : out std_logic_vector(0 to 3);
      M_type : out std_logic_vector(0 to 2);
      M_ABus : out std_logic_vector(0 to 31);
      M_wrBurst : out std_logic;
      M_rdBurst : out std_logic;
      M_wrDBus : out std_logic_vector(0 to (C_MPLB_DWIDTH-1));
      PLB_MSSize : in std_logic_vector(0 to 1);
      PLB_MAddrAck : in std_logic;
      PLB_MRearbitrate : in std_logic;
      PLB_MTimeout : in std_logic;
      PLB_MRdErr : in std_logic;
      PLB_MWrErr : in std_logic;
      PLB_MRdDBus : in std_logic_vector(0 to (C_MPLB_DWIDTH-1));
      PLB_MRdDAck : in std_logic;
      PLB_MWrDAck : in std_logic;
      PLB_MRdBTerm : in std_logic;
      PLB_MWrBTerm : in std_logic;
      M_TAttribute : out std_logic_vector(0 to 15);
      M_lockErr : out std_logic;
      M_abort : out std_logic;
      M_UABus : out std_logic_vector(0 to 31);
      PLB_MBusy : in std_logic;
      PLB_MIRQ : in std_logic;
      PLB_MRdWdAddr : in std_logic_vector(0 to 3);
      PLB_ABus : in std_logic_vector(0 to 31);
      PLB_PAValid : in std_logic;
      PLB_masterID : in std_logic_vector(0 to (C_SPLB_MID_WIDTH-1));
      PLB_RNW : in std_logic;
      PLB_BE : in std_logic_vector(0 to ((C_SPLB_DWIDTH/8)-1));
      PLB_size : in std_logic_vector(0 to 3);
      PLB_type : in std_logic_vector(0 to 2);
      PLB_wrDBus : in std_logic_vector(0 to (C_SPLB_DWIDTH-1));
      Sl_addrAck : out std_logic;
      Sl_SSize : out std_logic_vector(0 to 1);
      Sl_wait : out std_logic;
      Sl_rearbitrate : out std_logic;
      Sl_wrDAck : out std_logic;
      Sl_wrComp : out std_logic;
      Sl_rdDBus : out std_logic_vector(0 to (C_SPLB_DWIDTH-1));
      Sl_rdDAck : out std_logic;
      Sl_rdComp : out std_logic;
      Sl_MBusy : out std_logic_vector(0 to (C_SPLB_NUM_MASTERS-1));
      Sl_MWrErr : out std_logic_vector(0 to (C_SPLB_NUM_MASTERS-1));
      Sl_MRdErr : out std_logic_vector(0 to (C_SPLB_NUM_MASTERS-1));
      PLB_UABus : in std_logic_vector(0 to 31);
      PLB_SAValid : in std_logic;
      PLB_rdPrim : in std_logic;
      PLB_wrPrim : in std_logic;
      PLB_abort : in std_logic;
      PLB_busLock : in std_logic;
      PLB_MSize : in std_logic_vector(0 to 1);
      PLB_lockErr : in std_logic;
      PLB_wrBurst : in std_logic;
      PLB_rdBurst : in std_logic;
      PLB_wrPendReq : in std_logic;
      PLB_rdPendReq : in std_logic;
      PLB_wrPendPri : in std_logic_vector(0 to 1);
      PLB_rdPendPri : in std_logic_vector(0 to 1);
      PLB_reqPri : in std_logic_vector(0 to 1);
      PLB_TAttribute : in std_logic_vector(0 to 15);
      Sl_wrBTerm : out std_logic;
      Sl_rdWdAddr : out std_logic_vector(0 to 3);
      Sl_rdBTerm : out std_logic;
      Sl_MIRQ : out std_logic_vector(0 to (C_SPLB_NUM_MASTERS-1));
      DCR_Clk : in std_logic;
      DCR_Rst : in std_logic;
      DCR_Read : in std_logic;
      DCR_Write : in std_logic;
      DCR_ABus : in std_logic_vector(0 to 9);
      DCR_Sl_DBus : in std_logic_vector(0 to 31);
      Sl_DCRDBus : out std_logic_vector(0 to 31);
      Sl_DCRAck : out std_logic;
      SYS_TFT_Clk : in std_logic;
      TFT_HSYNC : out std_logic;
      TFT_VSYNC : out std_logic;
      TFT_DE : out std_logic;
      TFT_DPS : out std_logic;
      TFT_VGA_CLK : out std_logic;
      TFT_VGA_R : out std_logic_vector(5 downto 0);
      TFT_VGA_G : out std_logic_vector(5 downto 0);
      TFT_VGA_B : out std_logic_vector(5 downto 0);
      TFT_DVI_CLK_P : out std_logic;
      TFT_DVI_CLK_N : out std_logic;
      TFT_DVI_DATA : out std_logic_vector(11 downto 0);
      TFT_IIC_SCL_I : in std_logic;
      TFT_IIC_SCL_O : out std_logic;
      TFT_IIC_SCL_T : out std_logic;
      TFT_IIC_SDA_I : in std_logic;
      TFT_IIC_SDA_O : out std_logic;
      TFT_IIC_SDA_T : out std_logic
    );
  end component;

begin

  xps_tft_0 : xps_tft
    generic map (
      C_FAMILY => "virtex5",
      C_DCR_SPLB_SLAVE_IF => 1,
      C_TFT_INTERFACE => 1,
      C_I2C_SLAVE_ADDR => B"1110110",
      C_DEFAULT_TFT_BASE_ADDR => X"00000000",
      C_DCR_BASEADDR => B"1111111111",
      C_DCR_HIGHADDR => B"0000000000",
      C_MPLB_AWIDTH => 32,
      C_MPLB_DWIDTH => 128,
      C_MPLB_NATIVE_DWIDTH => 64,
      C_MPLB_SMALLEST_SLAVE => 32,
      C_SPLB_AWIDTH => 32,
      C_SPLB_DWIDTH => 128,
      C_SPLB_P2P => 0,
      C_SPLB_MID_WIDTH => 1,
      C_SPLB_NUM_MASTERS => 2,
      C_SPLB_NATIVE_DWIDTH => 32,
      C_SPLB_BASEADDR => X"86e00000",
      C_SPLB_HIGHADDR => X"86e0ffff"
    )
    port map (
      SPLB_Clk => SPLB_Clk,
      SPLB_Rst => SPLB_Rst,
      MPLB_Clk => MPLB_Clk,
      MPLB_Rst => MPLB_Rst,
      MD_error => MD_error,
      IP2INTC_Irpt => IP2INTC_Irpt,
      M_request => M_request,
      M_priority => M_priority,
      M_busLock => M_busLock,
      M_RNW => M_RNW,
      M_BE => M_BE,
      M_MSize => M_MSize,
      M_size => M_size,
      M_type => M_type,
      M_ABus => M_ABus,
      M_wrBurst => M_wrBurst,
      M_rdBurst => M_rdBurst,
      M_wrDBus => M_wrDBus,
      PLB_MSSize => PLB_MSSize,
      PLB_MAddrAck => PLB_MAddrAck,
      PLB_MRearbitrate => PLB_MRearbitrate,
      PLB_MTimeout => PLB_MTimeout,
      PLB_MRdErr => PLB_MRdErr,
      PLB_MWrErr => PLB_MWrErr,
      PLB_MRdDBus => PLB_MRdDBus,
      PLB_MRdDAck => PLB_MRdDAck,
      PLB_MWrDAck => PLB_MWrDAck,
      PLB_MRdBTerm => PLB_MRdBTerm,
      PLB_MWrBTerm => PLB_MWrBTerm,
      M_TAttribute => M_TAttribute,
      M_lockErr => M_lockErr,
      M_abort => M_abort,
      M_UABus => M_UABus,
      PLB_MBusy => PLB_MBusy,
      PLB_MIRQ => PLB_MIRQ,
      PLB_MRdWdAddr => PLB_MRdWdAddr,
      PLB_ABus => PLB_ABus,
      PLB_PAValid => PLB_PAValid,
      PLB_masterID => PLB_masterID,
      PLB_RNW => PLB_RNW,
      PLB_BE => PLB_BE,
      PLB_size => PLB_size,
      PLB_type => PLB_type,
      PLB_wrDBus => PLB_wrDBus,
      Sl_addrAck => Sl_addrAck,
      Sl_SSize => Sl_SSize,
      Sl_wait => Sl_wait,
      Sl_rearbitrate => Sl_rearbitrate,
      Sl_wrDAck => Sl_wrDAck,
      Sl_wrComp => Sl_wrComp,
      Sl_rdDBus => Sl_rdDBus,
      Sl_rdDAck => Sl_rdDAck,
      Sl_rdComp => Sl_rdComp,
      Sl_MBusy => Sl_MBusy,
      Sl_MWrErr => Sl_MWrErr,
      Sl_MRdErr => Sl_MRdErr,
      PLB_UABus => PLB_UABus,
      PLB_SAValid => PLB_SAValid,
      PLB_rdPrim => PLB_rdPrim,
      PLB_wrPrim => PLB_wrPrim,
      PLB_abort => PLB_abort,
      PLB_busLock => PLB_busLock,
      PLB_MSize => PLB_MSize,
      PLB_lockErr => PLB_lockErr,
      PLB_wrBurst => PLB_wrBurst,
      PLB_rdBurst => PLB_rdBurst,
      PLB_wrPendReq => PLB_wrPendReq,
      PLB_rdPendReq => PLB_rdPendReq,
      PLB_wrPendPri => PLB_wrPendPri,
      PLB_rdPendPri => PLB_rdPendPri,
      PLB_reqPri => PLB_reqPri,
      PLB_TAttribute => PLB_TAttribute,
      Sl_wrBTerm => Sl_wrBTerm,
      Sl_rdWdAddr => Sl_rdWdAddr,
      Sl_rdBTerm => Sl_rdBTerm,
      Sl_MIRQ => Sl_MIRQ,
      DCR_Clk => DCR_Clk,
      DCR_Rst => DCR_Rst,
      DCR_Read => DCR_Read,
      DCR_Write => DCR_Write,
      DCR_ABus => DCR_ABus,
      DCR_Sl_DBus => DCR_Sl_DBus,
      Sl_DCRDBus => Sl_DCRDBus,
      Sl_DCRAck => Sl_DCRAck,
      SYS_TFT_Clk => SYS_TFT_Clk,
      TFT_HSYNC => TFT_HSYNC,
      TFT_VSYNC => TFT_VSYNC,
      TFT_DE => TFT_DE,
      TFT_DPS => TFT_DPS,
      TFT_VGA_CLK => TFT_VGA_CLK,
      TFT_VGA_R => TFT_VGA_R,
      TFT_VGA_G => TFT_VGA_G,
      TFT_VGA_B => TFT_VGA_B,
      TFT_DVI_CLK_P => TFT_DVI_CLK_P,
      TFT_DVI_CLK_N => TFT_DVI_CLK_N,
      TFT_DVI_DATA => TFT_DVI_DATA,
      TFT_IIC_SCL_I => TFT_IIC_SCL_I,
      TFT_IIC_SCL_O => TFT_IIC_SCL_O,
      TFT_IIC_SCL_T => TFT_IIC_SCL_T,
      TFT_IIC_SDA_I => TFT_IIC_SDA_I,
      TFT_IIC_SDA_O => TFT_IIC_SDA_O,
      TFT_IIC_SDA_T => TFT_IIC_SDA_T
    );

end architecture STRUCTURE;

