# =====FPGA device : Artix7 in Nexys4DDR
set partname "xc7a100tcsg324-1"
set xdc_constraints "./Nexys-A7-100T-Master.xdc"

# =====Define output directory
set outputDir ./SYNTH_OUTPUTS
file mkdir $outputDir

# =====Setup design sources and constraints
#echo "=> compiling assets..."
read_vhdl -library assets ../src/assets/bram_xilinx.vhd
read_vhdl -library assets ../src/assets/fifo.vhd
read_vhdl -library assets ../src/assets/flag_buf.vhd
read_vhdl -library assets ../src/assets/mod_m_counter.vhd
read_vhdl -library assets ../src/assets/uart_rx.vhd
read_vhdl -library assets ../src/assets/uart_tx.vhd
read_vhdl -library assets ../src/assets/uart.vhd
read_vhdl -library assets ../src/assets/slow_ticker.vhd
read_vhdl -library assets ../src/assets/uart_bus_master.vhd

#echo "=> compiling src/vhd"
read_vhdl ../src/ram1_pkg.vhd
read_vhdl ../src/ram1_reg.vhd
read_vhdl ../src/ram1.vhd
read_vhdl ../src/ram2_pkg.vhd
read_vhdl ../src/ram2_reg.vhd
read_vhdl ../src/ram2.vhd
read_vhdl ../src/processing_pkg.vhd
read_vhdl ../src/processing_reg.vhd
read_vhdl ../src/processing.vhd
read_vhdl ../src/soc.vhd

read_xdc $xdc_constraints

synth_design -top soc -part $partname
write_checkpoint -force $outputDir/post_synth.dcp
report_timing_summary -file $outputDir/post_synth_timing_summary.rpt
report_utilization -file $outputDir/post_synth_util.rpt
opt_design
#reportCriticalPaths $outputDir/post_opt_critpath_report.csv

place_design
# report_clock_utilization -file $outputDir/clock_util.rpt
#
write_checkpoint -force $outputDir/post_place.dcp
report_utilization -file $outputDir/post_place_util.rpt
report_timing_summary -file $outputDir/post_place_timing_summary.rpt

# ====== run the router, write the post-route design checkpoint, report the routing
# status, report timing, power, and DRC, and finally save the Verilog netlist.
#
route_design
write_checkpoint -force $outputDir/post_route.dcp
report_route_status -file $outputDir/post_route_status.rpt
report_timing_summary -file $outputDir/post_route_timing_summary.rpt
report_power -file $outputDir/post_route_power.rpt
report_drc -file $outputDir/post_imp_drc.rpt
# write_verilog -force $outputDir/cpu_impl_netlist.v -mode timesim -sdf_anno true

# ====== generate a bitstream
write_bitstream -force $outputDir/top.bit
exit
