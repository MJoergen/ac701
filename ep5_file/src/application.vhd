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
      axi_awaddr_i    : in    std_logic_vector(15 downto 0);
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
      axi_araddr_i    : in    std_logic_vector(15 downto 0);
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

   constant C_ADDR_SIZE       : natural                                          := 16;
   constant C_DATA_SIZE       : natural                                          := 64;
   constant C_SERIAL_RAM_BASE : std_logic_vector(C_ADDR_SIZE - 1 downto 0)       := X"8000";

   signal   avm_write              : std_logic;
   signal   avm_read               : std_logic;
   signal   avm_address            : std_logic_vector(C_ADDR_SIZE - 1 downto 0);
   signal   avm_writedata          : std_logic_vector(C_DATA_SIZE - 1 downto 0);
   signal   avm_byteenable         : std_logic_vector(C_DATA_SIZE / 8 - 1 downto 0);
   signal   avm_readdata           : std_logic_vector(C_DATA_SIZE - 1 downto 0);
   signal   avm_readdatavalid      : std_logic;
   signal   avm_waitrequest        : std_logic;
   signal   avm_writeresponsevalid : std_logic;
   signal   avm_response           : std_logic_vector(1 downto 0);

   signal   mem_addr    : std_logic_vector(C_ADDR_SIZE - 1 downto 0);
   signal   mem_wr_en   : std_logic_vector(C_DATA_SIZE / 8 - 1 downto 0);
   signal   mem_wr_data : std_logic_vector(C_DATA_SIZE - 1 downto 0);
   signal   mem_rd_data : std_logic_vector(C_DATA_SIZE - 1 downto 0);

   signal   cnt         : natural range 0 to 7;
   signal   ram_wr_en   : std_logic_vector(7 downto 0);
   signal   ram_wr_addr : std_logic_vector(15 downto 0);
   signal   ram_wr_data : std_logic_vector(7 downto 0);

begin

   -------------------
   -- UART connection
   -------------------

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


   ------------------
   -- PCI connection
   ------------------

   axi_avalon_inst : entity work.axi_avalon
      generic map (
         G_ADDR_SIZE => C_ADDR_SIZE,
         G_DATA_SIZE => C_DATA_SIZE
      )
      port map (
         clk_i                      => clk_i,
         rst_i                      => rst_i,
         s_axil_awready_o           => axi_awready_o,
         s_axil_awvalid_i           => axi_awvalid_i,
         s_axil_awaddr_i            => axi_awaddr_i,
         s_axil_awprot_i            => axi_awprot_i,
         s_axil_awid_i              => X"00",
         s_axil_wready_o            => axi_wready_o,
         s_axil_wvalid_i            => axi_wvalid_i,
         s_axil_wdata_i             => axi_wdata_i,
         s_axil_wstrb_i             => axi_wstrb_i,
         s_axil_bready_i            => axi_bready_i,
         s_axil_bvalid_o            => axi_bvalid_o,
         s_axil_bresp_o             => axi_bresp_o,
         s_axil_bid_o               => open,
         s_axil_arready_o           => axi_arready_o,
         s_axil_arvalid_i           => axi_arvalid_i,
         s_axil_araddr_i            => axi_araddr_i,
         s_axil_arprot_i            => axi_arprot_i,
         s_axil_arid_i              => X"00",
         s_axil_rready_i            => axi_rready_i,
         s_axil_rvalid_o            => axi_rvalid_o,
         s_axil_rdata_o             => axi_rdata_o,
         s_axil_rresp_o             => axi_rresp_o,
         s_axil_rid_o               => open,
         s_axil_rlast_o             => axi_rlast_o,
         m_avm_write_o              => avm_write,
         m_avm_read_o               => avm_read,
         m_avm_address_o            => avm_address,
         m_avm_writedata_o          => avm_writedata,
         m_avm_byteenable_o         => avm_byteenable,
         m_avm_readdata_i           => avm_readdata,
         m_avm_readdatavalid_i      => avm_readdatavalid,
         m_avm_waitrequest_i        => avm_waitrequest,
         m_avm_writeresponsevalid_i => avm_writeresponsevalid,
         m_avm_response_i           => avm_response
      ); -- axi_avalon_inst

   avalon_mem_inst : entity work.avalon_mem
      generic map (
         G_ADDRESS_SIZE => C_ADDR_SIZE,
         G_DATA_SIZE    => C_DATA_SIZE
      )
      port map (
         clk_i                    => clk_i,
         rst_i                    => rst_i,
         avm_waitrequest_o        => avm_waitrequest,
         avm_write_i              => avm_write,
         avm_read_i               => avm_read,
         avm_address_i            => avm_address,
         avm_writedata_i          => avm_writedata,
         avm_byteenable_i         => avm_byteenable,
         avm_burstcount_i         => X"01",
         avm_readdata_o           => avm_readdata,
         avm_readdatavalid_o      => avm_readdatavalid,
         avm_writeresponsevalid_o => avm_writeresponsevalid,
         avm_response_o           => avm_response,
         mem_addr_o               => mem_addr,
         mem_wr_en_o              => mem_wr_en,
         mem_wr_data_o            => mem_wr_data,
         mem_rd_data_i            => mem_rd_data
      ); -- avalon_mem_inst

   deserial_proc : process (clk_i)
   begin
      if rising_edge(clk_i) then
         ram_wr_en <= (others => '0');
         -- bit 48 is serial clock
         -- bit 56 is serial data
         if avm_write = '1' and avm_address = X"0004" and avm_byteenable = X"F0" and avm_writedata(48) = '1' then
            ram_wr_data <= avm_writedata(56) & ram_wr_data(7 downto 1); -- first bit is LSB
            if cnt = 7 then
               ram_wr_addr                                        <= ram_wr_addr + 1;
               ram_wr_en(to_integer(ram_wr_addr(2 downto 0) + 1)) <= '1';
               cnt                                                <= 0;
            else
               cnt <= cnt + 1;
            end if;
         end if;

         if rst_i = '1' then
            cnt         <= 0;
            ram_wr_addr <= C_SERIAL_RAM_BASE - 1;
         end if;
      end if;
   end process deserial_proc;

   tdp_ram_byteenable_inst : entity work.tdp_ram_byteenable
      generic map (
         G_ADDR_SIZE   => C_ADDR_SIZE - 3,
         G_COLUMN_SIZE => 8,
         G_NUM_COLUMNS => 8
      )
      port map (
         a_clk_i     => clk_i,
         a_addr_i    => ram_wr_addr(C_ADDR_SIZE - 1 downto 3),
         a_wr_data_i => ram_wr_data & ram_wr_data & ram_wr_data & ram_wr_data &
                        ram_wr_data & ram_wr_data & ram_wr_data & ram_wr_data,
         a_wr_en_i   => ram_wr_en,
         a_rd_data_o => open,

         b_clk_i     => clk_i,
         b_addr_i    => mem_addr(C_ADDR_SIZE - 1 downto 3),
         b_wr_data_i => mem_wr_data,
         b_wr_en_i   => mem_wr_en,
         b_rd_data_o => mem_rd_data
      ); -- tdp_ram_inst

end architecture synthesis;

