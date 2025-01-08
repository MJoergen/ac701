# Shell script, run as root

echo 1 > /sys/devices/pci0000:00/0000:00:1b.4/0000:02:00.0/remove
echo 1 > /sys/bus/pci/rescan
setpci -s 02:00.0 COMMAND=0x02

