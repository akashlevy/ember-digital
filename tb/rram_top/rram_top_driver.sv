// The driver is responsible for driving transactions to the DUT 
// All it does is to get a transaction from the mailbox if it is 
// available and drive it out into the DUT interface.
typedef class fsm_tb_pkt;
typedef class spi_slave_rram_tb_pkt;
class rram_top_driver;
  // Full-clock time
  localparam CLK = 10;

  // Driver components
  virtual rram_top_if vif;
  event drv_done;
  mailbox drv_mbx;
  mailbox scb_mbx;
  mailbox spi_mbx;
  mailbox fsm_mbx;
  
  task run();
    // Log driver startup and some debug
    $display("T=%0t [Top Driver] starting...", $time);
    $display("PROG_CNFG_BITS_N=%0d, MISC_CNFG_BITS_N=%0d, FSM_FULL_STATE_BITS_N=%0d", `PROG_CNFG_BITS_N, `MISC_CNFG_BITS_N, `FSM_FULL_STATE_BITS_N);

    // Wait a few cycles for reset
    #CLK; #CLK; #CLK;

    // Try to get a new transaction every time and then assign 
    // packet contents to the interface. But do this only if the 
    // design is ready to accept new transactions
    forever begin
      // Get transaction item
      fsm_tb_pkt item;
      spi_slave_rram_tb_pkt pkt;
      $display("T=%0t [Top Driver] waiting for item...", $time);
      if (!drv_mbx.try_get(item)) begin
        -> drv_done; break;
      end
      item.print("Top Driver");

      if (item.perform_read) begin
        // Readout READ value with SPI and make sure that works
        for (int addr = 0; addr < 31; addr++) begin
          pkt = new;
          pkt.addr = addr;
          pkt.wr = 0;
          spi_mbx.put(pkt);
        end
        continue;
      end

      // Translate FSM packet into SPI commands below

      // Skip configuration if fast mode is enabled
      if (!item.fast_mode) begin
        // Program each range's settings
        for (int i = 0; i <= `PROG_CNFG_RANGES_LOG2_N'(item.num_levels-1); i++) begin
          pkt = new;
          pkt.addr = i;
          pkt.wdata = {item.loop_order_rst[i], item.pw_rst_step[i], item.pw_rst_stop[i], item.pw_rst_start[i], item.wl_dac_rst_lvl_step[i], item.wl_dac_rst_lvl_stop[i], item.wl_dac_rst_lvl_start[i], item.sl_dac_rst_lvl_step[i], item.sl_dac_rst_lvl_stop[i], item.sl_dac_rst_lvl_start[i], item.loop_order_set[i], item.pw_set_step[i], item.pw_set_stop[i], item.pw_set_start[i], item.wl_dac_set_lvl_step[i], item.wl_dac_set_lvl_stop[i], item.wl_dac_set_lvl_start[i], item.bl_dac_set_lvl_step[i], item.bl_dac_set_lvl_stop[i], item.bl_dac_set_lvl_start[i], item.adc_upper_write_ref_lvl[i], item.adc_lower_write_ref_lvl[i], item.adc_upper_read_ref_lvl[i], item.adc_read_dac_lvl[i], item.adc_clamp_ref_lvl[i]};
          pkt.wr = 1;
          spi_mbx.put(pkt);
        end
      end

      // Program miscellaneous global configuration bits
      pkt = new;
      pkt.addr = `PROG_CNFG_RANGES_N;
      pkt.wdata = {item.post_read_setup_cycles, item.step_write_setup_cycles, item.step_read_setup_cycles, item.write_to_init_read_setup_cycles, item.read_to_init_write_setup_cycles, item.idle_to_init_read_setup_cycles, item.idle_to_init_write_setup_cycles, item.all_dacs_on, item.ignore_failures, item.di_init_mask, item.set_first, item.pw_rst_cycle, item.wl_dac_rst_lvl_cycle, item.sl_dac_rst_lvl_cycle, item.pw_set_cycle, item.wl_dac_set_lvl_cycle, item.bl_dac_set_lvl_cycle, item.num_levels, item.use_ecc, item.max_attempts};
      pkt.wr = 1;
      spi_mbx.put(pkt);

      // Skip configuration if fast mode is enabled
      if (!item.fast_mode) begin
        // Program address bits
        pkt = new;
        pkt.addr = `PROG_CNFG_RANGES_N + 1;
        pkt.wdata = {item.address_step, item.address_stop, item.address_start};
        pkt.wr = 1;
        spi_mbx.put(pkt);

        // Program each write data register
        for (int i = `PROG_CNFG_RANGES_N + 2; i < `PROG_CNFG_RANGES_N + 6; i++) begin
          pkt = new;
          pkt.addr = i;
          pkt.wdata = item.write_data_bits[i];
          pkt.wr = 1;
          spi_mbx.put(pkt);
        end
      end

      // FSM command
      pkt = new;
      pkt.addr = `PROG_CNFG_RANGES_N + 6;
      pkt.wdata = {item.use_multi_addrs, item.opcode};
      pkt.wr = 1;
      spi_mbx.put(pkt);

      // Wait for FSM to start, and update packet time
      @(posedge vif.rram_busy) $display("T=%0t [Top Driver] FSM went from idle to busy...", $time);
      item.ti = $time;

      // Wait for FSM to finish, update packet time, then forward item to FSM
      @(negedge vif.rram_busy) $display("T=%0t [Top Driver] FSM went from busy to idle...", $time);
      item.tf = $time;
      fsm_mbx.put(item);
    end
  endtask
endclass
