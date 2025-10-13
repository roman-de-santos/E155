module top(
	input  logic       Reset,
	input  logic [3:0] Rows,
	output logic [3:0] Cols,
	output logic [6:0] Seg,
	output logic       En1, En2);

	logic IntOsc;
	logic [3:0] Sw1, Sw2;
	logic [15:0] KeyVal;
	
	// Initialize clock at 6MHz
	HSOSC #(.CLKHF_DIV(2'b11)) 
	 hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(IntOsc));
	 
	 // Initialize display
	 DualSevSeg DSevSeg(IntOsc, ~Reset, Sw1, Sw2, Seg, En1, En2);
	 
	 //Initialize keypad
	 Keypad keypad1(IntOsc, ~Reset, Rows, Cols, KeyVal);
	 
	 //initialize Fsm
	 DispFSM FSM1(IntOsc, ~Reset, KeyVal, Sw1, Sw2);
endmodule