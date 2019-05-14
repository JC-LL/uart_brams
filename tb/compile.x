echo "=> cleaning..."
rm -rf soc_tb tb.ghw

echo "=> compiling utils_lib"
ghdl -a --ieee=synopsys --work=utils_lib txt_util.vhd

echo "=> compiling assets lib..."
ghdl -a --work=assets ../src/assets/bram_xilinx.vhd
ghdl -a --work=assets ../src/assets/fifo.vhd
ghdl -a --work=assets ../src/assets/flag_buf.vhd
ghdl -a --work=assets ../src/assets/mod_m_counter.vhd
ghdl -a --work=assets ../src/assets/uart_rx.vhd
ghdl -a --work=assets ../src/assets/uart_tx.vhd
ghdl -a --work=assets ../src/assets/uart.vhd
ghdl -a --work=assets ../src/assets/slow_ticker.vhd
ghdl -a --work=assets ../src/assets/uart_bus_master.vhd

echo "=> compiling debug lib /tunnels"
ghdl -a --work=debug_lib ../src/tunnels.vhd

echo "=> compiling work lib /vhd"
ghdl -a ../src/ram1_pkg.vhd
ghdl -a ../src/ram1_reg.vhd
ghdl -a ../src/ram1.vhd
ghdl -a ../src/ram2_pkg.vhd
ghdl -a ../src/ram2_reg.vhd
ghdl -a ../src/ram2.vhd
ghdl -a ../src/processing_pkg.vhd
ghdl -a ../src/processing_reg.vhd
ghdl -a ../src/processing.vhd
ghdl -a ../src/soc.vhd

echo "=> compiling soc_tb"
ghdl -a --ieee=synopsys soc_tb.vhd

echo "=> elaborating soc_tb"
ghdl -e --ieee=synopsys soc_tb

if [ -f "soc_tb" ];then
echo "=> running simulation"
ghdl -r soc_tb --wave=tb.ghw

echo "=> viewing"
gtkwave tb.ghw tb.sav
fi ;
