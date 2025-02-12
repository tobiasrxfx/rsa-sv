`timescale 1ns / 1ps

module tb_montgomery_mult;

  // Testbench parameters
  parameter int WORD_WIDTH = 32;

  // Inputs to the DUT
  logic enable;
  logic clk;
  logic reset;
  logic unsigned [WORD_WIDTH-1:0] m;
  logic unsigned [WORD_WIDTH-1:0] x;
  logic unsigned [WORD_WIDTH-1:0] y;
  logic unsigned [WORD_WIDTH:0] R;  // R should be WORD_WIDTH+1 bits (33 bits for WORD_WIDTH = 32)

  // Outputs from the DUT
  logic done;
  logic unsigned [WORD_WIDTH-1:0] mult_result;

  // Instantiate the Device Under Test (DUT)
  montgomery_mult #(
      .WORD_WIDTH(WORD_WIDTH)
  ) dut (
      .enable(enable),
      .clk(clk),
      .reset(reset),
      .done(done),
      .m(m),
      .x(x),
      .y(y),
      .R(R),  // Correct width for R
      .mult_result(mult_result)
  );

  // Clock generation
  always #5 clk = ~clk;  // Clock period = 10 time units

  // Test vectors
  initial begin
    // Initialize signals
    clk = 0;
    reset = 0;
    enable = 0;
    m = 72639;  // Example modulus
    x = 5792;  // Example input x
    y = 12;  // Example input y
    R = 33'h100000000;  // R = 2^WORD_WIDTH (WORD_WIDTH = 32, so R = 2^32)

    // Apply reset
    reset = 1;
    #10 reset = 0;  // Deassert reset after 10 time units

    // Test case 1: Enable the module
    enable = 1;
    #10 enable = 0;  // Disable after 10 time units

    // Wait for the module to finish
    wait (done == 1'b1);

    // Check the result
    $display("Mult Result: %d", mult_result);
    $display("Done: %b", done);
    /*
        // Test case 2: Another set of inputs
        m = 32'h7F7F7F7F;
        x = 32'h1F1F1F1F;
        y = 32'h2F2F2F2F;
        R = 33'h100000000; // Same R value as before
        enable = 1;
        #10 enable = 0;  // Disable after 10 time units

        // Wait for the module to finish
        wait(done == 1'b1);

        // Check the result
        $display("Mult Result: %h", mult_result);
        $display("Done: %b", done);
        */
    // End simulation
    $finish;
  end

endmodule
