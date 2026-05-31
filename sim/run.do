vlib work
vmap work work

# RTL
vlog ../rtl/apb4_pkg.sv
vlog ../rtl/apb4_slave.sv

# Interface
vlog ../tb/interface/apb_if.sv

# TB Package
vlog +incdir+../tb/sequence_item \
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
vlog ../tb/top/top_tb.sv

# Simulate
vsim top_tb +UVM_TESTNAME=apb_pstrb_test +UVM_VERBOSITY=UVM_DEBUG -voptargs=+acc

# Waves
add wave sim:/top_tb/apb_vif/*
add wave sim:/top_tb/dut/*

# Run
run -all