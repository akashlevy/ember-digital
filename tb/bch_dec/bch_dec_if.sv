// The interface allows verification components to access DUT signals
// using a virtual interface handle
interface bch_dec_if (input bit clk);
  logic  [`ECC_WORD_SIZE-1:0]   read_bits               ;
  logic  [`ECC_RED_N_BITS-1:0]  read_ecc_bits           ;
  logic  [`ECC_WORD_SIZE-1:0]   write_bits              ;
  logic  [`ECC_RED_N_BITS-1:0]  write_ecc_bits          ;
  logic  [`ECC_WORD_SIZE-1:0]   ecc_msk_o               ; 
  logic                         ecc_err_det             ;
endinterface