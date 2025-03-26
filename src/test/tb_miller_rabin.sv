`timescale 1ns / 1ps

module tb_miller_rabin;

  parameter int WORD_WIDTH = 32;

  logic clk;
  logic rst;
  logic enable;
  logic done;
  logic [WORD_WIDTH-1:0] n;
  logic [5:0] security_parameter;
  logic is_prime;
  logic expected_result;

  int file, r, count_valid, count_total;

  // Instantiate the DUT
  miller_rabin #(
      .WORD_WIDTH(WORD_WIDTH)
  ) dut (
      .clk(clk),
      .rst(rst),
      .enable(enable),
      .done(done),
      .n(n),
      .security_parameter(security_parameter),
      .is_prime(is_prime)
  );

  // Clock generation
  always #5 clk = ~clk;  // 10ns period

  initial begin
    // $dumpfile("wave_miller_rabin.vcd");
    // $dumpvars();

    // Initialize signals
    clk = 0;
    rst = 0;
    enable = 0;
    count_valid = 0;
    count_total = 0;
    n = 0;
    security_parameter = 2;  // Number of iterations (security parameter)

    /*
    // Apply reset
    #10 rst = 1;
    #10 rst = 0;

    n = 17;
    expected_result = 1;
    enable = 1;
    #10 enable = 0;

    wait (done);

    $display("Test: n=%d, expected_result=%d, model_result=%d", n, expected_result, is_prime);

*/

    // Open test vector file
    file = $fopen("test/py-scripts/miller_rabin_test_vectors.txt", "r");
    if (file == 0) begin
      $display("Error opening test vector file!");
      $finish;
    end


    while (!$feof(
        file
    )) begin

      r   = $fscanf(file, "%d %d\n", n, expected_result);

      // Apply reset
      rst = 1;
      #10 rst = 0;  // Deassert reset after 10 time units

      // Test case 1: Enable the module
      enable = 1;
      #10 enable = 0;  // Disable after 10 time units

      // Wait for completion
      wait (done);
      // Check the result
      if (is_prime !== expected_result) begin
        $display("Test FAILED: n=%d, expected_result=%d, model_result=%d", n, expected_result,
                 is_prime);
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
