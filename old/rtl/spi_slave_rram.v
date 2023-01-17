// =========================== COPYRIGHT NOTICE =============================
// 
//                      Copyright 2020 © SkyWater Technology
//                     Customer Proprietary and Confidential                    
//                         Authored by Intrinsix Corp.                
//                                                           
// =============================== WARRANTY =================================
// 
// INTRINSIX CORP. MAKES NO WARRANTY OF ANY KIND WITH REGARD TO THE USE OF   
// THIS SOFTWARE OR ITS ACCOMPANYING DOCUMENTATION, EITHER EXPRESSED OR 
// IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
// MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.
//
// ==========================================================================
//
// Original Author: Kent Arnold
// Filename       : spi_slave_rram.v
// Description    : SPI interface and CNFG registers for SKY105 ASIC
// 
// ==========================================================================

//  This digital block provides a register array of configuration
//  registers and access to returned status bits. There
//  are 32 registers, 23 bits per register.

module spi_slave_rram (
  input       rst_n,     // (I) Chip reset, active LO

  input       scan_mode,         // (I) Scan Mode indicator
  input       scan_clk,          // (I) Scan clock

  // SPI i/f...
  input       sclk,      // (I) SPI serial clock
  input       sc,        // (I) SPI chip select (and async reset when sc = '0')
  input       mosi,      // (I) SPI master out, slave in
  output wire miso,      // (O) SPI master in, slave out data
  output wire miso_oe_n, // (O) miso output enable, active LO

  // Register Array i/f: control outputs...
  output reg         fsm_go,             // (O) CONTROL_REG: FSM trigger indicator
  output reg         spi_pop,            // (O) DIAGNOSTIC1_REG: diagnostic FIFO pop pulse
  output reg         data_out_read,      // (O) DATA_OUT register read indicator
  input              rram_do_full,       // (I) indicator that rram read data is present in holding reg

  // Register Array i/f: cnfg outputs...
  output wire [2:0]  clu_op_code,        // (O) CONTROL_REG: FSM command indicator

  output wire [1:0]  sa_clk_conf,        // (O) READ_CONFIG_REG: sa_clk configuration
  output wire        check_board_conf,   // (O) READ_CONFIG_REG: read checkerboard configuration
  output wire [16:0] read_multi_offset,  // (O) READ_CONFIG_REG: upper address for multiple reads
  output wire [1:0]  read_mode,          // (O) READ_CONFIG_REG: read one, multi, all 

  output wire [2:0]  wdata_pattern,      // (O) WRITE_CONFIG_REG: write checkerboard configuration
  output wire [16:0] write_multi_offset, // (O) WRITE_CONFIG_REG: upper address for multiple writes
  output wire [1:0]  write_mode,         // (O) WRITE_CONFIG_REG: write one, multi, all 

  output wire [16:0] form_multi_offset,  // (O) FORM_CONFIG_REG: upper address for multiple forms
  output wire [1:0]  form_mode,          // (O) FORM_CONFIG_REG: form one, multi, all 

  output wire [16:0] address,            // (O) RRAM_ADDR_REG: address
  output wire [3:0]  banksel,            // (O) RRAM_ADDR_REG: bank select

  output wire [15:0] data_in,            // (O) DATA_IN_REG bits

  output wire        rdata_dest,         // (O) CHIP_CONFIG_REG: SPI reg vs. Direct Access DO select
  output wire        wdata_source,       // (O) CHIP_CONFIG_REG: SPI reg vs. Direct Access DI select
  output wire        addr_source,        // (O) CHIP_CONFIG_REG: SPI reg vs. Direct Access ADDR select
  output wire        diag_mode,          // (O) CHIP_CONFIG_REG: dianostic mode select

  output wire        force_set_type,     // (O) SET_REF_CONFIG_REG: controls value of set_form signal during FORCE SET commands
  output wire        ref_mode,           // (O) SET_REF_CONFIG_REG: current source mode for SET, RESET, READ operations
  output wire [6:0]  set_ref_config,     // (O) SET_REF_CONFIG_REG: current reference parameter for SET operation

  output wire [6:0]  reset_ref_config,   // (O) RESET_REF_CONFIG_REG: current reference parameter for RESET operation

  output wire [6:0]  read_ref_config,    // (O) READ_REF_CONFIG_REG: current reference parameter for READ operation

  output wire [5:0]  set_retry_limit,    // (O) SET_CONFIG_REG: retry limits for SET
  output wire [16:0] set_timer_config,   // (O) SET_CONFIG_REG: pulse width for SET

  output wire [5:0]  reset_retry_limit,  // (O) RESET_CONFIG_REG: retry limits for RESET
  output wire [16:0] reset_timer_config, // (O) RESET_CONFIG_REG: pulse width for RESET

  output wire [16:0] bldis_timer_config, // (O) BLDIS_CONFIG_REG: pulse width for BLDIS (READ)

  // Register Array: rdback inputs...
  input       [15:0] data_out,           // (I) DATA_OUT_REG bits

  input       [4:0]  fsm_state,          // (I) STATUS_REG bit
  input              diag_fifo_full,     // (I) STATUS_REG bit
  input              diag_fifo_empty,    // (I) STATUS_REG bit
  input              mip,                // (I) STATUS_REG bit
  input              rip,                // (I) STATUS_REG bit
  input              wip,                // (I) STATUS_REG bit
  input              fip,                // (I) STATUS_REG bit
  input              fsm_error_flag,     // (I) STATUS REG bit

  input              byp,                // (I) STATUS_REG bit

  input       [16:0] failed_address,     // (I) DIAGNOSTIC1_REG bit
  input       [3:0]  failed_bank,        // (I) DIAGNOSTIC1_REG bit

  input       [1:0]  failed_operation,   // (I) DIAGNOSTIC2_REG bit
  input       [15:0] failed_data_bits,   // (I) DIAGNOSTIC2_REG bit

  input       [16:0] set_error_count,    // (I) DIAGNOSTIC3_REG bit
  input       [16:0] reset_error_count   // (I) DIAGNOSTIC4_REG bit
  );

