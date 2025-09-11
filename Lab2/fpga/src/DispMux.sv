module DispMux(
	input  logic       IntOsc,
	input  logic [3:0] Sw1, Sw2,
	output logic [3:0] SegInput,
	output logic       En1, En2
);
	logic DivClk;
	logic [22:0] counter = 0;

	// Choose input to SegDisp decoder
	assign SegInput = DivClk ? Sw1 : Sw2;
	
	// Assign Enable bits
	assign En1 = ~DivClk;
	assign En2 =  DivClk;
	
   // Clock Divider 6MHz to 60Hz	
	always_ff @(posedge IntOsc) begin
		counter <= counter + 1;
		
		if (counter >= 23'd60000) begin
			DivClk  = ~DivClk;
			counter  <= 23'b0;
		end
	end
	
endmodule