<!---
Markdown description for SystemRDL register map.

Don't override. Generated from: ember_regs
  - ember.rdl
-->

# EMBER address map

- Absolute Address: 0x0
- Base Offset: 0x0
- Size: 0x400

<p>Address map containing the EMBER register file specifications. To get SPI register file addresses, all offsets/sizes/strides should be divided by 32.</p>

|Offset|Identifier|        Name       |
|------|----------|-------------------|
|  0x0 | ember_rf |EMBER Register File|

## ember_rf register file

- Absolute Address: 0x0
- Base Offset: 0x0
- Size: 0x400

<p>Register file containing all of the config registers for the EMBER macro</p>

|Offset|   Identifier  |            Name            |
|------|---------------|----------------------------|
| 0x000|  lvl_settings |Level Settings Register File|
| 0x200|global_settings|  Global Settings Register  |
| 0x220|   rram_addr   |    RRAM Address Register   |
| 0x240|   write_data  |  Write Data Register File  |
| 0x2C0|    fsm_cmd    |    FSM Command Register    |
| 0x2E0|   fsm_state   |     FSM State Register     |
| 0x300|    fsm_diag   |  FSM Diagnostic Register 1 |
| 0x320|   read_data   |   Read Data Register File  |
| 0x3A0|   fsm_diag2   |  FSM Diagnostic Register 2 |
| 0x3E0|   apb_reset   |     APB Reset Register     |

## lvl_settings register file

- Absolute Address: 0x0
- Base Offset: 0x0
- Size: 0x200

<p>Register file containing the settings for each allocated level</p>

|Offset|   Identifier   |          Name         |
|------|----------------|-----------------------|
| 0x000|lvl_settings[0]|Level Settings Register|
| 0x020|lvl_settings[1]|Level Settings Register|
| 0x040|lvl_settings[2]|Level Settings Register|
| 0x060|lvl_settings[3]|Level Settings Register|
| 0x080|lvl_settings[4]|Level Settings Register|
| 0x0A0|lvl_settings[5]|Level Settings Register|
| 0x0C0|lvl_settings[6]|Level Settings Register|
| 0x0E0|lvl_settings[7]|Level Settings Register|
| 0x100|lvl_settings[8]|Level Settings Register|
| 0x120|lvl_settings[9]|Level Settings Register|
| 0x140|lvl_settings[10]|Level Settings Register|
| 0x160|lvl_settings[11]|Level Settings Register|
| 0x180|lvl_settings[12]|Level Settings Register|
| 0x1A0|lvl_settings[13]|Level Settings Register|
| 0x1C0|lvl_settings[14]|Level Settings Register|
| 0x1E0|lvl_settings[15]|Level Settings Register|

### lvl_settings register

- Absolute Address: 0x0
- Base Offset: 0x0
- Size: 0x20
- Array Dimensions: [16]
- Array Stride: 0x20
- Total Size: 0x200

<p>Register containing all of the settings for one allocated conductance level</p>

