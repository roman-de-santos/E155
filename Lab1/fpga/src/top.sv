// Roman De Santos
// rdesantos@hmc.edu
// 9/3/25
//
// This is the Top module for Lab1
// 	This file blinks an Led at 2.4Hz, XORs S0 and S1, ANDs S2 and S3, and displays a hex number based on S[3:0]
//
// Input:   S[3:0]   = {In3, In2, In1, In0}                            where each input is a switch
// Output1: Seg[6:0] = {A_P12, B_P20, C_P45, D_P3, E_P44, F_P18, G_P9} where each letter is a segment in the display
// Output2: Led[2:0] = {Led0_P10, Led1_P21, Led2_P11}

module top(
	input  logic [3:0] S,   // Input switches
	output logic [6:0] Seg, // 7-seg output
	output logic [2:0] Led  // Led output
);
	logic [22:0] LedState = 0;
	logic IntOsc;
	logic [22:0] counter = 0;
	
   // Internal high-speed oscillator (24MHz)
   HSOSC #(.CLKHF_DIV(2'b01)) 
         hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));
  
   // Counter
   always_ff @(posedge int_osc) begin
	counter <= counter + 1;
	
	if (counter >= 23'd5000000) begin
		LedState  = ~LedState;
		counter  <= 23'b0;
	end

	end
   
	// Assign Leds values
	assign Led[2] = LedState; // 2.4Hz Led
	
	assign Led[1] = S[3] & S[2]; // AND Led
	
	assign Led[0] = S[1] ^ S[0]; // XOR Led
	
	// Create an instance of the 4bit to hex seven segment display
	SegDisp sp1(S, Seg);
	

endmodule