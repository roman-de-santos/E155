module Debounce(
	input  logic Clk, Reset,
	input  logic Sw,
	output logic SwState);

	logic [14:0] counter;
	logic        SwSync0, SwSync1;
	logic        SwIdle, SwMax;
	
	assign SwIdle = (SwState == SwSync1);
	assign SwMax  = &counter;
	
	always @(posedge Clk) begin
		if (Reset) begin SwState = 0; end
		
		SwSync0 = ~Sw;
		SwSync1 = SwSync0;
		
		if(SwIdle || Reset) begin
			counter = 0;
		end else begin
			counter = counter +1;
			if(SwMax) SwState = ~SwState;
		end
	end
	

endmodule