module top(
	input  logic       Reset,
	input  logic [3:0] Rows,
	output logic [3:0] Cols,
	output logic [6:0] Seg,
	output logic       En1, En2, debug); // remove debug
	
	// Internal Nets
	logic       IntOsc;
	logic [3:0] Sw1, Sw2;
	logic [3:0] dRows;
	
	// Initialize clock at 6MHz
	HSOSC #(.CLKHF_DIV(2'b11)) 
	 hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(IntOsc));
	 
	 Sync sync1(IntOsc, ~Reset, Rows, dRows);
	 
	// Initialize display
	 DualSevSeg DSevSeg(IntOsc, ~Reset, Sw1, Sw2, Seg, En1, En2);
	 
	//Initialize keypad
	KeypadFSM keypad1(IntOsc, ~Reset, dRows, Cols, Sw1, Sw2, debug); //remove debug after
 
endmodule