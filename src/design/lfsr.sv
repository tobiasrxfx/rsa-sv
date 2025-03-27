// This method of generating pseudo-random integers is not secure.
// LFSR (Linear Feedback Shift Register).

`timescale 1ns / 1ps


module lfsr #(
    parameter int WORD_WIDTH = 32
) (
    input logic clk,
    input logic rst,
    output logic [WORD_WIDTH-1:0] rand_out
);

  // Internal register holding the state
  logic [WORD_WIDTH-1:0] lfsr;

  // Feedback taps for 512-bit. If the word bit changes it need to be changed too.
  // Source for this taps: https://datacipy.elektroniche.cz/lfsr_table.pdf
  wire feedback = lfsr[31] ^ lfsr[29] ^ lfsr[25] ^ lfsr[24];

  // Update logic for LFSR
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      // Init with all bits set
      lfsr <= 32'hA5A5_5A5A;
    end else begin
      // Every clock cycle the output is shifted to the left
      lfsr <= {lfsr[WORD_WIDTH-2:0], feedback};
    end
  end

  // Output the current LFSR state
  assign rand_out = lfsr;

endmodule
