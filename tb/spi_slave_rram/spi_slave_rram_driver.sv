// The driver is responsible for driving transactions to the DUT 
// All it does is to get a transaction from the mailbox if it is 
// available and drive it out into the DUT interface.
typedef class spi_slave_rram_tb_pkt;
class spi_slave_rram_driver;
  // Full and half clock time
  localparam CLK = 10;
  localparam HALFCLK = 5;

  // Driver components
  virtual spi_slave_rram_if vif;
  event drv_done;
  mailbox drv_mbx;
  mailbox scb_mbx;
  
  task run();
    // Log driver startup
    $display("T=%0t [SPI Driver] starting...", $time);

    // Hard reset
    vif.sc = 0; vif.mosi = 0;
    vif.rst_n = 1; #CLK;
    vif.rst_n = 0; #CLK #CLK #CLK;
    vif.rst_n = 1; #CLK #CLK #CLK;
    
    // Try to get a new transaction every time and then assign 
    // packet contents to the interface. But do this only if the 
    // design is ready to accept new transactions
    forever begin
      // Get transaction item
      spi_slave_rram_tb_pkt item;
      $display("T=%0t [SPI Driver] waiting for item...", $time);
      while (!drv_mbx.try_get(item)) begin
        $display("T=%0t [SPI Driver] finished!", $time);
        -> drv_done; #CLK; break;
      end
      item.print("SPI Driver");

      // Apply FSM signals
      vif.fsm_bits = item.fsmdata;
      vif.diag_bits = item.diagdata;
      vif.diag2_bits = item.diag2data;
      vif.readdata = item.readdata;

      // Reset
      vif.sc = 0; vif.mosi = 0; #CLK;                    // Reset
      vif.rst_n = 1; vif.sc = 1; vif.mosi = 0; #CLK;     // Reset finished

      // Read/write
      vif.mosi = item.wr; #CLK;                          // Read/write command (mosi = 0 or 1)

      // Address
      for (int i = 0; i < `CNFG_REG_ADDR_BITS_N; i++) begin
        vif.mosi = (item.addr >> (`CNFG_REG_ADDR_BITS_N-i-1)) & 1; #CLK;
      end

      // Either read or write data
      if (item.wr) begin
        // Write data
        for (int i = 0; i < `PROG_CNFG_BITS_N; i++) begin
          vif.mosi = (item.wdata >> (`PROG_CNFG_BITS_N-i-1)) & 1; #CLK;
        end

        // Wait three cycles
        for (int i = 0; i < 3; i++) begin
          assert(vif.miso_oe_n) #0; else $error("miso_oe_n should not be active (active low)"); #CLK;
        end
      end
      else begin
        // Wait two cycles
        for (int i = 0; i < 2; i++) begin
          assert(vif.miso_oe_n) #0; else $error("miso_oe_n should not be active (active low)"); #CLK;
        end

        // Read data
        for (int i = 0; i < `PROG_CNFG_BITS_N; i++) begin
          #HALFCLK;
          assert(~vif.miso_oe_n) #0; else $display("Time %0t: vif.miso_oen_n = %0d", $time, vif.miso_oe_n);
          item.rdata[`PROG_CNFG_BITS_N-i-1] = vif.miso; #HALFCLK;
        end

        // One "pad" cycle to complete transaction
        #CLK;
      end

      // FSM trigger
      item.fsm_go = vif.fsm_go;

      // Forward message to scoreboard
      scb_mbx.put(item);

      // Wait for negative edge of rram_busy if FSM triggered
      if (item.addr == `PROG_CNFG_RANGES_LOG2_N + `PROG_CNFG_RANGES_N + 2) begin
        @(negedge vif.rram_busy) $display("T=%0t [SPI Driver] FSM went from busy to idle...", $time);
      end

      // Wait one clock cycle to allow new packets to arrive
      #CLK;
    end
  endtask
endclass
