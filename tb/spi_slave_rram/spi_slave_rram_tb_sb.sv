// The scoreboard is responsible to check data integrity. Since the design
// stores data it receives for each address, scoreboard helps to check if the
// same data is received when the same address is read at any later point
// in time. So the scoreboard has a "memory" element which updates it
// internally for every write operation.
typedef class spi_slave_rram_tb_pkt;
class spi_slave_rram_tb_sb;
  // Scoreboard mailbox
  mailbox scb_mbx;
  
  // Memory of requests
  spi_slave_rram_tb_pkt refq [];
  
  task run();
    // Initial allocation of refq
    refq = new [`PROG_CNFG_RANGES_LOG2_N + `PROG_CNFG_RANGES_N + 3];

    forever begin
      // Get item from mailbox
      spi_slave_rram_tb_pkt item;
      scb_mbx.get(item);
      item.print("SPI Scoreboard");

      // Reset memory if write to address 31
      if (item.addr == 2**`CNFG_REG_ADDR_BITS_N-1) begin
        if (item.wr) begin
          $display("T=%0t [SPI Scoreboard] Write to reset address addr=0x%0h wr=0x%0h data=0x%0h", $time, item.addr, item.wr, item.wdata);
          refq = new [`PROG_CNFG_RANGES_LOG2_N + `PROG_CNFG_RANGES_N + 3];
        end
        else begin
          assert(item.rdata == 'h52414D) else $error("T=%0t [SPI Scoreboard] ERROR! Reset register read, addr=0x%0h exp=0x%0h act=0x%0h", $time, item.addr, 'h52414D, item.rdata);
        end
      end
      // FSM state bits readout
      else if ((item.addr == `PROG_CNFG_RANGES_LOG2_N + `PROG_CNFG_RANGES_N + 3) && !item.wr) begin
        assert(item.rdata == item.fsmdata) else $error("T=%0t [SPI Scoreboard] ERROR! FSM state read, addr=0x%0h exp=0x%0h act=0x%0h", $time, item.addr, item.fsmdata, item.rdata);
      end
      // FSM diagnostic bits readout
      else if ((item.addr == `PROG_CNFG_RANGES_LOG2_N + `PROG_CNFG_RANGES_N + 4) && !item.wr) begin
        assert(item.rdata == item.diagdata) else $error("T=%0t [SPI Scoreboard] ERROR! FSM diagnostic bits read, addr=0x%0h exp=0x%0h act=0x%0h", $time, item.addr, item.diagdata, item.rdata);
      end
      // Readout bits readout
      else if ((item.addr >= `PROG_CNFG_RANGES_N+5+`PROG_CNFG_RANGES_LOG2_N) && (item.addr < `PROG_CNFG_RANGES_N+5+2*`PROG_CNFG_RANGES_LOG2_N) && !item.wr) begin
        bit [`CNFG_REG_ADDR_BITS_N-1:0] rd = item.addr - (`PROG_CNFG_RANGES_N+5+`PROG_CNFG_RANGES_LOG2_N);
        assert(item.rdata == item.readdata[rd]) else $error("T=%0t [SPI Scoreboard] ERROR! Readout data read, addr=0x%0h exp=0x%0h act=0x%0h", $time, item.addr, item.readdata[rd], item.rdata);
      end
      // Invalid address to write to
      else if (item.addr >= (`PROG_CNFG_RANGES_LOG2_N + `PROG_CNFG_RANGES_N + 4) && item.wr) begin
        assert(0) else $error("T=%0t [SPI Scoreboard] ERROR! Invalid store address addr=0x%0h wr=0x%0h data=0x%0h", $time, item.addr, item.wr, item.wdata);
      end
      // Valid address
      else begin
        // If write, store value in replica memory
        if (item.wr) begin
          if (refq[item.addr] == null)
            refq[item.addr] = new;
          refq[item.addr] = item;
          $display("T=%0t [SPI Scoreboard] Store addr=0x%0h wr=0x%0h data=0x%0h", $time, item.addr, item.wr, item.wdata);
        end
        // If read, check if actual value matches expected value
        else begin
          if (refq[item.addr] == null) begin
            // Use correct reset value
            bit [`PROG_CNFG_BITS_N-1:0] rstval;
            if (item.addr < `PROG_CNFG_RANGES_N)
              rstval = `CNFG_BITS_PROG_RSTVAL;
            else if (item.addr == `PROG_CNFG_RANGES_N)
              rstval = `CNFG_BITS_MISC_RSTVAL;
            else
              rstval = 0;
            // Compare vs. reset value
            assert(item.rdata == rstval) else $error("T=%0t [SPI Scoreboard] ERROR! First time read, addr=0x%0h exp=0x%0h act=0x%0h", $time, item.addr, rstval[item.addr], item.rdata);
          end
          else begin
            // Use correct mask value
            bit [`PROG_CNFG_BITS_N-1:0] mask;
            if (item.addr < `PROG_CNFG_RANGES_N)
              mask = {`PROG_CNFG_BITS_N{1'b1}};
            else if (item.addr == `PROG_CNFG_RANGES_N)
              mask = {`MISC_CNFG_BITS_N{1'b1}};
            else if (item.addr == `PROG_CNFG_RANGES_N + 1)
              mask = {(3*`ADDR_BITS_N){1'b1}};
            else if (item.addr <= `PROG_CNFG_RANGES_N + 2)
              mask = {(3*`ADDR_BITS_N){1'b1}};
            else if (item.addr < `PROG_CNFG_RANGES_LOG2_N + `PROG_CNFG_RANGES_N + 2)
              mask = {`WORD_SIZE{1'b1}};
            else if (item.addr == `PROG_CNFG_RANGES_LOG2_N + `PROG_CNFG_RANGES_N + 2) begin
              mask = {`FSM_CMD_BITS_N{1'b1}};
              assert(item.fsm_go) else $error("T=%0t [SPI Scoreboard] ERROR! FSM trigger not enabled, addr=0x%0h", $time, item.addr);
            end
            else 
              mask = 0;
            // Compare vs. stored value
            assert(item.rdata == (refq[item.addr].wdata & mask)) else $error("T=%0t [SPI Scoreboard] ERROR! addr=0x%0h exp=0x%0h act=0x%0h", $time, item.addr, refq[item.addr].wdata & mask, item.rdata);
          end
        end
      end
    end
  endtask
endclass
