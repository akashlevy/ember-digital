// --------------------------------------------------------------------------
// ======================= COPYRIGHT NOTICE =================================
// --------------------------------------------------------------------------
//                Copyright 2019 © Intrinsix Corp. - All Rights Reserved
//                  Intrinsix Corp. Proprietary and Confidential 
//
// Intrinsix Corp. owns the sole copyright to this software. Under
// international copyright laws you (1) may not make a copy of this software
// except for the purposes of maintaining a single archive copy, (2) may not
// derive works herefrom, (3) may not distribute this work to others. These
// rights are provided forinformation clarification, other restrictions of
// rights may apply as well.
//
// This is an unpublished work.
//
// =========================== Warrantee ====================================
// --------------------------------------------------------------------------
// Intrinsix Corp. MAKES NO WARRANTY OF ANY KIND WITH REGARD TO THE USE OF
// THIS SOFTWARE, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO,
// THE IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR
// PURPOSE.
//
// Description: Placeholder for clock tree root node.
// Author:      Dave Charneski
// Filename:    $Id$
// Date:        $Date$
// Revisions:   $Log$

module dummy_clk_buf (
  // Inputs
  clk_in,
  // Outputs
  clk_out
);

  //-----------------------------------------------------------------------------
  //-- Declare I/O
  //-----------------------------------------------------------------------------
  input  clk_in;
  output clk_out;

  //-----------------------------------------------------------------------------
  //-- Assign output.
  //-----------------------------------------------------------------------------
  assign clk_out = clk_in;
endmodule
