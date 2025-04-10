// This method of generating pseudo-random integers is not secure.
// LFSR (Linear Feedback Shift Register).

`timescale 1ns / 1ps


module lfsr #(
    parameter int WORD_WIDTH = 32
) (
    input logic clk,
    input logic rst,
    input logic [WORD_WIDTH/2-1:0] seed,
    output logic [WORD_WIDTH/2-1:0] rand_out
);

  // Internal register holding the state
  logic [(WORD_WIDTH/2)-1:0] lfsr;

  // Feedback taps for 512-bit. If the word bit changes it need to be changed too.
  // Source for these taps: https://datacipy.elektroniche.cz/lfsr_table.pdf
  wire feedback = lfsr[14] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10];

  // Update logic for LFSR
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      lfsr <= seed;  // 16'hA65A;
    end else begin
      // Every clock cycle the output is shifted to the left
      lfsr <= {lfsr[WORD_WIDTH/2-2:0], feedback};
    end
  end

  // Output the current LFSR state
  assign rand_out = lfsr;

endmodule
