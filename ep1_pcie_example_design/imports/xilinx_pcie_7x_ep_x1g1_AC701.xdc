
##-----------------------------------------------------------------------------
##
## (c) Copyright 2020-2024 Advanced Micro Devices, Inc. All rights reserved.
##
## This file contains confidential and proprietary information
## of AMD and is protected under U.S. and
## international copyright and other intellectual property
## laws.
##
## DISCLAIMER
## This disclaimer is not a license and does not grant any
## rights to the materials distributed herewith. Except as
## otherwise provided in a valid license issued to you by
## AMD, and to the maximum extent permitted by applicable
## law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
## WITH ALL FAULTS, AND AMD HEREBY DISCLAIMS ALL WARRANTIES
## AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
## BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
## INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
## (2) AMD shall not be liable (whether in contract or tort,
## including negligence, or under any other theory of
## liability) for any loss or damage of any kind or nature
## related to, arising under or in connection with these
## materials, including for any direct, or any indirect,
## special, incidental, or consequential loss or damage
## (including loss of data, profits, goodwill, or any type of
## loss or damage suffered as a result of any action brought
## by a third party) even if such damage or loss was
## reasonably foreseeable or AMD had been advised of the
## possibility of the same.
##
## CRITICAL APPLICATIONS
## AMD products are not designed or intended to be fail-
## safe, or for use in any application requiring fail-safe
## performance, such as life-support or safety devices or
## systems, Class III medical devices, nuclear facilities,
## applications related to the deployment of airbags, or any
## other applications that could lead to death, personal
## injury, or severe property or environmental damage
## (individually and collectively, "Critical
## Applications"). Customer assumes the sole risk and
## liability of any use of AMD products in Critical
## Applications, subject only to applicable laws and
## regulations governing limitations on product liability.
##
## THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
## PART OF THIS FILE AT ALL TIMES.
##
##-----------------------------------------------------------------------------
## Project    : Series-7 Integrated Block for PCI Express
## File       : xilinx_pcie_7x_ep_x1g1_AC701.xdc
## Version    : 3.3
#
###############################################################################
# User Configuration 
# Link Width   - x1
# Link Speed   - gen1
# Family       - artix7
# Part         - xc7a200t
# Package      - fbg676
# Speed grade  - -2
# PCIe Block   - X0Y0
###############################################################################
#
###############################################################################
# User Time Names / User Time Groups / Time Specs
###############################################################################

###############################################################################
# User Physical Constraints
###############################################################################

set_property BITSTREAM.CONFIG.SPI_BUSWIDTH     4     [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE    YES   [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN div-1 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS        FALSE [current_design]
set_property CFGBVS                            VCCO  [current_design]
set_property CONFIG_VOLTAGE                    3.3   [current_design]


###############################################################################
# Timing Constraints
###############################################################################
#
create_clock -name sys_clk -period 10 [get_ports sys_clk_p]
#
# 
set_false_path -to [get_pins {pcie_7x_0_support_i/pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/S0}]
set_false_path -to [get_pins {pcie_7x_0_support_i/pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/S1}]
#
#
set_case_analysis 1 [get_pins {pcie_7x_0_support_i/pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/S0}]
set_case_analysis 0 [get_pins {pcie_7x_0_support_i/pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/S1}]
set_property DONT_TOUCH true [get_cells -of [get_nets -of [get_pins {pcie_7x_0_support_i/pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/S0}]]]

#
#
# Timing ignoring the below pins to avoid CDC analysis, but care has been taken in RTL to sync properly to other clock domain.
#
#
###############################################################################
# Pinout and Related I/O Constraints
###############################################################################

#
# SYS reset (input) signal.  The sys_reset_n signal should be
# obtained from the PCI Express interface if possible.  For
# slot based form factors, a system reset signal is usually
# present on the connector.  For cable based form factors, a
# system reset signal may not be available.  In this case, the
# system reset signal must be generated locally by some form of
# supervisory circuit.  You may change the IOSTANDARD and LOC
# to suit your requirements and VCCO voltage banking rules.
# Some 7 series devices do not have 3.3 V I/Os available.
# Therefore the appropriate level shift is required to operate
# with these devices that contain only 1.8 V banks.
#

set_property IOSTANDARD LVCMOS33 [get_ports sys_rst_n]

set_property PULLUP true [get_ports sys_rst_n]

set_property LOC M20 [get_ports sys_rst_n]

#
# LED Status Indicators for Example Design.
# LED 0-2 should be ON if link is up and functioning correctly
# LED 3 should be blinking if user applicaiton is receiving valid clock
#
set_property IOSTANDARD LVCMOS33 [get_ports led_0]
set_property IOSTANDARD LVCMOS33 [get_ports led_1]
set_property IOSTANDARD LVCMOS33 [get_ports led_2]
# SYS RESET = led_0
# USER RESET = led_0
# USER LINK UP = led_2
set_property LOC M26 [get_ports led_0]
set_property LOC T24 [get_ports led_1]
set_property LOC T25 [get_ports led_2]
set_property IOSTANDARD LVCMOS33 [get_ports led_3]
# USER CLK HEART BEAT = led_3
set_property LOC R26 [get_ports led_3]
set_false_path -to [get_ports -filter {NAME=~led_*}]


###############################################################################
# Physical Constraints
###############################################################################
#
# SYS clock 100 MHz (input) signal. The sys_clk_p and sys_clk_n
# signals are the PCI Express reference clock. Virtex-7 GT
# Transceiver architecture requires the use of a dedicated clock
# resources (FPGA input pins) associated with each GT Transceiver.
# To use these pins an IBUFDS primitive (refclk_ibuf) is
# instantiated in user's design.
# Please refer to the Virtex-7 GT Transceiver User Guide
# (UG) for guidelines regarding clock resource selection.
#

set_property LOC IBUFDS_GTE2_X0Y2 [get_cells refclk_ibuf]

set_false_path -from [get_ports sys_rst_n]

#------------------------- Adding waiver -------------------------#
create_waiver -type DRC -id {REQP-1840} -scope -internal -user "pcie_7x" -tags "1167258" -desc "DRC expects synchronous pins to be provided to BRAM inputs. Since synchronization is present one stage before, it is safe to ignore" -objects [get_cells -hier -filter {NAME =~ {*/inst/inst/pr_loader_i/*.WIDE_PRIM18.ram}}]

###############################################################################
# End
###############################################################################
