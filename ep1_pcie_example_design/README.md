# PCIe Example Design

This is the fundamental PCIe Example Design provided with Vivado. It consists of a PCI endpoint connected to an internal
BlockRAM memory.

The purpose is to verify the basic PCIe connectivity between the host machine and the FPGA on the AC701 board.

This episode is based on the (somewhat outdated, but still useful) documentation
[../doc/xtp227-ac701-pcie-c-2015-1.pdf](xtp227-ac701-pcie-c-2015-1.pdf)

## Generate bitstream

The files in this folder are the results of completing the following instructions:

 1. Start Vivado 2024.1
 2. Click `Create Project`. This opens the "Create a New Vivado Project" window.
 3. Click `Next`. This opens the "Project Name" window.
    - Choose a Project name, e.g. "ep1\_pcie\_example\_design"
    - Choose a Project location, e.g. just use the default value.
 4. Click `Next`. This opens the "Project Type" window.
    - Choose "RTL Project"
    - Select "Do not specify sources at this time"
    - De-select "Project is an extensible Vitis platform"
 5. Click `Next`. This opens the "Default Part" window.
    - Click "Boards"
    - Select "Artix-7 AC701 Evaluation Platform"
 6. Click `Next`. This opens the "New Project Summary" window.
    - Verify Default Board shows the AC701.
 7. Click `Finish`. This opens the "PROJECT MANAGER" window.
 8. Click `IP Catalog`.
    - Select "7 Series Integrated Block for PCI Express"
 9. Right-clock and choose "Customize IP...". This opens the "7 Series Integrated Block for PCI Express (3.3)" window.
    - Set Component name to ac701\_pcie\_x1\_gen1
10. Under the "Basic" tab
    - Set "Xilinx Development Board" to AC701
    - Set "Lane Width" to X1
    - Set "Maximum Link Speed" to 2.5 GT/s
    - Set the "Reference Clock Frequency (MHz)" to 100 MHz
    - Set "Tandem Configuration" to None
11. Under the "BARs" tab
    - Select "Bar0 Enabled"
    - Set "Size Unit" to Megabytes
    - Set "Size Value" to 1
12. Click `OK`. This opens the "Generate Output Products" windows.
    - Under "Synthesis Options", select "Out of context per IP"
13. Click `Generate`. This opens (after some time) the "Generate Output Products" confirmation window.
14. Click `OK`.
15. When synthesis is complete, under "Sources", right-click on Design Sources -> ac701\_pcie\_x1\_gen1
16. Click on "Open IP Example Design...". This opens the "Open IP Example Design" window.
17. Click `OK`. This opens a new project.
18. Under "Sources", double-click on Constraints -> constrs\_1 -> xilinx\_pcie\_7x\_ep\_x1g1\_AC701.xdc
19. Beneath the "User Physical Constraints" comment in the source file insert the following lines:
```
    set_property BITSTREAM.CONFIG.SPI_BUSWIDTH     4     [current_design]
    set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN div-1 [current_design]
    set_property BITSTREAM.GENERAL.COMPRESS        TRUE  [current_design]
    set_property BITSTREAM.CONFIG.SPI_FALL_EDGE    YES   [current_design]
    set_property CFGBVS                            VCCO  [current_design]
    set_property CONFIG_VOLTAGE                    3.3   [current_design]
```
20. Press "Ctrl-S" to save the file.
21. Click on Generate Bitstream and press Yes. This takes some time to complete.

## Testing bitstream
 1. Open Hardware Manager and prewss "Program Device"
 2. In a terminal. run the shell script `sudo ../rescan.sh`
    - Note. you might need to create a new file `/etc/sudoers.d/pcirescan` with the following contents:
    ```
    ALL ALL = NOPASSWD:/home/mike/git/MJoergen/ac701/rescan.sh
    ```
 3. `sudo /home/mike/bin/pcimem /sys/bus/pci/devices/0000\:02\:00.0/resource0 0x0 w 0x1234`
 4. `sudo /home/mike/bin/pcimem /sys/bus/pci/devices/0000\:02\:00.0/resource0 0x0 w`


## Programming of Flash storage

### Hardware Setup
1. Set SW1 to 001. This enables Master SPI configuration

### Create flash image
1. In Vivado tcl window, run the script make\_spi\_mcs.tcl.
2. In Vivado tcl window, run the script ac701\_program\_spi.tcl.



