// =========================== COPYRIGHT NOTICE =============================
// 
//                      Copyright 2020 © SkyWater Technology
//                     Customer Proprietary and Confidential                    
//                         Authored by Intrinsix Corp.                
//                                                           
// =============================== WARRANTY =================================
// 
// INTRINSIX CORP. MAKES NO WARRANTY OF ANY KIND WITH REGARD TO THE USE OF   
// THIS SOFTWARE OR ITS ACCOMPANYING DOCUMENTATION, EITHER EXPRESSED OR 
// IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
// MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.
//
// ==========================================================================
//
// Original Author: Kent Arnold
// Filename       : fsm.v
// Description    : Finite State Machine for SKY105 ASIC
// 
// ==========================================================================

//  This digital block provides the control logic that produces
//  rram signaling for FORM, WRITE and READ accesses.

module fsm (
  input              fsm_rst_n,    // (I) Chip reset, active LO
  input              fsm_clk,      // (I) Chip clock

  // Control from Register Array i/f
  input              fsm_go,             // (I) CONTROL_REG: FSM trigger indicator

  // Config from Register Array i/f
  input       [2:0]  clu_op_code,        // (I) CONTROL_REG: FSM command indicator

  input       [1:0]  sa_clk_conf,        // (I) READ_CONFIG_REG: sa_clk configuration
  input              check_board_conf,   // (I) READ_CONFIG_REG: read checkerboard configuration
  input       [16:0] read_multi_offset,  // (I) READ_CONFIG_REG: upper address for multiple reads
  input       [1:0]  read_mode,          // (I) READ_CONFIG_REG: read one, multi, all 

  input       [2:0]  wdata_pattern,      // (I) WRITE_CONFIG_REG: write checkerboard configuration
  input       [16:0] write_multi_offset, // (I) WRITE_CONFIG_REG: upper address for multiple writes
  input       [1:0]  write_mode,         // (I) WRITE_CONFIG_REG: write one, multi, all 

  input       [16:0] form_multi_offset,  // (I) FORM_CONFIG_REG: upper address for multiple forms
  input       [1:0]  form_mode,          // (I) FORM_CONFIG_REG: form one, multi, all 

  input       [16:0] address,            // (I) RRAM_ADDR_REG: address
  input       [3:0]  banksel,            // (I) RRAM_ADDR_REG: bank select

  input       [15:0] data_in,            // (I) DATA_IN_REG bits

  input              rdata_dest,         // (I) CHIP_CONFIG_REG: SPI reg vs. Direct Access DO select
  input              wdata_source,       // (I) CHIP_CONFIG_REG: SPI reg vs. Direct Access DI select
  input              addr_source,        // (I) CHIP_CONFIG_REG: SPI reg vs. Direct Access ADDR select

  input              diag_mode,          // (I) CHIP_CONFIG_REG: dianostic mode select
  input              diag_fifo_full,     // (I) FULL flag from diag FIFO
  output reg         diag_push,          // (O) PUSH/write control to diag FIFO

  input              force_set_type,     // (I) SET_REF_CONFIG_REG: controls value of set_form signal during FORCE SET commands

  input       [5:0]  set_retry_limit,    // (I) SET_CONFIG_REG: retry limits for SET
  input       [16:0] set_timer_config,   // (I) SET_CONFIG_REG: pulse width for SET

  input       [5:0]  reset_retry_limit,  // (I) RESET_CONFIG_REG: retry limits for RESET
  input       [16:0] reset_timer_config, // (I) RESET_CONFIG_REG: pulse width for RESET

  input       [16:0] bldis_timer_config, // (I) BLDIS_CONFIG_REG: pulse width for BLDIS (READ)

  // Readback to Register Array i/f
  output wire [4:0]  fsm_state,          // (O) STATUS_REG bit
  output wire        mip,                // (O) STATUS_REG bit
  output reg         rip,                // (O) STATUS_REG bit
  output reg         wip,                // (O) STATUS_REG bit
  output reg         fip,                // (O) STATUS_REG bit
  output reg         fsm_error_flag,     // (O) STATUS REG bit

  output wire [16:0] failed_address,     // (O) DIAGNOSTIC1_REG bit
  output wire [3:0]  failed_bank,        // (O) DIAGNOSTIC1_REG bit

  output reg  [1:0]  failed_operation,   // (O) DIAGNOSTIC2_REG bit
  output reg  [15:0] failed_data_bits,   // (O) DIAGNOSTIC2_REG bit

  output reg  [16:0] set_error_count,    // (O) DIAGNOSTIC3_REG bit

  output reg  [16:0] rst_error_count,    // (O) DIAGNOSTIC4_REG bit

  // Direct Access Port i/f...
  input              da_byp,             // (I) Direct access BYPASS mode (overrides FSM control)
  input              da_man,             // (I) Direct access MANUAL mode (allows user-adjustment of rram voltage levels)
  input              da_aclk,            // (I) Direct access strobe for direct RRAM access
  input              da_en,              // (I) Direct access enable rram access
  input              da_bldis,           // (I) Direct access bit-line discharge control
  input              da_set_form,        // (I) Direct access access type - WRITE (SET) or FORM
  input              da_set_rst,         // (I) Direct access WRITE type - SET or RESET
  input              da_read_mode,       // (I) Direct access READ type (normal/verify)
  input              da_we,              // (I) Direct access rram write enable

  input       [3:0]  da_banksel,         // (I) Direct access rram bank selector
  input       [16:0] da_addr,            // (I) Direct access rram address

  input       [15:0] da_di,              // (I) Direct access rram write data mask
  output reg         di_req_o,           // (O) fsm request for input
  input              in_ack_i,           // (I) Direct access acknowledge of DI_REQ

  output reg  [15:0] da_do,              // (O) Direct access rram read data
  output reg         do_valid_o,         // (O) fsm valid indicator for DO
  input              out_ack_i,          // (I) Direct access acknowledge of DO_VALID

  input              da_sa_en,           // (I) Direct access readout circuit enable
  input              da_sa_clk,          // (I) Direct access readout circuit clock
  output wire        sa_rdy_o,           // (I) Direct access readout circuit ready indicator

  // rram read data holding register...  
  output reg  [15:0] rram_do_hold,       // (O) rram_do bits, via holding register
  output reg         rram_do_full,       // (O) indicator that rram read data is present in holding reg
  input              data_out_read,      // (I) indicator that SPI read from DATA_OUT register occurred

  // rram signal i/f...
  output reg         rram_man,           // (O) Manual mode indicator
  output reg         rram_aclk,          // (O) rram strobe
  output reg  [8:0]  rram_en,            // (O) rram enable, 1-hot-zero encoded
  output reg         rram_bldis,         // (O) rram bit-line discharge control
  output reg         rram_set_form,      // (O) rram access type - WRITE (SET) or FORM
  output reg         rram_set_rst,       // (O) rram WRITE  type - SET or RESET
  output reg         rram_read_mode,     // (O) rram WRITE  type - SET or RESET
  output reg         rram_we,            // (O) rram write enable
  output reg  [16:0] rram_addr,          // (O) rram address
  output reg  [15:0] rram_di_mask,       // (O) rram data input mask

  output reg         rram_sa_en,         // (O) rram readout circuit enable
  output reg         rram_sa_clk,        // (O) rram readout circuit clock
  input              rram_sa_rdy,        // (I) rram readout circuit ready indicator

  input       [15:0] rram_do             // (I) rram data output from rram bank mux

  );

// FSM States...
localparam FSM_IDLE      = 5'h00;

localparam SR_SETUP      = 5'h01;
localparam SR_SIG        = 5'h02;
localparam SR_EN         = 5'h03;
localparam SR_ACLK_PLS   = 5'h04;
localparam SR_ACLK_DONE  = 5'h05;
localparam SR_EN_DONE    = 5'h06;
localparam SR_SIG_DONE   = 5'h07;

localparam BLDIS_PLS     = 5'h08;
localparam BLDIS_DONE    = 5'h09;
localparam READ_ADDR     = 5'h0A;
localparam READ_ENBL     = 5'h0B;
localparam READ_START    = 5'h0C;
localparam READ_DONE     = 5'h0D;

localparam READOUT_STALL = 5'h0E;
localparam WAIT_IN_ACK   = 5'h0F;

localparam PUSH_SETERR   = 5'h10;
localparam PUSH_RSTERR   = 5'h11;
localparam PUSH_DONE     = 5'h12;

localparam MAN_WAIT      = 5'h13;

localparam FSM_ERROR     = 5'h14;

// OP Codes...
localparam OP_IDLE   = 3'h0;
localparam OP_FORM   = 3'h1;
localparam OP_WRITE  = 3'h2;
localparam OP_READ   = 3'h3;
localparam OP_MAN    = 3'h4;
localparam OP_SET    = 3'h5;
localparam OP_RST    = 3'h6;
localparam OP_RDVER  = 3'h7;

localparam LAST_ADDR = 17'h1_1FFF;

localparam CHKBD0     = 3'h0;
localparam CHKBD1     = 3'h1;
localparam CHKBD2     = 3'h2;
localparam CHKBD3     = 3'h3;
localparam CHKBDEVEN  = 3'h4;
localparam CHKBDODD   = 3'h5;
localparam DATAEQADDR = 3'h6;

reg  [2:0]  fsm_go_sync;
wire        fsm_go_event;

reg  [4:0]  curr_state, next_state;

reg  [8:0]  da_en_1hot;

reg         fsm_man, next_fsm_man;
reg         fsm_en, next_fsm_en;
wire [8:0]  fsm_en_1hot;
reg         fsm_aclk, next_fsm_aclk;
reg         fsm_bldis, next_fsm_bldis;
reg         fsm_set_form, next_fsm_set_form;
reg         fsm_set_rst, next_fsm_set_rst;
reg         fsm_read_mode, next_fsm_read_mode;
reg         fsm_we, next_fsm_we;
wire [16:0] fsm_addr;
reg  [15:0] fsm_di, next_fsm_di;
reg         fsm_sa_en, next_fsm_sa_en;
wire        fsm_sa_clk;
reg         next_fsm_error_flag;
reg         next_fip, next_wip, next_rip;
reg         first_verify, next_first_verify;
reg         set_only, next_set_only;
reg         rst_only, next_rst_only;
reg         first_force, next_first_force;
reg         op_multi;
wire        op_multi_done;

reg  [2:0]  rram_sa_rdy_sync;
wire        rram_sa_rdy_detect;
reg         load_rram_do_hold;
wire        unload_rram_do_hold;
reg  [2:0]  data_out_read_sync;
wire        data_out_read_event;
reg  [2:0]  out_ack_i_sync;
wire        out_ack_assert;  
wire        out_ack_deassert;  
reg  [2:0]  in_ack_i_sync;
wire        in_ack_assert;  
wire        in_ack_deassert;  
reg         assert_di_req;

reg         load_init, load_next;
wire [16:0] addr_in_lim, da_addr_in_lim;
reg  [16:0] init_addrgen, next_addrgen, last_addrgen, addrgen;
reg  [17:0] addr_plus_offset;
reg  [15:0] init_wdatagen, next_wdatagen, wdatagen;
wire [15:0] muxed_data_in;
reg         hybrid_in;

