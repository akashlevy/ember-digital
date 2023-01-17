// The scoreboard is responsible for checking data integrity, serving as a gold
// model. It checks that the pulses received by the analog block correspond
// properly to the commands sent and the settings in the register file.
typedef class bch_dec_tb_pkt;
class bch_dec_tb_sb;
  // Full-clock time
  localparam CLK = 10;
  
  // Mailboxes
  mailbox scb_mbx;
  
  task run();
    forever begin
      // Get item from mailbox
      bch_dec_tb_pkt item;
      scb_mbx.get(item);
      item.print("ECC Scoreboard");

      // If zero errors, should detect no errors
      if (item.n_bit_flips == 0) begin
        assert(~item.ecc_err_det) else $error("T=%0t [ECC Scoreboard] ERROR! Error detected with %0d bit flips, but no error, enc=0x%0h dec=0x%0h", $time, item.n_bit_flips, item.write_bits, item.read_bits);
        assert(item.read_bits == item.write_bits) else $error("T=%0t [ECC Scoreboard] ERROR! Encode/decode error with %0d bit flips, enc=0x%0h dec=0x%0h", $time, item.n_bit_flips, item.write_bits, item.read_bits);
      end
      // If one errors, should detect error
      if (item.n_bit_flips == 1) begin
        assert(item.read_bits == item.write_bits) else $error("T=%0t [ECC Scoreboard] ERROR! Encode/decode error with %0d bit flips, enc=0x%0h dec=0x%0h", $time, item.n_bit_flips, item.write_bits, item.read_bits);
      end
      // If two errors, should detect errors
      if (item.n_bit_flips == 2) begin
        assert(item.read_bits == item.write_bits) else $error("T=%0t [ECC Scoreboard] ERROR! Encode/decode error with %0d bit flips, enc=0x%0h dec=0x%0h", $time, item.n_bit_flips, item.write_bits, item.read_bits);
      end
      // If ten errors, should detect errors
      if (item.n_bit_flips == 10) begin
        assert(item.ecc_err_det) else $error("T=%0t [ECC Scoreboard] ERROR! No error detected with %0d bit flips, but error is present, enc=0x%0h dec=0x%0h", $time, item.n_bit_flips, item.write_bits, item.read_bits);
        assert(item.read_bits != item.write_bits) else $error("T=%0t [ECC Scoreboard] ERROR! Encode/decode was somehow correct with %0d bit flips, enc=0x%0h dec=0x%0h", $time, item.n_bit_flips, item.write_bits, item.read_bits);
      end
    end
  endtask
endclass
