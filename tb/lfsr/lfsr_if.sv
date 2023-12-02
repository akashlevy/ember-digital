// The interface allows verification components to access DUT signals
// using a virtual interface handle
interface lfsr_if (input bit clk);
  logic                         rst     ;
  logic                         enable  ;
  logic  [`WORD_SIZE-1:0]       data_out;
endinterface
