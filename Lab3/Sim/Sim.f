-L work
-reflib pmi_work
-reflib ovi_ice40up


"C:/Users/rdesantos/Downloads/Lab3/source/impl_1/Debounce.sv" 
"C:/Users/rdesantos/Downloads/Lab3/source/impl_1/DispMux.sv" 
"C:/Users/rdesantos/Downloads/Lab3/source/impl_1/DualSevSeg.sv" 
"C:/Users/rdesantos/Downloads/Lab3/source/impl_1/SegDisp.sv" 
"C:/Users/rdesantos/Downloads/Lab3/source/impl_1/DispFSM.sv" 
"C:/Users/rdesantos/Downloads/Lab3/source/impl_1/top.sv" 
"C:/Users/rdesantos/Downloads/Lab3/source/impl_1/Keypad.sv" 
"C:/Users/rdesantos/Downloads/Lab3/source/impl_1/top_tb.sv" 
-sv
-optionset VOPTDEBUG
+noacc+pmi_work.*
+noacc+ovi_ice40up.*

-vopt.options
  -suppress vopt-7033
-end

-gui
-top top_tb
-vsim.options
  -suppress vsim-7033,vsim-8630,3009,3389
-end

-do "view wave"
-do "add wave /*"
-do "run -all"
