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
// Filename       : itrx_clkdiv2_rpl.v
// Description    : Simple ripple clock divider. Divides by two
//
// ==========================================================================
//
//    $Rev:: 3945                      $: Revision of last commit
// $Author:: aducimo                   $: Author of last commit
//   $Date:: 2016-01-22 12:10:43 -0500#$: Date of last commit
// 
// ==========================================================================

module itrx_clkdiv2_rpl (
  input      reset_n,
  input      en,
  input      clk_in,
  output reg clk_out
);
                     

  always @(posedge clk_in or negedge reset_n) begin : gen_clk
    if(!reset_n) begin : reset_blk
      clk_out <= 1'b0;
    end
    else begin : clk_div
      if (en) begin
        clk_out <= !clk_out;
      end
    end
  end
  
endmodule // itrx_clkdiv2_rpl
