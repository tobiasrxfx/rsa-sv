`timescale 1ns / 1ps


module miller_rabin #(
    parameter int WORD_WIDTH = 32
) (
    input  logic clk,
    input  logic rst,
    input  logic enable,
    output logic done,

    input logic [WORD_WIDTH-1:0] n,
    input logic [5:0] t, // Change name because there is the same name used in montgomery exponentiation.

    output logic is_prime
);

  // hold the r and s in the expression n-1 = 2^s * r
  logic [WORD_WIDTH-1:0] r, next_r;
  logic [10:0] s, next_s;  //  can hold until 1024
  logic [10:0] j, next_j;
  logic [5:0] i, next_i;  // can hold untill 63 (enogh since a good t ~= 40)
  logic enable_exp, reset_exp, done_exp;
  logic [WORD_WIDTH-1:0] exp_result, arg_x, arg_e;
  logic [WORD_WIDTH:0] R;
  logic [4:0] arg_t;

  montgomery_exp #(
      .WORD_WIDTH(WORD_WIDTH)
  ) unit_exp (
      .enable(enable_exp),
      .clk(clk),
      .reset(reset_exp),
      .done(done_exp),
      .m(n),
      .x(arg_x),
      .e(arg_e),
      .t(arg_t),
      .R(R),  // Correct width for R
      .exp_result(exp_result)
  );

  typedef enum logic [3:0] {
    INIT,
    FIND_R_S,
    PREP_STEP_2_2,
    STEP_2_2,
    PREP_STEP_2_3,
    STEP_2_3,
    DONE
  } state_t;

  state_t state, next_state;

  assign R = 2 ** WORD_WIDTH;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      state <= INIT;
      s     <= 0;
      r     <= n - 1;
    end else begin
      state  <= next_state;
      next_s <= s;
      next_r <= r;

      if (state == DONE) begin
        done <= 1;
      end else begin
        done <= 1;
      end
    end
  end

  always_comb begin
    case (state)

      INIT: begin
        if (enable) begin
          next_state = FIND_R_S;

          next_i = 1;  // initialize the for loop index
          next_j = 1;  // initialize the while loop index
          next_r = n - 1;
          next_s = 0;

          reset_exp = 0;
          enable_exp = 0;
        end else begin
          next_state = INIT;
        end
      end

      FIND_R_S: begin
        if ((r & 1) == 0) begin
          next_r = r >> 1;
          next_s = s + 1;
          next_state = FIND_R_S;
        end else begin
          next_state = PREP_STEP_2_2;
        end
      end
      PREP_STEP_2_2: begin
        arg_x = 2;  // Need to be choosen randomly for each loop turn
        arg_e = r;
        arg_t = WORD_WIDTH - s - 1;  // ?????

        reset_exp = 1;
        if (i > t) begin
          next_state = DONE;
          is_prime   = 1;  // Prime
        end else begin
          next_i = i + 1;
          next_state = STEP_2_2;
        end
      end

      STEP_2_2: begin
        reset_exp  = 0;
        enable_exp = 1;
        // If exponentiation is done, go to the next state otherwise stay at the same
        if (done_exp) begin
          enable_exp = 0;
          reset_exp  = 1;
          next_state = PREP_STEP_2_3;
        end else begin
          next_state = STEP_2_2;
        end
      end

      PREP_STEP_2_3: begin
        if ((exp_result != 1) && (exp_result != n - 1)) begin
          arg_x = exp_result;
          arg_e = 2;
          arg_t = 1;

          next_state = STEP_2_3;
        end else begin
          next_state = PREP_STEP_2_2;
        end
      end

      STEP_2_3: begin
        if ((j <= s - 1) && (exp_result != n - 1)) begin
          reset_exp  = 0;
          enable_exp = 1;
          if (done_exp) begin
            reset_exp = 1;
            enable_exp = 0;
            next_j = j + 1;
            if (exp_result == 1) begin
              next_state = DONE;
              is_prime   = 0;  // Composite
            end
          end else begin
            next_state = STEP_2_3;
          end
        end else begin
          if (exp_result != n - 1) begin
            next_state = DONE;
            is_prime   = 0;  // Composite
          end else begin
            next_state = PREP_STEP_2_2;
          end
        end
      end

      DONE: begin
        next_state = INIT;
      end

      default: next_state = INIT;
    endcase

  end

endmodule
