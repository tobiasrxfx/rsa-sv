`timescale 1ns / 1ps

module montgomery_exp #(
    parameter int WORD_WIDTH = 32,
    parameter int E_WIDTH = 20
) (
    // In/out control bits
    input  logic enable,
    input  logic clk,
    input  logic reset,
    output logic done,

    // Input data
    input logic unsigned [WORD_WIDTH-1:0] m,
    input logic unsigned [WORD_WIDTH-1:0] x,
    input logic unsigned [E_WIDTH-1:0] e,
    input logic unsigned [WORD_WIDTH:0] R,  // R = 2^WORD_WIDTH; Can be computed inside the module

    // Output data
    output logic unsigned [WORD_WIDTH-1:0] exp_result

);
  // Control signals for the sub-module montgomery_mult
  logic enable_mult, reset_mult, done_mult;
  // Argument signals for Montgomery multiplication unit
  logic unsigned [WORD_WIDTH-1:0] arg1, arg2;
  logic unsigned [WORD_WIDTH-1:0] mult_result;
  logic unsigned [WORD_WIDTH-1:0] A, next_A;
  logic unsigned [WORD_WIDTH-1:0] x_tilde;
  logic unsigned [WORD_WIDTH-1:0] i, next_i;
  logic e_i;
  logic unsigned [2*WORD_WIDTH:0] R_squared;

  assign R_squared = R * R;

  montgomery_mult #(
      .WORD_WIDTH(WORD_WIDTH)
  ) unit_mult (
      .enable(enable_mult),
      .clk(clk),
      .reset(reset_mult),
      .done(done_mult),
      .m(m),
      .x(arg1),
      .y(arg2),
      .R(R),  // Correct width for R
      .mult_result(mult_result)
  );

  typedef enum logic [3:0] {
    INIT,
    PREP_STEP_1,
    STEP_1,
    PREP_STEP_2_1,
    STEP_2_1,
    PREP_STEP_2_2,
    STEP_2_2,
    PREP_FINAL,
    FINAL,
    DONE
  } state_t;

  state_t state, next_state;

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      state <= INIT;
    end else begin
      state <= next_state;
    end
  end

  // Variable uptade block
  always_ff @(posedge clk) begin
    // Update variables to avoid feedback loops
    A   <= next_A;
    i   <= next_i;

    // Update intermediate variables
    e_i <= e[next_i];

    if (state == DONE) done <= 1;
    else done <= 0;
  end

  always_comb begin
    case (state)
      INIT: begin
        if (enable) begin
          enable_mult = 0;
          reset_mult  = 0;
          next_i      = E_WIDTH;  // Set initial value
          next_state  = PREP_STEP_1;
        end else begin
          next_state = INIT;
        end
      end
      PREP_STEP_1: begin
        next_A     = R % m;
        arg1       = x;
        arg2       = R_squared % m;
        reset_mult = 1;
        next_state = STEP_1;
      end
      STEP_1: begin
        reset_mult  = 0;
        enable_mult = 1;
        if (done_mult) begin
          reset_mult  = 1;
          enable_mult = 0;
          x_tilde    = mult_result;
          next_state = PREP_STEP_2_1;
        end else begin
          next_state = STEP_1;
        end
      end
      PREP_STEP_2_1: begin
        arg1 = A;
        arg2 = A;
        next_state = STEP_2_1;
      end
      STEP_2_1: begin
        reset_mult  = 0;
        enable_mult = 1;
        if (done_mult) begin  // Place this inside an always_ff ??????
          next_A      = mult_result;
          enable_mult = 0;
          reset_mult  = 1;
          // $display("next_A: %d -- i: %d  -- Arg1: %d -- Arg2: %d", next_A, i, arg1, arg2);
          next_state  = PREP_STEP_2_2;
        end else begin
          next_state = STEP_2_1;
        end
      end
      PREP_STEP_2_2: begin
        if (e_i) begin
          arg1       = A;
          arg2       = x_tilde;
          next_state = STEP_2_2;
        end else begin
          if (i == 0) begin
            next_state = PREP_FINAL;
          end else begin
            next_state = PREP_STEP_2_1;
            next_i     = i - 1;  // Index countdown
          end
        end
      end
      STEP_2_2: begin
        reset_mult  = 0;
        enable_mult = 1;
        if (done_mult) begin
          next_A      = mult_result;
          reset_mult  = 1;
          enable_mult = 0;
          if (i == 0) begin
            next_state = PREP_FINAL;
          end else begin
            next_state = PREP_STEP_2_1;
            next_i     = i - 1;  // Index countdown
          end
        end else begin
          next_state = STEP_2_2;
        end
      end
      PREP_FINAL: begin
        arg1       = A;
        arg2       = 1;
        next_state = FINAL;
      end
      FINAL: begin
        reset_mult  = 0;
        enable_mult = 1;
        if (done_mult) begin
          exp_result  = mult_result;
          reset_mult  = 1;
          enable_mult = 0;
          next_state  = DONE;
        end else begin
          next_state = FINAL;
        end
      end
      DONE: begin
        // done = 1;
        next_state = INIT;
      end
      default: next_state = INIT;
    endcase
  end

endmodule
