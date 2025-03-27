`timescale 1ns / 1ps

module tb_prime_generator;

  parameter int WORD_WIDTH = 32;

  logic clk;
  logic rst;
  logic start;
  logic done;
  logic [WORD_WIDTH-1:0] P, Q;

  // Instantiate the Prime Generator
  prime_generator #(
      .WORD_WIDTH(WORD_WIDTH)
  ) uut (
      .clk(clk),
      .rst(rst),
      .start(start),
      .done(done),
      .P(P),
      .Q(Q)
  );

  // Clock Generation (100 MHz)
  always #5 clk = ~clk;

  initial begin

    $dumpfile("wave_miller_rabin.vcd");
    $dumpvars();
    // Initialize signals
    clk   = 0;
    rst   = 0;
    start = 0;

    // Reset for a few cycles
    #20;
    rst = 1;
    #10;
    rst = 0;

    // Start prime generation
    $display("Starting Prime Generation...");
    start = 1;
    #10;
    start = 0;  // Only pulse start

    // Wait for completion
    wait (done);

    //#50000;
    //#50000;

    // Display results
    $display("Prime P: %d (0x%h)", P, P);
    $display("Prime Q: %d (0x%h)", Q, Q);

    // Basic checks
    if (P == Q) begin
      $display("ERROR: P and Q should be distinct!");
    end else if (P[0] == 0 || Q[0] == 0) begin
      $display("ERROR: P and Q should be odd!");
    end else begin
      $display("Test Passed: P and Q are valid.");
    end

    // Finish simulation
    #50;
    $finish;
  end

endmodule