// ---------------------------
// itrx_apbm_spi parameters...
// ---------------------------
// Initial mapping is for enough address bits to access up to 32 23-bit registers.
//  The "APB_RST" register is implemented, and is addressed at the last location 0x1F.
//  This register allows us to read back a fixed value (APB_RST_DATA), and to generate
//  the APB preset_n signal.
//
//  The itrx_apbm_spi transaction protocol would then need 32 clocks (at minimum):
//
//   CMD,  1  bit read/write select field = WRITE
//   ADDR, 5  bits address field
//   DATA, 23 bits WRITE data field
//   APB,  3  bits to create the APB signaling
//
//   CMD,  1  bit read/write select field = READ
//   ADDR, 5  bits address field
//   APB,  2  bits to create the APB signaling
//   DATA, 23 bits READ data field
//
//  The SPI master talking to this slave is expected to produce SPI transactions based
//  on 32 SCLK cycles. A SPI master that provides more than the required
//  32 clocks would result in this module simply providing data padding bits for the extra
//  clocks. It is up to the SPI master user to determine where the "real" 23 data bits are
//  returned on a read.

localparam ADDR_BITS_N  = 5;   // 5 bits for access to 32 registers
localparam DATA_BITS_M  = 23;  // 23 bit data
localparam PCLK_DIV     = 1;   // No PCLK division
localparam APB_RST_ADDR = 31;  // APB_RST Address = 5'h1F
localparam APB_RST_DATA = 23'h52414D;  // Read of APB_RST returns ascii "RAM"
localparam APB_RST_RO   = 1;   // Enable read-only APB_RST
localparam CPOL_MODE    = 0;   // SPI mode 1
localparam CPHA_MODE    = 1;   //  "

