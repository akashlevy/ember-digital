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
// Original Author: Kent Arnold
// Filename       : itrx_bit_mux.v
// Description    : 
// 
// ==========================================================================
//
//    $Rev:: 3676                      $: Revision of last commit
// $Author:: aducimo                   $: Author of last commit
//   $Date:: 2015-08-26 14:17:43 -0400#$: Date of last commit
// 
// ==========================================================================
// NOTE: based on parameterized N:1 bit mux code written by R. Baracka.
// o Generic/parameterized 1-bit wide MUX, N to 1.
// o Selectable 1-hot or binary encoding on the "sel" input
// o Returns "dout" = 0 if 1-hot "sel" is all zeros...
//

// trap to not recompile common modules...
`ifndef ITRX_BIT_MUX_V
//lint_checking USEMAC off
`define ITRX_BIT_MUX_V
//lint_checking USEMAC on

module itrx_bit_mux #(
 parameter  [31:0] N = 32'd17, // N to 1 mux
 parameter         T = 1'b1,   // Select type is 1-hot (otherwise encoded)
 parameter [N-1:0] M = {N{1'b0}}, // Mask is unused for input selections.
 parameter  [31:0] L = T ? N : itrx_clog2_fn(N)) (
  input  [N-1:0] din,          // Input data
  input  [L-1:0] sel,          // Input select
  output         dout);        // Output data

`include "itrx_clog2_fn.v" // Ceiling of log base 2 function

generate
 if (T) begin : t_gc
  assign dout = |(din & sel & ~M);
 end else begin : no_t_gc 
  assign dout = din[sel] & ~M[sel];
 end
endgenerate

endmodule
`endif
