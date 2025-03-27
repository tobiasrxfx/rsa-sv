`timescale 1ns / 1ps


module prime_generator #(
    parameter int WORD_WIDTH = 32
) (
    input  logic clk,
    input  logic rst,
    input  logic start,
    output logic done,

    output logic [WORD_WIDTH-1:0] P,
    output logic [WORD_WIDTH-1:0] Q
);

  logic [WORD_WIDTH-1:0] rand_num;
  logic [1:0] security_param = 1;
  logic enable_mr, done_mr, is_prime;
  logic [WORD_WIDTH-1:0] candidate;

  typedef enum logic [2:0] {
    IDLE,
    PREP_FIND_P,
    FIND_P,
    PREP_FIND_Q,
    FIND_Q,
    DONE
  } state_t;

  state_t state, next_state;

  logic rst_mr;

  // Instantiate LFSR for random number generation
  lfsr #(
      .WORD_WIDTH(WORD_WIDTH)
  ) rng (
      .clk(clk),
      .rst(rst),
      .rand_out(rand_num)
  );

  // Instantiate Miller-Rabin for primality testing
  miller_rabin #(
      .WORD_WIDTH(WORD_WIDTH)
  ) mr_test (
      .clk(clk),
      .rst(rst_mr),
      .enable(enable_mr),
      .done(done_mr),
      .n(candidate),
      .security_parameter(security_param),
      .is_prime(is_prime)
  );

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      state <= IDLE;
    end else begin
      state <= next_state;
    end
  end

  always_comb begin
    case (state)
      IDLE: begin
        if (start) begin
          next_state = PREP_FIND_P;
          P = 0;
          Q = 0;
          rst_mr = 0;
          enable_mr = 0;
        end else begin
          next_state = IDLE;
        end
      end

      PREP_FIND_P: begin
        candidate = rand_num | 1;  // Ensure it's odd
        next_state = FIND_P;
        rst_mr = 1;
      end

      FIND_P: begin
        rst_mr = 0;
        enable_mr = 1;
        if (done_mr) begin
          enable_mr = 0;
          if (is_prime) begin
            P = candidate;
            next_state = PREP_FIND_Q;
          end else begin
            next_state = PREP_FIND_P;
          end
        end else begin
          next_state = FIND_P;
        end
      end

      PREP_FIND_Q: begin
        candidate = rand_num | 1;  // Ensure it's odd
        rst_mr = 1;
        next_state = FIND_Q;
      end

      FIND_Q: begin
        rst_mr = 0;
        enable_mr = 1;
        if (done_mr) begin
          enable_mr = 0;
          if (is_prime && candidate != P) begin
            Q = candidate;
            next_state = DONE;
          end else begin
            next_state = PREP_FIND_Q;
          end
        end else begin
          next_state = FIND_Q;
        end
      end

      DONE: begin
        done = 1;
        next_state = IDLE;  // Ready for next generation
      end

      default: next_state = IDLE;
    endcase
  end
endmodule
