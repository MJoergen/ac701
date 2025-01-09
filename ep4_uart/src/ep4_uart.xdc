###############################################################################
# Pinout and I/O Constraints
###############################################################################

# MGTREFCLK0, bank 216
set_property LOC        IBUFDS_GTE2_X0Y2 [get_cells pcie_clk_qo_inst ]; # PCIE_CLK_QO, pins F11 & E11

# Bank 14, 3.3 V
set_property LOC        M20              [get_ports pcie_perst_i]; # PCIE_PERST (active low)
set_property IOSTANDARD LVCMOS33         [get_ports pcie_perst_i]
set_property PULLUP     true             [get_ports pcie_perst_i]

# Bank 13, 1.8 V
set_property BOARD_PIN  {rs232_uart_txd} [get_ports usb_uart_tx_o]; # USB_UART_TX, pin T19
set_property BOARD_PIN  {rs232_uart_rxd} [get_ports usb_uart_rx_i]; # USB_UART_RX, pin U19


###############################################################################
# Timing Constraints
###############################################################################

create_clock -name sys_clk -period 10 [get_ports pcie_clk_qo_p_i]; # GT Ref Clock
set_false_path -from [get_ports pcie_perst_i]


###############################################################################
# Configuration
###############################################################################

set_property BITSTREAM.CONFIG.SPI_BUSWIDTH     4     [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE    YES   [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN div-1 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS        FALSE [current_design]
set_property CFGBVS                            VCCO  [current_design]
set_property CONFIG_VOLTAGE                    3.3   [current_design]

