// Top level testbench contains the interface, DUT and test handles which 
// can be used to start test components once the DUT comes out of reset. Or
// the reset can also be a part of the test class in which case all you need
// to do is start the test's run method.
typedef class rram_top_fast_test;
module rram_top_tb;
  // TB clocks setup
  wire mclk;
  reg clk;
  always #5 clk = ~clk;

  // Top/SPI interface
  rram_top_if vif (clk);
  spi_slave_rram_if spi_vif (clk);
  fsm_if fsm_vif (mclk);

  // DUT instance
  rram_top dut(
    .mclk_pause_pad(vif.mclk_pause),    // (I) Main clock pause
    .rst_n_pad(spi_vif.rst_n),          // (I) Chip reset, active LO

    .rram_busy_pad(spi_vif.rram_busy),  // (O) RRAM busy indicator

    .sclk_pad(clk),                     // (I) SPI serial clock
    .sc_pad(spi_vif.sc),                // (I) SPI chip select (and async reset when sc = '0')
    .mosi_pad(spi_vif.mosi),            // (I) SPI master out, slave in
    .miso_pad(spi_vif.miso),            // (O) SPI master in, slave out data

    .heartbeat_pad(vif.heartbeat),      // (O) heartbeat signal

    .byp_pad(vif.byp),                  // (I) bypass signal

    .aclk_pad(vif.aclk),
    .bl_en_pad(vif.bl_en),
    .bleed_en_pad(vif.bleed_en),
    .bsl_dac_config_pad(vif.bsl_dac_config),
    .bsl_dac_en_pad(vif.bsl_dac_en),
    .clamp_ref_pad(vif.clamp_ref),
    .di_pad(vif.di),
    .man_pad(man_pad),
    .read_dac_config_pad(vif.read_dac_config),
    .read_dac_en_pad(vif.read_dac_en),
    .read_ref_pad(vif.read_ref),
    .rram_addr_pad(vif.rram_addr),
    .sa_clk_pad(vif.sa_clk),
    .sa_en_pad(vif.sa_en),
    .set_rst_pad(vif.set_rst),
    .sl_en_pad(vif.sl_en),
    .we_pad(vif.we),
    .wl_dac_config_pad(vif.wl_dac_config),
    .wl_dac_en_pad(vif.wl_dac_en),
    .wl_en_pad(vif.wl_en),

    .sa_do_pad(vif.sa_do),
    .sa_rdy_pad(vif.sa_rdy)
  );

  // Connect ports up
  assign vif.rst_n = spi_vif.rst_n;
  assign vif.sc = spi_vif.sc;
  assign vif.mosi = spi_vif.mosi;
  assign vif.miso = spi_vif.miso;
  assign vif.rram_busy = spi_vif.rram_busy;
  assign spi_vif.miso_oe_n = dut.miso_oe_n;
  assign fsm_vif.aclk = dut.aclk;
  assign fsm_vif.bl_en = dut.bl_en;
  assign fsm_vif.bleed_en = dut.bleed_en;
  assign fsm_vif.bsl_dac_config = dut.bsl_dac_config;
  assign fsm_vif.bsl_dac_en = dut.bsl_dac_en;
  assign fsm_vif.clamp_ref = dut.clamp_ref;
  assign fsm_vif.di = dut.di;
  assign fsm_vif.read_dac_config = dut.read_dac_config;
  assign fsm_vif.read_dac_en = dut.read_dac_en;
  assign fsm_vif.read_ref = dut.read_ref;
  assign fsm_vif.rram_addr = dut.rram_addr;
  assign fsm_vif.sa_clk = dut.sa_clk;
  assign fsm_vif.sa_en = dut.sa_en;
  assign fsm_vif.set_rst = dut.set_rst;
  assign fsm_vif.sl_en = dut.sl_en;
  assign fsm_vif.we = dut.we;
  assign fsm_vif.wl_dac_config = dut.wl_dac_config;
  assign fsm_vif.wl_dac_en = dut.wl_dac_en;
  assign fsm_vif.wl_en = dut.wl_en;
  assign fsm_vif.sa_do = dut.sa_do;
  assign fsm_vif.sa_rdy = dut.sa_rdy;
  assign fsm_vif.all_dacs_on = dut.all_dacs_on;
  assign fsm_vif.opcode = dut.opcode;
  assign fsm_vif.fsm_go = dut.fsm_go;
  assign fsm_vif.di_init_mask = dut.di_init_mask;
  assign fsm_vif.address_start = dut.address_start;
  assign mclk = dut.mclk;
  
  initial begin
    // Instantiate test
    rram_top_fast_test t0;

    // Set clock and reset
    clk <= 0;
    vif.mclk_pause <= 0;
    vif.byp <= 0;

    // Run test
    t0 = new;
    t0.e0.vif = vif;
    t0.e0.spi_vif = spi_vif;
    t0.e0.fsm_vif = fsm_vif;
    t0.run();

    // Wait until driver has empty mailbox
    @(t0.e0.d0.drv_done) $finish;
  end
  
  always begin
    @(posedge dut.fsm_go) $display("T=%0t [Top TB] FSM GO...", $time);
  end
  
  // Simulator dependent system tasks that can be used to 
  // dump simulation waves.
  initial begin
    $dumpvars;
    $dumpfile("dump.vcd");
  end
endmodule
