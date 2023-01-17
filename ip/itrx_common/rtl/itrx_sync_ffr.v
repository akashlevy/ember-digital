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
// Filename       : itrx_sync_ffr.v
// Description    : n-flop synchronizer, active LO reset to either 1's or
//                  0's, parameterized data width
// 
// ==========================================================================
//
//    $Rev:: 3676                      $: Revision of last commit
// $Author:: aducimo                   $: Author of last commit
//   $Date:: 2015-08-26 14:17:43 -0400#$: Date of last commit
// 
// ==========================================================================

// trap to not recompile common modules...
`ifndef ITRX_SYNC_FFR_V
//lint_checking USEMAC off
`define ITRX_SYNC_FFR_V
//lint_checking USEMAC on

module itrx_sync_ffr #( parameter NUM_FLOPS = 32'd2,        // default to 2-flop synchronizer
                        parameter WID       = 32'd1,        // default to one data bit
                        parameter RST_VAL   = 1'b0 ) (      // default to resetting flops to 0's

    input                   rst_n,  // (I) reset, active LO
    input                   clk,    // (I) clock
    input       [WID-1:0]   din,    // (I) data signal in

    output wire [WID-1:0]   dout    // (O) sync'd data signal out
    );

genvar i;
generate
  for (i=0; i<WID; i=i+1) begin : i_loop
    reg  [NUM_FLOPS-1:0] sync_in;

    always @(posedge clk or negedge rst_n)
      begin
        if (!rst_n)
          begin
            sync_in <= {NUM_FLOPS{RST_VAL}};
          end
        else
          begin
            sync_in <= {sync_in[NUM_FLOPS-2:0], din[i]};
          end
      end

    assign dout[i] = sync_in[NUM_FLOPS-1];

  end // i_loop
endgenerate

endmodule
`endif