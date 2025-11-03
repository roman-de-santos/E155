/*
 * Module: key_registrar
 *
 * Description:
 * Implements a Finite State Machine (FSM) to register a single, debounced
 * key press from a keypad.
 *
 * - Debounces both the key press and the key release.
 * - When a new, valid key press is detected, it captures the 4-bit 'key_code'.
 * - It asserts a one-cycle 'new_key_pulse' signal corresponding to the
 * captured key.
 * - It then ignores all key activity until the key has been fully released
 * (and the release is debounced).
 *
 * Parameters:
 * - CLK_FREQ_HZ: System clock frequency in Hertz (e.g., 12_000_000 for 12MHz).
 * - DEBOUNCE_MS: Desired debounce time in milliseconds (e.g., 5).
 *
 * Inputs:
 * - clk:         System clock.
 * - rst_n:       Active-low asynchronous reset.
 * - key_pressed: '1' if the keypad scanner detects *any* key is down, '0' otherwise.
 * - key_code:    The 4-bit value of the key being pressed.
 *
 * Outputs:
 * - new_key_pulse:       A single-cycle high pulse when a new key is registered.
 * - registered_key_code: The 4-bit 'key_code' captured when 'new_key_pulse' was high.
 */
module key_registrar #(
    parameter int CLK_FREQ_HZ = 12_000_000, // Default: 12 MHz
    parameter int DEBOUNCE_MS = 5           // Default: 5 ms debounce
) (
    input  logic clk,
    input  logic rst_n,

    // Inputs from the keypad scanner
    input  logic       key_pressed,
    input  logic [3:0] key_code,

    // Registered outputs
    output logic       new_key_pulse,
    output logic [3:0] registered_key_code
);

    // Calculate debounce counter target value
    // (CLK_FREQ_HZ / 1000) gives cycles per ms.
    localparam int DEBOUNCE_CYCLES = (CLK_FREQ_HZ / 1000) * DEBOUNCE_MS;
    
    // Calculate the width needed for the counter
    // Use $clog2 to find the ceiling of log-base-2
    localparam int COUNTER_WIDTH = $clog2(DEBOUNCE_CYCLES + 1);

    // FSM state definitions
    typedef enum logic [2:0] {
        IDLE,             // Waiting for a key press
        DEBOUNCE_PRESS,   // A key is down, wait for debounce time
        CAPTURE,          // Debounce complete, capture key for one cycle
        WAIT_FOR_RELEASE, // Key is registered, wait for it to be released
        DEBOUNCE_RELEASE  // Key is up, wait for debounce time
    } state_t;

    // State registers
    state_t state_reg, state_next;

    // Debounce counter registers
    logic [COUNTER_WIDTH-1:0] counter_reg, counter_next;

    // Register for the captured key code
    logic [3:0] registered_key_code_reg, registered_key_code_next;


    // --- Registers (Sequential Logic) ---
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Asynchronous reset
            state_reg               <= IDLE;
            counter_reg             <= '0;
            registered_key_code_reg <= '0;
        end else begin
            // Synchronous update
            state_reg               <= state_next;
            counter_reg             <= counter_next;
            registered_key_code_reg <= registered_key_code_next;
        end
    end


    // --- FSM (Combinational Logic) ---
    always_comb begin
        // Default assignments to prevent latches
        state_next               = state_reg;
        counter_next             = counter_reg;
        registered_key_code_next = registered_key_code_reg;
        new_key_pulse            = 1'b0; // Pulse is '0' by default

        case (state_reg)

            IDLE: begin
                // Waiting for a key to be pressed
                if (key_pressed) begin
                    // Key press detected, start press debounce
                    state_next   = DEBOUNCE_PRESS;
                    counter_next = '0;
                end
                // else: Stay in IDLE
            end

            DEBOUNCE_PRESS: begin
                if (key_pressed) begin
                    // Key is still pressed, continue counting
                    if (counter_reg == DEBOUNCE_CYCLES - 1) begin
                        // Debounce complete, move to capture
                        state_next = CAPTURE;
                    end else begin
                        // Still debouncing
                        counter_next = counter_reg + 1;
                    end
                end else begin
                    // Key released during debounce (glitch), go back to IDLE
                    state_next = IDLE;
                end
            end

            CAPTURE: begin
                // This state lasts for exactly one clock cycle.
                // Assert the pulse and capture the current key code.
                new_key_pulse            = 1'b1;
                registered_key_code_next = key_code;
                
                // Immediately move to wait for the key to be released
                state_next = WAIT_FOR_RELEASE;
            end

            WAIT_FOR_RELEASE: begin
                // Key has been registered, wait for it to be released
                if (!key_pressed) begin
                    // Key released, start release debounce
                    state_next   = DEBOUNCE_RELEASE;
                    counter_next = '0;
                end
                // else: Key still held down, stay in this state
            end

            DEBOUNCE_RELEASE: begin
                if (!key_pressed) begin
                    // Key is still released, continue counting
                    if (counter_reg == DEBOUNCE_CYCLES - 1) begin
                        // Release debounce complete, ready for next key
                        state_next = IDLE;
                    end else begin
                        // Still debouncing release
                        counter_next = counter_reg + 1;
                    end
                end else begin
                    // Key pressed again during release debounce (glitch)
                    // Go back to waiting for a stable release
                    state_next = WAIT_FOR_RELEASE;
                end
            end

            default: begin
                // Should not happen, but reset to IDLE for safety
                state_next = IDLE;
            end

        endcase
    end

    // --- Output Assignment ---
    // Assign the registered (stable) key code to the module output
    assign registered_key_code = registered_key_code_reg;

endmodule

