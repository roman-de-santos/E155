// Roman De Santos
// rdesantos@hmc.edu
// 9/3/25
//
// This is the testbench for the top module

module top_tb();
	logic	     Clk, Reset;
	logic [3:0]  S;
	logic [6:0]  Seg, ExSeg;
	logic [2:0]  Led, ExLed;
	logic [31:0] VectorNum, Errors;
	logic [13:0] TestVectors[15:0];
	
	// Initialize Device under Test
	top dut(S, Seg, Led);
	
	
	// Generate Clock
	always

		begin
		
			Clk=1; #5;
			Clk=0; #5;
			
		end
	
	// Start By reading testvectors
	initial
		
		begin
			
			$readmemb("top.tv", TestVectors);
			
			VectorNum=0;
			Errors=0;
			
			Reset=1; #22;
			Reset=0;
			
		end
	
	// Assign test vectors on positive edge
	always @(posedge Clk)
		
		begin
			
			#1;
			
			{S, ExSeg, ExLed} = TestVectors[VectorNum];
		
		end
		
	// Check if DUT output matches expected output at the end of the clock	
	always @(negedge Clk)
		
		if (~Reset) begin
		
			if ((Seg !== ExSeg) | (Led[1:0] !== ExLed[1:0])) begin
			
					$display("Error: inputs = %b", S);
					
					$display(" outputs = Seg: %b, Led: %b (Seg: %b, Led: %b expected)", Seg, Led, ExSeg, ExLed);
						
					Errors = Errors + 1;
			end
			
			VectorNum = VectorNum + 1;
			
			
			if (VectorNum === 32'd16) begin
			
				$display("%d tests completed with %d errors", VectorNum, 
					Errors);
					
				$stop;
				
			end
			
		end

endmodule