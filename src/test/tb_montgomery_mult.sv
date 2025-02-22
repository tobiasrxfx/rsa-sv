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
  logic unsigned [WORD_WIDTH-1:0] mult_result, expected_result;

  int file, r, count_valid, count_total;

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
    count_valid = 0;
    count_total = 0;
    //m = 72639;
    //x = 5792;
    //y = 12;
    //R = 33'h100000000;  // R = 2^WORD_WIDTH (WORD_WIDTH = 32, so R = 2^32)

    // Open test vector file
    file = $fopen("test/py-scripts/montgomery_test_vectors.txt", "r");
    if (file == 0) begin
      $display("Error opening test vector file!");
      $finish;
    end

    while (!$feof(
        file
    )) begin

      r = $fscanf(file, "%d %d %d %d\n", x, y, m, expected_result);
      //if (r != 4) continue;  // Skip lines that do not have enough values

      // Apply reset
      reset = 1;
      #10 reset = 0;  // Deassert reset after 10 time units

      // Test case 1: Enable the module
      enable = 1;
      #10 enable = 0;  // Disable after 10 time units

      // Wait for completion
      wait (done);
      // Check the result
      if (mult_result !== expected_result) begin
        $display("Test FAILED: x=%d, y=%d, m=%d, result=%d, expected=%d", x, y, m, mult_result,
                 expected_result);
      end else begin
        count_valid++;
      end
      count_total++;
    end

    $display("Test PASSED: %d out of %d", count_valid, count_total);
    $display("--- End of Tests ---");

    $finish;
  end

endmodule
