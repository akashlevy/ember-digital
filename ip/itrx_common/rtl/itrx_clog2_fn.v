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
// Filename       : itrx_clog2_fn.v
// Description    : Ceiling log base2 function to determine the # of bit
//                  used to index an object of width (value).  Intended to
//                  be used as a constant function that operates on
//                  parameter/constant input args. Equivalent to
//                  $clog2(value)
// 
// ==========================================================================
//
//    $Rev:: 3676                      $: Revision of last commit
// $Author:: aducimo                   $: Author of last commit
//   $Date:: 2015-08-26 14:17:43 -0400#$: Date of last commit
// 
// ==========================================================================
// 

// *NOTE: no `ifndef trap for this code - it is a function call, local in scope to the calling module...
function [31:0] itrx_clog2_fn;
 input [31:0] value;
 reg   [31:0] vr;

 begin
  vr = value > 32'd0 ? value - 32'd1 : value;
  for (itrx_clog2_fn = 0; vr > 0; itrx_clog2_fn = itrx_clog2_fn + 1)
   vr = vr >> 1;
 end
endfunction
