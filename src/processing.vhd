--------------------------------------------------------------------------------
-- Generated automatically by Reggae compiler
-- (c) Jean-Christophe Le Lann - 2011
-- date : Sat May 11 21:09:00 2019
--------------------------------------------------------------------------------
library ieee,std;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.processing_pkg.all;

--synthesis off
library utils_lib;
use utils_lib.txt_util.all;
--synthesis on

entity processing is
  port(
    reset_n : in  std_logic;
    clk     : in  std_logic;
    sreset  : in  std_logic;
    --------bus----------------
    ce      : in  std_logic;
    we      : in  std_logic;
    address : in  unsigned(7 downto 0);
    datain  : in  std_logic_vector(31 downto 0);
    dataout : out std_logic_vector(31 downto 0);
    ---------------------------
    processing_to_ram1_en   : out std_logic;
    processing_to_ram1_we   : out std_logic;
    processing_to_ram1_addr : out std_logic_vector( 7 downto 0);
    ram1_to_processing_data : in  std_logic_vector(31 downto 0);
    --
    processing_to_ram2_en   : out std_logic;
    processing_to_ram2_we   : out std_logic;
    processing_to_ram2_addr : out std_logic_vector( 7 downto 0);
    processing_to_ram2_data : out std_logic_vector(31 downto 0)
    );
end processing;

architecture RTL of processing is

  --interface
  signal regs      : registers_type;
  signal sampling  : sampling_type;
  --
  type state_t is (IDLE,COMPUTING,WAIT_CYCLE);
  signal state_r,state_c : state_t;
  signal addr_r,addr_c : unsigned(7 downto 0);
  --signal value: unsigned(31 downto 0);
  --signal addr: unsigned(7 downto 0);
begin

  regif_inst : entity work.processing_reg
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


  tick : process(reset_n,clk)
  begin
    if reset_n='0' then
      state_r <= IDLE;
      addr_r <= to_unsigned(0,8);
    elsif rising_edge(clk) then
      state_r <= state_c;
      addr_r <= addr_c;
    end if;
  end process;

  comb: process(state_r,addr_r,regs,ram1_to_processing_data)
  variable state_v : state_t;
  variable addr_v : unsigned(7 downto 0);
  variable value : unsigned(31 downto 0);
  begin
    state_v := state_r;
    addr_v := addr_r;
    value:=to_unsigned(0,32);
    processing_to_ram1_en   <= '0';
    processing_to_ram1_we   <= '0';
    processing_to_ram1_addr <= std_logic_vector(to_unsigned(0,8));
    processing_to_ram2_en   <= '0';
    processing_to_ram2_we   <= '0';
    processing_to_ram2_addr <= std_logic_vector(to_unsigned(0,8));
    processing_to_ram2_data <= std_logic_vector(to_unsigned(0,32));
    sampling.completed <= regs.status.completed;
    case state_v is
      when IDLE =>
        if regs.control.go='1' then
          processing_to_ram1_en <= '1';
          processing_to_ram1_we <= '0';
          processing_to_ram1_addr <= std_logic_vector(addr_v);
          state_v := COMPUTING;
        end if;
      when COMPUTING =>
        value := unsigned(ram1_to_processing_data);
        --synthesis off
        report "value = " & str(std_logic_vector(value));
        --synthesis on
        value := resize((value + 1 ) * 3,32); --THE computing !
        processing_to_ram2_en <= '1';
        processing_to_ram2_we <= '1';
        processing_to_ram2_addr <= std_logic_vector(addr_v);
        processing_to_ram2_data <= std_logic_vector(value);
        if addr_v < 255 then
          processing_to_ram1_en <= '1';
          processing_to_ram1_we <= '0';
          addr_v := addr_v+1;
          processing_to_ram1_addr <= std_logic_vector(addr_v);
        else
          state_v := IDLE;
          sampling.completed <= '1';
        end if;
      when others=>
        null;
    end case;
    state_c <= state_v;
    addr_c <= addr_v;
  end process;
end RTL;