|  Bits |       Identifier      |Access|Reset|              Name             |
|-------|-----------------------|------|-----|-------------------------------|
|  5:0  |   adc_clamp_ref_lvl   |  rw  | 0x0 |   ADC Clamp Reference Level   |
|  9:6  |    adc_read_dac_lvl   |  rw  | 0x0 |       ADC READ DAC Level      |
| 15:10 | adc_upper_read_ref_lvl|  rw  | 0x0 | ADC Upper Read Reference Level|
| 21:16 |adc_upper_write_ref_lvl|  rw  | 0x0 |ADC Upper Write Reference Level|
| 27:22 |adc_lower_write_ref_lvl|  rw  | 0x0 |ADC Lower Write Reference Level|
| 32:28 |  bl_dac_set_lvl_start |  rw  | 0x0 |     BL DAC SET Level Start    |
| 37:33 |  bl_dac_set_lvl_stop  |  rw  | 0x0 |     BL DAC SET Level Stop     |
| 42:38 |  bl_dac_set_lvl_step  |  rw  | 0x0 |     BL DAC SET Level Step     |
| 50:43 |  wl_dac_set_lvl_start |  rw  | 0x0 |     WL DAC SET Level Start    |
| 58:51 |  wl_dac_set_lvl_stop  |  rw  | 0x0 |     WL DAC SET Level Stop     |
| 66:59 |  wl_dac_set_lvl_step  |  rw  | 0x0 |     WL DAC SET Level Step     |
| 74:67 |      pw_set_start     |  rw  | 0x0 |          PW SET Start         |
| 82:75 |      pw_set_stop      |  rw  | 0x0 |          PW SET Stop          |
| 90:83 |      pw_set_step      |  rw  | 0x0 |          PW SET Step          |
| 93:91 |     loop_order_set    |  rw  | 0x0 |         Loop Order SET        |
| 98:94 |  sl_dac_rst_lvl_start |  rw  | 0x0 |    SL DAC RESET Level Start   |
| 103:99|  sl_dac_rst_lvl_stop  |  rw  | 0x0 |    SL DAC RESET Level Stop    |
|108:104|  sl_dac_rst_lvl_step  |  rw  | 0x0 |    SL DAC RESET Level Step    |
|116:109|  wl_dac_rst_lvl_start |  rw  | 0x0 |    WL DAC RESET Level Start   |
|124:117|  wl_dac_rst_lvl_stop  |  rw  | 0x0 |    WL DAC RESET Level Stop    |
|132:125|  wl_dac_rst_lvl_step  |  rw  | 0x0 |    WL DAC RESET Level Step    |
|140:133|      pw_rst_start     |  rw  | 0x0 |         PW RESET Start        |
|148:141|      pw_rst_stop      |  rw  | 0x0 |         PW RESET Stop         |
|156:149|      pw_rst_step      |  rw  | 0x0 |         PW RESET Step         |
|159:157|     loop_order_rst    |  rw  | 0x0 |        Loop Order RESET       |

#### adc_clamp_ref_lvl field

<p>ADC clamp reference DAC level to use</p>

#### adc_read_dac_lvl field

<p>ADC READ DAC level to use</p>

#### adc_upper_read_ref_lvl field

<p>ADC upper read reference DAC level to use</p>

#### adc_upper_write_ref_lvl field

<p>ADC upper write reference DAC level to use</p>

#### adc_lower_write_ref_lvl field

<p>ADC lower write reference DAC level to use</p>

#### bl_dac_set_lvl_start field

<p>BL DAC level to start at for SET during WRITE commands</p>

#### bl_dac_set_lvl_stop field

<p>BL DAC level to stop at for SET during WRITE commands</p>

#### bl_dac_set_lvl_step field

<p>BL DAC level to step at for SET during WRITE commands</p>

#### wl_dac_set_lvl_start field

<p>WL DAC level to start at for SET during WRITE commands</p>

#### wl_dac_set_lvl_stop field

<p>WL DAC level to stop at for SET during WRITE commands</p>

#### wl_dac_set_lvl_step field

<p>WL DAC level to step at for SET during WRITE commands</p>

#### pw_set_start field

<p>Pulse width to start at for SET during WRITE commands</p>

#### pw_set_stop field

<p>Pulse width to stop at for SET during WRITE commands</p>

#### pw_set_step field

<p>Pulse width to step at for SET during WRITE commands</p>

#### loop_order_set field

<p>Code for loop order to use for SET during WRITE commands</p>

#### sl_dac_rst_lvl_start field

<p>SL DAC level to start at for RESET during WRITE commands</p>

#### sl_dac_rst_lvl_stop field

<p>SL DAC level to stop at for RESET during WRITE commands</p>

#### sl_dac_rst_lvl_step field

<p>SL DAC level to step at for RESET during WRITE commands</p>

#### wl_dac_rst_lvl_start field

<p>WL DAC level to start at for RESET during WRITE commands</p>

#### wl_dac_rst_lvl_stop field

<p>WL DAC level to stop at for RESET during WRITE commands</p>

#### wl_dac_rst_lvl_step field

<p>WL DAC level to step at for RESET during WRITE commands</p>

#### pw_rst_start field

<p>Pulse width to start at for RESET during WRITE commands</p>

#### pw_rst_stop field

<p>Pulse width to stop at for RESET during WRITE commands</p>

#### pw_rst_step field

<p>Pulse width to step at for RESET during WRITE commands</p>

#### loop_order_rst field

<p>Code for loop order to use for RESET during WRITE commands</p>

## global_settings register

- Absolute Address: 0x200
- Base Offset: 0x200
- Size: 0x20

<p>Register containing all of the global settings for operating the RRAM macro</p>

