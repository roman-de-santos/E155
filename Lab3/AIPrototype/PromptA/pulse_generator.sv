/*
 * Module: pulse_generator
 *
 * Generates a single-cycle clock enable (ce) pulse at a divided frequency.
 * A 20,000,000 Hz input clock with MAX_COUNT = 133332 gives a pulse
 * every 133,333 cycles, for a frequency of ~150 Hz.
 *
 * With MAX_COUNT = 19999, it gives a pulse every 20,000 cycles,
 * for a frequency of 1 kHz.
 */
module pulse_generator
  #(parameter MAX_COUNT = 200000) // Default ~100Hz @ 20MHz
  (
    input  logic clk,
    input  logic rst_n,
    output logic ce_pulse
  );

  // Use $clog2 to calculate the minimum number of bits for the counter
  localparam CNT_WIDTH = $clog2(MAX_COUNT + 1);
  logic [CNT_WIDTH-1:0] counter_reg;

  assign ce_pulse = (counter_reg == MAX_COUNT);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      counter_reg <= '0;
    end else begin
      if (ce_pulse) begin
        counter_reg <= '0;
      end else begin
        counter_reg <= counter_reg + 1;
      end
    end
  end

endmodule