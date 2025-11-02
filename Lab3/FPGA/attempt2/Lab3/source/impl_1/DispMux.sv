// Roman De Santos
// rdesantos@hmc.edu
// 9/11/25
//
// This is the Display Mux module and it handles input switching to the two seperate
// Seven segment displays. It clock divides the input clock to 60MHz and uses that to
// set the enable bits and select the input to the seven segment decoder.
// 
// Input:  IntOsc is the oscillator to be divided
//  		Sw1, Sw2 are the two different dip switches
// Output: SegInput is the input to the seven segment decoder
//			En1, En2 are the clock dependent Enable bits

module DispMux(
	input  logic       IntOsc, Reset,
	input  logic [3:0] Sw1, Sw2,
	output logic [3:0] SegInput,
	output logic       En1, En2
);
	// Internal nets
	logic DivClk = 0;
	logic [22:0] counter = 0;

	// Choose input to SegDisp decoder
	assign SegInput = DivClk ? Sw1 : Sw2;
	
	// Assign Enable bits
	assign En1 = ~DivClk;
	assign En2 =  DivClk;
	
   // Clock Divider 6MHz to 60Hz	
	always_ff @(posedge IntOsc) begin
		if (Reset) begin
			DivClk  <= 0;
			counter <= 0;
		end else begin
		counter <= counter + 1;
		end
		
		if (counter >= 23'd60000) begin
			DivClk  <= ~DivClk;
			counter  <= 23'b0;
		end
	end
	
endmodule