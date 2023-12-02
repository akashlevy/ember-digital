// Log2 of number of ADC levels on readout circuit
`define ADC_BITS_N 6
// Log2 of number of DAC levels for WL DAC
`define WL_DAC_BITS_N 8
// Log2 of number of DAC levels for BL/SL DAC
`define BSL_DAC_BITS_N 5
// Log2 of number of DAC levels for READ DAC
`define READ_DAC_BITS_N 4
// Number of bits to use for PW (NOTE: this is a float, 3 exp bits, 5 mantissa)
`define PW_BITS_N 8
`define PW_FULL_BITS_N 14

// Log2 of number of possible loop orders
`define LOOP_BITS_N 3
// Number of bits to represent maximum number of programming attempts (up to 255)
`define MAX_ATTEMPTS_BITS_N 8
`define MAX_ATTEMPTS_FULL_BITS_N 14

// Maximum number of programming ranges
`define PROG_CNFG_RANGES_N 16
// Log2 of maximum number of programming ranges
`define PROG_CNFG_RANGES_LOG2_N 4

// Log2 of size of configuration register address space
`define CNFG_REG_ADDR_BITS_N (`PROG_CNFG_RANGES_LOG2_N+1)

// Word size number of bits read in parallel number of SAs
`define WORD_SIZE 48
`define WORD_SIZE_LOG2 6
// Effective word size after applying BCH ECC
`define ECC_WORD_SIZE 36
// Number of redundancy bits for ECC
`define ECC_RED_N_BITS 12

// Address size log2(number of WLs) + log2(column mux ratio) 10 + 6
`define ADDR_BITS_N 16
// Address size log2(number of WLs) + log2(column mux ratio) 10 + 6
`define NUM_WORDS (2**`ADDR_BITS_N)

// Number of bits in the configuration register for a single programming range (160)
`define PROG_CNFG_BITS_N (`READ_DAC_BITS_N + 4*`ADC_BITS_N + 2*(3*`WL_DAC_BITS_N + 3*`BSL_DAC_BITS_N + 3*`PW_BITS_N + `LOOP_BITS_N))

// Number of bits in the global configuration register
`define MISC_CNFG_BITS_N (`MAX_ATTEMPTS_BITS_N + 1 + `PROG_CNFG_RANGES_LOG2_N + 2*(`BSL_DAC_BITS_N + `WL_DAC_BITS_N + `PW_BITS_N) + 1 + `WORD_SIZE + 2 + 7*`SETUP_CYC_BITS_N)

// Number of bits to represent the number of setup cycles
`define SETUP_CYC_BITS_N 6

// Number of bits in the configuration register for 
`define ADDR_FSM_CMD_REG_BITS_N (`WORD_SIZE+`FSM_STATE_BITS_N+2)

// Reset values
`define CNFG_BITS_PROG_RSTVAL 0
`define CNFG_BITS_MISC_RSTVAL 0

// Number of bits for FSM stuff
`define FSM_STATE_BITS_N 5
`define OP_CODE_BITS_N 3
`define FSM_CMD_BITS_N (`OP_CODE_BITS_N + 5)
`define FSM_FULL_STATE_BITS_N (2*`FSM_STATE_BITS_N + 3 + `BSL_DAC_BITS_N + 1 + `ADC_BITS_N + `WORD_SIZE + `READ_DAC_BITS_N + 1 + `ADC_BITS_N + `ADDR_BITS_N + 5 + `WL_DAC_BITS_N + 2 + `PROG_CNFG_RANGES_LOG2_N + `PW_BITS_N + `PW_FULL_BITS_N + `MAX_ATTEMPTS_BITS_N + 6 + `PROG_CNFG_RANGES_LOG2_N)
`define FSM_DIAG_COUNT_BITS_N 32
`define FSM_DIAG_BITS_N (5*`FSM_DIAG_COUNT_BITS_N)

// SET/RST
`define RST 0
`define SET 1

// Possible FSM states
`define FSM_STATE_IDLE 0

`define FSM_STATE_INIT_TEST_PULSE 1
`define FSM_STATE_TEST_PULSE 2

`define FSM_STATE_INIT_TEST_READ 3
`define FSM_STATE_TEST_READ 4

`define FSM_STATE_INIT_TEST_CPULSE 5
`define FSM_STATE_TEST_CPULSE 6

`define FSM_STATE_INIT_CYCLE 7
`define FSM_STATE_PULSE_CYCLE 8
`define FSM_STATE_STEP_CYCLE 9

`define FSM_STATE_INIT_READ 10
`define FSM_STATE_READ_READ 11
`define FSM_STATE_STEP_READ 12
`define FSM_STATE_POST_READ 13

`define FSM_STATE_INIT_WRITE 14
`define FSM_STATE_READ_WRITE 15
`define FSM_STATE_PREPULSE_WRITE 16
`define FSM_STATE_PULSE_WRITE 17
`define FSM_STATE_PRESTEP_WRITE 18
`define FSM_STATE_STEP_WRITE 19

`define FSM_STATE_READ_ENERGY_INIT 20
`define FSM_STATE_READ_ENERGY_GO 21

// FSM opcodes
`define OP_TEST_PULSE 0
`define OP_TEST_READ 1
`define OP_TEST_CPULSE 2
`define OP_CYCLE 3
`define OP_READ 4
`define OP_WRITE 5
`define OP_REFRESH 6
`define OP_READ_ENERGY 7

// Loop orders
`define LOOP_PWB 0
`define LOOP_PBW 1
`define LOOP_WBP 2
`define LOOP_WPB 3
`define LOOP_BWP 4
`define LOOP_BPW 5

// Debugging switches
`define DEBUG_ADC_LVLS 1
`define DEBUG_PWS 0
`define DEBUG_DAC_LVLS 0
`define DEBUG_PULSES 1

// Macros to convert 8-bit floating point to int and compute max of two values
`define defloat(float) (float[4:0] << float[7:5])
`define max_fn(a, b) ((a > b) ? a : b)
