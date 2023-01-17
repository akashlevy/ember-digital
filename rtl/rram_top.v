// RRAM Top Module
module rram_top (
  /////////////
  // TO PADS //
  /////////////

  // Clock enable, reset
  input mclk_pause_pad,
  input rst_n_pad,

  // RRAM busy indicator
  output wire rram_busy_pad,

  // SPI interface (WONTFIX: could combine mosi/miso into one pad)
  input       sclk_pad,       // (I) SPI serial clock
  input       sc_pad,         // (I) SPI chip select
  input       mosi_pad,       // (I) SPI master out, slave in
  output wire miso_pad,       // (O) SPI master in, slave out data
  
  // Input to analog block
  input aclk_pad,
  input bl_en_pad,
  input bleed_en_pad,
  input [`BSL_DAC_BITS_N-1:0] bsl_dac_config_pad,
  input bsl_dac_en_pad,
  input [`ADC_BITS_N-1:0] clamp_ref_pad,
  input [`WORD_SIZE-1:0] di_pad,
  input man_pad,
  input [`READ_DAC_BITS_N-1:0] read_dac_config_pad,
  input read_dac_en_pad,
  input [`ADC_BITS_N-1:0] read_ref_pad,
  input [`ADDR_BITS_N-1:0] rram_addr_pad,
  input sa_clk_pad,
  input sa_en_pad,
  input set_rst_pad,
  input sl_en_pad,
  input we_pad,
  input [`WL_DAC_BITS_N-1:0] wl_dac_config_pad,
  input wl_dac_en_pad,
  input wl_en_pad,

  // Output from analog block
  output wire[`WORD_SIZE-1:0] sa_do_pad,
  output wire sa_rdy_pad,

  // FPGA debug
  input byp_pad,
  output wire heartbeat_pad
  );

  // Heartbeat register
  reg heartbeat;

  // Clock, reset, busy wires
    wire mclk_pause;
    wire mclk;
    wire rst_n;
    wire rram_busy;
  // SPI wires
    wire sclk;
    wire sc;
    wire mosi;
    wire miso;
    wire miso_oe_n;
  // SPI to/from FSM wires
    wire                                      fsm_go;
    wire    [`OP_CODE_BITS_N-1:0]             opcode;
    wire                                      use_multi_addrs;

    wire    [`ADDR_BITS_N-1:0]                address_start;
    wire    [`ADDR_BITS_N-1:0]                address_stop;
    wire    [`ADDR_BITS_N-1:0]                address_step;
    wire    [`MAX_ATTEMPTS_BITS_N-1:0]        max_attempts;
    wire                                      use_ecc;
    wire    [`PROG_CNFG_RANGES_LOG2_N-1:0]    num_levels;
    wire    [`BSL_DAC_BITS_N-1:0]             bl_dac_set_lvl_cycle;
    wire    [`WL_DAC_BITS_N-1:0]              wl_dac_set_lvl_cycle;
    wire    [`PW_BITS_N-1:0]                  pw_set_cycle;
    wire    [`BSL_DAC_BITS_N-1:0]             sl_dac_rst_lvl_cycle;
    wire    [`WL_DAC_BITS_N-1:0]              wl_dac_rst_lvl_cycle;
    wire    [`PW_BITS_N-1:0]                  pw_rst_cycle;
    wire                                      set_first;
    wire    [`WORD_SIZE-1:0]                  di_init_mask;
    wire                                      ignore_failures;
    wire                                      all_dacs_on;
    wire    [`SETUP_CYC_BITS_N-1:0]           idle_to_init_write_setup_cycles;
    wire    [`SETUP_CYC_BITS_N-1:0]           idle_to_init_read_setup_cycles;
    wire    [`SETUP_CYC_BITS_N-1:0]           read_to_init_write_setup_cycles;
    wire    [`SETUP_CYC_BITS_N-1:0]           write_to_init_read_setup_cycles;
    wire    [`SETUP_CYC_BITS_N-1:0]           step_read_setup_cycles;
    wire    [`SETUP_CYC_BITS_N-1:0]           step_write_setup_cycles;
    wire    [`SETUP_CYC_BITS_N-1:0]           post_read_setup_cycles;
    wire    [`ADC_BITS_N-1:0]                 adc_clamp_ref_lvl;
    wire    [`READ_DAC_BITS_N-1:0]            adc_read_dac_lvl;
    wire    [`ADC_BITS_N-1:0]                 adc_upper_read_ref_lvl;
    wire    [`ADC_BITS_N-1:0]                 adc_lower_write_ref_lvl;
    wire    [`ADC_BITS_N-1:0]                 adc_upper_write_ref_lvl;
    wire    [`BSL_DAC_BITS_N-1:0]             bl_dac_set_lvl_start;
    wire    [`BSL_DAC_BITS_N-1:0]             bl_dac_set_lvl_stop;
    wire    [`BSL_DAC_BITS_N-1:0]             bl_dac_set_lvl_step;
    wire    [`WL_DAC_BITS_N-1:0]              wl_dac_set_lvl_start;
    wire    [`WL_DAC_BITS_N-1:0]              wl_dac_set_lvl_stop;
    wire    [`WL_DAC_BITS_N-1:0]              wl_dac_set_lvl_step;
    wire    [`PW_BITS_N-1:0]                  pw_set_start;
    wire    [`PW_BITS_N-1:0]                  pw_set_stop;
    wire    [`PW_BITS_N-1:0]                  pw_set_step;
    wire    [`LOOP_BITS_N-1:0]                loop_order_set;
    wire    [`BSL_DAC_BITS_N-1:0]             sl_dac_rst_lvl_start;
    wire    [`BSL_DAC_BITS_N-1:0]             sl_dac_rst_lvl_stop;
    wire    [`BSL_DAC_BITS_N-1:0]             sl_dac_rst_lvl_step;
    wire    [`WL_DAC_BITS_N-1:0]              wl_dac_rst_lvl_start;
    wire    [`WL_DAC_BITS_N-1:0]              wl_dac_rst_lvl_stop;
    wire    [`WL_DAC_BITS_N-1:0]              wl_dac_rst_lvl_step;
    wire    [`PW_BITS_N-1:0]                  pw_rst_start;
    wire    [`PW_BITS_N-1:0]                  pw_rst_stop;
    wire    [`PW_BITS_N-1:0]                  pw_rst_step;
    wire    [`LOOP_BITS_N-1:0]                loop_order_rst;

    wire    [`PROG_CNFG_RANGES_LOG2_N-1:0]    rangei;
    wire    [`FSM_FULL_STATE_BITS_N-1:0]      fsm_bits;
    wire    [`FSM_DIAG_BITS_N-1:0]            diag_bits;

  // Analog block wires
    wire aclk;
    wire bl_en;
    wire bleed_en;
    wire [`BSL_DAC_BITS_N-1:0] bsl_dac_config;
    wire bsl_dac_en;
    wire [`ADC_BITS_N-1:0] clamp_ref;
    wire [`WORD_SIZE-1:0] di;
    wire [`READ_DAC_BITS_N-1:0] read_dac_config;
    wire read_dac_en;
    wire [`ADC_BITS_N-1:0] read_ref;
    wire [`ADDR_BITS_N-1:0] rram_addr;
    wire sa_clk;
    wire sa_en;
    wire set_rst;
    wire sl_en;
    wire we;
    wire [`WL_DAC_BITS_N-1:0] wl_dac_config;
    wire wl_dac_en;
    wire wl_en;
    wire [`WORD_SIZE-1:0] sa_do;
    wire sa_rdy;

  // FSM to/from analog block wires
    wire aclk_fsm;
    wire bl_en_fsm;
    wire bleed_en_fsm;
    wire [`BSL_DAC_BITS_N-1:0] bsl_dac_config_fsm;
    wire bsl_dac_en_fsm;
    wire [`ADC_BITS_N-1:0] clamp_ref_fsm;
    wire [`WORD_SIZE-1:0] di_fsm;
    wire [`READ_DAC_BITS_N-1:0] read_dac_config_fsm;
    wire read_dac_en_fsm;
    wire [`ADC_BITS_N-1:0] read_ref_fsm;
    wire [`ADDR_BITS_N-1:0] rram_addr_fsm;
    wire sa_clk_fsm;
    wire sa_en_fsm;
    wire set_rst_fsm;
    wire sl_en_fsm;
    wire we_fsm;
    wire [`WL_DAC_BITS_N-1:0] wl_dac_config_fsm;
    wire wl_dac_en_fsm;
    wire wl_en_fsm;

  // Pads to/from analog block + test struct wires 
    wire aclk_byp;
    wire bl_en_byp;
    wire bleed_en_byp;
    wire [`BSL_DAC_BITS_N-1:0] bsl_dac_config_byp;
    wire bsl_dac_en_byp;
    wire [`ADC_BITS_N-1:0] clamp_ref_byp;
    wire [`WORD_SIZE-1:0] di_byp;
    wire [`READ_DAC_BITS_N-1:0] read_dac_config_byp;
    wire read_dac_en_byp;
    wire [`ADC_BITS_N-1:0] read_ref_byp;
    wire [`ADDR_BITS_N-1:0] rram_addr_byp;
    wire sa_clk_byp;
    wire sa_en_byp;
    wire set_rst_byp;
    wire sl_en_byp;
    wire we_byp;
    wire [`WL_DAC_BITS_N-1:0] wl_dac_config_byp;
    wire wl_dac_en_byp;
    wire wl_en_byp;

  // ECC wires
    wire [`WORD_SIZE-1:0]       read_data_bits_no_ecc   [`PROG_CNFG_RANGES_LOG2_N-1:0];
    wire [`WORD_SIZE-1:0]       read_data_bits          [`PROG_CNFG_RANGES_LOG2_N-1:0];
    wire [`WORD_SIZE-1:0]       write_data_bits_no_ecc  [`PROG_CNFG_RANGES_LOG2_N-1:0];
    wire [`WORD_SIZE-1:0]       write_data_bits         [`PROG_CNFG_RANGES_LOG2_N-1:0];
    wire [`ECC_RED_N_BITS-1:0]  write_data_ecc_bits     [`PROG_CNFG_RANGES_LOG2_N-1:0];
    wire [`ECC_WORD_SIZE-1:0]   ecc_msk_o               [`PROG_CNFG_RANGES_LOG2_N-1:0]; 
    wire                        ecc_err_det             [`PROG_CNFG_RANGES_LOG2_N-1:0];

  // Override wires (manual and bypass)
    wire byp;
    wire man;

  // SPI interface to RRAM
  spi_slave_rram u_spi_slave_rram (
    .rst_n(rst_n),

    .sclk(sclk),
    .sc(sc),
    .mosi(mosi),
    .miso(miso),
    .miso_oe_n(miso_oe_n),

    .fsm_go(fsm_go),
    .opcode(opcode),
    .use_multi_addrs(use_multi_addrs),
    
    .address_start(address_start),
    .address_stop(address_stop),
    .address_step(address_step),

    .max_attempts(max_attempts),
    .use_ecc(use_ecc),
    .num_levels(num_levels),
    .bl_dac_set_lvl_cycle(bl_dac_set_lvl_cycle),
    .wl_dac_set_lvl_cycle(wl_dac_set_lvl_cycle),
    .pw_set_cycle(pw_set_cycle),
    .sl_dac_rst_lvl_cycle(sl_dac_rst_lvl_cycle),
    .wl_dac_rst_lvl_cycle(wl_dac_rst_lvl_cycle),
    .pw_rst_cycle(pw_rst_cycle),
    .set_first(set_first),
    .di_init_mask(di_init_mask),
    .ignore_failures(ignore_failures),
    .all_dacs_on(all_dacs_on),
    .idle_to_init_write_setup_cycles(idle_to_init_write_setup_cycles),
    .idle_to_init_read_setup_cycles(idle_to_init_read_setup_cycles),
    .read_to_init_write_setup_cycles(read_to_init_write_setup_cycles),
    .write_to_init_read_setup_cycles(write_to_init_read_setup_cycles),
    .step_read_setup_cycles(step_read_setup_cycles),
    .step_write_setup_cycles(step_write_setup_cycles),
    .post_read_setup_cycles(post_read_setup_cycles),

    .adc_clamp_ref_lvl(adc_clamp_ref_lvl),
    .adc_read_dac_lvl(adc_read_dac_lvl),
    .adc_upper_read_ref_lvl(adc_upper_read_ref_lvl),
    .adc_lower_write_ref_lvl(adc_lower_write_ref_lvl),
    .adc_upper_write_ref_lvl(adc_upper_write_ref_lvl),
    .bl_dac_set_lvl_start(bl_dac_set_lvl_start),
    .bl_dac_set_lvl_stop(bl_dac_set_lvl_stop),
    .bl_dac_set_lvl_step(bl_dac_set_lvl_step),
    .wl_dac_set_lvl_start(wl_dac_set_lvl_start),
    .wl_dac_set_lvl_stop(wl_dac_set_lvl_stop),
    .wl_dac_set_lvl_step(wl_dac_set_lvl_step),
    .pw_set_start(pw_set_start),
    .pw_set_stop(pw_set_stop),
    .pw_set_step(pw_set_step),
    .loop_order_set(loop_order_set),
    .sl_dac_rst_lvl_start(sl_dac_rst_lvl_start),
    .sl_dac_rst_lvl_stop(sl_dac_rst_lvl_stop),
    .sl_dac_rst_lvl_step(sl_dac_rst_lvl_step),
    .wl_dac_rst_lvl_start(wl_dac_rst_lvl_start),
    .wl_dac_rst_lvl_stop(wl_dac_rst_lvl_stop),
    .wl_dac_rst_lvl_step(wl_dac_rst_lvl_step),
    .pw_rst_start(pw_rst_start),
    .pw_rst_stop(pw_rst_stop),
    .pw_rst_step(pw_rst_step),
    .loop_order_rst(loop_order_rst),

    .rangei(rangei),
    .fsm_bits(fsm_bits),
    .diag_bits(diag_bits),

    .read_data_bits(read_data_bits),
    .write_data_bits(write_data_bits_no_ecc)
  );

  // Digital control FSM
  fsm u_fsm (
    .mclk(mclk),
    .rst_n(rst_n),

    .rram_busy(rram_busy),

    .address_start(address_start),
    .address_stop(address_stop),
    .address_step(address_step),
    .write_data_bits(write_data_bits),
    .read_data_bits(read_data_bits_no_ecc),
    .max_attempts(max_attempts),
    // .use_ecc(use_ecc),
    .num_levels(num_levels),
    .bl_dac_set_lvl_cycle(bl_dac_set_lvl_cycle),
    .wl_dac_set_lvl_cycle(wl_dac_set_lvl_cycle),
    .pw_set_cycle(pw_set_cycle),
    .sl_dac_rst_lvl_cycle(sl_dac_rst_lvl_cycle),
    .wl_dac_rst_lvl_cycle(wl_dac_rst_lvl_cycle),
    .pw_rst_cycle(pw_rst_cycle),
    .set_first(set_first),
    .di_init_mask(di_init_mask),
    .ignore_failures(ignore_failures),
    .all_dacs_on(all_dacs_on),
    .idle_to_init_write_setup_cycles(idle_to_init_write_setup_cycles),
    .idle_to_init_read_setup_cycles(idle_to_init_read_setup_cycles),
    .read_to_init_write_setup_cycles(read_to_init_write_setup_cycles),
    .write_to_init_read_setup_cycles(write_to_init_read_setup_cycles),
    .step_read_setup_cycles(step_read_setup_cycles),
    .step_write_setup_cycles(step_write_setup_cycles),
    .post_read_setup_cycles(post_read_setup_cycles),
    .adc_clamp_ref_lvl(adc_clamp_ref_lvl),
    .adc_read_dac_lvl(adc_read_dac_lvl),
    .adc_upper_read_ref_lvl(adc_upper_read_ref_lvl),
    .adc_lower_write_ref_lvl(adc_lower_write_ref_lvl),
    .adc_upper_write_ref_lvl(adc_upper_write_ref_lvl),
    .bl_dac_set_lvl_start(bl_dac_set_lvl_start),
    .bl_dac_set_lvl_stop(bl_dac_set_lvl_stop),
    .bl_dac_set_lvl_step(bl_dac_set_lvl_step),
    .wl_dac_set_lvl_start(wl_dac_set_lvl_start),
    .wl_dac_set_lvl_stop(wl_dac_set_lvl_stop),
    .wl_dac_set_lvl_step(wl_dac_set_lvl_step),
    .pw_set_start(pw_set_start),
    .pw_set_stop(pw_set_stop),
    .pw_set_step(pw_set_step),
    .loop_order_set(loop_order_set),
    .sl_dac_rst_lvl_start(sl_dac_rst_lvl_start),
    .sl_dac_rst_lvl_stop(sl_dac_rst_lvl_stop),
    .sl_dac_rst_lvl_step(sl_dac_rst_lvl_step),
    .wl_dac_rst_lvl_start(wl_dac_rst_lvl_start),
    .wl_dac_rst_lvl_stop(wl_dac_rst_lvl_stop),
    .wl_dac_rst_lvl_step(wl_dac_rst_lvl_step),
    .pw_rst_start(pw_rst_start),
    .pw_rst_stop(pw_rst_stop),
    .pw_rst_step(pw_rst_step),
    .loop_order_rst(loop_order_rst),
    .fsm_go(fsm_go),
    .opcode(opcode),
    .use_multi_addrs(use_multi_addrs),
    
    .rangei(rangei),
    .fsm_bits(fsm_bits),
    .diag_bits(diag_bits),

    .sa_do(sa_do),
    .sa_rdy(sa_rdy),
    
    .aclk(aclk_fsm),
    .bl_en(bl_en_fsm),
    .bleed_en(bleed_en_fsm),
    .bsl_dac_config(bsl_dac_config_fsm),
    .bsl_dac_en(bsl_dac_en_fsm),
    .clamp_ref(clamp_ref_fsm),
    .di(di_fsm),
    .read_dac_config(read_dac_config_fsm),
    .read_dac_en(read_dac_en_fsm),
    .read_ref(read_ref_fsm),
    .rram_addr(rram_addr_fsm),
    .sa_clk(sa_clk_fsm),
    .sa_en(sa_en_fsm),
    .set_rst(set_rst_fsm),
    .sl_en(sl_en_fsm),
    .we(we_fsm),
    .wl_dac_config(wl_dac_config_fsm),
    .wl_dac_en(wl_dac_en_fsm),
    .wl_en(wl_en_fsm)
  );

  // Pad ring instance
  padring u_padring (
    .mclk_pause(mclk_pause),
    .rst_n(rst_n),

    .rram_busy(rram_busy),

    .sclk(sclk),
    .sc(sc),
    .mosi(mosi),
    .miso(miso),
    .miso_oe_n(miso_oe_n),

    .aclk(aclk_byp),
    .bl_en(bl_en_byp),
    .bleed_en(bleed_en_byp),
    .bsl_dac_config(bsl_dac_config_byp),
    .bsl_dac_en(bsl_dac_en_byp),
    .clamp_ref(clamp_ref_byp),
    .di(di_byp),
    .man(man),
    .read_dac_config(read_dac_config_byp),
    .read_dac_en(read_dac_en_byp),
    .read_ref(read_ref_byp),
    .rram_addr(rram_addr_byp),
    .sa_clk(sa_clk_byp),
    .sa_en(sa_en_byp),
    .set_rst(set_rst_byp),
    .sl_en(sl_en_byp),
    .we(we_byp),
    .wl_dac_config(wl_dac_config_byp),
    .wl_dac_en(wl_dac_en_byp),
    .wl_en(wl_en_byp),

    // .sa_do(sa_do_byp),
    // .sa_rdy(sa_rdy_byp),

    .sa_do(sa_do),
    .sa_rdy(sa_rdy),

    .byp(byp),
    .heartbeat(heartbeat),

    .mclk_pause_pad(mclk_pause_pad),
    .rst_n_pad(rst_n_pad),
    .rram_busy_pad(rram_busy_pad),
    .sclk_pad(sclk_pad),
    .sc_pad(sc_pad),
    .mosi_pad(mosi_pad),
    .miso_pad(miso_pad),
    .aclk_pad(aclk_pad),
    .bl_en_pad(bl_en_pad),
    .bleed_en_pad(bleed_en_pad),
    .bsl_dac_config_pad(bsl_dac_config_pad),
    .bsl_dac_en_pad(bsl_dac_en_pad),
    .clamp_ref_pad(clamp_ref_pad),
    .di_pad(di_pad),
    .man_pad(man_pad),
    .read_dac_config_pad(read_dac_config_pad),
    .read_dac_en_pad(read_dac_en_pad),
    .read_ref_pad(read_ref_pad),
    .rram_addr_pad(rram_addr_pad),
    .sa_clk_pad(sa_clk_pad),
    .sa_en_pad(sa_en_pad),
    .set_rst_pad(set_rst_pad),
    .sl_en_pad(sl_en_pad),
    .we_pad(we_pad),
    .wl_dac_config_pad(wl_dac_config_pad),
    .wl_dac_en_pad(wl_dac_en_pad),
    .wl_en_pad(wl_en_pad),
    .sa_do_pad(sa_do_pad),
    .sa_rdy_pad(sa_rdy_pad),
    .byp_pad(byp_pad),
    .heartbeat_pad(heartbeat_pad)
  );

  // RRAM analog block
  rram_1p3Mb u_rram (
    .aclk(aclk),
    .bl_en(bl_en),
    .bleed_en(bleed_en),
    .bsl_dac_config(bsl_dac_config),
    .bsl_dac_en(bsl_dac_en),
    .clamp_ref(clamp_ref),
    .di(di),
    .man(man),
    .read_dac_config(read_dac_config),
    .read_dac_en(read_dac_en),
    .read_ref(read_ref),
    .rram_addr(rram_addr),
    .sa_clk(sa_clk),
    .sa_en(sa_en),
    .set_rst(set_rst),
    .sl_en(sl_en),
    .we(we),
    .wl_dac_config(wl_dac_config),
    .wl_dac_en(wl_dac_en),
    .wl_en(wl_en),
    .sa_do(sa_do),
    .sa_rdy(sa_rdy)
  );

  // RRAM test structure
  rdac_test_struct u_test_struct (
    .clamp_ref(clamp_ref),
    .sa_en(sa_en)
  );

  // ECC blocks
  genvar i;
  generate
    for (i = 0; i < `PROG_CNFG_RANGES_LOG2_N; i=i+1) begin
      // ECC BCH encoder instance
      bch_dec_enc_univ_top #(.P_D_WIDTH(`ECC_WORD_SIZE)) u_bch_enc (
        write_data_bits_no_ecc[i][`ECC_WORD_SIZE-1:0],
        write_data_ecc_bits[i]
      );

      // ECC BCH decoder instance
      bch_dec_dcd_univ_top #(.P_D_WIDTH(`ECC_WORD_SIZE)) u_bch_dcd (
        read_data_bits_no_ecc[i][`ECC_WORD_SIZE-1:0],
        read_data_bits_no_ecc[i][`ECC_WORD_SIZE+`ECC_RED_N_BITS-1:`ECC_WORD_SIZE],
        ecc_msk_o[i],
        ecc_err_det[i]
      );

      // Bypass mux for ECC encoder/decoder
      assign write_data_bits[i] = use_ecc ? {write_data_ecc_bits[i], write_data_bits_no_ecc[i][`ECC_WORD_SIZE-1:0]} : write_data_bits_no_ecc[i];
      assign read_data_bits[i] = use_ecc ? ({ecc_err_det[i], ecc_msk_o[i] ^ read_data_bits_no_ecc[i][`ECC_WORD_SIZE-1:0]}) : read_data_bits_no_ecc[i];
    end
  endgenerate

  // Heartbeat signal (clock divider)
  always @(posedge mclk or negedge rst_n) begin
    if (!rst_n)
      heartbeat <= 1'b0;
    else
      heartbeat <= ~heartbeat;
  end

  // Generated main clock by gating SPI clock (allows pausing of FSM for debug, ensure mclk_pause is sync'd)
  clock_gen gen_mclk (
    .mclk(mclk),
    .sclk(sclk),
    .mclk_pause(mclk_pause)
  );
  
  // Bypass mux from pads to analog block
    assign aclk = byp ? aclk_byp : aclk_fsm;
    assign bl_en = byp ? bl_en_byp : bl_en_fsm;
    assign bleed_en = byp ? bleed_en_byp : bleed_en_fsm;
    assign bsl_dac_config = byp ? bsl_dac_config_byp : bsl_dac_config_fsm;
    assign bsl_dac_en = byp ? bsl_dac_en_byp : bsl_dac_en_fsm;
    assign clamp_ref = byp ? clamp_ref_byp : clamp_ref_fsm;
    assign di = byp ? di_byp : di_fsm;
    assign read_dac_config = byp ? read_dac_config_byp : read_dac_config_fsm;
    assign read_dac_en = byp ? read_dac_en_byp : read_dac_en_fsm;
    assign read_ref = byp ? read_ref_byp : read_ref_fsm;
    assign rram_addr = byp ? rram_addr_byp : rram_addr_fsm;
    assign sa_clk = byp ? sa_clk_byp : sa_clk_fsm;
    assign sa_en = byp ? sa_en_byp : sa_en_fsm;
    assign set_rst = byp ? set_rst_byp : set_rst_fsm;
    assign sl_en = byp ? sl_en_byp : sl_en_fsm;
    assign we = byp ? we_byp : we_fsm;
    assign wl_dac_config = byp ? wl_dac_config_byp : wl_dac_config_fsm;
    assign wl_dac_en = byp ? wl_dac_en_byp : wl_dac_en_fsm;
    assign wl_en = byp ? wl_en_byp : wl_en_fsm;
endmodule
