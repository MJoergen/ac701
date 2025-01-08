
//-----------------------------------------------------------------------------
//
// (c) Copyright 2020-2025 Advanced Micro Devices, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of AMD and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// AMD, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND AMD HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) AMD shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or AMD had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// AMD products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of AMD products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//-----------------------------------------------------------------------------
// Project    : AXI Memory Mapped Bridge to PCI Express
// File       : xilinx_axi_pcie_ep.v
// Version    : 2.8
//-----------------------------------------------------------------------------
// Project    : AXI PCIe example design
// File       : xilinx_axi_pcie_ep.v
// Version    : 2.2 
// Description : Top-level example file
//
// Hierarchy   : consists of axi_pcie_0_support & axi_pcie_0 if both EXT_CLK< EXT_GT_COOMON are FALSE & axi_bram_ctrl_0
//               |--xilinx_axi_pcie_ep
//                  |
//                  |--axi_bram_cntrl
//                  |--axi_pcie_0 if PCIE_EXT_CLK & PCIE_EXT_GT_COMMON are FALSE
//						|
//						|--axi_pcie (axi pcie design)
//							|
//							|--<various>
//		    |--axi_pcie_0_support If either of or both PCIE_EXT_CLK & PCIE_EXT_GT_COMMON are TRUE
//						|
//						|--ext_pipe_clk(external pipe clock)
//						|--ext_gt_common(external gt common)
//						|--axi_pcie_0
//							|
//							|--axi_pcie (axi pcie design)
//								|
//								|--<various>
//
//-----------------------------------------------------------------------------

