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
// Filename       : itrx_amba4_axilite_if.sv
// Description    : Synthesizable AMBA4 AXI Interface.
//
// ==========================================================================
//
//    $Rev:: 3948                      $: Revision of last commit
// $Author:: aducimo                   $: Author of last commit
//   $Date:: 2016-01-22 12:49:13 -0500#$: Date of last commit
// 
// ==========================================================================

// lint_checking CDWARN off
`ifndef ITRX_AMBA4_AXILITE_IF_SV
// lint_checking USEMAC off
 `define ITRX_AMBA4_AXILITE_IF_SV
// lint_checking USEMAC on

// lint_checking EMPMOD off
interface itrx_amba4_axilite_if (input logic aclk, input logic areset_n);
  import itrx_amba4_axilite_pkg::*;

  parameter  XDATAW = 32'd64;
  localparam XSTRBW = PDATAW/8;

  // lint_checking ONPNSG off  
  // Write address channel signals
  t_xid                   awid;
  t_xaddr                 awaddr;
  ts_xprot                awprot;
  logic                   awvalid;
  logic                   awready;

  // Write data channel signals
  logic [XDATAW-1:0] wdata;
  logic [XSTRBW-1:0] wstrb;
  logic              wvalid;
  logic              wready;

  // Write response channel signals
  t_xid                 bid;
  te_xresp              bresp;
  logic                 bvalid;
  logic                 bready;
  
  // Read address channel signals
  t_xid                   arid;
  t_xaddr                 araddr;
  ts_xprot                arprot;
  logic                   arvalid;
  logic                   arready;

  // Read data channel signals
  t_xid                 rid;
  logic    [XDATAW-1:0] rdata;
  te_xresp              rresp
  logic    [RUSERW-1:0] ruser;
  logic                 rvalid;
  logic                 rready;

  // Low-power signals
  logic csysreq;
  logic csysack;
  logic cactive;
  
  // lint_checking ONPNSG on
endinterface : itrx_amba4_axilite_if
// lint_checking EMPMOD on

`endif //  `ifndef ITRX_AMBA4_AXILITE_IF_SV
// lint_checking CDWARN on
