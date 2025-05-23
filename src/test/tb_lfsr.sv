`timescale 1ns / 1ps

module tb_lfsr;

  // Parameters
  localparam int WORD_WIDTH = 32;

  logic rst, clk;
  logic [WORD_WIDTH/2-1:0] rand_out;
  logic [WORD_WIDTH/2-1:0] seed;

  lfsr #(
      .WORD_WIDTH(WORD_WIDTH)
  ) dut (
      .clk(clk),
      .rst(rst),
      .seed(seed),
      .rand_out(rand_out)
  );

  // Clock generation
  always #5 clk = ~clk;  // Clock period = 10 time units

  initial begin

    clk  = 0;

    seed = 16'hA65A;
    #5 rst = 0;
    #5 rst = 1;
    #10 rst = 0;

    #10 $display("Output: %d", rand_out);

    #10 $display("Output: %d", rand_out);

    #100 $display("Output: %d", rand_out);

    #10 $display("Output: %d", rand_out);

    #10 $display("Output: %d", rand_out);

    #10 $display("Output: %d", rand_out);

    #10 $display("Output: %d", rand_out);

    $finish;

  end
endmodule
