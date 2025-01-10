library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std_unsigned.all;

entity tb_application is
end entity tb_application;

architecture simulation of tb_application is

   -- Clock and reset
   signal   clk : std_logic;
   signal   rst : std_logic;

   constant C_HALF_PERIOD : natural := 5; -- 100 MHz

   -- Avalon Memory Map
   signal   avmm_address            : std_logic_vector(15 downto 0);
   signal   avmm_byteenable         : std_logic_vector(7 downto 0);
   signal   avmm_read               : std_logic;
   signal   avmm_readdata           : std_logic_vector(63 downto 0);
   signal   avmm_readdatavalid      : std_logic;
   signal   avmm_waitrequest        : std_logic;
   signal   avmm_write              : std_logic;
   signal   avmm_writedata          : std_logic_vector(63 downto 0);
   signal   avmm_response           : std_logic_vector(1 downto 0);
   signal   avmm_writeresponsevalid : std_logic;

   -- AXI-Lite
   signal   axil_awready : std_logic;
   signal   axil_awvalid : std_logic;
   signal   axil_awaddr  : std_logic_vector(15 downto 0);
   signal   axil_awlen   : std_logic_vector(7 downto 0);
   signal   axil_awsize  : std_logic_vector(2 downto 0);
   signal   axil_awburst : std_logic_vector(1 downto 0);
   signal   axil_awlock  : std_logic;
   signal   axil_awcache : std_logic_vector(3 downto 0);
   signal   axil_awprot  : std_logic_vector(2 downto 0);
   signal   axil_awid    : std_logic_vector(7 downto 0);
   signal   axil_wready  : std_logic;
   signal   axil_wvalid  : std_logic;
   signal   axil_wdata   : std_logic_vector(63 downto 0);
   signal   axil_wstrb   : std_logic_vector(7 downto 0);
   signal   axil_wlast   : std_logic;
   signal   axil_bready  : std_logic;
   signal   axil_bvalid  : std_logic;
   signal   axil_bresp   : std_logic_vector(1 downto 0);
   signal   axil_bid     : std_logic_vector(7 downto 0);
   signal   axil_arready : std_logic;
   signal   axil_arvalid : std_logic;
   signal   axil_araddr  : std_logic_vector(15 downto 0);
   signal   axil_arlen   : std_logic_vector(7 downto 0);
   signal   axil_arsize  : std_logic_vector(2 downto 0);
   signal   axil_arburst : std_logic_vector(1 downto 0);
   signal   axil_arlock  : std_logic;
   signal   axil_arcache : std_logic_vector(3 downto 0);
   signal   axil_arprot  : std_logic_vector(2 downto 0);
   signal   axil_arid    : std_logic_vector(7 downto 0);
   signal   axil_rready  : std_logic;
   signal   axil_rlast   : std_logic;
   signal   axil_rvalid  : std_logic;
   signal   axil_rdata   : std_logic_vector(63 downto 0);
   signal   axil_rresp   : std_logic_vector(1 downto 0);
   signal   axil_rid     : std_logic_vector(7 downto 0);

   signal   uart_rx_ready : std_logic;
   signal   uart_rx_valid : std_logic;
   signal   uart_rx_data  : std_logic_vector(7 downto 0);
   signal   uart_tx_ready : std_logic;
   signal   uart_tx_valid : std_logic;
   signal   uart_tx_data  : std_logic_vector(7 downto 0);

