// ============================ COPYRIGHT NOTICE ============================
// 
//            Copyright 2015 © Intrinsix Corp. - All Rights Reserved
//                  Intrinsix Corp. Proprietary and Confidential
//
// Intrinsix Corp. owns the sole copyright to this software. Under
// international copyright laws you (1) may not make a copy of this software
// except for the purposes of maintaining a single archive copy, (2) may not
// derive works herefrom, (3) may not distribute this work to others. These
// rights are provided for information clarification, other restrictions of
// rights may apply as well.
// 
// This is an unpublished work.
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
// Original Author: Anthony Ducimo
// Filename       : itrx_clkdiv_pwr2_rpl.v
// Description    : Parameterizable ripple clock divider. Divides
//                  clock by powers of two (up to 128).
// 
// ==========================================================================
//
//    $Rev:: 3945                      $: Revision of last commit
// $Author:: aducimo                   $: Author of last commit
//   $Date:: 2016-01-22 12:10:43 -0500#$: Date of last commit
// 
// ==========================================================================

module itrx_clkdiv_pwr2_rpl (
  reset_n,
  en,
  clk_in,
  clk_out

);

`include "itrx_clog2.vh" // Ceiling of log base 2 function macro

  parameter                      MAX_DIV_VAL     = 32'd128;
  localparam                     NUM_CNTR_BITS   = `ITRX_CLOG2(MAX_DIV_VAL+1);
  localparam                     NUM_CNTR_BITSM1 = NUM_CNTR_BITS-32'd1;
  parameter [NUM_CNTR_BITS-1:0]  PWR2            = {{NUM_CNTR_BITSM1{1'b0}},1'b1};
  
  input           reset_n;
  input           en;
  input           clk_in;
  output [PWR2:0] clk_out;

  genvar ii;

  assign clk_out[0] = en ? clk_in : 1'b0;
  
  generate
    if(PWR2 > {NUM_CNTR_BITS{1'b0}}) begin : divclk
      for(ii=1; ii<=PWR2; ii=ii+1) begin : div2_to_the
        itrx_clkdiv2_rpl _inst (.reset_n(reset_n), .en(en), .clk_in(clk_out[ii-1]), .clk_out(clk_out[ii]));
      end
    end // divclk
  endgenerate
endmodule
