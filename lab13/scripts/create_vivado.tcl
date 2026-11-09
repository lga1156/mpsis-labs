# vivado -mode batch -source scripts/create_vivado.tcl
set root [file normalize [file join [file dirname [info script]] ..]]
create_project lab13 [file join $root build vivado] -part xc7a100tcsg324-1 -force
set fp [open [file join $root sources.f] r]
foreach line [split [read $fp] \n] {
 if {[string trim $line] ne ""} {add_files [file join $root $line]}
}
close $fp
add_files [glob [file join $root mem *.mem]]
add_files -fileset constrs_1 [file join $root constraints nexys_a7_100t.xdc]
set_property top riscv_unit [get_filesets sources_1]
add_files -fileset sim_1 [glob [file join $root tb *.sv]]
set_property top lab_13_tb_processor_system [get_filesets sim_1]
set_property xsim.simulate.runtime 4ms [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
# BUFG is supplied by Xilinx UNISIM; do NOT add tb/BUFG.sv here.
puts "Project created. Run synthesis and implementation, inspect timing/DRC, then generate bitstream."
