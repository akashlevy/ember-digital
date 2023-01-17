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
// Original Author: Ron Baracka
// Filename       : itrx_ecc_72_64_check.v
// Description    : ECC checker for (72,64) code for EDC (error detection
//                  and correction) for SECDED (single error correction,
//                  double error detect)
// 
// ==========================================================================
//
//    $Rev:: 3676                      $: Revision of last commit
// $Author:: aducimo                   $: Author of last commit
//   $Date:: 2015-08-26 14:17:43 -0400#$: Date of last commit
// 
// ==========================================================================

/*
   For reference see: "A Class of Optimal Minimum Odd-weight-column SEC-DEC Codes" by M.Y.Hsiao

   Triple bit errors are NOT always detectable, and in fact may lead to miscorrection due to the
   fact that they can mimic single bit errors.
   

   Taxonomy of SECDEC results:

    any_err => generated syndrome is non-zero
      1) one_bit_err => single bit error (or misidentifed/miscorrected triple+ bit error)
         a)  chk_bit_err => single bit error in a check bit (optionally correctable)
         b) !chk_bit_err => single bit error not in a check bit
             x) !inv_bit_err => single bit error in data (correctable)
             y)  inv_bit_err => invalid syndrome (SOME triple+ bit errors)
                  For example, since the (72,64) codes "are shortened codes and are
                  used for single-error correction and double-error detection, there
                  are cases in which triple errors provide syndrome patterns outside
                  the columns of the code's parity check matrix".             

       2) two_bit_err => double bit error detected

    !any_err => NO single bit or double bit error (or triple+ bit error not detected)
*/
module itrx_ecc_72_64_check #(
  parameter HAM_V_HSIAO = 1'b0,     // Parameter sets Hamming (=1) vs. Hsiao (=0) code words
  parameter [31:0] DWID = 32'd64) ( // Data width; not to be changed.
   input [DWID-1:0] d,       // 64-bit data input
   input [     7:0] c,       // Check/parity bits asssociated with 64-bit data input
  
   output       any_err,     // Any error detected
   output       two_bit_err, // double bit error detected
   output       one_bit_err, // single bit error detected
   output       chk_bit_err, // single bit error detected in parity bits (no correction required)
   output       inv_bit_err, // invalid syndome generated
   output [7:0] s);          // syndrome pointer used to correct a data bit

assign any_err = |s; // Non-zero syndrome is an error

genvar j;
generate 

if (HAM_V_HSIAO) begin
 wire [6:0] sptr = s[6:0];  // bit pointer portion of the syndrome (excludes MSB parity bit)
