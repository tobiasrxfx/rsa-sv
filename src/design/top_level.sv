`timescale 1ns / 1ps

module top_level #(
    parameter int WORD_WIDTH = 32
) (
    input logic clk,
    input logic rst,
    input logic start,

    output logic done,

    input logic [1:0] mode,  // 00= nothing - 01=key ge; 10= encryption; 11= decryption;
    input logic [WORD_WIDTH/2-1:0] seed,
    input logic [WORD_WIDTH-1:0] message_i,
    input logic [WORD_WIDTH-1:0] e_i,
    input logic [WORD_WIDTH-1:0] d_i,
    input logic [WORD_WIDTH-1:0] N_i,

    output logic [WORD_WIDTH-1:0] message_o,
    output logic [WORD_WIDTH-1:0] e_o,
    output logic [WORD_WIDTH-1:0] d_o,
    output logic [WORD_WIDTH-1:0] N_o
);

  typedef enum logic [2:0] {
    INIT,
    PREP_KEY_GEN,
    KEY_GEN,
    PREP_EXP,
    EXP,
    DONE
  } state_t;

  state_t state, next_state;
  logic kg_rst, kg_start, kg_done;
  logic me_rst, me_start, me_done;
  logic [WORD_WIDTH-1:0] mux_e;
  logic [$clog2(WORD_WIDTH)-1:0] mux_t;  // Length of exponent of exponentiation (mux_e).
  logic [WORD_WIDTH:0] R;

  // Mux for choosing the exponent
  // If mode = 2'b11 then mux = d_i; If mode 2'b10 then mux = e_i; otherwise mux = 4'hXXXX;
  assign mux_e = (mode == 2'b10) ? e_i : (mode == 2'b11) ? d_i : {WORD_WIDTH{1'bx}};

  // Mux for choosing in which index is the MSB of the exponent
  // If mode = 2'b11 then mux_t = len(d_i); If mode 2'b10 then mux_t = len(e_i) = 17; otherwise mux = 4'h0000;
  assign mux_t = (mode == 2'b10) ? 17 : (mode == 2'b11) ? 31 : {$clog2(WORD_WIDTH) {1'bx}};

  assign R = 2 ** WORD_WIDTH;

  key_generator #(
      .WORD_WIDTH(WORD_WIDTH)
  ) kg (
      .clk(clk),
      .rst(kg_rst),
      .start(kg_start),
      .done(kg_done),
      .seed(seed),
      .N(N_o),
      .d(d_o),
      .e(e_o)
  );

  montgomery_exp #(
      .WORD_WIDTH(WORD_WIDTH)
  ) mont_exp (
      .enable(me_start),
      .clk(clk),
      .reset(me_rst),
      .done(me_done),
      .m(N_i),
      .x(message_i),
      .e(mux_e),
      .t(mux_t),  // index of the MSB
      .R(R),
      .exp_result(message_o)
  );

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      state <= INIT;
      done  <= 0;
    end else begin
      state <= next_state;
      if (state == DONE) begin
        done <= 1;
      end else begin
        done <= 0;
      end
    end
  end

  always_comb begin
    case (state)
      INIT: begin
        if (start) begin
          case (mode)
            2'b00:   next_state = INIT;
            2'b01:   next_state = PREP_KEY_GEN;
            2'b10:   next_state = PREP_EXP;
            2'b11:   next_state = PREP_EXP;
            default: next_state = INIT;
          endcase
        end else begin
          kg_rst = 1'b0;
          kg_start = 1'b0;
          me_rst = 1'b0;
          me_start = 1'b0;
          next_state = INIT;
        end
      end

      PREP_KEY_GEN: begin
        kg_rst = 1'b1;
        next_state = KEY_GEN;
      end

      KEY_GEN: begin
        kg_rst   = 1'b0;
        kg_start = 1'b1;
        if (kg_done) begin
          kg_start   = 1'b0;
          next_state = DONE;
        end else begin
          next_state = KEY_GEN;
        end
      end

      PREP_EXP: begin
        me_rst = 1'b1;
        next_state = EXP;
      end

      EXP: begin
        me_rst   = 1'b0;
        me_start = 1'b1;
        if (me_done) begin
          me_start   = 1'b0;
          next_state = DONE;
        end else begin
          next_state = EXP;
        end
      end

      DONE: begin
        next_state = INIT;
      end
      default: next_state = INIT;
    endcase
  end

endmodule
