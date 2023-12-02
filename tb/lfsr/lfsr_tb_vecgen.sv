// Testbench to get vectors produced by LFSR PRBS generators
module lfsr_tb_vecgen;
  // TB clock setup
  reg clk;
  always #5 clk = ~clk;

  // LFSR PRBS generators for random data
  localparam [`WORD_SIZE-1:0] lfsr_init [`PROG_CNFG_RANGES_LOG2_N-1:0] = {
    48'b101110001000100011101000010011101110001011110100,
    48'b100101111001111011100010000110100111000011110001,
    48'b010100011000000110001001000111010011101011101011,
    48'b110101110001111100110100000111000100110010011101
  };
  wire [`WORD_SIZE-1:0] lfsr_data_bits [`PROG_CNFG_RANGES_LOG2_N-1:0];
  reg rst;
  generate
    genvar k;
    for (k = 0; k < `PROG_CNFG_RANGES_LOG2_N; k = k+1) begin : lfsr_gen
      lfsr_prbs_gen #(.LFSR_INIT(lfsr_init[k])) lfsr_prbs_gen (
        .clk(clk),
        .rst(rst),
        .enable(1),
        .data_out(lfsr_data_bits[k])
      );
    end
  endgenerate

  // Vector output files
  integer vecfile [3:0];

  initial begin
    // Set clock
    clk <= 1;
    rst <= 1;
    #10;
    rst <= 0;
    @(posedge clk);

    // Open vector output files
    for (int i = 0; i < 4; i = i+1) begin
      vecfile[i] = $fopen($sformatf("lfsr_tb_vecgen_%0d.txt", i), "w");
    end

    // Run test
    for (int i = 0; i < 65536; i = i+1) begin
      for (int j = 0; j < 48; j = j+1) begin
        $fwrite(vecfile[0], "%0d", {lfsr_data_bits[0][j]});
        $fwrite(vecfile[1], "%0d", {lfsr_data_bits[1][j], lfsr_data_bits[0][j]});
        $fwrite(vecfile[2], "%0d", {lfsr_data_bits[2][j], lfsr_data_bits[1][j], lfsr_data_bits[0][j]});
        $fwrite(vecfile[3], "%0d", {lfsr_data_bits[3][j], lfsr_data_bits[2][j], lfsr_data_bits[1][j], lfsr_data_bits[0][j]});
        for (int k = 0; k < 4; k = k+1) begin
          if (j != 47) $fwrite(vecfile[k], ",");
        end
      end
      for (int j = 0; j < 4; j = j+1) begin
        $fwrite(vecfile[j], "\n");
      end
      @(posedge clk);
    end
    for (int i = 0; i < 4; i = i+1) begin
      $fclose(vecfile[i]);
    end
    $finish;
  end
  
  // Simulator dependent system tasks that can be used to 
  // dump simulation waves.
  initial begin
    $dumpvars;
    $dumpfile("dump.vcd");
  end
endmodule