// An environment without the generator and hence the stimulus should be 
// written in the test.
typedef class bch_dec_tb_env;
typedef class bch_dec_tb_pkt;
class bch_dec_test;
  // Test components
  bch_dec_tb_env e0;
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
    bch_dec_tb_pkt item;

    // Log start of test
    $display("T=%0t [ECC Test] Starting test...", $time);

    // Iterate testing with no errors
    for (int i = 0; i < 1000; i++) begin
      // Test no errors
      item = new;
      assert(item.randomize() with { n_bit_flips == 0; }); // assert uses return val to avoid warn
      drv_mbx.put(item);

      // Test one error (correctable)
      item = new;
      assert(item.randomize() with { n_bit_flips == 1; }); // assert uses return val to avoid warn
      drv_mbx.put(item);

      // Test two errors (correctable)
      item = new;
      assert(item.randomize() with { n_bit_flips == 2; }); // assert uses return val to avoid warn
      drv_mbx.put(item);

      // Test ten errors (very unlikely to be undetectable)
      item = new;
      assert(item.randomize() with { n_bit_flips == 10; }); // assert uses return val to avoid warn
      drv_mbx.put(item);
    end
  endtask
endclass