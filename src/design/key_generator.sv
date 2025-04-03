`timescale 1ns / 1ps

module key_generator #(
    parameter int WORD_WIDTH = 32
) (
    input  logic clk,
    input  logic rst,
    input  logic start,
    output logic done,

    output logic [WORD_WIDTH-1:0] N,
    output logic [WORD_WIDTH-1:0] d,
    output logic [WORD_WIDTH-1:0] e
);

  typedef enum logic [2:0] {
    INIT,
    PRIME_GEN,
    MULT,
    INVERSE,
    DONE
  } state_t;

  state_t state, next_state;
  logic pg_rst, pg_start, pg_done;
  logic [WORD_WIDTH/2-1:0] P, Q, P_reg, Q_reg;
  logic [WORD_WIDTH-1:0] phi;
  logic [WORD_WIDTH-1:0] e_reg = 65537;

  logic gcd_rst, gcd_enable, gcd_done;
  logic signed [WORD_WIDTH:0] coeff_i;
  logic [WORD_WIDTH-1:0] gcd_result;

  logic [WORD_WIDTH-1:0] minv_result;
  logic minv_error;

  prime_generator #(
      .WORD_WIDTH(WORD_WIDTH)
  ) pg (
      .clk(clk),
      .rst(pg_rst),
      .start(pg_start),
      .done(pg_done),
      .P(P),
      .Q(Q)
  );

  extended_binary_gcd #(
      .WORD_WIDTH(WORD_WIDTH)
  ) gcd (
      .clk(clk),
      .reset(gcd_rst),
      .enable(gcd_enable),
      .x(e_reg),
      .y(phi),
      .done(gcd_done),
      .gcd_result(gcd_result),
      .coeff_i(coeff_i),
      .coeff_j()
  );

  modular_inverse #(
      .WORD_WIDTH(WORD_WIDTH)
  ) minv (
      .gcd_result(gcd_result),
      .coeff_i(coeff_i),
      .n(phi),
      .inv(minv_result),
      .error(minv_error)
  );

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      state <= INIT;
    end else begin
      state <= next_state;
      if (state == DONE) begin
        done <= 1;
      end else begin
        done <= 0;
      end
    end
  end

  assign e = e_reg;

  always_comb begin
    case (state)
      INIT: begin
        if (start) begin
          next_state = PRIME_GEN;
          pg_rst = 1;
        end else begin
          next_state = INIT;
          pg_rst = 0;
          pg_start = 0;
          gcd_rst = 0;
          gcd_enable = 0;
        end
      end

      PRIME_GEN: begin
        pg_rst   = 0;
        pg_start = 1;
        if (pg_done) begin
          P_reg = P;
          Q_reg = Q;
          pg_start = 0;
          next_state = MULT;
        end else begin
          next_state = PRIME_GEN;
        end
      end

      MULT: begin
        N = P_reg * Q_reg;
        phi = (P_reg - 1) * (Q_reg - 1);
        gcd_rst = 1;
        next_state = INVERSE;
      end

      INVERSE: begin  // No error checking yet !!
        gcd_rst = 0;
        gcd_enable = 1;
        if (gcd_done) begin
          gcd_enable = 0;
          d = minv_result;
          next_state = DONE;
        end else begin
          next_state = INVERSE;
        end
      end

      DONE: begin
        next_state = INIT;
      end

      default: next_state = INIT;
    endcase
  end

endmodule
