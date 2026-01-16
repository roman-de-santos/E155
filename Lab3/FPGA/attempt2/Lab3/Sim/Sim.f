-L work
-reflib pmi_work
-reflib ovi_ice40up


"C:/Users/roman/Documents/E155/E155/Lab3/FPGA/attempt2/Lab3/source/impl_1/top.sv" 
"C:/Users/roman/Documents/E155/E155/Lab3/FPGA/attempt2/Lab3/source/impl_1/DispMux.sv" 
"C:/Users/roman/Documents/E155/E155/Lab3/FPGA/attempt2/Lab3/source/impl_1/DualSevSeg.sv" 
"C:/Users/roman/Documents/E155/E155/Lab3/FPGA/attempt2/Lab3/source/impl_1/SegDisp.sv" 
"C:/Users/roman/Documents/E155/E155/Lab3/FPGA/attempt2/Lab3/source/impl_1/KeypadFSM.sv" 
"C:/Users/roman/Documents/E155/E155/Lab3/FPGA/attempt2/Lab3/source/impl_1/Sync.sv" 
"C:/Users/roman/Documents/E155/E155/Lab3/FPGA/attempt2/Lab3/source/impl_1/Sync_tb.sv" 
-sv
-optionset VOPTDEBUG
+noacc+pmi_work.*
+noacc+ovi_ice40up.*

-vopt.options
  -suppress vopt-7033
-end

-gui
-top tb_Sync
-vsim.options
  -suppress vsim-7033,vsim-8630,3009,3389
-end

-do "view wave"
-do "add wave /*"
-do "run -all"
