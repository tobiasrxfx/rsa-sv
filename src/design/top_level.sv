module top_level #(
    parameter int WORD_WIDTH = 32
) (
    input clk,
    input rst,
    input enable,

    output done,

    input [1:0] mode,
    input [WORD_WIDTH-1:0] message_i,
    input [WORD_WIDTH-1:0] e_i,
    input [WORD_WIDTH-1:0] d_i,
    input [WORD_WIDTH-1:0] N_i,

    output [WORD_WIDTH-1:0] message_o,
    output [WORD_WIDTH-1:0] e_o,
    output [WORD_WIDTH-1:0] d_o,
    output [WORD_WIDTH-1:0] N_o

);

endmodule
