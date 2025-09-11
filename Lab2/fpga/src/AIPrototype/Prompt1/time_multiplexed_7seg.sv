//
// Module: time_multiplexed_7seg
// Description: Time multiplexes a single 7-segment decoder to drive two displays.
//              It takes two 4-bit data inputs and generates a shared segment
//              output and individual anode control signals.
//
module time_multiplexed_7seg #(
    parameter CLK_FREQ_HZ    = 50_000_000, // Example: 50 MHz system clock
    parameter REFRESH_RATE_HZ = 800         // Desired refresh rate per display
) (
    // System Inputs
    input  logic        clk,
    input  logic        reset,

    // Data Inputs for the two displays
    input  logic [3:0]  data_A,
    input  logic [3:0]  data_B,

    // Outputs to the Seven Segment Displays
    output logic [6:0]  segments,   // Shared segment bus (connect to both displays)
    output logic [1:0]  anodes      // Anode control (anodes[0] for A, anodes[1] for B)
                                    // Active-low: 0 = ON, 1 = OFF
);

    // Calculate the counter limit for the desired refresh rate.
    // We switch between two displays, so the toggle frequency must be 2x the refresh rate.
    localparam COUNTER_MAX = (CLK_FREQ_HZ / (REFRESH_RATE_HZ * 2)) - 1;
    localparam COUNTER_WIDTH = $clog2(COUNTER_MAX + 1);

    // Internal signals
    logic [COUNTER_WIDTH-1:0] refresh_counter;
    logic                     display_sel; // 0 for Display A, 1 for Display B
    logic [3:0]               decoder_in;
    
    // Instantiate the single decoder
    seven_seg_decoder decoder_inst (
        .bcd_in   (decoder_in),
        .segments (segments)      // The output of the decoder directly drives the segment bus
    );

    // -- Logic --

    // 1. Refresh counter to create the multiplexing clock
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            refresh_counter <= '0;
        end else if (refresh_counter == COUNTER_MAX) begin
            refresh_counter <= '0;
        end else begin
            refresh_counter <= refresh_counter + 1;
        end
    end

    // 2. Display select logic: toggle which display is active
    //    Toggles every time the refresh counter wraps around.
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            display_sel <= 1'b0;
        end else if (refresh_counter == COUNTER_MAX) begin
            display_sel <= ~display_sel;
        end
    end

    // 3. Multiplexer: Selects the data input and anode based on display_sel
    always_comb begin
        if (display_sel == 1'b0) begin
            // Select Display A
            decoder_in = data_A;
            anodes     = 2'b10; // Anode A is ON (0), Anode B is OFF (1)
        end else begin
            // Select Display B
            decoder_in = data_B;
            anodes     = 2'b01; // Anode A is OFF (1), Anode B is ON (0)
        end
    end

endmodule