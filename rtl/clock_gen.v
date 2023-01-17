// Simple clock generator
module clock_gen (
  input   wire  sclk,
  input   wire  mclk_pause,
  output  wire  mclk
  );
  CKLNQD1BWP40 clk_gate ( .TE(~mclk_pause), .E(~mclk_pause), .CP(sclk), .Q(mclk));
endmodule
