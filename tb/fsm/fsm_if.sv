// The interface allows verification components to access DUT signals
// using a virtual interface handle
interface fsm_if (input bit clk);
  // Reset
  logic                                         rst_n;

  // RRAM busy indicator
  logic                                         rram_busy;

  // Address
  logic     [`ADDR_BITS_N-1:0]                  address_start;
  logic     [`ADDR_BITS_N-1:0]                  address_stop;
  logic     [`ADDR_BITS_N-1:0]                  address_step;

  // Input and output data registers
  logic     [`WORD_SIZE-1:0]                    write_data_bits [`PROG_CNFG_RANGES_LOG2_N-1:0];
  logic     [`WORD_SIZE-1:0]                    read_data_bits [`PROG_CNFG_RANGES_LOG2_N-1:0];

  // Global parameters from register array
  logic     [`MAX_ATTEMPTS_BITS_N-1:0]          max_attempts;
  logic                                         use_ecc;
  logic     [`PROG_CNFG_RANGES_LOG2_N-1:0]      num_levels;
  logic     [`BSL_DAC_BITS_N-1:0]               bl_dac_set_lvl_cycle;
  logic     [`WL_DAC_BITS_N-1:0]                wl_dac_set_lvl_cycle;
  logic     [`PW_BITS_N-1:0]                    pw_set_cycle;
  logic     [`BSL_DAC_BITS_N-1:0]               sl_dac_rst_lvl_cycle;
  logic     [`WL_DAC_BITS_N-1:0]                wl_dac_rst_lvl_cycle;
  logic     [`PW_BITS_N-1:0]                    pw_rst_cycle;
  logic                                         set_first;
  logic     [`WORD_SIZE-1:0]                    di_init_mask;
  logic                                         ignore_failures;
  logic                                         all_dacs_on;
  logic     [`SETUP_CYC_BITS_N-1:0]             idle_to_init_write_setup_cycles;
  logic     [`SETUP_CYC_BITS_N-1:0]             idle_to_init_read_setup_cycles;
  logic     [`SETUP_CYC_BITS_N-1:0]             read_to_init_write_setup_cycles;
  logic     [`SETUP_CYC_BITS_N-1:0]             write_to_init_read_setup_cycles;
  logic     [`SETUP_CYC_BITS_N-1:0]             step_read_setup_cycles;
  logic     [`SETUP_CYC_BITS_N-1:0]             step_write_setup_cycles;
  logic     [`SETUP_CYC_BITS_N-1:0]             post_read_setup_cycles;

  // Programming parameters from register array
  logic     [`ADC_BITS_N-1:0]                   adc_clamp_ref_lvl;
  logic     [`READ_DAC_BITS_N-1:0]              adc_read_dac_lvl;
  logic     [`ADC_BITS_N-1:0]                   adc_upper_read_ref_lvl;
  logic     [`ADC_BITS_N-1:0]                   adc_lower_write_ref_lvl;
  logic     [`ADC_BITS_N-1:0]                   adc_upper_write_ref_lvl;
  logic     [`BSL_DAC_BITS_N-1:0]               bl_dac_set_lvl_start;
  logic     [`BSL_DAC_BITS_N-1:0]               bl_dac_set_lvl_stop;
  logic     [`BSL_DAC_BITS_N-1:0]               bl_dac_set_lvl_step;
  logic     [`WL_DAC_BITS_N-1:0]                wl_dac_set_lvl_start;
  logic     [`WL_DAC_BITS_N-1:0]                wl_dac_set_lvl_stop;
  logic     [`WL_DAC_BITS_N-1:0]                wl_dac_set_lvl_step;
  logic     [`PW_BITS_N-1:0]                    pw_set_start;
  logic     [`PW_BITS_N-1:0]                    pw_set_stop;
  logic     [`PW_BITS_N-1:0]                    pw_set_step;
  logic     [`LOOP_BITS_N-1:0]                  loop_order_set;
  logic     [`BSL_DAC_BITS_N-1:0]               sl_dac_rst_lvl_start;
  logic     [`BSL_DAC_BITS_N-1:0]               sl_dac_rst_lvl_stop;
  logic     [`BSL_DAC_BITS_N-1:0]               sl_dac_rst_lvl_step;
  logic     [`WL_DAC_BITS_N-1:0]                wl_dac_rst_lvl_start;
  logic     [`WL_DAC_BITS_N-1:0]                wl_dac_rst_lvl_stop;
  logic     [`WL_DAC_BITS_N-1:0]                wl_dac_rst_lvl_step;
  logic     [`PW_BITS_N-1:0]                    pw_rst_start;
  logic     [`PW_BITS_N-1:0]                    pw_rst_stop;
  logic     [`PW_BITS_N-1:0]                    pw_rst_step;
  logic     [`LOOP_BITS_N-1:0]                  loop_order_rst;

  // Analog block interface
  logic                                         aclk;
  logic                                         bl_en;
  logic                                         bleed_en;
  logic     [`BSL_DAC_BITS_N-1:0]               bsl_dac_config;
  logic                                         bsl_dac_en;
  logic     [`ADC_BITS_N-1:0]                   clamp_ref;
  logic     [`WORD_SIZE-1:0]                    di;
  logic     [`READ_DAC_BITS_N-1:0]              read_dac_config;
  logic                                         read_dac_en;
  logic     [`ADC_BITS_N-1:0]                   read_ref;
  logic     [`ADDR_BITS_N-1:0]                  rram_addr;
  logic                                         sa_clk;
  logic                                         sa_en;
  logic                                         set_rst;
  logic                                         sl_en;
  logic                                         we;
  logic     [`WL_DAC_BITS_N-1:0]                wl_dac_config;
  logic                                         wl_dac_en;
  logic                                         wl_en;

  // FSM commands from register array
  logic                                         fsm_go;
  logic     [`OP_CODE_BITS_N-1:0]               opcode;
  logic                                         use_multi_addrs;

  // FSM current range index
  logic     [`PROG_CNFG_RANGES_LOG2_N-1:0]      rangei;

  // FSM input from analog block
  logic     [`WORD_SIZE-1:0]                    sa_do;
  logic                                         sa_rdy;

  // FSM state
  logic     [`FSM_FULL_STATE_BITS_N-1:0]        fsm_state;
  logic     [`FSM_DIAG_BITS_N-1:0]              diag_state;

  // Behavioral model conductance
  logic [`ADC_BITS_N-1:0] g [`NUM_WORDS-1:0][`WORD_SIZE-1:0];

  // FSM test charge pulse behavior spec (validates everything except pulse widths)
  property charge_pulse_valid;
    @(posedge clk)
    (opcode == `OP_TEST_CPULSE) and $rose(fsm_go) |=>
    ($rose(bl_en) and $rose(sl_en) and (wl_en == 0) and (di == (di_init_mask ~^ {`WORD_SIZE{set_rst}})) and (rram_addr == address_start)) and (we == 1) ##[1:3]
    ($fell(bl_en) and $stable(sl_en) and $stable(wl_en) and $stable(di) and $stable(rram_addr) and $stable(we)) ##1
    ($stable(bl_en) and $stable(sl_en) and $rose(wl_en) and $stable(di) and $stable(rram_addr) and $stable(we)) ##[1:3]
    ($stable(bl_en) and $fell(sl_en) and $fell(wl_en) and $fell(we));
  endproperty

  // Write pulse validity
  property write_pulse_valid1;
    // Signals aclk and we are equivalent (unless we have test charge pulse)
    @(posedge clk)
    (opcode != `OP_TEST_CPULSE) |-> (aclk == we);
  endproperty
  property write_pulse_valid2;
    // During write, stable signals until complete (unless we have test charge pulse)
    @(posedge clk)
    ($rose(we) and (opcode != `OP_TEST_CPULSE)) |->
    ((bl_en == 1) and (wl_en == 1) and (sl_en == 1) and (bsl_dac_en == 1) and (wl_dac_en == 1) and (bleed_en == all_dacs_on) and (read_dac_en == all_dacs_on)
    and $stable(bl_en) and $stable(wl_en) and $stable(sl_en) and $stable(bsl_dac_en) and $stable(wl_dac_en) and $stable(bleed_en) and $stable(read_dac_en)
    and $stable(bsl_dac_config) and $stable(wl_dac_config) and $stable(set_rst) and $stable(di) and $stable(rram_addr)) [*1:$] ##1
    $fell(we);
  endproperty

  // Read pulse validity
  property read_pulse_valid;
    // During read, stable signals until complete
    @(posedge clk)
    $rose(sa_en) |->
    ((bl_en == 1) and (wl_en == 1) and (sl_en == 1) and (bsl_dac_en == all_dacs_on) and (wl_dac_en == all_dacs_on) and (bleed_en == 1) and (read_dac_en == 1)
    and $stable(bl_en) and $stable(wl_en) and $stable(sl_en) and $stable(bsl_dac_en) and $stable(wl_dac_en) and $stable(bleed_en) and $stable(read_dac_en)
    and $stable(wl_dac_config) and $stable(clamp_ref) and $stable(read_dac_config) and $stable(read_ref) and $stable(rram_addr) and $stable(di)) [*1:$] ##1
    $rose(sa_rdy);
  endproperty

  // All DACs on validity
  property all_dacs_on_valid;
    // When all_dacs_on signal is set globally, make sure all DAC enable signals are high
    @(posedge clk)
    all_dacs_on |-> (bsl_dac_en && wl_dac_en && bleed_en && read_dac_en);
  endproperty

  // Assert specs
  assert property (charge_pulse_valid);
  assert property (write_pulse_valid1);
  assert property (write_pulse_valid2);
  assert property (read_pulse_valid);
  assert property (all_dacs_on_valid);
endinterface
