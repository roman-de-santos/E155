// Roman De Santos
// rdesantos@hmc.edu
// 9/23/25
//
// This is the testbench for the Debunce module

module DispMux_tb();
	
	logic IntOsc, Reset;
	logic Sw;
	logic SwState;
	
	// Count the number of cycles 
	logic [18:0] Cycles;
	
	Debounce dut(IntOsc, Reset, Sw, SwState);
	
	// Initial setup
	initial begin
		Reset=1; #22;
		Reset=0;
		
		Cycles = 0;
		
		// generate a messy button input
		Sw = 0; #5;
		Sw = 1; #100;
		Sw = 0; #200;
		Sw = 1; #75;
		Sw = 1; #60000; // settle state
		
		Sw = 0; #300;
		Sw = 1; #200;
		Sw = 0; #300;
		Sw = 1; #500;
		Sw = 0; #3100000;
		Sw = 1;
		
	end
		
	// Generate Clock
	always begin
			IntOsc=1; #5;
			IntOsc=0; #5;
		end
	
//Run for 120k cycles (to visually inspect clock divider)	
	always @(negedge IntOsc) begin
		if (~Reset) begin
			if (Cycles === 19'd400000) begin
			
				//$display("%Two Divided Signal Cycles Shown, Visually inspect");
				$stop;
			end
			
				// Increment Cycles
				Cycles = Cycles + 1;
			end
		end
endmodule