reg         load_tmr;
reg  [16:0] load_tmr_val;
reg  [16:0] shared_tmr;

reg         load_ctr;
reg  [5:0]  load_ctr_val;
reg  [5:0]  shared_ctr;

reg  [15:0] set_data_mask, i_set_data_mask, next_set_data_mask;
reg  [15:0] rst_data_mask, i_rst_data_mask, next_rst_data_mask;
reg         load_mask;

reg         clear_error_counters;
reg         incr_set_err, incr_rst_err;
reg  [5:0]  set_retry_count, rst_retry_count;
reg         clear_retry_counters;
reg         incr_set_retry, incr_rst_retry;
wire        set_error, rst_error;
wire        do_set, do_rst;
wire        do_set_retry, do_rst_retry;
reg         write_op, next_write_op;

wire        start_sa_clk;
reg  [1:0]  start_sa_cnt;
reg  [3:0]  sa_clk_shreg;
reg  [1:0]  sa_clk_count;
reg         sa_clk_shift;

reg         skip_set, skip_rst;

// =================================
// RRAM data out holding register...
// =================================
// The holding register is necessary only for FSM controlled operations.
//
// In BYPASS mode, the readout circuit handshake signal "sa_rdy" indicates
//  data is valid on DO, and user-control of the Direct Access Port can assure
//  that DO is captured by the external equipment, so the holding register
//  is bypasseed.
// 
// A "full flag" indicates that the FSM has placed readback data into the holding
//  register. There are two ways to offload the holding register.
//
//    1. SPI reads DATA_OUT_REG: The full flag is made available to SPI as a STATUS_REG bit.
//        it is presumed that SPI verifies there is data to be offloaded by doing STATUS_REG
//        read first. Then, a DATA_OUT_REG read will cause the full flag to reset.
//
//    2. Direct Access in HYBRID mode offload: full flag assertion kicks off an asynchronous
//        handshake protocol with the direct access port, pins DO, DO_VALID, and OUT_ACK.
//        Detection of the de-assertion of OUT_ACK indicates external equipment has offloaded
//        the data, and the full flag is reset.
//
// The full flag serves as a means to stall the FSM - if the FSM continues on and does another
//  READ command, but the previous read data hasn't been offloaded (full flag = 1), the FSM
//  stalls.
//
// The FSM only loads the holding register in response to a READ opcode. The interim
//  "VERIFY" accesses performed during FORM or WRITE opcodes do *not* put data
//  into this holding register...
//
// For Direct Access in MANUAL mode, it is not possible to read values from RRAM.

// Sync/detect of rram_sa_rdy - this tells us when data is valid...
always @(posedge fsm_clk or negedge fsm_rst_n)
  begin
    if (!fsm_rst_n)
      begin
        rram_sa_rdy_sync <= 3'b000;
      end
    else
      begin
        rram_sa_rdy_sync <= {rram_sa_rdy_sync[1:0], rram_sa_rdy};
      end
  end

assign rram_sa_rdy_detect = (~rram_sa_rdy_sync[2] & rram_sa_rdy_sync[1]);

// holding reg...
always @(posedge fsm_clk or negedge fsm_rst_n)
  begin
    if (!fsm_rst_n)
      begin
        rram_do_hold <= 16'h0000;
        rram_do_full <= 1'b0;
      end
    else
     begin
        if (load_rram_do_hold)        // LOAD is controlled by FSM.
          begin                       //  LOAD can have precedence over UNLOAD if they
            rram_do_hold <= rram_do;  //  occur concurrently. FSM will prevent overwrite
            rram_do_full <= 1'b1;     //  of data not yet read from this register...
          end
        else
          begin
            if (unload_rram_do_hold)  // UNLOAD is controlled by (sync'd to MCLK) detection
              begin                   //  of either data_out_read OR out_ack_i...
                rram_do_full <= 1'b0;
              end
          end
      end
  end

// unload detect...
always @(posedge fsm_clk or negedge fsm_rst_n)
  begin
    if (!fsm_rst_n)
      begin
        data_out_read_sync <= 3'b000;
        out_ack_i_sync     <= 3'b000;
      end
    else
      begin
        data_out_read_sync[2:0] <= {data_out_read_sync[1:0], data_out_read};
        out_ack_i_sync[2:0]     <= {out_ack_i_sync[1:0], out_ack_i};
      end
  end

assign data_out_read_event = data_out_read_sync[2] ^ data_out_read_sync[1]; // data_out_read is a toggle signal, so detect *any* edge...

assign out_ack_assert      = ~out_ack_i_sync[2] & out_ack_i_sync[1];
assign out_ack_deassert    = out_ack_i_sync[2] & ~out_ack_i_sync[1];

// Wait for de-assertion of out_ack, or a SPI read of DATA_OUT_REG to reset full flag.
//  This will reset the rram_do_full flag, and unstall the FSM...
assign unload_rram_do_hold = rdata_dest ? out_ack_deassert : data_out_read_event;

// do_valid handshake generation...
always @(posedge fsm_clk or negedge fsm_rst_n)
  begin
    if (!fsm_rst_n)
      begin
        do_valid_o <= 1'b0;
      end
    else
      begin
        if (rdata_dest && load_rram_do_hold)  // Only drive handshake signaling if rdata_dest is for DO pins...
          begin
            do_valid_o <= 1'b1;
          end
        else
          begin
            if (out_ack_assert)               // The assertion of out_ack causes the de-assertion of do_valid...
              begin
                do_valid_o <= 1'b0;
              end
          end 
      end
  end

assign da_do = da_byp ? rram_do : rram_do_hold;

// ==============================
// Hybrid Mode Input Handshake...
// ==============================
//  addr_source or wdata_source from Direct Access Port requires a full 2-way async handshake...

always @(posedge fsm_clk or negedge fsm_rst_n)
  begin
    if (!fsm_rst_n)
      begin
        in_ack_i_sync <= 3'b000;
        di_req_o      <= 1'b0;
      end
    else
      begin
        in_ack_i_sync[2:0] <= {in_ack_i_sync[1:0], in_ack_i};

        if (assert_di_req)     // FSM starts the handshake...
          begin
            di_req_o <= 1'b1;
          end
        else
          begin
            if (in_ack_assert) // The assertion of in_ack causes the de-assertion of di_req...
              begin
                di_req_o <= 1'b0;
              end
          end
      end
  end

assign in_ack_assert   = ~in_ack_i_sync[2] & in_ack_i_sync[1];
assign in_ack_deassert = in_ack_i_sync[2] & ~in_ack_i_sync[1]; // The de-assertion of in_ack un-stalls the FSM...

// =========================
// State Machine: kickoff...
// =========================
always @(posedge fsm_clk or negedge fsm_rst_n)
  begin
    if (!fsm_rst_n)
      begin
        fsm_go_sync <= 3'b000;
      end
    else
      begin
        fsm_go_sync[2:0] <= {fsm_go_sync[1:0], fsm_go};
      end
  end

// fsm_go is a toggle signal, so detect *any* edge...
assign fsm_go_event = fsm_go_sync[2] ^ fsm_go_sync[1];

