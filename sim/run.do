vlib work
vmap work work

# RTL
vlog ../rtl/apb4_pkg.sv
vlog ../rtl/apb4_slave.sv

# Interface
vlog ../tb/interface/apb_if.sv

# TB Package
vlog +incdir+../tb/sequence_item \
     +incdir+../tb/sequencer \
     +incdir+../tb/driver \
     +incdir+../tb/monitor \
     +incdir+../tb/agent \
     +incdir+../tb/env \
     +incdir+../tb/tests \
     ../tb/pkg/apb_tb_pkg.sv

# Top
vlog ../tb/top/top_tb.sv