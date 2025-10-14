-L work
-reflib pmi_work
-reflib ovi_ice40up


"C:/Users/rdesantos/Documents/GitHub/E155/Lab3/FPGA/attempt2/Lab3/source/impl_1/KeypadFSM.sv" 
"C:/Users/rdesantos/Documents/GitHub/E155/Lab3/FPGA/attempt2/Lab3/source/impl_1/KeypadFSM_tb.sv" 
-sv
-optionset VOPTDEBUG
+noacc+pmi_work.*
+noacc+ovi_ice40up.*

-vopt.options
  -suppress vopt-7033
-end

-gui
-top KeypadFSM_tb
-vsim.options
  -suppress vsim-7033,vsim-8630,3009,3389
-end

-do "view wave"
-do "add wave /*"
-do "run -all"
