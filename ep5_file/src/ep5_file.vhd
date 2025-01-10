library ieee;
   use ieee.std_logic_1164.all;

library unisim;
   use unisim.vcomponents.all;

library xpm;
   use xpm.vcomponents.all;

entity ep5_file is
   generic (
      G_AXI_CLK_HZ    : natural := 62_500_000;
      G_UART_BAUDRATE : natural := 115_200
   );
   port (
      pcie_clk_qo_p_i : in    std_logic; -- GT Ref Clock
      pcie_clk_qo_n_i : in    std_logic;
      pcie_perst_i    : in    std_logic; -- Active low

      usb_uart_tx_o   : out   std_logic;
      usb_uart_rx_i   : in    std_logic;

      pci_exp_txp_o   : out   std_logic_vector(0 downto 0);
      pci_exp_txn_o   : out   std_logic_vector(0 downto 0);
      pci_exp_rxp_i   : in    std_logic_vector(0 downto 0);
      pci_exp_rxn_i   : in    std_logic_vector(0 downto 0)
   );
end entity ep5_file;

architecture synthesis of ep5_file is

   constant C_DATA_WIDTH : natural := 64; -- RX/TX interface data width

   -- Clock and reset
   signal   pcie_clk_qo : std_logic;      -- 100 MHz
   signal   pcie_perst  : std_logic;      -- Active low
   signal   mmcm_lock   : std_logic;
   signal   axi_clk     : std_logic;      -- 62.5 MHz
   signal   axi_rst     : std_logic;      -- Active high

   signal   axi_uart_rx_ready : std_logic;
   signal   axi_uart_rx_valid : std_logic;
   signal   axi_uart_rx_data  : std_logic_vector(7 downto 0);
   signal   axi_uart_tx_ready : std_logic;
   signal   axi_uart_tx_valid : std_logic;
   signal   axi_uart_tx_data  : std_logic_vector(7 downto 0);

   signal   m_axi_awaddr  : std_logic_vector(31 downto 0);
   signal   m_axi_awburst : std_logic_vector(1 downto 0);
   signal   m_axi_awcache : std_logic_vector(3 downto 0);
   signal   m_axi_awlen   : std_logic_vector(7 downto 0);
   signal   m_axi_awlock  : std_logic;
   signal   m_axi_awprot  : std_logic_vector(2 downto 0);
   signal   m_axi_awready : std_logic;
   signal   m_axi_awsize  : std_logic_vector(2 downto 0);
   signal   m_axi_awvalid : std_logic;
   signal   m_axi_wdata   : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
   signal   m_axi_wlast   : std_logic;
   signal   m_axi_wready  : std_logic;
   signal   m_axi_wstrb   : std_logic_vector(C_DATA_WIDTH / 8 - 1 downto 0);
   signal   m_axi_wvalid  : std_logic;
   signal   m_axi_bready  : std_logic;
   signal   m_axi_bresp   : std_logic_vector(1 downto 0);
   signal   m_axi_bvalid  : std_logic;
   signal   m_axi_araddr  : std_logic_vector(31 downto 0);
   signal   m_axi_arburst : std_logic_vector(1 downto 0);
   signal   m_axi_arcache : std_logic_vector(3 downto 0);
   signal   m_axi_arlen   : std_logic_vector(7 downto 0);
   signal   m_axi_arlock  : std_logic;
   signal   m_axi_arprot  : std_logic_vector(2 downto 0);
   signal   m_axi_arready : std_logic;
   signal   m_axi_arsize  : std_logic_vector(2 downto 0);
   signal   m_axi_arvalid : std_logic;
   signal   m_axi_rdata   : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
   signal   m_axi_rlast   : std_logic;
   signal   m_axi_rready  : std_logic;
   signal   m_axi_rresp   : std_logic_vector(1 downto 0);
   signal   m_axi_rvalid  : std_logic;

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
         msi_vector_num    : in    std_logic_vector(4 downto 0);
         msi_vector_width  : out   std_logic_vector(2 downto 0);
         s_axi_awid        : in    std_logic_vector(3 downto 0);
         s_axi_awaddr      : in    std_logic_vector(31 downto 0);
         s_axi_awregion    : in    std_logic_vector(3 downto 0);
         s_axi_awlen       : in    std_logic_vector(7 downto 0);
         s_axi_awsize      : in    std_logic_vector(2 downto 0);
         s_axi_awburst     : in    std_logic_vector(1 downto 0);
         s_axi_awvalid     : in    std_logic;
         s_axi_awready     : out   std_logic;
         s_axi_wdata       : in    std_logic_vector(63 downto 0);
         s_axi_wstrb       : in    std_logic_vector(7 downto 0);
         s_axi_wlast       : in    std_logic;
         s_axi_wvalid      : in    std_logic;
         s_axi_wready      : out   std_logic;
         s_axi_bid         : out   std_logic_vector(3 downto 0);
         s_axi_bresp       : out   std_logic_vector(1 downto 0);
         s_axi_bvalid      : out   std_logic;
         s_axi_bready      : in    std_logic;
         s_axi_arid        : in    std_logic_vector(3 downto 0);
         s_axi_araddr      : in    std_logic_vector(31 downto 0);
         s_axi_arregion    : in    std_logic_vector(3 downto 0);
         s_axi_arlen       : in    std_logic_vector(7 downto 0);
         s_axi_arsize      : in    std_logic_vector(2 downto 0);
         s_axi_arburst     : in    std_logic_vector(1 downto 0);
         s_axi_arvalid     : in    std_logic;
         s_axi_arready     : out   std_logic;
         s_axi_rid         : out   std_logic_vector(3 downto 0);
         s_axi_rdata       : out   std_logic_vector(63 downto 0);
         s_axi_rresp       : out   std_logic_vector(1 downto 0);
         s_axi_rlast       : out   std_logic;
         s_axi_rvalid      : out   std_logic;
         s_axi_rready      : in    std_logic;
         m_axi_awaddr      : out   std_logic_vector(31 downto 0);
         m_axi_awlen       : out   std_logic_vector(7 downto 0);
         m_axi_awsize      : out   std_logic_vector(2 downto 0);
         m_axi_awburst     : out   std_logic_vector(1 downto 0);
         m_axi_awprot      : out   std_logic_vector(2 downto 0);
         m_axi_awvalid     : out   std_logic;
         m_axi_awready     : in    std_logic;
         m_axi_awlock      : out   std_logic;
         m_axi_awcache     : out   std_logic_vector(3 downto 0);
         m_axi_wdata       : out   std_logic_vector(63 downto 0);
         m_axi_wstrb       : out   std_logic_vector(7 downto 0);
         m_axi_wlast       : out   std_logic;
         m_axi_wvalid      : out   std_logic;
         m_axi_wready      : in    std_logic;
         m_axi_bresp       : in    std_logic_vector(1 downto 0);
         m_axi_bvalid      : in    std_logic;
         m_axi_bready      : out   std_logic;
         m_axi_araddr      : out   std_logic_vector(31 downto 0);
         m_axi_arlen       : out   std_logic_vector(7 downto 0);
         m_axi_arsize      : out   std_logic_vector(2 downto 0);
         m_axi_arburst     : out   std_logic_vector(1 downto 0);
         m_axi_arprot      : out   std_logic_vector(2 downto 0);
         m_axi_arvalid     : out   std_logic;
         m_axi_arready     : in    std_logic;
         m_axi_arlock      : out   std_logic;
         m_axi_arcache     : out   std_logic_vector(3 downto 0);
         m_axi_rdata       : in    std_logic_vector(63 downto 0);
         m_axi_rresp       : in    std_logic_vector(1 downto 0);
         m_axi_rlast       : in    std_logic;
         m_axi_rvalid      : in    std_logic;
         m_axi_rready      : out   std_logic;
         pci_exp_txp       : out   std_logic_vector(0 to 0);
         pci_exp_txn       : out   std_logic_vector(0 to 0);
         pci_exp_rxp       : in    std_logic_vector(0 to 0);
         pci_exp_rxn       : in    std_logic_vector(0 to 0);
         refclk            : in    std_logic;
         s_axi_ctl_awaddr  : in    std_logic_vector(31 downto 0);
         s_axi_ctl_awvalid : in    std_logic;
         s_axi_ctl_awready : out   std_logic;
         s_axi_ctl_wdata   : in    std_logic_vector(31 downto 0);
         s_axi_ctl_wstrb   : in    std_logic_vector(3 downto 0);
         s_axi_ctl_wvalid  : in    std_logic;
         s_axi_ctl_wready  : out   std_logic;
         s_axi_ctl_bresp   : out   std_logic_vector(1 downto 0);
         s_axi_ctl_bvalid  : out   std_logic;
         s_axi_ctl_bready  : in    std_logic;
         s_axi_ctl_araddr  : in    std_logic_vector(31 downto 0);
         s_axi_ctl_arvalid : in    std_logic;
         s_axi_ctl_arready : out   std_logic;
         s_axi_ctl_rdata   : out   std_logic_vector(31 downto 0);
         s_axi_ctl_rresp   : out   std_logic_vector(1 downto 0);
         s_axi_ctl_rvalid  : out   std_logic;
         s_axi_ctl_rready  : in    std_logic
      );
   end component;

