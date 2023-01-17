// The interface allows verification components to access DUT signals
// using a virtual interface handle
interface rram_top_if (input bit sclk);
  // Clock enable
  logic       mclk_pause;

  // // Reset
  logic       rst_n;      // (I) Chip reset, active LO

  // // SPI interface
  logic       sc;         // (I) SPI chip select (and async reset when sc = '0')
  logic       mosi;       // (I) SPI master out, slave in
  logic       miso;       // (O) SPI master in, slave out data

  // RRAM busy indicator
  logic       rram_busy;

  // Analog block interface
  logic                                         aclk;
  logic                                         bl_en;
  logic                                         bleed_en;
  logic     [`BSL_DAC_BITS_N-1:0]               bsl_dac_config;
  logic                                         bsl_dac_en;
  logic     [`ADC_BITS_N-1:0]                   clamp_ref;
  logic     [`WORD_SIZE-1:0]                    di;
  logic     [`READ_DAC_BITS_N-1:0]              read_dac_config;
  logic                                         read_dac_en;
  logic     [`ADC_BITS_N-1:0]                   read_ref;
  logic     [`ADDR_BITS_N-1:0]                  rram_addr;
  logic                                         sa_clk;
  logic                                         sa_en;
  logic                                         set_rst;
  logic                                         sl_en;
  logic                                         we;
  logic     [`WL_DAC_BITS_N-1:0]                wl_dac_config;
  logic                                         wl_dac_en;
  logic                                         wl_en;

  // FSM input from analog block
  logic     [`WORD_SIZE-1:0]                    sa_do;
  logic                                         sa_rdy;

  // Bypass and heartbeat
  logic                                         byp;
  logic                                         heartbeat;
endinterface
