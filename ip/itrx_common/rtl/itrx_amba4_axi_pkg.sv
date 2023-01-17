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
// Filename       : itrx_amba4_axi_pkg.sv
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
`ifndef ITRX_AMBA4_AXI_PKG_SV
// lint_checking USEMAC off
 `define ITRX_AMBA4_AXI_PKG_SV
// lint_checking USEMAC on

package itrx_amba4_axi_pkg;
  // lint_checking UCCONN off

  // Address
  typedef logic [31:0] t_xaddr;
  
  // Address ID
  typedef logic [3:0] t_xid;

  // Burst Length
  typedef logic [7:0] te_xlen;

  // Transfer Size
  // lint_checking SYSVKW off
  typedef enum logic [2:0] {BYTE          = 3'b000, // 8-bits
                            HALFWORD      = 3'b001, // 16-bits
                            WORD          = 3'b010, // 32-bits
                            DBLWORD       = 3'b011, // 64-bits
                            QUADWORD      = 3'b100, // 128-bits
                            OCTOWORD      = 3'b101, // 256-bits
                            SIXTEENWORD   = 3'b110, // 512-bits
                            THIRTYTWOWORD = 3'b111  // 1024-bits
                            } te_xsize;
  // lint_checking SYSVKW on

  // Burst Type
  typedef enum logic [1:0] {FIXED = 2'b00,
                            INCR  = 2'b01,
                            WRAP  = 2'b10,
                            } te_xburst;

  // Cache Type
  // 01/15/2016 APD: o Cache type signaling cannot share the same enumerated
  //                   type because "The same memory type can have different
  //                   encodings on the read channel and write channel. This
  //                   provides backwards compatibility with AXI3 AxCACHE
  //                   definitions."
  //                 o ARCACHE and AWCACHE cannot have individual enumerated
  //                   types because "In AXI4 it is legal to use more than one
  //                   AxCACHE value for a particular memory type."
  //                 o So AxCACHE signaling will share the same non-enumerated
  //                   user-defined type
  typedef logic [3:0] t_xcache;
    
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
  typedef enum logic [1:0] {OKAY   = 2'b00, EXOKAY = 2'b01, 
                            SLVERR = 2'b10, DECERR = 2'b11
                            } te_xresp;
  
  // lint_checking UCCONN on
endpackage : itrx_amba4_axi_pkg

`endif //  `ifndef ITRX_AMBA4_AXI_PKG_SV
// lint_checking CDWARN on
