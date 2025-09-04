// Roman De Santos
// rdesantos@hmc.edu
// 9/3/25
//
// This is the testbench for the SegDisp module

module SegDisp_tb();
	logic	     Clk, Reset;
	logic [3:0]  S;
	logic [6:0]  Seg, ExSeg;
	logic [31:0] VectorNum, Errors;
	logic [10:0] TestVectors[15:0];
	
	// Initialize Device under Test
	SegDisp dut(S, Seg);
	
	// Generate Clock
	always

		begin
		
			Clk=1; #5;
			Clk=0; #5;
			
		end
	
	// Start By reading testvectors
	initial
		
		begin
			
			$readmemb("SegDisp.tv", TestVectors);
			
			VectorNum=0;
			Errors=0;
			
			Reset=1; #22;
			Reset=0;
			
		end
	
	// Assign test vectors on positive edge
	always @(posedge Clk)
		
		begin
			
			#1;
			
			{S, ExSeg} = TestVectors[VectorNum];
		
		end
		
	// Check if DUT output matches expected output at the end of the clock	
	always @(negedge Clk)
		
		if (~Reset) begin
		
			if (Seg !== ExSeg) begin // check if output matches expectation
			
					$display("Error: inputs = %b", S);
					
					$display(" outputs = %b (%b expected)", Seg, ExSeg);
						
					Errors = Errors + 1;
			end
			
			VectorNum = VectorNum + 1;
			
			
			if (TestVectors[VectorNum] === 11'bx) begin
			
				$display("%d tests completed with %d errors", VectorNum, 
					Errors);
					
				$stop;
				
			end
			
		end

endmodule