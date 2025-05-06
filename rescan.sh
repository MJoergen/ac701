# Shell script, run as root

## Rescan PCI bus after loading new FPGA bitstream via JTAG:
echo 1 > /sys/devices/pci0000:00/0000:00:1b.4/0000:02:00.0/remove
echo 1 > /sys/bus/pci/rescan

## Enable PCI memory mapped transfers
setpci -s 02:00.0 COMMAND=0x02

# The need for the last command is described in the link below:
# Link: https://adaptivesupport.amd.com/s/question/0D52E00006iHlNoSAK/lspci-reports-bar-0-disabled?language=en_US


