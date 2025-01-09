library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std_unsigned.all;

entity application is
   generic (
      G_AXI_CLK_HZ    : natural := 100_000_000;
      G_UART_BAUDRATE : natural := 115_200
   );
   port (
      clk_i           : in    std_logic;
      rst_i           : in    std_logic;
      axi_awaddr_i    : in    std_logic_vector(13 downto 0);
      axi_awlen_i     : in    std_logic_vector(7 downto 0);
      axi_awsize_i    : in    std_logic_vector(2 downto 0);
      axi_awburst_i   : in    std_logic_vector(1 downto 0);
      axi_awlock_i    : in    std_logic;
      axi_awcache_i   : in    std_logic_vector(3 downto 0);
      axi_awprot_i    : in    std_logic_vector(2 downto 0);
      axi_awvalid_i   : in    std_logic;
      axi_awready_o   : out   std_logic;
      axi_wdata_i     : in    std_logic_vector(63 downto 0);
      axi_wstrb_i     : in    std_logic_vector(7 downto 0);
      axi_wlast_i     : in    std_logic;
      axi_wvalid_i    : in    std_logic;
      axi_wready_o    : out   std_logic;
      axi_bresp_o     : out   std_logic_vector(1 downto 0);
      axi_bvalid_o    : out   std_logic;
      axi_bready_i    : in    std_logic;
      axi_araddr_i    : in    std_logic_vector(13 downto 0);
      axi_arlen_i     : in    std_logic_vector(7 downto 0);
      axi_arsize_i    : in    std_logic_vector(2 downto 0);
      axi_arburst_i   : in    std_logic_vector(1 downto 0);
      axi_arlock_i    : in    std_logic;
      axi_arcache_i   : in    std_logic_vector(3 downto 0);
      axi_arprot_i    : in    std_logic_vector(2 downto 0);
      axi_arvalid_i   : in    std_logic;
      axi_arready_o   : out   std_logic;
      axi_rdata_o     : out   std_logic_vector(63 downto 0);
      axi_rresp_o     : out   std_logic_vector(1 downto 0);
      axi_rlast_o     : out   std_logic;
      axi_rvalid_o    : out   std_logic;
      axi_rready_i    : in    std_logic;
      uart_rx_ready_o : out   std_logic;
      uart_rx_valid_i : in    std_logic;
      uart_rx_data_i  : in    std_logic_vector(7 downto 0);
      uart_tx_ready_i : in    std_logic;
      uart_tx_valid_o : out   std_logic;
      uart_tx_data_o  : out   std_logic_vector(7 downto 0)
   );
end entity application;

