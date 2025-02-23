/*  This algorithm is an implementation of the Montgomery Multiplication
*   proposed by Handbook of Applied Cryptography by A. Menezes, P. van Oorschot
*   and S. Vanstone. It can be found at the 14th chapter, 14.36.
*
*   It uses almost the same variable names as algorithm 14.36 descibes.
*   The 'n' here is WORD_WIDTH, 'b' is 2.
*
*   Since 'b' is 2, and 'm' will always be odd, so gcd(m,b) = 1. Then
*   there is no need to check it. R can be precomputed as R = b^n.
*
*   The same goes to m' = -m^(-1)mod b, since 'm' is odd and 'b' is 2,
*   then m' = -1 mod 2  => m' = 1.
*/
`timescale 1ns / 1ps


/* Montgomery multiplication.
*  Computes: mult_result = x*y*R^(-1) mod m
*
*/
module montgomery_mult #(
    parameter int WORD_WIDTH = 32
) (
    // In/out control bits
    input  logic enable,
    input  logic clk,
    input  logic reset,
    output logic done,

    // Input data
    input logic unsigned [WORD_WIDTH-1:0] m,
    input logic unsigned [WORD_WIDTH-1:0] x,
    input logic unsigned [WORD_WIDTH-1:0] y,
    input logic unsigned [  WORD_WIDTH:0] R,  // R = 2^WORD_WIDTH; Can be computed inside the module

    // Output data
    output logic unsigned [WORD_WIDTH-1:0] mult_result

);

  typedef enum logic [4:0] {
    INIT = 1,
    LOOP_OP1 = 2,
    LOOP_OP2 = 4,
    CHECK = 8,
    DONE = 16
  } state_t;

  state_t state, next_state;
  // The size of A is WORD_WIDTH+1 following the book's instruction.
  // However, for inputs of size WORD_WIDTH I got around 25% errors when using randomly choseen inputs. I guess it is due A's overflow.
  // The solution I found was to increase by 1-bit the size of A.
  logic unsigned [WORD_WIDTH+1:0] A, next_A;
  logic ui, next_ui;
  logic [5:0] i, next_i;
  logic y_0, x_i, A_0;  // Intermediate variables

  // State update block
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      state <= INIT;
    end else begin
      state <= next_state;
    end
  end

  always_ff @(posedge clk) begin
    // Update variables to avoid feedback loops
    ui  <= next_ui;
    A   <= next_A;
    i   <= next_i;

    // Update intermediate variables
    y_0 <= y[0];
    x_i <= x[next_i];
    A_0 <= next_A[0];

    if (state == DONE) done <= 1;
    else done <= 0;
  end

  always_comb begin
    case (state)
      INIT: begin
        if (enable) begin
          next_A = 0;  // Step 1
          next_i = 0;
          next_state = LOOP_OP1;
          // done = 1'b0;
        end else begin
          next_state = INIT;
        end
      end
      LOOP_OP1: begin  // Corresponds to the step 2.1
        if ((y_0 == 1'b0) || (x_i == 1'b0)) begin
          next_ui = A_0;
        end else if (A_0 == 1'b0) begin
          next_ui = 1'b1;
        end else begin
          next_ui = 1'b0;
        end
        next_state = LOOP_OP2;
      end
      LOOP_OP2: begin  // Corresponds to the step 2.2
        next_A = (A + (x_i * y) + (ui * m)) >> 1;
        next_i = i + 1;  // Can I place it inside a always_ff ?
        if (next_i > WORD_WIDTH - 1) begin
          next_state = CHECK;
        end else begin
          next_state = LOOP_OP1;
        end
      end
      CHECK: begin  // Step 3 and 4
        if (A >= m) begin
          mult_result = A - m;
          next_state  = DONE;
        end else begin
          mult_result = A;
          next_state  = DONE;
        end
      end
      DONE: begin
        // done = 1'b1;
        next_state = INIT;
      end
      default: begin
        next_state = INIT;
      end
    endcase
  end

endmodule
