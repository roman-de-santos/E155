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

module DualSevSeg(
	input  logic       Clk, Reset,
	input  logic [3:0] Sw1, Sw2,
	output logic [6:0] Seg,
	output logic       En1, En2);
	
	// Internal nets
	logic [3:0]  SegInput;
	
	// Initialize modules
	DispMux DispMux1(Clk, Reset, Sw1, Sw2, SegInput, En1, En2);
	SegDisp DispDecoder(SegInput, Seg);
	
endmodule
	
