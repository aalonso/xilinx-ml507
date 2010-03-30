//-----------------------------------------------------------------------------
// ddr2_sdram_wrapper.v
//-----------------------------------------------------------------------------

  (* x_core_info = "ppc440mc_ddr2_v3_00_a" *)
module ddr2_sdram_wrapper
  (
    mc_mibclk,
    mi_mcclk90,
    mi_mcreset,
    mi_mcclkdiv2,
    mi_mcclk_200,
    mi_mcaddressvalid,
    mi_mcaddress,
    mi_mcbankconflict,
    mi_mcrowconflict,
    mi_mcbyteenable,
    mi_mcwritedata,
    mi_mcreadnotwrite,
    mi_mcwritedatavalid,
    mc_miaddrreadytoaccept,
    mc_mireaddata,
    mc_mireaddataerr,
    mc_mireaddatavalid,
    idelay_ctrl_rdy_i,
    idelay_ctrl_rdy,
    DDR2_DQ,
    DDR2_DQS,
    DDR2_DQS_N,
    DDR2_A,
    DDR2_BA,
    DDR2_RAS_N,
    DDR2_CAS_N,
    DDR2_WE_N,
    DDR2_CS_N,
    DDR2_ODT,
    DDR2_CKE,
    DDR2_DM,
    DDR2_CK,
    DDR2_CK_N
  );
  input mc_mibclk;
  input mi_mcclk90;
  input mi_mcreset;
  input mi_mcclkdiv2;
  input mi_mcclk_200;
  input mi_mcaddressvalid;
  input [0:35] mi_mcaddress;
  input mi_mcbankconflict;
  input mi_mcrowconflict;
  input [0:15] mi_mcbyteenable;
  input [0:127] mi_mcwritedata;
  input mi_mcreadnotwrite;
  input mi_mcwritedatavalid;
  output mc_miaddrreadytoaccept;
  output [0:127] mc_mireaddata;
  output mc_mireaddataerr;
  output mc_mireaddatavalid;
  input idelay_ctrl_rdy_i;
  output idelay_ctrl_rdy;
  inout [63:0] DDR2_DQ;
  inout [7:0] DDR2_DQS;
  inout [7:0] DDR2_DQS_N;
  output [12:0] DDR2_A;
  output [1:0] DDR2_BA;
  output DDR2_RAS_N;
  output DDR2_CAS_N;
  output DDR2_WE_N;
  output [0:0] DDR2_CS_N;
  output [1:0] DDR2_ODT;
  output [0:0] DDR2_CKE;
  output [7:0] DDR2_DM;
  output [1:0] DDR2_CK;
  output [1:0] DDR2_CK_N;

  ppc440mc_ddr2
    #(
      .C_DDR_BAWIDTH ( 2 ),
      .C_NUM_CLK_PAIRS ( 2 ),
      .C_DDR_DWIDTH ( 64 ),
      .C_DDR_CAWIDTH ( 10 ),
      .C_NUM_RANKS_MEM ( 1 ),
      .C_CS_BITS ( 0 ),
      .C_DDR_DM_WIDTH ( 8 ),
      .C_DQ_BITS ( 6 ),
      .C_DDR2_ODT_WIDTH ( 2 ),
      .C_DDR2_ADDT_LAT ( 0 ),
      .C_INCLUDE_ECC_SUPPORT ( 0 ),
      .C_DDR2_ODT_SETTING ( 1 ),
      .C_DQS_BITS ( 3 ),
      .C_DDR_DQS_WIDTH ( 8 ),
      .C_DDR_RAWIDTH ( 13 ),
      .C_DDR_BURST_LENGTH ( 4 ),
      .C_DDR_CAS_LAT ( 4 ),
      .C_REG_DIMM ( 0 ),
      .C_MIB_MC_CLOCK_RATIO ( 1 ),
      .C_MEM_BASEADDR ( 32'h00000000 ),
      .C_MEM_HIGHADDR ( 32'h0fffffff ),
      .C_REDUCE_DRV ( 0 ),
      .C_DDR_TREFI ( 3900 ),
      .C_DDR_TRAS ( 40000 ),
      .C_DDR_TRCD ( 15000 ),
      .C_DDR_TRFC ( 75000 ),
      .C_DDR_TRP ( 15000 ),
      .C_DDR_TRTP ( 7500 ),
      .C_DDR_TWR ( 15000 ),
      .C_DDR_TWTR ( 7500 ),
      .C_MC_MIBCLK_PERIOD_PS ( 5000 ),
      .C_IDEL_HIGH_PERF ( "TRUE" ),
      .C_SIM_ONLY ( 0 ),
      .C_NUM_IDELAYCTRL ( 3 ),
      .C_IODELAY_GRP ( "DDR2_SDRAM" ),
      .C_READ_DATA_PIPELINE ( 0 ),
      .C_FPGA_SPEED_GRADE ( 1 )
    )
    DDR2_SDRAM (
      .mc_mibclk ( mc_mibclk ),
      .mi_mcclk90 ( mi_mcclk90 ),
      .mi_mcreset ( mi_mcreset ),
      .mi_mcclkdiv2 ( mi_mcclkdiv2 ),
      .mi_mcclk_200 ( mi_mcclk_200 ),
      .mi_mcaddressvalid ( mi_mcaddressvalid ),
      .mi_mcaddress ( mi_mcaddress ),
      .mi_mcbankconflict ( mi_mcbankconflict ),
      .mi_mcrowconflict ( mi_mcrowconflict ),
      .mi_mcbyteenable ( mi_mcbyteenable ),
      .mi_mcwritedata ( mi_mcwritedata ),
      .mi_mcreadnotwrite ( mi_mcreadnotwrite ),
      .mi_mcwritedatavalid ( mi_mcwritedatavalid ),
      .mc_miaddrreadytoaccept ( mc_miaddrreadytoaccept ),
      .mc_mireaddata ( mc_mireaddata ),
      .mc_mireaddataerr ( mc_mireaddataerr ),
      .mc_mireaddatavalid ( mc_mireaddatavalid ),
      .idelay_ctrl_rdy_i ( idelay_ctrl_rdy_i ),
      .idelay_ctrl_rdy ( idelay_ctrl_rdy ),
      .DDR2_DQ ( DDR2_DQ ),
      .DDR2_DQS ( DDR2_DQS ),
      .DDR2_DQS_N ( DDR2_DQS_N ),
      .DDR2_A ( DDR2_A ),
      .DDR2_BA ( DDR2_BA ),
      .DDR2_RAS_N ( DDR2_RAS_N ),
      .DDR2_CAS_N ( DDR2_CAS_N ),
      .DDR2_WE_N ( DDR2_WE_N ),
      .DDR2_CS_N ( DDR2_CS_N ),
      .DDR2_ODT ( DDR2_ODT ),
      .DDR2_CKE ( DDR2_CKE ),
      .DDR2_DM ( DDR2_DM ),
      .DDR2_CK ( DDR2_CK ),
      .DDR2_CK_N ( DDR2_CK_N )
    );

endmodule