// ==================================
// State Machine: Next State Logic...
// ==================================
always @*
  begin
    // stored signal initialization...
    next_state = curr_state;

    next_fsm_man       = fsm_man;
    next_fsm_en        = fsm_en;
    next_fsm_aclk      = fsm_aclk;
    next_fsm_bldis     = fsm_bldis;
    next_fsm_set_form  = fsm_set_form;
    next_fsm_set_rst   = fsm_set_rst;
    next_fsm_read_mode = fsm_read_mode;
    next_fsm_we        = fsm_we;
    next_fsm_di        = fsm_di;
    next_fsm_sa_en     = fsm_sa_en;

    next_fip           = fip;
    next_wip           = wip;
    next_rip           = rip;

    next_fsm_error_flag = fsm_error_flag;

    next_first_verify  = first_verify;
    next_set_only      = set_only;
    next_rst_only      = rst_only;
    next_write_op      = write_op;
    next_first_force   = first_force;

    // combinational signal initialization...
    assert_di_req = 1'b0;     // Hybrid mode request for input

    load_init     = 1'b0;       // Initialize address, wdata
    load_next     = 1'b0;       // Update address, wdata
    load_mask     = 1'b0;       // Update data masks
    load_tmr      = 1'b0;       // Load the shared timer
    load_tmr_val  = 17'h0_0000; // Value to load

    clear_error_counters = 1'b0; // Reset both error counters
    incr_set_err         = 1'b0; // Increment set error count
    incr_rst_err         = 1'b0; // Increment reset error count

    clear_retry_counters = 1'b0; // Reset both retry counters
    incr_set_retry       = 1'b0; // Increment set retry count
    incr_rst_retry       = 1'b0; // Increment reset retry count

    load_rram_do_hold = 1'b0; // READ command capture returned data
    diag_push     = 1'b0;     // Diagnostic FIFO push enable

    failed_operation = 2'b11;
    failed_data_bits = 16'h0000;

    case (curr_state)
      // ========
      FSM_IDLE :   // Wait for kickoff signal, decode the op code...
        begin
          if (fsm_go_event)
            begin
              clear_error_counters = 1'b1; // Always reset the error and retry counters coming
              clear_retry_counters = 1'b1; //  out of IDLE...

              case (clu_op_code)
                // ========
                OP_IDLE :
                  begin
                    next_state = FSM_IDLE;
                  end
                // ========
                OP_FORM : 
                  begin
                    next_state         = BLDIS_PLS;          // 1st time through always starts with BLDIS...
                    next_fip           = 1'b1;               // Indicate FORM-IN-PROGRESS...
                    next_fsm_bldis     = 1'b1;               // Assert BLDIS pulse...
                    next_fsm_we        = 1'b0;
                    next_fsm_set_form  = 1'b0;
                    next_fsm_set_rst   = 1'b0;
                    next_fsm_read_mode = 1'b1;               // VERIFY indicator
                    next_first_verify  = 1'b1;

                    load_tmr           = 1'b1;               // Load the shared timer with
                    load_tmr_val       = bldis_timer_config; //  BLDIS pulse width value...

                    if (hybrid_in)            // Hybrid Mode needs to retrieve inputs from DA Port...
                      begin                   // Get a jump on retrieving the initial ADDR
                        assert_di_req = 1'b1; //  while the BLDIS pulse is being applied...
                      end
                  end
                // ========
                OP_WRITE :
                  begin
                    next_state         = BLDIS_PLS;          // 1st time through always starts with BLDIS...
                    next_wip           = 1'b1;               // Indicate WRITE-IN-PROGRESS...
                    next_fsm_bldis     = 1'b1;               // Assert BLDIS pulse...
                    next_fsm_we        = 1'b0;
                    next_fsm_set_form  = 1'b0;
                    next_fsm_set_rst   = 1'b0;
                    next_fsm_read_mode = 1'b1;               // VERIFY indicator
                    next_first_verify  = 1'b1;

                    load_tmr           = 1'b1;               // Load the shared timer with
                    load_tmr_val       = bldis_timer_config; //  BLDIS pulse width value...

                    if (hybrid_in)            // Hybrid Mode needs to retrieve inputs from DA Port...
                      begin                   // Get a jump on retrieving the initial ADDR, WDATA
                        assert_di_req = 1'b1; //  while the BLDIS pulse is being applied...
                      end
                  end
                // ========
                OP_READ :
                  begin
                    next_state         = BLDIS_PLS;          // 1st time through always starts with BLDIS...
                    next_rip           = 1'b1;               // Indicate READ-IN-PROGRESS...
                    next_fsm_bldis     = 1'b1;               // Assert BLDIS pulse...
                    next_fsm_we        = 1'b0;
                    next_fsm_set_form  = 1'b0;
                    next_fsm_set_rst   = 1'b0;
                    next_fsm_read_mode = 1'b0;               // READ indicator
                    next_first_verify  = 1'b1;

                    load_tmr           = 1'b1;               // Load the shared timer with
                    load_tmr_val       = bldis_timer_config; //  BLDIS pulse width value...

                    if (hybrid_in)            // Hybrid Mode needs to retrieve inputs from DA Port...
                      begin                   // Get a jump on retrieving the initial ADDR
                        assert_di_req = 1'b1; //  while the BLDIS pulse is being applied...
                      end
                  end
                // ========
                OP_MAN, OP_SET :    // Both of these states create the signaling for a
                  begin             //  SET operation...
                    next_fsm_man  = (clu_op_code == OP_MAN);

                    next_wip      = (clu_op_code == OP_MAN) | ~force_set_type;
                    next_fip      = (clu_op_code != OP_MAN) & force_set_type;

                    next_first_verify = 1'b1;

                    if (hybrid_in)
                      begin
                        next_state       = WAIT_IN_ACK; // Need to wait for hybrid mode inputs...
                        next_first_force = 1'b1;
                        assert_di_req    = 1'b1;
                      end
                    else
                      begin
                        next_state    = SR_SETUP;
                        load_init     = 1'b1;          // Load the ADDR and WDATA..
                        next_fsm_di   = set_data_mask; // Apply the SET mask...
                        next_set_only = 1'b1;
                        next_rst_only = 1'b0;
                      end
                  end
                // ========
                OP_RST :
                  begin
                    next_wip          = 1'b1;
                    next_first_verify = 1'b1;

                    if (hybrid_in)
                      begin
                        next_state       = WAIT_IN_ACK; // Need to wait for hybrid mode inputs...
                        next_first_force = 1'b1;
                        assert_di_req    = 1'b1;
                      end
                    else
                      begin
                        next_state    = SR_SETUP;
                        load_init     = 1'b1;          // Load the ADDR and WDATA..
                        next_fsm_di   = rst_data_mask; // Apply the RST mask...
                        next_set_only = 1'b0;
                        next_rst_only = 1'b1;
                      end
                  end
                // ========
                OP_RDVER :
                  begin
                    next_state         = BLDIS_PLS;          // 1st Force VERIFY always starts with BLDIS...
                    next_fsm_bldis     = 1'b1;               // Assert BLDIS pulse...
                    next_fsm_we        = 1'b0;
                    next_fsm_set_form  = 1'b0;
                    next_fsm_set_rst   = 1'b0;
                    next_fsm_read_mode = 1'b1;               // VERIFY indicator
                    next_first_verify  = 1'b1;
                    next_wip           = 1'b1;               // FORCE VERIFY is actually a sub-task
                                                             //  of a WRITE...
                    load_tmr           = 1'b1;               // Load the shared timer with
                    load_tmr_val       = bldis_timer_config; //  BLDIS pulse width value...

                    if (hybrid_in)            // Hybrid Mode needs to retrieve inputs from DA Port...
                      begin                   // Get a jump on retrieving the initial ADDR, WDATA
                        assert_di_req = 1'b1; //  while the BLDIS pulse is being applied...
                      end
                  end
              endcase
            end
        end
      // ========
      BLDIS_PLS : // Assert the bldis pulse...
        begin
          if (fsm_go_event)             // Illegal user write to CONTROL_REG...
            begin
              next_state          = FSM_ERROR;
              next_fsm_man        = 1'b0;
              next_fsm_en         = 1'b0;
              next_fsm_aclk       = 1'b0;
              next_fsm_bldis      = 1'b0;
              next_fsm_set_form   = 1'b0;
              next_fsm_set_rst    = 1'b0;
              next_fsm_read_mode  = 1'b0;
              next_fsm_we         = 1'b0;
              next_fsm_sa_en      = 1'b0;
              next_fip            = 1'b0;
              next_wip            = 1'b0;
              next_rip            = 1'b0;
              next_fsm_error_flag = 1'b1;
              next_first_verify   = 1'b0;
              next_write_op       = 1'b0;
              next_set_only       = 1'b0;
              next_rst_only       = 1'b0;
            end
          else
            begin
              if (shared_tmr == 17'h0_0001)    // The shared timer is a down-counter - pulse is done
                begin                          //  when timer value gets to '1'...
                  next_state     = BLDIS_DONE;
                  next_fsm_bldis = 1'b0;
                end
            end
        end
      // ========
      BLDIS_DONE : // De-assert bldis for 1 cycle before moving on...
        begin  
          if (fsm_go_event)             // Illegal user write to CONTROL_REG...
            begin
              next_state          = FSM_ERROR;
              next_fsm_man        = 1'b0;
              next_fsm_en         = 1'b0;
              next_fsm_aclk       = 1'b0;
              next_fsm_bldis      = 1'b0;
              next_fsm_set_form   = 1'b0;
              next_fsm_set_rst    = 1'b0;
              next_fsm_read_mode  = 1'b0;
              next_fsm_we         = 1'b0;
              next_fsm_sa_en      = 1'b0;
              next_fip            = 1'b0;
              next_wip            = 1'b0;
              next_rip            = 1'b0;
              next_fsm_error_flag = 1'b1;
              next_first_verify   = 1'b0;
              next_write_op       = 1'b0;
              next_set_only       = 1'b0;
              next_rst_only       = 1'b0;
            end
          else
            begin
              if (first_verify)        // About to present ADDR and WDATA: if the source is
                begin                  //  from DA Port (Hybrid mode), be sure it is valid...
                  if (hybrid_in)       
                    begin
                      if (!di_req_o)  // di_req_o was asserted prior to going into this state - it can only
                                      //  get de-asserted if we had a valid IN_ACK...
                        begin
                          next_state  = READ_ADDR;     // A READ always follows a BLDIS...
                          load_init   = 1'b1;          // Load the initial address and wdata
                          next_fsm_di = init_wdatagen; // * for VERIFY, need to provide the write data!
                        end
                    end
                  else                                 // Non-hybrid mode, address and wdata all set to go...
                    begin
                      next_state  = READ_ADDR;        // A READ always follows a BLDIS...
                      load_init   = 1'b1;             // Load the initial address and wdata
                      next_fsm_di = init_wdatagen;    // * for VERIFY, need to provide the write data!
                    end
                end
              else                     // not first_verify, don't reload new address or wdata,
                begin                  //  but DO re-assert the current wdata onto fsm_di...
                  next_state  = READ_ADDR;
                  next_fsm_di = wdatagen;             // * for VERIFY, need to provide the write data!
                end
            end
        end
      // ========
      READ_ADDR : // Address setup phase for 1 cycle before moving on, OR stall if rram_do_hold is full...
        begin
          if (fsm_go_event)             // Illegal user write to CONTROL_REG...
            begin
              next_state          = FSM_ERROR;
              next_fsm_man        = 1'b0;
              next_fsm_en         = 1'b0;
              next_fsm_aclk       = 1'b0;
              next_fsm_bldis      = 1'b0;
              next_fsm_set_form   = 1'b0;
              next_fsm_set_rst    = 1'b0;
              next_fsm_read_mode  = 1'b0;
              next_fsm_we         = 1'b0;
              next_fsm_sa_en      = 1'b0;
              next_fip            = 1'b0;
              next_wip            = 1'b0;
              next_rip            = 1'b0;
              next_fsm_error_flag = 1'b1;
              next_first_verify   = 1'b0;
              next_write_op       = 1'b0;
              next_set_only       = 1'b0;
              next_rst_only       = 1'b0;
            end
          else
            begin
              next_state  = READ_ENBL;  // The address is being applied, next assert the enable...
              next_fsm_en = 1'b1;

              // KA: need to hold READ_ENBL state for 4 MCLK cycles to meet RRAM TenHIseHI timing...
              // KA: 4 MCLK cycles (80ns) too tight for 78ns requirement - physical design, clock skew, etc. Add another cycle...
              load_tmr     = 1'b1;       // Load the shared timer...
              load_tmr_val = 17'h0_0004; // 5 total MCLK cycle wait states in state SR_EN...

            end
        end
      // ========
      READ_ENBL : // Enable setup phase for 1 cycle before moving on...
        begin
          if (fsm_go_event)             // Illegal user write to CONTROL_REG...
            begin
              next_state          = FSM_ERROR;
              next_fsm_man        = 1'b0;
              next_fsm_en         = 1'b0;
              next_fsm_aclk       = 1'b0;
              next_fsm_bldis      = 1'b0;
              next_fsm_set_form   = 1'b0;
              next_fsm_set_rst    = 1'b0;
              next_fsm_read_mode  = 1'b0;
              next_fsm_we         = 1'b0;
              next_fsm_sa_en      = 1'b0;
              next_fip            = 1'b0;
              next_wip            = 1'b0;
              next_rip            = 1'b0;
              next_fsm_error_flag = 1'b1;
              next_first_verify   = 1'b0;
              next_write_op       = 1'b0;
              next_set_only       = 1'b0;
              next_rst_only       = 1'b0;
            end
          else if (shared_tmr == 17'h0_0000)    // The shared timer is an automatic  down-counter...
            begin
              next_state     = READ_START;  // The enable is being applied, next assert readout enable
              next_fsm_sa_en = 1'b1;
            end
        end
      // ========
      READ_START : // Readout logic enabled, waiting for data...
        begin
          if (fsm_go_event)             // Illegal user write to CONTROL_REG...
            begin
              next_state          = FSM_ERROR;
              next_fsm_man        = 1'b0;
              next_fsm_en         = 1'b0;
              next_fsm_aclk       = 1'b0;
              next_fsm_bldis      = 1'b0;
              next_fsm_set_form   = 1'b0;
              next_fsm_set_rst    = 1'b0;
              next_fsm_read_mode  = 1'b0;
              next_fsm_we         = 1'b0;
              next_fsm_sa_en      = 1'b0;
              next_fip            = 1'b0;
              next_wip            = 1'b0;
              next_rip            = 1'b0;
              next_fsm_error_flag = 1'b1;
              next_first_verify   = 1'b0;
              next_write_op       = 1'b0;
              next_set_only       = 1'b0;
              next_rst_only       = 1'b0;
            end
          else if (rram_sa_rdy_detect)     // 0->1 transition (re-assert RDY) is detected...
            begin
              if (((clu_op_code == OP_RDVER) || // A single RDVER operation or a normal READ
                    !fsm_read_mode) &&          //  will need to put readout data into the rram_do
                     rram_do_full)              //  holding register. Stall FSM if that register
                begin                                //  is FULL...
                  next_state = READOUT_STALL;
                end
              else
                begin
                  next_state     = READ_DONE;  // The read is complete...
                  next_fsm_sa_en = 1'b0;       // De-assert readout enable

                  if (clu_op_code == OP_RDVER)
                    begin
                      load_rram_do_hold = 1'b1;  // For single RDVER operation, return the readout
                    end                          //  data, don't bother loading the auto-
                  else                           //  calculated masks...
                    begin
                      load_mask         = fsm_read_mode;  // Calculate data masks and store them (VERIFY) OR
                      load_rram_do_hold = ~fsm_read_mode; //  capture readout data in holding reg (READ)...
                    end 
                end
            end
        end
      // ========
      READ_DONE : // This state is where a lot of decisions must happen...
        begin
          if (fsm_go_event)             // Illegal user write to CONTROL_REG...
            begin
              next_state          = FSM_ERROR;
              next_fsm_man        = 1'b0;
              next_fsm_en         = 1'b0;
              next_fsm_aclk       = 1'b0;
              next_fsm_bldis      = 1'b0;
              next_fsm_set_form   = 1'b0;
              next_fsm_set_rst    = 1'b0;
              next_fsm_read_mode  = 1'b0;
              next_fsm_we         = 1'b0;
              next_fsm_sa_en      = 1'b0;
              next_fip            = 1'b0;
              next_wip            = 1'b0;
              next_rip            = 1'b0;
              next_fsm_error_flag = 1'b1;
              next_first_verify   = 1'b0;
              next_write_op       = 1'b0;
              next_set_only       = 1'b0;
              next_rst_only       = 1'b0;
            end
          else
            begin
              case (clu_op_code)
            // ========
                OP_FORM, OP_WRITE :
                  begin
                    if (do_set && (first_verify ||     // The VERIFY determined bits need to be SET...
                        (set_retry_count < set_retry_limit)))  // More retries left...
                      begin
                        next_state     = SR_SETUP;
                        next_fsm_en    = 1'b0;           // de-assert EN...
                        next_fsm_di    = set_data_mask;
                        next_write_op  = 1'b1;
                        incr_set_retry = do_set_retry;  // SET is because it is a retry - increment set_retry_count

                        // KA: SET goes first, but need to know whether a RESET retry will be attempted
                        //      as well...
                        if (do_rst && (first_verify ||// The VERIFY determined bits need to be RESET...
                            (rst_retry_count < reset_retry_limit))) // More retries left...
                          begin
                            incr_rst_retry = do_rst_retry;  // RESET is because it is a retry - increment rst_retry_count
                          end
                      end
                    else if (do_rst && (first_verify ||// The VERIFY determined bits need to be RESET...
                        (rst_retry_count < reset_retry_limit))) // More retries left...
                      begin
                        next_state     = SR_SETUP;
                        next_fsm_en    = 1'b0;           // de-assert EN...
                        next_fsm_di    = rst_data_mask;
                        next_write_op  = 1'b0;
                        incr_rst_retry = do_rst_retry;  // RESET is because it is a retry - increment rst_retry_count
                      end
                    else if (set_error || rst_error)  // The VERIFY determined bits need to be
                      begin                           //  set or reset but all out of retries...
                        next_state = PUSH_SETERR;
                        clear_retry_counters = 1'b1;
                      end
                    else               // The VERIFY determined success...
                      begin
                        clear_retry_counters = 1'b1;

                        if (op_multi && !op_multi_done)   // Muliple access loop, do another
                          begin                           //  "first_verify" with a new address...
                            if (hybrid_in)
                              begin
                                next_state    = WAIT_IN_ACK; // Need to wait for hybrid mode inputs...
                                assert_di_req = 1'b1;
                              end
                            else
                              begin
                                next_state        = READ_ADDR;
                                next_first_verify = 1'b1;
                                load_next         = 1'b1;
                                next_fsm_di       = next_wdatagen; // * for VERIFY, need to provide the write data!
                              end
                          end
                        else                              // Truly all done...
                          begin
                            next_state         = FSM_IDLE;
                            next_fsm_en        = 1'b0;
                            next_fsm_set_form  = 1'b0;
                            next_fsm_set_rst   = 1'b0;
                            next_fsm_read_mode = 1'b0;
                            next_fip           = 1'b0;
                            next_wip           = 1'b0;
                          end
                      end
                  end
                // ========
                OP_READ, OP_RDVER :   // A READ and FORCE VERIFY are similar, and can loop...
                  begin
                    if (op_multi && !op_multi_done)   // multi-read, still more to go...
                      begin
                        if (hybrid_in)                // Need to wait for hybrid mode inputs...
                          begin
                            next_state    = WAIT_IN_ACK;
                            assert_di_req = 1'b1;
                          end
                        else
                          begin
                            next_state        = READ_ADDR;
                            next_first_verify = 1'b1;
                            load_next         = 1'b1;
                          end
                      end
                    else                              // single read, or multi-read is all done...
                      begin
                        next_state         = FSM_IDLE;
                        next_fsm_en        = 1'b0;
                        next_fsm_read_mode = 1'b0;
                        next_wip           = 1'b0;    // FORCE VERIFY was actually a WRITE...
                        next_rip           = 1'b0;
                      end
                  end
                // ========
                default :    // We should not ever get to this state with any of the other op codes!
                  begin
                    next_state          = FSM_ERROR;
                    next_fsm_man        = 1'b0;
                    next_fsm_en         = 1'b0;
                    next_fsm_aclk       = 1'b0;
                    next_fsm_bldis      = 1'b0;
                    next_fsm_set_form   = 1'b0;
                    next_fsm_set_rst    = 1'b0;
                    next_fsm_read_mode  = 1'b0;
                    next_fsm_we         = 1'b0;
                    next_fsm_sa_en      = 1'b0;
                    next_fip            = 1'b0;
                    next_wip            = 1'b0;
                    next_rip            = 1'b0;
                    next_fsm_error_flag = 1'b1;
                    next_first_verify   = 1'b0;
                    next_write_op       = 1'b0;
                    next_set_only       = 1'b0;
                    next_rst_only       = 1'b0;
                  end
              endcase
            end
        end
      // ========
      READOUT_STALL : // Waiting for rram_do holding reg to be offloaded before completing current read...
        begin
          if (fsm_go_event)             // Illegal user write to CONTROL_REG...
            begin
              next_state          = FSM_ERROR;
              next_fsm_man        = 1'b0;
              next_fsm_en         = 1'b0;
              next_fsm_aclk       = 1'b0;
              next_fsm_bldis      = 1'b0;
              next_fsm_set_form   = 1'b0;
              next_fsm_set_rst    = 1'b0;
              next_fsm_read_mode  = 1'b0;
              next_fsm_we         = 1'b0;
              next_fsm_sa_en      = 1'b0;
              next_fip            = 1'b0;
              next_wip            = 1'b0;
              next_rip            = 1'b0;
              next_fsm_error_flag = 1'b1;
              next_first_verify   = 1'b0;
              next_write_op       = 1'b0;
              next_set_only       = 1'b0;
              next_rst_only       = 1'b0;
            end
          else if (!rram_do_full)
            begin
              next_state     = READ_DONE;  // The read is complete...
              next_fsm_sa_en = 1'b0;       // De-assert readout enable

              if (clu_op_code == OP_RDVER)
                begin
                  load_rram_do_hold = 1'b1;  // For single RDVER operation, return the readout
                end                          //  data, don't bother loading the auto-
              else                           //  calculated masks...
                begin
                  load_mask         = fsm_read_mode;  // Calculate data masks and store them (VERIFY) OR
                  load_rram_do_hold = ~fsm_read_mode; //  capture readout data in holding reg (READ)...
                end 
            end
        end
      // ========
      WAIT_IN_ACK :
        begin
          if (fsm_go_event)             // Illegal user write to CONTROL_REG...
            begin
              next_state          = FSM_ERROR;
              next_fsm_man        = 1'b0;
              next_fsm_en         = 1'b0;
              next_fsm_aclk       = 1'b0;
              next_fsm_bldis      = 1'b0;
              next_fsm_set_form   = 1'b0;
              next_fsm_set_rst    = 1'b0;
              next_fsm_read_mode  = 1'b0;
              next_fsm_we         = 1'b0;
              next_fsm_sa_en      = 1'b0;
              next_fip            = 1'b0;
              next_wip            = 1'b0;
              next_rip            = 1'b0;
              next_fsm_error_flag = 1'b1;
              next_first_verify   = 1'b0;
              next_write_op       = 1'b0;
              next_set_only       = 1'b0;
              next_rst_only       = 1'b0;
            end
          else
            begin
              if (!di_req_o)  // di_req_o was asserted prior to going into this state - it can only
                              //  get de-asserted if we had a valid IN_ACK...

                begin  // KA: there is now another way into this state - OP_SET
                       //  or OP_RST looping! In which case, we have to assert load_next
                       //  instead of load_init. Added control signal "first_force"...

                  case (clu_op_code)
                    OP_MAN, OP_SET :
                      begin
                        next_state        = SR_SETUP;
                        next_first_verify = 1'b1;
                        load_init         = first_force;   // Load the Initial ADDR and WDATA..
                        load_next         = ~first_force;  // Load the Next ADDR and WDATA..
                        next_fsm_di       = set_data_mask; // Apply the SET mask...
                        next_set_only     = 1'b1;
                        next_rst_only     = 1'b0;
                        next_first_force  = 1'b0;
                      end
                    OP_RST :
                      begin
                        next_state        = SR_SETUP;
                        next_first_verify = 1'b1;
                        load_init         = first_force;   // Load the Initial ADDR and WDATA..
                        load_next         = ~first_force;  // Load the Next ADDR and WDATA..
                        next_fsm_di       = rst_data_mask; // Apply the RST mask...
                        next_set_only     = 1'b0;
                        next_rst_only     = 1'b1;
                        next_first_force  = 1'b0;
                      end
                    default :
                      begin
                        next_state        = READ_ADDR;     // A READ is the next thing to do (skip BLDIS)
                        next_first_verify = 1'b1;          // If this is a VERIFY, it is the first one w/ next addr
                        load_next         = 1'b1;          // Load the next address and/or wdata
                        next_fsm_di       = next_wdatagen; // * for VERIFY, need to provide the write data!
                      end
                  endcase
                end
            end
        end
      // ========
      SR_SETUP :  // First SET or FORCE SET or FORCE RESET: the EN signal
        begin     //  is de-asserted in this state...
          if (fsm_go_event)             // Illegal user write to CONTROL_REG...
            begin
              next_state          = FSM_ERROR;
              next_fsm_man        = 1'b0;
              next_fsm_en         = 1'b0;
              next_fsm_aclk       = 1'b0;
              next_fsm_bldis      = 1'b0;
              next_fsm_set_form   = 1'b0;
              next_fsm_set_rst    = 1'b0;
              next_fsm_read_mode  = 1'b0;
              next_fsm_we         = 1'b0;
              next_fsm_sa_en      = 1'b0;
              next_fip            = 1'b0;
              next_wip            = 1'b0;
              next_rip            = 1'b0;
              next_fsm_error_flag = 1'b1;
              next_first_verify   = 1'b0;
              next_write_op       = 1'b0;
              next_set_only       = 1'b0;
              next_rst_only       = 1'b0;
            end
          else
            begin
              next_state        = SR_SIG;
              next_fsm_we       = 1'b1;
              next_fsm_set_form = (clu_op_code == OP_FORM) | ((clu_op_code == OP_SET) & force_set_type);
              next_fsm_set_rst  = do_set;
            end
        end
      // ========
      SR_SIG :  // Control signals are asserted, now assert the EN...
        begin
          if (fsm_go_event)             // Illegal user write to CONTROL_REG...
            begin
              next_state          = FSM_ERROR;
              next_fsm_man        = 1'b0;
              next_fsm_en         = 1'b0;
              next_fsm_aclk       = 1'b0;
              next_fsm_bldis      = 1'b0;
              next_fsm_set_form   = 1'b0;
              next_fsm_set_rst    = 1'b0;
              next_fsm_read_mode  = 1'b0;
              next_fsm_we         = 1'b0;
              next_fsm_sa_en      = 1'b0;
              next_fip            = 1'b0;
              next_wip            = 1'b0;
              next_rip            = 1'b0;
              next_fsm_error_flag = 1'b1;
              next_first_verify   = 1'b0;
              next_write_op       = 1'b0;
              next_set_only       = 1'b0;
              next_rst_only       = 1'b0;
            end
          else
            begin
              next_state  = SR_EN;
              next_fsm_en = 1'b1;

              // KA: need to hold SA_EN state for 3 MCLK cycles to meet RRAM TenHIacHI timing...
              load_tmr     = 1'b1;       // Load the shared timer...
              load_tmr_val = 17'h0_0002; // 3 total MCLK cycle wait states in state SR_EN...
              
            end
        end
      // ========
      SR_EN :  // EN is asserted, now assert the ACLK pulse...
        begin
          if (fsm_go_event)             // Illegal user write to CONTROL_REG...
            begin
              next_state          = FSM_ERROR;
              next_fsm_man        = 1'b0;
              next_fsm_en         = 1'b0;
              next_fsm_aclk       = 1'b0;
              next_fsm_bldis      = 1'b0;
              next_fsm_set_form   = 1'b0;
              next_fsm_set_rst    = 1'b0;
              next_fsm_read_mode  = 1'b0;
              next_fsm_we         = 1'b0;
              next_fsm_sa_en      = 1'b0;
              next_fip            = 1'b0;
              next_wip            = 1'b0;
              next_rip            = 1'b0;
              next_fsm_error_flag = 1'b1;
              next_first_verify   = 1'b0;
              next_write_op       = 1'b0;
              next_set_only       = 1'b0;
              next_rst_only       = 1'b0;
            end
          else if (shared_tmr == 17'h0_0000)    // The shared timer is an automatic  down-counter...
            begin
              next_state    = SR_ACLK_PLS;
              next_fsm_aclk = 1'b1;

              load_tmr      = 1'b1; // Load the shared timer...

              if (do_set && do_rst) // If doing BOTH set and rst, figure out
                begin               //  which op we're currently doing...
                  if (write_op)
                    begin
                      load_tmr_val = set_timer_config; // We're doing the SET...
                    end
                  else
                    begin
                      load_tmr_val = reset_timer_config; // We're doing the RESET...
                    end
                end
              else                 // Else we're doing just one or the other...
                begin
                  if (do_set)
                    begin
                      load_tmr_val = set_timer_config; // We're doing the SET...
                    end
                  else
                    begin
                      load_tmr_val = reset_timer_config; // We're doing the RESET...
                    end
                end
            end
        end
      // ========
      SR_ACLK_PLS :
        begin
          if (fsm_go_event)             // Illegal user write to CONTROL_REG...
            begin
              next_state          = FSM_ERROR;
              next_fsm_man        = 1'b0;
              next_fsm_en         = 1'b0;
              next_fsm_aclk       = 1'b0;
              next_fsm_bldis      = 1'b0;
              next_fsm_set_form   = 1'b0;
              next_fsm_set_rst    = 1'b0;
              next_fsm_read_mode  = 1'b0;
              next_fsm_we         = 1'b0;
              next_fsm_sa_en      = 1'b0;
              next_fip            = 1'b0;
              next_wip            = 1'b0;
              next_rip            = 1'b0;
              next_fsm_error_flag = 1'b1;
              next_first_verify   = 1'b0;
              next_write_op       = 1'b0;
              next_set_only       = 1'b0;
              next_rst_only       = 1'b0;
            end
          else if (clu_op_code == OP_MAN)      // MANUAL mode: hold all signals in their
            begin                              //  current state and wait...
              next_state = MAN_WAIT;
            end
          else
            begin
              if (shared_tmr == 17'h0_0001)    // The shared timer is a down-counter - pulse is done
                begin                          //  when timer value gets to '1'...
                  next_state    = SR_ACLK_DONE;
                  next_fsm_aclk = 1'b0;
                end
            end
        end
      // ========
      SR_ACLK_DONE :
        begin
          if (fsm_go_event)             // Illegal user write to CONTROL_REG...
            begin
              next_state          = FSM_ERROR;
              next_fsm_man        = 1'b0;
              next_fsm_en         = 1'b0;
              next_fsm_aclk       = 1'b0;
              next_fsm_bldis      = 1'b0;
              next_fsm_set_form   = 1'b0;
              next_fsm_set_rst    = 1'b0;
              next_fsm_read_mode  = 1'b0;
              next_fsm_we         = 1'b0;
              next_fsm_sa_en      = 1'b0;
              next_fip            = 1'b0;
              next_wip            = 1'b0;
              next_rip            = 1'b0;
              next_fsm_error_flag = 1'b1;
              next_first_verify   = 1'b0;
              next_write_op       = 1'b0;
              next_set_only       = 1'b0;
              next_rst_only       = 1'b0;
            end
          else if (!fsm_man &&                    // Not in MANUAL mode, and 
                    do_set && do_rst && write_op) //  doing BOTH and we just completed the SET,
            begin                                 //  loop back to state SR_EN and do the RESET...
              //next_state       = SR_EN;
              next_state       = SR_SIG;          // KA: need extra MCLK cycle for TdataSU...
              next_fsm_set_rst = 1'b0;
              next_fsm_di      = rst_data_mask;
              next_write_op    = 1'b0;            // change write_op to indicate RESET...
            end
          else                                    // We weren't doing BOTH OR we completed the RESET
            begin                                 //  OR in MANUAL mode, all done...
              next_state = SR_EN_DONE;
              next_fsm_en = 1'b0;
            end
        end
      // ========
      SR_EN_DONE :
        begin
          if (fsm_go_event)             // Illegal user write to CONTROL_REG...
            begin
              next_state          = FSM_ERROR;
              next_fsm_man        = 1'b0;
              next_fsm_en         = 1'b0;
              next_fsm_aclk       = 1'b0;
              next_fsm_bldis      = 1'b0;
              next_fsm_set_form   = 1'b0;
              next_fsm_set_rst    = 1'b0;
              next_fsm_read_mode  = 1'b0;
              next_fsm_we         = 1'b0;
              next_fsm_sa_en      = 1'b0;
              next_fip            = 1'b0;
              next_wip            = 1'b0;
              next_rip            = 1'b0;
              next_fsm_error_flag = 1'b1;
              next_first_verify   = 1'b0;
              next_write_op       = 1'b0;
              next_set_only       = 1'b0;
              next_rst_only       = 1'b0;
            end
          else
            begin
              next_state        = SR_SIG_DONE;
              next_fsm_we       = 1'b0;
              next_fsm_set_form = 1'b0;
              next_fsm_set_rst  = 1'b0;
              next_first_verify = 1'b0;  // reset the first_verify signal for use in do_set,
                                         //  do_rst calculations for the next state... 
            end
        end
      // ========
      SR_SIG_DONE :
        begin
          if (fsm_go_event)             // Illegal user write to CONTROL_REG...
            begin
              next_state          = FSM_ERROR;
              next_fsm_man        = 1'b0;
              next_fsm_en         = 1'b0;
              next_fsm_aclk       = 1'b0;
              next_fsm_bldis      = 1'b0;
              next_fsm_set_form   = 1'b0;
              next_fsm_set_rst    = 1'b0;
              next_fsm_read_mode  = 1'b0;
              next_fsm_we         = 1'b0;
              next_fsm_sa_en      = 1'b0;
              next_fip            = 1'b0;
              next_wip            = 1'b0;
              next_rip            = 1'b0;
              next_fsm_error_flag = 1'b1;
              next_first_verify   = 1'b0;
              next_write_op       = 1'b0;
              next_set_only       = 1'b0;
              next_rst_only       = 1'b0;
            end
          else if ((clu_op_code == OP_FORM) ||   // FORM or WRITE: SET (or RST) needs to be 
                   (clu_op_code == OP_WRITE))    //  followed by a VERIFY
            begin
              next_state        = BLDIS_PLS;
              next_fsm_bldis    = 1'b1;
              load_tmr          = 1'b1;               // Load the shared timer with
              load_tmr_val      = bldis_timer_config; //  BLDIS pulse width value...
            end
          else if ((clu_op_code == OP_SET) ||    // FORCE SET or FORCE RESET can loop
                   (clu_op_code == OP_RST))      //  on same address via retry, and also
            begin                                //  generally loop based on WRITE_CONFIG_REG.WRITE_MODE...
              if (do_set &&                             // More retries to go: qualify with
                  (set_retry_count < set_retry_limit))  //  retry_count: if it == retry_limit
                begin                                   //  we've already done the last retry...
                  next_state     = SR_SETUP;
                  next_fsm_en    = 1'b0;          // de-assert EN...
                  incr_set_retry = do_set_retry;  // SET is because it is a retry - increment set_retry_count
                end
              else if (do_rst &&                         // More retries to go: qualify with
                  (rst_retry_count < reset_retry_limit)) //  retry_count: if it == retry_limit
                begin                                    //  we've aleady done the last retry...
                  next_state     = SR_SETUP;
                  next_fsm_en    = 1'b0;          // de-assert EN...
                  incr_rst_retry = do_rst_retry;  // RESET is because it is a retry - increment rst_retry_count
                end
              else
                begin
                  clear_retry_counters = 1'b1;

                  if (op_multi && !op_multi_done)   // Muliple access loop, do another
                    begin                           //  "first_verify" with a new address...
                      if (hybrid_in)
                        begin
                          next_state    = WAIT_IN_ACK; // Need to wait for hybrid mode inputs...
                          assert_di_req = 1'b1;
                        end
                      else
                        begin
                          next_state        = SR_SETUP;
                          next_first_verify = 1'b1;
                          load_next         = 1'b1;
                          next_fsm_di       = set_data_mask;  // In FORCE modes, set_data_mask and rst_data_mask have
                                                              //  the same source...
                        end
                    end
                  else                              // Truly all done...
                    begin
                      next_state         = FSM_IDLE;
                      next_fsm_en        = 1'b0;
                      next_fsm_set_form  = 1'b0;
                      next_fsm_set_rst   = 1'b0;
                      next_fsm_read_mode = 1'b0;
                      next_fip           = 1'b0;
                      next_wip           = 1'b0;
                      next_set_only      = 1'b0;
                      next_rst_only      = 1'b0;
                    end
                end
            end
          else                              // Any other op code and we're done...
            begin
              next_state    = FSM_IDLE;
              next_fip      = 1'b0;
              next_fsm_man  = 1'b0;         // We may have gotten here because of Manual mode...
              next_wip      = 1'b0;         // We may have gotten here because of FORCE SET or FORCE RST
              next_set_only = 1'b0;
              next_rst_only = 1'b0;
            end
        end
      // ========
      MAN_WAIT :
        begin
          if (fsm_go_event)                 // In MANUAL mode, the user is expected to write to
            begin                           //  to the CONTROL_REG, with op code IDLE in order to exit...
              if (clu_op_code == OP_IDLE)
                begin
                  next_state    = SR_ACLK_DONE;
                  next_fsm_aclk = 1'b0;
                end
              else                          // Illegal user write to CONTROL_REG...
                begin
                  next_state          = FSM_ERROR;
                  next_fsm_man        = 1'b0;
                  next_fsm_en         = 1'b0;
                  next_fsm_aclk       = 1'b0;
                  next_fsm_bldis      = 1'b0;
                  next_fsm_set_form   = 1'b0;
                  next_fsm_set_rst    = 1'b0;
                  next_fsm_read_mode  = 1'b0;
                  next_fsm_we         = 1'b0;
                  next_fsm_sa_en      = 1'b0;
                  next_fip            = 1'b0;
                  next_wip            = 1'b0;
                  next_rip            = 1'b0;
                  next_fsm_error_flag = 1'b1;
                  next_first_verify   = 1'b0;
                  next_write_op       = 1'b0;
                  next_set_only       = 1'b0;
                  next_rst_only       = 1'b0;
                end
            end 
        end
      // ========
      PUSH_SETERR :  // We enter this state only from READ_DONE, only if op code is FORM or WRITE,
                     //  and only if a SET and/or RST error occurred...
        begin
          if (fsm_go_event)             // Illegal user write to CONTROL_REG...
            begin
              next_state          = FSM_ERROR;
              next_fsm_man        = 1'b0;
              next_fsm_en         = 1'b0;
              next_fsm_aclk       = 1'b0;
              next_fsm_bldis      = 1'b0;
              next_fsm_set_form   = 1'b0;
              next_fsm_set_rst    = 1'b0;
              next_fsm_read_mode  = 1'b0;
              next_fsm_we         = 1'b0;
              next_fsm_sa_en      = 1'b0;
              next_fip            = 1'b0;
              next_wip            = 1'b0;
              next_rip            = 1'b0;
              next_fsm_error_flag = 1'b1;
              next_first_verify   = 1'b0;
              next_write_op       = 1'b0;
              next_set_only       = 1'b0;
              next_rst_only       = 1'b0;
            end
          else if (!diag_mode)  // limited diag mode: just increment error counters and move on
            begin
              next_state   = PUSH_DONE;
              incr_set_err = set_error;
              incr_rst_err = rst_error;
            end
          else
            begin
              if (!set_error)  // No set error, go to service the rst error...
                begin
                  next_state = PUSH_RSTERR;
                end
              else
                begin
                  if (!diag_fifo_full)  // Don't push to a full fifo!
                    begin
                      next_state       = (rst_error) ? PUSH_RSTERR : PUSH_DONE;
                      failed_operation = (clu_op_code == OP_FORM) ? 2'b10 : 2'b01;
                      failed_data_bits = set_data_mask;
                      diag_push        = 1'b1;
                      incr_set_err     = 1'b1;
                    end
                end
            end
        end
      // ========
      PUSH_RSTERR :
        begin
          if (fsm_go_event)             // Illegal user write to CONTROL_REG...
            begin
              next_state          = FSM_ERROR;
              next_fsm_man        = 1'b0;
              next_fsm_en         = 1'b0;
              next_fsm_aclk       = 1'b0;
              next_fsm_bldis      = 1'b0;
              next_fsm_set_form   = 1'b0;
              next_fsm_set_rst    = 1'b0;
              next_fsm_read_mode  = 1'b0;
              next_fsm_we         = 1'b0;
              next_fsm_sa_en      = 1'b0;
              next_fip            = 1'b0;
              next_wip            = 1'b0;
              next_rip            = 1'b0;
              next_fsm_error_flag = 1'b1;
              next_first_verify   = 1'b0;
              next_write_op       = 1'b0;
              next_set_only       = 1'b0;
              next_rst_only       = 1'b0;
            end
          else if (!diag_fifo_full)  // Don't push to a full fifo!
            begin
              next_state       = PUSH_DONE;
              failed_operation = 2'b00;
              failed_data_bits = rst_data_mask;
              diag_push        = 1'b1;
              incr_rst_err     = 1'b1;
            end
        end
      // ========
      PUSH_DONE :  // This exactly mimicks the exits from READ_DONE state, when op code
                   //  is FORM or WRITE...
        begin
          if (fsm_go_event)             // Illegal user write to CONTROL_REG...
            begin
              next_state          = FSM_ERROR;
              next_fsm_man        = 1'b0;
              next_fsm_en         = 1'b0;
              next_fsm_aclk       = 1'b0;
              next_fsm_bldis      = 1'b0;
              next_fsm_set_form   = 1'b0;
              next_fsm_set_rst    = 1'b0;
              next_fsm_read_mode  = 1'b0;
              next_fsm_we         = 1'b0;
              next_fsm_sa_en      = 1'b0;
              next_fip            = 1'b0;
              next_wip            = 1'b0;
              next_rip            = 1'b0;
              next_fsm_error_flag = 1'b1;
              next_first_verify   = 1'b0;
              next_write_op       = 1'b0;
              next_set_only       = 1'b0;
              next_rst_only       = 1'b0;
            end
          else if (op_multi && !op_multi_done)   // Muliple access loop, do another
            begin                                //  "first_verify" with a new address...
              if (hybrid_in)
                begin
                  next_state    = WAIT_IN_ACK; // Need to wait for hybrid mode inputs...
                  assert_di_req = 1'b1;
                end
              else
                begin
                  next_state        = READ_ADDR;
                  next_first_verify = 1'b1;
                  load_next         = 1'b1;
                end
            end
          else                              // Truly all done...
            begin
              next_state         = FSM_IDLE;
              next_fsm_en        = 1'b0;
              next_fsm_set_form  = 1'b0;
              next_fsm_set_rst   = 1'b0;
              next_fsm_read_mode = 1'b0;
              next_fip           = 1'b0;
              next_wip           = 1'b0;
            end
        end
      // ========
      FSM_ERROR :                      // This state indicates an illegal user
        begin                          //  write to CONTROL_REG during FSM processing.
          if (clu_op_code == OP_IDLE)  //  User must write CONTROL_REG back to IDLE...
            begin
              next_state          = FSM_IDLE;
              next_fsm_error_flag = 1'b0;
            end
        end
    endcase
  end

// ================================
// State Machine: State Register...
// ================================
always @(posedge fsm_clk or negedge fsm_rst_n)
  begin
    if (!fsm_rst_n)
      begin
        curr_state <= FSM_IDLE;
      end
    else
      begin
        curr_state <= next_state;
      end
  end

// Other sequential FSM signals...
always @(posedge fsm_clk or negedge fsm_rst_n)
  begin
    if (!fsm_rst_n)
      begin
        fsm_man        <= 1'b0;
        fsm_en         <= 1'b0;
        fsm_aclk       <= 1'b0;
        fsm_bldis      <= 1'b0;
        fsm_set_form   <= 1'b0;
        fsm_set_rst    <= 1'b0;
        fsm_read_mode  <= 1'b0;
        fsm_we         <= 1'b0;
        fsm_di         <= 16'h0000;
        fsm_sa_en      <= 1'b0;
        fip            <= 1'b0;
        wip            <= 1'b0;
        rip            <= 1'b0;
        fsm_error_flag <= 1'b0;
        first_verify   <= 1'b0;
        write_op       <= 1'b0;
        set_only       <= 1'b0;
        rst_only       <= 1'b0;
        first_force    <= 1'b0;
      end
    else
      begin
        fsm_man        <= next_fsm_man;
        fsm_en         <= next_fsm_en;
        fsm_aclk       <= next_fsm_aclk;
        fsm_bldis      <= next_fsm_bldis;
        fsm_set_form   <= next_fsm_set_form;
        fsm_set_rst    <= next_fsm_set_rst;
        fsm_read_mode  <= next_fsm_read_mode;
        fsm_we         <= next_fsm_we;
        fsm_di         <= next_fsm_di;
        fsm_sa_en      <= next_fsm_sa_en;
        fip            <= next_fip;
        wip            <= next_wip;
        rip            <= next_rip;
        fsm_error_flag <= next_fsm_error_flag;
        first_verify   <= next_first_verify;
        write_op       <= next_write_op;
        set_only       <= next_set_only;
        rst_only       <= next_rst_only;
        first_force    <= next_first_force;
      end
  end

assign fsm_en_1hot = fsm_en << banksel;  // Only drive 1 select signal...
assign mip = fsm_man;

// ===========================
// State Machine: Resources...
// ===========================

// --------------
// Retry Counters, need to track SET and RST retries independently...
// --------------
always @(posedge fsm_clk or negedge fsm_rst_n)
  begin
    if (!fsm_rst_n)
      begin
        set_retry_count <= 6'h00;
        rst_retry_count <= 6'h00;
      end
    else
      begin
        if (clear_retry_counters)   // Common control to set both counters...
          begin
            set_retry_count <= 6'h00;
            rst_retry_count <= 6'h00;
          end
        else
          begin
            if (incr_set_retry)    // Mutually exclusive control to increment set counter...
              begin
                set_retry_count <= set_retry_count + 6'h01;
              end
            if (incr_rst_retry)    // Mutually exclusive control to increment reset counter...
              begin
                rst_retry_count <= rst_retry_count + 6'h01;
              end
          end
      end
  end

// --------------
// Error Counters, need to track SET and RST errors independently...
// --------------
always @(posedge fsm_clk or negedge fsm_rst_n)
  begin
    if (!fsm_rst_n)
      begin
        set_error_count <= 17'h0_0000;
        rst_error_count <= 17'h0_0000;
      end
    else
      begin
        if (clear_error_counters)   // Common control to set both counters...
          begin
            set_error_count <= 17'h0_0000;
            rst_error_count <= 17'h0_0000;
          end
        else
          begin
            if (incr_set_err)    // Mutually exclusive control to increment set counter...
              begin
                set_error_count <= set_error_count + 17'h0_0001;
              end
            if (incr_rst_err)    // Mutually exclusive control to increment reset counter...
              begin
                rst_error_count <= rst_error_count + 17'h0_0001;
              end
          end
      end
  end

// Verify detection: combinational logic only acted upon during state READ_DONE...
//  Calculation of XXX_data_mask determines whether the FORM or WRITE command was successful.
//  If not successful, check to see if we can retry, else flag an error.
//
// NOTE: the do_set and do_reset indicators guide the seven shared SR_xxx FSM states.
//  o The mask checking is the overall qualifier - i.e. set_error, rst_error indicate at
//     least 1 bit unmasked. A SET or RESET will not take place if the masks indicate
//     "all masked".
//
//     - For commands OP_MAN, OP_SET and OP_RST the masks come directly from the user.
//     - For commands OP_FORM, OP_WRITE, the masks are derived from user-desired data value
//        and the results of a VERIFY.
//
//  o The debug command OP_MAN and force commands OP_SET and OP_RST override any "normal" FSM signaling
//     that would prevent the SET or RESET (first_verify, retry count).
//
//  o OP_SET and OP_RST can be allowed to loop on the same address via the retry mechanism:
//     allow retry count incrementing with these commands...

assign set_error = (set_data_mask != 16'h0000) | set_only; // OP_SET forces error to enable retry...
assign do_set    = (~rst_only & set_error & (first_verify | (set_retry_count <= set_retry_limit)));

// figure out if we're retrying a SET so we can increment the set_retry_count...
assign do_set_retry = (~rst_only & set_error & ~first_verify & (set_retry_count <= set_retry_limit));

assign rst_error = (rst_data_mask != 16'hFFFF) | rst_only; // OP_RST forces error to enable retry...
assign do_rst    = (~set_only & rst_error & (first_verify | (rst_retry_count <= reset_retry_limit)));

// figure out if we're retrying a RESET so we can increment the rst_retry_count...
assign do_rst_retry = (~set_only & rst_error & ~first_verify & (rst_retry_count <= reset_retry_limit));

// --------------
// Pulse Timer, shared between BLDIS pulse, ACLK pulse generation...
// --------------
always @(posedge fsm_clk or negedge fsm_rst_n)
  begin
    if (!fsm_rst_n)
      begin
        shared_tmr <= 17'h0_0000;
      end
    else
      begin
        if (load_tmr)                     // Load has precedence...
          begin
            shared_tmr <= load_tmr_val; 
          end
        else                              // The timer simply down-counts every fsm_clk until
          begin                           //  it reaches zero...
            if (shared_tmr != 17'h0_0000)
              begin
                shared_tmr <= shared_tmr - 17'h0_0001;
              end
          end
      end
  end

// --------------
// sa_clk generation...
// --------------
// Readout logic - for READ or VERIFY, need to create a series of 4 clock pulses.
//  Ideally, the frequency is 25MHz (i.e. fsm_clk/2). Customer believes this should
//  be sufficiently slow, but maybe not in all PVT corners.
//  As a backup, allow generation of sa_clk as every 2nd, 3rd or 4th fsm_clk...

// Implementation is a variable-length shift register with feedback. Held in reset
//  until shifting is needed...

always @(posedge fsm_clk or negedge fsm_rst_n)
  begin
    if (!fsm_rst_n)
      begin
        sa_clk_shreg <= 4'b0010;
      end
    else
      begin
        if (sa_clk_shift)
          begin
            case (sa_clk_conf)
              2'b00, 2'b01 : // div-2
                begin
                  sa_clk_shreg <= {sa_clk_shreg[3:2], sa_clk_shreg[0], sa_clk_shreg[1]};
                end
              2'b10 :  // div-4
                begin
                  sa_clk_shreg <= {sa_clk_shreg[0], sa_clk_shreg[3:1]};
                end
              2'b11 :  // div-3
                begin
                  sa_clk_shreg <= {sa_clk_shreg[3], sa_clk_shreg[0], sa_clk_shreg[2:1]};
                end
            endcase
          end
        else
          begin
            sa_clk_shreg <= 4'b0010;
          end
      end
  end

assign fsm_sa_clk = sa_clk_shreg[0];

// Assertion detect for sa_en kicks off sa_clk shifting.
//  Before sa_clk pulses, there is a 3-mclk-cycle setup time...

always @(posedge fsm_clk or negedge fsm_rst_n)
  begin
    if (!fsm_rst_n)
      begin
        start_sa_cnt <= 2'b00;
      end
    else
      begin
        if (!fsm_sa_en && next_fsm_sa_en)  // Assertion detect for sa_en
          begin
            start_sa_cnt <= 2'b11;
          end
        else
          begin
            if (start_sa_cnt > 2'h0)
              begin
                start_sa_cnt <= start_sa_cnt - 2'h1;
              end
          end
      end
  end

assign start_sa_clk = (start_sa_cnt == 2'b01);

always @(posedge fsm_clk or negedge fsm_rst_n)
  begin
    if (!fsm_rst_n)
      begin
        sa_clk_shift <= 1'b0;
        sa_clk_count <= 2'h0;
      end
    else
      begin
        if (start_sa_clk)  // setup time complete, kick off sa_clk pulses...
          begin
            sa_clk_shift <= 1'b1;
            sa_clk_count <= 2'h3;
          end
        else
          begin
            if (fsm_sa_clk)                // The rest of the transitions occur
              begin                        //  based on the sa_clk...
                if (sa_clk_count == 0)
                  begin                    // 4 sa_clk pulses have occured,
                    sa_clk_shift <= 1'b0;  //  stop shifting...
                  end
                else                       // else decrement the sa_clk_count...
                  begin
                    sa_clk_count <= sa_clk_count - 2'h1;
                  end
              end
          end
      end
  end

// --------------
// Address, Wdata Generation...
// --------------

// The reg arrays column addressing (16-bits at a time) is NOT a power of 2!
//  Assuming the address arrangement is WORDLINE ADDR as 9 LSBits, and COLUMN
//  ADDR as the upper 8 bits, but there aren't 2^^8 columns. This arrangment
//  should leave us contiguous addressable space from 0 to the parameter LAST_ADDR.
//
// It is decided that if the user mis-programs the address and multi-offset register
//  fields such that a generated address would exceed LAST_ADDR, the operation
//  goes forward but with address LAST_ADDR applied - in other words, a limiter
//  is imposed...

assign addr_in_lim = (address > LAST_ADDR) ? LAST_ADDR : address;
assign da_addr_in_lim = (da_addr > LAST_ADDR) ? LAST_ADDR : da_addr;

assign muxed_data_in = (wdata_source) ? da_di : data_in;

always @*
  begin
    case (clu_op_code)
      // ------
      OP_FORM :
        begin
          init_wdatagen = muxed_data_in; // FORM operation wants to SET all the bits,
          next_wdatagen = muxed_data_in; //  but user value here can choose to target any bits...

          addr_plus_offset = addr_in_lim + form_multi_offset;

          hybrid_in = (addr_source | wdata_source);   // FORM can get ADDR and/or WDTA in hybrid mode...

          case (form_mode)
            2'b00, 2'b11 :  // Form just one location
              begin
                op_multi     = 1'b0;
                init_addrgen = addr_in_lim;
                next_addrgen = addr_in_lim;
                last_addrgen = addr_in_lim;

              end
            2'b01 :         // Form multiple contiguous locations
              begin
                op_multi     = 1'b1;
                init_addrgen = addr_in_lim;
                next_addrgen = addrgen + 17'h0_0001;
                last_addrgen = (addr_plus_offset > LAST_ADDR) ? LAST_ADDR : addr_plus_offset[16:0];
              end
            2'b10 :         // Form all locations
              begin
                op_multi     = 1'b1;
                init_addrgen = 17'h0_0000;
                next_addrgen = addrgen + 17'h0_0001;
                last_addrgen = LAST_ADDR;
              end
          endcase
        end
      // ------
      OP_READ :
        begin
          init_wdatagen = 16'hFFFF;  // n/a for READ...
          next_wdatagen = 16'hFFFF;

          addr_plus_offset = addr_in_lim + read_multi_offset;

          hybrid_in = addr_source;   // READ would only get ADDR in hybrid mode, not WDATA

          case (read_mode)
            2'b00 :         // Read just one location
              begin
                op_multi     = 1'b0;
                init_addrgen = addr_in_lim;
                next_addrgen = addr_in_lim;
                last_addrgen = addr_in_lim;
              end
            2'b01 :         // Read multiple contiguous locations
              begin
                op_multi     = 1'b1;
                init_addrgen = addr_in_lim;
                next_addrgen = addrgen + 17'h0_0001;
                last_addrgen = (addr_plus_offset > LAST_ADDR) ? LAST_ADDR : addr_plus_offset[16:0];
              end
            2'b10 :         // Read all locations
              begin
                op_multi     = 1'b1;
                init_addrgen = 17'h0_0000;
                next_addrgen = addrgen + 17'h0_0001;
                last_addrgen = LAST_ADDR;
              end
            2'b11 :         // Read Checkerboard
              begin
                op_multi     = 1'b1;
                init_addrgen = {16'h0000, check_board_conf};
                next_addrgen = addrgen + 17'h0_0002;
                last_addrgen = {LAST_ADDR[16:1], check_board_conf};
              end
          endcase
        end
      // ------
      OP_WRITE :
        begin

          addr_plus_offset = addr_in_lim + write_multi_offset;

          hybrid_in = (addr_source | wdata_source); // WRITE could get ADDR and/or WDATA
                                                    //  in hybrid mode...
          case (write_mode)
            2'b00, 2'b11 :  // Write just one location
              begin
                op_multi      = 1'b0;
                init_addrgen  = addr_in_lim;
                next_addrgen  = addr_in_lim;
                last_addrgen  = addr_in_lim;
                init_wdatagen = muxed_data_in;
                next_wdatagen = muxed_data_in;
              end
            2'b01 :         // Write multiple contiguous locations
              begin
                op_multi     = 1'b1;

                case (wdata_pattern)
                  CHKBD0 : 
                    begin
                      init_addrgen = addr_in_lim;
                      next_addrgen = addrgen + 17'h0_0001;
                      init_wdatagen = (wdata_source) ? da_di :
                                       (init_addrgen[0]) ? 16'hFFFF : 16'h0000;
                      next_wdatagen = (wdata_source) ? da_di :
                                       (next_addrgen[0]) ? 16'hFFFF : 16'h0000;
                    end
                  CHKBD1 : 
                    begin
                      init_addrgen = addr_in_lim;
                      next_addrgen = addrgen + 17'h0_0001;
                      init_wdatagen = (wdata_source) ? da_di :
                                       (init_addrgen[0]) ? 16'h0000 : 16'hFFFF;
                      next_wdatagen = (wdata_source) ? da_di :
                                       (next_addrgen[0]) ? 16'h0000 : 16'hFFFF;
                    end
                  CHKBD2 : 
                    begin
                      init_addrgen = addr_in_lim;
                      next_addrgen = addrgen + 17'h0_0001;
                      init_wdatagen = (wdata_source) ? da_di :
                                       (init_addrgen[0]) ? 16'h5555 : 16'hAAAA;
                      next_wdatagen = (wdata_source) ? da_di :
                                       (next_addrgen[0]) ? 16'h5555 : 16'hAAAA;
                    end
                  CHKBD3 : 
                    begin
                      init_addrgen = addr_in_lim;
                      next_addrgen = addrgen + 17'h0_0001;
                      init_wdatagen = (wdata_source) ? da_di :
                                       (init_addrgen[0]) ? 16'hAAAA : 16'h5555;
                      next_wdatagen = (wdata_source) ? da_di :
                                       (next_addrgen[0]) ? 16'hAAAA : 16'h5555;
                    end
                  CHKBDEVEN :
                    begin
                      init_addrgen = {addr_in_lim[16:1], 1'b0};  // Force an EVEN start address
                      next_addrgen = addrgen + 17'h0_0002;
                      init_wdatagen = muxed_data_in;
                      next_wdatagen = muxed_data_in;
                    end
                  CHKBDODD :
                    begin
                      init_addrgen = {addr_in_lim[16:1], 1'b1};  // Force an ODD start address
                      next_addrgen = addrgen + 17'h0_0002;
                      init_wdatagen = muxed_data_in;
                      next_wdatagen = muxed_data_in;
                    end
                  DATAEQADDR :
                    begin
                      init_addrgen = addr_in_lim;
                      next_addrgen = addrgen + 17'h0_0001;
                      init_wdatagen = (wdata_source) ? da_di : init_addrgen;
                      next_wdatagen = (wdata_source) ? da_di : next_addrgen;
                    end
                  default :
                    begin
                      init_addrgen = addr_in_lim;
                      next_addrgen = addrgen + 17'h0_0001;
                      init_wdatagen = muxed_data_in;
                      next_wdatagen = muxed_data_in;
                    end
                  endcase

                last_addrgen = (addr_plus_offset > LAST_ADDR) ? LAST_ADDR : addr_plus_offset[16:0];
              end
            2'b10 :         // Write all locations
              begin
                op_multi     = 1'b1;

                case (wdata_pattern)
                  CHKBD0 : 
                    begin
                      init_addrgen = 17'h0_0000;
                      next_addrgen = addrgen + 17'h0_0001;
                      init_wdatagen = (wdata_source) ? da_di : 16'h0000;
                      next_wdatagen = (wdata_source) ? da_di :
                                       (next_addrgen[0]) ? 16'hFFFF : 16'h0000;
                    end
                  CHKBD1 : 
                    begin
                      init_addrgen = 17'h0_0000;
                      next_addrgen = addrgen + 17'h0_0001;
                      init_wdatagen = (wdata_source) ? da_di : 16'hFFFF;
                      next_wdatagen = (wdata_source) ? da_di :
                                       (next_addrgen[0]) ? 16'h0000 : 16'hFFFF;
                    end
                  CHKBD2 : 
                    begin
                      init_addrgen = 17'h0_0000;
                      next_addrgen = addrgen + 17'h0_0001;
                      init_wdatagen = (wdata_source) ? da_di : 16'hAAAA;
                      next_wdatagen = (wdata_source) ? da_di :
                                       (next_addrgen[0]) ? 16'h5555 : 16'hAAAA;
                    end
                  CHKBD3 : 
                    begin
                      init_addrgen = 17'h0_0000;
                      next_addrgen = addrgen + 17'h0_0001;
                      init_wdatagen = (wdata_source) ? da_di : 16'h5555;
                      next_wdatagen = (wdata_source) ? da_di :
                                       (next_addrgen[0]) ? 16'hAAAA : 16'h5555;
                    end
                  CHKBDEVEN :
                    begin
                      init_addrgen = 17'h0_0000;
                      next_addrgen = addrgen + 17'h0_0002;
                      init_wdatagen = muxed_data_in;
                      next_wdatagen = muxed_data_in;
                    end
                  CHKBDODD :
                    begin
                      init_addrgen = 17'h0_0001;
                      next_addrgen = addrgen + 17'h0_0002;
                      init_wdatagen = muxed_data_in;
                      next_wdatagen = muxed_data_in;
                    end
                  DATAEQADDR :
                    begin
                      init_addrgen = 17'h0_0000;
                      next_addrgen = addrgen + 17'h0_0001;
                      init_wdatagen = (wdata_source) ? da_di : init_addrgen;
                      next_wdatagen = (wdata_source) ? da_di : next_addrgen;
                    end
                  default :
                    begin
                      init_addrgen = 17'h0_0000;
                      next_addrgen = addrgen + 17'h0_0001;
                      init_wdatagen = muxed_data_in;
                      next_wdatagen = muxed_data_in;
                    end
                  endcase

                last_addrgen = {LAST_ADDR[16:1], (wdata_pattern != CHKBDEVEN)};
              end
          endcase
        end
      // ------
      OP_SET, OP_RST, OP_RDVER :  // Loop through incrementing addresses,
                                  //  but the data is always
                                  //  from DATA_IN_REG or DI port...
        begin

          addr_plus_offset = addr_in_lim + write_multi_offset;

          hybrid_in = (addr_source | wdata_source); // WRITE could get ADDR and/or WDATA
                                                    //  in hybrid mode...
          case (write_mode)
            2'b00, 2'b11 :  // Write just one location
              begin
                op_multi      = 1'b0;
                init_addrgen  = addr_in_lim;
                next_addrgen  = addr_in_lim;
                last_addrgen  = addr_in_lim;
                init_wdatagen = muxed_data_in;
                next_wdatagen = muxed_data_in;
              end
            2'b01 :         // Write multiple contiguous locations
              begin
                op_multi     = 1'b1;
                init_addrgen = addr_in_lim;
                next_addrgen = addrgen + 17'h0_0001;
                last_addrgen = (addr_plus_offset > LAST_ADDR) ? LAST_ADDR : addr_plus_offset[16:0];

                init_wdatagen = muxed_data_in;
                next_wdatagen = muxed_data_in;
              end
            2'b10 :         // Write all locations
              begin
                op_multi     = 1'b1;
                init_addrgen = 17'h0_0000;
                next_addrgen = addrgen + 17'h0_0001;
                last_addrgen = LAST_ADDR;

                init_wdatagen = muxed_data_in;
                next_wdatagen = muxed_data_in;
              end
          endcase
        end
      // ------
      default :
        begin
          op_multi         = 1'b0;
          addr_plus_offset = 18'h0_0000;
          hybrid_in        = (clu_op_code == OP_MAN) ? (addr_source | wdata_source) : 1'b0;

          init_addrgen = addr_in_lim;
          next_addrgen = addrgen + 17'h0_0001;
          last_addrgen = LAST_ADDR;

          init_wdatagen = muxed_data_in;
          next_wdatagen = muxed_data_in;
        end
    endcase
  end

always @(posedge fsm_clk or negedge fsm_rst_n)
  begin
    if (!fsm_rst_n)
      begin
        addrgen  <= 17'h0_0000;
        wdatagen <= 16'h0000;
      end
    else
      begin
        if (load_init)
          begin
            addrgen  <= init_addrgen;
            wdatagen <= init_wdatagen;
          end
        else
          begin
            if (load_next)
              begin
                addrgen  <= next_addrgen;
                wdatagen <= next_wdatagen;
              end
          end
      end
  end

assign op_multi_done = (addrgen == last_addrgen) |    // Last address is reached OR
                       (next_addrgen > last_addrgen); //  Next address exceeds last address (covers
                                                      //  the cases where address increments by 2
                                                      //  and user programming causes last address
                                                      //  to be even during CHKBDODD or odd during
                                                      //  CHKBDEVEN writes...
assign fsm_addr = addrgen;

// VERIFY mask generation...
//  wdatagen is the user-intended value to write to a location.
//  rram_do (qualified by rram_sa_rdy) is the actual value at the location.
//
//  SET mask: place a '1' at any bit where wdatagen=1 and rram_do=0.
//  RESET mask: place a '0' at any bit where wdatagen=0 and rram_do=1.

always @*
  begin
    next_set_data_mask = (wdatagen & ~rram_do);    // bit-wise operations...
    next_rst_data_mask = ~(~wdatagen & rram_do);
  end

always @(posedge fsm_clk or negedge fsm_rst_n)
  begin
    if (!fsm_rst_n)
      begin
        i_set_data_mask <= 16'h0000;  // all masked - SET
        i_rst_data_mask <= 16'hFFFF;  // all masked - RST
      end
    else
      begin
        if (load_mask)
          begin
            i_set_data_mask <= next_set_data_mask;
            i_rst_data_mask <= next_rst_data_mask;

            // KA: debug/status signals to show when SET or RESET is "skipped"
            skip_set <= first_verify & (next_set_data_mask == 16'h0000);
            skip_rst <= first_verify & (next_rst_data_mask == 16'hFFFF) & (clu_op_code != OP_FORM);
          end
      end
  end

// For clu op codes MAN, SET, RST, the mask is provided by the user
//  via DATA_IN_REG (or DI port in Hybrid mode)...
always @*
  begin
    case (clu_op_code)
      OP_MAN, OP_SET, OP_RST :
        begin
          set_data_mask = muxed_data_in;
          rst_data_mask = muxed_data_in;
        end
      default :
        begin
          set_data_mask = i_set_data_mask;
          rst_data_mask = i_rst_data_mask;
        end
    endcase
  end

// =======================
// Diagnostic signaling...
// =======================
assign failed_address = rram_addr;
assign failed_bank    = banksel;   // Always base on FSM operation, so use SPI reg banksel field...

// ========================
// Direct Access BYP mux...
// ========================

// decode the bank select...
always @*
  begin
    da_en_1hot = 9'h000;              // initialize to all zeros first
    da_en_1hot = da_en << da_banksel; // shift the enable bit to the correct position
  end

// 2:1 mux: FSM signals or DA signals...
always @*
  begin
    if (da_byp)   // BYPASS active: select DA...
      begin
        rram_man        = da_man;
        rram_aclk       = da_aclk;
        rram_en         = da_en_1hot;
        rram_bldis      = da_bldis;
        rram_set_form   = da_set_form;
        rram_set_rst    = da_set_rst;
        rram_read_mode  = da_read_mode;
        rram_we         = da_we;
        rram_addr       = da_addr;
        rram_di_mask    = da_di;
        rram_sa_en      = da_sa_en;
        rram_sa_clk     = da_sa_clk;
      end
    else
      begin
        rram_man        = fsm_man;
        rram_aclk       = fsm_aclk;
        rram_en         = fsm_en_1hot;
        rram_bldis      = fsm_bldis;
        rram_set_form   = fsm_set_form;
        rram_set_rst    = fsm_set_rst;
        rram_read_mode  = fsm_read_mode;
        rram_we         = fsm_we;
        rram_addr       = addr_source ? da_addr_in_lim : fsm_addr; // Hybrid mode address comes from direct access port...
        rram_di_mask    = fsm_di;
        rram_sa_en      = fsm_sa_en;
        rram_sa_clk     = fsm_sa_clk;
      end
  end

// Forward the rram_sa_rdy indictor, qualified w/ da_byp...
assign sa_rdy_o = (da_byp & rram_sa_rdy);

assign fsm_state = curr_state;

endmodule
