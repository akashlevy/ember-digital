# EMBER Digital

Digital Controller for EMBER Macro

## Development

- [Pinout + Padring](https://docs.google.com/spreadsheets/d/1F-PWVagtQ-Ui3u860bWzbaDPqzcz8UbagP6eDvCCSuY/edit#gid=0)
- [Design Spec](https://docs.google.com/document/d/1LbkW45vk6-VXC_B70_3eowlAWJctKT6UaLPAN31i_M0/edit#heading=h.lv7ay9o0ps8m)
- [Verification Testbenches](https://docs.google.com/spreadsheets/d/1GGPX_i5UcM2toY0Xc5Y4Ey8pEWphJH48-MqaJ5XcKpI/edit#gid=0)

## Task List

### LIB File
  - CREATE SILICONSMART BENCH FOR ANALOG BLOCK TO GET ACCURATE LIB

### RTL to Write
- Change FSM style
- FSM logic
  - Test charge pulse mode
  - Cycle mode
  - Read mode
  - Write mode
- IDLE indicator pin for when in IDLE state: `idle` pin
- Generate SAIF file for synthesis
- Change clock style to synchronous and add `fsm_pause` pin

### Testing
- Test SPI slave RRAM (DONE)
- Test FSM all conditions
  - Test pulse mode (DONE)
  - Test read mode (DONE)
  - Cycle mode
  - Write mode
  - Read mode
  - Refresh mode
  - Test charge pulse mode
- Top-level
  - Full flow integration tests run back to back
  - Cover all states
  - ECC testing
  - Test serial read out during FSM operation (pause FSM clock?)
    - Test clock disable/enable
- Coverage and Testing over Large Space of Random Params

### Documentation
- Do it!

## Dependencies

- XCELIUM 20.09.007 (`module load xcelium`)

## Generating a read/write pulse train VCD

- Make sure you have loaded Xcelium (`module load xcelium`)
- Modify `tb/fsm/fsm_test.sv`
  - Next, you want to constrain the pulses such that you apply a certain operation with a certain set of parameters
  - To do this, you want to add/modify code such as:
    ```systemverilog
    // Test TEST_PULSE operation
    item = new;
    assert(item.randomize() with { opcode == `OP_TEST_PULSE; pw == 5; }); // assert uses return val to avoid warn
    drv_mbx.put(item);
    ```
  - The constraints on the pulse train parameters may be modified to tune the behavior of the pulse train. By default, if unspecified, the parameter will be randomized. Below are a list of relevant parameters and a description of what they do:
    - `opcode`: whether to do a read/write operation. OP_TEST_PULSE is for write, OP_TEST_READ is for read
    - `set_first`: does a SET when equal to 1, does a RST when equal to 0
    - `di_init_mask`: this 48-bit value specifies the `di` mask to use
    - `idle_to_init_write_setup_cycles`: number of cycles to apply the write enable signals (`wl_en`,`bl_en`,`wl_dac_en`, etc.) before applying `aclk` and `we` during a write
    - `idle_to_init_read_setup_cycles`: number of cycles to apply the read enable signals (`wl_en`,`bl_en`,`read_dac_en`, etc.) before applying `sa_en` during a read
    - `pw_set_cycle`: pulse width in units of clock cycles if using a SET pulse
    - `pw_rst_cycle`: pulse width in units of clock cycles if using a RESET pulse
    - `address_start`: address to use
    - `adc_clamp_ref_lvl`: clamp ref level to use
    - `adc_read_dac_lvl`: read DAC level to use
    - `adc_upper_read_ref_lvl`: read ref level to use
    - `bl_dac_set_lvl_cycle`: BL DAC level to use during SET
    - `wl_dac_set_lvl_cycle`: WL DAC level to use during SET
    - `sl_dac_rst_lvl_cycle`: SL DAC level to use during RESET
    - `wl_dac_rst_lvl_cycle`: WL DAC level to use during RESET
- Run `make top=FSM`
- If successful, this should generate a file called `dump.vcd`
- You can explore the dump using `simvision` and you can import it into Cadence ADE to perform mixed-signal simulations

## EMBER Sister Repositories

- Digital: https://code.stanford.edu/tsmc40r/emblem-digital
- Physical Design: https://code.stanford.edu/tsmc40r/emblem-pd
- Analog: https://code.stanford.edu/tsmc40r/emblem-analog
