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
// Description: Clocks for SPI Master APB Slave IP
// Author:      Dave Charneski, Bill Elliott
// Filename:    $Id$
// Date:        $Date$
// Revisions:   $Log$

module itrx_apbm_spi_clks 
#(
  parameter CPOL_MODE = 0,
            CPHA_MODE = 1,
            PCLK_DIV = 1,
            PCLK_WR_PHA = 0,
            PCLK_RD_PHA = 0
)
(
  // Inputs
  sclk,      // SPI sclk in
  rst_n,     // Async reset
  pwrite, 
  // Outputs
  pclk_re_e, // early rising edge indication in sclk domain
  pclk_buf,  // APB clock
  sclk_buf   // SPI sclk out
);

  //-------------------------------------------------------------------
  // parameters
  // -------------------------------------------------------------------
  `include "itrx_clog2.vh"
//  parameter PCLK_MSB = `ITRX_CLOG2(PCLK_DIV) - 1;

  //-----------------------------------------------------------------------------
  //-- I/O
  //-----------------------------------------------------------------------------
  input  sclk;
  input  rst_n;
  input  pwrite;
  output pclk_re_e;
  output pclk_buf;
  output sclk_buf;

  //-----------------------------------------------------------------------------
  //-- Wires common to all configurations
  //-----------------------------------------------------------------------------
  wire sclk_loc = (CPOL_MODE != CPHA_MODE) ? sclk : ~sclk;
  wire pclk_loc;

  // Generate block to split out special case of PCLK_DIV=1
  generate
    if      (PCLK_DIV == 1) begin : pdiv_1_gen_blk
      assign pclk_re_e   = 1'b1;
      assign pclk_loc = sclk_loc; // equals pls too, but synth can remove ff
    end
    else if (PCLK_DIV == 2 || PCLK_DIV == 4 || PCLK_DIV == 8) begin : pdiv_2to8_gen_blk
      localparam PCLK_MSB = (PCLK_DIV > 1) ? (`ITRX_CLOG2(PCLK_DIV) - 1) : 1; // Line 52 moved here to avoid synthesis error
      //-----------------------------------------------------------------------------
      //-- Registers
      //-----------------------------------------------------------------------------
      reg [PCLK_MSB:0] pclk_ctr;
      reg pclk_pls_gate;
      reg pclk_enab;
      reg wr_bit_rcvd, wr_bit_rcvd_pe;
    
      //-----------------------------------------------------------------------------
      //-- Wires
      //-----------------------------------------------------------------------------
      wire pclk_pls;
      wire pclk_pls_gate_d;
      wire [PCLK_MSB:0] pclk_ctr_d;
      wire pclk_enab_d;
      wire wr_bit_pls = wr_bit_rcvd & ~wr_bit_rcvd_pe;
    
      //-----------------------------------------------------------------------------
      //-- Assigns
      //-----------------------------------------------------------------------------
      assign pclk_pls    = sclk_loc & pclk_pls_gate;
      assign pclk_ctr_d  = ~wr_bit_rcvd ? 3'd0 : 
                              (wr_bit_pls ? (pwrite ? PCLK_WR_PHA : PCLK_RD_PHA) : pclk_ctr + 3'd1);
      assign pclk_enab_d = pclk_enab  ? 1'b1 : (pclk_pls_gate_d ? 1'b1 : 1'b0);
      assign pclk_pls_gate_d = pclk_re_e;
    
      assign pclk_re_e   = &pclk_ctr;
      assign pclk_loc = pclk_pls | (pclk_enab & ~pclk_ctr[PCLK_MSB]); // dc extender
    
      // -----------------------------------------------------------------------------
      // pclk_ctr: Divide SCLK down to create PCLK/2, PCLK/4, PCLK/8.
      // -----------------------------------------------------------------------------
      always @ (posedge sclk_buf or negedge rst_n)
      begin
        if (!rst_n) begin
          pclk_ctr    <= 3'd0;
          pclk_enab   <= 1'b0;
          wr_bit_rcvd_pe  <= 1'b0;
        end
        else begin
          pclk_ctr    <= pclk_ctr_d;
          pclk_enab   <= pclk_enab_d;
          wr_bit_rcvd_pe  <= wr_bit_rcvd;
        end
      end
    
      always @ (negedge sclk_loc or negedge rst_n)
      begin
        if (!rst_n) begin
          wr_bit_rcvd <= 1'b0;
          pclk_pls_gate <= 1'b0;
        end
        else begin
          wr_bit_rcvd <= 1'b1;
          pclk_pls_gate <= pclk_pls_gate_d;
        end
      end
    end // end of PCLK_DIV = 2, 4, 8 block
    else begin : pdiv_err_gen_blk
      //$error("%m : Invalid PCLK divide value PCLK_DIV = %1d (must be 1, 2, 4 or 8)", PCLK_DIV);
      invalid_module_to_cause_verilog_compatible_error_msg_for INVALID_PCLK_DIV_PARAM();
    end
  endgenerate

  // -----------------------------------------------------------------------------
  // dummy_clk_buf_sclk: Clock root node for SCLK.
  // -----------------------------------------------------------------------------
  dummy_clk_buf dummy_clk_buf_sclk (
    // Inputs
    .clk_in(sclk_loc),
    // Outputs
    .clk_out(sclk_buf)
  );

  // -----------------------------------------------------------------------------
  // dummy_clk_buf_pclk: Clock root node for PCLK.
  // -----------------------------------------------------------------------------
  dummy_clk_buf dummy_clk_buf_pclk (
    // Inputs
    .clk_in(pclk_loc),
    // Outputs
    .clk_out(pclk_buf)
  );

  // -----------------------------------------------------------------------------

endmodule
