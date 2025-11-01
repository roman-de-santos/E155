module KeypadFSM (
    input  logic       Clk,
    input  logic       Reset,
    input  logic [3:0] Rows,
    output logic [3:0] Cols,
    output logic [3:0] Sw1,
    output logic [3:0] Sw2
);

    // FSM for scanning columns
    typedef enum logic [2:0] {
        s0, s1, s2, s3, s4, s5, s6, s7
    } statetype;

    statetype State, NextState;

    // Delay counter for debouncing
    logic [7:0] count, next_count;

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
            count     <= 17'd0;
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

        case (State)
			s0: begin
				next_count = 0;
				if (~(&Rows)) begin       // Key pressed
					NextState = s4;
					NextCols   = 4'b1000; // inv
				end else begin
					NextState = s1;
					NextCols   = 4'b0100; // inv
				end
			end

			s1: begin
				
				next_count = 0;
				if (~(&Rows)) begin
					NextState = s4;
					NextCols   = 4'b0100; //inv
				end else begin
					NextState = s2;
					NextCols   = 4'b0010; // inv
				end
			end

			s2: begin
				next_count = 0;
				if (~(&Rows)) begin
					NextState = s4;
					NextCols   = 4'b0010; // inv
				end else begin
					NextState = s3;
					NextCols   = 4'b0001; //inv
				end
			end

			s3: begin
				next_count = 0;
				if (~(&Rows)) begin
					NextState = s4;
					NextCols   = 4'b0001;
				end else begin
					NextState = s0;
					NextCols   = 4'b1000;
				end
			end

            s4: begin
                // Debounce state
                if (count[7] && ~(&Rows)) begin // Button pressed
                    next_count = 0;
                    NextState  = s5;
                end else if (count[7] && (&Rows)) begin // Button released
                    next_count = 0;
                    NextState  = s0;
                end else begin
                    next_count = count + 1;
                    NextState  = s4;
                end
            end

            s5: begin
                NextSw1   = Sw2; // Shift previous Sw2 to Sw1
                NextState  = s6;

                // Decode key based on Row/Col
				// Decode key based on Row/Col (active-low: 0 means selected)
				case ({~Rows, ~Cols})
					// Row 0 (0111): Keys 1, 2, 3, A
					8'b1110_1110: NextSw2 = 4'h1;
					8'b1110_1101: NextSw2 = 4'h2;
					8'b1110_1011: NextSw2 = 4'h3;
					8'b1110_0111: NextSw2 = 4'hA;

					// Row 1 (1101): Keys 4, 5, 6, B
					8'b1101_1110: NextSw2 = 4'h4;
					8'b1101_1101: NextSw2 = 4'h5;
					8'b1101_1011: NextSw2 = 4'h6;
					8'b1101_0111: NextSw2 = 4'hB;

					// Row 2 (1011): Keys 7, 8, 9, C
					8'b1011_1110: NextSw2 = 4'h7;
					8'b1011_1101: NextSw2 = 4'h8;
					8'b1011_1011: NextSw2 = 4'h9;
					8'b1011_0111: NextSw2 = 4'hC;

					// Row 3 (0111): Keys E, 0, F, D
					8'b0111_1110: NextSw2 = 4'hE;
					8'b0111_1101: NextSw2 = 4'h0;
					8'b0111_1011: NextSw2 = 4'hF;
					8'b0111_0111: NextSw2 = 4'hD;

					default: NextSw2 = 4'h0;
				endcase
            end

            s6: begin // Wait for button release
                if (~(&Rows))
                    NextState = s6;
                else
                    NextState = s7;
            end

            s7: begin // Final debounce release
                if (count[7] && ~(&Rows)) begin
                    next_count = 0;
                    NextState  = s6;
                end else if (count[7] && (&Rows)) begin
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
