module Sync(
	input  logic       Clk, Reset,
	input  logic [3:0] Rows,
	output logic [3:0] dRows);
	
	logic [3:0] Sync0;
	
	
	always @(posedge Clk) begin
		if (Reset) begin
			dRows = 0;
			Sync0 = 0;
		end else begin
			Sync0 = Rows;
			dRows = Sync0;
		end
			
	end
	
endmodule