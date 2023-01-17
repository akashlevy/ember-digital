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
// Filename       : itrx_ecc_72_64_correct.v
// Description    : ECC correction for (72,64) code for EDC (error detection
//                  and correction) SECDED (single error correction,
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
   Only syndrome values that point to valid message data bits will result in correction.
   Correction bits themselves are not corrected.
*/

module itrx_ecc_72_64_correct #(
  parameter HAM_V_HSIAO = 1'b0,      // Parameter sets Hamming (=1) vs. Hsiao (=0) code words
  parameter [31:0] DWID = 32'd64) (  // Data width; not to be changed.
   input       [DWID-1:0] d,         // Input data to be corrected for non-zero syndrome that points a data bit  
   input       [     7:0] s,         // Input syndrome points to data bit to be corrected in 72-bit code word
   output wire [DWID-1:0] dc);       // Ouput data corrected.

wire [DWID-1:0] e; // Bit mask of same width as data that flips the bit in error

generate // Map each of the 64 data bits to its associated single-bit error code value
if (HAM_V_HSIAO) begin
wire [ 7:0] p = {~s[7],s[6:0]}; // pointer to bit in error (overall code word parity is in error and points to a data bit)
assign e = {
 (p == 8'd71), (p == 8'd70), (p == 8'd69), (p == 8'd68),
 (p == 8'd67), (p == 8'd66), (p == 8'd65), (p == 8'd63),
 (p == 8'd62), (p == 8'd61), (p == 8'd60), (p == 8'd59),
 (p == 8'd58), (p == 8'd57), (p == 8'd56), (p == 8'd55),
 (p == 8'd54), (p == 8'd53), (p == 8'd52), (p == 8'd51),
 (p == 8'd50), (p == 8'd49), (p == 8'd48), (p == 8'd47),
 (p == 8'd46), (p == 8'd45), (p == 8'd44), (p == 8'd43),
 (p == 8'd42), (p == 8'd41), (p == 8'd40), (p == 8'd39),
 (p == 8'd38), (p == 8'd37), (p == 8'd36), (p == 8'd35),
 (p == 8'd34), (p == 8'd33), (p == 8'd31), (p == 8'd30),
 (p == 8'd29), (p == 8'd28), (p == 8'd27), (p == 8'd26),
 (p == 8'd25), (p == 8'd24), (p == 8'd23), (p == 8'd22),
 (p == 8'd21), (p == 8'd20), (p == 8'd19), (p == 8'd18),
 (p == 8'd17), (p == 8'd15), (p == 8'd14), (p == 8'd13),
 (p == 8'd12), (p == 8'd11), (p == 8'd10), (p == 8'd9),
 (p == 8'd7),  (p == 8'd6),  (p == 8'd5),  (p == 8'd3)};
end else
assign e = {
 (s == 8'd164), (s == 8'd196), (s == 8'd194), (s == 8'd162),
 (s == 8'd158), (s == 8'd193), (s == 8'd161), (s == 8'd145),
 (s == 8'd82),  (s == 8'd98),  (s == 8'd97),  (s == 8'd81),
 (s == 8'd79),  (s == 8'd224), (s == 8'd208), (s == 8'd200),
 (s == 8'd41),  (s == 8'd49),  (s == 8'd176), (s == 8'd168),
 (s == 8'd167), (s == 8'd112), (s == 8'd104), (s == 8'd100),
 (s == 8'd148), (s == 8'd152), (s == 8'd88),  (s == 8'd84),
 (s == 8'd211), (s == 8'd56),  (s == 8'd52),  (s == 8'd50),
 (s == 8'd74),  (s == 8'd76),  (s == 8'd44),  (s == 8'd42),
 (s == 8'd233), (s == 8'd28),  (s == 8'd26),  (s == 8'd25),
 (s == 8'd37),  (s == 8'd38),  (s == 8'd22),  (s == 8'd21),
 (s == 8'd244), (s == 8'd14),  (s == 8'd13),  (s == 8'd140),
 (s == 8'd146), (s == 8'd19),  (s == 8'd11),  (s == 8'd138),
 (s == 8'd122), (s == 8'd7),   (s == 8'd134), (s == 8'd70),
 (s == 8'd73),  (s == 8'd137), (s == 8'd133), (s == 8'd69),
 (s == 8'd61),  (s == 8'd131), (s == 8'd67),  (s == 8'd35)};
endgenerate

assign dc = d ^ e; // flip errored bit (correct)

endmodule
