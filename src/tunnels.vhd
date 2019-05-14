library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package tunnels is

  type bfm is record
    ce : std_logic;
    we : std_logic;
    addr : unsigned( 7 downto 0);
    din  : std_logic_vector(31 downto 0);
  end record;

  signal bypass_en  : boolean :=false;
  signal bypass_bus : bfm;
  signal tunnel_dataout : std_logic_vector(31 downto 0);
end package;