|  Bits |           Identifier          |Access|Reset|              Name             |
|-------|-------------------------------|------|-----|-------------------------------|
|  7:0  |          max_attempts         |  rw  | 0x0 |  Maximum Programming Attempts |
|   8   |            use_ecc            |  rw  | 0x0 |            Use ECC            |
|  13:9 |      bl_dac_set_lvl_cycle     |  rw  | 0x0 |        BL DAC SET Level       |
| 21:14 |      wl_dac_set_lvl_cycle     |  rw  | 0x0 |        WL DAC SET Level       |
| 29:22 |          pw_set_cycle         |  rw  | 0x0 |        PW DAC SET Level       |
| 34:30 |      bl_dac_rst_lvl_cycle     |  rw  | 0x0 |        BL DAC RST Level       |
| 42:35 |      wl_dac_rst_lvl_cycle     |  rw  | 0x0 |        WL DAC RST Level       |
| 50:43 |          pw_rst_cycle         |  rw  | 0x0 |        PW DAC RST Level       |
|   51  |           set_first           |  rw  | 0x0 |           SET First           |
| 99:52 |          di_init_mask         |  rw  | 0x0 |          Data In Mask         |
|  100  |        ignore_failures        |  rw  | 0x0 |        Ignore Failures        |
|  101  |          all_dacs_on          |  rw  | 0x0 |        Keep All DACs On       |
|107:102|idle_to_init_write_setup_cycles|  rw  | 0x0 |Idle to Init Write Setup Cycles|
|113:108| idle_to_init_read_setup_cycles|  rw  | 0x0 | Idle to Init Read Setup Cycles|
|119:114|read_to_init_write_setup_cycles|  rw  | 0x0 |Read to Init Write Setup Cycles|
|125:120|write_to_init_read_setup_cycles|  rw  | 0x0 |Write to Init Read Setup Cycles|
|131:126|     step_read_setup_cycles    |  rw  | 0x0 |     Step Read Setup Cycles    |
|137:132|    step_write_setup_cycles    |  rw  | 0x0 |    Step Write Setup Cycles    |
|143:138|     post_read_setup_cycles    |  rw  | 0x0 |     Post Read Setup Cycles    |

#### max_attempts field

<p>Maximum number of programming attempts before giving up</p>

#### use_ecc field

<p>Whether to use ECC to correct errors</p>

#### bl_dac_set_lvl_cycle field

<p>BL/SL DAC level to use for SET during CYCLE/PULSE commands</p>

#### wl_dac_set_lvl_cycle field

<p>WL DAC level to use for SET during CYCLE/PULSE commands</p>

#### pw_set_cycle field

<p>Pulse width to use for SETduring CYCLE/PULSE commands</p>

#### bl_dac_rst_lvl_cycle field

<p>BL/SL DAC level to use for RESET during CYCLE/PULSE commands</p>

#### wl_dac_rst_lvl_cycle field

<p>WL DAC level to use for RESET during CYCLE/PULSE commands</p>

#### pw_rst_cycle field

<p>Pulse width to use for RESET during CYCLE/PULSE commands</p>

#### set_first field

<p>Whether to SET (1) or RESET (0) first during CYCLE/PULSE/WRITE commands</p>

#### di_init_mask field

<p>Mask for the Data In (DI) to ignore certain bits during operations</p>

#### ignore_failures field

<p>Whether to ignore failures during programming</p>

#### all_dacs_on field

<p>Whether to keep all DACs on during programming</p>

#### idle_to_init_write_setup_cycles field

<p>Number of cycles to wait in INIT_WRITE state before starting the write, allowing for dynamically adjustable setup time</p>

#### idle_to_init_read_setup_cycles field

<p>Number of cycles to wait in INIT_READ state before starting the read, allowing for dynamically adjustable setup time</p>

#### read_to_init_write_setup_cycles field

<p>Number of cycles to wait in INIT_WRITE state before starting the write, given that a READ just happened, allowing for dynamically adjustable setup time</p>

#### write_to_init_read_setup_cycles field

<p>Number of cycles to wait in INIT_READ state before starting the read, given that a WRITE just happened, allowing for dynamically adjustable setup time</p>

#### step_read_setup_cycles field

<p>Number of cycles to wait in STEP_READ state before starting the next read, allowing for dynamically adjustable setup time</p>

#### step_write_setup_cycles field

