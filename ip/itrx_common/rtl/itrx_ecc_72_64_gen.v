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
// Filename       : itrx_ecc_72_64_gen.v
// Description    : ECC generator for (72,64) code for EDC (error detection
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

module itrx_ecc_72_64_gen #(
  parameter        HAM_V_HSIAO = 1'b0, // Parameter sets Hamming (=1) vs. Hsiao (=0) code words
  parameter [31:0] DWID = 32'd64) (    // Data width; not to be changed. 
   input [DWID-1:0] d,                 // Input data "messagae"
   output     [7:0] c);                // Generated check/parity bits for input data "message"

genvar j;
generate
if (HAM_V_HSIAO) begin : ham_gc // Hamming code implementation w overall parity bit.
// # of XOR terms in each parity bit: 35,35,35, 31,31,31, 7, 35
 assign c[0] = ^{d[ 0],d[ 1],d[ 3],d[ 4],d[ 6],d[ 8],d[10],d[11],d[13],d[15],d[17],d[19],d[21],d[23],d[25],d[26],
                 d[28],d[30],d[32],d[34],d[36],d[38],d[40],d[42],d[44],d[46],d[48],d[50],d[52],d[54],d[56],d[57],d[59],d[61],d[63]}; // 35 terms

 assign c[1] = ^{d[ 0],d[ 2],d[ 3],d[ 5],d[ 6],d[ 9],d[10],d[12],d[13],d[16],d[17],d[20],d[21],d[24],d[25],d[27],
                 d[28],d[31],d[32],d[35],d[36],d[39],d[40],d[43],d[44],d[47],d[48],d[51],d[52],d[55],d[56],d[58],d[59],d[62],d[63]}; // 35 terms

 assign c[2] = ^{d[ 1],d[ 2],d[ 3],d[ 7],d[ 8],d[ 9],d[10],d[14],d[15],d[16],d[17],d[22],d[23],d[24],d[25],d[29],
                 d[30],d[31],d[32],d[37],d[38],d[39],d[40],d[45],d[46],d[47],d[48],d[53],d[54],d[55],d[56],d[60],d[61],d[62],d[63]}; // 35 terms

 assign c[3] = ^{d[ 4],d[ 5],d[ 6],d[ 7],d[ 8],d[ 9],d[10],d[18],d[19],d[20],d[21],d[22],d[23],d[24],d[25],d[33],
                 d[34],d[35],d[36],d[37],d[38],d[39],d[40],d[49],d[50],d[51],d[52],d[53],d[54],d[55],d[56]};                         // 31 terms

 assign c[4] = ^{d[11],d[12],d[13],d[14],d[15],d[16],d[17],d[18],d[19],d[20],d[21],d[22],d[23],d[24],d[25],d[41],
                 d[42],d[43],d[44],d[45],d[46],d[47],d[48],d[49],d[50],d[51],d[52],d[53],d[54],d[55],d[56]};                         // 31 terms

 assign c[5] = ^{d[26],d[27],d[28],d[29],d[30],d[31],d[32],d[33],d[34],d[35],d[36],d[37],d[38],d[39],d[40],d[41],
                 d[42],d[43],d[44],d[45],d[46],d[47],d[48],d[49],d[50],d[51],d[52],d[53],d[54],d[55],d[56]};                         // 31 terms

 assign c[6] = ^{d[57],d[58],d[59],d[60],d[61],d[62],d[63]};                                                                         //  7 terms

// This is the overall parity for the entire code word (all bits). 
// Note that the data bits that occur an odd # of times above in c[6:0] are excluded from c[7]
 assign c[7] = ^{d[ 0],d[ 1],d[ 2],d[ 4],d[ 5],d[ 7],d[10],d[11],d[12],d[14],d[17],d[18],d[21],d[23],d[24],d[26],
                 d[27],d[29],d[32],d[33],d[36],d[38],d[39],d[41],d[44],d[46],d[47],d[50],d[51],d[53],d[56],d[57],d[58],d[60],d[63]}; // 35 terms

// Hsiao symmetric check/parity bits (26 XOR terms each)
//
end else begin : hsaio_gc
     // See "version 1" matrix from Hsiao "A Class of Optimal Minimum Odd-weight-column SEC-DEC Codes" [1970].
for (j=0; j<DWID; j=j+8) begin : j_gl // generate-loop index j
  assign c[j/8] = ^{d[(0+j)%DWID+:8],d[(51+j)%DWID+:3],d[(56+j)%DWID+:3],
                    d[(10+j)%DWID],d[(13+j)%DWID],d[(14+j)%DWID],d[(17+j)%DWID],d[(20+j)%DWID],d[(23+j)%DWID],
                    d[(24+j)%DWID],d[(27+j)%DWID],d[(35+j)%DWID],d[(43+j)%DWID],d[(46+j)%DWID],d[(47+j)%DWID]}; // 26 terms for EVERY check bit
 end
end
endgenerate

endmodule
