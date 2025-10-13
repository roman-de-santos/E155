module top(
	input  logic       Reset,
	input  logic [3:0] Rows,
	output logic [3:0] Cols,
	output logic [6:0] Seg,
	output logic       En1, En2);
	
	// Internal Nets
	logic       IntOsc;
	logic [3:0] Sw1, Sw2;
	
	// Initialize clock at 6MHz
	HSOSC #(.CLKHF_DIV(2'b11)) 
	 hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(IntOsc));
	 
	// Initialize display
	 DualSevSeg DSevSeg(IntOsc, ~Reset, Sw1, Sw2, Seg, En1, En2);
	 
	//Initialize keypad
	KeypadFSM keypad1(IntOsc, ~Reset, Rows, Cols, Sw1, Sw2);

endmodule