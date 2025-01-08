# ac701
Test designs for the AC701 evaluation board

## ep1

### Rescan after loading new FPGA bitstream via JTAG:
\# echo 1 > /sys/devices/pci0000:00/0000:00:1b.4/0000:02:00.0/remove
\# echo 1 > /sys/bus/pci/rescan

### Enable PCI memory mapped transfers
```
sudo setpci -s 02:00.0 COMMAND=0x02
```
Link: [https://adaptivesupport.amd.com/s/question/0D52E00006iHlNoSAK/lspci-reports-bar-0-disabled?language=en_US](https://adaptivesupport.amd.com/s/question/0D52E00006iHlNoSAK/lspci-reports-bar-0-disabled?language=en_US)

### Test
```
sudo /home/mike/bin/pcimem /sys/bus/pci/devices/0000\:02\:00.0/resource0 0x0 w 0x1234
```

