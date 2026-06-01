vlib work
vmap work work

# RTL
vlog -cover bcestf ../rtl/apb4_pkg.sv
vlog -cover bcestf ../rtl/apb4_slave.sv

# Interface
vlog -cover bcestf ../tb/interface/apb_if.sv

# TB Package
vlog -cover bcestf +incdir+../tb/sequence_item \
     +incdir+../tb/sequences \
     +incdir+../tb/sequencer \
     +incdir+../tb/driver \
     +incdir+../tb/monitor \
     +incdir+../tb/scoreboard \
     +incdir+../tb/coverage \
     +incdir+../tb/agent \
     +incdir+../tb/env \
     +incdir+../tb/tests \
     ../tb/pkg/apb_tb_pkg.sv

# Top
vlog -cover bcestf ../tb/top/top_tb.sv

# Simulate
vsim -coverage top_tb +UVM_TESTNAME=apb_smoke_test +UVM_VERBOSITY=UVM_DEBUG -voptargs="+acc +cover=bcesft" -onfinish stop

# Waves
add wave sim:/top_tb/apb_vif/*
add wave sim:/top_tb/dut/*

# Run
run -all
coverage save smoke.ucdb
quit -f