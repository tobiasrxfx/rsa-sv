`timescale 1ns / 1ps

module modular_inverse #(
    parameter int WORD_WIDTH = 32
) (
    input logic signed [WORD_WIDTH-1:0] a,
    input logic signed [WORD_WIDTH-1:0] coeff_i,
    input logic signed [WORD_WIDTH-1:0] n,

    output logic [WORD_WIDTH-1:0] inv,
    output logic error
);

  always_comb begin
    if (a == 1) begin
      if (coeff_i > 0) inv = coeff_i;
      else inv = coeff_i + n;
    end else begin
      error = 1;
      inv   = 0;
    end
  end


endmodule
