// This is the base transaction object that will be used
// in the environment to initiate new transactions and 
// capture transactions at DUT interface
class cb_tb_pkt;
  // Transaction elements
  rand bit enable;
  rand bit [`PROG_CNFG_RANGES_LOG2_N-1:0] num_levels;

  // Result elements
  bit [`WORD_SIZE-1:0] data_out [`PROG_CNFG_RANGES_LOG2_N-1:0];

  // Metadata
  time t;

  // Number of levels must be a power of 2
  constraint num_levels_constraint {
    (num_levels == 0) || (num_levels == 8) || (num_levels == 4) || (num_levels == 2);
  }

  // This function allows us to print contents of the data packet
  // so that it is easier to track in a logfile
  function void print(string tag="");
    $display("T=%0t [%s] enable=%0b data_out=%48b,%48b,%48b,%48b", $time, tag, enable, data_out[0], data_out[1], data_out[2], data_out[3]);
  endfunction
endclass
