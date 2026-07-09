transcript off
if {![file exists work]} {
    vlib work
}
vlog -sv ../pipeline_pkg.sv
vlog -sv ../ALU.sv
vlog -sv ../BranchUnit.sv
vlog -sv ../ControlUnit.sv
vlog -sv ../UnifiedMem.sv
vlog -sv ../EX_MEM.sv
vlog -sv ../ForwardingUnit.sv
vlog -sv ../ForwardMux.sv
vlog -sv ../HazardUnit.sv
vlog -sv ../ID_EX.sv
vlog -sv ../IF_ID.sv
vlog -sv ../ImmGen.sv
vlog -sv ../MEM_WB.sv
vlog -sv ../Monitor.sv
vlog -sv ../PC_IF.sv
vlog -sv ../RegFile.sv
vlog -sv ../ResultMux.sv
vlog -sv ../RV32I_Pipeline.sv
vlog -sv ../RV32I_Pipeline_tb.sv

set tests {
    add
    addi
    and
    andi
    branch_matrix
    beq
    bne
    dual_forward
    ebreak
    ecall
    misaligned_lh
    misaligned_lw
    misaligned_sh
    misaligned_sw
    jal
    jalr
    jalr_link
    load_branch_hazard
    or
    ori
    sll
    sra
    srl
    sub
    sb_lb
    sb_lbu
    sh_lh
    sh_lhu
    sw_lw_regression
    sw_lw
    sign_extension
    zero_extension
    offset
    fence
    xor
    xori
    stress
}

foreach test $tests {

    
    puts "Running $test"

    vsim -c -quiet -nolog -onfinish stop work.RV32I_Pipeline_tb \
        +TEST=programs/$test.hex

    run -all
}

puts "Tests Complete"

quit -f
