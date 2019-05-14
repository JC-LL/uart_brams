--------------------------------------------------------------------------------
-- Generated automatically by Reggae compiler
-- (c) Jean-Christophe Le Lann - 2011
-- date : Sat May 11 21:09:00 2019
--------------------------------------------------------------------------------
library ieee,std;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package ram2_pkg is

  type address_reg is record
    value : std_logic_vector(7 downto 0);
  end record;

  constant ADDRESS_INIT: address_reg :=(
    value => x"00");

  type datain_reg is record
    value : std_logic_vector(31 downto 0);
  end record;

  constant DATAIN_INIT: datain_reg :=(
    value => "00000000000000000000000000000000");

  type dataout_reg is record
    value : std_logic_vector(31 downto 0);
  end record;

  constant DATAOUT_INIT: dataout_reg :=(
    value => "00000000000000000000000000000000");

  type control_reg is record
    we     : std_logic;
    en     : std_logic;
    sreset : std_logic;
    mode   : std_logic;
  end record;

  constant CONTROL_INIT: control_reg :=(
    we     => '0',
    en     => '0',
    sreset => '0',
    mode   => '0');

  type registers_type is record
    address : address_reg; -- 0x4
    datain  : datain_reg; -- 0x5
    dataout : dataout_reg; -- 0x6
    control : control_reg; -- 0x7
  end record;

  constant REGS_INIT : registers_type :=(
    address => ADDRESS_INIT,
    datain  => DATAIN_INIT,
    dataout => DATAOUT_INIT,
    control => CONTROL_INIT);

  --sampling values from IPs
  type sampling_type is record
    dataout_value : std_logic_vector(31 downto 0);
  end record;

end package;