<p>Number of cycles to wait in STEP_WRITE state before starting the next write, allowing for dynamically adjustable setup time</p>

#### post_read_setup_cycles field

<p>Number of cycles to wait after READ finishes to account for timing violations</p>

## rram_addr register

- Absolute Address: 0x220
- Base Offset: 0x220
- Size: 0x20

<p>Register containing the target {start, stop, step} addresses</p>

| Bits|  Identifier |Access|Reset|       Name       |
|-----|-------------|------|-----|------------------|
| 15:0|address_start|  rw  | 0x0 |RRAM Address Start|
|31:16| address_stop|  rw  | 0x0 | RRAM Address Stop|
|47:32| address_step|  rw  | 0x0 | RRAM Address Step|

#### address_start field

<p>Register containing the address of the target RRAM word to start at</p>

#### address_stop field

<p>Register containing the address of the target RRAM word to stop at</p>

#### address_step field

<p>Register containing the stride of the target RRAM word address</p>

## write_data register file

- Absolute Address: 0x240
- Base Offset: 0x240
- Size: 0x80

<p>Register file containing the data to be written to the RRAM array</p>

|Offset|  Identifier |        Name       |
|------|-------------|-------------------|
| 0x00 |write_data[0]|Write Data Register|
| 0x20 |write_data[1]|Write Data Register|
| 0x40 |write_data[2]|Write Data Register|
| 0x60 |write_data[3]|Write Data Register|

### write_data register

- Absolute Address: 0x240
- Base Offset: 0x0
- Size: 0x20
- Array Dimensions: [4]
- Array Stride: 0x20
- Total Size: 0x80

<p>Register containing the data to be written to the RRAM array</p>

|Bits|   Identifier  |Access|Reset|   Name   |
|----|---------------|------|-----|----------|
|47:0|write_data_bits|  rw  | 0x0 |Write Data|

#### write_data_bits field

<p>Data to be written to the RRAM array</p>

### write_data register

- Absolute Address: 0x260
- Base Offset: 0x0
- Size: 0x20
- Array Dimensions: [4]
- Array Stride: 0x20
- Total Size: 0x80

<p>Register containing the data to be written to the RRAM array</p>

|Bits|   Identifier  |Access|Reset|   Name   |
|----|---------------|------|-----|----------|
|47:0|write_data_bits|  rw  | 0x0 |Write Data|

#### write_data_bits field

<p>Data to be written to the RRAM array</p>

### write_data register

- Absolute Address: 0x280
- Base Offset: 0x0
- Size: 0x20
- Array Dimensions: [4]
- Array Stride: 0x20
- Total Size: 0x80

<p>Register containing the data to be written to the RRAM array</p>

|Bits|   Identifier  |Access|Reset|   Name   |
|----|---------------|------|-----|----------|
|47:0|write_data_bits|  rw  | 0x0 |Write Data|

#### write_data_bits field

<p>Data to be written to the RRAM array</p>

### write_data register

- Absolute Address: 0x2A0
- Base Offset: 0x0
- Size: 0x20
- Array Dimensions: [4]
- Array Stride: 0x20
- Total Size: 0x80

<p>Register containing the data to be written to the RRAM array</p>

|Bits|   Identifier  |Access|Reset|   Name   |
|----|---------------|------|-----|----------|
|47:0|write_data_bits|  rw  | 0x0 |Write Data|

#### write_data_bits field

<p>Data to be written to the RRAM array</p>

### fsm_cmd register

- Absolute Address: 0x2C0
- Base Offset: 0x2C0
- Size: 0x20

<p>Register containing the current FSM command</p>

|Bits|   Identifier  |Access|Reset|             Name            |
|----|---------------|------|-----|-----------------------------|
| 2:0|     opcode    |  rw  | 0x0 |      FSM Command Opcode     |
|  3 |   loop_mode   |  rw  | 0x0 |          Loop Mode          |
|  4 |    check63    |  rw  | 0x0 |        Check Level 63       |
|  5 |  use_cb_data  |  rw  | 0x0 |    Use Checkerboard Data    |
|  6 | use_lfsr_data |  rw  | 0x0 |        Use LFSR Data        |
|  7 |use_multi_addrs|  rw  | 0x0 |Perform on Multiple Addresses|

#### opcode field

<p>Current FSM command opcode</p>

#### loop_mode field

<p>Whether to loop the current command</p>

#### check63 field

