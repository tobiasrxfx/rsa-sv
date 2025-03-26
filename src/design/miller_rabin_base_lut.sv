`timescale 1ns / 1ps

module miller_rabin_base_lut (
    input  logic [ 1:0] index,
    output logic [31:0] out
);

  always_comb begin
    case (index)
      2'b00:   out = 2;
      2'b01:   out = 3;
      2'b10:   out = 5;
      2'b11:   out = 7;
      default: out = 2;  // Default to 2
    endcase
  end

endmodule
