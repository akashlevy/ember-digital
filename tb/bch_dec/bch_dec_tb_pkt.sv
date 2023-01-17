// This is the base transaction object that will be used
// in the environment to initiate new transactions and 
// capture transactions at DUT interface
class bch_dec_tb_pkt;
  // Transaction elements
  rand bit [`ECC_WORD_SIZE-1:0] write_bits;
  rand bit [`WORD_SIZE_LOG2-1:0] bit_flip_index [];
  rand integer n_bit_flips;

  // Results
  logic  [`ECC_WORD_SIZE-1:0]   read_bits               ;
  logic                         ecc_err_det             ;

  // Constrain bit flip indices
  constraint bit_flip_index_constraints {
    // Size of bit flip index array is number of bit flips
    bit_flip_index.size() == n_bit_flips;

    // Constrain the bit_flip_indices to be within range and unique
    foreach (bit_flip_index[i]) {
      foreach (bit_flip_index[j]) {
        (i != j) -> bit_flip_index[i] != bit_flip_index[j];
      }
      bit_flip_index[i] < `WORD_SIZE;
    }
  }

  // This function allows us to print contents of the data packet
  // so that it is easier to track in a logfile
  function void print(string tag="");
    $display("T=%0t [%s] data=0x%0h nflips=%0d", $time, tag, write_bits, n_bit_flips);
  endfunction
endclass
