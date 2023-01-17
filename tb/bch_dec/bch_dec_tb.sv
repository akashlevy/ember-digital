// Top level testbench contains the interface, DUT and test handles which 
// can be used to start test components once the DUT comes out of reset. Or
// the reset can also be a part of the test class in which case all you need
// to do is start the test's run method.
typedef class bch_dec_test;
module bch_dec_tb;
  // TB clock setup
  reg clk;
  always #5 clk = ~clk;

  // FSM interface
  bch_dec_if vif (clk);

  // DUT instances
  bch_dec_enc_univ_top #(.P_D_WIDTH(`ECC_WORD_SIZE)) bch_enc_dut (
    .d_i(vif.write_bits),
    .p_o(vif.write_ecc_bits)
  );
  bch_dec_dcd_univ_top #(.P_D_WIDTH(`ECC_WORD_SIZE)) bch_dcd_dut (
    .d_i(vif.read_bits),
    .ecc_i(vif.read_ecc_bits),
    .msk_o(vif.ecc_msk_o),
    .err_det_o(vif.ecc_err_det)
  );

  initial begin
    // Instantiate test
    bch_dec_test t0;

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