begin

   test_proc : process
      variable data_v : std_logic_vector(63 downto 0);

      procedure write_avmm_64 (
         addr    : std_logic_vector(15 downto 0);
         data    : std_logic_vector(63 downto 0);
         byte_en : std_logic_vector(7 downto 0) := X"FF"
      ) is
      begin
         avmm_byteenable <= byte_en;
         avmm_address    <= addr;
         avmm_read       <= '0';
         avmm_write      <= '1';
         avmm_writedata  <= data;
         wait until rising_edge(clk);

         while avmm_write = '1' and avmm_waitrequest = '1' loop
            wait until rising_edge(clk);
         end loop;

         avmm_read      <= '0';
         avmm_write     <= '0';
         avmm_address   <= (others => '0');
         avmm_writedata <= (others => '0');
         wait until rising_edge(clk);
         wait until rising_edge(clk);
      end procedure write_avmm_64;

      procedure read_avmm_64 (
         addr : std_logic_vector(15 downto 0);
         data : out std_logic_vector(63 downto 0)
      ) is
      begin
         avmm_address <= addr;
         avmm_read    <= '1';
         avmm_write   <= '0';
         wait until rising_edge(clk);

         while avmm_read = '1' and avmm_waitrequest = '1' loop
            wait until rising_edge(clk);
         end loop;

         avmm_address   <= (others => '0');
         avmm_read      <= '0';
         avmm_write     <= '0';
         avmm_writedata <= (others => '0');
         wait until rising_edge(clk);

         while avmm_readdatavalid = '0' loop
            wait until rising_edge(clk);
         end loop;

         data := avmm_readdata;
         wait until rising_edge(clk);
      end procedure read_avmm_64;

      procedure verify_avmm_64 (
         addr : std_logic_vector(15 downto 0);
         data : std_logic_vector(63 downto 0)
      ) is
         variable data_v : std_logic_vector(63 downto 0);
      begin
         read_avmm_64(addr, data_v);
         assert data = data_v
            report "ERROR: Verify_avmm_64. Addr=0x" & to_hstring(addr)
            & ", read=0x" & to_hstring(data_v) &
            ", exp=0x" & to_hstring(data);
      end procedure verify_avmm_64;

      procedure write_avmm_32 (
         addr : std_logic_vector(15 downto 0);
         data : std_logic_vector(31 downto 0)
      ) is
      begin
         if addr(2) = '0' then
            write_avmm_64(addr, X"00000000" & data, X"0F");
         else
            write_avmm_64(addr, data & X"00000000", X"F0");
         end if;
      end procedure write_avmm_32;

      procedure read_avmm_32 (
         addr : std_logic_vector(15 downto 0);
         data : out std_logic_vector(31 downto 0)
      ) is
         variable data_64_v : std_logic_vector(63 downto 0);
      begin
         read_avmm_64(addr, data_64_v);
         if addr(2) = '0' then
            data := data_64_v(31 downto 0);
         else
            data := data_64_v(63 downto 32);
         end if;
      end procedure read_avmm_32;

      procedure verify_avmm_32 (
         addr : std_logic_vector(15 downto 0);
         data : std_logic_vector(31 downto 0)
      ) is
         variable data_v : std_logic_vector(31 downto 0);
      begin
         read_avmm_32(addr, data_v);
         assert data = data_v
            report "ERROR: Verify_avmm_32. Addr=0x" & to_hstring(addr)
            & ", read=0x" & to_hstring(data_v)
            & ", exp=0x" & to_hstring(data);
      end procedure verify_avmm_32;

      procedure write_serial(
         data : std_logic_vector(7 downto 0)
      ) is
         constant CLK_LO  : std_logic_vector(31 downto 0) := X"00000000";
         constant CLK_HI  : std_logic_vector(31 downto 0) := X"00010100";
         constant DATA_LO : std_logic_vector(31 downto 0) := X"00000000";
         constant DATA_HI : std_logic_vector(31 downto 0) := X"01000001";
      begin
         for i in 0 to 7 loop
            if data(i) = '1' then
               write_avmm_32(X"0004", CLK_LO or DATA_HI);
               write_avmm_32(X"0004", CLK_HI or DATA_HI);
            else
               write_avmm_32(X"0004", CLK_LO or DATA_LO);
               write_avmm_32(X"0004", CLK_HI or DATA_LO);
            end if;
         end loop;
      end procedure write_serial;

   --
   begin -- test_proc
      avmm_read  <= '0';
      avmm_write <= '0';
      wait for 500 ns;
      wait until rising_edge(clk);

      report "Test basic memory access";
      write_avmm_64 (X"0000", X"deadbeefb00bcafe");
      write_avmm_64 (X"0008", X"cafebabedeadb00b");
      verify_avmm_64(X"0000", X"deadbeefb00bcafe");
      verify_avmm_64(X"0008", X"cafebabedeadb00b");
      verify_avmm_32(X"0000", X"b00bcafe");
      verify_avmm_32(X"0004", X"deadbeef");
      verify_avmm_32(X"0008", X"deadb00b");
      verify_avmm_32(X"000C", X"cafebabe");
      write_avmm_32 (X"0000", X"beefdead");
      write_avmm_32 (X"000C", X"b00bbeef");
      verify_avmm_64(X"0000", X"deadbeefbeefdead");
      verify_avmm_64(X"0008", X"b00bbeefdeadb00b");

      report "Test serial write";
      write_serial(X"12");
      write_serial(X"34");
      write_serial(X"56");
      write_serial(X"78");
      write_serial(X"9A");
      write_serial(X"AB");
      write_serial(X"BC");
      write_serial(X"CD");
      verify_avmm_32(X"8000", X"78563412");
      verify_avmm_32(X"8004", X"CDBCAB9A");

      report "Test finished!";
      wait;
   end process test_proc;

   clk_proc : process
   begin
      clk <= '1';
      wait for C_HALF_PERIOD * 1 ns;
      clk <= '0';
      wait for C_HALF_PERIOD * 1 ns;
   end process clk_proc;

   rst_proc : process
   begin
      rst <= '1';
      wait for 100 ns;
      wait until clk = '1';

      rst <= '0';
      wait until clk = '1';
      wait;
   end process rst_proc;

   avalon_axi_inst : entity work.avalon_axi
      generic map (
         G_ADDR_SIZE => 16,
         G_DATA_SIZE => 64
      )
      port map (
         clk_i                      => clk,
         rst_i                      => rst,
         s_avm_address_i            => avmm_address,
         s_avm_byteenable_i         => avmm_byteenable,
         s_avm_read_i               => avmm_read,
         s_avm_readdata_o           => avmm_readdata,
         s_avm_readdatavalid_o      => avmm_readdatavalid,
         s_avm_waitrequest_o        => avmm_waitrequest,
         s_avm_write_i              => avmm_write,
         s_avm_writedata_i          => avmm_writedata,
         s_avm_response_o           => avmm_response,
         s_avm_writeresponsevalid_o => avmm_writeresponsevalid,
         m_axil_awready_i           => axil_awready,
         m_axil_awvalid_o           => axil_awvalid,
         m_axil_awaddr_o            => axil_awaddr,
         m_axil_awprot_o            => axil_awprot,
         m_axil_awid_o              => axil_awid,
         m_axil_wready_i            => axil_wready,
         m_axil_wvalid_o            => axil_wvalid,
         m_axil_wdata_o             => axil_wdata,
         m_axil_wstrb_o             => axil_wstrb,
         m_axil_bready_o            => axil_bready,
         m_axil_bvalid_i            => axil_bvalid,
         m_axil_bresp_i             => axil_bresp,
         m_axil_bid_i               => axil_bid,
         m_axil_arready_i           => axil_arready,
         m_axil_arvalid_o           => axil_arvalid,
         m_axil_araddr_o            => axil_araddr,
         m_axil_arprot_o            => axil_arprot,
         m_axil_arid_o              => axil_arid,
         m_axil_rready_o            => axil_rready,
         m_axil_rvalid_i            => axil_rvalid,
         m_axil_rdata_i             => axil_rdata,
         m_axil_rresp_i             => axil_rresp,
         m_axil_rid_i               => axil_rid
      ); -- avalon_axi_inst

   application_inst : entity work.application
      port map (
         clk_i           => clk,
         rst_i           => rst,
         axi_awaddr_i    => axil_awaddr,
         axi_awlen_i     => axil_awlen,
         axi_awsize_i    => axil_awsize,
         axi_awburst_i   => axil_awburst,
         axi_awlock_i    => axil_awlock,
         axi_awcache_i   => axil_awcache,
         axi_awprot_i    => axil_awprot,
         axi_awvalid_i   => axil_awvalid,
         axi_awready_o   => axil_awready,
         axi_wdata_i     => axil_wdata,
         axi_wstrb_i     => axil_wstrb,
         axi_wlast_i     => axil_wlast,
         axi_wvalid_i    => axil_wvalid,
         axi_wready_o    => axil_wready,
         axi_bresp_o     => axil_bresp,
         axi_bvalid_o    => axil_bvalid,
         axi_bready_i    => axil_bready,
         axi_araddr_i    => axil_araddr,
         axi_arlen_i     => axil_arlen,
         axi_arsize_i    => axil_arsize,
         axi_arburst_i   => axil_arburst,
         axi_arlock_i    => axil_arlock,
         axi_arcache_i   => axil_arcache,
         axi_arprot_i    => axil_arprot,
         axi_arvalid_i   => axil_arvalid,
         axi_arready_o   => axil_arready,
         axi_rdata_o     => axil_rdata,
         axi_rresp_o     => axil_rresp,
         axi_rlast_o     => axil_rlast,
         axi_rvalid_o    => axil_rvalid,
         axi_rready_i    => axil_rready,
         uart_rx_ready_o => uart_rx_ready,
         uart_rx_valid_i => uart_rx_valid,
         uart_rx_data_i  => uart_rx_data,
         uart_tx_ready_i => uart_tx_ready,
         uart_tx_valid_o => uart_tx_valid,
         uart_tx_data_o  => uart_tx_data
      ); -- application_inst

end architecture simulation;

