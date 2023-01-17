// An environment without the generator and hence the stimulus should be 
// written in the test.
typedef class fsm_tb_pkt;
typedef class rram_top_tb_env;
class rram_top_test;
  // Test components
  rram_top_tb_env e0;
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
    $display("T=%0t [Top Test] Starting test...", $time);

    // Iterate testing for multiple cycles (TODO: increase cycle count)
    for (int i = 0; i < 1; i++) begin
      // Test TEST_PULSE operation
      item = new;
      assert(item.randomize() with { opcode == `OP_TEST_PULSE; }); // assert uses return val to avoid warn
      drv_mbx.put(item);

      // Test TEST_READ operation
      item = new;
      assert(item.randomize() with { opcode == `OP_TEST_READ; }); // assert uses return val to avoid warn
      drv_mbx.put(item);

      // Test TEST_CPULSE operation
      item = new;
      assert(item.randomize() with { opcode == `OP_TEST_CPULSE; idle_to_init_write_setup_cycles <= 3; pw_set_cycle <= 3; pw_rst_cycle <= 3; }); // assert uses return val to avoid warn
      drv_mbx.put(item);

      // Test TEST_CYCLE operation
      item = new;
      assert(item.randomize() with { opcode == `OP_CYCLE; max_attempts <= 5; }); // assert uses return val to avoid warn
      drv_mbx.put(item);

      // Test READ operation
      item = new;
      assert(item.randomize() with { opcode == `OP_READ; }); // assert uses return val to avoid warn
      drv_mbx.put(item);
      
      // TODO: other stuff from FSM

      // Test debugging (TODO)

      // Test with ECC on during both WRITE and READ (TODO)

      // Test with ECC off during WRITE but on during READ and make sure it fails (TODO)
    end
  endtask
endclass