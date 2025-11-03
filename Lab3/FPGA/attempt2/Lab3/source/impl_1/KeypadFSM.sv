module KeypadFSM (
    input  logic       Clk,
    input  logic       Reset,
    input  logic [3:0] Rows,
    output logic [3:0] Cols,
    output logic [3:0] Sw1,
    output logic [3:0] Sw2,
	output logic       debug //remove debug
);

    // FSM for scanning columns
    typedef enum logic [2:0] {
        s0, s1, s2, s3, s4, s5, s6, s7
    } statetype;

    statetype State, NextState;

    // Delay counter for debouncing
    logic [17:0] count, next_count;

    // FSM Sw logic
    logic [3:0] NextSw1, NextSw2;
    logic [3:0] NextCols;

    // Sequential block
    always_ff @(posedge Clk or posedge Reset) begin
        if (Reset) begin
            State     <= s0;
            Sw1       <= 4'd0;
            Sw2       <= 4'd0;
            Cols      <= 4'b1000; //inv 
            count     <= 18'd0;
        end else begin
            State     <= NextState;
            Sw1       <= NextSw1;
            Sw2       <= NextSw2;
            Cols      <= NextCols;
            count     <= next_count;
        end
    end

    // Combinational logic
    always_comb begin
        // Default "hold" assignments
        NextState  = State;
        NextSw1    = Sw1;
        NextSw2    = Sw2;
        NextCols   = Cols;
        next_count = count;
		
		debug <= (State == s7);

        case (State)
			s0: begin
				next_count = 0;
				if (|Rows) begin       // Key pressed
					NextState = s4;
					NextCols   = 4'b1000; // inv
				end else begin
					NextState = s1;
					NextCols   = 4'b0100; // inv
				end
			end

			s1: begin
				
				next_count = 0;
				if (|Rows) begin
					NextState = s4;
					NextCols   = 4'b0100; //inv
				end else begin
					NextState = s2;
					NextCols   = 4'b0010; // inv
				end
			end

			s2: begin
				next_count = 0;
				if (|Rows) begin
					NextState = s4;
					NextCols   = 4'b0010; // inv
				end else begin
					NextState = s3;
					NextCols   = 4'b0001; //inv
				end
			end

			s3: begin
				next_count = 0;
				if (|Rows) begin
					NextState = s4;
					NextCols   = 4'b0001;
				end else begin
					NextState = s0;
					NextCols   = 4'b1000;
				end
			end

            s4: begin
                // Debounce state
                if (count[7] & (|Rows)) begin // Button pressed
                    next_count = 0;
                    NextState  = s5;
                end else if (count[7] & ~(|Rows)) begin // Button released
                    next_count = 0;
                    NextState  = s0;
                end else begin
                    next_count = count + 1;
                    NextState  = s4;
                end
            end

            s5: begin
                NextSw2   = Sw1; // Shift previous Sw2 to Sw1
                NextState  = s6;

                // Decode key based on Row/Col
				// Decode key based on Row/Col (active-low: 0 means selected)
				casex ({Rows, Cols})
						// Row 0 (0001), Col 3 (1000)
						8'b0001_1000: NextSw1 = 4'hA;
						// Row 0 (0001), Col 2 (0100)
						8'b0001_0100: NextSw1 = 4'h3;
						// Row 0 (0001), Col 1 (0010)
						8'b0001_0010: NextSw1 = 4'h2;
						// Row 0 (0001), Col 0 (0001)
						8'b0001_0001: NextSw1 = 4'h1;

						// Row 1 (0010), Col 3 (1000)
						8'b001x_1000: NextSw1 = 4'hB;
						// Row 1 (0010), Col 2 (0100)
						8'b001x_0100: NextSw1 = 4'h6;
						// Row 1 (0010), Col 1 (0010)
						8'b001x_0010: NextSw1 = 4'h5;
						// Row 1 (0010), Col 0 (0001)
						8'b001x_0001: NextSw1 = 4'h4;

						// Row 2 (0100), Col 3 (1000)
						8'b01xx_1000: NextSw1 = 4'hC;
						// Row 2 (0100), Col 2 (0100)
						8'b01xx_0100: NextSw1 = 4'h9;
						// Row 2 (0100), Col 1 (0010)
						8'b01xx_0010: NextSw1 = 4'h8;
						// Row 2 (0100), Col 0 (0001)
						8'b01xx_0001: NextSw1 = 4'h7;

						// Row 3 (1000), Col 3 (1000)
						8'b1xxx_1000: NextSw1 = 4'hD;
						// Row 3 (1000), Col 2 (0100)
						8'b1xxx_0100: NextSw1 = 4'hF;
						// Row 3 (1000), Col 1 (0010)
						8'b1xxx_0010: NextSw1 = 4'h0;
						// Row 3 (1000), Col 0 (0001)
						8'b1xxx_0001: NextSw1 = 4'hE;

						default: NextSw1 = 4'h0;
					endcase
            end

            s6: begin // Wait for button release
                if (|Rows)
                    NextState = s6;
                else
                    NextState = s7;
            end

            s7: begin // Final debounce release
                if (count[7] & (|Rows)) begin   //UPDATE COUNT
                    next_count = 0;
                    NextState  = s6;
                end else if (count[7] & ~(|Rows)) begin
                    next_count = 0;
                    NextState  = s0;
                end else begin
                    next_count = count + 1;
                    NextState  = s7;
                end
            end

            default: begin
                NextState  = s0;
                NextSw1    = 0;
                NextSw2    = 0;
                NextCols   = 0;
                next_count = 0;
            end
        endcase
    end

endmodule