localparam CNFG_BITS_0_RSTVAL  = 23'h00_0000;  // CONTROL_REG
localparam CNFG_BITS_1_RSTVAL  = 23'h00_0000;  // READ_CONFIG_REG
localparam CNFG_BITS_2_RSTVAL  = 23'h00_0000;  // WRITE_CONFIG_REG
localparam CNFG_BITS_3_RSTVAL  = 23'h00_0000;  // FORM_CONFIG_REG
localparam CNFG_BITS_4_RSTVAL  = 23'h00_0000;  // RRAM_ADDR_REG
localparam CNFG_BITS_5_RSTVAL  = 23'h00_0000;  // DATA_IN_REG
localparam CNFG_BITS_6_RSTVAL  = 23'h00_0000;  // DATA_OUT_REG
localparam CNFG_BITS_7_RSTVAL  = 23'h00_0000;  // CHIP_CONFIG_REG
localparam CNFG_BITS_8_RSTVAL  = 23'h00_0080;  // SET_REF_CONFIG_REG
localparam CNFG_BITS_9_RSTVAL  = 23'h00_0000;  // RESET_REF_CONFIG_REG
localparam CNFG_BITS_10_RSTVAL = 23'h00_0000;  // READ_REF_CONFIG_REG
localparam CNFG_BITS_11_RSTVAL = 23'h00_0001;  // SET_CONFIG_REG
localparam CNFG_BITS_12_RSTVAL = 23'h00_0001;  // RESET_CONFIG_REG
localparam CNFG_BITS_13_RSTVAL = 23'h00_0001;  // BLDIS_CONFIG_REG
localparam CNFG_BITS_14_RSTVAL = 23'h00_0000;  // reserved
localparam CNFG_BITS_15_RSTVAL = 23'h00_0000;  // reserved
localparam CNFG_BITS_16_RSTVAL = 23'h00_0020;  // STATUS_REG
localparam CNFG_BITS_17_RSTVAL = 23'h1F_FFFF;  // DIAGNOSTIC1_REG (contents is held in diag holding reg)
localparam CNFG_BITS_18_RSTVAL = 23'h03_0000;  // DIAGNOSTIC2_REG (contents is held in diag holding reg)
localparam CNFG_BITS_19_RSTVAL = 23'h00_0000;  // DIAGNOSTIC3_REG (contents is held in errcount holding reg)
localparam CNFG_BITS_20_RSTVAL = 23'h00_0000;  // DIAGNOSTIC4_REG (contents is held in errcount holding reg)
localparam CNFG_BITS_21_RSTVAL = 23'h00_0000;  // reserved
localparam CNFG_BITS_22_RSTVAL = 23'h00_0000;  // reserved
localparam CNFG_BITS_23_RSTVAL = 23'h00_0000;  // reserved
localparam CNFG_BITS_24_RSTVAL = 23'h00_0000;  // reserved
localparam CNFG_BITS_25_RSTVAL = 23'h00_0000;  // reserved
localparam CNFG_BITS_26_RSTVAL = 23'h00_0000;  // reserved
localparam CNFG_BITS_27_RSTVAL = 23'h00_0000;  // reserved
localparam CNFG_BITS_28_RSTVAL = 23'h00_0000;  // reserved
localparam CNFG_BITS_29_RSTVAL = 23'h00_0000;  // reserved
localparam CNFG_BITS_30_RSTVAL = 23'h00_0000;  // reserved

localparam CNFG_BITS_0_ADDR  = 5'h00;
localparam CNFG_BITS_1_ADDR  = 5'h01;
localparam CNFG_BITS_2_ADDR  = 5'h02;
localparam CNFG_BITS_3_ADDR  = 5'h03;
localparam CNFG_BITS_4_ADDR  = 5'h04;
localparam CNFG_BITS_5_ADDR  = 5'h05;
localparam CNFG_BITS_6_ADDR  = 5'h06;
localparam CNFG_BITS_7_ADDR  = 5'h07;
localparam CNFG_BITS_8_ADDR  = 5'h08;
localparam CNFG_BITS_9_ADDR  = 5'h09;
localparam CNFG_BITS_10_ADDR = 5'h0A;
localparam CNFG_BITS_11_ADDR = 5'h0B;
localparam CNFG_BITS_12_ADDR = 5'h0C;
localparam CNFG_BITS_13_ADDR = 5'h0D;
localparam CNFG_BITS_14_ADDR = 5'h0E;
localparam CNFG_BITS_15_ADDR = 5'h0F;
localparam CNFG_BITS_16_ADDR = 5'h10;
localparam CNFG_BITS_17_ADDR = 5'h11;
localparam CNFG_BITS_18_ADDR = 5'h12;
localparam CNFG_BITS_19_ADDR = 5'h13;
localparam CNFG_BITS_20_ADDR = 5'h14;
localparam CNFG_BITS_21_ADDR = 5'h15;
localparam CNFG_BITS_22_ADDR = 5'h16;
localparam CNFG_BITS_23_ADDR = 5'h17;
localparam CNFG_BITS_24_ADDR = 5'h18;
localparam CNFG_BITS_25_ADDR = 5'h19;
localparam CNFG_BITS_26_ADDR = 5'h1A;
localparam CNFG_BITS_27_ADDR = 5'h1B;
localparam CNFG_BITS_28_ADDR = 5'h1C;
localparam CNFG_BITS_29_ADDR = 5'h1D;
localparam CNFG_BITS_30_ADDR = 5'h1E;
localparam CNFG_BITS_31_ADDR = 5'h1F;

