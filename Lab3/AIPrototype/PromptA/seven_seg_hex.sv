/*
 * Module: seven_seg_hex
 *
 * Combinational decoder for a 4-bit hex value to 7-segment display.
 * Assumes a common-anode display (active-low segments).
 *
 * Segments are ordered: [g, f, e, d, c, b, a]
 */
module seven_seg_hex (
  input  logic [3:0] hex_in,
  output logic [6:0] segments_out
);

  // Default to all segments off (7'b1111111)
  localparam SEG_OFF = 7'h7F;

  always_comb begin
    case (hex_in)
      //           gfedcba
      4'h0: segments_out = 7'b1000000; // 0
      4'h1: segments_out = 7'b1111001; // 1
      4'h2: segments_out = 7'b0100100; // 2
      4'h3: segments_out = 7'b0110000; // 3
      4'h4: segments_out = 7'b0011001; // 4
      4'h5: segments_out = 7'b0010010; // 5
      4'h6: segments_out = 7'b0000010; // 6
      4'h7: segments_out = 7'b1111000; // 7
      4'h8: segments_out = 7'b0000000; // 8
      4'h9: segments_out = 7'b0010000; // 9
      4'hA: segments_out = 7'b0001000; // A
      4'hB: segments_out = 7'b0000011; // b
      4'hC: segments_out = 7'b1000110; // C
      4'hD: segments_out = 7'b0100001; // d
      4'hE: segments_out = 7'b0000110; // E
      4'hF: segments_out = 7'b0001110; // F
      default: segments_out = SEG_OFF;
    endcase
  end

endmodule
