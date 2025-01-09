library ieee;
   use ieee.std_logic_1164.all;

library unisim;
   use unisim.vcomponents.all;

entity xilinx_axi_pcie_ep is
   port (
      sys_clk_p_i   : in    std_logic;
      sys_clk_n_i   : in    std_logic;
      sys_rst_n_i   : in    std_logic;

      pci_exp_txp_o : out   std_logic_vector(0 downto 0);
      pci_exp_txn_o : out   std_logic_vector(0 downto 0);
      pci_exp_rxp_i : in    std_logic_vector(0 downto 0);
      pci_exp_rxn_i : in    std_logic_vector(0 downto 0)
   );
end entity xilinx_axi_pcie_ep;

architecture synthesis of xilinx_axi_pcie_ep is

   constant C_DATA_WIDTH : natural := 64;      -- RX/TX interface data width
   constant C_KEEP_WIDTH : natural := C_DATA_WIDTH / 8;

   signal   user_link_up     : std_logic;
   signal   axi_aclk_out     : std_logic;
   signal   axi_ctl_aclk_out : std_logic;
   signal   m_axi_awlock     : std_logic;
   signal   m_axi_awvalid    : std_logic;
   signal   m_axi_awready    : std_logic;
   signal   m_axi_wlast      : std_logic;
   signal   m_axi_wvalid     : std_logic;
   signal   m_axi_wready     : std_logic;
   signal   m_axi_bvalid     : std_logic;
   signal   m_axi_bready     : std_logic;
   signal   m_axi_arlock     : std_logic;
   signal   m_axi_arvalid    : std_logic;
   signal   m_axi_arready    : std_logic;
   signal   m_axi_rlast      : std_logic;
   signal   m_axi_rvalid     : std_logic;
   signal   m_axi_rready     : std_logic;

   signal   m_axi_awaddr     : std_logic_vector( 31 downto 0);
   signal   m_axi_araddr     : std_logic_vector( 31 downto 0);
   signal   m_axi_awlen   : std_logic_vector(7 downto 0);
   signal   m_axi_awsize  : std_logic_vector(2 downto 0);
   signal   m_axi_awprot  : std_logic_vector(2 downto 0);
   signal   m_axi_arprot  : std_logic_vector(2 downto 0);
   signal   m_axi_awcache : std_logic_vector(3 downto 0);
   signal   m_axi_arcache : std_logic_vector(3 downto 0);
   signal   m_axi_awburst : std_logic_vector(1 downto 0);
   signal   m_axi_bresp   : std_logic_vector(1 downto 0);
   signal   m_axi_rresp   : std_logic_vector(1 downto 0);
   signal   m_axi_wdata   : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
   signal   m_axi_rdata   : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
   signal   m_axi_wstrb   : std_logic_vector(C_KEEP_WIDTH - 1 downto 0);
   signal   m_axi_arlen   : std_logic_vector(7 downto 0);
   signal   m_axi_arsize  : std_logic_vector(2 downto 0);
   signal   m_axi_arburst : std_logic_vector(1 downto 0);


   signal   sys_rst_n_c    : std_logic;
   signal   sys_clk        : std_logic;
   signal   sys_rst_n_reg  : std_logic;
   signal   sys_rst_n_reg2 : std_logic;

   signal   mmcm_lock   : std_logic;
   signal   axi_aresetn : std_logic;

   attribute async_reg : string;
   attribute async_reg of sys_rst_n_reg  : signal is "true";
   attribute async_reg of sys_rst_n_reg2 : signal is "true";

   component axi_pcie_0 is
      port (
         axi_aresetn       : in    std_logic;
         user_link_up      : out   std_logic;
         axi_aclk_out      : out   std_logic;
         axi_ctl_aclk_out  : out   std_logic;
         mmcm_lock         : out   std_logic;
         interrupt_out     : out   std_logic;
         intx_msi_request  : in    std_logic;
         intx_msi_grant    : out   std_logic;
         msi_enable        : out   std_logic;
         msi_vector_num    : in    std_logic_vector( 4 downto 0);
         msi_vector_width  : out   std_logic_vector( 2 downto 0);
         s_axi_awid        : in    std_logic_vector( 3 downto 0);
         s_axi_awaddr      : in    std_logic_vector( 31 downto 0);
         s_axi_awregion    : in    std_logic_vector( 3 downto 0);
         s_axi_awlen       : in    std_logic_vector( 7 downto 0);
         s_axi_awsize      : in    std_logic_vector( 2 downto 0);
         s_axi_awburst     : in    std_logic_vector( 1 downto 0);
         s_axi_awvalid     : in    std_logic;
         s_axi_awready     : out   std_logic;
         s_axi_wdata       : in    std_logic_vector( 63 downto 0);
         s_axi_wstrb       : in    std_logic_vector( 7 downto 0);
         s_axi_wlast       : in    std_logic;
         s_axi_wvalid      : in    std_logic;
         s_axi_wready      : out   std_logic;
         s_axi_bid         : out   std_logic_vector( 3 downto 0);
         s_axi_bresp       : out   std_logic_vector( 1 downto 0);
         s_axi_bvalid      : out   std_logic;
         s_axi_bready      : in    std_logic;
         s_axi_arid        : in    std_logic_vector( 3 downto 0);
         s_axi_araddr      : in    std_logic_vector( 31 downto 0);
         s_axi_arregion    : in    std_logic_vector( 3 downto 0);
         s_axi_arlen       : in    std_logic_vector( 7 downto 0);
         s_axi_arsize      : in    std_logic_vector( 2 downto 0);
         s_axi_arburst     : in    std_logic_vector( 1 downto 0);
         s_axi_arvalid     : in    std_logic;
         s_axi_arready     : out   std_logic;
         s_axi_rid         : out   std_logic_vector( 3 downto 0);
         s_axi_rdata       : out   std_logic_vector( 63 downto 0);
         s_axi_rresp       : out   std_logic_vector( 1 downto 0);
         s_axi_rlast       : out   std_logic;
         s_axi_rvalid      : out   std_logic;
         s_axi_rready      : in    std_logic;
         m_axi_awaddr      : out   std_logic_vector( 31 downto 0);
         m_axi_awlen       : out   std_logic_vector( 7 downto 0);
         m_axi_awsize      : out   std_logic_vector( 2 downto 0);
         m_axi_awburst     : out   std_logic_vector( 1 downto 0);
         m_axi_awprot      : out   std_logic_vector( 2 downto 0);
         m_axi_awvalid     : out   std_logic;
         m_axi_awready     : in    std_logic;
         m_axi_awlock      : out   std_logic;
         m_axi_awcache     : out   std_logic_vector( 3 downto 0);
         m_axi_wdata       : out   std_logic_vector( 63 downto 0);
         m_axi_wstrb       : out   std_logic_vector( 7 downto 0);
         m_axi_wlast       : out   std_logic;
         m_axi_wvalid      : out   std_logic;
         m_axi_wready      : in    std_logic;
         m_axi_bresp       : in    std_logic_vector( 1 downto 0);
         m_axi_bvalid      : in    std_logic;
         m_axi_bready      : out   std_logic;
         m_axi_araddr      : out   std_logic_vector( 31 downto 0);
         m_axi_arlen       : out   std_logic_vector( 7 downto 0);
         m_axi_arsize      : out   std_logic_vector( 2 downto 0);
         m_axi_arburst     : out   std_logic_vector( 1 downto 0);
         m_axi_arprot      : out   std_logic_vector( 2 downto 0);
         m_axi_arvalid     : out   std_logic;
         m_axi_arready     : in    std_logic;
         m_axi_arlock      : out   std_logic;
         m_axi_arcache     : out   std_logic_vector( 3 downto 0);
         m_axi_rdata       : in    std_logic_vector( 63 downto 0);
         m_axi_rresp       : in    std_logic_vector( 1 downto 0);
         m_axi_rlast       : in    std_logic;
         m_axi_rvalid      : in    std_logic;
         m_axi_rready      : out   std_logic;
         pci_exp_txp       : out   std_logic_vector( 0 to 0);
         pci_exp_txn       : out   std_logic_vector( 0 to 0);
         pci_exp_rxp       : in    std_logic_vector( 0 to 0);
         pci_exp_rxn       : in    std_logic_vector( 0 to 0);
         refclk            : in    std_logic;
         s_axi_ctl_awaddr  : in    std_logic_vector( 31 downto 0);
         s_axi_ctl_awvalid : in    std_logic;
         s_axi_ctl_awready : out   std_logic;
         s_axi_ctl_wdata   : in    std_logic_vector( 31 downto 0);
         s_axi_ctl_wstrb   : in    std_logic_vector( 3 downto 0);
         s_axi_ctl_wvalid  : in    std_logic;
         s_axi_ctl_wready  : out   std_logic;
         s_axi_ctl_bresp   : out   std_logic_vector( 1 downto 0);
         s_axi_ctl_bvalid  : out   std_logic;
         s_axi_ctl_bready  : in    std_logic;
         s_axi_ctl_araddr  : in    std_logic_vector( 31 downto 0);
         s_axi_ctl_arvalid : in    std_logic;
         s_axi_ctl_arready : out   std_logic;
         s_axi_ctl_rdata   : out   std_logic_vector( 31 downto 0);
         s_axi_ctl_rresp   : out   std_logic_vector( 1 downto 0);
         s_axi_ctl_rvalid  : out   std_logic;
         s_axi_ctl_rready  : in    std_logic
      );
   end component;

   component axi_bram_ctrl_0 is
      port (
         s_axi_aclk    : in    std_logic;
         s_axi_aresetn : in    std_logic;
         s_axi_awid    : in    std_logic_vector( 3 downto 0);
         s_axi_awaddr  : in    std_logic_vector( 13 downto 0);
         s_axi_awlen   : in    std_logic_vector( 7 downto 0);
         s_axi_awsize  : in    std_logic_vector( 2 downto 0);
         s_axi_awburst : in    std_logic_vector( 1 downto 0);
         s_axi_awlock  : in    std_logic;
         s_axi_awcache : in    std_logic_vector( 3 downto 0);
         s_axi_awprot  : in    std_logic_vector( 2 downto 0);
         s_axi_awvalid : in    std_logic;
         s_axi_awready : out   std_logic;
         s_axi_wdata   : in    std_logic_vector( 63 downto 0);
         s_axi_wstrb   : in    std_logic_vector( 7 downto 0);
         s_axi_wlast   : in    std_logic;
         s_axi_wvalid  : in    std_logic;
         s_axi_wready  : out   std_logic;
         s_axi_bid     : out   std_logic_vector( 3 downto 0);
         s_axi_bresp   : out   std_logic_vector( 1 downto 0);
         s_axi_bvalid  : out   std_logic;
         s_axi_bready  : in    std_logic;
         s_axi_arid    : in    std_logic_vector( 3 downto 0);
         s_axi_araddr  : in    std_logic_vector( 13 downto 0);
         s_axi_arlen   : in    std_logic_vector( 7 downto 0);
         s_axi_arsize  : in    std_logic_vector( 2 downto 0);
         s_axi_arburst : in    std_logic_vector( 1 downto 0);
         s_axi_arlock  : in    std_logic;
         s_axi_arcache : in    std_logic_vector( 3 downto 0);
         s_axi_arprot  : in    std_logic_vector( 2 downto 0);
         s_axi_arvalid : in    std_logic;
         s_axi_arready : out   std_logic;
         s_axi_rid     : out   std_logic_vector( 3 downto 0);
         s_axi_rdata   : out   std_logic_vector( 63 downto 0);
         s_axi_rresp   : out   std_logic_vector( 1 downto 0);
         s_axi_rlast   : out   std_logic;
         s_axi_rvalid  : out   std_logic;
         s_axi_rready  : in    std_logic
      );
   end component;

