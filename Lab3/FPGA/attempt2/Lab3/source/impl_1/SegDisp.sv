// Roman De Santos
// rdesantos@hmc.edu
// 9/3/25
//
// This file contains the logic for a 4 bit input to hex seven segment display
// Segment is in common annode format 
// Input:  S = {In3, In2, In1, In0}    where each input is a switch
// Output: seg = {A, B, C, D, E, F, G} where each letter is a segment in the display

module SegDisp(
	input  logic [3:0] S,
	output logic [6:0] Seg
	);

	always_comb begin
		case (S)
			4'b0000: Seg = 7'b0000001; // 0
			4'b0001: Seg = 7'b1001111; // 1
			4'b0010: Seg = 7'b0010010; // 2
			4'b0011: Seg = 7'b0000110; // 3
			4'b0100: Seg = 7'b1001100; // 4
			4'b0101: Seg = 7'b0100100; // 5
			4'b0110: Seg = 7'b0100000; // 6
			4'b0111: Seg = 7'b0001111; // 7
			4'b1000: Seg = 7'b0000000; // 8
			4'b1001: Seg = 7'b0001100; // 9
			4'b1010: Seg = 7'b0001000; // A
			4'b1011: Seg = 7'b1100000; // b
			4'b1100: Seg = 7'b0110001; // C
			4'b1101: Seg = 7'b1000010; // d
			4'b1110: Seg = 7'b0110000; // E
			4'b1111: Seg = 7'b0111000; // F
			default: Seg = 7'b1111111; // All segments off (blank)
		endcase
	end
endmodule