--------------------------------------------------------------------------------
-- Generated automatically by Reggae compiler
-- (c) Jean-Christophe Le Lann - 2011
-- date : Sat May 11 21:09:00 2019
--------------------------------------------------------------------------------
library ieee,std;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package processing_pkg is

  type control_reg is record
    go : std_logic;
  end record;

  constant CONTROL_INIT: control_reg :=(
    go => '0');

  type status_reg is record
    completed : std_logic;
  end record;

  constant STATUS_INIT: status_reg :=(
    completed => '0');

  type registers_type is record
    control : control_reg; -- 0x9
    status  : status_reg; -- 0xa
  end record;

  constant REGS_INIT : registers_type :=(
    control => CONTROL_INIT,
    status  => STATUS_INIT);

  --sampling values from IPs
  type sampling_type is record
    completed : std_logic;
  end record;

end package;
