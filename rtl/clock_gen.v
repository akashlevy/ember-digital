// Simple clock generator
module clock_gen (
  input   wire  sclk,
  input   wire  mclk_pause,
  output  wire  mclk
  );
  // BUFGCE: Global Clock Buffer with Clock Enable
  //         7 Series
  // Xilinx HDL Language Template, version 2021.2
  
  BUFGCE BUFGCE_inst (
     .O(mclk),   // 1-bit output: Clock output
     .CE(~mclk_pause), // 1-bit input: Clock enable input for I0
     .I(sclk)    // 1-bit input: Primary clock
  );

  // End of BUFGCE_inst instantiation

  // // Standard cell clock gate
  // CKLNQD1BWP40 clk_gate ( .TE(~mclk_pause), .E(~mclk_pause), .CP(sclk), .Q(mclk));
endmodule
