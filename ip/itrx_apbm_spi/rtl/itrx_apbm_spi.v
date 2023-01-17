// --------------------------------------------------------------------------
// ======================= COPYRIGHT NOTICE =================================
// --------------------------------------------------------------------------
//                Copyright 2019 © Intrinsix Corp. - All Rights Reserved
//                  Intrinsix Corp. Proprietary and Confidential 
//
// Intrinsix Corp. owns the sole copyright to this software. Under
// international copyright laws you (1) may not make a copy of this software
// except for the purposes of maintaining a single archive copy, (2) may not
// derive works herefrom, (3) may not distribute this work to others. These
// rights are provided forinformation clarification, other restrictions of
// rights may apply as well.
//
// This is an unpublished work.
//
// =========================== Warrantee ====================================
// --------------------------------------------------------------------------
// Intrinsix Corp. MAKES NO WARRANTY OF ANY KIND WITH REGARD TO THE USE OF
// THIS SOFTWARE, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO,
// THE IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR
// PURPOSE.
//
// Description: SPI Slave APB Master Top Level
// Author:      Dave Charneski, Bill Elliott
// Filename:    $Id$
// Date:        $Date$
// Revisions:   $Log$

module itrx_apbm_spi 
#(
  parameter ADDR_BITS_N = 5,
            DATA_BITS_M = 8,
            PCLK_DIV = 1,
            APB_RST_ADDR = 0,
            APB_RST_DATA = 0,
            APB_RST_RO = 0,
            CPOL_MODE = 0,
            CPHA_MODE = 1
)
(
  // SPI Slave Inputs
  sclk,          // SPI serial clock
  cs_n,          // SPI chip select (and async reset when cs_n = '1')
  mosi,          // SPI master out, slave in
  // APB Input From Slave
  prdata,        // APB slave read data
  // SPI Outputs
  miso_data_out, // SPI master in, slave out data
  miso_oe_n,     // SPI master in, slave out output enable
  // APB Master Outputs
  preset_n,      // APB slave reset
  // pclk,          // APB clock
  psel,          // APB slave select
  penable,       // APB slave enable
  paddr,         // APB slave address
  pwdata,        // APB write data
  pwrite         // APB write/read control
);

  //-----------------------------------------------------------------------------
  //-- Local Parameters
  //-----------------------------------------------------------------------------
  localparam PCLK_WR_PHA = 
      (2*PCLK_DIV - (ADDR_BITS_N + DATA_BITS_M) % PCLK_DIV) % PCLK_DIV;
  localparam PCLK_RD_PHA = 
      (2*PCLK_DIV - ADDR_BITS_N % PCLK_DIV) % PCLK_DIV;
  //-----------------------------------------------------------------------------
  //-- I/O
  //-----------------------------------------------------------------------------
  input sclk;
  input cs_n;
  input mosi;
  input [(DATA_BITS_M-1):0] prdata;
  output miso_data_out;
  output miso_oe_n;
  output preset_n;
  output psel;
  output penable;
  output [(ADDR_BITS_N-1):0] paddr;
  output [(DATA_BITS_M-1):0] pwdata;
  output pwrite;

  // -----------------------------------------------------------------------------
  // Regs
  // -----------------------------------------------------------------------------

  // -----------------------------------------------------------------------------
  // Wires
  // -----------------------------------------------------------------------------
  wire rst_n;
  wire trans_start;
  wire trans_done;
  wire assert_preset;

  wire pwrite_e; // lint checking

  // -----------------------------------------------------------------------------
  // Invert CS_N to create RST_N.
  // -----------------------------------------------------------------------------
  assign rst_n = !cs_n;

  // // -----------------------------------------------------------------------------
  // // clocks_inst: Instance of clocks. Receives SPI serial clock, sclk, and
  // // creates pclk, sclk_buf, sclk180. This module serves at the site for the root
  // // node of all clock tree buffering.
  // // -----------------------------------------------------------------------------
  // itrx_apbm_spi_clks 
  // #(
  //   .PCLK_DIV(PCLK_DIV),
  //   .CPHA_MODE(CPHA_MODE),
  //   .CPOL_MODE(CPOL_MODE),
  //   .PCLK_WR_PHA(PCLK_WR_PHA),
  //   .PCLK_RD_PHA(PCLK_RD_PHA)
  // )
  // u_clks (
  //   // Inputs
  //   .sclk(sclk),         // SPI sclk in
  //   .rst_n(rst_n),       // Async reset
  //   .pwrite(pwrite_e),
  //   // Outputs
  //   .pclk_re_e(pclk_re_e), // Early indicator of pclk rising edge
  //   .pclk_buf(pclk_buf), // APB clock (sclk divided by PCLK_DIV)
  //   .sclk_buf(sclk_buf)  // SPI sclk out
  // );

  // -----------------------------------------------------------------------------
  // spi_fsm instance: FSM to handle the SPI interface. Connects to the APB data
  // and address buses
  // -----------------------------------------------------------------------------
  itrx_apbm_spi_fsm 
  #(
      .ADDR_BITS_N(ADDR_BITS_N),
      .DATA_BITS_M(DATA_BITS_M),
      .APB_RST_ADDR(APB_RST_ADDR),
      .APB_RST_DATA(APB_RST_DATA),
      .APB_RST_RO(APB_RST_RO),
      .CPHA_MODE(CPHA_MODE)
  )
  u_spi_fsm (
    // SPI Slave Inputs
    .sclk(sclk),                   // SPI clock
    .rst_n(rst_n),                 // Async reset
    .mosi(mosi),                   // SPI master out, slave in
    // APB FSM interface
    .trans_start(trans_start),
    .trans_done(trans_done),
    .assert_preset(assert_preset),
    // clk divider interface
    .pclk_re_e(1'b1),
    // APB Inputs From Slave
    .prdata(prdata),               // APB slave read data
    // SPI Slave Outputs
    .miso_data_out(miso_data_out), // SPI master in, slave out data
    .miso_oe_n(miso_oe_n),         // SPI master in, slave out output enable
    // APB Master Outputs
    .paddr(paddr),                 // APB slave address
    .pwdata(pwdata),               // APB write data
    .pwrite(pwrite),               // APB write/read control
    .pwrite_e(pwrite_e)            // APB write/read control 1/2 clock cycle early
  );

  // -----------------------------------------------------------------------------
  // -----------------------------------------------------------------------------
  itrx_apbm_fsm 
  #(
      .ADDR_BITS_N(ADDR_BITS_N),
      .DATA_BITS_M(DATA_BITS_M)
  )
  u_apb_fsm (
    // SPI Slave Inputs
    .sclk(sclk),                   // SPI clock
    .pclk_re_e(1'b1),              // Async reset
    .rst_n(rst_n),                 // Async reset
    // Handshaking with SPI FSM
    .trans_start(trans_start),
    .trans_done(trans_done),
    .assert_preset(assert_preset),
    // APB Inputs From Slave
    .pready(1'b1),                 // APB slave ready
    // APB Master Outputs
    .preset_n(preset_n),           // APB slave address
    .psel(psel),                   // APB write data
    .penable(penable)              // APB write data
  );


endmodule
