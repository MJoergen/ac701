-- Page numbers refer to ug952-ac701-a7-eval-bd.pdf

library ieee;
   use ieee.std_logic_1164.all;

entity ac701_rev1_0_top is
   port (
      -- DDR3 Memory Module, page 15
      ddr3_a_o               : out   std_logic_vector(15 downto 0);
      ddr3_ba_o              : out   std_logic_vector(2 downto 0);
      ddr3_cas_b_o           : out   std_logic;
      ddr3_cke0_o            : out   std_logic;
      ddr3_cke1_o            : out   std_logic;
      ddr3_clk0_n_o          : out   std_logic;
      ddr3_clk0_p_o          : out   std_logic;
      ddr3_clk1_n_o          : out   std_logic;
      ddr3_clk1_p_o          : out   std_logic;
      ddr3_d_io              : inout std_logic_vector(63 downto 0);
      ddr3_dm_o              : out   std_logic_vector(7 downto 0);
      ddr3_dqs_p_io          : inout std_logic_vector(7 downto 0);
      ddr3_dqs_n_io          : inout std_logic_vector(7 downto 0);
      ddr3_odt0_o            : out   std_logic;
      ddr3_odt1_o            : out   std_logic;
      ddr3_ras_b_o           : out   std_logic;
      ddr3_reset_b_o         : out   std_logic;
      ddr3_s0_b_i            : in    std_logic;
      ddr3_s1_b_i            : in    std_logic;
      ddr3_temp_event_i      : in    std_logic;
      ddr3_we_b_o            : out   std_logic;

      -- Quad SPI Flash Memory, page 20
      flash_d_i              : in    std_logic_vector(3 downto 0);
      fpga_emcclk_i          : in    std_logic; -- 90 MHz
      qspi_ic_cs_b_i         : in    std_logic;

      -- SD Card Interface, page 22
      sdio_clk_i             : in    std_logic;
      sdio_cmd_i             : in    std_logic;
      sdio_dat_i             : in    std_logic_vector(3 downto 0);
      sdio_sddet_i           : in    std_logic;
      sdio_sdwp_i            : in    std_logic;

      -- Clock Generation, page 24
      sysclk_n_i             : in    std_logic; -- 200 MHz
      sysclk_p_i             : in    std_logic;
      user_clock_n_i         : in    std_logic; -- 156.250 MHz
      user_clock_p_i         : in    std_logic;
      user_sma_clock_n_i     : in    std_logic;
      user_sma_clock_p_i     : in    std_logic;
      mgtrref_213_i          : in    std_logic;
      mgtrref_216_i          : in    std_logic;
      pcie_clk_qo_n_i        : in    std_logic;
      pcie_clk_qo_p_i        : in    std_logic;
      pcie_mgt_clk_sel_o     : out   std_logic_vector(1 downto 0);
      pcie_perst_i           : in    std_logic;
      pcie_wake_b_i          : in    std_logic;
      rec_clock_c_n_i        : in    std_logic;
      rec_clock_c_p_i        : in    std_logic;
      si5324_int_alm_b_i     : in    std_logic;
      si5324_rst_b_i         : in    std_logic;

      -- SFP/SFP+ Connector, page 39
      sfp_los_i              : in    std_logic;
      sfp_mgt_clk0_n_i       : in    std_logic;
      sfp_mgt_clk0_p_i       : in    std_logic;
      sfp_mgt_clk1_n_i       : in    std_logic;
      sfp_mgt_clk1_p_i       : in    std_logic;
      sfp_mgt_clk_sel_o      : out   std_logic_vector(1 downto 0);
      sfp_tx_disable_i       : in    std_logic;

      -- 10/100/1000 Mb/s Tri-Speed Ethernet PHY, page 41
      phy_mdc_i              : in    std_logic;
      phy_mdio_i             : in    std_logic;
      phy_reset_b_i          : in    std_logic;
      phy_rx_clk_i           : in    std_logic;
      phy_rx_ctrl_i          : in    std_logic;
      phy_rxd_i              : in    std_logic_vector(3 downto 0);
      phy_tx_clk_i           : in    std_logic;
      phy_tx_ctrl_i          : in    std_logic;
      phy_txd_i              : in    std_logic_vector(3 downto 0);

      -- USB-to-UART Bridge, page 43
      usb_uart_cts_i         : in    std_logic;
      usb_uart_rts_i         : in    std_logic;
      usb_uart_rx_i          : in    std_logic;
      usb_uart_tx_i          : in    std_logic;

      -- HDMI Video Output, page 44
      hdmi_int_i             : in    std_logic;
      hdmi_r_clk_i           : in    std_logic;
      hdmi_r_d_i             : in    std_logic_vector(35 downto 0);
      hdmi_r_de_i            : in    std_logic;
      hdmi_r_hsync_i         : in    std_logic;
      hdmi_r_spdif_i         : in    std_logic;
      hdmi_r_vsync_i         : in    std_logic;
      hdmi_spdif_out_i       : in    std_logic;

      -- LCD Character Display, page 47
      lcd_db_i               : in    std_logic_vector(7 downto 4);
      lcd_e_i                : in    std_logic;
      lcd_rs_i               : in    std_logic;
      lcd_rw_i               : in    std_logic;

      -- I2C Bus Switch, page 49
      iic_mux_reset_b_i      : in    std_logic;
      iic_scl_main_i         : in    std_logic;
      iic_sda_main_i         : in    std_logic;

      -- User I/O, page 51
      gpio_dip_sw_i          : in    std_logic_vector(3 downto 0);
      gpio_led_o             : out   std_logic_vector(3 downto 0);
      gpio_sw_c_i            : in    std_logic;
      gpio_sw_e_i            : in    std_logic;
      gpio_sw_n_i            : in    std_logic;
      gpio_sw_s_i            : in    std_logic;
      gpio_sw_w_i            : in    std_logic;
      cpu_reset_i            : in    std_logic;
      user_sma_gpio_n_i      : in    std_logic;
      user_sma_gpio_p_i      : in    std_logic;
      pmod_i                 : in    std_logic_vector(3 downto 0);
      rotary_inca_i          : in    std_logic;
      rotary_incb_i          : in    std_logic;
      rotary_push_i          : in    std_logic;

      -- FPGA Mezzanine Card Interface, page 58
      fmc1_hpc_clk0_m2c_n_i  : in    std_logic;
      fmc1_hpc_clk0_m2c_p_i  : in    std_logic;
      fmc1_hpc_clk1_m2c_n_i  : in    std_logic;
      fmc1_hpc_clk1_m2c_p_i  : in    std_logic;
      fmc1_hpc_ha_n_i        : in    std_logic_vector(23 downto 0);
      fmc1_hpc_ha_p_i        : in    std_logic_vector(23 downto 0);
      fmc1_hpc_la_n_i        : in    std_logic_vector(33 downto 0);
      fmc1_hpc_la_p_i        : in    std_logic_vector(33 downto 0);
      fmc1_hpc_pg_m2c_i      : in    std_logic;
      fmc1_hpc_prsnt_m2c_b_i : in    std_logic;
      fmc_vadj_on_b_i        : in    std_logic;
      ctrl2_pwrgood_i        : in    std_logic;

      -- Power Management, page 62
      pmbus_alert_i          : in    std_logic;
      pmbus_clk_io           : inout std_logic;
      pmbus_ctrl_i           : in    std_logic;
      pmbus_data_io          : inout std_logic;

      -- Cooling Fan Control, page 67
      sm_fan_pwm_i           : in    std_logic;
      sm_fan_tach_i          : in    std_logic;

      -- XADC Power System Measurement, page 72
      xadc_ad1_r_n_i         : in    std_logic;
      xadc_ad1_r_p_i         : in    std_logic;
      xadc_ad9_r_n_i         : in    std_logic;
      xadc_ad9_r_p_i         : in    std_logic;
      xadc_gpio_i            : in    std_logic_vector(3 downto 0);
      xadc_mux_addr_i        : in    std_logic_vector(2 downto 0);
      xadc_vaux0_r_n_i       : in    std_logic;
      xadc_vaux0_r_p_i       : in    std_logic;
      xadc_vaux8_r_n_i       : in    std_logic;
      xadc_vaux8_r_p_i       : in    std_logic
   );
end entity ac701_rev1_0_top;

architecture synthesis of ac701_rev1_0_top is

begin

end architecture synthesis;

