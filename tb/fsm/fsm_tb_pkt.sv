// This is the base transaction object that will be used
// in the environment to initiate new transactions and 
// capture transactions at DUT interface
class fsm_tb_pkt;
  // Address elements
  rand bit  [`ADDR_BITS_N-1:0]              address_start;
  rand bit  [`ADDR_BITS_N-1:0]              address_stop;
  rand bit  [`ADDR_BITS_N-1:0]              address_step;

  // Opcode
  rand bit  [`OP_CODE_BITS_N-1:0]           opcode;
  rand bit                                  use_multi_addrs;
  rand bit                                  use_lfsr_data;
  rand bit                                  use_cb_data;
  rand bit                                  check63;
  rand bit                                  loop_mode;

  // Read and write data bits
  bit       [`WORD_SIZE-1:0]                read_data_bits  [`PROG_CNFG_RANGES_LOG2_N-1:0];
  rand bit  [`WORD_SIZE-1:0]                write_data_bits [`PROG_CNFG_RANGES_LOG2_N-1:0];

  // Global parameters from register array
  rand bit  [`MAX_ATTEMPTS_BITS_N-1:0]      max_attempts;
  rand bit                                  use_ecc;
  rand bit  [`PROG_CNFG_RANGES_LOG2_N-1:0]  num_levels;
  rand bit  [`BSL_DAC_BITS_N-1:0]           bl_dac_set_lvl_cycle;
  rand bit  [`WL_DAC_BITS_N-1:0]            wl_dac_set_lvl_cycle;
  rand bit  [`PW_BITS_N-1:0]                pw_set_cycle;
  rand bit  [`BSL_DAC_BITS_N-1:0]           sl_dac_rst_lvl_cycle;
  rand bit  [`WL_DAC_BITS_N-1:0]            wl_dac_rst_lvl_cycle;
  rand bit  [`PW_BITS_N-1:0]                pw_rst_cycle;
  rand bit                                  set_first;
  rand bit  [`WORD_SIZE-1:0]                di_init_mask;
  rand bit                                  ignore_failures;
  rand bit                                  all_dacs_on;
  rand bit  [`SETUP_CYC_BITS_N-1:0]         idle_to_init_write_setup_cycles;
  rand bit  [`SETUP_CYC_BITS_N-1:0]         idle_to_init_read_setup_cycles;
  rand bit  [`SETUP_CYC_BITS_N-1:0]         read_to_init_write_setup_cycles;
  rand bit  [`SETUP_CYC_BITS_N-1:0]         write_to_init_read_setup_cycles;
  rand bit  [`SETUP_CYC_BITS_N-1:0]         step_read_setup_cycles;
  rand bit  [`SETUP_CYC_BITS_N-1:0]         step_write_setup_cycles;
  rand bit  [`SETUP_CYC_BITS_N-1:0]         post_read_setup_cycles;

  // Programming parameters from register array
  rand bit  [`ADC_BITS_N-1:0]                   adc_clamp_ref_lvl [];
  rand bit  [`READ_DAC_BITS_N-1:0]              adc_read_dac_lvl [];
  rand bit  [`ADC_BITS_N-1:0]                   adc_upper_read_ref_lvl [];
  rand bit  [`ADC_BITS_N-1:0]                   adc_lower_write_ref_lvl [];
  rand bit  [`ADC_BITS_N-1:0]                   adc_upper_write_ref_lvl [];
  rand bit  [`BSL_DAC_BITS_N-1:0]               bl_dac_set_lvl_start [];
  rand bit  [`BSL_DAC_BITS_N-1:0]               bl_dac_set_lvl_stop [];
  rand bit  [`BSL_DAC_BITS_N-1:0]               bl_dac_set_lvl_step [];
  rand bit  [`WL_DAC_BITS_N-1:0]                wl_dac_set_lvl_start [];
  rand bit  [`WL_DAC_BITS_N-1:0]                wl_dac_set_lvl_stop [];
  rand bit  [`WL_DAC_BITS_N-1:0]                wl_dac_set_lvl_step [];
  rand bit  [`PW_BITS_N-1:0]                    pw_set_start [];
  rand bit  [`PW_BITS_N-1:0]                    pw_set_stop [];
  rand bit  [`PW_BITS_N-1:0]                    pw_set_step [];
  rand bit  [`LOOP_BITS_N-1:0]                  loop_order_set [];
  rand bit  [`BSL_DAC_BITS_N-1:0]               sl_dac_rst_lvl_start [];
  rand bit  [`BSL_DAC_BITS_N-1:0]               sl_dac_rst_lvl_stop [];
  rand bit  [`BSL_DAC_BITS_N-1:0]               sl_dac_rst_lvl_step [];
  rand bit  [`WL_DAC_BITS_N-1:0]                wl_dac_rst_lvl_start [];
  rand bit  [`WL_DAC_BITS_N-1:0]                wl_dac_rst_lvl_stop [];
  rand bit  [`WL_DAC_BITS_N-1:0]                wl_dac_rst_lvl_step [];
  rand bit  [`PW_BITS_N-1:0]                    pw_rst_start [];
  rand bit  [`PW_BITS_N-1:0]                    pw_rst_stop [];
  rand bit  [`PW_BITS_N-1:0]                    pw_rst_step [];
  rand bit  [`LOOP_BITS_N-1:0]                  loop_order_rst [];

  // Start and end time of operation for scoreboard
  time ti;
  time tf;

  // Fast mode (in top level test bench, do not configure any SPI stuff)
  bit fast_mode;

  // Perform SPI readout and do nothing else
  bit perform_read;

  // Behavioral model conductance
  bit [`ADC_BITS_N-1:0] g [`NUM_WORDS-1:0][`WORD_SIZE-1:0];

  // Do not loop
  constraint no_loop {
    loop_mode == 0;
  }

  // Number of levels randomization constraints
  constraint num_levels_constraints {
    // Cannot be one level (NOTE: num_levels == 0 is actually 16 levels)
    num_levels != 1;
    (use_lfsr_data || use_cb_data) -> (num_levels == 0) || (num_levels == 2) || (num_levels == 4) || (num_levels == 8);
    use_lfsr_data -> !use_cb_data;
  }

  // Constrain settings to be configured based on the number of levels
  constraint size_constraints {
    adc_clamp_ref_lvl.size() == ((num_levels == 0) ? `PROG_CNFG_RANGES_N : num_levels);
    adc_read_dac_lvl.size() == ((num_levels == 0) ? `PROG_CNFG_RANGES_N : num_levels);
    adc_upper_read_ref_lvl.size() == ((num_levels == 0) ? `PROG_CNFG_RANGES_N : num_levels);
    adc_lower_write_ref_lvl.size() == ((num_levels == 0) ? `PROG_CNFG_RANGES_N : num_levels);
    adc_upper_write_ref_lvl.size() == ((num_levels == 0) ? `PROG_CNFG_RANGES_N : num_levels);
    bl_dac_set_lvl_start.size() == ((num_levels == 0) ? `PROG_CNFG_RANGES_N : num_levels);
    bl_dac_set_lvl_stop.size() == ((num_levels == 0) ? `PROG_CNFG_RANGES_N : num_levels);
    bl_dac_set_lvl_step.size() == ((num_levels == 0) ? `PROG_CNFG_RANGES_N : num_levels);
    wl_dac_set_lvl_start.size() == ((num_levels == 0) ? `PROG_CNFG_RANGES_N : num_levels);
    wl_dac_set_lvl_stop.size() == ((num_levels == 0) ? `PROG_CNFG_RANGES_N : num_levels);
    wl_dac_set_lvl_step.size() == ((num_levels == 0) ? `PROG_CNFG_RANGES_N : num_levels);
    pw_set_start.size() == ((num_levels == 0) ? `PROG_CNFG_RANGES_N : num_levels);
    pw_set_stop.size() == ((num_levels == 0) ? `PROG_CNFG_RANGES_N : num_levels);
    pw_set_step.size() == ((num_levels == 0) ? `PROG_CNFG_RANGES_N : num_levels);
    loop_order_set.size() == ((num_levels == 0) ? `PROG_CNFG_RANGES_N : num_levels);
    sl_dac_rst_lvl_start.size() == ((num_levels == 0) ? `PROG_CNFG_RANGES_N : num_levels);
    sl_dac_rst_lvl_stop.size() == ((num_levels == 0) ? `PROG_CNFG_RANGES_N : num_levels);
    sl_dac_rst_lvl_step.size() == ((num_levels == 0) ? `PROG_CNFG_RANGES_N : num_levels);
    wl_dac_rst_lvl_start.size() == ((num_levels == 0) ? `PROG_CNFG_RANGES_N : num_levels);
    wl_dac_rst_lvl_stop.size() == ((num_levels == 0) ? `PROG_CNFG_RANGES_N : num_levels);
    wl_dac_rst_lvl_step.size() == ((num_levels == 0) ? `PROG_CNFG_RANGES_N : num_levels);
    pw_rst_start.size() == ((num_levels == 0) ? `PROG_CNFG_RANGES_N : num_levels);
    pw_rst_stop.size() == ((num_levels == 0) ? `PROG_CNFG_RANGES_N : num_levels);
    pw_rst_step.size() == ((num_levels == 0) ? `PROG_CNFG_RANGES_N : num_levels);
    loop_order_rst.size() == ((num_levels == 0) ? `PROG_CNFG_RANGES_N : num_levels);
  }

  // Constraint on write data bits
  constraint write_data_bits_constraints {
    foreach (write_data_bits[0][i]) {
      {write_data_bits[3][i], write_data_bits[2][i], write_data_bits[1][i], write_data_bits[0][i]} < ((num_levels == 0) ? `PROG_CNFG_RANGES_N : num_levels);
    }
  }

  // ADC level allocation randomization constraints
  constraint adc_level_allocation_constraints {
    // Upper read ref level of highest level should always be maximum
    adc_upper_read_ref_lvl[`PROG_CNFG_RANGES_LOG2_N'(num_levels-1)] == {`ADC_BITS_N{1'b1}};

    // Constrain the ADC reference levels to be ordered correctly
    foreach (adc_upper_read_ref_lvl[i]) {
      adc_upper_read_ref_lvl[i] > adc_upper_write_ref_lvl[i];
      adc_upper_write_ref_lvl[i] > adc_lower_write_ref_lvl[i];
      (i != 0) -> adc_lower_write_ref_lvl[i] > adc_upper_read_ref_lvl[i-1];
    }
  }

  // BL DAC SET level randomization constraints
  constraint bl_dac_set_lvl_constraints {
    foreach (bl_dac_set_lvl_start[i]) {
      // Constrain bl_dac_set_lvl_stop to be a multiple of bl_dac_set_lvl_step greater than bl_dac_set_lvl_start
      (bl_dac_set_lvl_stop[i] - bl_dac_set_lvl_start[i]) % bl_dac_set_lvl_step[i] == 0;
      (bl_dac_set_lvl_stop[i] - bl_dac_set_lvl_start[i]) >= bl_dac_set_lvl_step[i];
      bl_dac_set_lvl_stop[i] > bl_dac_set_lvl_start[i];

      // Constrain total number of steps to not be too large
      bl_dac_set_lvl_stop[i] <= bl_dac_set_lvl_start[i] + bl_dac_set_lvl_step[i] * 10;
    }
  }

  // WL DAC SET level randomization constraints
  constraint wl_dac_set_lvl_constraints {
    foreach (wl_dac_set_lvl_start[i]) {
      // Constrain wl_dac_set_lvl_stop to be a multiple of wl_dac_set_lvl_step greater than wl_dac_set_lvl_start
      (wl_dac_set_lvl_stop[i] - wl_dac_set_lvl_start[i]) % wl_dac_set_lvl_step[i] == 0;
      (wl_dac_set_lvl_stop[i] - wl_dac_set_lvl_start[i]) >= wl_dac_set_lvl_step[i];
      wl_dac_set_lvl_stop[i] > wl_dac_set_lvl_start[i];

      // Constrain total number of steps to not be too large
      wl_dac_set_lvl_stop[i] <= wl_dac_set_lvl_start[i] + wl_dac_set_lvl_step[i] * 10;
    }
  }

  // // SET pulse width randomization constraints
  // constraint pw_set_constraints {
  //   foreach (pw_set_start[i]) {
  //     // Constrain pw_set_stop to be a multiple of pw_set_step greater than pw_set_start
  //     (`defloat(pw_set_stop[i]) - `defloat(pw_set_start[i])) % `defloat(pw_set_step[i]) == 0;
  //     (`defloat(pw_set_stop[i]) - `defloat(pw_set_start[i])) >= `defloat(pw_set_step[i]);
  //     `defloat(pw_set_stop[i]) > `defloat(pw_set_start[i]);

  //     // Constrain total number of steps to not be too large
  //     `defloat(pw_set_stop[i]) <= `defloat(pw_set_start[i]) + `defloat(pw_set_step[i]) * 10;

  //     // Constrain PW to not be too large
  //     `defloat(pw_set_stop[i]) < 10;
  //   }
  // }

  // SET pulse width randomization constraints
  constraint pw_set_constraints {
    foreach (pw_set_start[i]) {
      // Constrain pw_set_stop to be a multiple of pw_set_step greater than pw_set_start
      (pw_set_stop[i] - pw_set_start[i]) % pw_set_step[i] == 0;
      (pw_set_stop[i] - pw_set_start[i]) >= pw_set_step[i];
      pw_set_stop[i] > pw_set_start[i];

      // Constrain total number of steps to not be too large
      pw_set_stop[i] <= pw_set_start[i] + pw_set_step[i] * 10;

      // Constrain PW to not be zero or too large
      pw_set_start[i] > 0;
      pw_set_stop[i] < 16;
    }
  }

  // SL DAC RESET level randomization constraints
  constraint sl_dac_rst_lvl_constraints {
    foreach (sl_dac_rst_lvl_start[i]) {
      // Constrain sl_dac_rst_lvl_stop to be a multiple of sl_dac_rst_lvl_step greater than sl_dac_rst_lvl_start
      (sl_dac_rst_lvl_stop[i] - sl_dac_rst_lvl_start[i]) % sl_dac_rst_lvl_step[i] == 0;
      (sl_dac_rst_lvl_stop[i] - sl_dac_rst_lvl_start[i]) >= sl_dac_rst_lvl_step[i];
      sl_dac_rst_lvl_stop[i] > sl_dac_rst_lvl_start[i];

      // Constrain total number of steps to not be too large
      sl_dac_rst_lvl_stop[i] <= sl_dac_rst_lvl_start[i] + sl_dac_rst_lvl_step[i] * 10;
    }
  }

  // WL DAC RESET level randomization constraints
  constraint wl_dac_rst_lvl_constraints {
    foreach (wl_dac_rst_lvl_start[i]) {
      // Constrain wl_dac_rst_lvl_stop to be a multiple of wl_dac_rst_lvl_step greater than wl_dac_rst_lvl_start
      (wl_dac_rst_lvl_stop[i] - wl_dac_rst_lvl_start[i]) % wl_dac_rst_lvl_step[i] == 0;
      (wl_dac_rst_lvl_stop[i] - wl_dac_rst_lvl_start[i]) >= wl_dac_rst_lvl_step[i];
      wl_dac_rst_lvl_stop[i] > wl_dac_rst_lvl_start[i];

      // Constrain total number of steps to not be too large
      wl_dac_rst_lvl_stop[i] <= wl_dac_rst_lvl_start[i] + wl_dac_rst_lvl_step[i] * 10;
    }
  }

  // // RESET pulse width randomization constraints
  // constraint pw_rst_constraints {
  //   foreach (pw_rst_start[i]) {
  //     // Constrain pw_rst_stop to be a multiple of pw_rst_step greater than pw_rst_start
  //     (`defloat(pw_rst_stop[i]) - `defloat(pw_rst_start[i])) % `defloat(pw_rst_step[i]) == 0;
  //     (`defloat(pw_rst_stop[i]) - `defloat(pw_rst_start[i])) >= `defloat(pw_rst_step[i]);
  //     `defloat(pw_rst_stop[i]) > `defloat(pw_rst_start[i]);

  //     // Constrain total number of steps to not be too large
  //     `defloat(pw_rst_stop[i]) <= `defloat(pw_rst_start[i]) + `defloat(pw_rst_step[i]) * 10;

  //     // Constrain PW to not be too large
  //     `defloat(pw_rst_stop[i]) < 100;
  //   }
  // }

  // RESET pulse width randomization constraints
  constraint pw_rst_constraints {
    foreach (pw_rst_start[i]) {
      // Constrain pw_rst_stop to be a multiple of pw_rst_step greater than pw_rst_start
      (pw_rst_stop[i] - pw_rst_start[i]) % pw_rst_step[i] == 0;
      (pw_rst_stop[i] - pw_rst_start[i]) >= pw_rst_step[i];
      pw_rst_stop[i] > pw_rst_start[i];

      // Constrain total number of steps to not be too large
      pw_rst_stop[i] <= pw_rst_start[i] + pw_rst_step[i] * 10;

      // Constrain PW to not be zero or too large
      pw_rst_start[i] > 0;
      pw_rst_stop[i] < 16;
    }
  }

  // Maximum number of attempts randomization constraints
  constraint max_attempts_constraints {
    max_attempts[4:0] > 1;
  }

  // Constrain loop order
  constraint loop_order_constraints {
    foreach (loop_order_set[i]) {
      loop_order_set[i] < 6;
      loop_order_rst[i] < 6;
    }
  }

  // Setup cycle count randomization constraints
  constraint setup_constraints {
    idle_to_init_write_setup_cycles <= 3;
    idle_to_init_read_setup_cycles <= 3;
    read_to_init_write_setup_cycles <= 3;
    write_to_init_read_setup_cycles <= 3;
    step_read_setup_cycles <= 3;
    step_write_setup_cycles <= 3;
    post_read_setup_cycles <= 3;
    
    step_read_setup_cycles >= 1;
    post_read_setup_cycles >= 1;
  }

  // TODO: have an unbounded case with one attempt and a bounded case with multiple attempts

  // Pulse width randomization constraints
  constraint pw_constraints {
    pw_set_cycle >= 1;
    pw_rst_cycle >= 1;
    pw_set_cycle <= 3;
    pw_rst_cycle <= 3;
  }

  // Address randomization constraints
  constraint address_constraints {
    // Constrain address_stop to be a multiple of address_step greater than address_start
    (address_stop - address_start) % address_step == 0;
    address_stop > address_start;

    // Constrain total number of address steps to not be too large
    address_stop <= address_start + address_step * 5;
  }

  // This function allows us to print contents of the data packet
  // so that it is easier to track in a logfile
  function void print(string tag="");
    if (perform_read) begin
      $display("PERFORM READ");
    end
    else begin
      // Display driver operation
      $display("T=%0t [%s] addr=%0d-%0d-%0d op=%0d max_attempts=%0d", $time, tag, address_start, address_stop, address_step, opcode, max_attempts);
      
      // Display ADC levels
      if (`DEBUG_ADC_LVLS) begin
        foreach (adc_upper_read_ref_lvl[i]) begin
          $display("Range %0d ADC levels: %0d-%0d-%0d", i, adc_lower_write_ref_lvl[i], adc_upper_write_ref_lvl[i], adc_upper_read_ref_lvl[i]);
        end
      end

      // Display PW stepping
      if (`DEBUG_PWS) begin
        foreach (pw_set_start[i]) begin
          $display("Range %0d SET PW stepping: %0d-%0d-%0d", i, `defloat(pw_set_start[i]), `defloat(pw_set_stop[i]), `defloat(pw_set_step[i]));
        end
        foreach (pw_rst_start[i]) begin
          $display("Range %0d RST PW stepping: %0d-%0d-%0d", i, `defloat(pw_rst_start[i]), `defloat(pw_rst_stop[i]), `defloat(pw_rst_step[i]));
        end
      end

      // Display DAC stepping
      if (`DEBUG_DAC_LVLS) begin
        foreach (bl_dac_set_lvl_start[i]) begin
          $display("Range %0d SET BL DAC stepping: %0d-%0d-%0d", i, bl_dac_set_lvl_start[i], bl_dac_set_lvl_stop[i], bl_dac_set_lvl_step[i]);
        end
        foreach (wl_dac_set_lvl_start[i]) begin
          $display("Range %0d SET WL DAC stepping: %0d-%0d-%0d", i, wl_dac_set_lvl_start[i], wl_dac_set_lvl_stop[i], wl_dac_set_lvl_step[i]);
        end
        foreach (sl_dac_rst_lvl_start[i]) begin
          $display("Range %0d RST SL DAC stepping: %0d-%0d-%0d", i, sl_dac_rst_lvl_start[i], sl_dac_rst_lvl_stop[i], sl_dac_rst_lvl_step[i]);
        end
        foreach (wl_dac_rst_lvl_start[i]) begin
          $display("Range %0d RST WL DAC stepping: %0d-%0d-%0d", i, wl_dac_rst_lvl_start[i], wl_dac_rst_lvl_stop[i], wl_dac_rst_lvl_step[i]);
        end
      end
    end
  endfunction
endclass
