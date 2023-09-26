module fsm (
  // Clock, reset
  input wire    mclk,
  input wire    rst_n,

  // RRAM busy indicator
  output wire   rram_busy,

  // Address from register array
  input wire    [`ADDR_BITS_N-1:0]  address_start,
  input wire    [`ADDR_BITS_N-1:0]  address_stop,
  input wire    [`ADDR_BITS_N-1:0]  address_step,

  // Data to/from register array
  // NOTE: these 2-D array constructs are only supported by SystemVerilog, WONTFIX: could be flattened/unflattened
  input wire    [`WORD_SIZE-1:0]                    write_data_bits [`PROG_CNFG_RANGES_LOG2_N-1:0],
  output reg    [`WORD_SIZE-1:0]                    read_data_bits [`PROG_CNFG_RANGES_LOG2_N-1:0],

  // Global parameters from register array
  input wire    [`MAX_ATTEMPTS_BITS_N-1:0]          max_attempts,
  // input wire                                        use_ecc,
  input wire    [`PROG_CNFG_RANGES_LOG2_N-1:0]      num_levels,
  input wire    [`BSL_DAC_BITS_N-1:0]               bl_dac_set_lvl_cycle,
  input wire    [`WL_DAC_BITS_N-1:0]                wl_dac_set_lvl_cycle,
  input wire    [`PW_BITS_N-1:0]                    pw_set_cycle,
  input wire    [`BSL_DAC_BITS_N-1:0]               sl_dac_rst_lvl_cycle,
  input wire    [`WL_DAC_BITS_N-1:0]                wl_dac_rst_lvl_cycle,
  input wire    [`PW_BITS_N-1:0]                    pw_rst_cycle,
  input wire                                        set_first,
  input wire    [`WORD_SIZE-1:0]                    di_init_mask,
  input wire                                        ignore_failures,
  input wire                                        all_dacs_on,
  input wire    [`SETUP_CYC_BITS_N-1:0]             idle_to_init_write_setup_cycles,
  input wire    [`SETUP_CYC_BITS_N-1:0]             idle_to_init_read_setup_cycles,
  input wire    [`SETUP_CYC_BITS_N-1:0]             read_to_init_write_setup_cycles,
  input wire    [`SETUP_CYC_BITS_N-1:0]             write_to_init_read_setup_cycles,
  input wire    [`SETUP_CYC_BITS_N-1:0]             step_read_setup_cycles,
  input wire    [`SETUP_CYC_BITS_N-1:0]             step_write_setup_cycles,
  input wire    [`SETUP_CYC_BITS_N-1:0]             post_read_setup_cycles,

  // Programming parameters from register array
  input wire    [`ADC_BITS_N-1:0]           adc_clamp_ref_lvl,
  input wire    [`READ_DAC_BITS_N-1:0]      adc_read_dac_lvl,
  input wire    [`ADC_BITS_N-1:0]           adc_upper_read_ref_lvl,
  input wire    [`ADC_BITS_N-1:0]           adc_lower_write_ref_lvl,
  input wire    [`ADC_BITS_N-1:0]           adc_upper_write_ref_lvl,
  input wire    [`BSL_DAC_BITS_N-1:0]       bl_dac_set_lvl_start,
  input wire    [`BSL_DAC_BITS_N-1:0]       bl_dac_set_lvl_stop,
  input wire    [`BSL_DAC_BITS_N-1:0]       bl_dac_set_lvl_step,
  input wire    [`WL_DAC_BITS_N-1:0]        wl_dac_set_lvl_start,
  input wire    [`WL_DAC_BITS_N-1:0]        wl_dac_set_lvl_stop,
  input wire    [`WL_DAC_BITS_N-1:0]        wl_dac_set_lvl_step,
  input wire    [`PW_BITS_N-1:0]            pw_set_start,
  input wire    [`PW_BITS_N-1:0]            pw_set_stop,
  input wire    [`PW_BITS_N-1:0]            pw_set_step,
  input wire    [`LOOP_BITS_N-1:0]          loop_order_set,
  input wire    [`BSL_DAC_BITS_N-1:0]       sl_dac_rst_lvl_start,
  input wire    [`BSL_DAC_BITS_N-1:0]       sl_dac_rst_lvl_stop,
  input wire    [`BSL_DAC_BITS_N-1:0]       sl_dac_rst_lvl_step,
  input wire    [`WL_DAC_BITS_N-1:0]        wl_dac_rst_lvl_start,
  input wire    [`WL_DAC_BITS_N-1:0]        wl_dac_rst_lvl_stop,
  input wire    [`WL_DAC_BITS_N-1:0]        wl_dac_rst_lvl_step,
  input wire    [`PW_BITS_N-1:0]            pw_rst_start,
  input wire    [`PW_BITS_N-1:0]            pw_rst_stop,
  input wire    [`PW_BITS_N-1:0]            pw_rst_step,
  input wire    [`LOOP_BITS_N-1:0]          loop_order_rst,

  // FSM commands from register array
  input wire                                      fsm_go,
  input wire    [`OP_CODE_BITS_N-1:0]             opcode,
  input wire                                      use_multi_addrs,

  // FSM to register array
  output reg    [`PROG_CNFG_RANGES_LOG2_N-1:0]    rangei,     // for indexing which programming settings to use from FSM
  output        [`FSM_FULL_STATE_BITS_N-1:0]      fsm_bits,   // state of all regs in FSM
  output        [`FSM_DIAG_BITS_N-1:0]            diag_bits,  // diagnostic bits in FSM

  // FSM input from analog block
  input wire [`WORD_SIZE-1:0] sa_do,
  input wire                  sa_rdy,

  // FSM output to analog block
  output reg aclk,
  output reg bl_en,
  output reg bleed_en,
  output reg [`BSL_DAC_BITS_N-1:0] bsl_dac_config,
  output reg bsl_dac_en,
  output reg [`ADC_BITS_N-1:0] clamp_ref,
  output wire [`WORD_SIZE-1:0] di,
  output reg [`READ_DAC_BITS_N-1:0] read_dac_config,
  output reg read_dac_en,
  output reg [`ADC_BITS_N-1:0] read_ref,
  output reg [`ADDR_BITS_N-1:0] rram_addr,
  output wire sa_clk,
  output reg sa_en,
  output reg set_rst,
  output reg sl_en,
  output reg we,
  output reg [`WL_DAC_BITS_N-1:0] wl_dac_config,
  output reg wl_dac_en,
  output reg wl_en
  );

  // Muxed write data bits (uses read data bits if REFRESH mode)
  wire [`WORD_SIZE-1:0] write_data [`PROG_CNFG_RANGES_LOG2_N-1:0];
  assign write_data = (opcode == `OP_REFRESH) ? read_data_bits : write_data_bits;

  // Address
  reg [`ADDR_BITS_N-1:0] next_rram_addr;

  // FSM state
  reg [`FSM_STATE_BITS_N-1:0] next_state;
  reg [`FSM_STATE_BITS_N-1:0] state;

  // FSM outputs
  reg [`PW_BITS_N-1:0] pw;

  // Counter stuff
  reg [`PW_FULL_BITS_N-1:0] counter;
  reg counter_incr_en;
  reg counter_rst;
  reg [`FSM_DIAG_COUNT_BITS_N-1:0] success_counter;
  reg success_counter_incr_en;
  reg success_counter_rst;
  reg [`FSM_DIAG_COUNT_BITS_N-1:0] failure_counter;
  reg failure_counter_incr_en;
  reg failure_counter_rst;
  reg [`FSM_DIAG_COUNT_BITS_N-1:0] set_counter;
  reg set_counter_incr_en;
  reg set_counter_rst;
  reg [`FSM_DIAG_COUNT_BITS_N-1:0] reset_counter;
  reg reset_counter_incr_en;
  reg reset_counter_rst;
  reg [`FSM_DIAG_COUNT_BITS_N-1:0] read_counter;
  reg read_counter_incr_en;
  reg read_counter_rst;
  reg [`MAX_ATTEMPTS_BITS_N-1:0] attempts_counter;
  reg attempts_counter_incr_en;
  reg attempts_counter_rst;
  reg is_first_try;
  reg next_is_first_try;
  reg [`PROG_CNFG_RANGES_LOG2_N-1:0] next_rangei;

  // Loop variables
  reg [`PW_BITS_N-1:0] pw_loop;
  reg [`PW_BITS_N-1:0] next_pw_loop;
  reg [`WL_DAC_BITS_N-1:0] wl_loop;
  reg [`WL_DAC_BITS_N-1:0] next_wl_loop;
  reg [`BSL_DAC_BITS_N-1:0] bsl_loop;
  reg [`BSL_DAC_BITS_N-1:0] next_bsl_loop;
  reg set_rst_loop;
  reg next_set_rst_loop;

  // Masking
  reg [`WORD_SIZE-1:0] mask;
  reg [`WORD_SIZE-1:0] next_mask;

  // Read data bits
  reg [`WORD_SIZE-1:0] next_read_data_bits [`PROG_CNFG_RANGES_LOG2_N-1:0];

  // SA clock connected to master clock
  assign sa_clk = mclk;

  // Update state and registers
  integer i, j; // WONTFIX: could make these genvars
  always @(posedge mclk or negedge rst_n) begin
    // Reset registers
    if (!rst_n) begin
      rram_addr <= 0;
      state <= `FSM_STATE_IDLE;
      counter <= 0;
      attempts_counter <= 0;
      success_counter <= 0;
      failure_counter <= 0;
      set_counter <= 0;
      reset_counter <= 0;
      read_counter <= 0;
      is_first_try <= 0;
      rangei <= 0;
      mask <= 0;
      pw_loop <= 0;
      wl_loop <= 0;
      bsl_loop <= 0;
      set_rst_loop <= 0;

      // Reset read data bits to 0
      for (i = 0; i < `PROG_CNFG_RANGES_LOG2_N; i=i+1) begin
        read_data_bits[i] <= 0;
      end
    end
    // Update registers
    else begin
      // Update address, state, first try, range index, read data bits
      rram_addr <= next_rram_addr;
      state <= next_state;
      is_first_try <= next_is_first_try;
      rangei <= next_rangei;
      mask <= next_mask;
      read_data_bits <= next_read_data_bits;
      pw_loop <= next_pw_loop;
      wl_loop <= next_wl_loop;
      bsl_loop <= next_bsl_loop;
      set_rst_loop <= next_set_rst_loop;

      // Update counter
      if (counter_rst)
        counter <= 0;
      else if (counter_incr_en)
        counter <= counter + 1;

      // Update success counter
      if (success_counter_rst)
        success_counter <= 0;
      else if (success_counter_incr_en)
        success_counter <= success_counter + 1;

      // Update failure counter
      if (failure_counter_rst)
        failure_counter <= 0;
      else if (failure_counter_incr_en)
        failure_counter <= failure_counter + 1;

      // Update SET counter
      if (set_counter_rst)
        set_counter <= 0;
      else if (set_counter_incr_en)
        set_counter <= set_counter + 1;

      // Update RESET counter
      if (reset_counter_rst)
        reset_counter <= 0;
      else if (reset_counter_incr_en)
        reset_counter <= reset_counter + 1;

      // Update READ counter
      if (read_counter_rst)
        read_counter <= 0;
      else if (read_counter_incr_en)
        read_counter <= read_counter + 1;

      // Update attempts counter
      if (attempts_counter_rst)
        attempts_counter <= 0;
      else if (attempts_counter_incr_en)
        attempts_counter <= attempts_counter + 1;
    end
  end

  // State outputs and next state logic
  always @(*) begin
    // Default values outside of case (overridden inside case statement)
    sa_en = 0; aclk = 0; we = 0; set_rst = 0; pw = 0;                             // READ/SET/RST
    bl_en = 0; sl_en = 0; wl_en = 0;                                              // WBSL enables
    bleed_en = all_dacs_on; read_dac_en = all_dacs_on;                            // DAC enables
    bsl_dac_en = all_dacs_on; wl_dac_en = all_dacs_on;                            // DAC enables
    bsl_dac_config = 0; wl_dac_config = 0;                                        // Write DAC levels
    clamp_ref = 0; read_dac_config = 0; read_ref = 0;                             // Read DAC levels
    counter_incr_en = 0; counter_rst = 0;                                         // Counter
    attempts_counter_incr_en = 0; attempts_counter_rst = 0;                       // Attempts counter
    success_counter_incr_en = 0; success_counter_rst = 0;                         // Success counter
    failure_counter_incr_en = 0; failure_counter_rst = 0;                         // Failure counter
    set_counter_incr_en = 0; set_counter_rst = 0;                                 // SET counter
    reset_counter_incr_en = 0; reset_counter_rst = 0;                             // RESET counter
    read_counter_incr_en = 0; read_counter_rst = 0;                               // READ counter
    next_is_first_try = is_first_try;                                             // Is first try
    next_rram_addr = rram_addr;                                                   // RRAM address
    next_rangei = rangei;                                                         // Range index
    next_mask = mask;                                                             // Next data mask
    next_read_data_bits = read_data_bits;                                         // Next read data bits
    next_state = state;                                                           // Next state
    next_pw_loop = pw_loop;                                                       // Next pulse width in a loop
    next_wl_loop = wl_loop;                                                       // Next word line voltage in a loop
    next_bsl_loop = bsl_loop;                                                     // Next bit/source line voltage in a loop
    next_set_rst_loop = set_rst_loop;                                             // Next SET/RESET mode in a loop

    // Process state
    case (state)
      // IDLE, everything off
      `FSM_STATE_IDLE: begin
        counter_rst = 1; attempts_counter_rst = 1; next_is_first_try = 1;         // Reset all counters
        next_rram_addr = address_start;                                           // Start from first address
        next_rangei = 0;                                                          // Start from 0 index
        next_mask = di_init_mask;                                                 // SET/RST mask
        if (fsm_go) begin
          // Interpret opcode
          case (opcode)
            `OP_TEST_PULSE:
              next_state = `FSM_STATE_INIT_TEST_PULSE;
            `OP_TEST_READ:
              next_state = `FSM_STATE_INIT_TEST_READ;
            `OP_TEST_CPULSE:
              next_state = `FSM_STATE_INIT_TEST_CPULSE;
            `OP_CYCLE:
              next_state = `FSM_STATE_INIT_CYCLE;
            `OP_READ:
              next_state = `FSM_STATE_INIT_READ;
            `OP_WRITE:
              next_state = `FSM_STATE_INIT_WRITE;
            `OP_REFRESH:
              next_state = `FSM_STATE_INIT_READ;
            default:
              next_state = `FSM_STATE_IDLE;
          endcase
        end
      end

      // Initialize test pulse: prepare pulse signals (all except aclk and we)
      `FSM_STATE_INIT_TEST_PULSE: begin
        set_rst = set_first; pw = set_first ? pw_set_cycle : pw_rst_cycle;        // READ/SET/RST
        bl_en = 1; sl_en = 1; wl_en = 1;                                          // WBSL enables
        bsl_dac_en = 1; wl_dac_en = 1;                                            // DAC enables
        bsl_dac_config = set_first ? bl_dac_set_lvl_cycle : sl_dac_rst_lvl_cycle; // Write DAC levels
        wl_dac_config = set_first ? wl_dac_set_lvl_cycle : wl_dac_rst_lvl_cycle;  // Write DAC levels
        next_mask = di_init_mask;                                                 // SET/RST mask
        if (counter < idle_to_init_write_setup_cycles)                            // Counter for write setup time (in fixed-pt. repr.)
          counter_incr_en = 1;
        else begin
          counter_rst = 1;                                                        // Reset counter
          next_state = `FSM_STATE_TEST_PULSE;                                     // Move on to pulse
        end
      end
      
      // Perform pulse
      `FSM_STATE_TEST_PULSE: begin
        set_rst = set_first; pw = set_first ? pw_set_cycle : pw_rst_cycle;        // READ/SET/RST
        bl_en = 1; sl_en = 1; wl_en = 1;                                          // WBSL enables
        bsl_dac_en = 1; wl_dac_en = 1;                                            // DAC enables
        bsl_dac_config = set_first ? bl_dac_set_lvl_cycle : sl_dac_rst_lvl_cycle; // Write DAC levels
        wl_dac_config = set_first ? wl_dac_set_lvl_cycle : wl_dac_rst_lvl_cycle;  // Write DAC levels
        next_mask = di_init_mask;                                                 // SET/RST mask
        aclk = 1; we = 1;                                                         // Enable pulse
        if (counter < `pw_defloat(pw))                                            // Counter for pulse width (convert from float repr.)
          counter_incr_en = 1;
        else begin
          aclk = 0; we = 0;                                                       // Disable pulse
          counter_rst = 1;                                                        // Reset counter
          next_state = `FSM_STATE_IDLE;                                           // Return to IDLE
        end
      end

      // Initialize test read: prepare pulse signals (all except aclk and we)
      `FSM_STATE_INIT_TEST_READ: begin
        next_rangei = 0;                                                          // Range to consider (uses 0)
        bl_en = 1; sl_en = 1; wl_en = 1;                                          // WBSL enables
        bleed_en = 1; read_dac_en = 1;                                            // DAC enables
        clamp_ref = adc_clamp_ref_lvl; read_dac_config = adc_read_dac_lvl;        // Read DAC levels
        read_ref = adc_upper_read_ref_lvl;                                        // Read level
        set_rst = 1; next_mask = di_init_mask;                                    // DI mask
        if (counter < idle_to_init_read_setup_cycles)                             // Counter for read setup time (in fixed-pt. repr.)
          counter_incr_en = 1;
        else begin
          counter_rst = 1;                                                        // Reset counter
          next_state = `FSM_STATE_TEST_READ;                                      // Move on to test read state
        end
      end
      
      // Perform read
      `FSM_STATE_TEST_READ: begin
        next_rangei = 0;                                                          // Range to consider (uses 0)
        bl_en = 1; sl_en = 1; wl_en = 1;                                          // WBSL enables
        bleed_en = 1; read_dac_en = 1;                                            // DAC enables
        clamp_ref = adc_clamp_ref_lvl; read_dac_config = adc_read_dac_lvl;        // Read DAC levels
        read_ref = adc_upper_read_ref_lvl;                                        // Read level
        set_rst = 1; next_mask = di_init_mask;                                    // DI mask
        sa_en = 1;                                                                // Enable read
        if (sa_rdy & (counter < post_read_setup_cycles)) begin                    // Wait for post read cycle after SA ready
          counter_incr_en = 1;                                                    // Increment counter
          next_read_data_bits[0] = sa_do;
        end
        if (counter == post_read_setup_cycles) begin                              // Add extra cycle for disabling
          sa_en = 0;                                                              // Disable SA
          next_state = `FSM_STATE_IDLE;                                           // Return to IDLE
        end
      end

      // Initialize test charge pulse: prepare pulse signals (all except aclk and we)
      `FSM_STATE_INIT_TEST_CPULSE: begin
        bl_en = 1; sl_en = 1; wl_en = 0;                                          // BSL enables (WL off)
        next_mask = di_init_mask;                                                 // SET/RST mask
        we = 1;                                                                   // Enable pulse
        if (counter < idle_to_init_write_setup_cycles)                            // Counter for write setup time (in fixed-pt. repr.)
          counter_incr_en = 1;
        else begin
          bl_en = 0;
          counter_rst = 1;                                                        // Reset counter
          next_state = `FSM_STATE_TEST_CPULSE;                                    // Move on to pulse
        end
      end
      
      // Perform charge pulse
      `FSM_STATE_TEST_CPULSE: begin
        pw = set_first ? pw_set_cycle : pw_rst_cycle;                             // Determine pulse width
        bl_en = 0; sl_en = 1; wl_en = 1;                                          // WBSL enables
        next_mask = di_init_mask;                                                 // SET/RST mask
        next_rram_addr = address_start;                                           // RRAM address
        we = 1;                                                                   // Enable pulse
        if (counter < `pw_defloat(pw))                                            // Counter for pulse width (convert from float repr.)
          counter_incr_en = 1;
        else begin
          bl_en = 0; sl_en = 0; wl_en = 0; we = 0;                                // Disable pulse
          counter_rst = 1;                                                        // Reset counter
          next_state = `FSM_STATE_IDLE;                                           // Return to IDLE
        end
      end

      // Initialize cycling: prepare pulse signals (all except aclk and we)
      `FSM_STATE_INIT_CYCLE: begin
        set_rst = set_first; pw = set_first ? pw_set_cycle : pw_rst_cycle;        // READ/SET/RST
        bl_en = 1; sl_en = 1; wl_en = 1;                                          // WBSL enables
        bsl_dac_en = 1; wl_dac_en = 1;                                            // DAC enables
        bsl_dac_config = set_first ? bl_dac_set_lvl_cycle : sl_dac_rst_lvl_cycle; // Write DAC levels
        wl_dac_config = set_first ? wl_dac_set_lvl_cycle : wl_dac_rst_lvl_cycle;  // Write DAC levels
        next_mask = di_init_mask;                                                 // SET/RST mask
        if (counter < idle_to_init_write_setup_cycles)                            // Counter for write setup time (in fixed-pt. repr.)
          counter_incr_en = 1;
        else begin
          counter_rst = 1;                                                        // Reset counter
          next_state = `FSM_STATE_PULSE_CYCLE;                                    // Move on to pulse
        end
      end
      
      // Perform cycle pulse
      `FSM_STATE_PULSE_CYCLE: begin
        set_rst = (is_first_try == set_first);                                    // Whether to perform SET/RESET
        pw = set_rst ? pw_set_cycle : pw_rst_cycle;                               // Pulse width
        bl_en = 1; sl_en = 1; wl_en = 1;                                          // WBSL enables
        bsl_dac_en = 1; wl_dac_en = 1;                                            // DAC enables
        bsl_dac_config = set_rst ? bl_dac_set_lvl_cycle : sl_dac_rst_lvl_cycle;   // Write DAC levels
        wl_dac_config = set_rst ? wl_dac_set_lvl_cycle : wl_dac_rst_lvl_cycle;    // Write DAC levels
        next_mask = di_init_mask;                                                 // SET/RST mask
        aclk = 1; we = 1;                                                         // Enable pulse
        if (counter < `pw_defloat(pw))                                            // Counter for pulse width (convert from float repr.)
          counter_incr_en = 1;
        else begin
          // NOTE: this is a "cooldown" clock cycle
          // This turns the write enable before the change
          aclk = 0; we = 0;                                                       // Disable pulse
          counter_rst = 1;                                                        // Reset counter
          next_is_first_try = ~is_first_try;                                      // Switch from SET->RST or RST->SET mode
          next_state = `FSM_STATE_STEP_CYCLE;                                     // Return to IDLE
          if (~is_first_try) begin                                                // Check if full cycle is complete
            if ((attempts_counter + 1) < max_attempts) begin                      // If any more SET/RST cycles left to do
              attempts_counter_incr_en = 1;                                       // Go to next SET/RST cycle (attempt)
            end
            else begin                                                            // Otherwise, go to next address
              attempts_counter_rst = 1;                                           // Reset the cycle (attempt) ccounter
              next_rram_addr = rram_addr + address_step;                          // New RRAM address
              if ((next_rram_addr > address_stop) | ~use_multi_addrs) begin       // If finished with all addresses
                next_state = `FSM_STATE_IDLE;                                     // Return to IDLE
              end
            end
          end
        end
      end

      // Perform setup
      `FSM_STATE_STEP_CYCLE: begin
        set_rst = (is_first_try == set_first);                                    // Whether to perform SET/RESET
        pw = set_rst ? pw_set_cycle : pw_rst_cycle;                               // Pulse width
        bl_en = 1; sl_en = 1; wl_en = 1;                                          // WBSL enables
        bsl_dac_en = 1; wl_dac_en = 1;                                            // DAC enables
        bsl_dac_config = set_rst ? bl_dac_set_lvl_cycle : sl_dac_rst_lvl_cycle;   // Write DAC levels
        wl_dac_config = set_rst ? wl_dac_set_lvl_cycle : wl_dac_rst_lvl_cycle;    // Write DAC levels
        next_mask = di_init_mask;                                                 // SET/RST mask
        aclk = 0; we = 0;                                                         // Disable pulse
        if (counter < step_write_setup_cycles) begin
          counter_incr_en = 1;
        end
        else begin
          counter_rst = 1;                                                        // Reset counter
          next_state = `FSM_STATE_PULSE_CYCLE;                                    // Begin next cycle
        end
      end

      // Initialize test read: prepare pulse signals (all except aclk and we)
      `FSM_STATE_INIT_READ: begin
        next_rangei = 0;                                                          // Range to consider (uses 0)
        bl_en = 1; sl_en = 1; wl_en = 1;                                          // WBSL enables
        for (i = 0; i < `PROG_CNFG_RANGES_LOG2_N; i=i+1) begin
          next_read_data_bits[i] = 0;                                             // Reset read data bits
        end
        next_mask = di_init_mask;                                                 // SET/RST mask
        bleed_en = 1; read_dac_en = 1;                                            // DAC enables
        clamp_ref = adc_clamp_ref_lvl; read_dac_config = adc_read_dac_lvl;        // Read DAC levels
        read_ref = adc_upper_read_ref_lvl;                                        // Read level
        set_rst = 1;                                                              // Enable SET mode just to get mask matching DI
        if (counter < idle_to_init_read_setup_cycles)                             // Counter for read setup time (in fixed-pt. repr.)
          counter_incr_en = 1;
        else begin
          counter_rst = 1;                                                        // Reset counter
          next_state = `FSM_STATE_READ_READ;                                      // Move on to read read state
        end
      end
      
      // Perform read
      `FSM_STATE_READ_READ: begin
        bl_en = 1; sl_en = 1; wl_en = 1;                                          // WBSL enables
        bleed_en = 1; read_dac_en = 1;                                            // DAC enables
        clamp_ref = adc_clamp_ref_lvl; read_dac_config = adc_read_dac_lvl;        // Read DAC levels
        read_ref = adc_upper_read_ref_lvl;                                        // Read level
        set_rst = 1;                                                              // Enable SET mode just to get mask matching DI
        sa_en = 1;                                                                // Enable read
        if (sa_rdy) begin                                                         // Wait until SA ready
          if (counter < post_read_setup_cycles) begin                             // Wait for post read cycle after SA ready
            counter_incr_en = 1;                                                  // Increment counter
          end
          else begin
            counter_rst = 1;                                                      // Reset the counter
            next_state = `FSM_STATE_STEP_READ;                                    // Go to step read to go to next level/address
            next_rangei = rangei + 1;                                             // Increment range index
            for (i = 0; i < `PROG_CNFG_RANGES_LOG2_N; i=i+1) begin
              for (j = 0; j < `WORD_SIZE; j=j+1) begin
                if (mask[j] & ~sa_do[j]) begin                                    // If unmasked and below sense amp threshold
                  next_read_data_bits[i][j] = rangei[i];                          // Update inferred read level
                  next_mask[j] = 0;                                               // Mask the bit for which level has been inferred
                end
              end
            end
            if (`PROG_CNFG_RANGES_LOG2_N'(next_rangei + 1) == num_levels) begin   // When on second last level, stop (no READ required)
              for (i = 0; i < `PROG_CNFG_RANGES_LOG2_N; i=i+1) begin
                for (j = 0; j < `WORD_SIZE; j=j+1) begin
                  if (next_mask[j]) begin                                         // If unmasked
                    next_read_data_bits[i][j] = next_rangei[i];                   // Update inferred read level
                  end
                end
              end
              next_state = (opcode == `OP_REFRESH) ? `FSM_STATE_INIT_WRITE : `FSM_STATE_POST_READ; // Return to IDLE (or WRITE if REFRESH op)
            end
            if (next_mask == 0) begin                                             // If next mask is empty, no more READs required
              next_state = (opcode == `OP_REFRESH) ? `FSM_STATE_INIT_WRITE : `FSM_STATE_POST_READ; // Return to IDLE (or WRITE if REFRESH op)
            end
          end
        end
      end

      // Post-read to disable sa_en before bsl/wl_en
      `FSM_STATE_POST_READ: begin
        bl_en = 1; sl_en = 1; wl_en = 1;                                          // WBSL enables
        bleed_en = 1; read_dac_en = 1;                                            // DAC enables
        clamp_ref = adc_clamp_ref_lvl; read_dac_config = adc_read_dac_lvl;        // Read DAC levels
        read_ref = adc_upper_read_ref_lvl;                                        // Read level
        set_rst = 1;                                                              // Enable SET mode just to get mask matching DI
        sa_en = 0;                                                                // Enable read
        next_state = `FSM_STATE_IDLE;                                             // Go back to IDLE
      end

      // Perform next read setup
      `FSM_STATE_STEP_READ: begin
        bl_en = 1; sl_en = 1; wl_en = 1;                                          // WBSL enables
        bleed_en = 1; read_dac_en = 1;                                            // DAC enables
        clamp_ref = adc_clamp_ref_lvl; read_dac_config = adc_read_dac_lvl;        // Read DAC levels
        read_ref = adc_upper_read_ref_lvl;                                        // Read level
        set_rst = 1;                                                              // Enable SET mode just to get mask matching DI
        sa_en = 0;                                                                // Disable read
        if (counter < step_read_setup_cycles)                                     // Allow setup time
          counter_incr_en = 1;                                                    // Increment counter
        else begin
          counter_rst = 1;                                                        // Reset counter
          next_state = `FSM_STATE_READ_READ;                                      // Begin next cycle
        end
      end

      // Initialize writing: prepare pulse signals
      `FSM_STATE_INIT_WRITE: begin
        // Prepare for read
        bl_en = 1; sl_en = 1; wl_en = 1;                                          // WBSL enables
        next_mask = di_init_mask;                                                 // SET/RST mask
        bleed_en = 1; read_dac_en = 1; wl_dac_en = 1;                             // DAC enables
        set_rst = 1;                                                              // Enable SET mode just to get mask matching DI
        clamp_ref = adc_clamp_ref_lvl; read_dac_config = adc_read_dac_lvl;        // Read DAC levels
        read_ref = set_first ? adc_lower_write_ref_lvl : adc_upper_write_ref_lvl; // Read level should be lower write ref level if SET, upper write ref level if RESET

        // Initialize loop variables
        next_rram_addr = address_start;                                           // Initialize RRAM address
        next_set_rst_loop = set_first;                                            // Initialize whether to do SET/RESET
        next_wl_loop = set_first ? wl_dac_set_lvl_start : wl_dac_rst_lvl_start;   // Initialize WL DAC level
        next_bsl_loop = set_first ? bl_dac_set_lvl_start : sl_dac_rst_lvl_start;  // Initialize BSL DAC level
        next_pw_loop = set_first ? pw_set_start : pw_rst_start;                   // Initialize pulse width

        // Counter
        if (counter < idle_to_init_read_setup_cycles)                             // Counter for read setup time (in fixed-pt. repr.)
          counter_incr_en = 1;
        else begin
          counter_rst = 1;                                                        // Reset counter
          next_is_first_try = 1;                                                  // Reset first try register
          next_state = `FSM_STATE_READ_WRITE;                                     // Go to the next step
        end

        // Initialize mask based on bits to be written
        for (i = 0; i < `WORD_SIZE; i=i+1) begin
          if ({write_data[3][i], write_data[2][i], write_data[1][i], write_data[0][i]} != rangei) begin
            next_mask[i] = 0;
          end
        end

        // If next mask is 0, then skip write pulse
        if (next_mask == 0) begin
          next_state = `FSM_STATE_STEP_WRITE;
        end

        // Reset success/failure counters
        if (opcode != `OP_REFRESH) begin
          success_counter_rst = 1;
          failure_counter_rst = 1;
          set_counter_rst = 1;
          reset_counter_rst = 1;
          read_counter_rst = 1;
        end
      end
      
      // Perform read to further determine which bits to pulse
      `FSM_STATE_READ_WRITE: begin
        bl_en = 1; sl_en = 1; wl_en = 1;                                          // WBSL enables
        bleed_en = 1; read_dac_en = 1;                                            // DAC enables
        clamp_ref = adc_clamp_ref_lvl; read_dac_config = adc_read_dac_lvl;        // Read DAC levels
        read_ref = set_rst_loop ? adc_lower_write_ref_lvl : adc_upper_write_ref_lvl; // Read level should be lower write ref level if SET, upper write ref level if RESET
        set_rst = 1;                                                              // Enable SET mode just to get mask matching DI
        sa_en = 1;                                                                // Enable read
        if (sa_rdy) begin                                                         // Wait until SA ready
          if (counter < post_read_setup_cycles) begin                             // Wait for post read cycle after SA ready
            counter_incr_en = 1;                                                  // Increment counter
          end                                                                     
          else begin
            counter_rst = 1;                                                      // Reset the counter
            read_counter_incr_en = 1;                                             // Increment READ counter
            next_state = `FSM_STATE_PREPULSE_WRITE;                               // Go to step read to go to next level/address
            next_mask = mask & (set_rst_loop ? ~sa_do : sa_do);                   // Update mask based on bits to be written
            if (next_mask == 0) begin                                             // If next mask is 0, then skip write pulse
              next_state = `FSM_STATE_STEP_WRITE;                                 // Go straight to step write state
              if (is_first_try && (attempts_counter != 0)) begin                  // If first try and at least one check has been made
                next_rangei = rangei + 1;                                         // Go to next range
              end
            end
          end
        end
      end

      // Setup write pulse
      `FSM_STATE_PREPULSE_WRITE: begin
        set_rst = set_rst_loop;                                                   // Whether to perform SET/RESET
        bl_en = 1; sl_en = 1; wl_en = 1;                                          // WBSL enables
        bsl_dac_en = 1; wl_dac_en = 1;                                            // DAC enables
        bsl_dac_config = bsl_loop; wl_dac_config = wl_loop;                       // Write DAC levels
        aclk = 0; we = 0;                                                         // Disable pulse
        next_is_first_try = 0;                                                    // Disable first try
        if (counter < read_to_init_write_setup_cycles)                            // Counter for setup cycles
          counter_incr_en = 1;
        else begin
          counter_rst = 1;                                                        // Reset counter
          next_state = `FSM_STATE_PULSE_WRITE;                                    // Do the actual pulse
        end
      end
      
      // Perform write pulsesa
      `FSM_STATE_PULSE_WRITE: begin
        pw = pw_loop;                                                             // Set pulse width to loop value  
        set_rst = set_rst_loop;                                                   // Whether to perform SET/RESET
        bl_en = 1; sl_en = 1; wl_en = 1;                                          // WBSL enables
        bsl_dac_en = 1; wl_dac_en = 1;                                            // DAC enables
        bsl_dac_config = bsl_loop; wl_dac_config = wl_loop;                       // Write DAC levels
        aclk = 1; we = 1;                                                         // Enable pulse
        if (counter < `pw_defloat(pw))                                            // Counter for pulse width (convert from float repr.)
          counter_incr_en = 1;
        else begin
          aclk = 0; we = 0;                                                       // Disable pulse
          set_counter_incr_en = set_rst_loop;                                     // Increment SET counter (if appropriate)
          reset_counter_incr_en = ~set_rst_loop;                                  // Increment RESET counter (if appropriate)
          counter_rst = 1;                                                        // Reset counter
          next_state = `FSM_STATE_STEP_WRITE;                                     // Step the write parameters
        end
      end

      // Step writing parameters
      `FSM_STATE_STEP_WRITE: begin
        // Update loop state on first cycle
        if (counter == 0) begin
          // If mask is 0, then current SET/RESET loop is finished and need to switch between SET/RESET mode
          if (mask == 0) begin
            // Switch between SET/RESET mode and reset the first try
            next_set_rst_loop = ~set_rst_loop;                                    // Switch between SET/RESET
            next_is_first_try = 1;                                                // Reset first try registers
            attempts_counter_incr_en = 1;                                         // Attempts counter
            // If it was the first try, the range index just incremented (rangei gets incremented in FSM_STATE_READ_WRITE)
            if (is_first_try && (attempts_counter != 0)) begin
              next_set_rst_loop = set_first;                                      // Initialize whether to do SET/RESET
              // Update address if done with all ranges
              if (rangei == num_levels) begin                                     // Check if rangei reached maximum
                success_counter_incr_en = 1;                                      // Record success
                next_rram_addr = rram_addr + address_step;                        // Increment address
                // Break out of loop and go to IDLE if done with all addresses
                if ((next_rram_addr > address_stop) | ~use_multi_addrs) begin     // If finished with all addresses
                  next_state = `FSM_STATE_IDLE;                                   // Return to IDLE
                end
              end
            end
            // Update loop variables to starting values
            next_wl_loop = next_set_rst_loop ? wl_dac_set_lvl_start : wl_dac_rst_lvl_start; // Initialize WL DAC level
            next_bsl_loop = next_set_rst_loop ? bl_dac_set_lvl_start : sl_dac_rst_lvl_start; // Initialize BSL DAC level
            next_pw_loop = next_set_rst_loop ? pw_set_start : pw_rst_start;       // Initialize pulse width
            next_mask = di_init_mask;                                             // Reset mask to initial value
            // Initialize mask based on bits to be written
            for (i = 0; i < `WORD_SIZE; i=i+1) begin
              if ({write_data[3][i], write_data[2][i], write_data[1][i], write_data[0][i]} != rangei) begin
                next_mask[i] = 0;
              end
            end
          end
          // Otherwise, update loop variables depending on loop order
          else begin
            case (set_rst_loop ? loop_order_set : loop_order_rst)
              `LOOP_PWB: begin
                // Increment BL
                next_bsl_loop = bsl_loop + (set_rst_loop ? bl_dac_set_lvl_step : sl_dac_rst_lvl_step);
                // Check if BSL overflowed or reached maximum, and if so: reset value and increment WL
                if ((next_bsl_loop == 0) || (next_bsl_loop >= (set_rst_loop ? bl_dac_set_lvl_stop : sl_dac_rst_lvl_stop))) begin
                  next_bsl_loop = (set_rst_loop ? bl_dac_set_lvl_start : sl_dac_rst_lvl_start);
                  next_wl_loop = wl_loop + (set_rst_loop ? wl_dac_set_lvl_step : wl_dac_rst_lvl_step);
                end
                // Check if WL overflowed or reached maximum, and if so: reset value and increment PW
                if ((next_wl_loop == 0) || (next_wl_loop >= (set_rst_loop ? wl_dac_set_lvl_stop : wl_dac_rst_lvl_stop))) begin
                  next_wl_loop = (set_rst_loop ? wl_dac_set_lvl_start : wl_dac_rst_lvl_start);
                  next_pw_loop = pw_loop + (set_rst_loop ? pw_set_step : pw_rst_step);
                end
                // Check if PW overflowed or reached maximum, and if so: reset value and increment attempts counter
                if ((next_pw_loop == 0) || (next_pw_loop >= (set_rst_loop ? pw_set_stop : pw_rst_stop))) begin
                  next_pw_loop = (set_rst_loop ? pw_set_start : pw_rst_start);
                  attempts_counter_incr_en = 1;
                end
              end
              `LOOP_PBW: begin
                // Increment WL
                next_wl_loop = wl_loop + (set_rst_loop ? wl_dac_set_lvl_step : wl_dac_rst_lvl_step);
                // Check if WL overflowed or reached maximum, and if so: reset value and increment BSL
                if ((next_wl_loop == 0) || (next_wl_loop >= (set_rst_loop ? wl_dac_set_lvl_stop : wl_dac_rst_lvl_stop))) begin
                  next_wl_loop = (set_rst_loop ? wl_dac_set_lvl_start : wl_dac_rst_lvl_start);
                  next_bsl_loop = bsl_loop + (set_rst_loop ? bl_dac_set_lvl_step : sl_dac_rst_lvl_step);
                end
                // Check if BSL overflowed or reached maximum, and if so: reset value and increment PW
                if ((next_bsl_loop == 0) || (next_bsl_loop >= (set_rst_loop ? bl_dac_set_lvl_stop : sl_dac_rst_lvl_stop))) begin
                  next_bsl_loop = (set_rst_loop ? bl_dac_set_lvl_start : sl_dac_rst_lvl_start);
                  next_pw_loop = pw_loop + (set_rst_loop ? pw_set_step : pw_rst_step);
                end
                // Check if PW overflowed or reached maximum, and if so: reset value and increment attempts counter
                if ((next_wl_loop == 0) || (next_wl_loop >= (set_rst_loop ? wl_dac_set_lvl_stop : wl_dac_rst_lvl_stop))) begin
                  next_pw_loop = (set_rst_loop ? pw_set_start : pw_rst_start);
                  attempts_counter_incr_en = 1;
                end
              end
              `LOOP_WBP: begin
                // Increment PW
                next_pw_loop = pw_loop + (set_rst_loop ? pw_set_step : pw_rst_step);
                // Check if PW overflowed or reached maximum, and if so: reset value and increment BSL
                if ((next_pw_loop == 0) || (next_pw_loop >= (set_rst_loop ? pw_set_stop : pw_rst_stop))) begin
                  next_pw_loop = (set_rst_loop ? pw_set_start : pw_rst_start);
                  next_bsl_loop = bsl_loop + (set_rst_loop ? bl_dac_set_lvl_step : sl_dac_rst_lvl_step);
                end
                // Check if BSL overflowed or reached maximum, and if so: reset value and increment WL
                if ((next_wl_loop == 0) || (next_wl_loop >= (set_rst_loop ? wl_dac_set_lvl_stop : wl_dac_rst_lvl_stop))) begin
                  next_bsl_loop = (set_rst_loop ? bl_dac_set_lvl_start : sl_dac_rst_lvl_start);
                  next_wl_loop = wl_loop + (set_rst_loop ? wl_dac_set_lvl_step : wl_dac_rst_lvl_step);
                end
                // Check if WL overflowed or reached maximum, and if so: reset value and increment attempts counter
                if ((next_wl_loop == 0) || (next_wl_loop >= (set_rst_loop ? wl_dac_set_lvl_stop : wl_dac_rst_lvl_stop))) begin
                  next_wl_loop = (set_rst_loop ? wl_dac_set_lvl_start : wl_dac_rst_lvl_start);
                  attempts_counter_incr_en = 1;
                end
              end
              `LOOP_WPB: begin
                // Increment BL
                next_bsl_loop = bsl_loop + (set_rst_loop ? bl_dac_set_lvl_step : sl_dac_rst_lvl_step);
                // Check if BSL overflowed or reached maximum, and if so: reset value and increment PW
                if ((next_bsl_loop == 0) || (next_bsl_loop >= (set_rst_loop ? bl_dac_set_lvl_stop : sl_dac_rst_lvl_stop))) begin
                  next_bsl_loop = (set_rst_loop ? bl_dac_set_lvl_start : sl_dac_rst_lvl_start);
                  next_pw_loop = pw_loop + (set_rst_loop ? pw_set_step : pw_rst_step);
                end
                // Check if PW overflowed or reached maximum, and if so: reset value and increment WL
                if ((next_pw_loop == 0) || (next_pw_loop >= (set_rst_loop ? pw_set_stop : pw_rst_stop))) begin
                  next_pw_loop = (set_rst_loop ? pw_set_start : pw_rst_start);
                  next_wl_loop = wl_loop + (set_rst_loop ? wl_dac_set_lvl_step : wl_dac_rst_lvl_step);
                end
                // Check if WL overflowed or reached maximum, and if so: reset value and increment attempts counter
                if ((next_wl_loop == 0) || (next_wl_loop >= (set_rst_loop ? wl_dac_set_lvl_stop : wl_dac_rst_lvl_stop))) begin
                  next_wl_loop = (set_rst_loop ? wl_dac_set_lvl_start : wl_dac_rst_lvl_start);
                  attempts_counter_incr_en = 1;
                end
              end
              `LOOP_BWP: begin
                // Increment PW
                next_pw_loop = pw_loop + (set_rst_loop ? pw_set_step : pw_rst_step);
                // Check if PW overflowed or reached maximum, and if so: reset value and increment WL
                if ((next_pw_loop == 0) || (next_pw_loop >= (set_rst_loop ? pw_set_stop : pw_rst_stop))) begin
                  next_pw_loop = (set_rst_loop ? pw_set_start : pw_rst_start);
                  next_wl_loop = wl_loop + (set_rst_loop ? wl_dac_set_lvl_step : wl_dac_rst_lvl_step);
                end
                // Check if WL overflowed or reached maximum, and if so: reset value and increment BSL
                if ((next_wl_loop == 0) || (next_wl_loop >= (set_rst_loop ? wl_dac_set_lvl_stop : wl_dac_rst_lvl_stop))) begin
                  next_wl_loop = (set_rst_loop ? wl_dac_set_lvl_start : wl_dac_rst_lvl_start);
                  next_bsl_loop = bsl_loop + (set_rst_loop ? bl_dac_set_lvl_step : sl_dac_rst_lvl_step);
                end
                // Check if BL overflowed or reached maximum, and if so: reset value and increment attempts counter
                if ((next_bsl_loop == 0) || (next_bsl_loop >= (set_rst_loop ? bl_dac_set_lvl_stop : sl_dac_rst_lvl_stop))) begin
                  next_bsl_loop = (set_rst_loop ? bl_dac_set_lvl_start : sl_dac_rst_lvl_start);
                  attempts_counter_incr_en = 1;
                end
              end
              default: begin // `LOOP_BPW
                // Increment WL
                next_wl_loop = wl_loop + (set_rst_loop ? wl_dac_set_lvl_step : wl_dac_rst_lvl_step);
                // Check if WL overflowed or reached maximum, and if so: reset value and increment PW
                if ((next_wl_loop == 0) || (next_wl_loop >= (set_rst_loop ? wl_dac_set_lvl_stop : wl_dac_rst_lvl_stop))) begin
                  next_wl_loop = (set_rst_loop ? wl_dac_set_lvl_start : wl_dac_rst_lvl_start);
                  next_pw_loop = pw_loop + (set_rst_loop ? pw_set_step : pw_rst_step);
                end
                // Check if PW overflowed or reached maximum, and if so: reset value and increment BSL
                if ((next_pw_loop == 0) || (next_pw_loop >= (set_rst_loop ? pw_set_stop : pw_rst_stop))) begin
                  next_pw_loop = (set_rst_loop ? pw_set_start : pw_rst_start);
                  next_bsl_loop = bsl_loop + (set_rst_loop ? bl_dac_set_lvl_step : sl_dac_rst_lvl_step);
                end
                // Check if BL overflowed or reached maximum, and if so: reset value and increment attempts counter
                if ((next_bsl_loop == 0) || (next_bsl_loop >= (set_rst_loop ? bl_dac_set_lvl_stop : sl_dac_rst_lvl_stop))) begin
                  next_bsl_loop = (set_rst_loop ? bl_dac_set_lvl_start : sl_dac_rst_lvl_start);
                  attempts_counter_incr_en = 1;
                end
              end
            endcase
            // Check if attempts counter reached maximum, and if so: reset value and increment failures
            if ((attempts_counter + 1) >= max_attempts) begin
              // If failures are ignored, increment failure counter
              if (ignore_failures) begin
                failure_counter_incr_en = 1;
              end
              // Otherwise, go back to IDLE
              else begin
                next_state = `FSM_STATE_IDLE;                                     // Return to IDLE
              end
            end
            // Check if failures counter overflowed, and if so: go to IDLE
            if (failure_counter == {16{1'b1}}) begin
              next_state = `FSM_STATE_IDLE;                                       // Return to IDLE
            end
          end
        end

        // Setup cycles
        if (counter < write_to_init_read_setup_cycles)                            // Counter for setup cycles
          counter_incr_en = 1;
        else begin
          counter_rst = 1;                                                        // Reset counter
          next_state = ((opcode == `OP_REFRESH) && (mask == 0) && is_first_try && (attempts_counter != 0) && (rangei == num_levels)) ? `FSM_STATE_INIT_READ : `FSM_STATE_READ_WRITE; // Return to WRITE (or READ if REFRESH op and just finished an address)
        end

        // Set signals in preparation for READ
        bl_en = 1; sl_en = 1; wl_en = 1;                                          // WBSL enables
        bleed_en = 1; read_dac_en = 1;                                            // DAC enables
        clamp_ref = adc_clamp_ref_lvl; read_dac_config = adc_read_dac_lvl;        // Read DAC levels
        read_ref = set_rst_loop ? adc_lower_write_ref_lvl : adc_upper_write_ref_lvl; // Read level should be lower write ref level if SET, upper write ref level if RESET
        set_rst = 1;                                                              // Enable SET mode just to get mask matching DI
      end

      // Bad FSM state, go back to IDLE
      default: begin
        next_state = `FSM_STATE_IDLE;
      end
    endcase
  end

  // RRAM busy indicator (if not IDLE)
  assign rram_busy = (state != `FSM_STATE_IDLE);

  // Derive di from mask and set_rst
  // di being HIGH means that SET pulses are applied if set_rst is HIGH
  // di being LOW means that RESET pulses are applied if set_rst is LOW
  assign di = mask ~^ {`WORD_SIZE{set_rst}};

  // FSM full state config bits
  assign fsm_bits = {next_rangei, next_is_first_try, attempts_counter_rst, attempts_counter_incr_en, counter_rst, counter_incr_en, is_first_try, attempts_counter, counter, pw, rangei, wl_en, wl_dac_en, wl_dac_config, we, sl_en, set_rst, sa_en, sa_clk, rram_addr, read_ref, read_dac_en, read_dac_config, di, clamp_ref, bsl_dac_en, bsl_dac_config, bleed_en, bl_en, aclk, next_state, state};

  // FSM diagnostic bits
  assign diag_bits = {reset_counter, set_counter, read_counter, failure_counter, success_counter};
endmodule
