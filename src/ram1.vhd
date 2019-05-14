--------------------------------------------------------------------------------
-- Generated automatically by Reggae compiler
-- (c) Jean-Christophe Le Lann - 2011
-- date : Sat May 11 21:09:00 2019
--------------------------------------------------------------------------------
library ieee,std;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library assets;

use work.ram1_pkg.all;

entity ram1 is
  port(
    reset_n : in  std_logic;
    clk     : in  std_logic;
    sreset  : in  std_logic;
    ce      : in  std_logic;
    we      : in  std_logic;
    address : in  unsigned(7 downto 0);
    datain  : in  std_logic_vector(31 downto 0);
    dataout : out std_logic_vector(31 downto 0);
    -----------------------------------------------
    processing_to_ram_en   : in  std_logic;
    processing_to_ram_we   : in  std_logic;
    processing_to_ram_addr : in  std_logic_vector( 7 downto 0);
    processing_to_ram_data : in  std_logic_vector(31 downto 0);
    ram_to_processing_data : out std_logic_vector(31 downto 0)
    );
end ram1;

architecture RTL of ram1 is

  --interface
  signal regs      : registers_type;
  signal sampling  : sampling_type;
  -- kernel
  signal bram_sreset : std_logic;
  signal bram_en : std_logic;
  signal bram_we : std_logic;
  signal bram_address : std_logic_vector( 7 downto 0);
  signal bram_datain  : std_logic_vector(31 downto 0);
  signal bram_dataout : std_logic_vector(31 downto 0);

begin

  regif_inst : entity work.ram1_reg
    port map(
      reset_n   => reset_n,
      clk       => clk,
      sreset    => sreset,
      ce        => ce,
      we        => we,
      address   => address,
      datain    => datain,
      dataout   => dataout,
      registers => regs,
      sampling  => sampling
    );


   bram : entity assets.bram_xilinx
   generic map(nbits_addr => 8, nbits_data=> 32)
   port map(
      clk     => clk,
      sreset  => bram_sreset,
      we      => bram_we,
      en      => bram_en,
      address => bram_address,
      datain  => bram_datain,
      dataout => bram_dataout
    );

    bram_sreset  <= regs.control.sreset when regs.control.mode='0' else '0';
    bram_en      <= regs.control.en     when regs.control.mode='0' else processing_to_ram_en;
    bram_we      <= regs.control.we     when regs.control.mode='0' else processing_to_ram_we;
    bram_address <= regs.address.value  when regs.control.mode='0' else processing_to_ram_addr;
    bram_datain  <= regs.datain.value   when regs.control.mode='0' else processing_to_ram_data;

    ram_to_processing_data <= bram_dataout;
    sampling.dataout_value <= bram_dataout;

end RTL;
