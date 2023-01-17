// An environment without the generator and hence the stimulus should be 
// written in the test.
typedef class fsm_tb_env;
typedef class fsm_tb_pkt;
class fsm_test;
  // Test components
  fsm_tb_env e0;
  mailbox drv_mbx;

  // New instance
  function new();
    drv_mbx = new;
    e0 = new;
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
    $display("T=%0t [FSM Test] Starting test...", $time);

    // Iterate testing for multiple cycles (TODO: increase cycle count to 1000)
    for (int i = 0; i < 1; i++) begin
      // // Test TEST_PULSE operation
      // item = new;
      // assert(item.randomize() with { opcode == `OP_TEST_PULSE; }); // assert uses return val to avoid warn
      // item.pw_rst_cycle = 8'b11110000; // TODO: remove this once PW problem is fixed
      // drv_mbx.put(item);

      // // Test TEST_READ operation
      // item = new;
      // assert(item.randomize() with { opcode == `OP_TEST_READ; }); // assert uses return val to avoid warn
      // drv_mbx.put(item);

      // // Test TEST_CPULSE operation
      // item = new;
      // assert(item.randomize() with { opcode == `OP_TEST_CPULSE; idle_to_init_write_setup_cycles >= 1; }); // assert uses return val to avoid warn
      // drv_mbx.put(item);

      // // Test TEST_CYCLE operation
      // item = new;
      // assert(item.randomize() with { opcode == `OP_CYCLE; max_attempts <= 5; }); // assert uses return val to avoid warn
      // drv_mbx.put(item);

      // // Test READ operation
      // item = new;
      // assert(item.randomize() with { opcode == `OP_READ; }); // assert uses return val to avoid warn
      // drv_mbx.put(item);
      
      // // TODO: make it so that write has different probabilities

      // Test WRITE operation 
      item = new;
      assert(item.randomize() with { opcode == `OP_WRITE; di_init_mask == {`WORD_SIZE{1'b1}}; use_multi_addrs == 0; num_levels == 4; }); // assert uses return val to avoid warn
      drv_mbx.put(item);

      // // Test READ afte WRITE (TODO: verify in scoreboard)
      // item = new item; // copy same settings into new packet
      // item.opcode = `OP_READ; // use same settings, but update to use READ operation instead
      // drv_mbx.put(item);

      // // Test REFRESH operation (TODO: ensure that correction is made)
      // item = new;
      // assert(item.randomize() with { opcode == `OP_REFRESH; di_init_mask == {`WORD_SIZE{1'b1}}; }); // assert uses return val to avoid warn

      // TODO: test specifically with 16 levels constraint to make sure everything is ok
    end
  endtask
endclass