<p>Whether to perform READ on level 63 during programming (1 = skip and assume below, 0 = READ to check)</p>

#### use_cb_data field

<p>Whether to use checkerboard data during programming</p>

#### use_lfsr_data field

<p>Whether to use LFSR data during programming</p>

#### use_multi_addrs field

<p>Whether to perform the current command on multiple addresses using address {start, stop, step}</p>

### fsm_state register

- Absolute Address: 0x2E0
- Base Offset: 0x2E0
- Size: 0x20

<p>Register containing the current FSM state</p>

|  Bits |       Identifier       |Access|Reset|               Name              |
|-------|------------------------|------|-----|---------------------------------|
|  4:0  |          state         |  rw  | 0x0 |            FSM State            |
|  9:5  |       next_state       |  rw  | 0x0 |          FSM Next State         |
|   10  |          aclk          |  rw  | 0x0 |               aclk              |
|   11  |          bl_en         |  rw  | 0x0 |              bl_en              |
|   12  |        bleed_en        |  rw  | 0x0 |             bleed_en            |
| 17:13 |     bsl_dac_config     |  rw  | 0x0 |          bsl_dac_config         |
|   18  |       bsl_dac_en       |  rw  | 0x0 |            bsl_dac_en           |
| 24:19 |        clamp_ref       |  rw  | 0x0 |            clamp_ref            |
| 72:25 |           di           |  rw  | 0x0 |                di               |
| 76:73 |     read_dac_config    |  rw  | 0x0 |         read_dac_config         |
|   77  |       read_dac_en      |  rw  | 0x0 |           read_dac_en           |
| 83:78 |        read_ref        |  rw  | 0x0 |             read_ref            |
| 99:84 |        rram_addr       |  rw  | 0x0 |            rram_addr            |
|  100  |         sa_clk         |  rw  | 0x0 |              sa_clk             |
|  101  |          sa_en         |  rw  | 0x0 |              sa_en              |
|  102  |         set_rst        |  rw  | 0x0 |             set_rst             |
|  103  |          sl_en         |  rw  | 0x0 |              sl_en              |
|  104  |           we           |  rw  | 0x0 |                we               |
|112:105|      wl_dac_config     |  rw  | 0x0 |          wl_dac_config          |
|  113  |        wl_dac_en       |  rw  | 0x0 |            wl_dac_en            |
|  114  |          wl_en         |  rw  | 0x0 |              wl_en              |
|118:115|         rangei         |  rw  | 0x0 |           Range Index           |
|126:119|           pw           |  rw  | 0x0 |           Pulse Width           |
|140:127|         counter        |  rw  | 0x0 |             Counter             |
|148:141|      max_attempts      |  rw  | 0x0 |   Maximum Programming Attempts  |
|  149  |      is_first_try      |  rw  | 0x0 |           Is First Try          |
|  150  |     counter_incr_en    |  rw  | 0x0 |     Counter Increment Enable    |
|  151  |       counter_rst      |  rw  | 0x0 |          Counter Reset          |
|  152  |attempts_counter_incr_en|  rw  | 0x0 |Attempts Counter Increment Enable|
|  153  |  attempts_counter_rst  |  rw  | 0x0 |      Attempts Counter Reset     |
|  154  |    next_is_first_try   |  rw  | 0x0 |        Next Is First Try        |
|158:155|       next_rangei      |  rw  | 0x0 |         Next Range Index        |

#### state field

<p>Current FSM state</p>

#### next_state field

<p>Next FSM state</p>

#### aclk field

<p>Write enable</p>

#### bl_en field

<p>BL enable</p>

#### bleed_en field

<p>Bleed enable</p>

#### bsl_dac_config field

<p>BL/SL DAC level</p>

#### bsl_dac_en field

<p>BL/SL DAC enable</p>

#### clamp_ref field

<p>ADC clamp reference DAC level</p>

#### di field

<p>Data in mask</p>

#### read_dac_config field

<p>ADC READ DAC level</p>

#### read_dac_en field

<p>ADC READ DAC enable</p>

#### read_ref field

<p>ADC read reference DAC level</p>

#### rram_addr field

<p>RRAM word address</p>

#### sa_clk field

<p>SA clock enable</p>

#### sa_en field

<p>SA enable</p>

#### set_rst field

<p>Whether to SET (1) or RESET (0)</p>

#### sl_en field

<p>SL enable</p>

