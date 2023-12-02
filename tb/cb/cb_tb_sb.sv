// The scoreboard is responsible for checking data integrity, serving as a gold
// model. It checks that the pulses received by the analog block correspond
// properly to the commands sent and the settings in the register file.
typedef class cb_tb_pkt;
class cb_tb_sb;
  // Full-clock time
  localparam CLK = 10;
  
  // Mailboxes
  mailbox scb_mbx;

  // Counters
  int i;
  int counter;

  // Expected data
  int exp_data_out [`WORD_SIZE];

  task run();
    forever begin
      // Get item from mailbox
      cb_tb_pkt item;
      scb_mbx.get(item);
      item.print("CB Scoreboard");

      // Increment counter
      if (item.enable) counter += 1;

      // Check data out
      for (i = 0; i < `WORD_SIZE; i=i+1) begin
        exp_data_out[i] = (counter + i) % ((item.num_levels == 0) ? 16 : (item.num_levels == 8) ? 8 : (item.num_levels == 4) ? 4 : (item.num_levels == 2) ? 2 : 1);
        assert ({item.data_out[3][i], item.data_out[2][i], item.data_out[1][i], item.data_out[0][i]} == exp_data_out[i]) else $error("T=%0t [CB Scoreboard] Data out mismatch, i=%0d data_out=%48b exp_data_out=%48b", item.t, i, {item.data_out[3][i], item.data_out[2][i], item.data_out[1][i], item.data_out[0][i]}, exp_data_out[i]);
      end
    end
  endtask
endclass
