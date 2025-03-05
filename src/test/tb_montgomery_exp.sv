`timescale 1ns / 1ps

module tb_montgomery_exp;

  parameter int WORD_WIDTH = 32;
  parameter int E_WIDTH = 17;

  logic clk;
  logic reset;
  logic enable;
  logic done;

  logic unsigned [WORD_WIDTH-1:0] m;
  logic unsigned [WORD_WIDTH-1:0] x;
  logic unsigned [WORD_WIDTH-1:0] e;
  logic unsigned [WORD_WIDTH:0] R;
  logic unsigned [WORD_WIDTH-1:0] exp_result, expected_result;
  logic unsigned [4:0] t;

  int file, r, count_valid, count_total;

  montgomery_exp #(
      .WORD_WIDTH(WORD_WIDTH)
  ) dut_uu (
      .enable(enable),
      .clk(clk),
      .reset(reset),
      .done(done),
      .m(m),
      .x(x),
      .e(e),
      .t(t),
      .R(R),
      .exp_result(exp_result)
  );


  // Clock generation
  always #5 clk = ~clk;  // Clock period = 10 time units

  // Test vectors
  initial begin
    // Initialize signals
    clk = 0;
    reset = 0;
    enable = 0;
    R = 1 << WORD_WIDTH;
    count_valid = 0;
    count_total = 0;
    t = 16;

    // Open test vector file
    file = $fopen("test/py-scripts/exp_test_vectors.txt", "r");
    if (file == 0) begin
      $display("Error opening test vector file!");
      $finish;
    end

    while (!$feof(
        file
    )) begin

      r = $fscanf(file, "%d %d %d %d\n", x, e, m, expected_result);
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
      if (exp_result !== expected_result) begin
        $display("Test FAILED: x=%d, e=%d, m=%d, result=%d, expected=%d", x, e, m, exp_result,
                 expected_result);
      end else begin
        count_valid++;
      end
      count_total++;
    end

    $display("Test PASSED: %d out of %d", count_valid, count_total);
    $display("--- End of Tests ---");
    $display("%t", $time);
    $finish;
  end

endmodule

