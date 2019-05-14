--------------------------------------------------------------------------------
-- Generated automatically by Reggae compiler
-- (c) Jean-Christophe Le Lann - 2011
-- date : Sat May 11 21:09:00 2019
--------------------------------------------------------------------------------
library ieee,std;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.processing_pkg.all;

entity processing_reg is
  port(
    reset_n : in  std_logic;
    clk     : in  std_logic;
    sreset  : in  std_logic;
    ce        : in  std_logic;
    we        : in  std_logic;
    address   : in  unsigned(7 downto 0);
    datain    : in  std_logic_vector(31 downto 0);
    dataout   : out std_logic_vector(31 downto 0);
    registers : out registers_type;
    sampling  : in sampling_type);
end processing_reg;

architecture RTL of processing_reg is

  --interface
  signal regs : registers_type;

  --addresses are declared here to avoid VHDL93 error /locally static/
  constant ADDR_CONTROL : unsigned(7 downto 0) := "00001000";-- 0x08;
  constant ADDR_STATUS  : unsigned(7 downto 0) := "00001001";-- 0x09;

  --application signals

begin

  write_reg_p : process(reset_n,clk)
  begin
    if reset_n='0' then
      regs <= REGS_INIT;
    elsif rising_edge(clk) then
      if ce='1' then
        if we='1' then
          case address is
            when ADDR_CONTROL =>
              regs.control.go <= datain(0);
            when ADDR_STATUS =>
              regs.status.completed <= datain(0);
            when others =>
              null;
          end case;
        end if;
      else --no bus preemption => sampling or toggle
      --sampling
        regs.status.completed <= sampling.completed;--null; --no_sampling
        --toggling
        regs.control.go <= '0'; 
      end if;
    end if;
  end process;

  read_reg_p: process(reset_n,clk)
  begin
    if reset_n='0' then
      dataout <= (others=>'0');
    elsif rising_edge(clk) then
      if ce='1' then
        if we='0' then
          dataout <= (others=>'0');
          case address is
            when ADDR_CONTROL =>
              dataout(0) <= regs.control.go;
            when ADDR_STATUS =>
              dataout(0) <= regs.status.completed;
            when others=>
              dataout <= (others=>'0');
          end case;
        end if;
      end if;
    end if;
  end process;
  registers <= regs;

end RTL;
