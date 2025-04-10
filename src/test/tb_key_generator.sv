`timescale 1ns / 1ps

module tb_key_generator;

  parameter int WORD_WIDTH = 32;

  logic clk;
  logic rst;
  logic start;
  logic done;

  logic [WORD_WIDTH-1:0] N;
  logic [WORD_WIDTH-1:0] d;
  logic [WORD_WIDTH-1:0] e;
  logic [WORD_WIDTH/2-1:0] seed;

  key_generator #(
      .WORD_WIDTH(WORD_WIDTH)
  ) keygen_uut (
      .clk(clk),
      .rst(rst),
      .start(start),
      .done(done),
      .seed(seed),
      .N(N),
      .d(d),
      .e(e)
  );

  always #5 clk = ~clk;

  initial begin
    $dumpfile("wave_keygen.vcd");
    $dumpvars();

    clk   = 0;
    rst   = 0;
    start = 0;
    seed  = 16'h11AF;
    // Reset for a few cycles
    #155;
    rst = 1;
    #195;
    rst = 0;

    // Start key generation
    $display("Starting Key Generation...");
    start = 1;
    #10;
    start = 0;  // Only pulse start

    // Wait for completion
    wait (done);

    // Display results
    $display("Public key e, N: %d, %d", e, N);
    $display("Private key d: %d", d);

    #50;
    $finish;

  end

endmodule

