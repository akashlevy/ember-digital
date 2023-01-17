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
// Filename       : itrx_amba3_ahblite_if.sv
// Description    : Synthesizable AMBA3 AHB-Lite Interface.
//
// ==========================================================================
//
//    $Rev:: 3948                      $: Revision of last commit
// $Author:: aducimo                   $: Author of last commit
//   $Date:: 2016-01-22 12:49:13 -0500#$: Date of last commit
// 
// ==========================================================================

// lint_checking CDWARN off
`ifndef ITRX_AMBA3_AHBLITE_IF_SV
// lint_checking USEMAC off
 `define ITRX_AMBA3_AHBLITE_IF_SV
// lint_checking USEMAC on

// lint_checking EMPMOD off
interface itrx_amba3_ahblite_if (input logic hclk, input logic hreset_n);
  import itrx_amba3_ahblite_pkg::*;

  parameter HDATAW = 32'd64;
  parameter NS     = 32'd16;

  // lint_checking ONPNSG off
  logic                    [31:0] haddr;
  te_htrans                       htrans;
  te_hwrite                       hwrite;
  te_hsize                        hsize;
  te_hburst                       hburst;
  ts_hprot                        hprot;
  logic              [HDATAW-1:0] hwdata;
  logic                           hmastlock;
  logic      [NS-1:0]             hsel;
  logic      [NS-1:0][HDATAW-1:0] hrdata;
  logic                           hready;
  logic      [NS-1:0]             hreadyout;
  te_hresp   [NS-1:0]             hresp;
  // lint_checking ONPNSG on

  modport master (output haddr, htrans, hwrite, hsize, hburst, hprot, hwdata,
                         hmastlock,
                  input  hreset_n, hclk, hrdata, hready, hresp);
  
  modport slave (output hreadyout, hresp, hrdata,
                 input  hreset_n, hclk, hsel, haddr, hwrite, htrans, hsize,
                        hburst, hprot, hwdata, hready, hmastlock);

  modport decoder (output hsel,
                   input  haddr);

  modport piped_deoder (output hsel,
                        input  hreset_n, hclk, haddr);

endinterface : itrx_amba3_ahblite_if
// lint_checking EMPMOD on

`endif //  `ifndef ITRX_AMBA3_AHBLITE_IF_SV
// lint_checking CDWARN on
