// Top level testbench contains the interface, DUT and test handles which 
// can be used to start test components once the DUT comes out of reset. Or
// the reset can also be a part of the test class in which case all you need
// to do is start the test's run method.
typedef class spi_slave_rram_test;
module spi_slave_rram_tb;
  // TB clock setup
  reg clk;
  always #5 clk = ~clk;

  // SPI interface
  spi_slave_rram_if vif (clk);

  // DUT instance
  spi_slave_rram dut(
    .rst_n(vif.rst_n),              // (I) Chip reset, active LO
    .sclk(vif.sclk),                // (I) SPI serial clock
    .sc(vif.sc),                    // (I) SPI chip select (and async reset when sc = '0')
    .mosi(vif.mosi),                // (I) SPI master out, slave in
    .miso(vif.miso),                // (O) SPI master in, slave out data
    .miso_oe_n(vif.miso_oe_n),      // (O) SPI master in, slave out output enable, active LO

    .fsm_go(vif.fsm_go),            // (O) FSM trigger

    .fsm_bits(vif.fsm_bits),        // (I) FSM state bits
    .diag_bits(vif.diag_bits),      // (I) FSM diagnostic bits
    .diag2_bits(vif.diag2_bits),    // (I) FSM diagnostic 2 bits
    .read_data_bits(vif.readdata),  // (I) Read data bits

    .rangei()
  );

  // Let RRAM busy toggle to trigger SPI to move on
  assign vif.rram_busy = clk;
  
  initial begin
    // Instantiate test
    spi_slave_rram_test t0;

    // Set clock
    clk <= 0;

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