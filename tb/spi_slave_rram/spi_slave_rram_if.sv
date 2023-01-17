// The interface allows verification components to access DUT signals
// using a virtual interface handle
interface spi_slave_rram_if (input bit sclk);
  // Reset
  logic       rst_n;      // (I) Chip reset, active LO

  // SPI interface
  logic       sc;         // (I) SPI chip select (and async reset when sc = '0')
  logic       mosi;       // (I) SPI master out, slave in
  logic       miso;       // (O) SPI master in, slave out data
  logic       miso_oe_n;  // (O) miso output enable, active LO

  // FSM bits
  logic     [`FSM_FULL_STATE_BITS_N-1:0]    fsm_bits;   // State of all regs in FSM
  logic     [`FSM_DIAG_BITS_N-1:0]          diag_bits;  // Diagnostic state in FSM
  logic     [`WORD_SIZE-1:0] readdata [`PROG_CNFG_RANGES_LOG2_N-1:0]; // Read data
  logic                                     rram_busy;  // Is FSM active

  // Transaction elements
  bit       [`CNFG_REG_ADDR_BITS_N-1:0]     addr;       // Register file address
  bit       [`PROG_CNFG_BITS_N-1:0]         wdata;      // Register file write data
  bit       [`PROG_CNFG_BITS_N-1:0]         rdata;      // Register file read data
  bit       [`FSM_FULL_STATE_BITS_N-1:0]    fsmdata;    // FSM state data
  bit       [`FSM_FULL_STATE_BITS_N-1:0]    diagdata;   // FSM state data
  bit                                       fsm_go;     // FSM trigger
  bit                                       wr;         // Do read if 0, write if 1
endinterface
