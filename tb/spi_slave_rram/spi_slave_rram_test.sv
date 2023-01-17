// An environment without the generator and hence the stimulus should be 
// written in the test.
typedef class spi_slave_rram_tb_env;
typedef class spi_slave_rram_tb_pkt;
class spi_slave_rram_test;
  // Test components
  spi_slave_rram_tb_env e0;
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
    spi_slave_rram_tb_pkt item;

    // Log start of test
    $display("T=%0t [SPI Test] Starting test...", $time);

    // Test reset values of all registers
    for (int i = 0; i < `PROG_CNFG_RANGES_LOG2_N + `PROG_CNFG_RANGES_N + 3; i++) begin
      item = new;
      assert(item.randomize() with { addr == i; wr == 0; }); // assert uses return val to avoid warn
      drv_mbx.put(item);
    end

    // Write values to all registers
    for (int i = 0; i < `PROG_CNFG_RANGES_LOG2_N + `PROG_CNFG_RANGES_N + 3; i++) begin
      item = new;
      assert(item.randomize() with { addr == i; wr == 1; }); // assert uses return val to avoid warn
      drv_mbx.put(item);
    end

    // Read all registers
    for (int i = 0; i < 2**`CNFG_REG_ADDR_BITS_N; i++) begin
      item = new;
      assert(item.randomize() with { addr == i; wr == 0; }); // assert uses return val to avoid warn
      drv_mbx.put(item);
    end

    // Write to the reset register
    item = new;
    assert(item.randomize() with { addr == 31; wr == 1; }); // assert uses return val to avoid warn
    drv_mbx.put(item);

    // Read all registers
    for (int i = 0; i < 2**`CNFG_REG_ADDR_BITS_N; i++) begin
      item = new;
      assert(item.randomize() with { addr == i; wr == 0; }); // assert uses return val to avoid warn
      drv_mbx.put(item);
    end
  endtask
endclass