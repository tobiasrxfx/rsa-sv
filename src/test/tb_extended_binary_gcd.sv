`timescale 1ns / 1ps

module tb_extended_binary_gcd;

  parameter int WORD_WIDTH = 32;

  // Testbench signals
  logic clk;
  logic reset;
  logic enable;
  logic [WORD_WIDTH-1:0] x;
  logic [WORD_WIDTH-1:0] y;
  logic done;
  logic [WORD_WIDTH-1:0] gcd_result;
  logic signed [WORD_WIDTH-1:0] coeff_i;
  logic signed [WORD_WIDTH-1:0] coeff_j;

  // Instantiate the design under test (DUT)
  extended_binary_gcd #(
      .WORD_WIDTH(WORD_WIDTH)
  ) dut (
      .enable(enable),
      .clk(clk),
      .reset(reset),
      .x(x),
      .y(y),
      .done(done),
      .gcd_result(gcd_result),
      .coeff_i(coeff_i),
      .coeff_j(coeff_j)
  );

  // Clock generation
  always #5 clk = ~clk;  // 10 ns clock period

  initial begin
    $display("Starting simulation...");

    // Initialize signals
    clk = 0;
    reset = 0;
    enable = 0;
    x = 0;
    y = 0;

    // Apply reset
    #10 reset = 1;
    #10 reset = 0;

    // Test case 1
    enable = 1;
    x = 693;  // Example values
    y = 609;
    $display("Time: %0t | Test Case 1 | x: %0d, y: %0d", $time, x, y);

    // Wait for computation to complete
    wait (done);
    $display("Time: %0t | GCD(%0d,%0d) = %0d. Bézout's coeffs: %0d,%0d", $time, x, y, gcd_result,
             coeff_i, coeff_j);


    $finish;
  end

endmodule
