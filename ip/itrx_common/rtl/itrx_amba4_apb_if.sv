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
// Filename       : itrx_amba4_apb_if.sv
// Description    : Synthesizable AMBA4 APB Interface.
//
// ==========================================================================
//
//    $Rev:: 3948                      $: Revision of last commit
// $Author:: aducimo                   $: Author of last commit
//   $Date:: 2016-01-22 12:49:13 -0500#$: Date of last commit
// 
// ==========================================================================

// lint_checking CDWARN off
`ifndef ITRX_AMBA4_APB_IF_SV
// lint_checking USEMAC off
 `define ITRX_AMBA4_APB_IF_SV
// lint_checking USEMAC on

// lint_checking EMPMOD off
interface itrx_amba4_apb_if (input logic pclk, input logic preset_n);
  import itrx_amba4_apb_pkg::*;

  parameter  PDATAW = 32'd32;
  parameter  NS     = 32'd16;
  localparam PSTRBW = PDATAW/8;

  // lint_checking ONPNSG off
  logic                    [31:0] paddr;
  te_pwrite                       pwrite;
  logic              [PDATAW-1:0] pwdata;
  logic      [NS-1:0]             psel;
  logic                           penable;
  logic      [NS-1:0][PDATAW-1:0] prdata;
  logic      [NS-1:0]             pready;
  logic      [NS-1:0]             pslverr;
  logic              [PSTRBW-1:0] pstrb;
  ts_pprot                        pprot;
  // lint_checking ONPNSG on
  
  modport master (output paddr, pwrite, pwdata, psel, penable, pstrb, pprot,
                  input  preset_n, pclk, prdata);

  modport slave  (output prdata,
                  input  preset_n, pclk, paddr, pwrite, pwdata, psel, penable,
                         pstrb, pprot);

endinterface : itrx_amba4_apb_if
// lint_checking EMPMOD on

`endif //  `ifndef ITRX_AMBA4_APB_IF_SV
// lint_checking CDWARN on
