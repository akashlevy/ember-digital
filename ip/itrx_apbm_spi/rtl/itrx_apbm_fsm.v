// --------------------------------------------------------------------------
// ======================= COPYRIGHT NOTICE =================================
// --------------------------------------------------------------------------
//                Copyright 2019 © Intrinsix Corp. - All Rights Reserved
//                  Intrinsix Corp. Proprietary and Confidential 
//
// Intrinsix Corp. owns the sole copyright to this software. Under
// international copyright laws you (1) may not make a copy of this software
// except for the purposes of maintaining a single archive copy, (2) may not
// derive works herefrom, (3) may not distribute this work to others. These
// rights are provided forinformation clarification, other restrictions of
// rights may apply as well.
//
// This is an unpublished work.
//
// =========================== Warrantee ====================================
// --------------------------------------------------------------------------
// Intrinsix Corp. MAKES NO WARRANTY OF ANY KIND WITH REGARD TO THE USE OF
// THIS SOFTWARE, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO,
// THE IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR
// PURPOSE.
//
// Description: APB Finite State Machine
// Author:      Bill Elliott
// Filename:    $Id$
// Date:        $Date$
// Revisions:   $Log$

module itrx_apbm_fsm
#(
  parameter ADDR_BITS_N = 5,
            DATA_BITS_M = 8
)
(
  // SPI Slave Inputs
  sclk,          // SPI clock
  pclk_re_e,     // APB clock rising edge indicator
  rst_n,         // Async reset
  // Handshaking with SPI FSM
  trans_start,   // Start an APB transfer
  trans_done,    // Signal that APB transfer is done
  assert_preset, // Address matches reset address
  // APB Inputs From Slave
  pready,        // APB slave is ready for transfer
  // APB Master Outputs
  preset_n,      // APB slave reset
  psel,          // APB slave select
  penable       // APB slave enable
);

  //-----------------------------------------------------------------------------
  //-- I/O
  //-----------------------------------------------------------------------------
  input  sclk;
  input  pclk_re_e;
  input  rst_n;
  input  trans_start;
  output trans_done;
  input  assert_preset;
  input  pready;
  output preset_n;
  output psel;
  output penable;

  //-------------------------------------------------------------------
  //-- Local Parameters
  //-------------------------------------------------------------------
  // APB_SM States
  localparam APB_FSM_BITS   = 2;
  localparam [(APB_FSM_BITS-1):0] 
              APB_FSM_IDLE   = 0,
              APB_FSM_SETUP  = 1,
              APB_FSM_ACCESS = 2,
              APB_NUM_STATES = 3;

  //-----------------------------------------------------------------------------
  //-- Output Registers
  //-----------------------------------------------------------------------------
  reg psel, psel_d;
  reg penable, penable_d;
  reg preset_n, preset_n_d;

  //-----------------------------------------------------------------------------
  //-- Internal Registers
  //-----------------------------------------------------------------------------
  // State Machines
  reg [(APB_FSM_BITS-1):0] apb_st, apb_st_d;

  //-----------------------------------------------------------------------------
  // Assignment statements
  //-----------------------------------------------------------------------------
//  assign trans_done = (apb_st == APB_FSM_IDLE) || (apb_st == APB_FSM_ACCESS && pready == 1'b1);
  assign trans_done = (apb_st == APB_FSM_IDLE) || penable; // not waiting for pready, so early done signal

  // -----------------------------------------------------------------------------
  // Combinational logic
  // -----------------------------------------------------------------------------
  // -----------------------------------------------------------------------------
  // apb_sm: Handles APB accesses, specifically controlling PSEL, PENABLE.
  // -----------------------------------------------------------------------------
  always @(*) begin
    // default
    apb_st_d   = apb_st;
    psel_d     = psel;
    penable_d  = penable;
    preset_n_d = preset_n;

    case (apb_st) 
      APB_FSM_IDLE: if (trans_start) 
        begin
           apb_st_d = APB_FSM_SETUP;
        end
      APB_FSM_SETUP: 
        begin
           apb_st_d = APB_FSM_ACCESS;
        end
      APB_FSM_ACCESS: 
        if (assert_preset || ~preset_n) 
          begin
             apb_st_d = APB_FSM_IDLE;
          end
        else if (pready) 
          if (trans_start)
            begin
               apb_st_d = APB_FSM_SETUP;
            end
          else
            begin
               apb_st_d = APB_FSM_IDLE;
            end
      default: begin
          apb_st_d = APB_FSM_IDLE;
      end
    endcase

    case (apb_st_d) 
      APB_FSM_IDLE: begin
        psel_d     = 1'b0;
        penable_d  = 1'b0;
        preset_n_d = 1'b1;
      end
      APB_FSM_SETUP: begin
        psel_d     = 1'b1;
        penable_d  = 1'b0;
        preset_n_d = ~assert_preset;
      end
      APB_FSM_ACCESS: begin
        psel_d     = 1'b1;
        penable_d  = 1'b1;
        preset_n_d = ~assert_preset;
      end
      default: begin
        psel_d    = 1'b0;
        penable_d = 1'b0;
        preset_n_d = 1'b1;
      end
    endcase
  end

  // -----------------------------------------------------------------------------
  // Clocked logic
  // -----------------------------------------------------------------------------
  always @ (posedge sclk or negedge rst_n)
  begin
    if (!rst_n) begin
      apb_st   <= APB_FSM_IDLE;
      psel     <= 1'b0;
      penable  <= 1'b0;
      preset_n <= 1'b1;
    end
    else begin
      apb_st   <= pclk_re_e ? apb_st_d : apb_st;
      psel     <= pclk_re_e ? psel_d : psel;
      penable  <= pclk_re_e ? penable_d : penable;
      preset_n <= pclk_re_e ? preset_n_d : preset_n;
    end
  end

endmodule