begin

   -------------------
   -- Clock and Reset
   -------------------

   pcie_clk_qo_inst : component ibufds_gte2
      port map (
         i     => pcie_clk_qo_p_i,
         ceb   => '0',
         ib    => pcie_clk_qo_n_i,
         o     => pcie_clk_qo,
         odiv2 => open
      );

   sys_reset_n_ibuf_inst : component ibuf
      port map (
         i => pcie_perst_i,
         o => pcie_perst
      );

   xpm_cdc_async_rst_inst : component xpm_cdc_async_rst
      generic map (
         RST_ACTIVE_HIGH => 1
      )
      port map (
         src_arst  => (not mmcm_lock) or (not pcie_perst),
         dest_clk  => axi_clk,
         dest_arst => axi_rst
      ); -- xpm_cdc_async_rst_inst


   ---------------
   -- Application
   ---------------

   application_inst : entity work.application
      generic map (
         G_AXI_CLK_HZ    => G_AXI_CLK_HZ,
         G_UART_BAUDRATE => G_UART_BAUDRATE
      )
      port map (
         clk_i           => axi_clk,
         rst_i           => axi_rst,
         axi_awaddr_i    => m_axi_awaddr(15 downto 0),
         axi_awlen_i     => m_axi_awlen,
         axi_awsize_i    => m_axi_awsize,
         axi_awburst_i   => m_axi_awburst,
         axi_awlock_i    => m_axi_awlock,
         axi_awcache_i   => m_axi_awcache,
         axi_awprot_i    => m_axi_awprot,
         axi_awvalid_i   => m_axi_awvalid,
         axi_awready_o   => m_axi_awready,
         axi_wdata_i     => m_axi_wdata,
         axi_wstrb_i     => m_axi_wstrb,
         axi_wlast_i     => m_axi_wlast,
         axi_wvalid_i    => m_axi_wvalid,
         axi_wready_o    => m_axi_wready,
         axi_bresp_o     => m_axi_bresp,
         axi_bvalid_o    => m_axi_bvalid,
         axi_bready_i    => m_axi_bready,
         axi_araddr_i    => m_axi_araddr(15 downto 0),
         axi_arlen_i     => m_axi_arlen,
         axi_arsize_i    => m_axi_arsize,
         axi_arburst_i   => m_axi_arburst,
         axi_arlock_i    => m_axi_arlock,
         axi_arcache_i   => m_axi_arcache,
         axi_arprot_i    => m_axi_arprot,
         axi_arvalid_i   => m_axi_arvalid,
         axi_arready_o   => m_axi_arready,
         axi_rdata_o     => m_axi_rdata,
         axi_rresp_o     => m_axi_rresp,
         axi_rlast_o     => m_axi_rlast,
         axi_rvalid_o    => m_axi_rvalid,
         axi_rready_i    => m_axi_rready,
         uart_rx_ready_o => axi_uart_rx_ready,
         uart_rx_valid_i => axi_uart_rx_valid,
         uart_rx_data_i  => axi_uart_rx_data,
         uart_tx_ready_i => axi_uart_tx_ready,
         uart_tx_valid_o => axi_uart_tx_valid,
         uart_tx_data_o  => axi_uart_tx_data
      ); -- application_inst


   -------------
   -- Board I/O
   -------------

   uart_inst : entity work.uart
      generic map (
         G_DIVISOR => G_AXI_CLK_HZ / G_UART_BAUDRATE
      )
      port map (
         clk_i      => axi_clk,
         rst_i      => axi_rst,
         uart_rx_i  => usb_uart_rx_i,
         uart_tx_o  => usb_uart_tx_o,
         rx_ready_i => axi_uart_rx_ready,
         rx_valid_o => axi_uart_rx_valid,
         rx_data_o  => axi_uart_rx_data,
         tx_ready_o => axi_uart_tx_ready,
         tx_valid_i => axi_uart_tx_valid,
         tx_data_i  => axi_uart_tx_data
      ); -- uart_inst

   axi_pcie_0_inst : component axi_pcie_0
      port map (
         user_link_up      => open,
         axi_aresetn       => not axi_rst,
         axi_aclk_out      => axi_clk,
         axi_ctl_aclk_out  => open,
         mmcm_lock         => mmcm_lock,
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
         m_axi_awaddr      => m_axi_awaddr,
         m_axi_awlen       => m_axi_awlen,
         m_axi_awsize      => m_axi_awsize,
         m_axi_awburst     => m_axi_awburst,
         m_axi_awprot      => m_axi_awprot,
         m_axi_awvalid     => m_axi_awvalid,
         m_axi_awready     => m_axi_awready,
         m_axi_awlock      => m_axi_awlock,
         m_axi_awcache     => m_axi_awcache,
         m_axi_wdata       => m_axi_wdata,
         m_axi_wstrb       => m_axi_wstrb,
         m_axi_wlast       => m_axi_wlast,
         m_axi_wvalid      => m_axi_wvalid,
         m_axi_wready      => m_axi_wready,
         m_axi_bresp       => m_axi_bresp,
         m_axi_bvalid      => m_axi_bvalid,
         m_axi_bready      => m_axi_bready,
         m_axi_araddr      => m_axi_araddr,
         m_axi_arlen       => m_axi_arlen,
         m_axi_arsize      => m_axi_arsize,
         m_axi_arburst     => m_axi_arburst,
         m_axi_arprot      => m_axi_arprot,
         m_axi_arvalid     => m_axi_arvalid,
         m_axi_arready     => m_axi_arready,
         m_axi_arlock      => m_axi_arlock,
         m_axi_arcache     => m_axi_arcache,
         m_axi_rdata       => m_axi_rdata,
         m_axi_rresp       => m_axi_rresp,
         m_axi_rlast       => m_axi_rlast,
         m_axi_rvalid      => m_axi_rvalid,
         m_axi_rready      => m_axi_rready,
         pci_exp_txp       => pci_exp_txp_o,
         pci_exp_txn       => pci_exp_txn_o,
         pci_exp_rxp       => pci_exp_rxp_i,
         pci_exp_rxn       => pci_exp_rxn_i,
         refclk            => pcie_clk_qo,
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

end architecture synthesis;

