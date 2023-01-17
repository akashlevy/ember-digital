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
// Filename       : itrx_clog2.vh
// Description    : Define a Macro with argument "n". (limited to 2047 bit
//                  vectors)  "n" is the number of bits in a vector  Macro
//                  returns the number of bits needed to index the vector
//                  (when index is binary encoded) Ceiling log base 2
//                  function
// 
// ==========================================================================
//
//    $Rev:: 3676                      $: Revision of last commit
// $Author:: aducimo                   $: Author of last commit
//   $Date:: 2015-08-26 14:17:43 -0400#$: Date of last commit
// 
// ==========================================================================

// trap to not recompile module that performs a `define...
`ifndef ITRX_CLOG2_VH
//lint_checking USEMAC off
`define ITRX_CLOG2_VH
//lint_checking USEMAC on

`define ITRX_CLOG2(n) ((n) <=    1 ?  32'd0 : \
                  (n) <=    2 ?  32'd1 : \
                  (n) <=    4 ?  32'd2 : \
                  (n) <=    8 ?  32'd3 : \
                  (n) <=   16 ?  32'd4 : \
                  (n) <=   32 ?  32'd5 : \
                  (n) <=   64 ?  32'd6 : \
                  (n) <=  128 ?  32'd7 : \
                  (n) <=  256 ?  32'd8 : \
                  (n) <=  512 ?  32'd9 : \
                  (n) <= 1024 ?  32'd10 : 32'd11)
`endif
