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
// Filename       : itrx_amba4_apb_pkg.sv
// Description    : AMBA4 APB Package
//
// ==========================================================================
//
//    $Rev:: 3948                      $: Revision of last commit
// $Author:: aducimo                   $: Author of last commit
//   $Date:: 2016-01-22 12:49:13 -0500#$: Date of last commit
// 
// ==========================================================================

// lint_checking CDWARN off
`ifndef ITRX_AMBA4_APB_PKG_SV
// lint_checking USEMAC off
 `define ITRX_AMBA4_APB_PKG_SV
// lint_checking USEMAC on

package itrx_amba4_apb_pkg;
  // lint_checking UCCONN off
  //  Transfer Direction
  typedef enum logic {READ  = 1'b0,
                      WRITE = 1'b1
                      } te_pwrite;

  // Protection Type
  typedef enum logic {NORMAL    = 1'b0, PRIVILEGED  = 1'b1} te_pprot0;
  typedef enum logic {SECURE    = 1'b0, NONSECURE   = 1'b1} te_pprot1;
  typedef enum logic {DATA      = 1'b0, INSTR       = 1'b1} te_pprot2;

  typedef struct packed {te_pprot2 pprot2;
                         te_pprot1 pprot1;
                         te_pprot0 pprot0;
                         } ts_pprot;

  // lint_checking UCCONN on
endpackage : itrx_amba4_apb_pkg

`endif //  `ifndef ITRX_AMBA4_APB_PKG_SV
// lint_checking CDWARN on