localparam TIE_LO = 1'b0;
localparam TIE_HI = 1'b1;

wire                   preset_n, pclk;
wire                   psel, penable, pwrite;
wire [ADDR_BITS_N-1:0] paddr;
wire [DATA_BITS_M-1:0] pwdata;
reg  [DATA_BITS_M-1:0] prdata;

wire sclk_dft;
wire regarray_reset_n;

reg  [22:0] cnfg_bits30;
reg  [22:0] cnfg_bits29;
reg  [22:0] cnfg_bits28;
reg  [22:0] cnfg_bits27;
reg  [22:0] cnfg_bits26;
reg  [22:0] cnfg_bits25;
reg  [22:0] cnfg_bits24;
reg  [22:0] cnfg_bits23;
reg  [22:0] cnfg_bits22;
reg  [22:0] cnfg_bits21;
reg  [22:0] cnfg_bits20;
reg  [22:0] cnfg_bits19;
reg  [22:0] cnfg_bits18;
reg  [22:0] cnfg_bits17;
reg  [22:0] cnfg_bits16;
reg  [22:0] cnfg_bits15;
reg  [22:0] cnfg_bits14;
reg  [22:0] cnfg_bits13;
reg  [22:0] cnfg_bits12;
reg  [22:0] cnfg_bits11;
reg  [22:0] cnfg_bits10;
reg  [22:0] cnfg_bits9;
reg  [22:0] cnfg_bits8;
reg  [22:0] cnfg_bits7;
reg  [22:0] cnfg_bits6;
reg  [22:0] cnfg_bits5;
reg  [22:0] cnfg_bits4;
reg  [22:0] cnfg_bits3;
reg  [22:0] cnfg_bits2;
reg  [22:0] cnfg_bits1;
reg  [22:0] cnfg_bits0;

wire [8:0] status_bus_in, status_bus_out;
wire       fsm_error_flag_s,
           rram_do_full_s,
           diag_fifo_full_s,
           diag_fifo_empty_s,
           mip_s,
           rip_s,
           wip_s,
           fip_s,
           byp_s;

// =======
// SCAN...
// =======
assign sclk_dft = (scan_mode) ? scan_clk : sclk;

assign regarray_reset_n = rst_n & (scan_mode | preset_n);

// ============
// SPI SLAVE...
// ============

wire sc_inv;
assign sc_inv = (scan_mode) ? ~rst_n : ~sc;

