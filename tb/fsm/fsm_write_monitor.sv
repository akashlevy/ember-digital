// The monitor has a virtual interface handle with which it can monitor
// the events happening on the interface. It sees new transactions and then
// captures information into a packet and sends it to the scoreboard
// using another mailbox.
typedef class fsm_pulse_pkt;
class fsm_write_monitor;
  // Full-clock time
  localparam CLK = 10;

  // Virtual interface and mailbox
  virtual fsm_if vif;
  mailbox scb_mbx; 		// Mailbox connected to scoreboard

  task run();
    $display("T=%0t [FSM Write Monitor] starting...", $time);
    
    // FIND WRITE PULSES
    // Check forever at every clock edge to see if there is a 
    // valid write and if yes, capture info into a class
    // object and send it to the scoreboard when the pulse 
    // is over.
    forever begin
      // Create packet to send pulse properties to scoreboard
      fsm_pulse_pkt item;
      item = new;

      // Capture write pulse properties
      @(posedge vif.aclk);
      item.ti = $time;
      item.bsl_dac_config = vif.bsl_dac_config;
      item.wl_dac_config = vif.wl_dac_config;
      item.set_rst = vif.set_rst;
      item.di = vif.di;
      item.rram_addr = vif.rram_addr;
      item.we = vif.we;
      @(negedge vif.aclk);
      item.tf = $time;
      item.pw = (item.tf - item.ti) / CLK;
      
      // Send pulse properties to scoreboard
      scb_mbx.put(item);

      // Debugging display
      if (`DEBUG_PULSES) begin
        item.print("FSM Write Monitor");
      end
    end
  endtask
endclass
