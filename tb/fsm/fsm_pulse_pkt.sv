// This is the base transaction object that will be used
// in the environment to send pulse data to the scoreboard
class fsm_pulse_pkt;
  // Pulse packet
  bit     [`BSL_DAC_BITS_N-1:0]               bsl_dac_config;
  bit     [`ADC_BITS_N-1:0]                   clamp_ref;
  bit     [`WORD_SIZE-1:0]                    di;
  bit     [`PW_FULL_BITS_N-1:0]               pw;
  bit     [`READ_DAC_BITS_N-1:0]              read_dac_config;
  bit     [`ADC_BITS_N-1:0]                   read_ref;
  bit     [`ADDR_BITS_N-1:0]                  rram_addr;
  bit                                         set_rst;
  bit                                         we;
  bit     [`WL_DAC_BITS_N-1:0]                wl_dac_config;

  // Read output
  bit     [`WORD_SIZE-1:0]                    sa_do;

  // Start and end time of operation for scoreboard
  time ti;
  time tf;

  // This function allows us to print contents of the data packet
  // so that it is easier to track in a logfile
  function void print(string tag="");
    if (we) begin
      $display("T=%0t [%s] %s pulse detected @ addr %0d: WL=%0d BSL=%0d PW=%0d DI=0x%0h",
                ti, tag, set_rst ? "SET" : "RST", rram_addr, wl_dac_config, bsl_dac_config, pw, di);
    end
    else begin
      $display("T=%0t [%s] READ pulse detected @ addr %0d: REF=%0d DO=0x%0h WL=%0d BSL=%0d READDAC=%0d CLAMP=%0d DI=0x%0h TF=%0t",
                ti, tag, rram_addr, read_ref, sa_do, wl_dac_config, bsl_dac_config, read_dac_config, clamp_ref, di, tf);
    end
  endfunction
endclass
