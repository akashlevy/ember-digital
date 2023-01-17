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
// Filename       : itrx_sync_ff.v
// Description    : n-flop synchronizer, no reset, parameterized data width
// 
// ==========================================================================
//
//    $Rev:: 3676                      $: Revision of last commit
// $Author:: aducimo                   $: Author of last commit
//   $Date:: 2015-08-26 14:17:43 -0400#$: Date of last commit
// 
// ==========================================================================

// trap to not recompile common modules...
`ifndef ITRX_SYNC_FF_V
//lint_checking USEMAC off
`define ITRX_SYNC_FF_V
//lint_checking USEMAC on

module itrx_sync_ff #( parameter NUM_FLOPS = 32'd2,
                       parameter WID       = 32'd1 ) (

    input                   clk,    // (I) clock
    input       [WID-1:0]   din,     // (I) data signal in

    output wire [WID-1:0]   dout     // (O) sync'd data signal out
    );

genvar i;
generate
  for (i=0; i<WID; i=i+1) begin : i_loop
    reg  [NUM_FLOPS-1:0] sync_in;

    always @(posedge clk)
      begin
        sync_in <= {sync_in[0], din[i]};
      end

    assign dout[i] = sync_in[NUM_FLOPS-1];

  end // i_loop
endgenerate

endmodule
`endif