itrx_apbm_spi #(.ADDR_BITS_N  (ADDR_BITS_N ),
                .DATA_BITS_M  (DATA_BITS_M ),
                .PCLK_DIV     (PCLK_DIV    ),
                .APB_RST_ADDR (APB_RST_ADDR),
                .APB_RST_DATA (APB_RST_DATA),
                .APB_RST_RO   (APB_RST_RO  ),
                .CPOL_MODE    (CPOL_MODE   ),
                .CPHA_MODE    (CPHA_MODE   )) u_itrx_apbm_spi (

  // SPI Slave i/f...
  .sclk          (sclk_dft),  // (I) SPI serial clock
  .cs_n          (sc_inv),    // (I) SPI chip select (and async reset when cs_n = '1')
  .mosi          (mosi),      // (I) SPI master out, slave in
  .miso_data_out (miso),      // (O) SPI master in, slave out data
  .miso_oe_n     (miso_oe_n), // (O) SPI master in, slave out output enable, active LO

  // APB Master i/f...
  .preset_n (preset_n),                // (O) APB slave reset
  .pclk     (pclk),                    // (O) APB clock
  .psel     (psel),                    // (O) APB slave select
  .penable  (penable),                 // (O) APB slave enable
  .paddr    (paddr[ADDR_BITS_N-1:0]),  // (O) APB slave address
  .pwrite   (pwrite),                  // (O) APB write/read control
  .pwdata   (pwdata[DATA_BITS_M-1:0]), // (O) APB write data
  .prdata   (prdata[DATA_BITS_M-1:0])  // (I) APB slave read data
  );

// =============================
// SPECIAL CONTROL GENERATION...
// =============================

always @(posedge pclk or negedge rst_n)
  begin
    if (!rst_n)  // These control signals are NOT reset by soft "preset_n"!
                 //  A preset_n only resets the registers, and should not
                 //  be used to reset these sync signals, especially
                 //  the toggle indicators!
      begin
        spi_pop       <= 1'b0;
        fsm_go        <= 1'b0;
        data_out_read <= 1'b0;
      end
    else
      begin
        // spi_pop: a pulse that is asserted for two SCLK cycles indicating a READ from DIAGNOSTIC1_REG
        //           has occurred. This condition also causes holding regs cnfg_bits17 and cnfg_bits18
        //           to capture the values present on the failed_xxx inputs (which are sourced by the
        //           diagnostic FIFO)...

        spi_pop <= (psel & ~pwrite & (paddr == CNFG_BITS_17_ADDR));

        // fsm_go is a toggle indicator telling the fsm that a WRITE to CONTROL_REG has occurred...

        if (psel && penable && pwrite && (paddr == CNFG_BITS_0_ADDR))
          begin
            fsm_go <= ~fsm_go;
          end

        // data_out_read: a toggle indicator telling the rram_do holding register that SPI has read
        //                 its contents, and can de-assert rram_do_full flag...

        if (psel && penable && !pwrite && (paddr == CNFG_BITS_6_ADDR) &&
             rram_do_full_s)    // Intercept a user read of DATA_OUT_REG if it doesn't contain valid data...
          begin
            data_out_read <= ~data_out_read;
          end
      end
  end

// ===============
// REGISTER ARRAY...
// ===============

