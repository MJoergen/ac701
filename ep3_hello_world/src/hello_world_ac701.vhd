-- Page numbers refer to ug952-ac701-a7-eval-bd.pdf

library ieee;
   use ieee.std_logic_1164.all;

entity hello_world_ac701 is
   port (
      -- Clock Generation, page 24
      pcie_clk_q0_p_i : in    std_logic;
      pcie_clk_q0_n_i : in    std_logic;
      pcie_perst_i    : in    std_logic;

      -- PCI
      pci_exp_txp_o   : out   std_logic;
      pci_exp_txn_o   : out   std_logic;
      pci_exp_rxp_i   : in    std_logic;
      pci_exp_rxn_i   : in    std_logic;

      -- USB-to-UART Bridge, page 43
      usb_uart_rx_i   : in    std_logic;
      usb_uart_tx_i   : in    std_logic
   );
end entity hello_world_ac701;

architecture synthesis of hello_world_ac701 is

begin

   pcie_clk_q0_ibuf_inst : component ibufds_gte2
      port map (
         i     => pcie_clk_q0_p_i,
         ib    => pcie_clk_q0_n_i,
         ceb   => '0',
         o     => sys_clk,
         odiv2 => open
      ); -- pcie_clk_q0_ibuf

end architecture synthesis;

