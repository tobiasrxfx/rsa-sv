`timescale 1ns / 1ps

module tb_modular_inverse;

  // Parameters
  localparam int WORD_WIDTH = 32;

  // DUT signals
  logic signed [WORD_WIDTH-1:0] a;
  logic signed [WORD_WIDTH-1:0] coeff_i;
  logic signed [WORD_WIDTH-1:0] n;
  logic [WORD_WIDTH-1:0] inv;
  logic error;

  // Instantiate the DUT
  modular_inverse #(
      .WORD_WIDTH(WORD_WIDTH)
  ) dut (
      .a(a),
      .coeff_i(coeff_i),
      .n(n),
      .inv(inv),
      .error(error)
  );

  // Test procedure
  initial begin
    // Display header
    $display("Time\ta\tcoeff_i\tn\tinv\terror");

    // Test case 1: Valid modular inverse
    a = 1;
    coeff_i = 5;
    n = 7;
    #1;
    $display("%0t\t%0d\t%0d\t%0d\t%0d\t%0d", $time, a, coeff_i, n, inv, error);

    // Test case 2: coeff_i < 0, valid modular inverse
    a = 1;
    coeff_i = -3;
    n = 7;
    #1;
    $display("%0t\t%0d\t%0d\t%0d\t%0d\t%0d", $time, a, coeff_i, n, inv, error);

    // Test case 3: a != 1, error expected
    a = 0;
    coeff_i = 5;
    n = 7;
    #1;
    $display("%0t\t%0d\t%0d\t%0d\t%0d\t%0d", $time, a, coeff_i, n, inv, error);

    // Test case 4: a != 1, another error case
    a = -1;
    coeff_i = 5;
    n = 7;
    #1;
    $display("%0t\t%0d\t%0d\t%0d\t%0d\t%0d", $time, a, coeff_i, n, inv, error);

    // Finish simulation
    $finish;
  end

endmodule
