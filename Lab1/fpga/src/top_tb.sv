// Roman De Santos
// rdesantos@hmc.edu
// 9/3/25
//
// This is the testbench for the top module

module top_tb();
	logic	     clk, reset;
	logic [3:0]  S;
	logic [6:0]  Seg, ExSeg;
	logic [2:0]  Led, ExLed;
	logic [31:0] vectornum, errors;
	logic [13:0] testvectors[15:0];
	
	// Initialize Device under Test
	top dut(S, Seg, Led);
	
	
	// Generate Clock
	always

		begin
		
			clk=1; #5;
			clk=0; #5;
			
		end
	
	// Start By reading testvectors
	initial
		
		begin
			
			$readmemb("top.tv", testvectors);
			
			vectornum=0;
			errors=0;
			
			reset=1; #22;
			reset=0;
			
		end
	
	// Assign test vectors on positive edge
	always @(posedge clk)
		
		begin
			
			#1;
			
			{S, ExSeg, ExLed} = testvectors[vectornum];
		
		end
		
	// Check if DUT output matches expected output at the end of the clock	
	always @(negedge clk)
		
		if (~reset) begin
		
			if ((Seg !== ExSeg) | (Led[1:0] !== ExLed[1:0])) begin
			
					$display("Error: inputs = %b", S);
					
					$display(" outputs = Seg: %b, Led: %b (Seg: %b, Led: %b expected)", Seg, Led, ExSeg, ExLed);
						
					errors = errors + 1;
			end
			
			vectornum = vectornum + 1;
			
			
			if (vectornum === 32'd16) begin
			
				$display("%d tests completed with %d errors", vectornum, 
					errors);
					
				$stop;
				
			end
			
		end

endmodule