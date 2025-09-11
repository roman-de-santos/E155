// Corrected top.sv
// This version moves all signal declarations to the top of the module body
// to fix the syntax error.

module top(
	input  logic [3:0] Sw1, Sw2,
	output logic [6:0] Seg,
	output logic       En1, En2,
	output logic [4:0] Sum
	);

	// Internal signals for multiplexing and decoding
	// All declarations are placed here at the start of the module.
	logic        IntOsc;         // High-frequency clock from internal oscillator
	logic        DivClk;         // Slow clock for multiplexing
	logic [3:0]  SegInput;       // Multiplexed 4-bit input to the decoder
	logic [22:0] counter = 0;    [cite_start]// Counter for the clock divider [cite: 8]
	
	[cite_start]// 1. Initialize clock at 6MHz [cite: 14]
	// Instantiates the high-speed oscillator primitive.
	HSOSC #(.CLKHF_DIV(2'b11)) 
	 hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(IntOsc));
	
	// 2. Clock Divider logic
	[cite_start]// Divides the 6MHz clock down to ~50Hz for a flicker-free display refresh[cite: 10].
	always_ff @(posedge IntOsc) begin
		counter <= counter + 1;
		[cite_start]if (counter >= 23'd60000) begin [cite: 11]
			DivClk  <= ~DivClk;
			[cite_start]counter <= 23'b0; [cite: 11]
		end
	end
	
	// 3. Input and Enable Multiplexing
	// Uses the slow clock (DivClk) to select which switch input to display
	[cite_start]// and which display to enable[cite: 8, 9].
	assign SegInput = DivClk ? Sw1 : Sw2;
	assign En1 = ~DivClk;
	assign En2 =  DivClk;
	
	[cite_start]// 4. Instantiate the Seven Segment Decoder [cite: 15]
	// Connects the multiplexed input to the decoder.
	SegDisp DispDecoder(
        .S(SegInput), 
        .Seg(Seg)
    );
	
	[cite_start]// 5. Assign Sum LEDs (active low so invert) [cite: 15]
	assign Sum = ~(Sw1 + Sw2);
	
endmodule