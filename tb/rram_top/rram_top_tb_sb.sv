// The scoreboard is responsible to check data integrity. Since the design
// stores data it receives for each address, scoreboard helps to check if the
// same data is received when the same address is read at any later point
// in time. So the scoreboard has a "memory" element which updates it
// internally for every write operation.
typedef class fsm_tb_pkt;
class rram_top_tb_sb;
  // Scoreboard mailbox
  mailbox scb_mbx;
  
  // // Memory of requests
  // fsm_tb_pkt refq [];
  
  task run();
    // // Initial allocation of refq
    // refq = new [`PROG_CNFG_RANGES_LOG2_N + `PROG_CNFG_RANGES_N + 3];

    forever begin
      // Get item from mailbox
      fsm_tb_pkt item;
      scb_mbx.get(item);
      item.print("Top Scoreboard");

      // TODO: write followed by read should produce correct value if successful and incorrect value if unsuccessful
      
    end
  endtask
endclass
