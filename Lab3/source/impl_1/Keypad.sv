module Keypad(
    input  logic        Clk, Reset,
    input  logic [3:0]  Rows,
    output logic [3:0]  Cols,
    output logic [15:0] KeyVal
);

    logic [15:0] NextKey;
    logic        ir0, ir1, ir2, ir3;

    // This flag tracks if any key was found during the last full scan.
    logic        KeyScan;
    logic        KeyS0;

    // Debounce the row inputs
    Debounce Db1(Clk, Reset, Rows[0], ir0);
    Debounce Db2(Clk, Reset, Rows[1], ir1);
    Debounce Db3(Clk, Reset, Rows[2], ir2);
    Debounce Db4(Clk, Reset, Rows[3], ir3);

    // FSM for scanning columns
    typedef enum logic [1:0] {
        s0, s1, s2, s3
    } statetype;

    statetype State, NextState;

    // Delay counter
    logic [16:0] count; // enough bits to hold 70,000 (needs 17 bits)

    // This combinatorial signal is true if any debounced row is low
    assign KeyS0 = ~(&{ir3, ir2, ir1, ir0});

    always_ff @(posedge Clk or posedge Reset) begin
        if (Reset) begin
            State   <= s0;
            KeyVal  <= 0;
            KeyScan <= 1'b0;
            count   <= 0;
        end else begin
            if (count == 17'd70000) begin
                State   <= NextState;
                KeyVal  <= NextKey;
                count   <= 0;

                if (State == s0)
                    KeyScan <= KeyS0;
                else
                    KeyScan <= KeyScan | KeyS0;

            end else begin
                count <= count + 1;
                // Hold values until counter expires
                KeyVal  <= KeyVal;
                State   <= State;
                KeyScan <= KeyScan;
            end
        end
    end

    always_comb begin
        NextState = State;
        NextKey   = KeyVal; // Default behavior: HOLD the previous value.
        Cols      = 4'b1111; // default off

        // Only look for a new key if one isn't already locked in.
        if (KeyVal == 0) begin
            case (State)
                s0: begin
                    if      (~ir0) NextKey = 16'h8000;
                    else if (~ir1) NextKey = 16'h0080;
                    else if (~ir2) NextKey = 16'h0010;
                    else if (~ir3) NextKey = 16'h0002;
                end
                s1: begin
                    if      (~ir0) NextKey = 16'h0001;
                    else if (~ir1) NextKey = 16'h0100;
                    else if (~ir2) NextKey = 16'h0020;
                    else if (~ir3) NextKey = 16'h0004;
                end
                s2: begin
                    if      (~ir0) NextKey = 16'h4000;
                    else if (~ir1) NextKey = 16'h0200;
                    else if (~ir2) NextKey = 16'h0040;
                    else if (~ir3) NextKey = 16'h0008;
                end
                s3: begin
                    if      (~ir0) NextKey = 16'h2000;
                    else if (~ir1) NextKey = 16'h1000;
                    else if (~ir2) NextKey = 16'h0800;
                    else if (~ir3) NextKey = 16'h0400;
                end
            endcase
        end

        case (State)
            s0: begin Cols = 4'b1110; NextState = s1; end
            s1: begin Cols = 4'b1101; NextState = s2; end
            s2: begin Cols = 4'b1011; NextState = s3; end
            s3: begin Cols = 4'b0111; NextState = s0; end
        endcase

        // Clear the output only when a full scan has completed with no keys pressed.
        if (State == s3 && !KeyScan)
            NextKey = 0;
    end

endmodule
