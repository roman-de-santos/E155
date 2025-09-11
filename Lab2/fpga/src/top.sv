module top(
	input  logic [3:0] Sw1, Sw2,
	output logic [6:0] Seg,
	output logic       En1, En2,
	output logic [4:0] Sum
	);

	logic [3:0]  SegInput;
	logic        IntOsc;
	
	// Initialize clock at 6MHz
	HSOSC #(.CLKHF_DIV(2'b11)) 
	 hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(IntOsc));
	
	DispMux DM(IntOsc, Sw1, Sw2, SegInput, En1, En2);
	
	SegDisp DispDecoder(SegInput, Seg);
	
	//Assign Sum LEDs (active low so invert)
	assign Sum = ~(Sw1+Sw2);
	
endmodule
	
