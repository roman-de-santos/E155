// Roman De Santos
// rdesantos@hmc.edu
// 9/3/25
//
// This is the testbench for the DispMux module

module DispMux_tb();
	
	logic       IntOsc, Reset;
	logic [3:0] Sw1, Sw2;
	logic [6:0] SegInput;
	logic       En1, En2;
	
	// Count the number of cycles 
	logic [16:0]Cycles;
	
	DispMux dut(IntOsc, Sw1, Sw2, SegInput, En1, En2);
	
	// Initial setup
	initial begin
		Reset=1; #22;
		Reset=0;
		
		Sw1 = 0;
		Sw2 = 0;
		
		Cycles = 0;
	end
		
	// Generate Clock
	always begin
			IntOsc=1; #5;
			IntOsc=0; #5;
		end
	
//Run for 120k cycles (to visually inspect clock divider)	
	always @(negedge IntOsc) begin
		if (~Reset) begin
			if (Cycles === 17'd125000) begin
			
				//$display("%Two Divided Signal Cycles Shown, Visually inspect");
				$stop;
			end
			
				// Increment Cycles
				Cycles = Cycles + 1;
			end
		end
endmodule