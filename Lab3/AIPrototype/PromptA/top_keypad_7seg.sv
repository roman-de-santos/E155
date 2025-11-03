/*
 * Module: top_keypad_7seg
 *
 * Top-level module for the keypad scanner and dual 7-segment display.
 * - Assumes a ~20MHz input clock (clk_in)
 * - Generates a ~150 Hz scan clock for the keypad
 * - Generates a ~1 kHz multiplexing clock for the 7-segment display
 * - Stores the last two key presses
 * - Displays the older key on the left (Digit 1) and the most
 * recent key on the right (Digit 0).
 */
module top_keypad_7seg (
  input  logic clk_in,             // ~20MHz system clock
  input  logic rst_n,              // Active-low reset
  input  logic [3:0] keypad_rows_in, // 4 row inputs from keypad

  output logic [3:0] keypad_cols_out, // 4 column outputs to keypad
  output logic [1:0] anode_sel_out,   // Anode selection (active-low)
  output logic [6:0] segments_out     // Segment outputs (active-low)
);

  // --- Clock Enable Signals ---
  logic ce_scan_clk; // ~150 Hz for keypad
  logic ce_mux_clk;  // ~1 kHz for 7-seg mux

  // Generate ~150 Hz pulse (20,000,000 / 133,333)
  pulse_generator #(
    .MAX_COUNT(133_332)
  ) U_SCAN_CLK_GEN (
    .clk(clk_in),
    .rst_n(rst_n),
    .ce_pulse(ce_scan_clk)
  );

  // Generate ~1 kHz pulse (20,000,000 / 20,000)
  // This gives 500 Hz refresh rate per digit.
  pulse_generator #(
    .MAX_COUNT(19_999)
  ) U_MUX_CLK_GEN (
    .clk(clk_in),
    .rst_n(rst_n),
    .ce_pulse(ce_mux_clk)
  );


  // --- Keypad Scanner ---
  logic [3:0] new_key_value;
  logic new_key_strobe;

  keypad_scanner U_KEYPAD (
    .clk(clk_in),
    .rst_n(rst_n),
    .scan_clk_ce(ce_scan_clk),
    .rows_in(keypad_rows_in),
    .cols_out(keypad_cols_out),
    .key_out(new_key_value),
    .new_key_strobe(new_key_strobe)
  );


  // --- Key Press Storage ---
  logic [3:0] recent_key_reg; // The most recent key (Digit 0)
  logic [3:0] older_key_reg;  // The previous key (Digit 1)

  always_ff @(posedge clk_in or negedge rst_n) begin
    if (!rst_n) begin
      recent_key_reg <= 4'h0;
      older_key_reg  <= 4'h0;
    end else begin
      if (new_key_strobe) begin
        older_key_reg  <= recent_key_reg; // Shift recent to older
        recent_key_reg <= new_key_value;  // Store new key as recent
      end
    end
  end


  // --- Dual 7-Segment Multiplexer ---
  logic [1:0] anode_sel_reg; // [1]=Digit 1 (older), [0]=Digit 0 (recent)
  logic [3:0] hex_to_decode;
  logic [6:0] segments_decoded;

  // Toggle between digits on the mux clock
  always_ff @(posedge clk_in or negedge rst_n) begin
    if (!rst_n) begin
      anode_sel_reg <= 2'b10; // Start with Digit 0 (recent)
    end else begin
      if (ce_mux_clk) begin
        anode_sel_reg <= {anode_sel_reg[0], anode_sel_reg[1]}; // Rotate
      end
    end
  end

  // Combinational logic to select the correct digit and drive anodes
  always_comb begin
    if (anode_sel_reg == 2'b10) begin
      // Displaying Digit 0 (Most Recent)
      hex_to_decode = recent_key_reg;
    end else begin
      // Displaying Digit 1 (Older)
      hex_to_decode = older_key_reg;
    end
  end

  // Instantiate the decoder
  seven_seg_hex U_DECODER (
    .hex_in(hex_to_decode),
    .segments_out(segments_decoded)
  );

  // Assign final outputs
  assign anode_sel_out = anode_sel_reg;
  assign segments_out = segments_decoded;

endmodule
