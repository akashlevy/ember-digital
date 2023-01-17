// The monitor has a virtual interface handle with which it can monitor
// the events happening on the interface. It sees new transactions and then
// captures information into a packet and sends it to the scoreboard
// using another mailbox.
typedef class fsm_pulse_pkt;
class fsm_read_monitor;
  virtual fsm_if vif;
  mailbox scb_mbx; 		// Mailbox connected to scoreboard

  task run();
    $display("T=%0t [FSM Read Monitor] starting...", $time);
    
    // FIND READ PULSES
    // Check forever at every clock edge to see if there is a 
    // valid read and if yes, capture info into a class
    // object and send it to the scoreboard when the pulse 
    // is over.
    forever begin
      // Create packet to send pulse properties to scoreboard
      fsm_pulse_pkt item;
      item = new;

      // Capture read pulse properties
      @(posedge vif.sa_en);
      item.ti = $time;
      item.wl_dac_config = vif.wl_dac_config;
      item.read_dac_config = vif.read_dac_config;
      item.clamp_ref = vif.clamp_ref;
      item.di = vif.di;
      item.rram_addr = vif.rram_addr;
      item.read_ref = vif.read_ref;
      item.we = vif.we;
      @(posedge vif.sa_rdy);
      item.tf = $time;
      item.sa_do = vif.sa_do;
      
      // Send pulse properties to scoreboard
      scb_mbx.put(item);

      // Debugging display
      if (`DEBUG_PULSES) begin
        item.print("FSM Read Monitor");
      end
    end
  endtask
endclass
