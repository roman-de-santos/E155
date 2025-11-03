/*
 * Module: keypad_scanner
 *
 * Description:
 * Scans a 4x4 matrix keypad by activating one column at a time (active-low)
 * and reading the row inputs (active-low).
 *
 * - Assumes a standard hex layout where key_code[3:2] is the column index
 * and key_code[1:0] is the row index.
 * - Detects the first single key press found during a scan cycle.
 * - Updates outputs once per full scan (all 4 columns) to provide a
 * stable signal.
 * - Row inputs are synchronized to the system clock.
 *
 * Parameters:
 * - CLK_FREQ_HZ:      System clock frequency in Hertz (e.g., 12_000_000).
 * - COL_SCAN_FREQ_HZ: Frequency to scan *one* column (e.g., 4000).
 * A 4kHz scan rate means 250us per column,
 * for a 1ms full keypad scan (4 * 250us).
 *
 * Inputs:
 * - clk:         System clock.
 * - rst_n:       Active-low asynchronous reset.
 * - row_in:      [3:0] Active-low row inputs from the keypad.
 *
 * Outputs:
 * - col_out:        [3:0] Active-low column outputs to the keypad.
 * - key_is_pressed: '1' if a key was detected on the last scan, '0' otherwise.
 * - key_code:       [3:0] 4-bit code of the key detected.
 */
module keypad_scanner #(
    parameter int CLK_FREQ_HZ      = 12_000_000, // Default: 12 MHz
    parameter int COL_SCAN_FREQ_HZ = 4000        // Default: 4 kHz (1ms full scan)
) (
    input  logic clk,
    input  logic rst_n,
    input  logic [3:0] row_in,

    output logic [3:0] col_out,
    output logic       key_is_pressed,
    output logic [3:V:0] key_code
);

    // --- Clock Divider for Scan Rate ---
    localparam int DIVIDER_COUNT = CLK_FREQ_HZ / COL_SCAN_FREQ_HZ;
    localparam int DIVIDER_WIDTH = $clog2(DIVIDER_COUNT);

    logic [DIVIDER_WIDTH-1:0] divider_counter_reg;
    logic                     scan_clk_enable_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            divider_counter_reg <= '0;
            scan_clk_enable_reg <= 1'b0;
        end else begin
            scan_clk_enable_reg <= 1'b0; // Default to '0', pulse for one cycle
            if (divider_counter_reg == DIVIDER_COUNT - 1) begin
                divider_counter_reg <= '0;
                scan_clk_enable_reg <= 1'b1;
            end else begin
                divider_counter_reg <= divider_counter_reg + 1;
            end
        end
    end


    // --- Row Input Synchronizer (2-flop) ---
    logic [3:0] row_in_s1, row_in_s2;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            row_in_s1 <= 4'hF; // Default to no key pressed
            row_in_s2 <= 4'hF;
        end else begin
            row_in_s1 <= row_in;
            row_in_s2 <= row_in_s1;
        end
    end


    // --- Row Decoder (Combinational) ---
    // Priority-encodes the synchronized row inputs.
    // Finds the first active (low) row.
    logic       col_has_key;
    logic [1:0] row_index;

    always_comb begin
        case (row_in_s2)
            // Row 0 pressed
            4'b1110: begin
                col_has_key = 1'b1;
                row_index   = 2'b00;
            end
            // Row 1 pressed
            4'b1101: begin
                col_has_key = 1'b1;
                row_index   = 2'b01;
            end
            // Row 2 pressed
            4'b1011: begin
                col_has_key = 1'b1;
                row_index   = 2'b10;
            end
            // Row 3 pressed
            4'b0111: begin
                col_has_key = 1'b1;
                row_index   = 2'b11;
            end
            // No key or multiple keys (which we ignore)
            default: begin
                col_has_key = 1'b0;
                row_index   = 2'b00;
            end
        endcase
    end


    // --- Scan FSM and Key Latch ---
    logic [1:0] col_index_reg;
    logic [3:0] col_out_reg;
    
    // Registers to hold the results of a full scan
    logic [3:0] scan_key_code;
    logic       scan_key_pressed;
    logic [3:0] key_code_out_reg;
    logic       key_is_pressed_out_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset scan state
            col_index_reg      <= 2'b00;
            col_out_reg        <= 4'b1110; // Start scanning Column 0
            
            // Reset current scan trackers
            scan_key_pressed   <= 1'b0;
            scan_key_code      <= 4'b0;
            
            // Reset stable outputs
            key_is_pressed_out_reg <= 1'b0;
            key_code_out_reg       <= 4'b0;
        end 
        else if (scan_clk_enable_reg) begin
            // --- This logic runs at the *end* of each column scan period ---

            // 1. Check for key press in the column we *just finished* scanning
            //    (col_has_key/row_index are from row_in_s2, which is stable)
            //    Only latch the *first* key found in a scan.
            if (col_has_key && !scan_key_pressed) begin
                scan_key_pressed <= 1'b1;
                scan_key_code    <= {col_index_reg, row_index};
            end

            // 2. Check if we are at the end of a full scan cycle
            //    (We just finished scanning Col 3)
            if (col_index_reg == 2'b11) begin
                // Latch the results from the completed scan
                key_is_pressed_out_reg <= scan_key_pressed;
                key_code_out_reg       <= scan_key_code;
                
                // Reset trackers for the *next* scan (starting with Col 0)
                scan_key_pressed <= 1'b0;
                scan_key_code    <= 4'b0;
            end

            // 3. Advance to the next column
            logic [1:0] next_col_index;
            next_col_index = col_index_reg + 1;
            col_index_reg <= next_col_index;

            // 4. Update col_out to drive the *next* column
            case (next_col_index)
                2'b00: col_out_reg <= 4'b1110; // Drive Col 0
                2'b01: col_out_reg <= 4'b1101; // Drive Col 1
                2'b10: col_out_reg <= 4'b1011; // Drive Col 2
                2'b11: col_out_reg <= 4'b0111; // Drive Col 3
            endcase
        end
    end

    // --- Assign Registered Outputs ---
    assign col_out        = col_out_reg;
    assign key_is_pressed = key_is_pressed_out_reg;
    assign key_code       = key_code_out_reg;

endmodule
