// RRAM Array Behavioral Model
// Used only for testing (not synthesizable)

// Analog block behavioral model
module rram_1p3Mb (
  // Input to analog block
  input aclk,
  input bl_en,
  input bleed_en,
  input [`BSL_DAC_BITS_N-1:0] bsl_dac_config,
  input bsl_dac_en,
  input [`ADC_BITS_N-1:0] clamp_ref,
  input [`WORD_SIZE-1:0] di,
  input man,
  input [`READ_DAC_BITS_N-1:0] read_dac_config,
  input read_dac_en,
  input [`ADC_BITS_N-1:0] read_ref,
  input [`ADDR_BITS_N-1:0] rram_addr,
  input sa_clk,
  input sa_en,
  input set_rst,
  input sl_en,
  input we,
  input [`WL_DAC_BITS_N-1:0] wl_dac_config,
  input wl_dac_en,
  input wl_en,

  // Output from analog block
  output reg [`WORD_SIZE-1:0] sa_do,
  output reg sa_rdy
  );

  // Specify timing for model
  specify
    //
    // TIMING SPECS
    //
    specparam T_RRAM_ADDR_SETUP_SA_EN               = 19ns;
    specparam T_READ_DAC_CONFIG_SETUP_SA_EN         = 19ns;
    specparam T_WL_DAC_CONFIG_SETUP_SA_EN           = 19ns;
    specparam T_READ_REF_SETUP_SA_EN                = 19ns;
    specparam T_CLAMP_REF_SETUP_SA_EN               = 19ns;
    specparam T_READ_EN_SETUP_SA_EN                 = 19ns;
    specparam T_RRAM_ADDR_SETUP_WE                  = 19ns;
    specparam T_WL_DAC_CONFIG_SETUP_WE              = 19ns;
    specparam T_BSL_DAC_CONFIG_SETUP_WE             = 19ns;
    specparam T_SET_RST_SETUP_WE                    = 19ns;
    specparam T_DI_SETUP_WE                         = 19ns;
    specparam T_WRITE_EN_SETUP_WE                   = 19ns;
    specparam T_WRITE_EN_SETUP_SA_EN                = 19ns;
    specparam T_SA_EN_SETUP_WE                      = 19ns;
    specparam T_READ                                = 19ns;
    specparam T_WRITE                               = 19ns;

    // //
    // // READOUT SETUP
    // //
    // // Address to begin sensing setup
    // $setup     (posedge rram_addr             , posedge sa_en         , T_RRAM_ADDR_SETUP_SA_EN              );
    // $setup     (negedge rram_addr             , posedge sa_en         , T_RRAM_ADDR_SETUP_SA_EN              );

    // // DAC config to begin sensing setup
    // $setup     (posedge read_dac_config       , posedge sa_en         , T_READ_DAC_CONFIG_SETUP_SA_EN        );
    // $setup     (negedge read_dac_config       , posedge sa_en         , T_READ_DAC_CONFIG_SETUP_SA_EN        );

    // $setup     (posedge wl_dac_config         , posedge sa_en         , T_WL_DAC_CONFIG_SETUP_SA_EN          );
    // $setup     (negedge wl_dac_config         , posedge sa_en         , T_WL_DAC_CONFIG_SETUP_SA_EN          );

    // $setup     (posedge read_ref              , posedge sa_en         , T_READ_REF_SETUP_SA_EN               );
    // $setup     (negedge read_ref              , posedge sa_en         , T_READ_REF_SETUP_SA_EN               );

    // $setup     (posedge clamp_ref             , posedge sa_en         , T_CLAMP_REF_SETUP_SA_EN              );
    // $setup     (negedge clamp_ref             , posedge sa_en         , T_CLAMP_REF_SETUP_SA_EN              );

    // // Enable signals to begin sensing setup (all are activated simultaneously)
    // $setup     (posedge wl_en                 , posedge sa_en         , T_READ_EN_SETUP_SA_EN                );
    // $setup     (posedge bl_en                 , posedge sa_en         , T_READ_EN_SETUP_SA_EN                );
    // $setup     (posedge sl_en                 , posedge sa_en         , T_READ_EN_SETUP_SA_EN                );
    // $setup     (posedge bleed_en              , posedge sa_en         , T_READ_EN_SETUP_SA_EN                );
    // $setup     (posedge read_dac_en           , posedge sa_en         , T_READ_EN_SETUP_SA_EN                );
    // $setup     (posedge wl_dac_en             , posedge sa_en         , T_READ_EN_SETUP_SA_EN                );
    // $setup     (posedge bsl_dac_en            , posedge sa_en         , T_READ_EN_SETUP_SA_EN                );

    // //
    // // PROGRAMMING SETUP
    // //
    // // Address to begin write setup
    // $setup     (posedge rram_addr             , posedge aclk          , T_RRAM_ADDR_SETUP_WE                 );
    // $setup     (negedge rram_addr             , posedge aclk          , T_RRAM_ADDR_SETUP_WE                 );
    // $setup     (posedge rram_addr             , posedge we            , T_RRAM_ADDR_SETUP_WE                 );
    // $setup     (negedge rram_addr             , posedge we            , T_RRAM_ADDR_SETUP_WE                 );

    // // DAC config to begin write setup
    // $setup     (posedge wl_dac_config         , posedge aclk          , T_WL_DAC_CONFIG_SETUP_WE             );
    // $setup     (negedge wl_dac_config         , posedge aclk          , T_WL_DAC_CONFIG_SETUP_WE             );
    // $setup     (posedge wl_dac_config         , posedge we            , T_WL_DAC_CONFIG_SETUP_WE             );
    // $setup     (negedge wl_dac_config         , posedge we            , T_WL_DAC_CONFIG_SETUP_WE             );

    // $setup     (posedge bsl_dac_config        , posedge aclk          , T_BSL_DAC_CONFIG_SETUP_WE            );
    // $setup     (negedge bsl_dac_config        , posedge aclk          , T_BSL_DAC_CONFIG_SETUP_WE            );
    // $setup     (posedge bsl_dac_config        , posedge we            , T_BSL_DAC_CONFIG_SETUP_WE            );
    // $setup     (negedge bsl_dac_config        , posedge we            , T_BSL_DAC_CONFIG_SETUP_WE            );

    // // SET/RESET to begin write setup
    // $setup     (posedge set_rst               , posedge aclk          , T_SET_RST_SETUP_WE                   );
    // $setup     (posedge set_rst               , posedge we            , T_SET_RST_SETUP_WE                   );

    // // Data in to begin write setup
    // $setup     (posedge di                    , posedge aclk          , T_DI_SETUP_WE                        );
    // $setup     (posedge di                    , posedge we            , T_DI_SETUP_WE                        );

    // // Enable signals to begin write setup (all are activated simultaneously)
    // $setup     (posedge wl_en                 , posedge aclk          , T_WRITE_EN_SETUP_WE                  );
    // $setup     (posedge bl_en                 , posedge aclk          , T_WRITE_EN_SETUP_WE                  );
    // $setup     (posedge sl_en                 , posedge aclk          , T_WRITE_EN_SETUP_WE                  );
    // $setup     (posedge wl_dac_en             , posedge aclk          , T_WRITE_EN_SETUP_WE                  );
    // $setup     (posedge bsl_dac_en            , posedge aclk          , T_WRITE_EN_SETUP_WE                  );
    // $setup     (posedge wl_en                 , posedge we            , T_WRITE_EN_SETUP_WE                  );
    // $setup     (posedge bl_en                 , posedge we            , T_WRITE_EN_SETUP_WE                  );
    // $setup     (posedge sl_en                 , posedge we            , T_WRITE_EN_SETUP_WE                  );
    // $setup     (posedge wl_dac_en             , posedge we            , T_WRITE_EN_SETUP_WE                  );
    // $setup     (posedge bsl_dac_en            , posedge we            , T_WRITE_EN_SETUP_WE                  );

    // //
    // // OTHER SETUP
    // //
    // // Time between write and read
    // $setup     (negedge aclk                  , posedge sa_en         , T_WRITE_EN_SETUP_SA_EN               );
    // $setup     (negedge we                    , posedge sa_en         , T_WRITE_EN_SETUP_SA_EN               );

    // // Time between read and write
    // $setup     (negedge sa_en                 , posedge we            , T_SA_EN_SETUP_WE                     );
    // $setup     (negedge sa_en                 , posedge aclk          , T_SA_EN_SETUP_WE                     );

    // // Minimum time for read and write
    // $width     (posedge sa_en                                         , T_READ                               );
    // $width     (posedge aclk                                          , T_WRITE                              );
    // $width     (posedge we                                            , T_WRITE                              );
  endspecify

  // Parameters
  parameter DEFAULT_LEVEL = 0;
  parameter USE_RANDOM = 1;
  parameter CHANGE_PROB = 1.0; // probability that a write pulse will affect the conductance

  // Values for SET and RST
  localparam RST = 0;
  localparam SET = 1;

  // Generator variable
  integer i;

  // Initialize variable
  reg [`ADC_BITS_N-1:0] g0;

  // Cell conductances (represented as ADC thresholds)
  reg [`ADC_BITS_N-1:0] g [`NUM_WORDS-1:0][`WORD_SIZE-1:0] = '{default:DEFAULT_LEVEL};
  initial begin
    if (USE_RANDOM) assert(randomize(g));
  end

  // Reading/writing conditions
  wire read_en = wl_en & bl_en & sl_en & bleed_en & read_dac_en; // & sa_en
  wire write_en = we & aclk & wl_en & bl_en & sl_en & wl_dac_en & bsl_dac_en;

  // Need mask from di
  reg [`WORD_SIZE-1:0] mask;
  assign mask = di ~^ {`WORD_SIZE{set_rst}};

  // READ behavior
  // Assert read_en when sa_en goes high
  always @(posedge sa_en) assert(read_en);

  // Data becomes ready after T_READ and indicates whether g >= read_ref
  always @(posedge sa_clk) begin
    if (sa_en) begin
      #T_READ
      sa_rdy = 1;
      for (i = 0; i < `WORD_SIZE; i=i+1) begin
        sa_do[i] = mask[i] ? (g[rram_addr][i] >= read_ref) : 'x;
      end
      // $display("[RRAM Behav.] READ detected: T=%0t addr=%0d i=%0d ref=%0d val=%0d", $time, rram_addr, i, read_ref, sa_do[i]);
    end
    // Data becomes invalid when sa_en low
    if (~sa_en) begin
      for (i = 0; i < `WORD_SIZE; i=i+1) begin
        sa_do[i] = 'x;
      end
      sa_rdy = 0;
    end
  end

  // WRITE behavior
  always @(posedge write_en) begin
    #T_WRITE
    // Only write if unmasked and randomly selected to make a change
    for (i = 0; i < `WORD_SIZE; i=i+1) begin
      if (mask[i] & ($urandom_range(100000) < (CHANGE_PROB * 100000.0))) begin
        case (set_rst)
            // SET results in >= conductance, ignores pulse settings for now
            SET: begin
              g0 = g[rram_addr][i];
              g[rram_addr][i] = $urandom_range(32'(g[rram_addr][i]), 32'({`ADC_BITS_N{1'b1}}));
              $display("[RRAM Behav.] SET detected: T=%0t addr=%0d i=%0d wl=%0d bsl=%0d g0=%0d gf=%0d", $time, rram_addr, i, wl_dac_config, bsl_dac_config, g0, g[rram_addr][i]);
            end
            // RST results in <= conductance, ignores pulse settings for now
            RST: begin
              g0 = g[rram_addr][i];
              g[rram_addr][i] = $urandom_range(32'd0, 32'(g[rram_addr][i]));
              $display("[RRAM Behav.] RST detected: T=%0t addr=%0d i=%0d wl=%0d bsl=%0d g0=%0d gf=%0d", $time, rram_addr, i, wl_dac_config, bsl_dac_config, g0, g[rram_addr][i]);
            end
        endcase
      end
    end
  end
endmodule

// Test structure dummy block
module rdac_test_struct (
  input [`ADC_BITS_N-1:0] clamp_ref,
  input sa_en
  );
endmodule