#### we field

<p>Write enable</p>

#### wl_dac_config field

<p>WL DAC level</p>

#### wl_dac_en field

<p>WL DAC enable</p>

#### wl_en field

<p>WL enable</p>

#### rangei field

<p>Current conductance range index</p>

#### pw field

<p>Current pulse width to use</p>

#### counter field

<p>Current counter value</p>

#### max_attempts field

<p>Maximum number of programming attempts before giving up</p>

#### is_first_try field

<p>Whether this is the first try of the current operation</p>

#### counter_incr_en field

<p>Whether to increment the counter</p>

#### counter_rst field

<p>Whether to reset the counter</p>

#### attempts_counter_incr_en field

<p>Whether to increment the attempts counter</p>

#### attempts_counter_rst field

<p>Whether to reset the attempts counter</p>

#### next_is_first_try field

<p>The next value of is_first_try</p>

#### next_rangei field

<p>The next value of rangei</p>

### fsm_diag register

- Absolute Address: 0x300
- Base Offset: 0x300
- Size: 0x20

<p>Register containing the current FSM diagnostic information</p>

|  Bits |   Identifier  |Access|Reset|     Name    |
|-------|---------------|------|-----|-------------|
|  31:0 |success_counter|   r  | 0x0 |Success Count|
| 63:32 |failure_counter|   r  | 0x0 |Failure Count|
| 95:64 |  read_counter |   r  | 0x0 |  Read Count |
| 127:96|  set_counter  |   r  | 0x0 |  SET Count  |
|159:128| reset_counter |   r  | 0x0 | RESET Count |

#### success_counter field

<p>Current number of addresses written to during current/last operation</p>

#### failure_counter field

<p>Current number of address levels failed to write to during current/last operation</p>

#### read_counter field

<p>Current number of READs performed on words during current/last operation</p>

#### set_counter field

<p>Current number of SETs performed on words during current/last operation</p>

#### reset_counter field

<p>Current number of RESETs performed on words during current/last operation</p>

## read_data register file

- Absolute Address: 0x320
- Base Offset: 0x320
- Size: 0x80

<p>Register file containing the data read from the RRAM array</p>

|Offset| Identifier |       Name       |
|------|------------|------------------|
| 0x00 |read_data[0]|Read Data Register|
| 0x20 |read_data[1]|Read Data Register|
| 0x40 |read_data[2]|Read Data Register|
| 0x60 |read_data[3]|Read Data Register|

### read_data register

- Absolute Address: 0x320
- Base Offset: 0x0
- Size: 0x20
- Array Dimensions: [4]
- Array Stride: 0x20
- Total Size: 0x80

<p>Register containing the data read from the RRAM array</p>

|Bits|  Identifier  |Access|Reset|   Name  |
|----|--------------|------|-----|---------|
|47:0|read_data_bits|   r  | 0x0 |Read Data|

#### read_data_bits field

<p>Data read from the RRAM array</p>

## fsm_diag2 register

- Absolute Address: 0x3A0
- Base Offset: 0x3A0
- Size: 0x20

<p>Register containing the current FSM diagnostic information</p>

| Bits |    Identifier    |Access|Reset|      Name      |
|------|------------------|------|-----|----------------|
| 31:0 |   cycle_counter  |   r  | 0x0 |   Cycle Count  |
| 63:32| read_bits_counter|   r  | 0x0 | Read Bits Count|
| 95:64| set_bits_counter |   r  | 0x0 | SET Bits Count |
|127:96|reset_bits_counter|   r  | 0x0 |RESET Bits Count|

#### cycle_counter field

<p>Number of cycles since current/last operation was initiated</p>

#### read_bits_counter field

<p>Current number of bits read from the RRAM array during current/last operation</p>

#### set_bits_counter field

<p>Current number of bits SET in the RRAM array during current/last operation</p>

#### reset_bits_counter field

<p>Current number of bits RESET in the RRAM array during current/last operation</p>

## apb_reset register

- Absolute Address: 0x3E0
- Base Offset: 0x3E0
- Size: 0x20

<p>Reset the register file, return ASCII 'RAM'</p>

|Bits|Identifier|Access|  Reset |   Name  |
|----|----------|------|--------|---------|
|31:0|    ram   |   r  |0x52414D|APB Reset|

#### ram field

<p>Read-only register that returns ASCII 'RAM'</p>