// Control Registers
always @(posedge pclk or negedge regarray_reset_n)
  begin
    if (!regarray_reset_n)
      begin
        cnfg_bits30 <= CNFG_BITS_30_RSTVAL;
        cnfg_bits29 <= CNFG_BITS_29_RSTVAL;
        cnfg_bits28 <= CNFG_BITS_28_RSTVAL;
        cnfg_bits27 <= CNFG_BITS_27_RSTVAL;
        cnfg_bits26 <= CNFG_BITS_26_RSTVAL;
        cnfg_bits25 <= CNFG_BITS_25_RSTVAL;
        cnfg_bits24 <= CNFG_BITS_24_RSTVAL;
        cnfg_bits23 <= CNFG_BITS_23_RSTVAL;
        cnfg_bits22 <= CNFG_BITS_22_RSTVAL;
        cnfg_bits21 <= CNFG_BITS_21_RSTVAL;
        cnfg_bits20 <= CNFG_BITS_20_RSTVAL;
        cnfg_bits19 <= CNFG_BITS_19_RSTVAL;
        cnfg_bits18 <= CNFG_BITS_18_RSTVAL;
        cnfg_bits17 <= CNFG_BITS_17_RSTVAL;
        cnfg_bits16 <= CNFG_BITS_16_RSTVAL;
        cnfg_bits15 <= CNFG_BITS_15_RSTVAL;
        cnfg_bits14 <= CNFG_BITS_14_RSTVAL;
        cnfg_bits13 <= CNFG_BITS_13_RSTVAL;
        cnfg_bits12 <= CNFG_BITS_12_RSTVAL;
        cnfg_bits11 <= CNFG_BITS_11_RSTVAL;
        cnfg_bits10 <= CNFG_BITS_10_RSTVAL;
        cnfg_bits9  <= CNFG_BITS_9_RSTVAL;
        cnfg_bits8  <= CNFG_BITS_8_RSTVAL;
        cnfg_bits7  <= CNFG_BITS_7_RSTVAL;
        cnfg_bits6  <= CNFG_BITS_6_RSTVAL;
        cnfg_bits5  <= CNFG_BITS_5_RSTVAL;
        cnfg_bits4  <= CNFG_BITS_4_RSTVAL;
        cnfg_bits3  <= CNFG_BITS_3_RSTVAL;
        cnfg_bits2  <= CNFG_BITS_2_RSTVAL;
        cnfg_bits1  <= CNFG_BITS_1_RSTVAL;
        cnfg_bits0  <= CNFG_BITS_0_RSTVAL;
      end
    else
      begin
        if (psel && penable && pwrite && (paddr == CNFG_BITS_30_ADDR))
          begin
            cnfg_bits30 <= pwdata[22:0];
          end
        if (psel && penable && pwrite && (paddr == CNFG_BITS_29_ADDR))
          begin
            cnfg_bits29 <= pwdata[22:0];
          end
        if (psel && penable && pwrite && (paddr == CNFG_BITS_28_ADDR))
          begin
            cnfg_bits28 <= pwdata[22:0];
          end
        if (psel && penable && pwrite && (paddr == CNFG_BITS_27_ADDR))
          begin
            cnfg_bits27 <= pwdata[22:0];
          end
        if (psel && penable && pwrite && (paddr == CNFG_BITS_26_ADDR))
          begin
            cnfg_bits26 <= pwdata[22:0];
          end
        if (psel && penable && pwrite && (paddr == CNFG_BITS_25_ADDR))
          begin
            cnfg_bits25 <= pwdata[22:0];
          end
        if (psel && penable && pwrite && (paddr == CNFG_BITS_24_ADDR))
          begin
            cnfg_bits24 <= pwdata[22:0];
          end
        if (psel && penable && pwrite && (paddr == CNFG_BITS_23_ADDR))
          begin
            cnfg_bits23 <= pwdata[22:0];
          end
        if (psel && penable && pwrite && (paddr == CNFG_BITS_22_ADDR))
          begin
            cnfg_bits22 <= pwdata[22:0];
          end
        if (psel && penable && pwrite && (paddr == CNFG_BITS_21_ADDR))
          begin
            cnfg_bits21 <= pwdata[22:0];
          end
        if (psel && penable && pwrite && (paddr == CNFG_BITS_20_ADDR))
          begin
            cnfg_bits20 <= pwdata[22:0];
          end
        if (psel && penable && pwrite && (paddr == CNFG_BITS_19_ADDR))
          begin
            cnfg_bits19 <= pwdata[22:0];
          end

        // DIAGNOSTIC1_REG: a READ from this register captures information from
        //  the diagnostic FIFO and creates the spi_pop pulse. FIFO info is stored
        //  in BOTH cnfg_bits17 and cnfg_bits18 as the holding register...

        if (psel && !pwrite && (paddr == CNFG_BITS_17_ADDR))
          begin
            cnfg_bits17 <= {2'b00, failed_address, failed_bank};
            cnfg_bits18 <= {5'b00000, failed_operation, failed_data_bits};
          end

        if (psel && penable && pwrite && (paddr == CNFG_BITS_16_ADDR))
          begin
          end
        if (psel && penable && pwrite && (paddr == CNFG_BITS_15_ADDR))
          begin
            cnfg_bits15 <= pwdata[22:0];
          end
        if (psel && penable && pwrite && (paddr == CNFG_BITS_14_ADDR))
          begin
            cnfg_bits14 <= pwdata[22:0];
          end
        if (psel && penable && pwrite && (paddr == CNFG_BITS_13_ADDR))
          begin
            cnfg_bits13 <= pwdata[22:0];
          end
        if (psel && penable && pwrite && (paddr == CNFG_BITS_12_ADDR))
          begin
            cnfg_bits12 <= pwdata[22:0];
          end
        if (psel && penable && pwrite && (paddr == CNFG_BITS_11_ADDR))
          begin
            cnfg_bits11 <= pwdata[22:0];
          end
        if (psel && penable && pwrite && (paddr == CNFG_BITS_10_ADDR))
          begin
            cnfg_bits10 <= pwdata[22:0];
          end
        if (psel && penable && pwrite && (paddr == CNFG_BITS_9_ADDR))
          begin
            cnfg_bits9  <= pwdata[22:0];
          end
        if (psel && penable && pwrite && (paddr == CNFG_BITS_8_ADDR))
          begin
            cnfg_bits8  <= pwdata[22:0];
          end
        if (psel && penable && pwrite && (paddr == CNFG_BITS_7_ADDR))
          begin
            cnfg_bits7  <= pwdata[22:0];
          end
        if (psel && penable && pwrite && (paddr == CNFG_BITS_6_ADDR))
          begin
            cnfg_bits6  <= pwdata[22:0];
          end
        if (psel && penable && pwrite && (paddr == CNFG_BITS_5_ADDR))
          begin
            cnfg_bits5  <= pwdata[22:0];
          end
        if (psel && penable && pwrite && (paddr == CNFG_BITS_4_ADDR))
          begin
            cnfg_bits4  <= pwdata[22:0];
          end
        if (psel && penable && pwrite && (paddr == CNFG_BITS_3_ADDR))
          begin
            cnfg_bits3  <= pwdata[22:0];
          end
        if (psel && penable && pwrite && (paddr == CNFG_BITS_2_ADDR))
          begin
            cnfg_bits2  <= pwdata[22:0];
          end
        if (psel && penable && pwrite && (paddr == CNFG_BITS_1_ADDR))
          begin
            cnfg_bits1  <= pwdata[22:0];
          end
        if (psel && penable && pwrite && (paddr == CNFG_BITS_0_ADDR))
          begin
            cnfg_bits0  <= pwdata[22:0];
          end
      end
  end

// bitfield mapping...

assign clu_op_code = cnfg_bits0[2:0];

assign sa_clk_conf       = cnfg_bits1[21:20];
assign check_board_conf  = cnfg_bits1[19];
assign read_multi_offset = cnfg_bits1[18:2];
assign read_mode         = cnfg_bits1[1:0];

assign wdata_pattern      = cnfg_bits2[21:19];
assign write_multi_offset = cnfg_bits2[18:2];
assign write_mode         = cnfg_bits2[1:0];

assign form_multi_offset = cnfg_bits3[18:2];
assign form_mode         = cnfg_bits3[1:0];

assign address = cnfg_bits4[20:4];
assign banksel = cnfg_bits4[3:0];

assign data_in = cnfg_bits5[15:0];

assign rdata_dest   = cnfg_bits7[6];
assign wdata_source = cnfg_bits7[5];
assign addr_source  = cnfg_bits7[4];
assign diag_mode    = cnfg_bits7[0];

assign force_set_type = cnfg_bits8[8];
assign ref_mode       = cnfg_bits8[7];
assign set_ref_config = cnfg_bits8[6:0];

assign reset_ref_config = cnfg_bits9[6:0];

assign read_ref_config = cnfg_bits10[6:0];

assign set_retry_limit  = cnfg_bits11[22:17];
assign set_timer_config = cnfg_bits11[16:0];

assign reset_retry_limit  = cnfg_bits12[22:17];
assign reset_timer_config = cnfg_bits12[16:0];

assign bldis_timer_config = cnfg_bits13[16:0];

// =======================
// Control/Status Readback
// =======================

// re-sync the single-bit status fields, as users may
//  use these fields for program control...

// *NOTE: the fsm_state field is RAW STATUS ONLY, not re-sync'd
//    to pclk domain. Users should NOT rely on this field
//    for program control...

assign status_bus_in = {fsm_error_flag,
                        rram_do_full,
                        diag_fifo_full,
                        diag_fifo_empty,
                        mip,
                        rip,
                        wip,
                        fip,
                        byp};

itrx_sync_ffr #(.NUM_FLOPS (32'd2),
                .WID       (32'd9),
                .RST_VAL   (1'b0)) u_sync_status_bits (
  .rst_n (regarray_reset_n),
  .clk   (pclk),
  .din   (status_bus_in),
  .dout  (status_bus_out)
  );

assign fsm_error_flag_s  = status_bus_out[8];
assign rram_do_full_s    = status_bus_out[7];
assign diag_fifo_full_s  = status_bus_out[6];
assign diag_fifo_empty_s = status_bus_out[5];
assign mip_s             = status_bus_out[4];
assign rip_s             = status_bus_out[3];
assign wip_s             = status_bus_out[2];
assign fip_s             = status_bus_out[1];
assign byp_s             = status_bus_out[0];


always @*
  begin
    case (paddr)
      CNFG_BITS_31_ADDR: prdata = APB_RST_DATA;
      CNFG_BITS_30_ADDR: prdata = 23'h00_0000;
      CNFG_BITS_29_ADDR: prdata = 23'h00_0000;
      CNFG_BITS_28_ADDR: prdata = 23'h00_0000;
      CNFG_BITS_27_ADDR: prdata = 23'h00_0000;
      CNFG_BITS_26_ADDR: prdata = 23'h00_0000;
      CNFG_BITS_25_ADDR: prdata = 23'h00_0000;
      CNFG_BITS_24_ADDR: prdata = 23'h00_0000;
      CNFG_BITS_23_ADDR: prdata = 23'h00_0000;
      CNFG_BITS_22_ADDR: prdata = 23'h00_0000;
      CNFG_BITS_21_ADDR: prdata = 23'h00_0000;
      CNFG_BITS_20_ADDR: prdata = {6'h00, reset_error_count};
      CNFG_BITS_19_ADDR: prdata = {6'h00, set_error_count};
      CNFG_BITS_18_ADDR: prdata = cnfg_bits18;
      CNFG_BITS_17_ADDR: prdata = cnfg_bits17;
      CNFG_BITS_16_ADDR: prdata = {6'h00, 3'b000, fsm_error_flag_s, fsm_state,
                                   rram_do_full_s, diag_fifo_full_s, diag_fifo_empty_s, mip_s,
                                   rip_s, wip_s, fip_s, byp_s};
      CNFG_BITS_15_ADDR: prdata = 23'h00_0000;
      CNFG_BITS_14_ADDR: prdata = 23'h00_0000;
      CNFG_BITS_13_ADDR: prdata = {6'h00, bldis_timer_config};
      CNFG_BITS_12_ADDR: prdata = {reset_retry_limit, reset_timer_config};
      CNFG_BITS_11_ADDR: prdata = {set_retry_limit, set_timer_config};
      CNFG_BITS_10_ADDR: prdata = {16'h0000, read_ref_config};
      CNFG_BITS_9_ADDR:  prdata = {16'h0000, reset_ref_config};
      CNFG_BITS_8_ADDR:  prdata = {14'h0000, force_set_type, ref_mode, set_ref_config};
      CNFG_BITS_7_ADDR:  prdata = {15'h0000, 
                                   1'b0, rdata_dest, wdata_source, addr_source,
                                   3'b000, diag_mode};
      CNFG_BITS_6_ADDR:  prdata = {rdata_dest, 5'h00, rram_do_full_s, data_out};
      CNFG_BITS_5_ADDR:  prdata = {7'h00, data_in};
      CNFG_BITS_4_ADDR:  prdata = {2'h0, address, banksel};
      CNFG_BITS_3_ADDR:  prdata = {4'h0, form_multi_offset, form_mode};
      CNFG_BITS_2_ADDR:  prdata = {1'b0, wdata_pattern, write_multi_offset, write_mode};
      CNFG_BITS_1_ADDR:  prdata = {1'b0, sa_clk_conf, check_board_conf, read_multi_offset, read_mode};
      CNFG_BITS_0_ADDR:  prdata = {20'h0_0000, clu_op_code};

      default: prdata = 23'h00_0000;
    endcase
  end


endmodule
