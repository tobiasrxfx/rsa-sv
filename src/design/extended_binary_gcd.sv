`timescale 1ns / 1ps

/*
Binary extended gcd algorithm
This algorithm was desgined using a FSM logic. It is inspired by
the pseudocode 14.61, described in Handbook of Applied Cryptography,
in chapter 14.

Author: Tobias Oliveira on January 10th 2025
*/

module extended_binary_gcd #(
    parameter int WORD_WIDTH = 32
) (
    input logic enable,
    input logic clk,
    input logic reset,

    input logic signed [WORD_WIDTH-1:0] x,
    input logic signed [WORD_WIDTH-1:0] y,

    output logic done,

    output logic [WORD_WIDTH-1:0] gcd_result,
    output logic [WORD_WIDTH-1:0] coeff_i,
    output logic [WORD_WIDTH-1:0] coeff_j
);

  typedef enum logic [7:0] {
    IDLE = 1,
    BOTH_EVEN_CHECK = 2,
    U_EVEN_CHECK = 4,
    V_EVEN_CHECK = 8,
    U_GREATER_CHECK = 16,
    IS_U_ZERO = 32,
    DONE = 64
  } state_t;


  state_t state, next_state;
  logic signed [WORD_WIDTH-1:0] temp_x, temp_y, temp_u, temp_v;
  logic signed [WORD_WIDTH-1:0] a, b, c, d;  // Hold the Bezout's coefficients
  logic signed [WORD_WIDTH-1:0] next_temp_x, next_temp_y, next_temp_u, next_temp_v;
  logic signed [WORD_WIDTH-1:0] next_a, next_b, next_c, next_d;  // Hold the Bezout's coefficients
  logic signed [WORD_WIDTH-1:0] g, next_g;  // Factor that counts trailing zeroes

  // Uptade the next state
  always_ff @(posedge clk or negedge reset) begin
    if (~reset) begin
      state <= IDLE;
    end else begin
      state <= next_state;
    end
  end

  always_ff @(posedge clk) begin
    if (state == IDLE) begin
      temp_x <= x;
      temp_y <= y;
      temp_u <= 0;
      temp_v <= 0;
      a <= 0;
      b <= 0;
      c <= 0;
      d <= 0;
      g <= 1;
    end else begin
      a      <= next_a;
      b      <= next_b;
      c      <= next_c;
      d      <= next_d;
      temp_u <= next_temp_u;
      temp_v <= next_temp_v;
      temp_x <= next_temp_x;
      temp_y <= next_temp_y;
      g      <= next_g;
    end
  end

  // Combinational logic for the FSM
  always_comb begin
    case (state)
      IDLE: begin
        if (enable) begin
          next_temp_x = x;
          next_temp_y = y;
          next_g = g;
          next_state = BOTH_EVEN_CHECK;
        end else begin
          next_state = IDLE;
        end
        $display("State: IDLE | temp_x: %0d, temp_y: %0d", temp_x, temp_y);
      end
      // This state represents the steps 2 and 3 from the base algorithm
      BOTH_EVEN_CHECK: begin
        $display("State: BOTH_EVEN | temp_x: %0d, temp_y: %0d", temp_x, temp_y);
        if (temp_x % 2 == 0 & temp_y % 2 == 0) begin
          next_temp_x = temp_x >> 1;
          next_temp_y = temp_y >> 1;
          next_g = g << 1;
          next_state = BOTH_EVEN_CHECK;
        end else begin
          next_temp_u = temp_x;
          next_temp_v = temp_y;
          next_a = 1;
          next_b = 0;
          next_c = 0;
          next_d = 1;
          next_state = U_EVEN_CHECK;
        end
      end
      // This state represents the step 4
      U_EVEN_CHECK: begin
        $display("State: U_EVEN | temp_u: %0d, temp_v: %0d", temp_u, temp_v);
        $display("State: U_EVEN | temp_X: %0d, temp_Y: %0d", temp_x, temp_y);
        if (temp_u % 2 == 0) begin
          next_temp_u = temp_u >> 1;
          if (a % 2 == 0 & b % 2 == 0) begin
            next_a = a / 2;
            next_b = b / 2;
          end else begin
            $display("PASSOU!");
            next_a = (a + temp_y) / 2;
            next_b = (b - temp_x) / 2;
          end
          next_state = U_EVEN_CHECK;
        end else begin
          next_state = V_EVEN_CHECK;
        end
        $display("State: U_EVEN | A: %0d, B: %0d", next_a, next_b);
      end
      // This state represents the step 5
      V_EVEN_CHECK: begin
        $display("State: V_EVEN | temp_u: %0d, temp_v: %0d", temp_u, temp_v);
        if (temp_v % 2 == 0) begin
          next_temp_v = temp_v >> 1;
          if (c % 2 == 0 & d % 2 == 0) begin
            next_c = c / 2;
            next_d = d / 2;
          end else begin
            next_c = (c + temp_y) / 2;
            next_d = (d - temp_x) / 2;
          end
          $display("State: V_EVEN | C: %0d, D: %0d", next_c, next_d);
          next_state = U_EVEN_CHECK;
        end else begin
          next_state = U_GREATER_CHECK;
        end
      end
      // This state represents the steps 6 and partly 7
      U_GREATER_CHECK: begin
        $display("State: U_GREAT | temp_u: %0d, temp_v: %0d", temp_u, temp_v);
        $display("Before --- A: %0d -- B: %0d -- C: %0d -- D: %0d", a, b, c, d);
        if (temp_u >= temp_v) begin
          next_temp_u = temp_u - temp_v;
          next_a = a - c;
          next_b = b - d;
        end else begin
          next_temp_v = temp_v - temp_u;
          next_c = c - a;
          next_d = d - b;
        end
        $display("After --- A: %0d -- B: %0d -- C: %0d -- D: %0d", a, b, c, d);
        next_state = IS_U_ZERO;
      end
      // This step is the rest of the 7th
      IS_U_ZERO: begin
        $display("State: IS_U_ZERO | temp_u: %0d, temp_v: %0d", temp_u, temp_v);
        if (temp_u == 0) begin
          next_state = DONE;
        end else begin
          next_state = U_EVEN_CHECK;
        end
      end
      DONE: begin
        coeff_i = c;
        coeff_j = d;
        gcd_result = temp_v * g;  // g will be always power of 2
        next_state = DONE;
        $display("State: DONE | GCD: %0d, g: %0d", gcd_result, g);
      end
      default: next_state = IDLE;
    endcase
  end

  // "Done" combinational logic
  /*always_comb begin
    if (state == DONE) begin
      done = 1;
    end else begin
      done = 0;
    end
  end*/

endmodule