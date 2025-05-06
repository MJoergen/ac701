# Introduction
This repo contains various test designs for the AC701 evaluation board from AMD. One
of the purposes of this repo is to experiment with the MultiBoot feature.

List of episodes:
1.  This is the fundamental PCIe example design provided with Vivado
2.  This is the fundamental AXI example design provided with Vivado
3.  This is a simple hard-coded Hello World application using the PCIe endpoint
4.  This is a more generic application using the PCIe endpoint
5.  This episode experiments with transferring large files over the PCI link.

The first episodes uses the Vivado GUI (in project flow), while the later episodes uses Vivado in non-project flow.

# AC701
The AC701 evaluation board is a PCIe expansion card for a desktop computer.
It has an Artix 7 AMD FPGA with a Gigabit Transceiver capable of running PCIe x4 Gen 2.
With AMD Vivado follows a bare-bones PCIe endpoint IP block, described in
[../doc/pg054-7series-pcie-en-us-3.3.pdf](pg054-7series-pcie-en-us-3.3.pdf). Furthermore, AMD Vivado provides
an AXI memory mapped interface for easier integration into user designs, described in
[../doc/pg055-axi-bridge-pcie-en-us-2.9.pdf](pg055-axi-bridge-pcie-en-us-2.9.pdf).

# MultiBoot
The AC701 board also has an onboard flash, which is necessary to support MultiBoot.

