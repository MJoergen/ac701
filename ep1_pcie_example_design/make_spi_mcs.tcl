file copy -force pcie_7x_0_ex.runs/impl_1/xilinx_pcie_2_1_ep_7x.bit .
write_cfgmem -force -format MCS -size 32 -interface SPIx4 -loadbit "up 0x00000000 xilinx_pcie_2_1_ep_7x.bit" xilinx_pcie_2_1_ep_7x.mcs

