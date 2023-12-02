// The scoreboard is responsible for checking data integrity, serving as a gold
// model. It checks that the pulses received by the analog block correspond
// properly to the commands sent and the settings in the register file.
typedef class fsm_tb_pkt;
typedef class fsm_pulse_pkt;
class fsm_tb_sb;
  // Full-clock time
  localparam CLK = 10;
  
  // Mailboxes
  mailbox drv_mbx;
  mailbox mon_mbx;

  task run();
    forever begin
      // Pulse property declarations
      fsm_pulse_pkt pulse;
      integer we;
      integer exp_we;
      integer setup_cycles;
      integer exp_setup_cycles;
      integer bsl_dac_config;
      integer exp_bsl_dac_config;
      integer wl_dac_config;
      integer exp_wl_dac_config;
      integer read_dac_config;
      integer exp_read_dac_config;
      integer clamp_ref;
      integer exp_clamp_ref;
      integer read_ref;
      integer exp_read_ref;
      logic set_rst;
      logic exp_set_rst;
      logic [`WORD_SIZE-1:0] di;
      logic [`WORD_SIZE-1:0] exp_di;
      integer rram_addr;
      integer exp_rram_addr;
      integer pw;
      integer exp_pw_float;
      integer exp_pw;
      time last_tf;
      integer rangei;
      integer i;
      logic is_first;
      logic is_first_try;
      integer attempts;
      logic [`WORD_SIZE-1:0] mask;
      integer exp_wl;
      integer exp_bsl;
      integer v1; integer v1_start; integer v1_stop; integer v1_step;
      integer v2; integer v2_start; integer v2_stop; integer v2_step;
      integer v3; integer v3_start; integer v3_stop; integer v3_step;
      integer failures;
      logic [`PROG_CNFG_RANGES_LOG2_N-1:0] write_data [`WORD_SIZE-1:0];
      integer cb_data_bits [`WORD_SIZE-1:0];
      logic [`WORD_SIZE-1:0] lfsr_data_bits [`PROG_CNFG_RANGES_LOG2_N-1:0];
      logic [`WORD_SIZE-1:0] lfsr_data_bits_q0 [5:0] = {48'h323E_CF92B86E, 48'hEE8A_4456CA4F, 48'h3D4E_9378518B, 48'hF2A6_1FD130D2, 48'h50A2_A45E5490, 48'hD603_AF1733C2};
      logic [`WORD_SIZE-1:0] lfsr_data_bits_q1 [5:0] = {48'hCF13_2F6A90EB, 48'h9ABA_7C9D612C, 48'h7042_6B321B5D, 48'h54C7_D2AE1A0D, 48'hFFD2_1983FD7A, 48'h7C16_2490C6B1};
      logic [`WORD_SIZE-1:0] lfsr_data_bits_q2 [5:0] = {48'hE0E7_FE08304F, 48'hE38F_C8EC001C, 48'h823F_EC4ED87E, 48'hAEA9_1572483C, 48'hCDDD_FA5EB99B, 48'h1A6C_11026DE6};
      logic [`WORD_SIZE-1:0] lfsr_data_bits_q3 [5:0] = {48'hE106_63CC2D95, 48'hDAF7_EC63E56E, 48'hBAF8_7DED2588, 48'h99E5_84C9526C, 48'h807A_DDDAF8A7, 48'hAB8C_15521026};
      
      // Get request from mailbox
      fsm_tb_pkt req;
      drv_mbx.get(req);
      req.print("FSM Scoreboard");

      // Initialize last tf to be the beginning of the request
      last_tf = req.ti;

      // Initialize is_first
      is_first = 1;

      // Process request
      case (req.opcode)
        // Test pulse operation
        `OP_TEST_PULSE: begin
          assert(mon_mbx.try_get(pulse)) else begin
            $error("T=%0t [FSM Scoreboard] ERROR! Did not receive enough pulse packets", $time);
            $fatal;
          end
          we = pulse.we;
          exp_we = 1;
          setup_cycles = (pulse.ti - last_tf) / CLK;
          exp_setup_cycles = req.idle_to_init_write_setup_cycles + 1;
          bsl_dac_config = pulse.bsl_dac_config;
          exp_bsl_dac_config = req.set_first ? req.bl_dac_set_lvl_cycle : req.sl_dac_rst_lvl_cycle;
          wl_dac_config = pulse.wl_dac_config;
          exp_wl_dac_config = req.set_first ? req.wl_dac_set_lvl_cycle : req.wl_dac_rst_lvl_cycle;
          set_rst = pulse.set_rst;
          exp_set_rst = req.set_first;
          di = pulse.di;
          exp_di = req.di_init_mask ~^ {`WORD_SIZE{req.set_first}};
          rram_addr = pulse.rram_addr;
          exp_rram_addr = req.address_start;
          pw = pulse.pw;
          exp_pw_float = req.set_first ? req.pw_set_cycle : req.pw_rst_cycle;
          exp_pw = `defloat(exp_pw_float);
          assert(we == exp_we) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect write pulse type, exp=%0d act=%0d", pulse.ti, exp_we, we); 
          assert(setup_cycles == exp_setup_cycles) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect number of setup cycles, exp=%0d act=%0d", pulse.ti, exp_setup_cycles, setup_cycles);
          assert(bsl_dac_config == exp_bsl_dac_config) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect BSL DAC config value, exp=%0d act=%0d", pulse.ti, exp_bsl_dac_config, bsl_dac_config);
          assert(wl_dac_config == exp_wl_dac_config) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect WL DAC config value, exp=%0d act=%0d", pulse.ti, exp_wl_dac_config, wl_dac_config);
          assert(set_rst == exp_set_rst) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect SET/RST, exp=%0d act=%0d", pulse.ti, exp_set_rst, set_rst);
          assert(di == exp_di) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect data in value, exp=0x%0h act=0x%0h", pulse.ti, exp_di, di);
          assert(rram_addr == exp_rram_addr) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect RRAM address, exp=%0d act=%0d", pulse.ti, exp_rram_addr, rram_addr);
          assert(pw == exp_pw) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect PW, pw=%0d expfloat=%0b exp=%0b act=%0b", pulse.ti, pulse.pw, exp_pw_float, exp_pw, pw);
          assert(mon_mbx.num() == 0) else $error("T=%0t [FSM Scoreboard] ERROR! Extraneous %0d pulse packet(s) found", $time, mon_mbx.num());
        end

        // Test read operation
        `OP_TEST_READ: begin
          assert(mon_mbx.try_get(pulse)) else begin
            $error("T=%0t [FSM Scoreboard] ERROR! Did not receive enough pulse packets", $time);
            $fatal;
          end
          we = pulse.we;
          exp_we = 0;
          setup_cycles = (pulse.ti - last_tf) / CLK;
          exp_setup_cycles = req.idle_to_init_read_setup_cycles + 1;
          wl_dac_config = pulse.wl_dac_config;
          read_dac_config = pulse.read_dac_config;
          exp_read_dac_config = req.adc_read_dac_lvl[0];
          clamp_ref = pulse.clamp_ref;
          exp_clamp_ref = req.adc_clamp_ref_lvl[0];
          read_ref = pulse.read_ref;
          exp_read_ref = req.adc_upper_read_ref_lvl[0];
          di = pulse.di;
          exp_di = req.di_init_mask;
          rram_addr = pulse.rram_addr;
          exp_rram_addr = req.address_start;
          assert(we == exp_we) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect write pulse type, exp=%0d act=%0d", pulse.ti, exp_we, we); 
          assert(setup_cycles == exp_setup_cycles) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect number of setup cycles, exp=%0d act=%0d", pulse.ti, exp_setup_cycles, setup_cycles);
          assert(read_dac_config == exp_read_dac_config) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect READ DAC config value, exp=%0d act=%0d", pulse.ti, exp_read_dac_config, read_dac_config);
          assert(clamp_ref == exp_clamp_ref) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect clamp ref config value, exp=%0d act=%0d", pulse.ti, exp_clamp_ref, clamp_ref);
          assert(read_ref == exp_read_ref) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect read ref value, exp=%0d act=%0d", pulse.ti, exp_read_ref, read_ref);
          assert(di == exp_di) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect data in value, exp=0x%0h act=0x%0h", pulse.ti, exp_di, di);
          assert(rram_addr == exp_rram_addr) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect RRAM address, exp=%0d act=%0d", pulse.ti, exp_rram_addr, rram_addr);
          assert(mon_mbx.num() == 0) else $error("T=%0t [FSM Scoreboard] ERROR! Extraneous %0d pulse packet(s) found", $time, mon_mbx.num());
        end

        // Cycle operation
        `OP_CYCLE: begin
          // Across addresses
          for (exp_rram_addr = req.address_start; exp_rram_addr <= req.address_stop; exp_rram_addr = exp_rram_addr + req.address_step) begin
            // Cycle counting
            for (i = 0; i < `defloat(req.max_attempts); i += 1) begin
              // First pulse
              assert(mon_mbx.try_get(pulse)) else begin
                $error("T=%0t [FSM Scoreboard] ERROR! Did not receive enough pulse packets", $time);
                $fatal;
              end
              we = pulse.we;
              exp_we = 1;
              setup_cycles = (pulse.ti - last_tf) / CLK;
              exp_setup_cycles = is_first ? (req.idle_to_init_write_setup_cycles + 1) : (req.step_write_setup_cycles + 2); is_first = 0;
              bsl_dac_config = pulse.bsl_dac_config;
              exp_bsl_dac_config = req.set_first ? req.bl_dac_set_lvl_cycle : req.sl_dac_rst_lvl_cycle;
              wl_dac_config = pulse.wl_dac_config;
              exp_wl_dac_config = req.set_first ? req.wl_dac_set_lvl_cycle : req.wl_dac_rst_lvl_cycle;
              set_rst = pulse.set_rst;
              exp_set_rst = req.set_first;
              di = pulse.di;
              exp_di = req.di_init_mask ~^ {`WORD_SIZE{req.set_first}};
              rram_addr = pulse.rram_addr;
              pw = pulse.pw;
              exp_pw_float = req.set_first ? req.pw_set_cycle : req.pw_rst_cycle;
              exp_pw = `defloat(exp_pw_float);
              assert(we == exp_we) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect write pulse type, exp=%0d act=%0d", pulse.ti, exp_we, we); 
              assert(setup_cycles == exp_setup_cycles) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect number of setup cycles, exp=%0d act=%0d", pulse.ti, exp_setup_cycles, setup_cycles);
              assert(bsl_dac_config == exp_bsl_dac_config) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect BSL DAC config value, exp=%0d act=%0d", pulse.ti, exp_bsl_dac_config, bsl_dac_config);
              assert(wl_dac_config == exp_wl_dac_config) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect WL DAC config value, exp=%0d act=%0d", pulse.ti, exp_wl_dac_config, wl_dac_config);
              assert(set_rst == exp_set_rst) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect SET/RST, exp=%0d act=%0d", pulse.ti, exp_set_rst, set_rst);
              assert(di == exp_di) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect data in value, exp=0x%0h act=0x%0h", pulse.ti, exp_di, di);
              assert(rram_addr == exp_rram_addr) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect RRAM address, exp=%0d act=%0d", pulse.ti, exp_rram_addr, rram_addr);
              assert(pw == exp_pw) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect PW, pw=%0d expfloat=%0b exp=%0b act=%0b", pulse.ti, pulse.pw, exp_pw_float, exp_pw, pw);

              // Update last tf
              last_tf = pulse.tf;

              // Second pulse
              assert(mon_mbx.try_get(pulse)) else begin
                $error("T=%0t [FSM Scoreboard] ERROR! Did not receive enough pulse packets", $time);
                $fatal;
              end
              we = pulse.we;
              exp_we = 1;
              setup_cycles = (pulse.ti - last_tf) / CLK;
              exp_setup_cycles = req.step_write_setup_cycles + 2;
              bsl_dac_config = pulse.bsl_dac_config;
              exp_bsl_dac_config = (!req.set_first) ? req.bl_dac_set_lvl_cycle : req.sl_dac_rst_lvl_cycle;
              wl_dac_config = pulse.wl_dac_config;
              exp_wl_dac_config = (!req.set_first) ? req.wl_dac_set_lvl_cycle : req.wl_dac_rst_lvl_cycle;
              set_rst = pulse.set_rst;
              exp_set_rst = !req.set_first;
              di = pulse.di;
              exp_di = req.di_init_mask ~^ {`WORD_SIZE{~req.set_first}};
              rram_addr = pulse.rram_addr;
              pw = pulse.pw;
              exp_pw_float = (!req.set_first) ? req.pw_set_cycle : req.pw_rst_cycle;
              exp_pw = `defloat(exp_pw_float);
              assert(we == exp_we) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect write pulse type, exp=%0d act=%0d", pulse.ti, exp_we, we); 
              assert(setup_cycles == exp_setup_cycles) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect number of setup cycles, exp=%0d act=%0d", pulse.ti, exp_setup_cycles, setup_cycles);
              assert(bsl_dac_config == exp_bsl_dac_config) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect BSL DAC config value, exp=%0d act=%0d", pulse.ti, exp_bsl_dac_config, bsl_dac_config);
              assert(wl_dac_config == exp_wl_dac_config) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect WL DAC config value, exp=%0d act=%0d", pulse.ti, exp_wl_dac_config, wl_dac_config);
              assert(set_rst == exp_set_rst) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect SET/RST, exp=%0d act=%0d", pulse.ti, exp_set_rst, set_rst);
              assert(di == exp_di) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect data in value, exp=0x%0h act=0x%0h", pulse.ti, exp_di, di);
              assert(rram_addr == exp_rram_addr) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect RRAM address, exp=%0d act=%0d", pulse.ti, exp_rram_addr, rram_addr);
              assert(pw == exp_pw) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect PW, pw=%0d expfloat=%0b exp=%0b act=%0b", pulse.ti, pulse.pw, exp_pw_float, exp_pw, pw);

              // Update last tf
              last_tf = pulse.tf;
            end

            // Break if not doing multiple addresses
            if (!req.use_multi_addrs) break;
          end
          
          // Check for extraneous packets
          assert(mon_mbx.num() == 0) else $error("T=%0t [FSM Scoreboard] ERROR! Extraneous %0d pulse packet(s) found", $time, mon_mbx.num());
        end

        // Read operation
        `OP_READ: begin
          // Pulse verification
          for (rangei = 0; rangei < `PROG_CNFG_RANGES_LOG2_N'(req.num_levels-1); rangei += 1) begin
            assert(mon_mbx.try_get(pulse)) else begin
              $error("T=%0t [FSM Scoreboard] ERROR! Did not receive enough pulse packets", $time);
              $fatal;
            end
            we = pulse.we;
            exp_we = 0;
            setup_cycles = (pulse.ti - last_tf) / CLK;
            exp_setup_cycles = (rangei == 0) ? (req.idle_to_init_read_setup_cycles + 1) : (req.step_read_setup_cycles + req.post_read_setup_cycles + 1);
            wl_dac_config = pulse.wl_dac_config;
            read_dac_config = pulse.read_dac_config;
            exp_read_dac_config = req.adc_read_dac_lvl[rangei];
            clamp_ref = pulse.clamp_ref;
            exp_clamp_ref = req.adc_clamp_ref_lvl[rangei];
            read_ref = pulse.read_ref;
            exp_read_ref = req.adc_upper_read_ref_lvl[rangei];
            di = pulse.di;
            if (rangei == 0) exp_di = req.di_init_mask;
            rram_addr = pulse.rram_addr;
            exp_rram_addr = req.address_start;
            assert(we == exp_we) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect write pulse type, exp=%0d act=%0d", pulse.ti, exp_we, we); 
            assert(setup_cycles == exp_setup_cycles) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect number of setup cycles, exp=%0d act=%0d", pulse.ti, exp_setup_cycles, setup_cycles);
            assert(read_dac_config == exp_read_dac_config) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect READ DAC config value, exp=%0d act=%0d", pulse.ti, exp_read_dac_config, read_dac_config);
            assert(clamp_ref == exp_clamp_ref) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect clamp ref config value, exp=%0d act=%0d", pulse.ti, exp_clamp_ref, clamp_ref);
            assert(read_ref == exp_read_ref) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect read ref value, exp=%0d act=%0d", pulse.ti, exp_read_ref, read_ref);
            assert(di == exp_di) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect data in value, exp=0x%0h act=0x%0h", pulse.ti, exp_di, di);
            assert(rram_addr == exp_rram_addr) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect RRAM address, exp=%0d act=%0d", pulse.ti, exp_rram_addr, rram_addr);

            // Update expected di
            exp_di = exp_di & pulse.sa_do;

            // Update last tf
            last_tf = pulse.tf;

            // Break if no more bits left
            if (exp_di == 0) break;
          end

          // Functional verification: ensure that the values read are consistent with conductance values and read range boundaries
          for (i = 0; i < `WORD_SIZE; i += 1) begin
            if (~req.di_init_mask[i]) continue; // ignore if masked initially
            rangei = {req.read_data_bits[3][i], req.read_data_bits[2][i], req.read_data_bits[1][i], req.read_data_bits[0][i]}; // reshape level
            read_ref = (rangei != 0) ? req.adc_upper_read_ref_lvl[rangei-1] : 0;
            assert(req.g[exp_rram_addr][i] >= read_ref) else $error("T=%0t [FSM Scoreboard] ERROR! Conductance readout lower bound mismatch, addr=%0d i=%0d rangei=%0d g=%0d bound=%0d", $time, rram_addr, i, rangei, req.g[exp_rram_addr][i], read_ref);
            read_ref = (rangei != `PROG_CNFG_RANGES_LOG2_N'(req.num_levels-1)) ? req.adc_upper_read_ref_lvl[rangei] : 2**`ADC_BITS_N;
            assert(req.g[exp_rram_addr][i] < read_ref) else $error("T=%0t [FSM Scoreboard] ERROR! Conductance readout upper bound mismatch, addr=%0d i=%0d rangei=%0d g=%0d bound=%0d", $time, rram_addr, i, rangei, req.g[exp_rram_addr][i], read_ref);
          end

          // Check for extraneous packets
          assert(mon_mbx.num() == 0) else $error("T=%0t [FSM Scoreboard] ERROR! Extraneous %0d pulse packet(s) found", $time, mon_mbx.num());
        end

        // Write operation
        `OP_WRITE: begin
          // Initialize failures
          failures = 0;

          // Pulse verification
          for (exp_rram_addr = req.address_start; exp_rram_addr <= req.address_stop; exp_rram_addr = exp_rram_addr + req.address_step) begin
            // Break if not using multiple addresses and not on first
            if ((~req.use_multi_addrs) & exp_rram_addr != req.address_start) break;

            // Initialize write data
            lfsr_data_bits[0] =                                                       lfsr_data_bits_q0[(exp_rram_addr - req.address_start) / req.address_step];
            lfsr_data_bits[1] = ((req.num_levels > 4'd2) || (req.num_levels == 0))  ? lfsr_data_bits_q1[(exp_rram_addr - req.address_start) / req.address_step] : 0;
            lfsr_data_bits[2] = ((req.num_levels > 4'd4) || (req.num_levels == 0))  ? lfsr_data_bits_q2[(exp_rram_addr - req.address_start) / req.address_step] : 0;
            lfsr_data_bits[3] = (req.num_levels == 0)                               ? lfsr_data_bits_q3[(exp_rram_addr - req.address_start) / req.address_step] : 0;
            for (i = 0; i < `WORD_SIZE; i=i+1) begin
              cb_data_bits[i] = (((exp_rram_addr - req.address_start) / req.address_step + i) % ((req.num_levels == 0) ? 16 : req.num_levels));
              write_data[i] = req.use_cb_data ? cb_data_bits[i] : req.use_lfsr_data ? {lfsr_data_bits[3][i], lfsr_data_bits[2][i], lfsr_data_bits[1][i], lfsr_data_bits[0][i]} : {req.write_data_bits[3][i], req.write_data_bits[2][i], req.write_data_bits[1][i], req.write_data_bits[0][i]};
            end

            // Loop over ranges
            for (rangei = 0; rangei < `PROG_CNFG_RANGES_LOG2_N'(req.num_levels-1) + 1; rangei = rangei + 1) begin
              // Initialize loop variables
              attempts = 0;
              exp_set_rst = req.set_first;
              exp_wl = exp_set_rst ? req.wl_dac_set_lvl_start[rangei] : req.wl_dac_rst_lvl_start[rangei];
              exp_bsl = exp_set_rst ? req.bl_dac_set_lvl_start[rangei] : req.sl_dac_rst_lvl_start[rangei];
              exp_pw = exp_set_rst ? `defloat(req.pw_set_start[rangei]) : `defloat(req.pw_rst_start[rangei]);
              is_first_try = 1;
              mask = req.di_init_mask;

              // Initialize mask based on bits to be written
              for (i = 0; i < `WORD_SIZE; i=i+1) begin
                if (write_data[i] != rangei) begin
                  mask[i] = 0;
                end
              end

              // Increment stuff
              while (1) begin
                // Do READ
                assert(mon_mbx.try_get(pulse)) else begin
                  $error("T=%0t [FSM Scoreboard] ERROR! Did not receive enough pulse packets", $time);
                  $fatal;
                end
                we = pulse.we;
                exp_we = 0;
                setup_cycles = (pulse.ti - last_tf) / CLK;
                exp_setup_cycles = is_first ? (req.idle_to_init_read_setup_cycles + 1) : (req.write_to_init_read_setup_cycles + 2); is_first = 0;
                wl_dac_config = pulse.wl_dac_config;
                read_dac_config = pulse.read_dac_config;
                exp_read_dac_config = req.adc_read_dac_lvl[rangei];
                clamp_ref = pulse.clamp_ref;
                exp_clamp_ref = req.adc_clamp_ref_lvl[rangei];
                read_ref = pulse.read_ref;
                exp_read_ref = exp_set_rst ? req.adc_lower_write_ref_lvl[rangei] : req.adc_upper_write_ref_lvl[rangei];
                di = pulse.di;
                rram_addr = pulse.rram_addr;
                assert(we == exp_we) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect write pulse type, exp=%0d act=%0d", pulse.ti, exp_we, we); 
                assert(setup_cycles == exp_setup_cycles) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect number of setup cycles, exp=%0d act=%0d", pulse.ti, exp_setup_cycles, setup_cycles);
                assert(read_dac_config == exp_read_dac_config) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect READ DAC config value, exp=%0d act=%0d", pulse.ti, exp_read_dac_config, read_dac_config);
                assert(clamp_ref == exp_clamp_ref) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect clamp ref config value, exp=%0d act=%0d", pulse.ti, exp_clamp_ref, clamp_ref);
                assert(read_ref == exp_read_ref) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect read ref value, exp=%0d act=%0d", pulse.ti, exp_read_ref, read_ref);
                assert(di == mask) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect data in value, exp=0x%0h act=0x%0h", pulse.ti, mask, di);
                assert(rram_addr == exp_rram_addr) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect RRAM address, exp=%0d act=%0d", pulse.ti, exp_rram_addr, rram_addr);

                // Update expected di mask
                mask = mask & (exp_set_rst ? ~pulse.sa_do : pulse.sa_do);
                if (req.check63 && (exp_read_ref == 63) && !exp_set_rst) mask = 0; // trick to allow conductances above 63

                // Update last tf
                last_tf = pulse.tf + req.post_read_setup_cycles * CLK;

                // Do write pulse only if mask is not 0
                if (mask != 0) begin
                  // No longer first try
                  is_first_try = 0;

                  // Write pulse
                  assert(mon_mbx.try_get(pulse)) else begin
                    $error("T=%0t [FSM Scoreboard] ERROR! Did not receive enough pulse packets", $time);
                    $fatal;
                  end
                  we = pulse.we;
                  exp_we = 1;
                  setup_cycles = (pulse.ti - last_tf) / CLK;
                  exp_setup_cycles = req.read_to_init_write_setup_cycles + 1;
                  bsl_dac_config = pulse.bsl_dac_config;
                  exp_bsl_dac_config = exp_bsl;
                  wl_dac_config = pulse.wl_dac_config;
                  exp_wl_dac_config = exp_wl;
                  set_rst = pulse.set_rst;
                  di = pulse.di;
                  exp_di = mask ~^ {`WORD_SIZE{exp_set_rst}};
                  rram_addr = pulse.rram_addr;
                  pw = pulse.pw;
                  assert(we == exp_we) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect write pulse type, exp=%0d act=%0d", pulse.ti, exp_we, we); 
                  assert(setup_cycles == exp_setup_cycles) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect number of setup cycles, exp=%0d act=%0d", pulse.ti, exp_setup_cycles, setup_cycles);
                  assert(bsl_dac_config == exp_bsl_dac_config) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect BSL DAC config value, exp=%0d act=%0d", pulse.ti, exp_bsl_dac_config, bsl_dac_config);
                  assert(wl_dac_config == exp_wl_dac_config) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect WL DAC config value, exp=%0d act=%0d", pulse.ti, exp_wl_dac_config, wl_dac_config);
                  assert(set_rst == exp_set_rst) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect SET/RST, exp=%0d act=%0d", pulse.ti, exp_set_rst, set_rst);
                  assert(di == exp_di) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect data in value, exp=0x%0h act=0x%0h", pulse.ti, exp_di, di);
                  assert(rram_addr == exp_rram_addr) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect RRAM address, exp=%0d act=%0d", pulse.ti, exp_rram_addr, rram_addr);
                  assert(pw == exp_pw) else $error("T=%0t [FSM Scoreboard] ERROR! Incorrect PW, pw=%0d exp=%0d act=%0d", pulse.ti, pulse.pw, exp_pw, pw);

                  // Update last tf
                  last_tf = pulse.tf;

                  // Increment attempts
                  if (exp_we) begin
                    attempts += 1;
                  end
                end
                // If mask is 0, then SET/RESET process is done, move on
                else begin
                  // If first try and not first attempt, or number of attempts timed out, then done with level
                  if ((is_first_try & ((attempts != 0) | (exp_set_rst != req.set_first))) | ((attempts >= `defloat(req.max_attempts)) & req.ignore_failures)) begin
                    break;
                  end
                  
                  // Switch SET/RESET loop
                  exp_set_rst = !exp_set_rst;

                  // Reinitialize loop variables
                  exp_wl = exp_set_rst ? req.wl_dac_set_lvl_start[rangei] : req.wl_dac_rst_lvl_start[rangei];
                  exp_bsl = exp_set_rst ? req.bl_dac_set_lvl_start[rangei] : req.sl_dac_rst_lvl_start[rangei];
                  exp_pw = exp_set_rst ? `defloat(req.pw_set_start[rangei]) : `defloat(req.pw_rst_start[rangei]);
                  is_first_try = 1;
                  mask = req.di_init_mask;

                  // Initialize mask based on bits to be written
                  for (i = 0; i < `WORD_SIZE; i=i+1) begin
                    if (write_data[i] != rangei) begin
                      mask[i] = 0;
                    end
                  end

                  // Continue to avoid updating loop variables
                  continue;
                end

                // Get "pointers" (v1, v2, v3) to the three loop variables based on loop order
                case (exp_set_rst ? req.loop_order_set[rangei] : req.loop_order_rst[rangei])
                  `LOOP_PWB: begin
                    v1 = exp_pw; v1_start = exp_set_rst ? req.pw_set_start[rangei]: req.pw_rst_start[rangei]; v1_stop = exp_set_rst ? req.pw_set_stop[rangei] : req.pw_rst_stop[rangei]; v1_step = exp_set_rst ? req.pw_set_step[rangei] : req.pw_rst_step[rangei]; 
                    v2 = exp_wl; v2_start = exp_set_rst ? req.wl_dac_set_lvl_start[rangei] : req.wl_dac_rst_lvl_start[rangei]; v2_stop = exp_set_rst ? req.wl_dac_set_lvl_stop[rangei] : req.wl_dac_rst_lvl_stop[rangei]; v2_step = exp_set_rst ? req.wl_dac_set_lvl_step[rangei] : req.wl_dac_rst_lvl_step[rangei]; 
                    v3 = exp_bsl; v3_start = exp_set_rst ? req.bl_dac_set_lvl_start[rangei] : req.sl_dac_rst_lvl_start[rangei]; v3_stop = exp_set_rst ? req.bl_dac_set_lvl_stop[rangei] : req.sl_dac_rst_lvl_stop[rangei]; v3_step = exp_set_rst ? req.bl_dac_set_lvl_step[rangei] : req.sl_dac_rst_lvl_step[rangei]; 
                  end
                  `LOOP_PBW: begin
                    v1 = exp_pw; v1_start = exp_set_rst ? req.pw_set_start[rangei]: req.pw_rst_start[rangei]; v1_stop = exp_set_rst ? req.pw_set_stop[rangei] : req.pw_rst_stop[rangei]; v1_step = exp_set_rst ? req.pw_set_step[rangei] : req.pw_rst_step[rangei]; 
                    v2 = exp_bsl; v2_start = exp_set_rst ? req.bl_dac_set_lvl_start[rangei] : req.sl_dac_rst_lvl_start[rangei]; v2_stop = exp_set_rst ? req.bl_dac_set_lvl_stop[rangei] : req.sl_dac_rst_lvl_stop[rangei]; v2_step = exp_set_rst ? req.bl_dac_set_lvl_step[rangei] : req.sl_dac_rst_lvl_step[rangei]; 
                    v3 = exp_wl; v3_start = exp_set_rst ? req.wl_dac_set_lvl_start[rangei] : req.wl_dac_rst_lvl_start[rangei]; v3_stop = exp_set_rst ? req.wl_dac_set_lvl_stop[rangei] : req.wl_dac_rst_lvl_stop[rangei]; v3_step = exp_set_rst ? req.wl_dac_set_lvl_step[rangei] : req.wl_dac_rst_lvl_step[rangei]; 
                  end
                  `LOOP_WBP: begin
                    v1 = exp_wl; v1_start = exp_set_rst ? req.wl_dac_set_lvl_start[rangei] : req.wl_dac_rst_lvl_start[rangei]; v1_stop = exp_set_rst ? req.wl_dac_set_lvl_stop[rangei] : req.wl_dac_rst_lvl_stop[rangei]; v1_step = exp_set_rst ? req.wl_dac_set_lvl_step[rangei] : req.wl_dac_rst_lvl_step[rangei];
                    v2 = exp_bsl; v2_start = exp_set_rst ? req.bl_dac_set_lvl_start[rangei] : req.sl_dac_rst_lvl_start[rangei]; v2_stop = exp_set_rst ? req.bl_dac_set_lvl_stop[rangei] : req.sl_dac_rst_lvl_stop[rangei]; v2_step = exp_set_rst ? req.bl_dac_set_lvl_step[rangei] : req.sl_dac_rst_lvl_step[rangei]; 
                    v3 = exp_pw; v3_start = exp_set_rst ? req.pw_set_start[rangei]: req.pw_rst_start[rangei]; v3_stop = exp_set_rst ? req.pw_set_stop[rangei] : req.pw_rst_stop[rangei]; v3_step = exp_set_rst ? req.pw_set_step[rangei] : req.pw_rst_step[rangei]; 
                  end
                  `LOOP_WPB: begin
                    v1 = exp_wl; v1_start = exp_set_rst ? req.wl_dac_set_lvl_start[rangei] : req.wl_dac_rst_lvl_start[rangei]; v1_stop = exp_set_rst ? req.wl_dac_set_lvl_stop[rangei] : req.wl_dac_rst_lvl_stop[rangei]; v1_step = exp_set_rst ? req.wl_dac_set_lvl_step[rangei] : req.wl_dac_rst_lvl_step[rangei];
                    v2 = exp_pw; v2_start = exp_set_rst ? req.pw_set_start[rangei]: req.pw_rst_start[rangei]; v2_stop = exp_set_rst ? req.pw_set_stop[rangei] : req.pw_rst_stop[rangei]; v2_step = exp_set_rst ? req.pw_set_step[rangei] : req.pw_rst_step[rangei]; 
                    v3 = exp_bsl; v3_start = exp_set_rst ? req.bl_dac_set_lvl_start[rangei] : req.sl_dac_rst_lvl_start[rangei]; v3_stop = exp_set_rst ? req.bl_dac_set_lvl_stop[rangei] : req.sl_dac_rst_lvl_stop[rangei]; v3_step = exp_set_rst ? req.bl_dac_set_lvl_step[rangei] : req.sl_dac_rst_lvl_step[rangei]; 
                  end
                  `LOOP_BWP: begin
                    v1 = exp_bsl; v1_start = exp_set_rst ? req.bl_dac_set_lvl_start[rangei] : req.sl_dac_rst_lvl_start[rangei]; v1_stop = exp_set_rst ? req.bl_dac_set_lvl_stop[rangei] : req.sl_dac_rst_lvl_stop[rangei]; v1_step = exp_set_rst ? req.bl_dac_set_lvl_step[rangei] : req.sl_dac_rst_lvl_step[rangei]; 
                    v2 = exp_wl; v2_start = exp_set_rst ? req.wl_dac_set_lvl_start[rangei] : req.wl_dac_rst_lvl_start[rangei]; v2_stop = exp_set_rst ? req.wl_dac_set_lvl_stop[rangei] : req.wl_dac_rst_lvl_stop[rangei]; v2_step = exp_set_rst ? req.wl_dac_set_lvl_step[rangei] : req.wl_dac_rst_lvl_step[rangei]; 
                    v3 = exp_pw; v3_start = exp_set_rst ? req.pw_set_start[rangei]: req.pw_rst_start[rangei]; v3_stop = exp_set_rst ? req.pw_set_stop[rangei] : req.pw_rst_stop[rangei]; v3_step = exp_set_rst ? req.pw_set_step[rangei] : req.pw_rst_step[rangei]; 
                  end
                  `LOOP_BPW: begin
                    v1 = exp_bsl; v1_start = exp_set_rst ? req.bl_dac_set_lvl_start[rangei] : req.sl_dac_rst_lvl_start[rangei]; v1_stop = exp_set_rst ? req.bl_dac_set_lvl_stop[rangei] : req.sl_dac_rst_lvl_stop[rangei]; v1_step = exp_set_rst ? req.bl_dac_set_lvl_step[rangei] : req.sl_dac_rst_lvl_step[rangei]; 
                    v2 = exp_pw; v2_start = exp_set_rst ? req.pw_set_start[rangei]: req.pw_rst_start[rangei]; v2_stop = exp_set_rst ? req.pw_set_stop[rangei] : req.pw_rst_stop[rangei]; v2_step = exp_set_rst ? req.pw_set_step[rangei] : req.pw_rst_step[rangei]; 
                    v3 = exp_wl; v3_start = exp_set_rst ? req.wl_dac_set_lvl_start[rangei] : req.wl_dac_rst_lvl_start[rangei]; v3_stop = exp_set_rst ? req.wl_dac_set_lvl_stop[rangei] : req.wl_dac_rst_lvl_stop[rangei]; v3_step = exp_set_rst ? req.wl_dac_set_lvl_step[rangei] : req.wl_dac_rst_lvl_step[rangei]; 
                  end
                endcase

                // Update loop variables
                // Check if v3 overflowed or reached maximum, and if so: reset value and increment v2
                v3 += v3_step;
                if (v3 >= v3_stop) begin
                  v3 = v3_start;
                  v2 += v2_step;
                end
                // Check if v2 overflowed or reached maximum, and if so: reset value and increment v1
                if (v2 >= v2_stop) begin
                  v2 = v2_start;
                  v1 += v1_step;
                end
                // Check if v1 overflowed or reached maximum, and if so: reset value and increment attempts counter
                if (v1 >= v1_stop) begin
                  v1 = v1_start;
                end
                // Check if attempts counter reached maximum, and if so: reset value and increment failures
                if (attempts >= `defloat(req.max_attempts)) begin
                  // // Display that max attempts have been reached
                  // $info("T=%0t [FSM Scoreboard] Maximum number of attempts reached, attempts=%0d max_attempts=%0d", pulse.ti, attempts, `defloat(req.max_attempts));

                  // If failures are ignored, increment failure counter
                  if (req.ignore_failures) begin
                    failures += 1;
                    mask = 0;
                  end
                  else break;
                end

                // Write loop variable "pointers" back
                case (exp_set_rst ? req.loop_order_set[rangei] : req.loop_order_rst[rangei])
                  `LOOP_PWB: begin
                    exp_pw = v1;
                    exp_wl = v2;
                    exp_bsl = v3;
                  end
                  `LOOP_PBW: begin
                    exp_pw = v1;
                    exp_bsl = v2;
                    exp_wl = v3;
                  end
                  `LOOP_WBP: begin
                    exp_wl = v1;
                    exp_bsl = v2;
                    exp_pw = v3;
                  end
                  `LOOP_WPB: begin
                    exp_wl = v1;
                    exp_pw = v2;
                    exp_bsl = v3;
                  end
                  `LOOP_BWP: begin
                    exp_bsl = v1;
                    exp_wl = v2;
                    exp_pw = v3;
                  end
                  `LOOP_BPW: begin
                    exp_bsl = v1;
                    exp_pw = v2;
                    exp_wl = v3;
                  end
                endcase
              end

              // Break when not ignoring failures
              if ((attempts >= `defloat(req.max_attempts)) & !req.ignore_failures) break;
            end

            // Break when not ignoring failures
            if ((attempts >= `defloat(req.max_attempts)) & !req.ignore_failures) break;

            // Functional verification: upon success, ensure that the values written are consistent with conductance values and write range boundaries
            if (failures == 0) begin
              for (i = 0; i < `WORD_SIZE; i += 1) begin
                if (~req.di_init_mask[i]) continue; // ignore if masked initially
                rangei = write_data[i];
                read_ref = req.adc_lower_write_ref_lvl[rangei];
                assert(req.g[exp_rram_addr][i] >= read_ref) else $error("T=%0t [FSM Scoreboard] ERROR! Conductance readout lower bound mismatch, addr=%0d i=%0d rangei=%0d g=%0d bound=%0d", $time, rram_addr, i, rangei, req.g[exp_rram_addr][i], read_ref);
                read_ref = req.adc_upper_write_ref_lvl[rangei];
                assert(req.g[exp_rram_addr][i] < read_ref) else $error("T=%0t [FSM Scoreboard] ERROR! Conductance readout upper bound mismatch, addr=%0d i=%0d rangei=%0d g=%0d bound=%0d", $time, rram_addr, i, rangei, req.g[exp_rram_addr][i], read_ref);
              end
            end
          end

          // Check for extraneous packets
          assert(mon_mbx.num() == 0) else $error("T=%0t [FSM Scoreboard] ERROR! Extraneous %0d pulse packet(s) found", pulse.ti, mon_mbx.num());
        end

        // `OP_REFRESH: begin
        // end
      endcase
    end
  endtask
endclass
