//  This digital block provides a register array of configuration
//  registers and access to returned status bits.
module spi_slave_rram (
  // Reset
  input  wire rst_n,      // (I) Chip reset, active LO

  // SPI interface
  input  wire sclk,       // (I) SPI serial clock
  input  wire sc,         // (I) SPI chip select (and async reset when sc = '0')
  input  wire mosi,       // (I) SPI master out, slave in
  output wire miso,       // (O) SPI master in, slave out data
  output wire miso_oe_n,  // (O) miso output enable, active LO

  // Register array command interface to FSM
  output reg                                  fsm_go,
  output wire [`OP_CODE_BITS_N-1:0]           opcode,
  output wire                                 use_multi_addrs,

  // Register array interface
  output wire [`ADDR_BITS_N-1:0]              address_start,
  output wire [`ADDR_BITS_N-1:0]              address_stop,
  output wire [`ADDR_BITS_N-1:0]              address_step,

  output wire [`MAX_ATTEMPTS_BITS_N-1:0]      max_attempts,
  output wire                                 use_ecc,
  output wire [`PROG_CNFG_RANGES_LOG2_N-1:0]  num_levels,
  output wire [`BSL_DAC_BITS_N-1:0]           bl_dac_set_lvl_cycle,
  output wire [`WL_DAC_BITS_N-1:0]            wl_dac_set_lvl_cycle,
  output wire [`PW_BITS_N-1:0]                pw_set_cycle,
  output wire [`BSL_DAC_BITS_N-1:0]           sl_dac_rst_lvl_cycle,
  output wire [`WL_DAC_BITS_N-1:0]            wl_dac_rst_lvl_cycle,
  output wire [`PW_BITS_N-1:0]                pw_rst_cycle,
  output wire                                 set_first,
  output wire [`WORD_SIZE-1:0]                di_init_mask,
  output wire                                 ignore_failures,
  output wire                                 all_dacs_on,
  output wire [`SETUP_CYC_BITS_N-1:0]         idle_to_init_write_setup_cycles,
  output wire [`SETUP_CYC_BITS_N-1:0]         idle_to_init_read_setup_cycles,
  output wire [`SETUP_CYC_BITS_N-1:0]         read_to_init_write_setup_cycles,
  output wire [`SETUP_CYC_BITS_N-1:0]         write_to_init_read_setup_cycles,
  output wire [`SETUP_CYC_BITS_N-1:0]         step_read_setup_cycles,
  output wire [`SETUP_CYC_BITS_N-1:0]         step_write_setup_cycles,
  output wire [`SETUP_CYC_BITS_N-1:0]         post_read_setup_cycles,

  output wire [`ADC_BITS_N-1:0]               adc_clamp_ref_lvl,
  output wire [`READ_DAC_BITS_N-1:0]          adc_read_dac_lvl,
  output wire [`ADC_BITS_N-1:0]               adc_upper_read_ref_lvl,
  output wire [`ADC_BITS_N-1:0]               adc_lower_write_ref_lvl,
  output wire [`ADC_BITS_N-1:0]               adc_upper_write_ref_lvl,
  output wire [`BSL_DAC_BITS_N-1:0]           bl_dac_set_lvl_start,
  output wire [`BSL_DAC_BITS_N-1:0]           bl_dac_set_lvl_stop,
  output wire [`BSL_DAC_BITS_N-1:0]           bl_dac_set_lvl_step,
  output wire [`WL_DAC_BITS_N-1:0]            wl_dac_set_lvl_start,
  output wire [`WL_DAC_BITS_N-1:0]            wl_dac_set_lvl_stop,
  output wire [`WL_DAC_BITS_N-1:0]            wl_dac_set_lvl_step,
  output wire [`PW_BITS_N-1:0]                pw_set_start,
  output wire [`PW_BITS_N-1:0]                pw_set_stop,
  output wire [`PW_BITS_N-1:0]                pw_set_step,
  output wire [`LOOP_BITS_N-1:0]              loop_order_set,
  output wire [`BSL_DAC_BITS_N-1:0]           sl_dac_rst_lvl_start,
  output wire [`BSL_DAC_BITS_N-1:0]           sl_dac_rst_lvl_stop,
  output wire [`BSL_DAC_BITS_N-1:0]           sl_dac_rst_lvl_step,
  output wire [`WL_DAC_BITS_N-1:0]            wl_dac_rst_lvl_start,
  output wire [`WL_DAC_BITS_N-1:0]            wl_dac_rst_lvl_stop,
  output wire [`WL_DAC_BITS_N-1:0]            wl_dac_rst_lvl_step,
  output wire [`PW_BITS_N-1:0]                pw_rst_start,
  output wire [`PW_BITS_N-1:0]                pw_rst_stop,
  output wire [`PW_BITS_N-1:0]                pw_rst_step,
  output wire [`LOOP_BITS_N-1:0]              loop_order_rst,

  // FSM inputs for control and SPI access
  input       [`PROG_CNFG_RANGES_LOG2_N-1:0]  rangei,     // for indexing which programming settings to use from FSM
  input       [`FSM_FULL_STATE_BITS_N-1:0]    fsm_bits,   // state of all regs in FSM 
  input       [`FSM_DIAG_BITS_N-1:0]          diag_bits,  // diagnostic bits in FSM 

  // NOTE: these 2-D array constructs are only supported by SystemVerilog, WONTFIX: could be flattened/unflattened
  input       [`WORD_SIZE-1:0]                read_data_bits [`PROG_CNFG_RANGES_LOG2_N-1:0],
  output reg  [`WORD_SIZE-1:0]                write_data_bits [`PROG_CNFG_RANGES_LOG2_N-1:0]
  );

  // ---------------------------
  // itrx_apbm_spi parameters...
  // ---------------------------
  //  The "APB_RST" register is implemented, and is addressed at the last location 0x1F.
  //  This register allows us to read back a fixed value (APB_RST_DATA), and to generate
  //  the APB preset_n signal.

  localparam ADDR_BITS_N  = `CNFG_REG_ADDR_BITS_N;    // 5 bits for addressing registers
  localparam DATA_BITS_M  = `PROG_CNFG_BITS_N;        // 160 bit data
  localparam PCLK_DIV     = 1;                        // No PCLK division
  localparam APB_RST_ADDR = 2**ADDR_BITS_N-1;         // APB_RST Address = 5'h1F
  localparam APB_RST_DATA = 'h52414D;                 // Read of APB_RST returns ascii "RAM"
  localparam APB_RST_RO   = 1;                        // Enable read-only APB_RST
  localparam CPOL_MODE    = 0;                        // SPI mode 1
  localparam CPHA_MODE    = 1;                        // SPI mode 1

  wire                   preset_n;
  wire                   psel, penable, pwrite;
  wire [ADDR_BITS_N-1:0] paddr;
  wire [DATA_BITS_M-1:0] pwdata;
  reg  [DATA_BITS_M-1:0] prdata;

  // Reset signal
  wire   reset_n;
  assign reset_n = ~(~preset_n | ~rst_n);

  // ============
  // SPI SLAVE...
  // ============
  itrx_apbm_spi #(.ADDR_BITS_N  (ADDR_BITS_N ),
                  .DATA_BITS_M  (DATA_BITS_M ),
                  .PCLK_DIV     (PCLK_DIV    ),
                  .APB_RST_ADDR (APB_RST_ADDR),
                  .APB_RST_DATA (APB_RST_DATA),
                  .APB_RST_RO   (APB_RST_RO  ),
                  .CPOL_MODE    (CPOL_MODE   ),
                  .CPHA_MODE    (CPHA_MODE   )) u_itrx_apbm_spi (

    // SPI Slave i/f...
    .sclk          (sclk),      // (I) SPI serial clock
    .cs_n          (~sc),       // (I) SPI chip select
    .mosi          (mosi),      // (I) SPI master out, slave in
    .miso_data_out (miso),      // (O) SPI master in, slave out data
    .miso_oe_n     (miso_oe_n), // (O) SPI master in, slave out output enable, active LO

    // APB Master i/f...
    .preset_n (preset_n),                // (O) APB slave reset
    .psel     (psel),                    // (O) APB slave select
    .penable  (penable),                 // (O) APB slave enable
    .paddr    (paddr[ADDR_BITS_N-1:0]),  // (O) APB slave address
    .pwrite   (pwrite),                  // (O) APB write/read control
    .pwdata   (pwdata[DATA_BITS_M-1:0]), // (O) APB write data
    .prdata   (prdata[DATA_BITS_M-1:0])  // (I) APB slave read data
    );

  // ===============
  // REGISTER ARRAY...
  // ===============

  reg  [`PROG_CNFG_BITS_N-1:0] prog_cnfg_bits [`PROG_CNFG_RANGES_N-1:0];  // Programming settings for each range
  reg  [`MISC_CNFG_BITS_N-1:0] misc_cnfg_bits;  // Global programming settings
  reg  [3*`ADDR_BITS_N-1:0] addr_bits;  // Address of word to program
  reg  [`FSM_CMD_BITS_N-1:0] fsm_cmd_bits;  // Command to FSM

  // // Control Registers
  always @(posedge sclk or negedge reset_n) begin
    // Reset the registers to their default values (0)
    if (!reset_n) begin
      integer i; // WONTFIX: could make this a genvar
      for (i = 0; i < `PROG_CNFG_RANGES_N; i = i+1) begin
        prog_cnfg_bits[i] <= 0;
      end
      misc_cnfg_bits <= 0;
      addr_bits <= 0;
      fsm_cmd_bits <= 0;
      for (i = 0; i < `PROG_CNFG_RANGES_LOG2_N; i = i+1) begin
        write_data_bits[i] <= 0;
      end
      fsm_go <= 0;
    end
    // Program the registers to data from SPI controller
    else begin
      if (psel && penable && pwrite) begin
        if (paddr < `PROG_CNFG_RANGES_N)
          prog_cnfg_bits[paddr] <= pwdata[`PROG_CNFG_BITS_N-1:0];
        else if (paddr == `PROG_CNFG_RANGES_N)
          misc_cnfg_bits <= pwdata[`MISC_CNFG_BITS_N-1:0];
        else if (paddr == `PROG_CNFG_RANGES_N+1)
          addr_bits <= pwdata[`PROG_CNFG_BITS_N-1:0];
        else if ((paddr >= `PROG_CNFG_RANGES_N+2) && (paddr < `PROG_CNFG_RANGES_N+2+`PROG_CNFG_RANGES_LOG2_N))
          write_data_bits[paddr-`PROG_CNFG_RANGES_N-2] <= pwdata[`PROG_CNFG_BITS_N-1:0];
        else if (paddr == `PROG_CNFG_RANGES_N+2+`PROG_CNFG_RANGES_LOG2_N) begin
          fsm_cmd_bits <= pwdata[`FSM_CMD_BITS_N-1:0];
          fsm_go <= 1; // Trigger FSM
        end
      end
      // Turn off FSM trigger once FSM is no longer idle
      else if (fsm_bits[`FSM_STATE_BITS_N-1:0] != `FSM_STATE_IDLE)
        fsm_go <= 0;
    end
  end

  // Global settings (misc. register)
  assign {post_read_setup_cycles, step_write_setup_cycles, step_read_setup_cycles, write_to_init_read_setup_cycles, read_to_init_write_setup_cycles, idle_to_init_read_setup_cycles, idle_to_init_write_setup_cycles, all_dacs_on, ignore_failures, di_init_mask, set_first, pw_rst_cycle, wl_dac_rst_lvl_cycle, sl_dac_rst_lvl_cycle, pw_set_cycle, wl_dac_set_lvl_cycle, bl_dac_set_lvl_cycle, num_levels, use_ecc, max_attempts} = misc_cnfg_bits;

  // Programming/reading settings (prog. registers)
  assign {loop_order_rst, pw_rst_step, pw_rst_stop, pw_rst_start, wl_dac_rst_lvl_step, wl_dac_rst_lvl_stop, wl_dac_rst_lvl_start, sl_dac_rst_lvl_step, sl_dac_rst_lvl_stop, sl_dac_rst_lvl_start, loop_order_set, pw_set_step, pw_set_stop, pw_set_start, wl_dac_set_lvl_step, wl_dac_set_lvl_stop, wl_dac_set_lvl_start, bl_dac_set_lvl_step, bl_dac_set_lvl_stop, bl_dac_set_lvl_start, adc_upper_write_ref_lvl, adc_lower_write_ref_lvl, adc_upper_read_ref_lvl, adc_read_dac_lvl, adc_clamp_ref_lvl} = prog_cnfg_bits[rangei];

  // Address and data
  assign {address_step, address_stop, address_start} = addr_bits;

  // FSM command bits
  assign opcode = fsm_cmd_bits[`OP_CODE_BITS_N-1:0];
  assign use_multi_addrs = fsm_cmd_bits[`FSM_CMD_BITS_N-1];

  // Set the SPI read data wire
  always @* begin
    // Low addresses access the programming configuration registers
    if (paddr < `PROG_CNFG_RANGES_N)
      prdata = prog_cnfg_bits[paddr[`PROG_CNFG_RANGES_LOG2_N-1:0]];
    // Global programming configuration register next
    else if (paddr == `PROG_CNFG_RANGES_N)
      prdata = misc_cnfg_bits;
    // Address register next
    else if (paddr == `PROG_CNFG_RANGES_N+1)
      prdata = addr_bits;
    // Write data register next
    else if ((paddr >= `PROG_CNFG_RANGES_N+2) && (paddr < `PROG_CNFG_RANGES_N+2+`PROG_CNFG_RANGES_LOG2_N))
      prdata = write_data_bits[paddr[`PROG_CNFG_RANGES_LOG2_N-1:0]-2];
    // FSM command register next
    else if (paddr == `PROG_CNFG_RANGES_N+2+`PROG_CNFG_RANGES_LOG2_N)
      prdata = fsm_cmd_bits;
    // FSM state bits next
    else if (paddr == `PROG_CNFG_RANGES_N+3+`PROG_CNFG_RANGES_LOG2_N)
      prdata = fsm_bits;
    // FSM diagnostic bits next
    else if (paddr == `PROG_CNFG_RANGES_N+4+`PROG_CNFG_RANGES_LOG2_N)
      prdata = diag_bits;
    // Read data register next
    else if ((paddr >= `PROG_CNFG_RANGES_N+5+`PROG_CNFG_RANGES_LOG2_N) && (paddr < `PROG_CNFG_RANGES_N+5+2*`PROG_CNFG_RANGES_LOG2_N))
      prdata = read_data_bits[paddr[`PROG_CNFG_RANGES_LOG2_N-1:0]-(5+`PROG_CNFG_RANGES_LOG2_N)];
    // Reset configuration bits by accessing the highest possible register
    else if (paddr == APB_RST_ADDR)
      prdata = APB_RST_DATA;
    // Else, just return zero
    else
      prdata = 0;
  end
endmodule
