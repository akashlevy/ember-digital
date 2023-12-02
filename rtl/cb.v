module cb (
  input clk,
  input rst,
  input enable,
  input [`PROG_CNFG_RANGES_LOG2_N-1:0] num_levels,
  output [`WORD_SIZE-1:0] data_out [`PROG_CNFG_RANGES_LOG2_N-1:0]
);
  reg [63:0] counter;
  reg [`PROG_CNFG_RANGES_LOG2_N-1:0] data_out_raw [`WORD_SIZE-1:0];

  generate
    genvar i, j;
    for (i = 0; i < `WORD_SIZE; i=i+1) begin
      assign data_out_raw[i] = ((counter + i) % ((num_levels == 0) ? 16 : (num_levels == 8) ? 8 : (num_levels == 4) ? 4 : (num_levels == 2) ? 2 : 1));
      for (j = 0; j < `PROG_CNFG_RANGES_LOG2_N; j=j+1) begin
        assign data_out[j][i] = data_out_raw[i][j];
      end
    end
  endgenerate

  always @(posedge clk) begin
    if (rst) begin
      counter <= 0;
    end else begin
      if (enable) begin
        counter <= counter + 1;
      end
    end
  end
endmodule