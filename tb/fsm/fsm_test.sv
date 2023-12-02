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

    // Test WRITE operation 
    for (int i = 0; i < 100; i++) begin
      item = new;
      assert(item.randomize() with { opcode == `OP_WRITE; }); // assert uses return val to avoid warn
      drv_mbx.put(item);
    end
  endtask
endclass
