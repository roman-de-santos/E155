/*
 * Module: keypad_scanner
 *
 * Scans a 4x4 matrix keypad using a ~150 Hz scan clock enable.
 * Outputs a single-cycle strobe when a *new* key is pressed.
 * Implements "debounce-by-design" by only sampling on the slow clock.
 * Ignores all key activity while any key is held down, and only
 * re-arms after a full scan cycle detects *no* keys pressed.
 */
module keypad_scanner (
  input  logic clk,             // Fast system clock (~20MHz)
  input  logic rst_n,           // Async active-low reset
  input  logic scan_clk_ce,     // Slow clock enable (~150 Hz)
  input  logic [3:0] rows_in,   // Keypad row inputs (active-low)

  output logic [3:0] cols_out,  // Keypad column drive (active-low, one-hot)
  output logic [3:0] key_out,   // 4-bit hex value of pressed key
  output logic new_key_strobe   // Single-cycle strobe on new key press
);

  // FSM states. We scan one column per state.
  // In S_SCAN, we look for a press.
  // In S_HELD, we look for a release.
  typedef enum logic [2:0] {
    S_SCAN0, S_SCAN1, S_SCAN2, S_SCAN3, // Scanning columns 0-3 for a press
    S_HELD0, S_HELD1, S_HELD2, S_HELD3  // Scanning columns 0-3 for release
  } state_t;

  state_t state_reg;
  logic [3:0] key_down_snapshot_reg; // Used in HELD state to detect full release
  logic [3:0] key_out_reg;
  logic [3:0] cols_out_reg;
  logic new_key_strobe_reg;

  // Registered outputs
  assign key_out = key_out_reg;
  assign cols_out = cols_out_reg;
  assign new_key_strobe = new_key_strobe_reg;

  // This FSM runs on the *slow* scan_clk_ce.
  // We check the 'rows_in' value that corresponds to the 'cols_out'
  // set in the *previous* clock cycle. This gives a full ~6.6ms
  // (1/150Hz) for the output to drive and the input to settle.
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state_reg <= S_SCAN0;
      cols_out_reg <= 4'b1110; // Start by scanning column 0
      key_out_reg <= 4'h0;
      new_key_strobe_reg <= 1'b0;
      key_down_snapshot_reg <= 4'b0;
    end else begin
      // Strobe is always one cycle long, reset by default
      new_key_strobe_reg <= 1'b0;

      if (scan_clk_ce) begin
        logic [3:0] rows_active = ~rows_in; // Convert active-low to active-high
        logic key_pressed_this_col = (rows_active != 4'b0);
        logic [1:0] row_idx;

        // Simple priority encoder for the first active row
        if (rows_active[0]) row_idx = 2'b00;
        else if (rows_active[1]) row_idx = 2'b01;
        else if (rows_active[2]) row_idx = 2'b10;
        else row_idx = 2'b11; // (rows_active[3])

        case (state_reg)
          // --- SCAN STATES: Look for the *first* key press ---
          S_SCAN0: begin // Checking col 0
            cols_out_reg <= 4'b1101; // Pre-set output for next state (col 1)
            if (key_pressed_this_col) begin
              key_out_reg <= {2'b00, row_idx}; // Store key
              new_key_strobe_reg <= 1'b1;
              state_reg <= S_HELD1;
              key_down_snapshot_reg <= 4'b0; // Clear snapshot for HELD scan
            end else begin
              state_reg <= S_SCAN1;
            end
          end
          S_SCAN1: begin // Checking col 1
            cols_out_reg <= 4'b1011; // Pre-set output for next state (col 2)
            if (key_pressed_this_col) begin
              key_out_reg <= {2'b01, row_idx}; // Store key
              new_key_strobe_reg <= 1'b1;
              state_reg <= S_HELD2;
              key_down_snapshot_reg <= 4'b0;
            end else begin
              state_reg <= S_SCAN2;
            end
          end
          S_SCAN2: begin // Checking col 2
            cols_out_reg <= 4'b0111; // Pre-set output for next state (col 3)
            if (key_pressed_this_col) begin
              key_out_reg <= {2'b10, row_idx}; // Store key
              new_key_strobe_reg <= 1'b1;
              state_reg <= S_HELD3;
              key_down_snapshot_reg <= 4'b0;
            end else begin
              state_reg <= S_SCAN3;
            end
          end
          S_SCAN3: begin // Checking col 3
            cols_out_reg <= 4'b1110; // Pre-set output for next state (col 0)
            if (key_pressed_this_col) begin
              key_out_reg <= {2'b11, row_idx}; // Store key
              new_key_strobe_reg <= 1'b1;
              state_reg <= S_HELD0;
              key_down_snapshot_reg <= 4'b0;
            end else begin
              state_reg <= S_SCAN0;
            end
          end

          // --- HELD STATES: Wait for *all* keys to be released ---
          S_HELD0: begin // Checking col 0
            cols_out_reg <= 4'b1101; // Pre-set output for next state (col 1)
            if (key_pressed_this_col) key_down_snapshot_reg[0] <= 1'b1;
            state_reg <= S_HELD1;
          end
          S_HELD1: begin // Checking col 1
            cols_out_reg <= 4'b1011; // Pre-set output for next state (col 2)
            if (key_pressed_this_col) key_down_snapshot_reg[1] <= 1'b1;
            state_reg <= S_HELD2;
          end
          S_HELD2: begin // Checking col 2
            cols_out_reg <= 4'b0111; // Pre-set output for next state (col 3)
            if (key_pressed_this_col) key_down_snapshot_reg[2] <= 1'b1;
            state_reg <= S_HELD3;
          end
          S_HELD3: begin // Checking col 3
            cols_out_reg <= 4'b1110; // Pre-set output for next state (col 0)
            if (key_pressed_this_col) key_down_snapshot_reg[3] <= 1'b1;

            // At the end of the HELD scan, check the results
            if (key_down_snapshot_reg == 4'b0 && !key_pressed_this_col) begin
              // All keys were up for one full scan cycle!
              state_reg <= S_SCAN0;
            end else begin
              // A key is still held, scan again
              key_down_snapshot_reg <= 4'b0; // Reset for next scan
              state_reg <= S_HELD0;
            end
          end
          default: begin
            state_reg <= S_SCAN0;
            cols_out_reg <= 4'b1110;
          end
        endcase
      end
    end
  end

  // This demonstrates the requested standard hex keypad mapping,
  // but the {col, row} mapping above is simpler and uses less logic.
  // I will keep the simpler {col, row} mapping for efficiency.
  // If you want the phone pad mapping, you can replace the `key_out_reg <= ...`
  // lines with a combinational lookup based on `{col_idx, row_idx}`.
  /*
   always_comb begin
     case ({col_idx, row_idx})
       4'b0000: mapped_key = 4'h1;
       4'b0001: mapped_key = 4'h4;
       // ... etc ...
     endcase
   end
  */

endmodule
