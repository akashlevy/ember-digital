// The driver is responsible for driving transactions to the DUT 
// All it does is to get a transaction from the mailbox if it is 
// available and drive it out into the DUT interface.
typedef class bch_dec_tb_pkt;
class bch_dec_driver;
  // Full-clock time
  localparam CLK = 10;
  
  // Maximum packet time
  localparam MAX_PKT_TIME = 10000;

  // Driver components
  virtual bch_dec_if vif;
  event drv_done;
  mailbox drv_mbx;
  mailbox scb_mbx;

  // Read bits with errors
  logic  [`ECC_WORD_SIZE-1:0]   read_bits_w_errs              ;
  logic  [`ECC_RED_N_BITS-1:0]  read_ecc_bits_w_errs          ;
  integer i;
  
  task run();
    // Log driver startup
    $display("T=%0t [ECC Driver] starting...", $time);
    
    // Try to get a new transaction every time and then assign 
    // packet contents to the interface. But do this only if the 
    // design is ready to accept new transactions
    forever begin
      // Get transaction item
      bch_dec_tb_pkt item;
      $display("T=%0t [ECC Driver] waiting for item...", $time);
      if (!drv_mbx.try_get(item)) begin
        -> drv_done; break;
      end
      item.print("ECC Driver");

      // Transfer data to encoder DUT from packet
      vif.write_bits = item.write_bits;
      #CLK;

      // Flip bits
      read_bits_w_errs = item.write_bits;
      read_ecc_bits_w_errs = vif.write_ecc_bits;
      foreach (item.bit_flip_index[i]) begin
        if (i < `ECC_WORD_SIZE) read_bits_w_errs[item.bit_flip_index[i]] = ~read_bits_w_errs[item.bit_flip_index[i]];
        else read_ecc_bits_w_errs[item.bit_flip_index[i] - `ECC_WORD_SIZE] = ~read_ecc_bits_w_errs[item.bit_flip_index[i] - `ECC_WORD_SIZE];
      end
      #CLK;

      // Transfer bit-flipped data to decoder DUT
      vif.read_bits = read_bits_w_errs;
      vif.read_ecc_bits = read_ecc_bits_w_errs;
      #CLK;
      
      // Transfer data from decoder DUT to packet
      item.read_bits = vif.read_bits ^ vif.ecc_msk_o;
      item.ecc_err_det = vif.ecc_err_det;
      #CLK;

      // Forward message to scoreboard
      scb_mbx.put(item);
    end
  endtask
endclass