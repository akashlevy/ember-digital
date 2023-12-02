// The driver is responsible for driving transactions to the DUT 
// All it does is to get a transaction from the mailbox if it is 
// available and drive it out into the DUT interface.
typedef class fsm_tb_pkt;
class fsm_driver;
  // Full-clock time
  localparam CLK = 10;
  
  // Maximum packet time
  localparam MAX_PKT_TIME = 10000;

  // Driver components
  virtual fsm_if vif;
  event drv_done;
  mailbox drv_mbx;
  mailbox scb_mbx;
  
  task run();
    // Log driver startup
    $display("T=%0t [FSM Driver] starting...", $time);
    
    // Try to get a new transaction every time and then assign 
    // packet contents to the interface. But do this only if the 
    // design is ready to accept new transactions
    forever begin
      // Get transaction item
      fsm_tb_pkt item;
      $display("T=%0t [FSM Driver] waiting for item...", $time);
      if (!drv_mbx.try_get(item)) begin
        -> drv_done; break;
      end
      item.print("FSM Driver");

      // Transfer data from packet to DUT
      vif.address_start = item.address_start;
      vif.address_stop = item.address_stop;
      vif.address_step = item.address_step;
      vif.max_attempts = item.max_attempts;
      vif.use_ecc = item.use_ecc;
      vif.num_levels = item.num_levels;
      vif.bl_dac_set_lvl_cycle = item.bl_dac_set_lvl_cycle;
      vif.wl_dac_set_lvl_cycle = item.wl_dac_set_lvl_cycle;
      vif.pw_set_cycle = item.pw_set_cycle;
      vif.sl_dac_rst_lvl_cycle = item.sl_dac_rst_lvl_cycle;
      vif.wl_dac_rst_lvl_cycle = item.wl_dac_rst_lvl_cycle;
      vif.pw_rst_cycle = item.pw_rst_cycle;
      vif.set_first = item.set_first;
      vif.di_init_mask = item.di_init_mask;
      vif.ignore_failures = item.ignore_failures;
      vif.all_dacs_on = item.all_dacs_on;
      vif.idle_to_init_write_setup_cycles = item.idle_to_init_write_setup_cycles;
      vif.idle_to_init_read_setup_cycles = item.idle_to_init_read_setup_cycles;
      vif.read_to_init_write_setup_cycles = item.read_to_init_write_setup_cycles;
      vif.write_to_init_read_setup_cycles = item.write_to_init_read_setup_cycles;
      vif.step_read_setup_cycles = item.step_read_setup_cycles;
      vif.step_write_setup_cycles = item.step_write_setup_cycles;
      vif.post_read_setup_cycles = item.post_read_setup_cycles;
      vif.opcode = item.opcode;
      vif.use_multi_addrs = item.use_multi_addrs;
      vif.use_lfsr_data = item.use_lfsr_data;
      vif.use_cb_data = item.use_cb_data;
      vif.check63 = item.check63;
      vif.loop_mode = item.loop_mode;
      
      vif.write_data_bits = item.write_data_bits;

      // NOTE: ```(vif.rangei === 'x) ? 0 : vif.rangei``` fixes invalid rangei
      vif.adc_clamp_ref_lvl = item.adc_clamp_ref_lvl[(vif.rangei === 'x) ? 0 : vif.rangei];
      vif.adc_read_dac_lvl = item.adc_read_dac_lvl[(vif.rangei === 'x) ? 0 : vif.rangei];
      vif.adc_upper_read_ref_lvl = item.adc_upper_read_ref_lvl[(vif.rangei === 'x) ? 0 : vif.rangei];
      vif.adc_lower_write_ref_lvl = item.adc_lower_write_ref_lvl[(vif.rangei === 'x) ? 0 : vif.rangei];
      vif.adc_upper_write_ref_lvl = item.adc_upper_write_ref_lvl[(vif.rangei === 'x) ? 0 : vif.rangei];
      vif.bl_dac_set_lvl_start = item.bl_dac_set_lvl_start[(vif.rangei === 'x) ? 0 : vif.rangei];
      vif.bl_dac_set_lvl_stop = item.bl_dac_set_lvl_stop[(vif.rangei === 'x) ? 0 : vif.rangei];
      vif.bl_dac_set_lvl_step = item.bl_dac_set_lvl_step[(vif.rangei === 'x) ? 0 : vif.rangei];
      vif.wl_dac_set_lvl_start = item.wl_dac_set_lvl_start[(vif.rangei === 'x) ? 0 : vif.rangei];
      vif.wl_dac_set_lvl_stop = item.wl_dac_set_lvl_stop[(vif.rangei === 'x) ? 0 : vif.rangei];
      vif.wl_dac_set_lvl_step = item.wl_dac_set_lvl_step[(vif.rangei === 'x) ? 0 : vif.rangei];
      vif.pw_set_start = item.pw_set_start[(vif.rangei === 'x) ? 0 : vif.rangei];
      vif.pw_set_stop = item.pw_set_stop[(vif.rangei === 'x) ? 0 : vif.rangei];
      vif.pw_set_step = item.pw_set_step[(vif.rangei === 'x) ? 0 : vif.rangei];
      vif.loop_order_set = item.loop_order_set[(vif.rangei === 'x) ? 0 : vif.rangei];
      vif.sl_dac_rst_lvl_start = item.sl_dac_rst_lvl_start[(vif.rangei === 'x) ? 0 : vif.rangei];
      vif.sl_dac_rst_lvl_stop = item.sl_dac_rst_lvl_stop[(vif.rangei === 'x) ? 0 : vif.rangei];
      vif.sl_dac_rst_lvl_step = item.sl_dac_rst_lvl_step[(vif.rangei === 'x) ? 0 : vif.rangei];
      vif.wl_dac_rst_lvl_start = item.wl_dac_rst_lvl_start[(vif.rangei === 'x) ? 0 : vif.rangei];
      vif.wl_dac_rst_lvl_stop = item.wl_dac_rst_lvl_stop[(vif.rangei === 'x) ? 0 : vif.rangei];
      vif.wl_dac_rst_lvl_step = item.wl_dac_rst_lvl_step[(vif.rangei === 'x) ? 0 : vif.rangei];
      vif.pw_rst_start = item.pw_rst_start[(vif.rangei === 'x) ? 0 : vif.rangei];
      vif.pw_rst_stop = item.pw_rst_stop[(vif.rangei === 'x) ? 0 : vif.rangei];
      vif.pw_rst_step = item.pw_rst_step[(vif.rangei === 'x) ? 0 : vif.rangei];
      vif.loop_order_rst = item.loop_order_rst[(vif.rangei === 'x) ? 0 : vif.rangei];

      // Disable FSM trigger
      vif.fsm_go = 0;

      // Reset
      #CLK
      #CLK
      vif.rst_n = 1;

      // One clock period in IDLE
      #CLK

      // Trigger FSM
      vif.fsm_go = 1;
      #CLK
      vif.fsm_go = 0;

      // Wait until out of IDLE state
      @(vif.rram_busy);
      
      // Record start time
      item.ti = $time;

      // Update range-dependent packet contents continuously
      while (1) begin
        // Tick the clock
        @(vif.fsm_state, vif.rangei);

        // Update range-dependent packet contents
        vif.adc_clamp_ref_lvl = item.adc_clamp_ref_lvl[vif.rangei];
        vif.adc_read_dac_lvl = item.adc_read_dac_lvl[vif.rangei];
        vif.adc_upper_read_ref_lvl = item.adc_upper_read_ref_lvl[vif.rangei];
        vif.adc_lower_write_ref_lvl = item.adc_lower_write_ref_lvl[vif.rangei];
        vif.adc_upper_write_ref_lvl = item.adc_upper_write_ref_lvl[vif.rangei];
        vif.bl_dac_set_lvl_start = item.bl_dac_set_lvl_start[vif.rangei];
        vif.bl_dac_set_lvl_stop = item.bl_dac_set_lvl_stop[vif.rangei];
        vif.bl_dac_set_lvl_step = item.bl_dac_set_lvl_step[vif.rangei];
        vif.wl_dac_set_lvl_start = item.wl_dac_set_lvl_start[vif.rangei];
        vif.wl_dac_set_lvl_stop = item.wl_dac_set_lvl_stop[vif.rangei];
        vif.wl_dac_set_lvl_step = item.wl_dac_set_lvl_step[vif.rangei];
        vif.pw_set_start = item.pw_set_start[vif.rangei];
        vif.pw_set_stop = item.pw_set_stop[vif.rangei];
        vif.pw_set_step = item.pw_set_step[vif.rangei];
        vif.loop_order_set = item.loop_order_set[vif.rangei];
        vif.sl_dac_rst_lvl_start = item.sl_dac_rst_lvl_start[vif.rangei];
        vif.sl_dac_rst_lvl_stop = item.sl_dac_rst_lvl_stop[vif.rangei];
        vif.sl_dac_rst_lvl_step = item.sl_dac_rst_lvl_step[vif.rangei];
        vif.wl_dac_rst_lvl_start = item.wl_dac_rst_lvl_start[vif.rangei];
        vif.wl_dac_rst_lvl_stop = item.wl_dac_rst_lvl_stop[vif.rangei];
        vif.wl_dac_rst_lvl_step = item.wl_dac_rst_lvl_step[vif.rangei];
        vif.pw_rst_start = item.pw_rst_start[vif.rangei];
        vif.pw_rst_stop = item.pw_rst_stop[vif.rangei];
        vif.pw_rst_step = item.pw_rst_step[vif.rangei];
        vif.loop_order_rst = item.loop_order_rst[vif.rangei];

        // Allow completion of task when in IDLE state
        if (!vif.rram_busy) break;
      end

      // Forward message to scoreboard
      item.tf = $time;
      item.read_data_bits = vif.read_data_bits;
      item.g = vif.g;
      scb_mbx.put(item);

      // Two clocks to finish off
      #CLK #CLK;
    end
  endtask
endclass
