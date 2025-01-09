## Page numbers refer to ug952-ac701-a7-eval-bd.pdf
#
## Clock Generation, page 24
set_property PACKAGE_PIN M20              [get_ports pcie_perst_i]
set_property IOSTANDARD  LVCMOS33         [get_ports pcie_perst_i]
set_property PULLUP      TRUE             [get_ports pcie_perst_i]
set_property LOC         IBUFDS_GTE2_X0Y2 [get_cells pcie_clk_q0_ibuf_inst]
#
## USB-to-UART Bridge, page 43
set_property PACKAGE_PIN U19        [get_ports usb_uart_rx_i]
set_property PACKAGE_PIN T19        [get_ports usb_uart_tx_i]
set_property IOSTANDARD LVCMOS18    [get_ports usb_*]

## CONFIG
set_property BITSTREAM.GENERAL.COMPRESS        FALSE [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH     4     [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN div-1 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE    YES   [current_design]
set_property CFGBVS                            VCCO  [current_design]
set_property CONFIG_VOLTAGE                    3.3   [current_design]
#

# Timing
create_clock -name sys_clk -period 10 [get_ports pcie_clk_q0_p_i]