`timescale 1ns/1ns

module xilinx_axi_pcie_ep  #(
  parameter PL_FAST_TRAIN       = "FALSE", // Simulation Speedup
  parameter PCIE_EXT_CLK        = "FALSE",  // Use External Clocking Module
  parameter EXT_PIPE_SIM        = "FALSE",  // This Parameter has effect on selecting Enable External PIPE Interface in GUI.	
  parameter PCIE_EXT_GT_COMMON  = "FALSE",
  parameter REF_CLK_FREQ        = 0,
  parameter C_DATA_WIDTH        = 64, // RX/TX interface data width
  parameter KEEP_WIDTH          = C_DATA_WIDTH / 8
) (

  output  [0:0]    pci_exp_txp,
  output  [0:0]    pci_exp_txn,
  input   [0:0]    pci_exp_rxp,
  input   [0:0]    pci_exp_rxn,




  input                  sys_clk_p,
  input                  sys_clk_n,
  input                  sys_rst_n
);
wire user_link_up;
wire axi_aclk_out;
wire axi_ctl_aclk_out;
wire m_axi_awlock;
wire m_axi_awvalid;	
wire m_axi_awready;	
wire m_axi_wlast  ;      
wire m_axi_wvalid ;      
wire m_axi_wready ;      
wire m_axi_bvalid ;      
wire m_axi_bready ;      
wire m_axi_arlock ;      
wire m_axi_arvalid;	
wire m_axi_arready;	
wire m_axi_rlast  ;      
wire m_axi_rvalid ;      
wire m_axi_rready ; 

wire [7 : 0] 	m_axi_awlen;
wire [2 : 0] 	m_axi_awsize;
wire [2 : 0] 	m_axi_awprot;
wire [2 : 0] 	m_axi_arprot;
wire [3 : 0] 	m_axi_awcache;
wire [3 : 0] 	m_axi_arcache;
wire [1 : 0] 	m_axi_awburst;
wire [1 : 0] 	bresp;
wire [1 : 0] 	rresp;
wire [(C_DATA_WIDTH - 1) : 0]	m_axi_wdata;
wire [(C_DATA_WIDTH - 1) : 0]	rdata;
wire [(KEEP_WIDTH -1) : 0]	m_axi_wstrb;
wire [7 : 0] 	m_axi_arlen;
wire [2 : 0] 	m_axi_arsize;
wire [1 : 0] 	m_axi_arburst;

wire [1 : 0] 	m_axi_bresp = bresp[1:0];
wire [1 : 0] 	m_axi_rresp = rresp[1:0];
wire [7 : 0] 	awlen =   m_axi_awlen	[7 : 0] ;
wire [2 : 0] 	awsize= m_axi_awsize	[2 : 0] ;
wire [2 : 0] 	awprot= m_axi_awprot	[2 : 0] ;
wire [2 : 0] 	arprot= m_axi_arprot	[2 : 0] ;
wire [3 : 0] 	awcache= m_axi_awcache	[3 : 0] ;
wire [3 : 0] 	arcache= m_axi_arcache	[3 : 0] ;
wire [1 : 0] 	awburst=m_axi_awburst	[1 : 0] ;
wire [(C_DATA_WIDTH -1) : 0]	wdata=  m_axi_wdata	[(C_DATA_WIDTH -1) : 0];
wire [(C_DATA_WIDTH -1) : 0]	m_axi_rdata=  rdata	[(C_DATA_WIDTH -1) : 0];
wire [(KEEP_WIDTH -1) : 0]	wstrb=  m_axi_wstrb	[(KEEP_WIDTH -1) : 0] ;
wire [7 : 0] 	arlen=  m_axi_arlen	[7 : 0] ;
wire [2 : 0] 	arsize= m_axi_arsize	[2 : 0] ;
wire [1 : 0] 	arburst=m_axi_arburst	[1 : 0] ;

wire [31:0]  m_axi_araddr;
wire [31:0]  m_axi_awaddr;
wire       [13:0]    awaddr = m_axi_awaddr[13:0];
wire       [13:0]    araddr = m_axi_araddr[13:0];
 //-------------------------------------------------------
  // 5. External Channel DRP Interface
  //-------------------------------------------------------
//  wire                                                    ext_ch_gt_drpclk;
  wire        [8:0]  ext_ch_gt_drpaddr;
  wire        [0:0]    ext_ch_gt_drpen;
  wire        [15:0]  ext_ch_gt_drpdi;
  wire        [0:0]    ext_ch_gt_drpwe;
 //--------------------Tie-off's for EXT GT Channel DRP ports----------------------------//
//  assign        ext_ch_gt_drpclk=1'b0;
  assign        ext_ch_gt_drpaddr = 9'd0;
  assign        ext_ch_gt_drpen=1'd0;
  assign        ext_ch_gt_drpdi=16'd0;
  assign        ext_ch_gt_drpwe=1'd0;


  //-------------------------------------------------------
  reg pipe_mmcm_rst_n = 1'b1;


  wire sys_rst_n_c;
  wire sys_clk;

// Local Parameters
  localparam                                  TCQ = 1;

  localparam USER_CLK_FREQ = 1;
  localparam USER_CLK2_DIV2 = "FALSE";
  localparam USERCLK2_FREQ   =  (USER_CLK2_DIV2 == "FALSE") ? USER_CLK_FREQ : 
                                                             (USER_CLK_FREQ == 4) ? 3 :
                                                             (USER_CLK_FREQ == 3) ? 2 :
                                                             (USER_CLK_FREQ == 2) ? 1 :
                                                              USER_CLK_FREQ;


  IBUF   sys_reset_n_ibuf (.O(sys_rst_n_c), .I(sys_rst_n));
  IBUFDS_GTE2 refclk_ibuf (.O(sys_clk), .ODIV2(), .I(sys_clk_p), .CEB(1'b0), .IB(sys_clk_n));

  // Synchronize Reset
  wire mmcm_lock;
  reg axi_aresetn;
(* ASYNC_REG = "TRUE" *)  reg sys_rst_n_reg;
(* ASYNC_REG = "TRUE" *)  reg sys_rst_n_reg2;
  
  always @ (posedge axi_aclk_out or negedge sys_rst_n_c) begin
  
      if (!sys_rst_n_c) begin
      
          sys_rst_n_reg  <= #TCQ 1'b0;
          sys_rst_n_reg2 <= #TCQ 1'b0;
          
      end else begin
      
          sys_rst_n_reg  <= #TCQ 1'b1;
          sys_rst_n_reg2 <= #TCQ sys_rst_n_reg;
          
      end
      
  end
  
  always @ (posedge axi_aclk_out) begin
  
      if (sys_rst_n_reg2 && mmcm_lock) begin
      
          axi_aresetn <= #TCQ 1'b1;
          
      end else begin
      
          axi_aresetn <= #TCQ 1'b0;
          
      end
  
  end
  
  //
  // Simulation endpoint without CSL
  //

axi_pcie_0 axi_pcie_0_i
 (
  .user_link_up     (user_link_up),
  .axi_aresetn		(axi_aresetn),
  .axi_aclk_out		(axi_aclk_out),
  .axi_ctl_aclk_out	(axi_ctl_aclk_out),	
  .mmcm_lock		(mmcm_lock),	
  .interrupt_out	(),	
  .INTX_MSI_Request	(1'b0),	
  .INTX_MSI_Grant	(),	
  .MSI_enable		(),	
  .MSI_Vector_Num	(5'b0),	
  .MSI_Vector_Width	(),		
  .s_axi_awid		(4'b0),	
  .s_axi_awaddr		(32'b0),	
  .s_axi_awregion	(4'b0),		
  .s_axi_awlen		(8'b0),	
  .s_axi_awsize		(3'b0),		
  .s_axi_awburst	(2'b0),			
  .s_axi_awvalid	(1'b0),		
  .s_axi_awready	(),		
  .s_axi_wdata		(64'b0),		
  .s_axi_wstrb		(8'b0),			
  .s_axi_wlast		(1'b0),		
  .s_axi_wvalid		(1'b0),		
  .s_axi_wready		(),		
  .s_axi_bid		(),	
  .s_axi_bresp		(),	
  .s_axi_bvalid		(),		
  .s_axi_bready		(1'b0),		
  .s_axi_arid		(4'b0),		
  .s_axi_araddr		(32'b0),		
  .s_axi_arregion	(4'b0),		
  .s_axi_arlen		(8'b0),	
  .s_axi_arsize		(3'b0),		
  .s_axi_arburst	(2'b0),
  .s_axi_arvalid	(1'b0),
  .s_axi_arready	(),
  .s_axi_rid		(),
  .s_axi_rdata		(),	
  .s_axi_rresp		(),
  .s_axi_rlast		(),
  .s_axi_rvalid		(),
  .s_axi_rready		(1'b0),
  .m_axi_awaddr		(m_axi_awaddr),
  .m_axi_awlen		(m_axi_awlen	),
  .m_axi_awsize		(m_axi_awsize	),
  .m_axi_awburst	(m_axi_awburst),
  .m_axi_awprot		(m_axi_awprot	),
  .m_axi_awvalid	(m_axi_awvalid),
  .m_axi_awready	(m_axi_awready),	
  .m_axi_awlock		(m_axi_awlock	),
  .m_axi_awcache	(m_axi_awcache),
  .m_axi_wdata		(m_axi_wdata	),
  .m_axi_wstrb		(m_axi_wstrb	),
  .m_axi_wlast		(m_axi_wlast	),
  .m_axi_wvalid		(m_axi_wvalid	),
  .m_axi_wready		(m_axi_wready	),
  .m_axi_bresp		(m_axi_bresp	),
  .m_axi_bvalid		(m_axi_bvalid	),
  .m_axi_bready		(m_axi_bready	),
  .m_axi_araddr		(m_axi_araddr	),
  .m_axi_arlen		(m_axi_arlen	),
  .m_axi_arsize		(m_axi_arsize	),
  .m_axi_arburst	(m_axi_arburst),
  .m_axi_arprot		(m_axi_arprot	),
  .m_axi_arvalid	(m_axi_arvalid),
  .m_axi_arready	(m_axi_arready),
  .m_axi_arlock		(m_axi_arlock	),
  .m_axi_arcache	(m_axi_arcache),       
  .m_axi_rdata		(m_axi_rdata	),
  .m_axi_rresp		(m_axi_rresp	),
  .m_axi_rlast		(m_axi_rlast	),
  .m_axi_rvalid		(m_axi_rvalid	),
  .m_axi_rready		(m_axi_rready	),
  .pci_exp_txp          ( pci_exp_txp ),
  .pci_exp_txn          ( pci_exp_txn ),
  .pci_exp_rxp          ( pci_exp_rxp ),
  .pci_exp_rxn          ( pci_exp_rxn ),
  .REFCLK		(sys_clk),
  .s_axi_ctl_awaddr	(32'b0),
  .s_axi_ctl_awvalid	(1'b0),
  .s_axi_ctl_awready	(),
  .s_axi_ctl_wdata	(32'b0),
  .s_axi_ctl_wstrb	(4'b0),
  .s_axi_ctl_wvalid	(1'b0),
  .s_axi_ctl_wready	(),
  .s_axi_ctl_bresp	(),
  .s_axi_ctl_bvalid	(),
  .s_axi_ctl_bready	(1'b0),
  .s_axi_ctl_araddr	(32'b0),
  .s_axi_ctl_arvalid	(1'b0),
  .s_axi_ctl_arready	(),
  .s_axi_ctl_rdata	(),
  .s_axi_ctl_rresp	(),
  .s_axi_ctl_rvalid	(),

  .s_axi_ctl_rready	(1'b0)

	
);

     
    //example design BRAM Controller
    axi_bram_ctrl_0 AXI_BRAM_CTL(
      .s_axi_aclk 	(axi_aclk_out),
      .s_axi_aresetn 	(axi_aresetn),
      .s_axi_awid 	(4'b0),
      .s_axi_awaddr 	(awaddr),
      .s_axi_awlen 	(awlen),
      .s_axi_awsize 	(awsize),
      .s_axi_awburst 	(awburst),
      .s_axi_awlock 	(m_axi_awlock),
      .s_axi_awcache 	(awcache),
      .s_axi_awprot 	(awprot),
      .s_axi_awvalid	(m_axi_awvalid),
      .s_axi_awready 	(m_axi_awready),
      .s_axi_wdata 	(wdata),
      .s_axi_wstrb	(wstrb),
      .s_axi_wlast 	(m_axi_wlast),
      .s_axi_wvalid 	(m_axi_wvalid),
      .s_axi_wready 	(m_axi_wready),
      .s_axi_bid	(),
      .s_axi_bresp 	(bresp),
      .s_axi_bvalid	(m_axi_bvalid),
      .s_axi_bready 	(m_axi_bready),
      .s_axi_arid 	(4'b0),
      .s_axi_araddr 	(araddr),
      .s_axi_arlen      (arlen),
      .s_axi_arsize	(arsize),
      .s_axi_arburst 	(arburst),
      .s_axi_arlock	(m_axi_arlock),
      .s_axi_arcache 	(arcache),
      .s_axi_arprot	(arprot),
      .s_axi_arvalid 	(m_axi_arvalid),
      .s_axi_arready 	(m_axi_arready),
      .s_axi_rid	(),
      .s_axi_rdata      (rdata),
      .s_axi_rresp      (rresp),
      .s_axi_rlast      (m_axi_rlast),
      .s_axi_rvalid	(m_axi_rvalid),
      .s_axi_rready	(m_axi_rready)
);



endmodule // BOARD


