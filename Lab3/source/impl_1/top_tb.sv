// Roman De Santos
// rdesantos@hmc.edu
// 9/3/25
//
// This is the testbench for the DispMux module

module top_tb();
	
	logic       IntOsc, Reset;
	logic [3:0] Rows, Cols;
	logic [6:0] Seg;
	logic       En1, En2;
	
	// Count the number of cycles 
	logic [19:0] Cycles;
	
	top dut(Reset, Rows, Cols, Seg, En1, En2);
	
	// Initial setup
	initial begin
		Reset=1; #22;
		Reset=0;
		
		Rows= 4'b1111;
		
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
			if (Cycles === 20'd400000) begin
			
				//$display("%Two Divided Signal Cycles Shown, Visually inspect");
				$stop;
			end
			
				// Increment Cycles
				Cycles = Cycles + 1;
			end
		end
endmodule