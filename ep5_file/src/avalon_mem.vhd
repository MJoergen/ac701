library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std_unsigned.all;

entity avalon_mem is
   generic (
      G_ADDRESS_SIZE : integer; -- Number of bits
      G_DATA_SIZE    : integer  -- Number of bits
   );
   port (
      clk_i                    : in    std_logic;
      rst_i                    : in    std_logic;
      avm_waitrequest_o        : out   std_logic;
      avm_write_i              : in    std_logic;
      avm_read_i               : in    std_logic;
      avm_address_i            : in    std_logic_vector(G_ADDRESS_SIZE - 1 downto 0);
      avm_writedata_i          : in    std_logic_vector(G_DATA_SIZE - 1 downto 0);
      avm_byteenable_i         : in    std_logic_vector(G_DATA_SIZE / 8 - 1 downto 0);
      avm_burstcount_i         : in    std_logic_vector(7 downto 0);
      avm_readdata_o           : out   std_logic_vector(G_DATA_SIZE - 1 downto 0);
      avm_readdatavalid_o      : out   std_logic;
      avm_writeresponsevalid_o : out   std_logic;
      avm_response_o           : out   std_logic_vector(1 downto 0);

      mem_addr_o               : out   std_logic_vector(G_ADDRESS_SIZE - 1 downto 0);
      mem_wr_data_o            : out   std_logic_vector(G_DATA_SIZE - 1 downto 0);
      mem_wr_en_o              : out   std_logic_vector(G_DATA_SIZE / 8 - 1 downto 0);
      mem_rd_data_i            : in    std_logic_vector(G_DATA_SIZE - 1 downto 0)
   );
end entity avalon_mem;

architecture synthesis of avalon_mem is

   signal write_burstcount : std_logic_vector(7 downto 0);
   signal write_address    : std_logic_vector(G_ADDRESS_SIZE - 1 downto 0);

   signal read_burstcount : std_logic_vector(7 downto 0);
   signal read_address    : std_logic_vector(G_ADDRESS_SIZE - 1 downto 0);

   signal mem_write_burstcount : std_logic_vector(7 downto 0);
   signal mem_read_burstcount  : std_logic_vector(7 downto 0);
   signal mem_write_address    : std_logic_vector(G_ADDRESS_SIZE - 1 downto 0);
   signal mem_read_address     : std_logic_vector(G_ADDRESS_SIZE - 1 downto 0);

begin

   mem_write_address    <= avm_address_i when write_burstcount = X"00" else
                           write_address;
   mem_read_address     <= avm_address_i when read_burstcount = X"00" else
                           read_address;
   mem_write_burstcount <= avm_burstcount_i when write_burstcount = X"00" else
                           write_burstcount;
   mem_read_burstcount  <= avm_burstcount_i when read_burstcount = X"00" else
                           read_burstcount;

   avm_waitrequest_o    <= '0' when read_burstcount = 0 else
                           '1';


   mem_proc : process (clk_i)
   begin
      if rising_edge(clk_i) then
         avm_readdatavalid_o      <= '0';
         avm_writeresponsevalid_o <= '0';

         if avm_write_i = '1' and avm_waitrequest_o = '0' then
            write_address            <= ((mem_write_address) + 1);
            write_burstcount         <= ((mem_write_burstcount) - 1);
            avm_writeresponsevalid_o <= '1';
            avm_response_o           <= "00";
         end if;

         if (avm_read_i = '1' and avm_waitrequest_o = '0') or ((read_burstcount)) > 0 then
            read_address        <= ((mem_read_address) + 1);
            read_burstcount     <= ((mem_read_burstcount) - 1);

            avm_readdatavalid_o <= '1';
         end if;

         if rst_i = '1' then
            write_burstcount <= (others => '0');
            read_burstcount  <= (others => '0');
         end if;
      end if;
   end process mem_proc;

   mem_addr_o           <= mem_write_address when avm_write_i else
                           mem_read_address;
   mem_wr_data_o        <= avm_writedata_i;
   mem_wr_en_o          <= avm_byteenable_i when avm_write_i = '1' and avm_waitrequest_o = '0' else
                           (others => '0');

   avm_readdata_o       <= mem_rd_data_i;

end architecture synthesis;

