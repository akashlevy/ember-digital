// An environment without the generator and hence the stimulus should be 
// written in the test.
typedef class cb_tb_env;
typedef class cb_tb_pkt;
class cb_test;
  // Test components
  cb_tb_env e0;
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
    cb_tb_pkt item;

    // Log start of test
    $display("T=%0t [CB Test] Starting test...", $time);

    // Iterate testing with no errors
    for (int i = 0; i < 200000; i++) begin
      // Test data
      item = new;
      assert(item.randomize());
      drv_mbx.put(item);
    end
  endtask
endclass