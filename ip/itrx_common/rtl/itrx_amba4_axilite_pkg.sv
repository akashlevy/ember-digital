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
// Filename       : itrx_amba4_axilite_pkg.sv
// Description    : AMBA4 AXI Package
//
// ==========================================================================
//
//    $Rev:: 3948                      $: Revision of last commit
// $Author:: aducimo                   $: Author of last commit
//   $Date:: 2016-01-22 12:49:13 -0500#$: Date of last commit
// 
// ==========================================================================

// lint_checking CDWARN off
`ifndef ITRX_AMBA4_AXILITE_PKG_SV
// lint_checking USEMAC off
 `define ITRX_AMBA4_AXILITE_PKG_SV
// lint_checking USEMAC on

package itrx_amba4_axilitelite_pkg;
  // lint_checking UCCONN off

  // Address
  typedef logic [31:0] t_xaddr;
  
  // Address ID
  typedef logic [3:0] t_xid;
    
  // Protection Type
  typedef enum logic {UNPRIV = 1'b0, PRIV   = 1'b1} te_xprot0;
  typedef enum logic {SECURE = 1'b0, NONSEC = 1'b1} te_xprot1;
  typedef enum logic {DATA   = 1'b0, INSTR  = 1'b1} te_xprot2;

  typedef struct packed {te_xprot2 xprot2;
                         te_xprot1 xprot1;
                         te_xprot0 xprot0;
                         } ts_xprot;

  // QoS Signaling
  typedef logic [3:0] t_xqos;

  // Multiple Region Signaling
  typedef logic [3:0] t_xregion;

  // Response
  typedef enum logic [1:0] {OKAY   = 2'b00, 
                            SLVERR = 2'b10, DECERR = 2'b11
                            } te_xresp;
  
  // lint_checking UCCONN on
endpackage : itrx_amba4_axilite_pkg

`endif //  `ifndef ITRX_AMBA4_AXILITE_PKG_SV
// lint_checking CDWARN on
