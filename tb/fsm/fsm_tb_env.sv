// The environment is a container object simply to hold all verification 
// components together. This environment can then be reused later and all
// components in it would be automatically connected and available for use
// This is an environment without a generator.
typedef class fsm_driver;
typedef class fsm_tb_sb;
typedef class fsm_write_monitor;
typedef class fsm_read_monitor;
class fsm_tb_env;
  // Testbench components
  fsm_driver         d0;            // Driver to design
  fsm_tb_sb          s0;            // Scoreboard connected to monitor
  fsm_write_monitor  mw0;           // Monitor for write pulses connected to scoreboard
  fsm_read_monitor   mr0;           // Monitor for write pulses connected to scoreboard
  mailbox            drv_scb_mbx;   // Top level mailbox for DRV -> SCB 
  mailbox            mon_scb_mbx;   // Top level mailbox for MON -> SCB 
  virtual fsm_if     vif;           // Virtual interface handle
  
  // Instantiate all testbench components
  function new();
    d0 = new;
    s0 = new;
    mw0 = new;
    mr0 = new;
    drv_scb_mbx = new;
    mon_scb_mbx = new;
  endfunction
  
  // Assign handles and start all components so that they all become
  // active and wait for transactions to be available
  virtual task run();
    d0.vif = vif;
    mw0.vif = vif;
    mr0.vif = vif;
    s0.mon_mbx = mon_scb_mbx;
    s0.drv_mbx = drv_scb_mbx;
    d0.scb_mbx = drv_scb_mbx;
    mw0.scb_mbx = mon_scb_mbx;
    mr0.scb_mbx = mon_scb_mbx;
    
    fork
      s0.run();
      d0.run();
      mw0.run();
      mr0.run();
    join_any
  endtask
endclass
