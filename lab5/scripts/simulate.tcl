# In Vivado Tcl Console: source /absolute/path/to/lab5/scripts/simulate.tcl
set lab_dir [file normalize [file join [file dirname [info script]] ..]]
create_project lab5_sim [file join $lab_dir build_sim] -part xc7a100tcsg324-1 -force
foreach name {alu_opcodes_pkg csr_pkg decoder_pkg decoder} {
    add_files [file join $lab_dir rtl ${name}.sv]
}
add_files -fileset sim_1 [file join $lab_dir tb lab_05.tb_decoder.sv]
set_property top decoder [get_filesets sources_1]
set_property top lab_05_tb_decoder [get_filesets sim_1]
set_property xsim.simulate.runtime 0ns [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
launch_simulation
add_wave /lab_05_tb_decoder/DUT/*
run all
