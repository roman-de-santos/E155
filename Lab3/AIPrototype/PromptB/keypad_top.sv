/*
 * Module: keypad_top
 *
 * Description:
 * Top-level module for the 4x4 keypad to dual 7-segment display project.
 * - Instantiates the iCE40 UP5K 12MHz internal oscillator.
 * - Instantiates the 'keypad_scanner' to scan the keypad.
 * - Instantiates the 'key_registrar' to debounce and one-shot key presses.
 * - Implements a 2-position shift register for the last two hex keys.
 * - Updates the display registers *only* on a new key press.
 * - Drives a multiplexed dual-digit 7-segment display.
 * - Assumes a common-anode display (an_sel_out is active-low).
 *
 * Ports:
 * - rst_n:        Active-low asynchronous reset (e.g., from a button).
 * - keypad_row:   [3:0] Active-low row inputs from the keypad.
 * - keypad_col:   [3:0] Active-low column outputs to the keypad.
 * - seg_out:      [6:0] Active-low 7-segment outputs (a-g).
 * - an_sel_out:   [1:0] Active-low anode selects for the two digits.
 * (an_sel_out[0] = Digit 0 (older), an_sel_out[1] = Digit 1 (newer))
 */
module keypad_top (
    input  logic       rst_n,
    input  logic [3:0] keypad_row,

    output logic [3:0] keypad_col,
    output logic [6:0] seg_out,
    output logic [1:0] an_sel_out
);

    // --- System Parameters ---
    localparam int ROOT_CLK_FREQ_HZ    = 12_000_000; // 12 MHz
    localparam int DEBOUNCE_MS         = 5;          // 5 ms
    localparam int COL_SCAN_FREQ_HZ    = 4000;       // 4 kHz (1ms full scan)
    localparam int MUX_TOGGLE_FREQ_HZ  = 400;        // 400 Hz toggle rate (200Hz full refresh)


    // --- Internal Clock ---
    logic clk;

    // Instantiate iCE40 12MHz internal high-frequency oscillator
    SB_HFOSC #(
        .CLKHF_DIV("0b10") // 0b10 = 12 MHz
    ) osc_inst (
        .CLKHFPU(1'b1), // Power up
        .CLKHFEN(1'b1), // Enable
        .CLKHF(clk)
    );


    // --- Wires for Module Connections ---
    logic       w_key_is_pressed;
    logic [3:0] w_key_code_from_scanner;
    logic       w_new_key_pulse;
    logic [3:0] w_registered_key_code;


    // --- Module Instantiation ---

    // 1. Keypad Scanner
    keypad_scanner #(
        .CLK_FREQ_HZ(ROOT_CLK_FREQ_HZ),
        .COL_SCAN_FREQ_HZ(COL_SCAN_FREQ_HZ)
    ) scanner_inst (
        .clk(clk),
        .rst_n(rst_n),
        .row_in(keypad_row),
        .col_out(keypad_col),
        .key_is_pressed(w_key_is_pressed),
        .key_code(w_key_code_from_scanner)
    );

    // 2. Key Press Registrar (One-Shot)
    key_registrar #(
        .CLK_FREQ_HZ(ROOT_CLK_FREQ_HZ),
        .DEBOUNCE_MS(DEBOUNCE_MS)
    ) registrar_inst (
        .clk(clk),
        .rst_n(rst_n),
        .key_pressed(w_key_is_pressed),
        .key_code(w_key_code_from_scanner),
        .new_key_pulse(w_new_key_pulse),
        .registered_key_code(w_registered_key_code)
    );


    // --- Key Press Shift Register ---
    // Stores the last two valid key presses.
    // 4'hF is used as a 'blank' code.
    logic [3:0] digit_old_reg, digit_new_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            digit_old_reg <= 4'hF; // Blank
            digit_new_reg <= 4'hF; // Blank
        end else if (w_new_key_pulse) begin
            // Shift values on new key press
            digit_old_reg <= digit_new_reg;
            digit_new_reg <= w_registered_key_code;
        end
    end


    // --- 7-Segment Display Multiplexer ---

    // Divider to create the mux toggle clock
    localparam int MUX_DIVIDER_COUNT = ROOT_CLK_FREQ_HZ / MUX_TOGGLE_FREQ_HZ;
    localparam int MUX_DIVIDER_WIDTH = $clog2(MUX_DIVIDER_COUNT);

    logic [MUX_DIVIDER_WIDTH-1:0] mux_divider_counter_reg;
    logic                         mux_sel_reg; // 0=Digit0 (old), 1=Digit1 (new)

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mux_divider_counter_reg <= '0;
            mux_sel_reg             <= 1'b0;
        end else begin
            if (mux_divider_counter_reg == MUX_DIVIDER_COUNT - 1) begin
                mux_divider_counter_reg <= '0;
                mux_sel_reg             <= ~mux_sel_reg; // Toggle digit
            end else begin
                mux_divider_counter_reg <= mux_divider_counter_reg + 1;
            end
        end
    end

    // Combinational Mux: Selects which digit's data and anode to drive
    logic [3:0] muxed_digit_data;

    always_comb begin
        if (mux_sel_reg == 1'b0) begin
            // Display older digit (Digit 0)
            muxed_digit_data = digit_old_reg;
            an_sel_out       = 2'b10; // Select Digit 0, disable Digit 1
        end else begin
            // Display newer digit (Digit 1)
            muxed_digit_data = digit_new_reg;
            an_sel_out       = 2'b01; // Select Digit 1, disable Digit 0
        end
    end


    // --- 7-Segment Decoder (Combinational) ---
    // Converts 4-bit hex code to active-low 7-segment (g,f,e,d,c,b,a)
    always_comb begin
        case (muxed_digit_data)
            //                 gfedcba
            4'h0: seg_out = 7'b1000000; // 0
            4'h1: seg_out = 7'b1111001; // 1
            4'h2: seg_out = 7'b0100100; // 2
            4'h3: seg_out = 7'b0110000; // 3
            4'h4: seg_out = 7'b0011001; // 4
            4'h5: seg_out = 7'b0010010; // 5
            4'h6: seg_out = 7'b0000010; // 6
            4'h7: seg_out = 7'b1111000; // 7
            4'h8: seg_out = 7'b0000000; // 8
            4'h9: seg_out = 7'b0010000; // 9
            4'hA: seg_out = 7'b0001000; // A
            4'hB: seg_out = 7'b0000011; // b
            4'hC: seg_out = 7'b1000110; // C
            4'hD: seg_out = 7'b0100001; // d
            4'hE: seg_out = 7'b0000110; // E
            4'hF: seg_out = 7'b0001110; // F
            default: seg_out = 7'b1111111; // Off (blank)
        endcase
    end

endmodule
