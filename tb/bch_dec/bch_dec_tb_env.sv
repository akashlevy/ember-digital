// The environment is a container object simply to hold all verification 
// components together. This environment can then be reused later and all
// components in it would be automatically connected and available for use
// This is an environment without a generator.
typedef class bch_dec_driver;
typedef class bch_dec_tb_sb;
class bch_dec_tb_env;
  // Testbench components
  bch_dec_driver         d0;            // Driver to design
  bch_dec_tb_sb          s0;            // Scoreboard connected to monitor
  mailbox                scb_mbx;       // Top level mailbox for DRV -> SCB 
  virtual bch_dec_if     vif;           // Virtual interface handle
  
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
    s0.scb_mbx = scb_mbx;
    d0.scb_mbx = scb_mbx;
    
    fork
      s0.run();
      d0.run();
    join_any
  endtask
endclass
