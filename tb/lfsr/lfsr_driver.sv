// The driver is responsible for driving transactions to the DUT 
// All it does is to get a transaction from the mailbox if it is 
// available and drive it out into the DUT interface.
typedef class lfsr_tb_pkt;
class lfsr_driver;
  // Full-clock time
  localparam CLK = 10;
  
  // Maximum packet time
  localparam MAX_PKT_TIME = 10000;

  // Driver components
  virtual lfsr_if vif;
  event drv_done;
  mailbox drv_mbx;
  mailbox scb_mbx;

  task run();
    // Log driver startup
    $display("T=%0t [LFSR Driver] starting...", $time);

    // Reset the DUT
    vif.rst = 0; #CLK;
    vif.rst = 1; #CLK #CLK #CLK;
    vif.rst = 0; #CLK #CLK #CLK;
    
    // Try to get a new transaction every time and then assign 
    // packet contents to the interface. But do this only if the 
    // design is ready to accept new transactions
    forever begin
      // Get transaction item
      lfsr_tb_pkt item;
      $display("T=%0t [LFSR Driver] waiting for item...", $time);
      if (!drv_mbx.try_get(item)) begin
        -> drv_done; break;
      end
      item.print("LFSR Driver");

      // Transfer data to DUT from packet
      vif.enable = item.enable;
      #CLK;

      // Transfer data from DUT to packet
      item.t = $time;
      item.data_out = vif.data_out;

      // Forward message to scoreboard
      scb_mbx.put(item);
    end
  endtask
endclass