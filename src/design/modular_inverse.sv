`timescale 1ns / 1ps

module modular_inverse #(
    parameter int WORD_WIDTH = 32
) (
    input logic [WORD_WIDTH-1:0] gcd_result,
    input logic signed [WORD_WIDTH:0] coeff_i,
    input logic [WORD_WIDTH-1:0] n,

    output logic [WORD_WIDTH-1:0] inv,
    output logic error
);

  always_comb begin
    if (gcd_result == 1) begin
      if (coeff_i > 0) begin
        inv   = coeff_i;
        error = 0;
      end else begin
        inv   = coeff_i + n;
        error = 0;
      end
    end else begin
      error = 1;
      inv   = 0;
    end
  end


endmodule
