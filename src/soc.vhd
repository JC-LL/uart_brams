--------------------------------------------------------------------------------
-- Generated automatically by Reggae compiler
-- (c) Jean-Christophe Le Lann - 2011
-- date : Sat May 11 18:32:21 2019
--------------------------------------------------------------------------------
library ieee,std;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library assets;

--synthesis off
library debug_lib;
use  debug_lib.tunnels.all;

--synthesis on

entity soc is
  port(
    reset_n : in std_logic;
    clk     : in  std_logic;
    rx      : in  std_logic;
    tx      : out std_logic;
    leds    : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of soc is
  -- bus
  signal ce      : std_logic;
  signal we      : std_logic;
  signal address : unsigned(7 downto 0);
  signal datain  : std_logic_vector(31 downto 0);
  signal dataout : std_logic_vector(31 downto 0);
  --debug----
  signal dummy_ce      : std_logic;
  signal dummy_we      : std_logic;
  signal dummy_address : unsigned(7 downto 0);
  signal dummy_datain  : std_logic_vector(31 downto 0);
  signal dummy_dataout : std_logic_vector(31 downto 0);
  -----------
  signal dataout_ram1 : std_logic_vector(31 downto 0);
  signal dataout_ram2 : std_logic_vector(31 downto 0);
  signal dataout_proc : std_logic_vector(31 downto 0);
  --
  signal sreset  : std_logic;
  -- debug
  signal slow_clk,slow_tick : std_logic;
  --
  signal processing_to_ram1_en   : std_logic;
  signal processing_to_ram1_we   : std_logic;
  signal processing_to_ram1_addr : std_logic_vector( 7 downto 0);
  signal processing_to_ram1_data : std_logic_vector(31 downto 0);
  signal ram1_to_processing_data : std_logic_vector(31 downto 0);
  --
  signal processing_to_ram2_en   : std_logic;
  signal processing_to_ram2_we   : std_logic;
  signal processing_to_ram2_addr : std_logic_vector( 7 downto 0);
  signal processing_to_ram2_data : std_logic_vector(31 downto 0);
  signal ram2_to_processing_data : std_logic_vector(31 downto 0);

begin

  -- ============== UART as Master of bus !=========
  uart_master : entity assets.uart_bus_master
    generic map (DATA_WIDTH => 32)
    port map(
      reset_n => reset_n,
      clk     => clk,
      -- UART --
      rx      => rx,
      tx      => tx,
      -- **************Bus************** --
      -- *** uncomment for Testbench****
      --ce      => dummy_ce,
      --we      => dummy_we,
      --address => dummy_address,
      --datain  => dummy_datain,
      ce      => ce,
      we      => we,
      address => address,
      datain  => datain,
      dataout => dataout
      );

  --------------------------------------------------------
  -- D E B U G simulation
  --------------------------------------------------------
  -- synthesis off
  debug: process(bypass_bus,dataout)
  begin
    ce      <= bypass_bus.ce;
    we      <= bypass_bus.we;
    address <= bypass_bus.addr;
    datain  <= bypass_bus.din;
    tunnel_dataout <= dataout;
  end process;
  -- synthesis on

  sreset <= '0';
  processing_to_ram1_data <= (others=>'0');

  dataout <= dataout_ram1 or dataout_ram2 or dataout_proc;

  -- =====================ram1=====================
  inst_ram1 : entity work.ram1
    port map (
      reset_n => reset_n,
      clk     => clk,
      sreset  => sreset,
      -------------------------------
      ce      => ce,
      we      => we,
      address => address,
      datain  => datain,
      dataout => dataout_ram1,
      -------------------------------
      processing_to_ram_en   => processing_to_ram1_en,
      processing_to_ram_we   => processing_to_ram1_we,
      processing_to_ram_addr => processing_to_ram1_addr,
      processing_to_ram_data => processing_to_ram1_data,
      ram_to_processing_data => ram1_to_processing_data
    );

  -- =====================ram2=====================
  inst_ram2 : entity work.ram2
    port map (
      reset_n => reset_n,
      clk     => clk,
      sreset  => sreset,
      ce      => ce,
      we      => we,
      address => address,
      datain  => datain,
      dataout => dataout_ram2,
      -------------------------------
      processing_to_ram_en   => processing_to_ram2_en,
      processing_to_ram_we   => processing_to_ram2_we,
      processing_to_ram_addr => processing_to_ram2_addr,
      processing_to_ram_data => processing_to_ram2_data,
      ram_to_processing_data => ram2_to_processing_data
    );

  -- ==================processing==================
  inst_processing : entity work.processing
    port map (
      reset_n => reset_n,
      clk     => clk,
      -----------------------
      sreset  => sreset,
      ce      => ce,
      we      => we,
      address => address,
      datain  => datain,
      dataout => dataout_proc,
      ------------------------
      processing_to_ram1_en   => processing_to_ram1_en   ,
      processing_to_ram1_we   => processing_to_ram1_we   ,
      processing_to_ram1_addr => processing_to_ram1_addr ,
      ram1_to_processing_data => ram1_to_processing_data ,
      ----
      processing_to_ram2_en   => processing_to_ram2_en   ,
      processing_to_ram2_we   => processing_to_ram2_we   ,
      processing_to_ram2_addr => processing_to_ram2_addr ,
      processing_to_ram2_data => processing_to_ram2_data
    );

  -- =================== DEBUG ====================
  ticker : entity assets.slow_ticker(rtl)
    port map(
      reset_n   => reset_n,
      fast_clk  => clk,
      slow_clk  => slow_clk,
      slow_tick => slow_tick
      );
  leds <= reset_n & "00000000000000" & slow_clk;

end;
