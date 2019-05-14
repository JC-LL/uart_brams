--------------------------------------------------------------------------------
-- Generated automatically by Reggae compiler
-- (c) Jean-Christophe Le Lann - 2011
-- date : Sat May 11 21:09:00 2019
--------------------------------------------------------------------------------
library ieee,std;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ram2_pkg.all;

entity ram2_reg is
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
end ram2_reg;

architecture RTL of ram2_reg is

  --interface
  signal regs : registers_type;

  --addresses are declared here to avoid VHDL93 error /locally static/
  constant ADDR_ADDRESS : unsigned(7 downto 0) := "00000100";-- 0x04;
  constant ADDR_DATAIN  : unsigned(7 downto 0) := "00000101";-- 0x05;
  constant ADDR_DATAOUT : unsigned(7 downto 0) := "00000110";-- 0x06;
  constant ADDR_CONTROL : unsigned(7 downto 0) := "00000111";-- 0x07;

  --application signals
  signal dataout_value : std_logic_vector(31 downto 0);

begin

  write_reg_p : process(reset_n,clk)
  begin
    if reset_n='0' then
      regs <= REGS_INIT;
    elsif rising_edge(clk) then
      if ce='1' then
        if we='1' then
          case address is
            when ADDR_ADDRESS =>
              regs.address.value <= datain(7 downto 0);
            when ADDR_DATAIN =>
              regs.datain.value <= datain(31 downto 0);
            when ADDR_DATAOUT =>
              regs.dataout.value <= datain(31 downto 0);
            when ADDR_CONTROL =>
              regs.control.we <= datain(0);
              regs.control.en <= datain(1);
              regs.control.sreset <= datain(2);
              regs.control.mode <= datain(3);
            when others =>
              null;
          end case;
        end if;
      else --no bus preemption => sampling or toggle
      --sampling
        regs.dataout.value <= sampling.dataout_value;
      --toggling
        regs.control.we <= '0';
        regs.control.en <= '0';
        regs.control.sreset <= '0';
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
            when ADDR_ADDRESS =>
              dataout(7 downto 0) <= regs.address.value;
            when ADDR_DATAIN =>
              dataout(31 downto 0) <= regs.datain.value;
            when ADDR_DATAOUT =>
              dataout(31 downto 0) <= regs.dataout.value;
            when ADDR_CONTROL =>
              dataout(0) <= regs.control.we;
              dataout(1) <= regs.control.en;
              dataout(2) <= regs.control.sreset;
              dataout(3) <= regs.control.mode;
            when others=>
              dataout <= (others=>'0');
          end case;
        end if;
      end if;
    end if;
  end process;
  registers <= regs;

end RTL;
