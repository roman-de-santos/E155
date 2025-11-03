if {[catch {

# define run engine funtion
source [file join {C:/lscc/radiant/2025.1} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) "1"
set para(prj_dir) "C:/Users/roman/Documents/E155/E155/Lab3/FPGA/attempt2/Lab3"
if {![file exists {C:/Users/roman/Documents/E155/E155/Lab3/FPGA/attempt2/Lab3/impl_1}]} {
  file mkdir {C:/Users/roman/Documents/E155/E155/Lab3/FPGA/attempt2/Lab3/impl_1}
}
cd {C:/Users/roman/Documents/E155/E155/Lab3/FPGA/attempt2/Lab3/impl_1}
# synthesize IPs
# synthesize VMs
# synthesize top design
::radiant::runengine::run_postsyn [list -a iCE40UP -p iCE40UP5K -t SG48 -sp High-Performance_1.2V -oc Industrial -top -w -o Lab3_impl_1_syn.udb Lab3_impl_1.vm] [list Lab3_impl_1.ldc]

} out]} {
   ::radiant::runengine::runtime_log $out
   exit 1
}
