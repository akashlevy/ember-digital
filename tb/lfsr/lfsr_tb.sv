// Top level testbench contains the interface, DUT and test handles which 
// can be used to start test components once the DUT comes out of reset. Or
// the reset can also be a part of the test class in which case all you need
// to do is start the test's run method.
typedef class lfsr_test;
module lfsr_tb;
  // TB clock setup
  reg clk;
  always #5 clk = ~clk;

  // FSM interface
  lfsr_if vif (clk);

  // DUT
  // Random 1: 48'b101110001000100011101000010011101110001011110100
  // Random 2: 48'b100101111001111011100010000110100111000011110001
  // Random 3: 48'b010100011000000110001001000111010011101011101011
  // Random 4: 48'b110101110001111100110100000111000100110010011101
  lfsr_prbs_gen #(.LFSR_INIT(48'b110101110001111100110100000111000100110010011101)) dut (
    .clk(clk),
    .rst(vif.rst),
    .enable(vif.enable),
    .data_out(vif.data_out)
  );

  initial begin
    // Instantiate test
    lfsr_test t0;

    // Set clock
    clk <= 1;

    // Run test
    t0 = new;
    t0.e0.vif = vif;
    t0.run();

    // Wait until driver has empty mailbox
    @(t0.e0.d0.drv_done) $finish;
  end
  
  // Simulator dependent system tasks that can be used to 
  // dump simulation waves.
  initial begin
    $dumpvars;
    $dumpfile("dump.vcd");
  end
endmodule