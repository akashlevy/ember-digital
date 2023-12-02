// The interface allows verification components to access DUT signals
// using a virtual interface handle
interface cb_if (input bit clk);
  logic rst;
  logic enable;
  logic [`PROG_CNFG_RANGES_LOG2_N-1:0] num_levels;
  logic [`WORD_SIZE-1:0] data_out [`PROG_CNFG_RANGES_LOG2_N-1:0];
endinterface
