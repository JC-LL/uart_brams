-----------------------------------------------------------------
-- This file was generated automatically by vhdl_tb Ruby utility
-- date : (d/m/y) 11/05/2019 20:46
-- Author : Jean-Christophe Le Lann - 2014
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;--hread

library std;
use std.textio.all;

library debug_lib;
use debug_lib.tunnels.all;

library utils_lib;
use utils_lib.txt_util.all;

entity soc_tb is
end entity;

architecture bhv of soc_tb is

  constant HALF_PERIOD : time := 5 ns;

  signal clk     : std_logic := '0';
  signal reset_n : std_logic := '0';
  signal sreset  : std_logic := '0';
  signal running : boolean   := true;

  procedure wait_cycles(n : natural) is
   begin
     for i in 1 to n loop
       wait until rising_edge(clk);
     end loop;
   end procedure;

  signal rx      : std_logic;
  signal tx      : std_logic;
  signal leds    : std_logic_vector(15 downto 0);

begin
  -------------------------------------------------------------------
  -- clock and reset
  -------------------------------------------------------------------
  reset_n <= '0','1' after 666 ns;

  clk <= not(clk) after HALF_PERIOD when running else clk;

  --------------------------------------------------------------------
  -- Design Under Test
  --------------------------------------------------------------------
  dut : entity work.soc(rtl)
        port map (
          reset_n => reset_n,
          clk     => clk    ,
          rx      => rx     ,
          tx      => tx     ,
          leds    => leds
        );

  --------------------------------------------------------------------
  -- sequential stimuli
  --------------------------------------------------------------------
  stim : process

    procedure bfm_write(
      address : unsigned(7 downto 0);
      data    : std_logic_vector(31 downto 0)
    ) is
    begin
      wait until rising_edge(clk);
      bypass_bus.ce  <= '1';
      bypass_bus.we  <= '1';
      bypass_bus.addr <= address;
      bypass_bus.din  <= data;
      wait until rising_edge(clk);
      bypass_bus.ce  <= '0';
      bypass_bus.we  <= '0';
    end procedure;

    procedure bfm_read(
      address : unsigned(7 downto 0)
    ) is
    begin
      wait until rising_edge(clk);
      bypass_bus.ce   <= '1';
      bypass_bus.we   <= '0';
      bypass_bus.addr <= address;
      bypass_bus.din  <= (others=>'0');
      wait until rising_edge(clk);
      bypass_bus.ce   <= '0';
      bypass_bus.we   <= '0';
      bypass_bus.din  <= (others=>'0');
    end procedure;

    procedure cycles(n : natural) is
    begin
      for i in 0 to n-1 loop
        wait until rising_edge(clk);
      end loop;
    end procedure;

    procedure download_ram1(filename : string) is
      file f          : text;
      variable L      : line;
      variable status : file_open_status;
      variable addr  : std_logic_vector(31 downto 0);
      variable value  : std_logic_vector(31 downto 0);
      variable str17   : string(1 to 17);
      variable addr_str,data_str : string(1 to 8);
      variable char : character;
    begin
      FILE_OPEN(status, F, filename, read_mode);
      if status /= open_ok then
        report "problem to open stimulus file " & filename severity error;
      else
        report "downloading data from file " & filename;
        while not(ENDFILE(f)) loop
          readline(f,l);
          read(l,char);--0
          read(l,char);--x
          hread(l,addr);
          read(l,char);--space
          read(l,char);--0
          read(l,char);--x
          hread(l,value);
          report hstr(addr) & " " & hstr(value);
          -- write in reg 0x0 : address of IRAM
          bfm_write(x"00",addr);
          -- write in reg 0x1 : datain of IRAM
          bfm_write(x"01",value);
          -- write in reg 0x3 : control of IRAM
          bfm_write(x"03",x"00000003");-- 0...011" (ce,we)
        end loop;
        --bfm_write(x"03",x"00000008");-- 0...1000" (mode=1)
        report "end of download. Good.";
      end if;
    end procedure;

    procedure download_ram2(filename : string) is
      file f          : text;
      variable L      : line;
      variable status : file_open_status;
      variable addr  : std_logic_vector(31 downto 0);
      variable value  : std_logic_vector(31 downto 0);
      variable str17   : string(1 to 17);
      variable addr_str,data_str : string(1 to 8);
      variable char : character;
    begin
      FILE_OPEN(status, F, filename, read_mode);
      if status /= open_ok then
        report "problem to open stimulus file " & filename severity error;
      else
        report "downloading data from file " & filename;
        bfm_write(x"07",x"00000008");-- 0...0000"=0x0 (mode=0)
        while not(ENDFILE(f)) loop
          readline(f,l);
          read(l,char);--0
          read(l,char);--x
          hread(l,addr);
          read(l,char);--space
          read(l,char);--0
          read(l,char);--x
          hread(l,value);
          report hstr(addr) & " " & hstr(value);
          -- write in reg 0x4 : address of Data RAM
          bfm_write(x"04",addr);
          -- write in reg 0x5 : datain of D RAM
          bfm_write(x"05",value);
          -- write in reg 0x7 : control of D RAM
          bfm_write(x"07",x"00000003");-- 0...011"=0x3 (we,ce)
        end loop;
        wait_cycles(10);
        bfm_write(x"07",x"00000008");-- 0...1000"=0x8 (mode=1)
        report "end of download. Good.";
      end if;
    end procedure;

    procedure reread_ram2 is
      variable addr_bv : std_logic_vector(31 downto 0);
      begin

        report("re-reading data ram2 (0..10)");
        report("putting data ram in mode 0");
        bfm_write(x"07",x"00000000");-- 0...0 000"=0x0 (mode=0)

        for addr in 0 to 10 loop
          wait_cycles(1);
          addr_bv := std_logic_vector(to_unsigned(addr,32));
          report "addr : " & hstr(addr_bv);
          -- reg 4 is address of dram
          bfm_write(x"04", addr_bv);
          wait_cycles(4);
          -- reg 7 is control of dram
          bfm_write(x"07",x"00000002");-- 0...010"=0x2 (ce,we)
          bfm_read(x"06");
          wait_cycles(11);
          report "     data : " & hstr(tunnel_dataout);
        end loop;
      end procedure;

    procedure ending is
    begin
      report "end of stimuli";
      cycles(10);
      running <= false;
      wait;
    end procedure;

    procedure toggle(signal s : inout std_logic) is
    begin
       s <= '1';
       cycles(1);
       s <= '0';
    end procedure;

   begin
     report "running testbench for soc(rtl)";
     report "waiting for asynchronous reset";
     wait until reset_n='1';
     wait_cycles(10);
     report "applying stimuli...";
     download_ram1("ram1.hex");
     wait_cycles(20);
     download_ram2("ram2.hex");
     wait_cycles(20);

     reread_ram2;
     wait_cycles(50);

     bfm_write(x"03",x"0000000" & "0110");--sreset
     bfm_write(x"07",x"0000000" & "0110");--sreset

     bfm_write(x"03",x"0000000" & "1100");--control by proc
     bfm_write(x"07",x"0000000" & "1100");--control by proc
     bfm_write(x"08",x"00000001");--go!
     wait_cycles(500);
     reread_ram2;
     wait_cycles(50);
     report "end of simulation";
     running <=false;
     wait;
   end process;

end bhv;