begin

   sys_reset_n_ibuf_inst : component ibuf
      port map (
         i => sys_rst_n_i,
         o => sys_rst_n_c
      );

   refclk_ibuf_inst : component ibufds_gte2
      port map (
         i     => sys_clk_p_i,
         ceb   => '0',
         ib    => sys_clk_n_i,
         o     => sys_clk,
         odiv2 => open
      );

   -- Synchronize Reset

   sys_rst_n_proc : process (all)
   begin
      if not sys_rst_n_c then
         sys_rst_n_reg  <= '0';
         sys_rst_n_reg2 <= '0';
      elsif rising_edge(axi_aclk_out) then
         sys_rst_n_reg  <= '1';
         sys_rst_n_reg2 <= sys_rst_n_reg;
      end if;
   end process sys_rst_n_proc;


   axi_aresetn_proc : process (all)
   begin
      if sys_rst_n_reg2 and mmcm_lock then
         axi_aresetn <= '1';
      elsif rising_edge(axi_aclk_out) then
         axi_aresetn <= '0';
      end if;
   end process axi_aresetn_proc;


   axi_pcie_0_inst : component axi_pcie_0
      port map (
         user_link_up      => (user_link_up),
         axi_aresetn       => (axi_aresetn),
         axi_aclk_out      => (axi_aclk_out),
         axi_ctl_aclk_out  => (axi_ctl_aclk_out),
         mmcm_lock         => (mmcm_lock),
         interrupt_out     => open,
         intx_msi_request  => '0',
         intx_msi_grant    => open,
         msi_enable        => open,
         msi_vector_num    => (others => '0'),
         msi_vector_width  => open,
         s_axi_awid        => (others => '0'),
         s_axi_awaddr      => (others => '0'),
         s_axi_awregion    => (others => '0'),
         s_axi_awlen       => (others => '0'),
         s_axi_awsize      => (others => '0'),
         s_axi_awburst     => (others => '0'),
         s_axi_awvalid     => '0',
         s_axi_awready     => open,
         s_axi_wdata       => (others => '0'),
         s_axi_wstrb       => (others => '0'),
         s_axi_wlast       => '0',
         s_axi_wvalid      => '0',
         s_axi_wready      => open,
         s_axi_bid         => open,
         s_axi_bresp       => open,
         s_axi_bvalid      => open,
         s_axi_bready      => '0',
         s_axi_arid        => (others => '0'),
         s_axi_araddr      => (others => '0'),
         s_axi_arregion    => (others => '0'),
         s_axi_arlen       => (others => '0'),
         s_axi_arsize      => (others => '0'),
         s_axi_arburst     => (others => '0'),
         s_axi_arvalid     => '0',
         s_axi_arready     => open,
         s_axi_rid         => open,
         s_axi_rdata       => open,
         s_axi_rresp       => open,
         s_axi_rlast       => open,
         s_axi_rvalid      => open,
         s_axi_rready      => '0',
         m_axi_awaddr      => (m_axi_awaddr),
         m_axi_awlen       => (m_axi_awlen    ),
         m_axi_awsize      => (m_axi_awsize   ),
         m_axi_awburst     => (m_axi_awburst),
         m_axi_awprot      => (m_axi_awprot   ),
         m_axi_awvalid     => (m_axi_awvalid),
         m_axi_awready     => (m_axi_awready),
         m_axi_awlock      => (m_axi_awlock   ),
         m_axi_awcache     => (m_axi_awcache),
         m_axi_wdata       => (m_axi_wdata    ),
         m_axi_wstrb       => (m_axi_wstrb    ),
         m_axi_wlast       => (m_axi_wlast    ),
         m_axi_wvalid      => (m_axi_wvalid   ),
         m_axi_wready      => (m_axi_wready   ),
         m_axi_bresp       => (m_axi_bresp    ),
         m_axi_bvalid      => (m_axi_bvalid   ),
         m_axi_bready      => (m_axi_bready   ),
         m_axi_araddr      => (m_axi_araddr   ),
         m_axi_arlen       => (m_axi_arlen    ),
         m_axi_arsize      => (m_axi_arsize   ),
         m_axi_arburst     => (m_axi_arburst),
         m_axi_arprot      => (m_axi_arprot   ),
         m_axi_arvalid     => (m_axi_arvalid),
         m_axi_arready     => (m_axi_arready),
         m_axi_arlock      => (m_axi_arlock   ),
         m_axi_arcache     => (m_axi_arcache),
         m_axi_rdata       => (m_axi_rdata    ),
         m_axi_rresp       => (m_axi_rresp    ),
         m_axi_rlast       => (m_axi_rlast    ),
         m_axi_rvalid      => (m_axi_rvalid   ),
         m_axi_rready      => (m_axi_rready   ),
         pci_exp_txp       => ( pci_exp_txp_o ),
         pci_exp_txn       => ( pci_exp_txn_o ),
         pci_exp_rxp       => ( pci_exp_rxp_i ),
         pci_exp_rxn       => ( pci_exp_rxn_i ),
         refclk            => (sys_clk),
         s_axi_ctl_awaddr  => (others => '0'),
         s_axi_ctl_awvalid => '0',
         s_axi_ctl_awready => open,
         s_axi_ctl_wdata   => (others => '0'),
         s_axi_ctl_wstrb   => (others => '0'),
         s_axi_ctl_wvalid  => '0',
         s_axi_ctl_wready  => open,
         s_axi_ctl_bresp   => open,
         s_axi_ctl_bvalid  => open,
         s_axi_ctl_bready  => '0',
         s_axi_ctl_araddr  => (others => '0'),
         s_axi_ctl_arvalid => '0',
         s_axi_ctl_arready => open,
         s_axi_ctl_rdata   => open,
         s_axi_ctl_rresp   => open,
         s_axi_ctl_rvalid  => open,
         s_axi_ctl_rready  => '0'
      ); -- axi_pcie_0_inst

   axi_bram_ctl_inst : component axi_bram_ctrl_0
      port map (
         s_axi_aclk    => (axi_aclk_out),
         s_axi_aresetn => (axi_aresetn),
         s_axi_awid    => "0000",
         s_axi_awaddr  => (m_axi_awaddr(13 downto 0)),
         s_axi_awlen   => (m_axi_awlen),
         s_axi_awsize  => (m_axi_awsize),
         s_axi_awburst => (m_axi_awburst),
         s_axi_awlock  => (m_axi_awlock),
         s_axi_awcache => (m_axi_awcache),
         s_axi_awprot  => (m_axi_awprot),
         s_axi_awvalid => (m_axi_awvalid),
         s_axi_awready => (m_axi_awready),
         s_axi_wdata   => (m_axi_wdata),
         s_axi_wstrb   => (m_axi_wstrb),
         s_axi_wlast   => (m_axi_wlast),
         s_axi_wvalid  => (m_axi_wvalid),
         s_axi_wready  => (m_axi_wready),
         s_axi_bid     => open,
         s_axi_bresp   => (m_axi_bresp),
         s_axi_bvalid  => (m_axi_bvalid),
         s_axi_bready  => (m_axi_bready),
         s_axi_arid    => "0000",
         s_axi_araddr  => (m_axi_araddr(13 downto 0)),
         s_axi_arlen   => (m_axi_arlen),
         s_axi_arsize  => (m_axi_arsize),
         s_axi_arburst => (m_axi_arburst),
         s_axi_arlock  => (m_axi_arlock),
         s_axi_arcache => (m_axi_arcache),
         s_axi_arprot  => (m_axi_arprot),
         s_axi_arvalid => (m_axi_arvalid),
         s_axi_arready => (m_axi_arready),
         s_axi_rid     => open,
         s_axi_rdata   => (m_axi_rdata),
         s_axi_rresp   => (m_axi_rresp),
         s_axi_rlast   => (m_axi_rlast),
         s_axi_rvalid  => (m_axi_rvalid),
         s_axi_rready  => (m_axi_rready)
      ); -- axi_bram_ctl_inst

end architecture synthesis;

