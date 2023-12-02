// This is the base transaction object that will be used
// in the environment to initiate new transactions and 
// capture transactions at DUT interface
class lfsr_tb_pkt;
  // Transaction elements
  rand bit enable;

  // Result elements
  bit [`WORD_SIZE-1:0] data_out;

  // Metadata
  time t;

  // This function allows us to print contents of the data packet
  // so that it is easier to track in a logfile
  function void print(string tag="");
    $display("T=%0t [%s] enable=%0b data_out=%48b", $time, tag, enable, data_out);
  endfunction
endclass
