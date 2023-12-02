// This is the base transaction object that will be used
// in the environment to initiate new transactions and 
// capture transactions at DUT interface
class spi_slave_rram_tb_pkt;
  // Transaction elements
  rand bit  [`CNFG_REG_ADDR_BITS_N-1:0]     addr;       // Register file address
  rand bit  [`PROG_CNFG_BITS_N-1:0]         wdata;      // Register file write data
  bit       [`PROG_CNFG_BITS_N-1:0]         rdata;      // Register file read data
  bit                                       fsm_go;     // FSM trigger
  rand bit  [`FSM_FULL_STATE_BITS_N-1:0]    fsmdata;    // FSM state data
  rand bit  [`FSM_DIAG_BITS_N-1:0]          diagdata;   // FSM diagnostic data
  rand bit  [`FSM_DIAG_BITS_N-1:0]          diag2data;  // FSM diagnostic data
  rand bit                                  wr;         // Do read if 0, write if 1
  rand bit  [`WORD_SIZE-1:0] readdata [`PROG_CNFG_RANGES_LOG2_N-1:0]; // Read data
  
  // Constrain FSM state to be IDLE
  constraint fsm_state_constraint { fsmdata[`FSM_STATE_BITS_N-1:0] == 0; }
  
  // This function allows us to print contents of the data packet
  // so that it is easier to track in a logfile
  function void print(string tag="");
    $display("T=%0t [%s] addr=%0d wr=%0d wdata=0x%0h rdata=0x%0h", $time, tag, addr, wr, wdata, rdata);
  endfunction
endclass
