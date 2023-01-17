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
// Filename       : itrx_amba2_ahb_pkg.sv
// Description    : AMBA2 AHB Package
//
// ==========================================================================
//
//    $Rev:: 3948                      $: Revision of last commit
// $Author:: aducimo                   $: Author of last commit
//   $Date:: 2016-01-22 12:49:13 -0500#$: Date of last commit
// 
// ==========================================================================

// lint_checking CDWARN off
`ifndef ITRX_AMBA2_AHB_PKG_SV
// lint_checking USEMAC off
 `define ITRX_AMBA2_AHB_PKG_SV
// lint_checking USEMAC on

package itrx_amba2_ahb_pkg;
  // lint_checking UCCONN off
  // Transfer Type
  typedef enum logic [1:0] {IDLE   = 2'b00,
                            BUSY   = 2'b01,
                            NONSEQ = 2'b10,
                            SEQ    = 2'b11
                            } te_htrans;

  //  Transfer Direction
  typedef enum logic {READ  = 1'b0,
                      WRITE = 1'b1
                      } te_hwrite;

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
                            } te_hsize;
  // lint_checking SYSVKW on

  // Burst Type
  typedef enum logic [2:0] {SINGLE = 3'b000,
                            INCR   = 3'b001,
                            WRAP4  = 3'b010,
                            INCR4  = 3'b011,
                            WRAP8  = 3'b100,
                            INCR8  = 3'b101,
                            WRAP16 = 3'b110,
                            INCR16 = 3'b111
                            } te_hburst;

  // Transfer Response
  typedef enum logic [1:0] {OKAY  = 2'b00,
                            ERROR = 2'b01,
                            RETRY = 2'b10,
                            SPLIT = 2'b11
                            } te_hresp;

  // Master ID
  typedef enum logic [3:0] {M0 = 4'h0, M1 = 4'h1, M2 = 4'h2, M3 = 4'h3,
                            M4 = 4'h4, M5 = 4'h5, M6 = 4'h6, M7 = 4'h7,
                            M8 = 4'h8, M9 = 4'h9, MA = 4'hA, MB = 4'hB,
                            MC = 4'hC, MD = 4'hD, ME = 4'hE, MF = 4'hF
                            } te_hmaster;

  // Split Completion Request
  typedef enum logic [15:0] {SPLIT_M0 = 16'h0001, SPLIT_M1 = 16'h0002,
                             SPLIT_M2 = 16'h0004, SPLIT_M3 = 16'h0008,
                             SPLIT_M4 = 16'h0010, SPLIT_M5 = 16'h0020,
                             SPLIT_M6 = 16'h0040, SPLIT_M7 = 16'h0080,
                             SPLIT_M8 = 16'h0100, SPLIT_M9 = 16'h0200,
                             SPLIT_MA = 16'h0400, SPLIT_MB = 16'h0800,
                             SPLIT_MC = 16'h1000, SPLIT_MD = 16'h2000,
                             SPLIT_ME = 16'h4000, SPLIT_MF = 16'h8000
                             } te_hsplit;

  // Protection Control
  typedef enum logic {OPCODE   = 1'b0, DATA        = 1'b1} te_hprot0;
  typedef enum logic {USER     = 1'b0, PRIVILEGED  = 1'b1} te_hprot1;
  typedef enum logic {NONBUFF  = 1'b0, BUFF        = 1'b1} te_hprot2;
  typedef enum logic {NONCACHE = 1'b0, CACHE       = 1'b1} te_hprot3;

  typedef struct packed {te_hprot3 hprot3;
                         te_hprot2 hprot2;
                         te_hprot1 hprot1;
                         te_hprot0 hprot0;
                         } ts_hprot;
  // lint_checking UCCONN on  
endpackage : itrx_amba2_ahb_pkg

`endif //  `ifndef ITRX_AMBA2_AHB_PKG_SV
// lint_checking CDWARN on
