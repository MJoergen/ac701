XILINX_DIR = /opt/Xilinx/Vivado/2024.1

PROJECT = hello_world
PLATFORM = ac701

TOP = $(PROJECT)_$(PLATFORM)

SRCS += $(TOP).vhd

XDC = ../$(PLATFORM).xdc

PART = xc7a200tfbg676-2

$(TOP).bit: $(TOP).tcl $(SRCS) $(XDC) Makefile
	bash -c "source $(XILINX_DIR)/settings64.sh ; vivado -mode tcl -source $<"

$(TOP).tcl: Makefile
	echo "# This is a tcl command script for the Vivado tool chain" > $@
	echo "read_vhdl -vhdl2008 { $(SRCS) }" >> $@
	echo "read_xdc $(XDC)" >> $@
	echo "set_property XPM_LIBRARIES {XPM_CDC XPM_FIFO} [current_project]" >> $@
	echo "synth_design -top $(TOP) -part $(PART) -flatten_hierarchy none $(GENERICS)" >> $@
	echo "write_checkpoint -force post_synth.dcp" >> $@
	echo "opt_design" >> $@
	echo "place_design" >> $@
	echo "phys_opt_design" >> $@
	echo "route_design" >> $@
	echo "write_checkpoint -force $(TOP).dcp" >> $@
	echo "write_bitstream -force $(TOP).bit" >> $@
	echo "exit" >> $@

clean:
	rm -rf usage_statistics_webtalk.*
	rm -rf vivado*
	rm -rf post_synth.dcp
	rm -rf .Xil
	rm -rf .cache
	rm -rf debug.ltx
	rm -rf $(TOP).tcl
	rm -rf $(TOP).bit
	rm -rf $(TOP).dcp
	rm -rf $(TOP).cache
	rm -rf $(TOP).hw
	rm -rf $(TOP).runs
	rm -rf $(TOP).srcs

