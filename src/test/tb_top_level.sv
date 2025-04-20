`timescale 1ns / 1ps

module tb_top_level;

  parameter int WORD_WIDTH = 32;

  logic clk;
  logic rst;
  logic start;

  logic done;

  logic [1:0] mode;  // 00= nothing - 01=key ge; 10= encryption; 11= decryption;
  logic [WORD_WIDTH/2-1:0] seed;
  logic [WORD_WIDTH-1:0] message_i;
  logic [WORD_WIDTH-1:0] e_i;
  logic [WORD_WIDTH-1:0] d_i;
  logic [WORD_WIDTH-1:0] N_i;

  logic [WORD_WIDTH-1:0] message_o;
  logic [WORD_WIDTH-1:0] e_o;
  logic [WORD_WIDTH-1:0] d_o;
  logic [WORD_WIDTH-1:0] N_o;

  top_level #(
      .WORD_WIDTH(WORD_WIDTH)
  ) uut_top (
      .clk(clk),
      .rst(rst),
      .start(start),
      .done(done),
      .mode(mode),
      .seed(seed),
      .message_i(message_i),
      .e_i(e_i),
      .d_i(d_i),
      .N_i(N_i),
      .message_o(message_o),
      .e_o(e_o),
      .d_o(d_o),
      .N_o(N_o)
  );


  always #5 clk = ~clk;

  initial begin
    $dumpfile("wave_top.vcd");
    $dumpvars();


    clk   = 0;
    rst   = 0;
    start = 0;
    mode  = 0;
    seed  = 16'h11AF;

    #15 rst = 1;
    #15 rst = 0;

    mode = 2'b01;  // Key generation

    $display("------------------------------");
    $display("Starting Key Generation...");


    start = 1;
    #10;
    start = 0;  // Only pulse start

    // Wait for completion
    wait (done);
    // Set the found outputs to inputs
    e_i = e_o;
    N_i = N_o;
    d_i = d_o;

    // Display results
    $display("Public key e, N: %d, %d", e_o, N_o);
    $display("Private key d: %d", d_o);

    #10;

    $display("------------------------------");
    $display("Starting Message Encryption...");

    // Encryption mode 
    mode = 2'b10;
    message_i = 2;

    start = 1;
    #10;
    start = 0;  // Only pulse start

    wait (done);

    // Display results
    $display("Public key e, N: %d, %d", e_i, N_i);
    $display("Message to be encrypted: %d", message_i);
    $display("Message encrypted: %d", message_o);

    #10;

    $display("------------------------------");
    $display("Starting Message Decryption...");
    message_i = message_o;
    mode = 2'b11;

    start = 1;
    #10;
    start = 0;  // Only pulse start

    wait (done);

    // Display results
    $display("Public key d, N: %d, %d", d_i, N_i);
    $display("Message to be decrypted: %d", message_i);
    $display("Message decrypted: %d", message_o);


    #10 $finish;
  end



endmodule
