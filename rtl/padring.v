// RTL pad definition for pad ring
module padring (
  ////////////////
  // TO DIGITAL //
  ////////////////

  // Clock, reset
  output wire mclk_pause,
  output wire rst_n,

  // RRAM busy indicator
  input wire rram_busy,
  
  // SPI interface
  output wire  sclk,       // SPI serial clock
  output wire  sc,         // SPI chip select
  output wire  mosi,       // SPI master out, slave in
  input        miso,       // SPI master in, slave out data
  input  wire  miso_oe_n,  // miso output enable, active LO
  
  // Output to analog block
  output wire aclk,
  output wire bl_en,
  output wire bleed_en,
  output wire [`BSL_DAC_BITS_N-1:0] bsl_dac_config,
  output wire bsl_dac_en,
  output wire [`ADC_BITS_N-1:0] clamp_ref,
  output wire [`WORD_SIZE-1:0] di,
  output wire man,
  output wire [`READ_DAC_BITS_N-1:0] read_dac_config,
  output wire read_dac_en,
  output wire [`ADC_BITS_N-1:0] read_ref,
  output wire [`ADDR_BITS_N-1:0] rram_addr,
  output wire sa_clk,
  output wire sa_en,
  output wire set_rst,
  output wire sl_en,
  output wire we,
  output wire [`WL_DAC_BITS_N-1:0] wl_dac_config,
  output wire wl_dac_en,
  output wire wl_en,

  // Input from analog block
  input[`WORD_SIZE-1:0] sa_do,
  input sa_rdy,

  // FPGA debug
  output wire byp,
  input heartbeat,


  /////////////
  // TO PADS //
  /////////////

  // Clock, reset
  input mclk_pause_pad,
  input rst_n_pad,

  // RRAM busy indicator
  output wire rram_busy_pad,

  // SPI interface
  input       sclk_pad,       // SPI serial clock
  input       sc_pad,         // SPI chip select
  input       mosi_pad,       // SPI master out, slave in
  output wire miso_pad,       // SPI master in, slave out data
  
  // Input to analog block
  input aclk_pad,
  input bl_en_pad,
  input bleed_en_pad,
  input [`BSL_DAC_BITS_N-1:0] bsl_dac_config_pad,
  input bsl_dac_en_pad,
  input [`ADC_BITS_N-1:0] clamp_ref_pad,
  input [`WORD_SIZE-1:0] di_pad,
  input man_pad,
  input [`READ_DAC_BITS_N-1:0] read_dac_config_pad,
  input read_dac_en_pad,
  input [`ADC_BITS_N-1:0] read_ref_pad,
  input [`ADDR_BITS_N-1:0] rram_addr_pad,
  input sa_clk_pad,
  input sa_en_pad,
  input set_rst_pad,
  input sl_en_pad,
  input we_pad,
  input [`WL_DAC_BITS_N-1:0] wl_dac_config_pad,
  input wl_dac_en_pad,
  input wl_en_pad,

  // Output from analog block
  output wire[`WORD_SIZE-1:0] sa_do_pad,
  output wire sa_rdy_pad,

  // FPGA debug
  input byp_pad,
  output wire heartbeat_pad
  );

  // Generator variable
  genvar i;


  /////////////
  // DIGITAL //
  /////////////

  // Clock, reset: use Tri-State Output Pad with Schmitt Trigger Input and Enable Controlled Pull-Down, Fail-Safe to debounce
  PDDW08SDGZ_G pad_mclk_pause(.I(1'b0), .OEN(1'b1), .REN(1'b0), .PAD(mclk_pause_pad), .C(mclk_pause));
  PDDW08SDGZ_G pad_rst_n(.I(1'b0), .OEN(1'b1), .REN(1'b0), .PAD(rst_n_pad), .C(rst_n));

  // FSM: RRAM busy output pad
  PDDW08DGZ_G pad_rram_busy(.I(rram_busy), .OEN(1'b0), .REN(1'b0), .PAD(rram_busy_pad), .C());

  // SPI: use Tri-State Output Pad with Input and Enable Controlled Pull-Down, Fail-Safe
  PDDW08SDGZ_G pad_sclk(.I(1'b0), .OEN(1'b1), .REN(1'b0), .PAD(sclk_pad), .C(sclk)); // Schmitt trigger for clock signal
  PDDW08DGZ_G pad_sc(.I(1'b0), .OEN(1'b1), .REN(1'b0), .PAD(sc_pad), .C(sc));
  PDDW08DGZ_G pad_mosi(.I(1'b0), .OEN(1'b1), .REN(1'b0), .PAD(mosi_pad), .C(mosi));
  PDDW08DGZ_G pad_miso(.I(miso), .OEN(1'b1), .REN(1'b0), .PAD(miso_pad), .C());

  // Input to analog block
  PDDW08DGZ_G pad_aclk(.I(1'b0), .OEN(1'b1), .REN(1'b0), .PAD(aclk_pad), .C(aclk));
  PDDW08DGZ_G pad_bl_en(.I(1'b0), .OEN(1'b1), .REN(1'b0), .PAD(bl_en_pad), .C(bl_en));
  PDDW08DGZ_G pad_bleed_en(.I(1'b0), .OEN(1'b1), .REN(1'b0), .PAD(bleed_en_pad), .C(bleed_en));
  generate
    for (i = 0; i < `BSL_DAC_BITS_N; i = i+1) begin : bsl_dac_config_gen
      PDDW08DGZ_G pad_bsl_dac_config(.I(1'b0), .OEN(1'b1), .REN(1'b0), .PAD(bsl_dac_config_pad[i]), .C(bsl_dac_config[i]));
    end
  endgenerate
  PDDW08DGZ_G pad_bsl_dac_en(.I(1'b0), .OEN(1'b1), .REN(1'b0), .PAD(bsl_dac_en_pad), .C(bsl_dac_en));
  generate
    for (i = 0; i < `ADC_BITS_N; i = i+1) begin : clamp_ref_gen
      PDDW08DGZ_G pad_clamp_ref(.I(1'b0), .OEN(1'b1), .REN(1'b0), .PAD(clamp_ref_pad[i]), .C(clamp_ref[i]));
    end
  endgenerate
  generate
    for (i = 0; i < `WORD_SIZE; i = i+1) begin : di_gen
      PDDW08DGZ_G pad_di(.I(1'b0), .OEN(1'b1), .REN(1'b0), .PAD(di_pad[i]), .C(di[i]));
    end
  endgenerate
  PDDW08DGZ_G pad_man(.I(1'b0), .OEN(1'b1), .REN(1'b0), .PAD(man_pad), .C(man));
  generate
    for (i = 0; i < `READ_DAC_BITS_N; i = i+1) begin : read_dac_config_gen
      PDDW08DGZ_G pad_read_dac_config(.I(1'b0), .OEN(1'b1), .REN(1'b0), .PAD(read_dac_config_pad[i]), .C(read_dac_config[i]));
    end
  endgenerate
  PDDW08DGZ_G pad_read_dac_en(.I(1'b0), .OEN(1'b1), .REN(1'b0), .PAD(read_dac_en_pad), .C(read_dac_en));
  generate
    for (i = 0; i < `ADC_BITS_N; i = i+1) begin : read_ref_gen
      PDDW08DGZ_G pad_read_ref(.I(1'b0), .OEN(1'b1), .REN(1'b0), .PAD(read_ref_pad[i]), .C(read_ref[i]));
    end
  endgenerate
  generate
    for (i = 0; i < `ADDR_BITS_N; i = i+1) begin : rram_addr_gen
      PDDW08DGZ_G pad_rram_addr(.I(1'b0), .OEN(1'b1), .REN(1'b0), .PAD(rram_addr_pad[i]), .C(rram_addr[i]));
    end
  endgenerate
  PDDW08DGZ_G pad_sa_clk(.I(1'b0), .OEN(1'b1), .REN(1'b0), .PAD(sa_clk_pad), .C(sa_clk));
  PDDW08DGZ_G pad_sa_en(.I(1'b0), .OEN(1'b1), .REN(1'b0), .PAD(sa_en_pad), .C(sa_en));
  PDDW08DGZ_G pad_set_rst(.I(1'b0), .OEN(1'b1), .REN(1'b0), .PAD(set_rst_pad), .C(set_rst));
  PDDW08DGZ_G pad_sl_en(.I(1'b0), .OEN(1'b1), .REN(1'b0), .PAD(sl_en_pad), .C(sl_en));
  PDDW08DGZ_G pad_we(.I(1'b0), .OEN(1'b1), .REN(1'b0), .PAD(we_pad), .C(we));
  generate
    for (i = 0; i < `WL_DAC_BITS_N; i = i+1) begin : wl_dac_config_gen
      PDDW08DGZ_G pad_wl_dac_config(.I(1'b0), .OEN(1'b1), .REN(1'b0), .PAD(wl_dac_config_pad[i]), .C(wl_dac_config[i]));
    end
  endgenerate
  PDDW08DGZ_G pad_wl_dac_en(.I(1'b0), .OEN(1'b1), .REN(1'b0), .PAD(wl_dac_en_pad), .C(wl_dac_en));
  PDDW08DGZ_G pad_wl_en(.I(1'b0), .OEN(1'b1), .REN(1'b0), .PAD(wl_en_pad), .C(wl_en));

  // Output from analog block
  generate
    for (i = 0; i < `WORD_SIZE; i = i+1) begin : sa_do_gen
      PDDW08DGZ_G pad_sa_do(.I(sa_do[i]), .OEN(1'b0), .REN(1'b0), .PAD(sa_do_pad[i]), .C());
    end
  endgenerate
  PDDW08DGZ_G pad_sa_rdy(.I(sa_rdy), .OEN(1'b0), .REN(1'b0), .PAD(sa_rdy_pad), .C());

  // FPGA debug
  PDDW08DGZ_G pad_byp(.I(1'b0), .OEN(1'b0), .REN(1'b0), .PAD(byp_pad), .C(byp));
  PDDW08DGZ_G pad_heartbeat(.I(heartbeat), .OEN(1'b0), .REN(1'b0), .PAD(heartbeat_pad), .C());

  ///////////
  // POWER //
  ///////////

  // IREF test
  PVDD1ANA_G pad_iref_test();

  // WL source pin pad
  PVDD2ANA_G pad_wl_source_pin();

  // BL source pin pad
  generate
    for (i = 0; i < 2; i = i+1) begin : bl_source_pin_gen
      PVDD2ANA_G pad_bl_source_pin();
    end
  endgenerate
  

  // SL source pin pad
  generate
    for (i = 0; i < 2; i = i+1) begin : sl_source_pin_gen
      PVDD2ANA_G pad_sl_source_pin();
    end
  endgenerate
  

  // VDD core to analog block pads
  generate
    for (i = 0; i < 10; i = i+1) begin : vdd_gen
      PVDD1ANA_G pad_vdd();
    end
  endgenerate

  // VDD test structure pad
  PVDD1ANA_G pad_vdd_test();

  // VDD DAC spec voltage pad
  generate
    for (i = 0; i < 6; i = i+1) begin : vdd_dac_gen
      PVDD1ANA_G pad_vdd_dac();
    end
  endgenerate

  // VDD core supply to FSM pads
  generate
    for (i = 0; i < 8; i = i+1) begin : vdd_fsm_gen
      PVDD1DGZ_G pad_vdd_fsm();
    end
  endgenerate

  // VDD IO pads to array
  generate
    for (i = 0; i < 12; i = i+1) begin : vddio_gen
      PVDD2ANA_G pad_vddio();
    end
  endgenerate

  // VDD IO pads to DACs
  generate
    for (i = 0; i < 12; i = i+1) begin : vddio_dac_gen
      PVDD2ANA_G pad_vddio_dac();
    end
  endgenerate

  // VDD IO pads to FSM
  generate
    for (i = 0; i < 15; i = i+1) begin : vddio_fsm_gen
      PVDD2DGZ_G pad_vddio_fsm();
    end
  endgenerate

  // VSA pad for sense amp
  generate
    for (i = 0; i < 5; i = i+1) begin : vsa_gen
      PVDD1ANA_G pad_vsa();
    end
  endgenerate

  // VSS pads
  generate
    for (i = 0; i < 16; i = i+1) begin : vss_gen
      PVSS3DGZ_G pad_vss();
    end
  endgenerate

  // POC pad
  PVDD2POC_G pad_poc();

endmodule
