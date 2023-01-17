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
// Filename       : itrx_sync_rstp_scan.v
// Description    : active HI reset de-assertion synchronizer, parameterized
//                  pipeline depth, scanmode bypass
//
// 
// ==========================================================================
//
//    $Rev:: 3676                      $: Revision of last commit
// $Author:: aducimo                   $: Author of last commit
//   $Date:: 2015-08-26 14:17:43 -0400#$: Date of last commit
// 
// ==========================================================================

// trap to not recompile common modules...
`ifndef ITRX_SYNC_RSTP_SCAN_V
//lint_checking USEMAC off
`define ITRX_SYNC_RSTP_SCAN_V
//lint_checking USEMAC on

module itrx_sync_rstp_scan #( parameter NUM_FLOPS = 32'd2 ) (
    input           rst,    // (I) reset, active HI
    input           clk,    // (I) clock
    input           scanmode, // (I) Scan testm mode indicator

    output wire     dout     // (O) sync'd reset signal out
    );

reg  [NUM_FLOPS-1:0] sync_rstp;

always @(posedge clk or posedge rst)
  begin
    if (rst)
      begin
        sync_rstp <= {NUM_FLOPS{1'b1}};
      end
    else
      begin
        sync_rstp <= {sync_rstp[NUM_FLOPS-2:0], 1'b0};
      end
    end

    assign dout = scanmode ? rst : sync_rstp[NUM_FLOPS-1];

endmodule
`endif
