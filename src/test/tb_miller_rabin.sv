`timescale 1ns / 1ps

module tb_miller_rabin;

  parameter int WORD_WIDTH = 32;

  logic clk;
  logic rst;
  logic enable;
  logic done;
  logic [WORD_WIDTH-1:0] n;
  logic [5:0] t;
  logic is_prime;

  // Instantiate the DUT
  miller_rabin #(
      .WORD_WIDTH(WORD_WIDTH)
  ) dut (
      .clk(clk),
      .rst(rst),
      .enable(enable),
      .done(done),
      .n(n),
      .t(t),
      .is_prime(is_prime)
  );

  // Clock generation
  always #5 clk = ~clk;  // 10ns period

  initial begin
    // Initialize signals
    clk = 0;
    rst = 0;
    enable = 0;
    n = 0;
    t = 5;  // Number of iterations (security parameter)

    // // Apply reset
    // #10 rst = 1;
    // #10 rst = 0;

    // // Test case 1: Small prime number (e.g., 7)
    // n = 7;
    // enable = 1;
    // #10 enable = 0;
    // wait (done);
    // $display("Test 1: n = %d, is_prime = %b (Expected: 1)", n, is_prime);

    // // Apply reset
    // #5 rst = 1;
    // #5 rst = 0;
    // // Test case 2: Small composite number (e.g., 8)
    // #20;
    // n = 8;
    // enable = 1;
    // #10 enable = 0;
    // wait (done);
    // $display("Test 2: n = %d, is_prime = %b (Expected: 0)", n, is_prime);

    // // Apply reset
    // #5 rst = 1;
    // #5 rst = 0;

    // // Test case 3: Large prime number (e.g., 97)
    // #20;
    // n = 11;
    // enable = 1;
    // #10 enable = 0;
    // wait (done);
    // $display("Test 3: n = %d, is_prime = %b/1", n, is_prime);


    // Apply reset
    #5 rst = 1;
    #5 rst = 0;


    // Test case 4: Large composite number (e.g., 100)
    #20;
    n = 10;
    enable = 1;
    #10 enable = 0;
    wait (done);
    $display("Test 4: n = %d, is_prime = %b/0", n, is_prime);

    // Apply reset
    #5 rst = 1;
    #5 rst = 0;


    $finish;
  end

endmodule
