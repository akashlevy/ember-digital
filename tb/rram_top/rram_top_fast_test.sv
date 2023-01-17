// An environment without the generator and hence the stimulus should be 
// written in the test.
typedef class fsm_tb_pkt;
typedef class spi_slave_rram_tb_pkt;
typedef class rram_top_test;
class rram_top_fast_test extends rram_top_test;
  // Apply stimulus
  virtual task apply_stim();
    // Create transaction
    fsm_tb_pkt item;
    spi_slave_rram_tb_pkt spi_item;

    // Log start of test
    $display("T=%0t [Top Test] Starting test...", $time);

    // Test TEST_READ operation
    item = new;
    assert(item.randomize() with { opcode == `OP_READ; num_levels == 4;
    adc_clamp_ref_lvl[0] == 2; adc_upper_read_ref_lvl[0] == 2; adc_read_dac_lvl[0] == 4'b1111; 
    adc_clamp_ref_lvl[1] == 6; adc_upper_read_ref_lvl[1] == 6; adc_read_dac_lvl[1] == 4'b1111; 
    adc_clamp_ref_lvl[2] == 10; adc_upper_read_ref_lvl[2] == 32; adc_read_dac_lvl[2] == 4'b1111;
    address_start == 16'b0000001111111111; idle_to_init_read_setup_cycles == 3; di_init_mask == 48'hFFFFFFFFFFFF;}); // assert uses return val to avoid warn
    drv_mbx.put(item);

    // Readout FSM read registers
    item = new item;
    item.perform_read = 1;
    drv_mbx.put(item);

    // Enable fast mode (in top level test bench, do not configure any SPI stuff)
    item = new item;
    item.perform_read = 0;
    item.fast_mode = 1;

    // Test TEST_PULSE (SET/FORM) operation
    item = new item;
    item.opcode = `OP_TEST_PULSE;
    item.pw_set_cycle = 8'b00111001;
    item.set_first = 1;
    item.di_init_mask = 48'hFFFFFFFFFFFF;
    item.bl_dac_set_lvl_cycle = 5'b11111;
    item.wl_dac_set_lvl_cycle = 8'b11111111;
    item.sl_dac_rst_lvl_cycle = 5'b11111;
    item.wl_dac_rst_lvl_cycle = 8'b11111111;
    item.idle_to_init_write_setup_cycles = 15;
    item.write_to_init_read_setup_cycles = 5; 
    drv_mbx.put(item);

    // Test TEST_PULSE (RESET) operation
    item = new item;
    item.set_first = 0;
    drv_mbx.put(item);
  endtask
endclass
