// Top level testbench contains the interface, DUT and test handles which 
// can be used to start test components once the DUT comes out of reset. Or
// the reset can also be a part of the test class in which case all you need
// to do is start the test's run method.
typedef class fsm_test;
module fsm_tb;
  // TB clock setup
  reg clk;
  always #5 clk = ~clk;

  // FSM interface
  fsm_if vif (clk);

  // DUT instance
  fsm dut(
    .mclk(vif.clk),
    .rst_n(vif.rst_n),

    .rram_busy(vif.rram_busy),

    .address_start(vif.address_start),
    .address_stop(vif.address_stop),
    .address_step(vif.address_step),
    .max_attempts(vif.max_attempts),
    //.use_ecc(vif.use_ecc),
    .num_levels(vif.num_levels),
    .bl_dac_set_lvl_cycle(vif.bl_dac_set_lvl_cycle),
    .wl_dac_set_lvl_cycle(vif.wl_dac_set_lvl_cycle),
    .pw_set_cycle(vif.pw_set_cycle),
    .sl_dac_rst_lvl_cycle(vif.sl_dac_rst_lvl_cycle),
    .wl_dac_rst_lvl_cycle(vif.wl_dac_rst_lvl_cycle),
    .pw_rst_cycle(vif.pw_rst_cycle),
    .set_first(vif.set_first),
    .di_init_mask(vif.di_init_mask),
    .ignore_failures(vif.ignore_failures),
    .all_dacs_on(vif.all_dacs_on),
    .idle_to_init_write_setup_cycles(vif.idle_to_init_write_setup_cycles),
    .idle_to_init_read_setup_cycles(vif.idle_to_init_read_setup_cycles),
    .read_to_init_write_setup_cycles(vif.read_to_init_write_setup_cycles),
    .write_to_init_read_setup_cycles(vif.write_to_init_read_setup_cycles),
    .step_read_setup_cycles(vif.step_read_setup_cycles),
    .step_write_setup_cycles(vif.step_write_setup_cycles),
    .post_read_setup_cycles(vif.post_read_setup_cycles),

    .adc_clamp_ref_lvl(vif.adc_clamp_ref_lvl),
    .adc_read_dac_lvl(vif.adc_read_dac_lvl),
    .adc_upper_read_ref_lvl(vif.adc_upper_read_ref_lvl),
    .adc_lower_write_ref_lvl(vif.adc_lower_write_ref_lvl),
    .adc_upper_write_ref_lvl(vif.adc_upper_write_ref_lvl),
    .bl_dac_set_lvl_start(vif.bl_dac_set_lvl_start),
    .bl_dac_set_lvl_stop(vif.bl_dac_set_lvl_stop),
    .bl_dac_set_lvl_step(vif.bl_dac_set_lvl_step),
    .wl_dac_set_lvl_start(vif.wl_dac_set_lvl_start),
    .wl_dac_set_lvl_stop(vif.wl_dac_set_lvl_stop),
    .wl_dac_set_lvl_step(vif.wl_dac_set_lvl_step),
    .pw_set_start(vif.pw_set_start),
    .pw_set_stop(vif.pw_set_stop),
    .pw_set_step(vif.pw_set_step),
    .loop_order_set(vif.loop_order_set),
    .sl_dac_rst_lvl_start(vif.sl_dac_rst_lvl_start),
    .sl_dac_rst_lvl_stop(vif.sl_dac_rst_lvl_stop),
    .sl_dac_rst_lvl_step(vif.sl_dac_rst_lvl_step),
    .wl_dac_rst_lvl_start(vif.wl_dac_rst_lvl_start),
    .wl_dac_rst_lvl_stop(vif.wl_dac_rst_lvl_stop),
    .wl_dac_rst_lvl_step(vif.wl_dac_rst_lvl_step),
    .pw_rst_start(vif.pw_rst_start),
    .pw_rst_stop(vif.pw_rst_stop),
    .pw_rst_step(vif.pw_rst_step),
    .loop_order_rst(vif.loop_order_rst),

    .fsm_go(vif.fsm_go),
    .opcode(vif.opcode),
    .use_multi_addrs(vif.use_multi_addrs),
    .use_lfsr_data(vif.use_lfsr_data),
    .use_cb_data(vif.use_cb_data),
    .check63(vif.check63),
    .loop_mode(vif.loop_mode),

    .aclk(vif.aclk),
    .bl_en(vif.bl_en),
    .bleed_en(vif.bleed_en),
    .bsl_dac_config(vif.bsl_dac_config),
    .bsl_dac_en(vif.bsl_dac_en),
    .clamp_ref(vif.clamp_ref),
    .di(vif.di),
    .read_dac_config(vif.read_dac_config),
    .read_dac_en(vif.read_dac_en),
    .read_ref(vif.read_ref),
    .rram_addr(vif.rram_addr),
    .sa_clk(vif.sa_clk),
    .sa_en(vif.sa_en),
    .set_rst(vif.set_rst),
    .sl_en(vif.sl_en),
    .we(vif.we),
    .wl_dac_config(vif.wl_dac_config),
    .wl_dac_en(vif.wl_dac_en),
    .wl_en(vif.wl_en),

    .sa_do(vif.sa_do),
    .sa_rdy(vif.sa_rdy),

    .fsm_bits(vif.fsm_state),
    .diag_bits(vif.diag_state),
    .diag2_bits(vif.diag2_state),

    .write_data_bits(vif.write_data_bits),
    .read_data_bits(vif.read_data_bits),

    .rangei(vif.rangei)
  );

  // Analog RRAM behavioral model for testing purposes
  rram_1p3Mb beh(
    .aclk(vif.aclk),
    .bl_en(vif.bl_en),
    .bleed_en(vif.bleed_en),
    .bsl_dac_config(vif.bsl_dac_config),
    .bsl_dac_en(vif.bsl_dac_en),
    .clamp_ref(vif.clamp_ref),
    .di(vif.di),
    .read_dac_config(vif.read_dac_config),
    .read_dac_en(vif.read_dac_en),
    .read_ref(vif.read_ref),
    .rram_addr(vif.rram_addr),
    .sa_clk(vif.sa_clk),
    .sa_en(vif.sa_en),
    .set_rst(vif.set_rst),
    .sl_en(vif.sl_en),
    .we(vif.we),
    .wl_dac_config(vif.wl_dac_config),
    .wl_dac_en(vif.wl_dac_en),
    .wl_en(vif.wl_en),

    .sa_do(vif.sa_do),
    .sa_rdy(vif.sa_rdy),

    .man()
  );

  assign vif.g = beh.g;
  
  initial begin
    // Instantiate test
    fsm_test t0;

    // Set clock and reset
    clk <= 1; vif.rst_n <= 0;

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
