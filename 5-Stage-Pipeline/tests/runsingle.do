transcript off
if {![file exists work]} {
    vlib work
}
vlog -sv ../pipeline_pkg.sv
vlog -sv ../ALU.sv
vlog -sv ../BranchUnit.sv
vlog -sv ../ControlUnit.sv
vlog -sv ../DataMem.sv
vlog -sv ../EX_MEM.sv
vlog -sv ../ForwardingUnit.sv
vlog -sv ../ForwardMux.sv
vlog -sv ../HazardUnit.sv
vlog -sv ../ID_EX.sv
vlog -sv ../IF_ID.sv
vlog -sv ../ImmGen.sv
vlog -sv ../InstructionMem.sv
vlog -sv ../MEM_WB.sv
vlog -sv ../Monitor.sv
vlog -sv ../PC_IF.sv
vlog -sv ../RegFile.sv
vlog -sv ../ResultMux.sv
vlog -sv ../RV32I_Pipeline.sv
vlog -sv ../RV32I_Pipeline_tb.sv


puts "Running cpitest"

# Open GUI
vsim work.tb_RV32I_Pipeline +TEST=programs/cpitest.hex

# Open windows
view wave
view structure
view signals

# Add signals
add wave -r sim:/tb_RV32I_Pipeline/dut/*

# Optional: zoom to fit after running
run -all
wave zoom full