architecture synthesis of application is

   -- Convert ASCII string to std_logic_vector

   pure function str2slv (
      str : string
   ) return std_logic_vector is
      variable res_v : std_logic_vector(str'length * 8 - 1 downto 0);
   begin
      --
      for i in 0 to str'length-1 loop
         res_v(8 * i + 7 downto 8 * i) := to_stdlogicvector(character'pos(str(str'length - i)), 8);
      end loop;

      return res_v;
   end function str2slv;

   constant C_CRLF : string(1 to 2)                                              := "" & character'val(13) & character'val(10);

   constant C_START_STR : string                                                 := C_CRLF & "ep4_uart" & C_CRLF & C_CRLF;

   constant C_START_DATA : std_logic_vector(C_START_STR'length * 8 - 1 downto 0) := str2slv(C_START_STR);

   signal   start_ready : std_logic;
   signal   start_valid : std_logic;

   component axi_bram_ctrl_0 is
      port (
         s_axi_aclk    : in    std_logic;
         s_axi_aresetn : in    std_logic;
         s_axi_awid    : in    std_logic_vector(3 downto 0);
         s_axi_awaddr  : in    std_logic_vector(13 downto 0);
         s_axi_awlen   : in    std_logic_vector(7 downto 0);
         s_axi_awsize  : in    std_logic_vector(2 downto 0);
         s_axi_awburst : in    std_logic_vector(1 downto 0);
         s_axi_awlock  : in    std_logic;
         s_axi_awcache : in    std_logic_vector(3 downto 0);
         s_axi_awprot  : in    std_logic_vector(2 downto 0);
         s_axi_awvalid : in    std_logic;
         s_axi_awready : out   std_logic;
         s_axi_wdata   : in    std_logic_vector(63 downto 0);
         s_axi_wstrb   : in    std_logic_vector(7 downto 0);
         s_axi_wlast   : in    std_logic;
         s_axi_wvalid  : in    std_logic;
         s_axi_wready  : out   std_logic;
         s_axi_bid     : out   std_logic_vector(3 downto 0);
         s_axi_bresp   : out   std_logic_vector(1 downto 0);
         s_axi_bvalid  : out   std_logic;
         s_axi_bready  : in    std_logic;
         s_axi_arid    : in    std_logic_vector(3 downto 0);
         s_axi_araddr  : in    std_logic_vector(13 downto 0);
         s_axi_arlen   : in    std_logic_vector(7 downto 0);
         s_axi_arsize  : in    std_logic_vector(2 downto 0);
         s_axi_arburst : in    std_logic_vector(1 downto 0);
         s_axi_arlock  : in    std_logic;
         s_axi_arcache : in    std_logic_vector(3 downto 0);
         s_axi_arprot  : in    std_logic_vector(2 downto 0);
         s_axi_arvalid : in    std_logic;
         s_axi_arready : out   std_logic;
         s_axi_rid     : out   std_logic_vector(3 downto 0);
         s_axi_rdata   : out   std_logic_vector(63 downto 0);
         s_axi_rresp   : out   std_logic_vector(1 downto 0);
         s_axi_rlast   : out   std_logic;
         s_axi_rvalid  : out   std_logic;
         s_axi_rready  : in    std_logic
      );
   end component;

begin

   uart_rx_ready_o <= '1';

   serializer_inst : entity work.serializer
      generic map (
         G_DATA_SIZE_IN  => C_START_DATA'length,
         G_DATA_SIZE_OUT => 8
      )
      port map (
         clk_i     => clk_i,
         rst_i     => rst_i,
         s_ready_o => start_ready,
         s_valid_i => start_valid,
         s_data_i  => C_START_DATA,
         m_ready_i => uart_tx_ready_i,
         m_valid_o => uart_tx_valid_o,
         m_data_o  => uart_tx_data_o
      ); -- serializer_inst

   start_proc : process (clk_i)
   begin
      if rising_edge(clk_i) then
         if start_ready = '1' then
            start_valid <= '0';
         end if;

         if rst_i = '1' then
            start_valid <= '1';
         end if;
      end if;
   end process start_proc;

   axi_bram_ctl_inst : component axi_bram_ctrl_0
      port map (
         s_axi_aclk    => clk_i,
         s_axi_aresetn => not rst_i,
         s_axi_awid    => "0000",
         s_axi_awaddr  => axi_awaddr_i,
         s_axi_awlen   => axi_awlen_i,
         s_axi_awsize  => axi_awsize_i,
         s_axi_awburst => axi_awburst_i,
         s_axi_awlock  => axi_awlock_i,
         s_axi_awcache => axi_awcache_i,
         s_axi_awprot  => axi_awprot_i,
         s_axi_awvalid => axi_awvalid_i,
         s_axi_awready => axi_awready_o,
         s_axi_wdata   => axi_wdata_i,
         s_axi_wstrb   => axi_wstrb_i,
         s_axi_wlast   => axi_wlast_i,
         s_axi_wvalid  => axi_wvalid_i,
         s_axi_wready  => axi_wready_o,
         s_axi_bid     => open,
         s_axi_bresp   => axi_bresp_o,
         s_axi_bvalid  => axi_bvalid_o,
         s_axi_bready  => axi_bready_i,
         s_axi_arid    => "0000",
         s_axi_araddr  => axi_araddr_i,
         s_axi_arlen   => axi_arlen_i,
         s_axi_arsize  => axi_arsize_i,
         s_axi_arburst => axi_arburst_i,
         s_axi_arlock  => axi_arlock_i,
         s_axi_arcache => axi_arcache_i,
         s_axi_arprot  => axi_arprot_i,
         s_axi_arvalid => axi_arvalid_i,
         s_axi_arready => axi_arready_o,
         s_axi_rid     => open,
         s_axi_rdata   => axi_rdata_o,
         s_axi_rresp   => axi_rresp_o,
         s_axi_rlast   => axi_rlast_o,
         s_axi_rvalid  => axi_rvalid_o,
         s_axi_rready  => axi_rready_i
      ); -- axi_bram_ctl_inst

end architecture synthesis;

