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
// Filename       : itrx_sync_dbnc.v
// Description    : full signal debouncer, active LO reset to either 1's or
//                  0's, parameterized data width, bypass mode
// 
// ==========================================================================
//
//    $Rev:: 3676                      $: Revision of last commit
// $Author:: aducimo                   $: Author of last commit
//   $Date:: 2015-08-26 14:17:43 -0400#$: Date of last commit
// 
// ==========================================================================

// trap to not recompile common modules...
`ifndef ITRX_SYNC_DBNC_V
//lint_checking USEMAC off
`define ITRX_SYNC_DBNC_V
//lint_checking USEMAC on

module itrx_sync_dbnc #( parameter WID       = 32'd1,        // default to one data bit
                         parameter RST_VAL   = 1'b0,         // default to resetting flops to 0's
                         parameter COUNT_WID = 32'd24 ) (    // width of capture window counter

    input                       rst_n,  // (I) reset, active LO
    input                       clk,    // (I) clock
    input                       bypass, // (I) bypass mode
    input       [COUNT_WID-1:0] countval, // (I) 24-bit counter value provides the capture window
    input       [WID-1:0]       din,    // (I) data signal in

    output wire [WID-1:0]       dout    // (O) sync'd data signal out
    );

localparam COUNTER_0 = {COUNT_WID{1'b0}};
localparam COUNTER_1 = {{COUNT_WID-1{1'b0}}, 1'b1};

genvar i;
generate
  for (i=0; i<WID; i=i+1) begin : i_loop
    reg  [2:0] sync_in;
    reg  final_sync;
    wire din_change;
    reg  [COUNT_WID-1:0] counter;

    // straight 3-flop sync of din, need to detect any change in state...
    always @(posedge clk or negedge rst_n)
      begin
        if (!rst_n)
          begin
            sync_in <= {3{RST_VAL}};
          end
        else
          begin
            sync_in[2:0] <= {sync_in[1:0], din[i]};
          end
      end

    // din change detector...
    assign din_change = (sync_in[2] ^ sync_in[1]);

    // debounce counter: when this counter reaches zero, allow a final stage of signal sampling. If any
    //  change in din is detected, the counter reloads to countval (i.e. as long as the
    //  input is changing state it keeps reloading the counter, preventing it from reaching
    //  zero, thus preventing it from the final stage sampling of din)...
    always @(posedge clk or negedge rst_n)
      begin
        if (!rst_n)
          begin
            counter <= {COUNT_WID{1'b0}};
          end
        else
          begin
            if ((counter == COUNTER_0) || din_change)    // the counter will reload either when it
              begin                                         //  reaches zero (allowing final stage sample
                counter <= countval[COUNT_WID-1:0];         //  din), or if a change to din is detected...
              end
            else
              begin
                counter <= counter - COUNTER_1;
              end
          end
      end

    // final stage sampling of din: ONLY when the counter reaches zero (meaning that din has been
    //  stable for countval cycles)...
    always @(posedge clk or negedge rst_n)
      begin
        if (!rst_n)
          begin
            final_sync <= RST_VAL;
          end
        else
          begin
            if (counter == COUNTER_0)            // final sampling stage of din ONLY when counter == 0...
              begin
                final_sync <= sync_in[2];
              end
          end
      end

    assign dout[i] = bypass ? din[i] : final_sync;

  end // i_loop
endgenerate

endmodule
`endif