// Syndrome parity checkers:  XOR terms 36,36,36, 32,32,32, 8, 72

 assign s[0] = ^{c[ 0],d[ 0],d[ 1],d[ 3],d[ 4],d[ 6],d[ 8],d[10],d[11],d[13],d[15],d[17],d[19],d[21],d[23],d[25],
                 d[26],d[28],d[30],d[32],d[34],d[36],d[38],d[40],d[42],d[44],d[46],d[48],d[50],d[52],d[54],d[56],d[57],d[59],d[61],d[63]};

 assign s[1] = ^{c[ 1],d[ 0],d[ 2],d[ 3],d[ 5],d[ 6],d[ 9],d[10],d[12],d[13],d[16],d[17],d[20],d[21],d[24],d[25],
                 d[27],d[28],d[31],d[32],d[35],d[36],d[39],d[40],d[43],d[44],d[47],d[48],d[51],d[52],d[55],d[56],d[58],d[59],d[62],d[63]};

 assign s[2] = ^{c[ 2],d[ 1],d[ 2],d[ 3],d[ 7],d[ 8],d[ 9],d[10],d[14],d[15],d[16],d[17],d[22],d[23],d[24],d[25],
                 d[29],d[30],d[31],d[32],d[37],d[38],d[39],d[40],d[45],d[46],d[47],d[48],d[53],d[54],d[55],d[56],d[60],d[61],d[62],d[63]};

 assign s[3] = ^{c[ 3],d[ 4],d[ 5],d[ 6],d[ 7],d[ 8],d[ 9],d[10],d[18],d[19],d[20],d[21],d[22],d[23],d[24],d[25],
                 d[33],d[34],d[35],d[36],d[37],d[38],d[39],d[40],d[49],d[50],d[51],d[52],d[53],d[54],d[55],d[56]};

 assign s[4] = ^{c[ 4],d[11],d[12],d[13],d[14],d[15],d[16],d[17],d[18],d[19],d[20],d[21],d[22],d[23],d[24],d[25],
                 d[41],d[42],d[43],d[44],d[45],d[46],d[47],d[48],d[49],d[50],d[51],d[52],d[53],d[54],d[55],d[56]};

 assign s[5] = ^{c[ 5],d[26],d[27],d[28],d[29],d[30],d[31],d[32],d[33],d[34],d[35],d[36],d[37],d[38],d[39],d[40],
                 d[41],d[42],d[43],d[44],d[45],d[46],d[47],d[48],d[49],d[50],d[51],d[52],d[53],d[54],d[55],d[56]};

 assign s[6] = ^{c[ 6],d[57],d[58],d[59],d[60],d[61],d[62],d[63]};

 assign s[7] = ^{c,d}; // 72 terms!* -- overall parity

 assign one_bit_err = s[7]; 
 assign two_bit_err = |sptr & ~s[7];

 assign inv_bit_err = s[7] & (sptr >= 7'd72); // Invalid syndrome generated

// Error in check bits if non-zero syndrome matches a check bit pointer.
 assign chk_bit_err = ((sptr == 7'd0)  |
                       (sptr == 7'd1)  |
                       (sptr == 7'd2)  |
                       (sptr == 7'd4)  |
                       (sptr == 7'd8)  |
                       (sptr == 7'd16) |
                       (sptr == 7'd32) |
                       (sptr == 7'd64)  ) & s[7];

end else begin // Hsiao code parity check matrix (PCM), version 2

 for (j=0; j<DWID; j=j+8) begin : jl
   assign s[j/8] = ^{c[j/8],
                     d[(0+j)%DWID+:8],d[(51+j)%DWID+:3],d[(56+j)%DWID+:3],
                     d[(10+j)%DWID],d[(13+j)%DWID],d[(14+j)%DWID],d[(17+j)%DWID],d[(20+j)%DWID],d[(23+j)%DWID],
                     d[(24+j)%DWID],d[(27+j)%DWID],d[(35+j)%DWID],d[(43+j)%DWID],d[(46+j)%DWID],d[(47+j)%DWID]};
  end

 assign one_bit_err =  ^s & any_err;
 assign two_bit_err = ~^s & any_err;

// Error in check bits if non-zero syndrome matches a check bit pointer.
 assign chk_bit_err = ((s == 8'd1)  |
                       (s == 8'd2)  |
                       (s == 8'd4)  |
                       (s == 8'd8)  |
                       (s == 8'd16) |
                       (s == 8'd32) |
                       (s == 8'd64) |
                       (s == 8'd128) );

 assign inv_bit_err =  // codes that indicate one_bit_err, yet are otherwise invalid (unused)
  (s == 8'd31)  | (s == 8'd47)  | (s == 8'd55)  | (s == 8'd59)  |
  (s == 8'd62)  | (s == 8'd87)  | (s == 8'd91)  | (s == 8'd93)  |
  (s == 8'd94)  | (s == 8'd103) | (s == 8'd107) | (s == 8'd109) |
  (s == 8'd110) | (s == 8'd115) | (s == 8'd117) | (s == 8'd118) |
  (s == 8'd121) | (s == 8'd124) | (s == 8'd127) | (s == 8'd143) |
  (s == 8'd151) | (s == 8'd155) | (s == 8'd157) | (s == 8'd171) |
  (s == 8'd173) | (s == 8'd174) | (s == 8'd179) | (s == 8'd181) |
  (s == 8'd182) | (s == 8'd185) | (s == 8'd186) | (s == 8'd188) |
  (s == 8'd191) | (s == 8'd199) | (s == 8'd203) | (s == 8'd205) |
  (s == 8'd206) | (s == 8'd213) | (s == 8'd214) | (s == 8'd217) |
  (s == 8'd218) | (s == 8'd220) | (s == 8'd223) | (s == 8'd227) |
  (s == 8'd229) | (s == 8'd230) | (s == 8'd234) | (s == 8'd236) |
  (s == 8'd239) | (s == 8'd241) | (s == 8'd242) | (s == 8'd247) |
  (s == 8'd248) | (s == 8'd251) | (s == 8'd253) | (s == 8'd254);

end
endgenerate

endmodule
