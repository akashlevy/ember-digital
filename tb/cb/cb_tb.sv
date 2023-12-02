// Top level testbench contains the interface, DUT and test handles which 
// can be used to start test components once the DUT comes out of reset. Or
// the reset can also be a part of the test class in which case all you need
// to do is start the test's run method.
typedef class cb_test;
module cb_tb;
  // TB clock setup
  reg clk;
  always #5 clk = ~clk;

  // FSM interface
  cb_if vif (clk);

  // DUT
  cb dut (
    .clk(clk),
    .rst(vif.rst),
    .enable(vif.enable),
    .num_levels(vif.num_levels),
    .data_out(vif.data_out)
  );

  initial begin
    // Instantiate test
    cb_test t0;

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