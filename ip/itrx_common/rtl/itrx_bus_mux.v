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
// Filename       : itrx_bus_mux.v
// Description    : 
// 
// ==========================================================================
//
//    $Rev:: 3676                      $: Revision of last commit
// $Author:: aducimo                   $: Author of last commit
//   $Date:: 2015-08-26 14:17:43 -0400#$: Date of last commit
// 
// ==========================================================================
// NOTE: based on parameterized N:1 bus mux code written by R. Baracka.
// o Multiplex input busses to output bus module
// o Generic/parameterized bus MUX, N to 1,
//    Output data is a "W" bit wide bus vector.
//    Input data is a N*W bit wide bus vector.
// o Selectable 1-hot or binary encoding on the "sel" input
// o Returns "dout" = W`0 if 1-hot "sel" is all zeros...

// trap to not recompile common modules...
`ifndef ITRX_BUS_MUX_V
//lint_checking USEMAC off
`define ITRX_BUS_MUX_V
//lint_checking USEMAC on

module itrx_bus_mux #(
  parameter  [31:0] W = 32'd64,              // Width of input data
  parameter  [31:0] N = 32'd17,              // N to 1 mux
  parameter         T = 1'b1,                // select Type == 1 is 1-hot (otherwise binary encoded)
  parameter   BIG_END = 1'b0,                // Big Endian select (if select is binary encoded then selection 0 selects the MSBs of the input)
  parameter [N-1:0] M = {N{1'b0}},           // connection Mask (set to 1 for each unused "disconnected" input source)
//parameter [N-1:0] M = 17'b00000000000000010,
  parameter  [31:0] L = T ? N : itrx_clog2_fn(N)) ( // Bit width of select input (DERIVED)
   input [N*W-1:0]  din,    // Input bus data
//lint: A "one bit bus" is expected for L == 1 (encoded 2-to-1 MUX select)
//lint_checking ONPNSG off
   input   [L-1:0] sel,    // Input select
//lint_checking ONPNSG on
   output  [W-1:0] dout);  // Output bus data

`include "itrx_clog2_fn.v" // ceiling of log base 2 function

genvar i,k;
generate
 for (k=0;k<W;k=k+1) begin : bit_out
  wire [N-1:0] dtmp;
  for (i=0;i<N;i=i+1) begin : word_in
   if (!M[i]) begin : no_msk_gc // Masked inputs are unused
     assign dtmp [i] = din[k+i*W];
    end else begin : msk_gc
     assign dtmp [i] = 1'b0;
    end
  end
  if (T) begin : oh_gc
      assign dout[k] = |(dtmp & sel); // 1-hot select
      wire unused_ok = BIG_END;
  end else begin : no_oh_gc 
    if (BIG_END) begin : be_gc
      localparam MAX_SEL = N - 32'd1; // Maximum value of binary encoded input selector
      wire [L-1:0] sel_be = MAX_SEL[L-1:0] - sel; // Adjust selection for big endian
      assign dout[k] = dtmp[sel_be];
     end else begin : no_be_gc
      assign dout[k] = dtmp[sel];
      wire unused_ok = BIG_END;
     end
   end
 end
endgenerate

endmodule
`endif
