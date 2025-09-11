// Roman De Santos
// rdesantos@hmc.edu
// 9/11/25
//
// This is the top module for Lab2
// 
// Input:  Sw1, Sw2 are dip switches
// Output: seg = {A, B, C, D, E, F, G} where each letter is a segment in the display
//   		En1, En2 are the bits that control which display is on
// 			Sum is the sum of the two dipswitches

module top(
	input  logic [3:0] Sw1, Sw2,
	output logic [6:0] Seg,
	output logic       En1, En2,
	output logic [4:0] Sum
	);
	
	// Internal nets
	logic [3:0]  SegInput;
	logic        IntOsc;
	
	// Initialize clock at 6MHz
	HSOSC #(.CLKHF_DIV(2'b11)) 
	 hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(IntOsc));
	
	// Initialize modules
	DispMux DispMux1(IntOsc, Sw1, Sw2, SegInput, En1, En2);
	SegDisp DispDecoder(SegInput, Seg);
	
	//Assign Sum LEDs (active low so invert)
	assign Sum = ~(Sw1+Sw2);
	
endmodule
	
