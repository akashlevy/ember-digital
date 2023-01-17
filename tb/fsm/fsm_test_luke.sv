// An environment without the generator and hence the stimulus should be 
// written in the test.
typedef class fsm_tb_env;
typedef class fsm_tb_pkt;
class fsm_test_luke;
  // Test components
  fsm_tb_env e0;
  mailbox drv_mbx;

  // New instance
  function new();
    drv_mbx = new();
    e0 = new();
  endfunction
  
  // Run test
  virtual task run();
    e0.d0.drv_mbx = drv_mbx;
    
    fork
    	e0.run();
    join_none
    
    apply_stim();
  endtask
  
  // Apply stimulus
  virtual task apply_stim();
    // Create transaction
    fsm_tb_pkt item;

    // Log start of test
    $display ("T=%0t [Test] Starting test...", $time);

// TOP RIGHT (RIGHT CELL)  
  // Test TEST_READ operation (INITIAL READ)
    item = new;
    assert(item.randomize() with { opcode == `OP_TEST_READ; num_levels == 2; adc_clamp_ref_lvl[0] == 2; adc_upper_read_ref_lvl[0] == 2; adc_read_dac_lvl[0] == 4'b0000; address_start == 16'b1010111111111111; idle_to_init_read_setup_cycles == 15;}); // assert uses return val to avoid warn
    drv_mbx.put(item);    

    // Test TEST_PULSE operation (SET/FORM)
    item = new;
    assert(item.randomize() with { opcode == `OP_TEST_PULSE; pw_set_cycle == 8'b00111001; set_first == 1; di_init_mask == 48'hFFFFFFFFFFFF; bl_dac_set_lvl_cycle == 5'b00000; wl_dac_set_lvl_cycle == 8'b11111111; address_start == 16'b1010111111111111; idle_to_init_write_setup_cycles == 15;
    write_to_init_read_setup_cycles == 5;}); // assert uses return val to avoid warn
    drv_mbx.put(item);    

    // Test TEST_PULSE operation (RESET)
    item = new;
    //pw_rst_cycle == 8'b10101000;
    assert(item.randomize() with { opcode == `OP_TEST_PULSE; pw_rst_cycle == 8'b10001000; set_first == 0; di_init_mask == 48'hFFFFFFFFFFFF; sl_dac_rst_lvl_cycle == 5'b00000; wl_dac_rst_lvl_cycle == 8'b11111111; address_start == 16'b1010111111111111; idle_to_init_write_setup_cycles == 15;}); // assert uses return val to avoid warn
    drv_mbx.put(item);

// TOP RIGHT (LEFT CELL)  
  // Test TEST_READ operation (INITIAL READ)
    //item = new;
    //assert(item.randomize() with { opcode == `OP_TEST_READ; adc_clamp_ref_lvl == 10; adc_upper_read_ref_lvl == 10; adc_read_dac_lvl == 4'b1111; address_start == 16'b0011101111111111; wl_dac_read_lvl == 8'b11111111; idle_to_init_read_setup_cycles == 10;}); // assert uses return val to avoid warn
    //drv_mbx.put(item);    

    // Test TEST_PULSE operation (SET/FORM)
    //item = new;
    //assert(item.randomize() with { opcode == `OP_TEST_PULSE; pw_set_cycle == 50; set_first == 1; di_init_mask == 48'hFFFFFFFFFFFF; bl_dac_set_lvl_cycle == 5'b11111; wl_dac_set_lvl_cycle == 8'b11111111; address_start == 16'b0011101111111111; idle_to_init_write_setup_cycles == 10;}); // assert uses return val to avoid warn
    //drv_mbx.put(item);    

    // Test TEST_READ operation (POST-SET READ)
    //item = new;
    //assert(item.randomize() with { opcode == `OP_TEST_READ; adc_clamp_ref_lvl == 10; adc_upper_read_ref_lvl == 10; adc_read_dac_lvl == 4'b1111; address_start == 16'b0011101111111111; wl_dac_read_lvl == 8'b11111111; idle_to_init_read_setup_cycles == 10;}); // assert uses return val to avoid warn
    //drv_mbx.put(item);

    // Test TEST_PULSE operation (RESET)
    //item = new;
    //assert(item.randomize() with { opcode == `OP_TEST_PULSE; pw_rst_cycle == 8'b10101000; set_first == 0; di_init_mask == 48'h000000000000; sl_dac_rst_lvl_cycle == 5'b11111; wl_dac_rst_lvl_cycle == 8'b11111111; address_start == 16'b0011101111111111; idle_to_init_write_setup_cycles == 10;}); // assert uses return val to avoid warn
    //drv_mbx.put(item);

    // Test TEST_READ operation (POST-RESET READ)
    //item = new;
    //assert(item.randomize() with { opcode == `OP_TEST_READ; adc_clamp_ref_lvl == 10; adc_upper_read_ref_lvl == 10; adc_read_dac_lvl == 4'b1111; address_start == 16'b0011101111111111; wl_dac_read_lvl == 8'b11111111; idle_to_init_read_setup_cycles == 10;}); // assert uses return val to avoid warn
    //drv_mbx.put(item);

// BOT RIGHT (RIGHT CELL)  
  // Test TEST_READ operation (INITIAL READ)
    //item = new;
    //assert(item.randomize() with { opcode == `OP_TEST_READ; adc_clamp_ref_lvl == 10; adc_upper_read_ref_lvl == 10; adc_read_dac_lvl == 4'b1111; address_start == 16'b0011110111111111; wl_dac_read_lvl == 8'b11111111; idle_to_init_read_setup_cycles == 10;}); // assert uses return val to avoid warn
    //drv_mbx.put(item);    

    // Test TEST_PULSE operation (SET/FORM)
    //item = new;
    //assert(item.randomize() with { opcode == `OP_TEST_PULSE; pw_set_cycle == 50; set_first == 1; di_init_mask == 48'hFFFFFFFFFFFF; bl_dac_set_lvl_cycle == 5'b11111; wl_dac_set_lvl_cycle == 8'b11111111; address_start == 16'b0011110111111111; idle_to_init_write_setup_cycles == 10;}); // assert uses return val to avoid warn
    //drv_mbx.put(item);    

    // Test TEST_READ operation (POST-SET READ)
    //item = new;
    //assert(item.randomize() with { opcode == `OP_TEST_READ; adc_clamp_ref_lvl == 10; adc_upper_read_ref_lvl == 10; adc_read_dac_lvl == 4'b1111; address_start == 16'b0011110111111111; wl_dac_read_lvl == 8'b11111111; idle_to_init_read_setup_cycles == 10;}); // assert uses return val to avoid warn
    //drv_mbx.put(item);

    // Test TEST_PULSE operation (RESET)
    //item = new;
    //assert(item.randomize() with { opcode == `OP_TEST_PULSE; pw_rst_cycle == 8'b10101000; set_first == 0; di_init_mask == 48'h000000000000; sl_dac_rst_lvl_cycle == 5'b11111; wl_dac_rst_lvl_cycle == 8'b11111111; address_start == 16'b0011110111111111; idle_to_init_write_setup_cycles == 10;}); // assert uses return val to avoid warn
    //drv_mbx.put(item);

    // Test TEST_READ operation (POST-RESET READ)
    //item = new;
    //assert(item.randomize() with { opcode == `OP_TEST_READ; adc_clamp_ref_lvl == 10; adc_upper_read_ref_lvl == 10; adc_read_dac_lvl == 4'b1111; address_start == 16'b0011110111111111; wl_dac_read_lvl == 8'b11111111; idle_to_init_read_setup_cycles == 10;}); // assert uses return val to avoid warn
    //drv_mbx.put(item);

// BOT RIGHT (LEFT CELL)  
  // Test TEST_READ operation (INITIAL READ)
    //item = new;
    //assert(item.randomize() with { opcode == `OP_TEST_READ; adc_clamp_ref_lvl == 10; adc_upper_read_ref_lvl == 10; adc_read_dac_lvl == 4'b1111; address_start == 16'b0011100111111111; wl_dac_read_lvl == 8'b11111111; idle_to_init_read_setup_cycles == 10;}); // assert uses return val to avoid warn
    //drv_mbx.put(item);    

    // Test TEST_PULSE operation (SET/FORM)
    //item = new;
    //assert(item.randomize() with { opcode == `OP_TEST_PULSE; pw_set_cycle == 50; set_first == 1; di_init_mask == 48'hFFFFFFFFFFFF; bl_dac_set_lvl_cycle == 5'b11111; wl_dac_set_lvl_cycle == 8'b11111111; address_start == 16'b0011100111111111; idle_to_init_write_setup_cycles == 10;}); // assert uses return val to avoid warn
    //drv_mbx.put(item);    

    // Test TEST_READ operation (POST-SET READ)
    //item = new;
    //assert(item.randomize() with { opcode == `OP_TEST_READ; adc_clamp_ref_lvl == 10; adc_upper_read_ref_lvl == 10; adc_read_dac_lvl == 4'b1111; address_start == 16'b0011100111111111; wl_dac_read_lvl == 8'b11111111; idle_to_init_read_setup_cycles == 10;}); // assert uses return val to avoid warn
    //drv_mbx.put(item);

    // Test TEST_PULSE operation (RESET)
    //item = new;
    //assert(item.randomize() with { opcode == `OP_TEST_PULSE; pw_rst_cycle == 8'b10101000; set_first == 0; di_init_mask == 48'h000000000000; sl_dac_rst_lvl_cycle == 5'b11111; wl_dac_rst_lvl_cycle == 8'b11111111; address_start == 16'b0011100111111111; idle_to_init_write_setup_cycles == 10;}); // assert uses return val to avoid warn
    //drv_mbx.put(item);

    // Test TEST_READ operation (POST-RESET READ)
    //item = new;
    //assert(item.randomize() with { opcode == `OP_TEST_READ; adc_clamp_ref_lvl == 10; adc_upper_read_ref_lvl == 10; adc_read_dac_lvl == 4'b1111; address_start == 16'b0011100111111111; wl_dac_read_lvl == 8'b11111111; idle_to_init_read_setup_cycles == 10;}); // assert uses return val to avoid warn
    //drv_mbx.put(item);

// SHIFT TO SL<0>

// TOP RIGHT (RIGHT CELL)  
  // Test TEST_READ operation (INITIAL READ)
    //item = new;
    //assert(item.randomize() with { opcode == `OP_TEST_READ; adc_clamp_ref_lvl == 10; adc_upper_read_ref_lvl == 10; adc_read_dac_lvl == 4'b1111; address_start == 16'b0000011111111111; wl_dac_read_lvl == 8'b11111111; idle_to_init_read_setup_cycles == 10;}); // assert uses return val to avoid warn
    //drv_mbx.put(item);    

    // Test TEST_PULSE operation (SET/FORM)
    //item = new;
    //assert(item.randomize() with { opcode == `OP_TEST_PULSE; pw_set_cycle == 50; set_first == 1; di_init_mask == 48'hFFFFFFFFFFFF; bl_dac_set_lvl_cycle == 5'b11111; wl_dac_set_lvl_cycle == 8'b11111111; address_start == 16'b0000011111111111; idle_to_init_write_setup_cycles == 10;}); // assert uses return val to avoid warn
    //drv_mbx.put(item);    

    // Test TEST_READ operation (POST-SET READ)
    //item = new;
    //assert(item.randomize() with { opcode == `OP_TEST_READ; adc_clamp_ref_lvl == 10; adc_upper_read_ref_lvl == 10; adc_read_dac_lvl == 4'b1111; address_start == 16'b0000011111111111; wl_dac_read_lvl == 8'b11111111; idle_to_init_read_setup_cycles == 10;}); // assert uses return val to avoid warn
    //drv_mbx.put(item);

    // Test TEST_PULSE operation (RESET)
    //item = new;
    //assert(item.randomize() with { opcode == `OP_TEST_PULSE; pw_rst_cycle == 8'b10101000; set_first == 0; di_init_mask == 48'h000000000000; sl_dac_rst_lvl_cycle == 5'b11111; wl_dac_rst_lvl_cycle == 8'b11111111; address_start == 16'b0000011111111111; idle_to_init_write_setup_cycles == 10;}); // assert uses return val to avoid warn
    //drv_mbx.put(item);

    // Test TEST_READ operation (POST-RESET READ)
    //item = new;
    //assert(item.randomize() with { opcode == `OP_TEST_READ; adc_clamp_ref_lvl == 10; adc_upper_read_ref_lvl == 10; adc_read_dac_lvl == 4'b1111; address_start == 16'b0000011111111111; wl_dac_read_lvl == 8'b11111111; idle_to_init_read_setup_cycles == 10;}); // assert uses return val to avoid warn
    //drv_mbx.put(item);

// TOP RIGHT (LEFT CELL)  
  // Test TEST_READ operation (INITIAL READ)
    //item = new;
    //assert(item.randomize() with { opcode == `OP_TEST_READ; adc_clamp_ref_lvl == 10; adc_upper_read_ref_lvl == 10; adc_read_dac_lvl == 4'b1111; address_start == 16'b0000001111111111; wl_dac_read_lvl == 8'b11111111; idle_to_init_read_setup_cycles == 10;}); // assert uses return val to avoid warn
    //drv_mbx.put(item);    

    // Test TEST_PULSE operation (SET/FORM)
    //item = new;
    //assert(item.randomize() with { opcode == `OP_TEST_PULSE; pw_set_cycle == 50; set_first == 1; di_init_mask == 48'hFFFFFFFFFFFF; bl_dac_set_lvl_cycle == 5'b11111; wl_dac_set_lvl_cycle == 8'b11111111; address_start == 16'b0000001111111111; idle_to_init_write_setup_cycles == 10;}); // assert uses return val to avoid warn
    //drv_mbx.put(item);    

    // Test TEST_READ operation (POST-SET READ)
    //item = new;
    //assert(item.randomize() with { opcode == `OP_TEST_READ; adc_clamp_ref_lvl == 10; adc_upper_read_ref_lvl == 10; adc_read_dac_lvl == 4'b1111; address_start == 16'b0000001111111111; wl_dac_read_lvl == 8'b11111111; idle_to_init_read_setup_cycles == 10;}); // assert uses return val to avoid warn
    //drv_mbx.put(item);

    // Test TEST_PULSE operation (RESET)
    //item = new;
    //assert(item.randomize() with { opcode == `OP_TEST_PULSE; pw_rst_cycle == 8'b10101000; set_first == 0; di_init_mask == 48'h000000000000; sl_dac_rst_lvl_cycle == 5'b11111; wl_dac_rst_lvl_cycle == 8'b11111111; address_start == 16'b0000001111111111; idle_to_init_write_setup_cycles == 10;}); // assert uses return val to avoid warn
    //drv_mbx.put(item);

    // Test TEST_READ operation (POST-RESET READ)
    //item = new;
    //assert(item.randomize() with { opcode == `OP_TEST_READ; adc_clamp_ref_lvl == 10; adc_upper_read_ref_lvl == 10; adc_read_dac_lvl == 4'b1111; address_start == 16'b0000001111111111; wl_dac_read_lvl == 8'b11111111; idle_to_init_read_setup_cycles == 10;}); // assert uses return val to avoid warn
    //drv_mbx.put(item);

// BOT RIGHT (RIGHT CELL)  
  // Test TEST_READ operation (INITIAL READ)
    //item = new;
    //assert(item.randomize() with { opcode == `OP_TEST_READ; adc_clamp_ref_lvl == 10; adc_upper_read_ref_lvl == 10; adc_read_dac_lvl == 4'b1111; address_start == 16'b0000010111111111; wl_dac_read_lvl == 8'b11111111; idle_to_init_read_setup_cycles == 10;}); // assert uses return val to avoid warn
    //drv_mbx.put(item);    

    // Test TEST_PULSE operation (SET/FORM)
    //item = new;
    //assert(item.randomize() with { opcode == `OP_TEST_PULSE; pw_set_cycle == 50; set_first == 1; di_init_mask == 48'hFFFFFFFFFFFF; bl_dac_set_lvl_cycle == 5'b11111; wl_dac_set_lvl_cycle == 8'b11111111; address_start == 16'b0000010111111111; idle_to_init_write_setup_cycles == 10;}); // assert uses return val to avoid warn
    //drv_mbx.put(item);    

    // Test TEST_READ operation (POST-SET READ)
    //item = new;
    //assert(item.randomize() with { opcode == `OP_TEST_READ; adc_clamp_ref_lvl == 10; adc_upper_read_ref_lvl == 10; adc_read_dac_lvl == 4'b1111; address_start == 16'b0000010111111111; wl_dac_read_lvl == 8'b11111111; idle_to_init_read_setup_cycles == 10;}); // assert uses return val to avoid warn
    //drv_mbx.put(item);

    // Test TEST_PULSE operation (RESET)
    //item = new;
    //assert(item.randomize() with { opcode == `OP_TEST_PULSE; pw_rst_cycle == 8'b10101000; set_first == 0; di_init_mask == 48'h000000000000; sl_dac_rst_lvl_cycle == 5'b11111; wl_dac_rst_lvl_cycle == 8'b11111111; address_start == 16'b0000010111111111; idle_to_init_write_setup_cycles == 10;}); // assert uses return val to avoid warn
    //drv_mbx.put(item);

    // Test TEST_READ operation (POST-RESET READ)
    //item = new;
    //assert(item.randomize() with { opcode == `OP_TEST_READ; adc_clamp_ref_lvl == 10; adc_upper_read_ref_lvl == 10; adc_read_dac_lvl == 4'b1111; address_start == 16'b0000010111111111; wl_dac_read_lvl == 8'b11111111; idle_to_init_read_setup_cycles == 10;}); // assert uses return val to avoid warn
    //drv_mbx.put(item);

// BOT RIGHT (LEFT CELL)  
  // Test TEST_READ operation (INITIAL READ)
    //item = new;
    //assert(item.randomize() with { opcode == `OP_TEST_READ; adc_clamp_ref_lvl == 10; adc_upper_read_ref_lvl == 10; adc_read_dac_lvl == 4'b1111; address_start == 16'b0000000111111111; wl_dac_read_lvl == 8'b11111111; idle_to_init_read_setup_cycles == 10;}); // assert uses return val to avoid warn
    //drv_mbx.put(item);    

    // Test TEST_PULSE operation (SET/FORM)
    //item = new;
    //assert(item.randomize() with { opcode == `OP_TEST_PULSE; pw_set_cycle == 50; set_first == 1; di_init_mask == 48'hFFFFFFFFFFFF; bl_dac_set_lvl_cycle == 5'b11111; wl_dac_set_lvl_cycle == 8'b11111111; address_start == 16'b0000000111111111; idle_to_init_write_setup_cycles == 10;}); // assert uses return val to avoid warn
    //drv_mbx.put(item);    

    // Test TEST_READ operation (POST-SET READ)
    //item = new;
    //assert(item.randomize() with { opcode == `OP_TEST_READ; adc_clamp_ref_lvl == 10; adc_upper_read_ref_lvl == 10; adc_read_dac_lvl == 4'b1111; address_start == 16'b0000000111111111; wl_dac_read_lvl == 8'b11111111; idle_to_init_read_setup_cycles == 10;}); // assert uses return val to avoid warn
    //drv_mbx.put(item);

    // Test TEST_PULSE operation (RESET)
    //item = new;
    //assert(item.randomize() with { opcode == `OP_TEST_PULSE; pw_rst_cycle == 8'b10101000; set_first == 0; di_init_mask == 48'h000000000000; sl_dac_rst_lvl_cycle == 5'b11111; wl_dac_rst_lvl_cycle == 8'b11111111; address_start == 16'b0000000111111111; idle_to_init_write_setup_cycles == 10;}); // assert uses return val to avoid warn
    //drv_mbx.put(item);

    // Test TEST_READ operation (POST-RESET READ)
    //item = new;
    //assert(item.randomize() with { opcode == `OP_TEST_READ; adc_clamp_ref_lvl == 10; adc_upper_read_ref_lvl == 10; adc_read_dac_lvl == 4'b1111; address_start == 16'b0000000111111111; wl_dac_read_lvl == 8'b11111111; idle_to_init_read_setup_cycles == 10;}); // assert uses return val to avoid warn
    //drv_mbx.put(item);

  endtask
endclass
