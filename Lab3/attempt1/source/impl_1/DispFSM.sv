module DispFSM(
    input  logic        Clk, Reset,
    input  logic [15:0] KeyVal,  // buttons
    output logic [3:0]  Sw1, Sw2
);

    // FSM states
    typedef enum logic [5:0] {
        idle, s0, s1, s2, s3, s4, s5, s6, s7, s8,
        s9, s10, s11, s12, s13, s14, s15, stop
    } statetype;

    statetype State, NextState;

    // "next" signals for outputs
    logic [3:0] Sw1_next, Sw2_next;

    // Sequential logic: update state and outputs on clock
    always_ff @(posedge Clk or posedge Reset) begin
        if (Reset) begin
            State <= idle;
            Sw1   <= 4'b0000;
            Sw2   <= 4'b0000;
        end else begin
            State <= NextState;
            Sw1   <= Sw1_next;
            Sw2   <= Sw2_next;
        end
    end

    // Combinational logic: compute next state and outputs
    always_comb begin
        // Defaults to hold values unless changed
        NextState = State;
        Sw1_next  = Sw1;
        Sw2_next  = Sw2;

        case (State)
            idle: begin //detect button press
				case (KeyVal)
					16'h0001: NextState = s0;
					16'h0002: NextState = s1;
					16'h0004: NextState = s2;
					16'h0008: NextState = s3;
					16'h0010: NextState = s4;
					16'h0020: NextState = s5;
					16'h0040: NextState = s6;
					16'h0080: NextState = s7;
					16'h0100: NextState = s8;
					16'h0200: NextState = s9;
					16'h0400: NextState = s10;
					16'h0800: NextState = s11;
					16'h1000: NextState = s12;
					16'h2000: NextState = s13;
					16'h4000: NextState = s14;
					16'h8000: NextState = s15;
					default: NextState = idle;
				endcase
            end

            s0: begin Sw1_next = Sw2; Sw2_next = 4'h0; NextState = stop; end
            s1: begin Sw1_next = Sw2; Sw2_next = 4'h1; NextState = stop; end
            s2: begin Sw1_next = Sw2; Sw2_next = 4'h2; NextState = stop; end
            s3: begin Sw1_next = Sw2; Sw2_next = 4'h3; NextState = stop; end
            s4: begin Sw1_next = Sw2; Sw2_next = 4'h4; NextState = stop; end
            s5: begin Sw1_next = Sw2; Sw2_next = 4'h5; NextState = stop; end
            s6: begin Sw1_next = Sw2; Sw2_next = 4'h6; NextState = stop; end
            s7: begin Sw1_next = Sw2; Sw2_next = 4'h7; NextState = stop; end
            s8: begin Sw1_next = Sw2; Sw2_next = 4'h8; NextState = stop; end
            s9: begin Sw1_next = Sw2; Sw2_next = 4'h9; NextState = stop; end
            s10: begin Sw1_next = Sw2; Sw2_next = 4'hA; NextState = stop; end
            s11: begin Sw1_next = Sw2; Sw2_next = 4'hB; NextState = stop; end
            s12: begin Sw1_next = Sw2; Sw2_next = 4'hC; NextState = stop; end
            s13: begin Sw1_next = Sw2; Sw2_next = 4'hD; NextState = stop; end
            s14: begin Sw1_next = Sw2; Sw2_next = 4'hE; NextState = stop; end
            s15: begin Sw1_next = Sw2; Sw2_next = 4'hF; NextState = stop; end

            stop: begin 
                if (~(|KeyVal))
                    NextState = idle;
                else
                    NextState = stop;
            end
			
			default: NextState = idle;
        endcase
    end

endmodule
