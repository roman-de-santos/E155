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
	
	// clk divider
	logic [15:0] ce_counter;
    logic       ce_100hz;

    always_ff @(posedge IntOsc) begin
        if (~Reset) begin
            ce_counter <= 16'd0;
			ce_100hz <= 0;
        end else begin
            // Count from 0 to 499 (6MHz / 1000 = 6000 Hz)
            if (ce_counter == 16'd249) begin
                ce_counter <= 16'd0;
				ce_100hz <= ~ ce_100hz;
            end else begin
                ce_counter <= ce_counter + 1;
            end
        end
    end
 
	 
	 Sync sync1(IntOsc, ~Reset, Rows, dRows);
	 
	// Initialize display
	 DualSevSeg DSevSeg(IntOsc, ~Reset, Sw1, Sw2, Seg, En1, En2);
	 
	//Initialize keypad
	KeypadFSM keypad1(ce_100hz, ~Reset, dRows, Cols, Sw1, Sw2, debug); //remove debug after
 
endmodule