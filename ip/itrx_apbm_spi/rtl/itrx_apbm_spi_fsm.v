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
// Description: SPI to APB
// Author:      Dave Charneski, Bill Elliott
// Filename:    $Id$
// Date:        $Date$
// Revisions:   $Log$

module itrx_apbm_spi_fsm
#(
  parameter ADDR_BITS_N = 3,
            DATA_BITS_M = 8,
            APB_RST_ADDR = 0,
            APB_RST_DATA = 0,
            APB_RST_RO = 1,
            CPHA_MODE = 1
)
(
  // SPI Slave Inputs
  sclk,          // SPI clock
  rst_n,         // Async reset
  mosi,          // SPI master out, slave in
  // APB FSM interface
  trans_start,   // Signal to start an APB transfer
  trans_done,    // Signal that APB transfer is done
  assert_preset, // Signal to send an APB bus reset
  // Clk divider interface
  pclk_re_e,     // Early indicator of pclk rising edge
  // APB Inputs From Slave
  prdata,        // APB slave read data
  // SPI Slave Outputs
  miso_data_out, // SPI master in, slave out data
  miso_oe_n,     // SPI master in, slave out output enable
  // APB Master Outputs
  paddr,         ///APB slave address
  pwdata,        // APB write data
  pwrite,        // APB write/read control
  pwrite_e       // APB write/read control, 1/2 clock cycle early
);

  //-------------------------------------------------------------------
  //-- SPI APB parameters.
  //-------------------------------------------------------------------
  `include "itrx_clog2.vh"

  //-------------------------------------------------------------------
  //-- I/O
  //-------------------------------------------------------------------
  input sclk;
  input rst_n;
  input mosi;
  output trans_start;
  input  trans_done;
  output assert_preset;
  input pclk_re_e;
  input [(DATA_BITS_M-1):0] prdata;
  output miso_data_out;
  output miso_oe_n;
  output [(ADDR_BITS_N-1):0] paddr;
  output [(DATA_BITS_M-1):0] pwdata;
  output pwrite;
  output pwrite_e;

  //-------------------------------------------------------------------
  //-- Local Parameters
  //-------------------------------------------------------------------
  // localparams based on input params
  // TODO : use one bit counter, whichever is largest
  localparam ADDR_BIT_CTR_WIDTH = `ITRX_CLOG2(ADDR_BITS_N);
  localparam DATA_BIT_CTR_WIDTH = `ITRX_CLOG2(DATA_BITS_M);

  // SPI States
  localparam SPI_FSM_BITS = 3;
  localparam [(SPI_FSM_BITS-1):0]
              SPI_FSM_IDLE        = 0,
              SPI_FSM_RW_SAMP     = 1,
              SPI_FSM_ADDR        = 2,
              SPI_FSM_TRANS_START = 3,
              SPI_FSM_TRANS_WAIT  = 4,
              SPI_FSM_DATA        = 5,
              SPI_FSM_DONE        = 6,
              SPI_NUM_STATES      = 7;

  //-----------------------------------------------------------------------------
  //-- Output Registers
  //-----------------------------------------------------------------------------
  reg trans_start;
  reg assert_preset, assert_preset_d;
  reg miso_oe_n, miso_oe_n_d;
  reg [(ADDR_BITS_N-1):0] paddr, paddr_d;
  reg [(DATA_BITS_M-1):0] pwdata, pwdata_d;
  reg pwrite, pwrite_d;
  
  wire pclk_re_e, pwrite_e;  // lint checking -- dpm
   
  //-----------------------------------------------------------------------------
  //-- Internal Registers
  //-----------------------------------------------------------------------------
  // State Machines
  reg [(SPI_FSM_BITS-1):0] spi_st, spi_st_d;

  // General
  reg mosi_ne;  // sampled mosi data
  // TODO : use one bit ctr, whichever size is largest
  reg [(ADDR_BIT_CTR_WIDTH-1):0] addr_bit_ctr, addr_bit_ctr_d;
  reg [(DATA_BIT_CTR_WIDTH-1):0] data_bit_ctr, data_bit_ctr_d;
  reg [(DATA_BITS_M-1):0] prdata_sr, prdata_sr_d;

  //-----------------------------------------------------------------------------
  //-- Assign Local Regs to Ports
  //-----------------------------------------------------------------------------
  assign miso_data_out = prdata_sr[DATA_BITS_M-1]; // MSB of prdata_sr shifted out via spi_rd_fsm
  assign pwrite_e = pwrite | pwrite_d;

  // -----------------------------------------------------------------------------
  // Combinational Logic
  // -----------------------------------------------------------------------------
  // LINT complains that SPI_FSM_DONE is a terminal state
  // This is by design, When spi cs is asserted, reset to the FSM is asserted and 
  // the FSM exits SPI_FSM_DONE. So ignore this error -- dpm
  // lint_checking TERMST off
  always @(*) begin
    // defaults
    spi_st_d        = spi_st;
    addr_bit_ctr_d  = addr_bit_ctr;
    data_bit_ctr_d  = data_bit_ctr;
    trans_start     = 1'b0;
    miso_oe_n_d     = 1'b1;
    pwdata_d        = pwdata;
    prdata_sr_d     = prdata_sr;
    paddr_d         = paddr;
    pwrite_d        = pwrite;
    assert_preset_d = 1'b0;

    // assume all bit counters are set in reset (CS_N)
    case (spi_st)
      SPI_FSM_IDLE:    spi_st_d = SPI_FSM_RW_SAMP;
      SPI_FSM_RW_SAMP: begin
        spi_st_d     = SPI_FSM_ADDR;
        pwrite_d     = mosi_ne; 
      end
      SPI_FSM_ADDR: begin
        paddr_d = {paddr[(ADDR_BITS_N-2):0],mosi_ne};
        if (!(|addr_bit_ctr)) begin  
          if (pwrite)
            begin 
               spi_st_d = SPI_FSM_DATA;
            end
          else
            begin
               spi_st_d = SPI_FSM_TRANS_START;
            end
           
        end
        else 
          begin
             addr_bit_ctr_d = addr_bit_ctr - 1;
          end // else: !if(~(|addr_bit_ctr))
         
      end
      SPI_FSM_DATA: begin
        if (pwrite)
          begin
             pwdata_d    = {pwdata[(DATA_BITS_M-2):0],mosi_ne};
          end
        else
          begin
             prdata_sr_d = {prdata_sr[(DATA_BITS_M-2):0],1'b0};
          end
        if (!(|data_bit_ctr)) begin
          if (pwrite)
            begin
               spi_st_d = SPI_FSM_TRANS_START;
            end
          else 
            begin
               spi_st_d = SPI_FSM_DONE;
            end         
        end
        else begin
          data_bit_ctr_d = data_bit_ctr - 1;
        end
      end
      SPI_FSM_TRANS_START: 
        if (!trans_done)  
          begin   
             spi_st_d = SPI_FSM_TRANS_WAIT;
          end        
      SPI_FSM_TRANS_WAIT: begin
        if (trans_done && pclk_re_e) begin  
          if (pwrite)
            begin  
               spi_st_d = SPI_FSM_DONE;
            end  
          else begin
            spi_st_d    = SPI_FSM_DATA;
          end
        end
        if (~pwrite && pclk_re_e)  
          begin  
             prdata_sr_d = ((paddr == APB_RST_ADDR) && APB_RST_RO) ? APB_RST_DATA : prdata;  
          end  
      end
      SPI_FSM_DONE:
        begin 
           spi_st_d = SPI_FSM_DONE; // nop
        end  
      
      default: 
        begin         
           spi_st_d = SPI_FSM_IDLE;
        end  
    endcase

    case (spi_st_d)
      SPI_FSM_IDLE:    ;
      SPI_FSM_RW_SAMP: ;
      SPI_FSM_ADDR:    ;
      SPI_FSM_DATA: if (!pwrite)
        begin
           miso_oe_n_d = 1'b0;
        end
      SPI_FSM_TRANS_START: begin
        if (pwrite && paddr == APB_RST_ADDR)
          begin    
             assert_preset_d = 1'b1;
          end    
        trans_start = 1'b1; 
      end
      SPI_FSM_TRANS_WAIT: begin
        if (pwrite && paddr == APB_RST_ADDR)
          begin
             assert_preset_d = 1'b1; 
          end
      end
      SPI_FSM_DONE: ;
      default:      ;
    endcase
  end 
  
  // -----------------------------------------------------------------------------
  // Clocked logic
  // -----------------------------------------------------------------------------
  always @(posedge sclk or negedge rst_n) begin
    if (!rst_n) begin
      spi_st        <= CPHA_MODE ? SPI_FSM_IDLE : SPI_FSM_RW_SAMP;
      paddr         <= {ADDR_BITS_N{1'b0}};
      pwdata        <= {DATA_BITS_M{1'b0}};
      prdata_sr     <= {DATA_BITS_M{1'b0}};
      addr_bit_ctr  <= ADDR_BITS_N-1;
      data_bit_ctr  <= DATA_BITS_M-1;
      pwrite        <= 1'b0;
      assert_preset <= 1'b0;
      miso_oe_n     <= 1'b1;
    end 
    else begin
      spi_st        <= spi_st_d;
      paddr         <= paddr_d;
      pwdata        <= pwdata_d;
      prdata_sr     <= prdata_sr_d;
      addr_bit_ctr  <= addr_bit_ctr_d;
      data_bit_ctr  <= data_bit_ctr_d;
      pwrite        <= pwrite_d;
      assert_preset <= assert_preset_d;
      miso_oe_n     <= miso_oe_n_d;
    end
  end  
 
  // capture input data on the negedge 
  always @(negedge sclk or negedge rst_n)
    if (!rst_n) 
      begin  
         mosi_ne <= 0;
      end  
    else
      begin  
        mosi_ne <= mosi;
      end  
endmodule
