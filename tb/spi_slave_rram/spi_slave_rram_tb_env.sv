// The environment is a container object simply to hold all verification 
// components together. This environment can then be reused later and all
// components in it would be automatically connected and available for use
// This is an environment without a generator.
typedef class spi_slave_rram_driver;
typedef class spi_slave_rram_tb_sb;
class spi_slave_rram_tb_env;
  // Testbench components
  spi_slave_rram_driver         d0;       // Driver to design
  spi_slave_rram_tb_sb          s0;       // Scoreboard connected to driver
  mailbox                       scb_mbx;  // Top level mailbox for SCB <-> DRV 
  virtual spi_slave_rram_if     vif;      // Virtual interface handle
  
  // Instantiate all testbench components
  function new();
    d0 = new;
    s0 = new;
    scb_mbx = new;
  endfunction
  
  // Assign handles and start all components so that they all become
  // active and wait for transactions to be available
  virtual task run();
    d0.vif = vif;
    d0.scb_mbx = scb_mbx;
    s0.scb_mbx = scb_mbx;
    
    fork
      s0.run();
      d0.run();
    join_any
  endtask
endclass
