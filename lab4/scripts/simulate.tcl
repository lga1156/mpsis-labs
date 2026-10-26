# In Vivado Tcl Console: source /absolute/path/to/lab4/scripts/simulate.tcl
set lab_dir [file normalize [file join [file dirname [info script]] ..]]
create_project lab4_sim [file join $lab_dir build_sim] -part xc7a100tcsg324-1 -force
add_files [glob [file join $lab_dir rtl *.sv]]
add_files [file join $lab_dir mem program.mem]
add_files -fileset sim_1 [file join $lab_dir tb lab_04.tb_cybercobra.sv]
set_property top CYBERcobra [get_filesets sources_1]
set_property top lab_04_tb_CYBERcobra [get_filesets sim_1]
set_property xsim.simulate.runtime 0ns [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
launch_simulation
add_wave /lab_04_tb_CYBERcobra/DUT/*
run all
