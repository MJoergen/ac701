# This Makefile is based on the chapter "Scripting the Non Project Mode"
# in ug939 "Vivado Design Suite Tutorial: Designing with IP".
# https://docs.amd.com/r/2022.2-English/ug939-vivado-designing-with-ip-tutorial/Scripting-the-Non-Project-Mode

XILINX_DIR = /opt/Xilinx/Vivado/2024.1

TOP = ep5_file

SRCS += src/$(TOP).vhd
SRCS += src/application.vhd
SRCS += src/avalon_mem.vhd
SRCS += src/axi_avalon.vhd
SRCS += src/serializer.vhd
SRCS += src/tdp_ram_byteenable.vhd
SRCS += src/uart.vhd

IPS += src/axi_pcie_0/axi_pcie_0.xci

XDC = src/$(TOP).xdc

BOARD = xilinx.com:ac701:part0:1.4

$(TOP).bit: $(TOP).tcl $(SRCS) $(XDC) Makefile
	bash -c "source $(XILINX_DIR)/settings64.sh ; vivado -mode tcl -source $<"

$(TOP).tcl: Makefile
	echo "# This is a tcl command script for the Vivado tool chain" > $@
	echo "read_vhdl -vhdl2008 { $(SRCS) }" >> $@
	echo "read_ip { $(IPS) }" >> $@
	echo "read_xdc { $(XDC) }" >> $@
	echo "set_property BOARD_PART $(BOARD) [current_project]" >> $@
	echo "set_property XPM_LIBRARIES {XPM_CDC XPM_FIFO} [current_project]" >> $@
	echo "generate_target all [get_ips] -force" >> $@
	echo "synth_ip [get_ips]" >> $@
	echo "synth_design -top $(TOP) -flatten_hierarchy none $(GENERICS)" >> $@
	echo "write_checkpoint -force post_synth.dcp" >> $@
	echo "opt_design" >> $@
	echo "source ../debug.tcl" >> $@
	echo "place_design" >> $@
	echo "phys_opt_design" >> $@
	echo "route_design" >> $@
	echo "write_checkpoint -force $(TOP).dcp" >> $@
	echo "write_bitstream -force $(TOP).bit" >> $@
	echo "exit" >> $@

clean:
	rm -rf usage_statistics_webtalk.*
	rm -rf vivado*.jou
	rm -rf vivado*.log
	rm -rf vivado*.str
	rm -rf vivado.cache/
	rm -rf vivado.hw/
	rm -rf vivado.runs/
	rm -rf vivado.sim/
	rm -rf vivado.ip_user_files/
	rm -rf post_synth.dcp
	rm -rf hs_err_*.log
	rm -rf .Xil
	rm -rf .cache
	rm -rf debug.ltx
	rm -rf clockInfo.txt
	rm -rf $(TOP).tcl
	rm -rf $(TOP).bit
	rm -rf $(TOP).dcp
	rm -rf $(TOP).cache
	rm -rf $(TOP).hw
	rm -rf $(TOP).runs
	rm -rf $(TOP).srcs

program:
	m65 -q $(TOP).bit

rescan:
	sudo ../rescan.sh

