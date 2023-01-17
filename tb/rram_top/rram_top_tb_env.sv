// The environment is a container object simply to hold all verification 
// components together. This environment can then be reused later and all
// components in it would be automatically connected and available for use
// This is an environment without a generator.
typedef class rram_top_driver;
typedef class rram_top_tb_sb;
// typedef class fsm_tb_env;
typedef class spi_slave_rram_tb_env;
class rram_top_tb_env;
  // Testbench components
  rram_top_driver                 d0;       // Driver to design
  rram_top_tb_sb                  s0;       // Scoreboard connected to driver
  mailbox                         scb_mbx;  // Top level mailbox for SCB <-> DRV 
  mailbox                         spi_mbx;  // Top level mailbox for DRV <-> SPI
  mailbox                         fsm_mbx;  // Top level mailbox for DRV <-> FSM
  virtual rram_top_if             vif;      // Virtual interface handle
  virtual spi_slave_rram_if       spi_vif;  // Virtual interface handle
  virtual fsm_if                  fsm_vif;  // Virtual interface handle

  // Other testbench environments to include
  fsm_tb_env                      fsm_env;
  spi_slave_rram_tb_env           spi_env;
  
  // Instantiate all testbench components
  function new();
    d0 = new;
    s0 = new;
    scb_mbx = new;
    spi_mbx = new;
    fsm_mbx = new;
    fsm_env = new;
    spi_env = new;
    fsm_env.d0.drv_mbx = new;
  endfunction
  
  // Assign handles and start all components so that they all become
  // active and wait for transactions to be available
  virtual task run();
    // Connect mailboxes
    d0.scb_mbx = scb_mbx;
    s0.scb_mbx = scb_mbx;
    d0.spi_mbx = spi_mbx;
    d0.fsm_mbx = fsm_mbx;
    spi_env.d0.drv_mbx = spi_mbx;
    fsm_env.drv_scb_mbx = fsm_mbx;

    // Connect VIFs
    d0.vif = vif;
    spi_env.vif = spi_vif;
    fsm_env.vif = fsm_vif;

    fork
      s0.run();
      d0.run();
      spi_env.run();
      fsm_env.run();
    join_any
  endtask
endclass
