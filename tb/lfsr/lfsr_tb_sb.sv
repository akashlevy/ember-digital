// The scoreboard is responsible for checking data integrity, serving as a gold
// model. It checks that the pulses received by the analog block correspond
// properly to the commands sent and the settings in the register file.
typedef class lfsr_tb_pkt;
class lfsr_tb_sb;
  // Full-clock time
  localparam CLK = 10;
  
  // Mailboxes
  mailbox scb_mbx;

  // Values
  time values [bit [`WORD_SIZE-1:0]];
  bit [`WORD_SIZE-1:0] last_data = 0;

  // Counters
  int num_1s = 0;
  int num_0s = 0;
  
  task run();
    forever begin
      // Get item from mailbox
      lfsr_tb_pkt item;
      scb_mbx.get(item);
      item.print("LFSR Scoreboard");

      // Values
      if (item.enable) assert(!values.exists(item.data_out)) else $error("T=%0t [LFSR Scoreboard] Data seen before, data_out=%48b prev_time=%0t", item.t, item.data_out, values[item.data_out]);
      else assert((item.data_out == last_data) || (last_data == 0)) else $error("T=%0t [LFSR Scoreboard] Data out not equal to last data out, data_out=%48b last_data=%48b", item.t, item.data_out, last_data);

      // Set last value
      values[item.data_out] = item.t;
      last_data = item.data_out;

      // Update counters
      for (int i = 0; i < `WORD_SIZE; i += 1) begin
        if (item.data_out[i]) num_1s += 1;
        else num_0s += 1;
      end
      $info("T=%0t [LFSR Scoreboard] num_1s=%0d num_0s=%0d", item.t, num_1s, num_0s);
    end
  endtask
endclass
