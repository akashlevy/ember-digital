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
// Original Author: rbaracka
// Filename       : itrx_ahbs_ctrl.v
// Description    : AHB Slave Controller
// 
// ==========================================================================
//
//    $Rev:: 3676                      $: Revision of last commit
// $Author:: aducimo                   $: Author of last commit
//   $Date:: 2015-08-26 14:17:43 -0400#$: Date of last commit
// 
// ==========================================================================
/*
   Generic AHB slave controller with 0 wait state response.
    Generates output read/write strobes together with the address and size coincident with each AHB data phase transfer.
    Can be configured to generate an error response for HSIZEs not in range or via and input decoding error.
*/
module itrx_ahbs_ctrl #(
  parameter [ 2:0] HSIZE_MAX = 3'd2,      // Maximum allowed HSIZE for no err response (2^HSIZE bytes, e.g. 32-bits)
  parameter [ 2:0] HSIZE_MIN = 3'd2,      // Minimum allowed HSIZE for no err response
  parameter [31:0] HADDR_WID = 32'd20) (  // Number of address bits actually used by the slave.

   input        hclk,          // Standard AHB slave interface
   input        hreset_n,
   input [31:0] haddr,
   input [ 2:0] hburst,
   input        hmastlock,
   input        hready,
   input        hsel,
   input [ 2:0] hsize,
   input [ 1:0] htrans,
   input        hwrite,

   output reg   hresp,
   output reg   hreadyout,

   input                      haddr_decode_err, // May want to respond with error for address decoded by HSEL, yet otherwise invalid
   output reg [HADDR_WID-1:0] ahbs_haddr_rg,    // Latched address
   output reg [2:0]           ahbs_hsize_rg,    // HSIZE output
   output reg                 ahbs_rd_strb,     // Register Read  strobe
   output reg                 ahbs_wr_strb);    // Register Write strobe

localparam  [1:0] HTRANS_IDL = 2'b00; // AHB standard constants
localparam  [1:0] HTRANS_BSY = 2'b01;

wire valid_hctrl = (hsize >= HSIZE_MIN) & (hsize <= HSIZE_MAX) & !haddr_decode_err; // Valid AHB control and decode
wire addr_phase_rdy = hsel & hready & (htrans != HTRANS_IDL) & (htrans != HTRANS_BSY); // Selected, ready, and not IDLE and not Busy

always @(posedge hclk or negedge hreset_n)
 if (!hreset_n) begin
      {hreadyout, hresp, ahbs_rd_strb, ahbs_wr_strb} <= {1'b1, 1'b0, 1'b0, 1'b0};
      {ahbs_haddr_rg, ahbs_hsize_rg} <= {{HADDR_WID{1'b0}}, 3'd0};
  end else begin
   if (!hreadyout && hresp) begin // 2nd ERR response cycle
      {hreadyout, hresp, ahbs_rd_strb, ahbs_wr_strb} <= {1'b1, 1'b1, 1'b0, 1'b0}; // ERR and HREADY response
   end else if (addr_phase_rdy) begin // NON IDLE address phase with HREADY
     if (valid_hctrl) begin // Valid AHB read or write
      {hreadyout, hresp, ahbs_rd_strb, ahbs_wr_strb} <= {1'b1, 1'b0, ~hwrite, hwrite}; // OK and HREADY response, assert strobe
      end else begin // 1st ERR response cycle
      {hreadyout, hresp, ahbs_rd_strb, ahbs_wr_strb} <= {1'b0, 1'b1, 1'b0, 1'b0}; // ERR and NOT HREADY response
      end
    end else begin // IDLE or BUSY
      {hreadyout, hresp, ahbs_rd_strb, ahbs_wr_strb} <= {1'b1, 1'b0, 1'b0, 1'b0}; // OK and HREADY response
    end

   if (addr_phase_rdy && valid_hctrl)
    {ahbs_haddr_rg, ahbs_hsize_rg} <= {haddr[HADDR_WID-1:0], hsize}; // Latch HADDR and HSIZE
  end

wire unused_ok; // For linting & documentation
generate 
  if (HADDR_WID==32) begin : wid32
   assign unused_ok = |{hmastlock, hburst};
  end else begin : no_wid32
   assign unused_ok = |{hmastlock, hburst, haddr[31:HADDR_WID]};
  end
endgenerate

endmodule
