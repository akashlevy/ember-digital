// RRAM Array Behavioral Model
module rram_behavioral (
   // Digital ports...
   input                     RRAM_MAN,       // (I) Manual Mode indicator
   input                     RRAM_ACLK,      // (I) Clock/Strobe
   input                     RRAM_EN,        // (I) Enable
   input                     RRAM_BLDIS,     // (I) Bit-line discharge control
   input                     RRAM_SET_FORM,  // (I) Access type select WRITE or FORM
   input                     RRAM_SET_RST,   // (I) WRITE type SET or RESET
   input                     RRAM_READ_MODE, // (I) Read mode type READ or VERIFY
   input                     RRAM_WE,        // (I) Write Enable
   input [16:0]              RRAM_ADDR,      // (I) Address
   input [15:0]              RRAM_DI,        // (I) Data input (need for read/verify)

   input                     RRAM_SA_EN,     // (I) readout circuit enable
   input                     RRAM_SA_CLK,    // (I) readout circuit clock (TODO: needed?)
   output wire               RRAM_SA_RDY,    // (O) readout circuit ready indicator (TODO: needed?)

   output wire [15:0]        RRAM_DO,        // (O) Data output

   input                     RRAM_REF_MODE,  // (I) SET_REF_CONFIG_REG: current source mode for SET, RESET, READ operations
   input [`BSL_DAC_WIDTH:0]  RRAM_SET_REF,   // (I) current reference parameter for SET operation
   input [6:0]               RRAM_RESET_REF, // (I) current reference parameter for RESET operation
   input [6:0]               RRAM_READ_REF,  // (I) current reference parameter for READ operation

  // Analog/power ports
`ifdef POWER_PINS
                   inout              VSS,
                   inout              VDD,
`endif
                   inout              VSA
                   );

   bit enableWarnings = 1;
   bit enableErrors = 1;

   // Memory Array variables
   rramFormed [15:0] memState      [0:'h11fff]       = '{default:RAM_UNFORMED}; // Memory Array Formed State
   rramErrorState    memErrorState [0:'h11fff][15:0] = '{default:0};            // Memory Error State
   reg        [15:0] mem           [0:'h11fff]       = '{default:0};            // Memory Array  itself

   // Temporary State for Output pins
   reg        [15:0] dataOut;
   reg               saRdy     = 1;
   
   // State Machine Counter
   reg [ 2:0]        clkCount  = 0;

   specify                                                 // Specify Timing for model
      specparam TaddrSU       = 12ns  ;  // was 6ns
      specparam TaddrSUse     = 85ns  ;  // was 19ns
      //             TreadMore
      specparam Tbldis        = 20ns  ;
      specparam TenHIseHI     = 78ns  ;  // was 18ns
      specparam TseLOenLO     = 5ns   ;  // was 3ns
      specparam TseSU         = 48ns  ;
      specparam Tset          = 20ns  ;
      specparam Trst          = 20ns  ;
      specparam TenLOweLO     = 13.5ns;  // was 7ns
      specparam TweHIenHI     = 5ns   ;
      specparam TacLOenLO     = 6ns   ;  // was 4ns
      specparam TenHIacHI     = 46.5ns;  // was 12ns
      specparam Tclk1HIrdyLO  = 8ns   ;  // was 6ns
      specparam Tclk4HIrdyHI  = 9ns   ;  // was 6ns
      specparam TenLOweHI     = 13.5ns;  // was 6ns
      specparam TdataSU       = ((TweHIenHI + TenHIacHI):20ns:(TenLOweHI + TweHIenHI + TenHIacHI));
      specparam TdataHLD      = TacLOenLO + TenLOweLO ;
      specparam TblLOenHI     = TaddrSU  ;
      specparam TenLOblHI     = TenLOweLO ;
      specparam TdoCAP        = 40ns  ;
      specparam Tread         = TenHIseHI + TseSU + 3*(20) + Tclk4HIrdyHI + TdoCAP + TseLOenLO;
      specparam TacLOsrLO     = TdataHLD ;
      specparam TsrLOacHI     = TdataSU;
      specparam TacPer        = 20ns  ;
      specparam TacWidLo      = 10ns  ;
      specparam TscPer        = 20ns  ;
      specparam TscWidLo      = 10ns  ;

      specparam TclkNHIrdyLO  = 9ns   ; // was 6ns

      // KA: break out any combined setuphold; change recovery to corresponding setup or hold...
      $setup     (posedge RRAM_ADDR     , posedge RRAM_EN       , TaddrSU  );
      $setup     (negedge RRAM_ADDR     , posedge RRAM_EN       , TaddrSU  );
      $setup     (posedge RRAM_READ_MODE, posedge RRAM_EN       , TaddrSU  );
      $setup     (negedge RRAM_READ_MODE, posedge RRAM_EN       , TaddrSU  );
      $setup     (posedge RRAM_MAN      , posedge RRAM_EN       , TaddrSU  );
      $setup     (negedge RRAM_MAN      , posedge RRAM_EN       , TaddrSU  );

      $setup     (posedge RRAM_ADDR     , posedge RRAM_SA_EN    , TaddrSUse);
      $setup     (negedge RRAM_ADDR     , posedge RRAM_SA_EN    , TaddrSUse);

      $setup     (posedge RRAM_DI       , posedge RRAM_ACLK     , TdataSU  );
      $setup     (negedge RRAM_DI       , posedge RRAM_ACLK     , TdataSU  );
      $hold      (negedge RRAM_ACLK     , posedge RRAM_DI       , TdataHLD );
      $hold      (negedge RRAM_ACLK     , negedge RRAM_DI       , TdataHLD );


      $setup     (negedge RRAM_BLDIS    , posedge RRAM_EN       , TblLOenHI);
      $hold      (negedge RRAM_EN       , posedge RRAM_BLDIS    , TenLOblHI);

      $setup     (posedge RRAM_EN       , posedge RRAM_SA_EN    , TenHIseHI);
      $hold      (negedge RRAM_SA_EN    , negedge RRAM_EN       , TseLOenLO);

      $setup     (posedge RRAM_SA_EN    , posedge RRAM_SA_CLK   , TseSU    );

      // KA: TdoCAP not a .lib parameter...
      $recovery  (posedge RRAM_SA_RDY   , negedge RRAM_SA_EN    , TdoCAP   );

      $hold      (negedge RRAM_EN       , posedge RRAM_WE       , TenLOweHI);
      $hold      (negedge RRAM_EN       , negedge RRAM_WE       , TenLOweLO);
      $hold      (negedge RRAM_EN       , posedge RRAM_SET_FORM , TenLOweHI);
      $hold      (negedge RRAM_EN       , negedge RRAM_SET_FORM , TenLOweLO);
      $hold      (negedge RRAM_EN       , posedge RRAM_SET_RST  , TenLOweHI);
      $hold      (negedge RRAM_EN       , negedge RRAM_SET_RST  , TenLOweLO);

      $hold      (posedge RRAM_EN       , negedge RRAM_READ_MODE, TenLOweHI);
      $hold      (posedge RRAM_EN       , negedge RRAM_MAN      , TenLOweLO);

      $setup     (posedge RRAM_WE       , posedge RRAM_EN       , TweHIenHI);
      $setup     (posedge RRAM_SET_FORM , posedge RRAM_EN       , TweHIenHI);
      $setup     (posedge RRAM_SET_RST  , posedge RRAM_EN       , TweHIenHI);

      $setup     (negedge RRAM_SET_RST  , posedge RRAM_ACLK     , TsrLOacHI);
      $hold      (negedge RRAM_ACLK     , negedge RRAM_SET_RST  , TacLOsrLO);

      $setup     (posedge RRAM_EN       , posedge RRAM_ACLK     , TenHIacHI);
      $hold      (negedge RRAM_ACLK     , negedge RRAM_EN       , TacLOenLO);

      $period    (posedge RRAM_ACLK     ,                         TacPer   );
      $width     (negedge RRAM_ACLK     ,                         TacWidLo );
      $period    (posedge RRAM_SA_CLK   ,                         TscPer   );
      $width     (negedge RRAM_SA_CLK   ,                         TscWidLo );

      // KA: TclkNHIrdyLO not a .lib parameter...
      $recovery  (posedge RRAM_SA_CLK &&& clkCount===0, negedge RRAM_SA_RDY, Tclk1HIrdyLO      );
      $recovery  (posedge RRAM_SA_CLK &&& clkCount===3, posedge RRAM_SA_RDY, Tclk4HIrdyHI      );

      $width     (posedge RRAM_EN &&& RRAM_WE === 0     , Tread             );
//    $width     (edge RRAM_ADDR &&&  RRAM_EN === 1     , TreadMore         );
      $width     (posedge RRAM_BLDIS                    , Tbldis            );
      $width     (posedge RRAM_ACLK &&& RRAM_SET_RST===1, Tset              );
      $width     (posedge RRAM_ACLK &&& RRAM_SET_RST===0, Trst              );

      // RRAM_DO, RRAM_SA_RDY delay from SA_CLK edge...
      (posedge RRAM_SA_CLK => (RRAM_DO:16'hxxxx))=(TclkNHIrdyLO, TclkNHIrdyLO);
      (posedge RRAM_SA_CLK => (RRAM_SA_RDY:1'bx))=(TclkNHIrdyLO, TclkNHIrdyLO);

   endspecify                                 // End of Specify BLock.

   // assign output pins
   assign RRAM_DO      = dataOut;
   assign RRAM_SA_RDY  = saRdy & RRAM_EN;
   
   always @(posedge RRAM_ACLK) begin
      if (RRAM_EN) begin
         if (RRAM_WE && RRAM_SET_FORM && RRAM_SET_RST) begin // FORM Operation
            foreach (memState[RRAM_ADDR][i]) begin
               if (RRAM_DI[i] == 1) begin
                  if (memState[RRAM_ADDR][i] == RAM_FORMED)
                     if (enableErrors) 
                        $error($sformatf("Attempting to FORM an already FORMed RAM location at %0x bit %2d", RRAM_ADDR, i));
                     else if (enableWarnings)
                        $warning($sformatf("Attempting to FORM an already FORMed RAM location at %0x bit %2d", RRAM_ADDR, i));
                     else
                        $info($sformatf("Attempting to FORM an already FORMed RAM location at %0x bit %2d", RRAM_ADDR, i));
                  
                  if (memErrorState[RRAM_ADDR][i].forceCount == 0) begin
                     mem[RRAM_ADDR][i] = 1;
                     memState[RRAM_ADDR][i] = RAM_FORMED;
                  end else begin // if (memErrorState[RRAM_ADDR][i].forceCount == 0)
                     mem[RRAM_ADDR][i] = memErrorState[RRAM_ADDR][i].forcedValue;
                     if (memErrorState[RRAM_ADDR][i].forcedValue == 1)
                        memState[RRAM_ADDR][i]  = RAM_FORMED;
                     else
                        memErrorState[RRAM_ADDR][i].forceCount--;
                  end // else: !if(memErrorState[RRAM_ADDR][i].forceCount == 0)
               end // if (RRAM_DI[i] == 1)
            end // foreach (rramStates[rram_addr][i])
         end // if (WE && SET_FORM && SET_RST)

         if (RRAM_WE && ~RRAM_SET_FORM && RRAM_SET_RST) begin // WRITE One (SET)
            foreach (memState[RRAM_ADDR][i]) begin
               if (memState[RRAM_ADDR][i] == RAM_UNFORMED)
                  if (enableErrors) 
                     $error($sformatf("Attempting to SET an unFORMed RAM location, %x", RRAM_ADDR));
                  else if (enableWarnings)
                     $warning($sformatf("Attempting to SET an unFORMed RAM location, %x", RRAM_ADDR));
                  else 
                     $info($sformatf("Attempting to SET an unFORMed RAM location, %x", RRAM_ADDR));
               else begin
                  if (RRAM_DI[i] == 1) begin
                     if (mem[RRAM_ADDR][i] == 1) 
                        if (enableErrors) 
                           $error("Attempting to SET an already SET RAM location");
                        else if (enableWarnings)
                           $warning("Attempting to SET an already SET RAM location");
                        else
                           $info("Attempting to SET an already SET RAM location");

                     if (memErrorState[RRAM_ADDR][i].forceCount == 0) begin
                        mem[RRAM_ADDR][i]       = 1;
                     end else begin // if (memErrorState[RRAM_ADDR][i].forceCount == 0)
                        mem[RRAM_ADDR][i]       = memErrorState[RRAM_ADDR][i].forcedValue;
                        memErrorState[RRAM_ADDR][i].forceCount--;
                     end // else: !if(memErrorState[RRAM_ADDR][i].forceCount == 0)
                  end // if (RRAM_DI[i] == 1)
               end // else: !if((memState[RRAM_ADDR][i] == RAM_UNFORMED) && enableErrors)
            end // foreach (memState[rram_addr][i])
         end // if (RRAM_WE && ~RRAM_SET_FORM && RRAM_SET_RST)
         
         if (RRAM_WE && ~RRAM_SET_FORM && ~RRAM_SET_RST) begin // WRITE Zero (RESET)
            foreach (memState[RRAM_ADDR][i]) begin
               if (memState[RRAM_ADDR][i] == RAM_UNFORMED)
                  if (enableErrors) 
                     $error("Attempting to RESET an unFORMed RAM location");
                  else if (enableWarnings)
                     $warning("Attempting to RESET an unFORMed RAM location");
                  else
                     $info("Attempting to RESET an unFORMed RAM location");

               else begin
                  if (RRAM_DI[i] == 0) begin
                     if (mem[RRAM_ADDR][i] == 0)
                        if (enableErrors) 
                           $error("Attempting to RESET an already RESET RAM location");
                        else if (enableWarnings)
                           $warning("Attempting to RESET an already RESET RAM location");
                        else
                           $info("Attempting to RESET an already RESET RAM location");

                     if (memErrorState[RRAM_ADDR][i].forceCount == 0) begin
                        mem[RRAM_ADDR][i]       = 0;
                     end else begin // if (memErrorState[RRAM_ADDR][i].forceCount == 0)
                        mem[RRAM_ADDR][i]       = memErrorState[RRAM_ADDR][i].forcedValue;
                        memErrorState[RRAM_ADDR][i].forceCount--;
                     end // else: !if(memErrorState[RRAM_ADDR][i].forceCount == 0)
                  end // if (RRAM_DI[i] == 0)
               end // else: !if((memState[RRAM_ADDR][i] == RAM_UNFORMED) && enableErrors)
            end // foreach (memState[RRAM_ADDR][i])
         end // if (RRAM_WE && ~RRAM_SET_FORM && ~RRAM_SET_RST)
      end // if (RRAM_EN)
   end // always @ (posedge RRAM_ACLK)

   always @(posedge RRAM_SA_EN) begin
      clkCount  = 0;            // Reset Counter for new Read to take place
   end

   always @(negedge RRAM_EN) begin
      dataOut = '0;             // Ram not enabled, data not driven
   end

   always @(posedge RRAM_SA_CLK) begin
      if (RRAM_SA_EN & RRAM_EN) begin
         if (clkCount == 0) begin
            dataOut = 16'hFFFF;
            saRdy = 0;          // Deassert SARDY to user
         end
         else if (clkCount >= 3) begin
            dataOut = mem[RRAM_ADDR]; // Drive Data to User
            saRdy   = 1;         // Reassert SARDY to user
         end // if (clkCount >= 3)
         else begin
            saRdy = 0;          // Deassert SARDY to user
         end // else: !if(clkCount >= 3)
      end // if (RRAM_EN)
      clkCount++;
   end // always @ (posedge rram_read_start)

   // Support Functions
   //
   // setErrorState - Control each individual bit in the RRAM Array.
   //                 This forces a value onto the bit for the number of write/form accesses designated by forceCount.
   //                 When the forceCount is non-zero, then sets/resets/forms to the bit will be ignored, 
   //                 and the forceCount will be decremented instead.
   //                 Using this function, the error counting mechanisms of the FSM can be tested.
   
   function void setErrorState(reg [3:0 ] bitNum,       // The specific bit in the addressed word
                               reg [16:0] addr,         // The address of the bitword in question
                               bit        forcedValue,  // The value the bit should be stuck at (0,1)
                               int        forceCount);  // The number of write/form accesses that the bit will be stuck for.
      memErrorState[addr][bitNum].forcedValue = forcedValue;
      memErrorState[addr][bitNum].forceCount  = forceCount;
   endfunction : setErrorState
   
   // getErrorsEnable - This function check the state of the enableErrors setting.
   function bit getErrorsEnable();          // return state of enableErrors
      getErrorsEnable = enableErrors;
   endfunction : getErrorsEnable

   // getwarningsEnable - This function check the state of the enableWarnings setting.
   function bit getWarningsEnable();        // return state of enableWarnings
      getWarningsEnable = enableWarnings;
   endfunction : getWarningsEnable

   // setErrorsEnable - This function is used to enable/disable error printing in the model.
   //                   Error printing is enabled by default.
   //                   When disabled, errors are reduced to warnings.
   function void setErrorsEnable(bit enable=1);          // Enable bit for error printing
      enableErrors = enable;
   endfunction : setErrorsEnable

   // setwarningsEnable - This function is used to enable/disable warning printing in the model.
   //                     Warning printing is enabled by default.
   //                     When disabled, warnings are reduced to info messages.
   function void setWarningsEnable(bit enable=1);        // Enable bit for warning printing
      enableWarnings = enable;
   endfunction : setWarningsEnable

endmodule: rram_1p1Mb

// This module turns individual signals into busses and passes to behavioural model above

module rram_1p1Mb_scalar (
                          input       RRAM_MAN,         // (I) Manual Mode indicator
                          input       RRAM_ACLK,        // (I) Clock/Strobe
                          input       RRAM_EN,          // (I) Enable
                          input       RRAM_BLDIS,       // (I) Bit-line discharge control
                          input       RRAM_SET_FORM,    // (I) Access type select WRITE or FORM
                          input       RRAM_SET_RST,     // (I) WRITE type SET or RESET
                          input       RRAM_READ_MODE,   // (I) Read mode type READ or VERIFY
                          input       RRAM_WE,          // (I) Write Enable
                          input       RRAM_ADDR_16,     // (I) Address
                          input       RRAM_ADDR_15, 
                          input       RRAM_ADDR_14, 
                          input       RRAM_ADDR_13, 
                          input       RRAM_ADDR_12, 
                          input       RRAM_ADDR_11, 
                          input       RRAM_ADDR_10, 
                          input       RRAM_ADDR_09, 
                          input       RRAM_ADDR_08, 
                          input       RRAM_ADDR_07, 
                          input       RRAM_ADDR_06, 
                          input       RRAM_ADDR_05, 
                          input       RRAM_ADDR_04, 
                          input       RRAM_ADDR_03, 
                          input       RRAM_ADDR_02, 
                          input       RRAM_ADDR_01, 
                          input       RRAM_ADDR_00, 
                          input       RRAM_DI_15,       // (I) Data input mask
                          input       RRAM_DI_14, 
                          input       RRAM_DI_13, 
                          input       RRAM_DI_12, 
                          input       RRAM_DI_11, 
                          input       RRAM_DI_10, 
                          input       RRAM_DI_09, 
                          input       RRAM_DI_08, 
                          input       RRAM_DI_07, 
                          input       RRAM_DI_06, 
                          input       RRAM_DI_05, 
                          input       RRAM_DI_04, 
                          input       RRAM_DI_03, 
                          input       RRAM_DI_02, 
                          input       RRAM_DI_01, 
                          input       RRAM_DI_00, 

                          input       RRAM_SA_EN,       // (I) readout circuit enable
                          input       RRAM_SA_CLK,      // (I) readout circuit clock
                          output wire RRAM_SA_RDY,      // (O) readout circuit ready indicator

                          output wire RRAM_DO_15,       // (O) Data output
                          output wire RRAM_DO_14,
                          output wire RRAM_DO_13,
                          output wire RRAM_DO_12,
                          output wire RRAM_DO_11,
                          output wire RRAM_DO_10,
                          output wire RRAM_DO_09,
                          output wire RRAM_DO_08,
                          output wire RRAM_DO_07,
                          output wire RRAM_DO_06,
                          output wire RRAM_DO_05,
                          output wire RRAM_DO_04,
                          output wire RRAM_DO_03,
                          output wire RRAM_DO_02,
                          output wire RRAM_DO_01,
                          output wire RRAM_DO_00,

                          input       RRAM_REF_MODE,    // (I) SET_REF_CONFIG_REG: current source mode for SET, RESET, READ operations
                          input       RRAM_SET_REF_6,   // (I) current reference parameter for SET operation
                          input       RRAM_SET_REF_5,
                          input       RRAM_SET_REF_4,
                          input       RRAM_SET_REF_3,
                          input       RRAM_SET_REF_2,
                          input       RRAM_SET_REF_1,
                          input       RRAM_SET_REF_0,
                          input       RRAM_RESET_REF_6, // (I) current reference parameter for RESET operation
                          input       RRAM_RESET_REF_5,
                          input       RRAM_RESET_REF_4,
                          input       RRAM_RESET_REF_3,
                          input       RRAM_RESET_REF_2,
                          input       RRAM_RESET_REF_1,
                          input       RRAM_RESET_REF_0,
                          input       RRAM_READ_REF_6,  // (I) current reference parameter for READ operation
                          input       RRAM_READ_REF_5,
                          input       RRAM_READ_REF_4,
                          input       RRAM_READ_REF_3,
                          input       RRAM_READ_REF_2,
                          input       RRAM_READ_REF_1,
                          input       RRAM_READ_REF_0,
  // Analog/power ports...
                          inout       VBL_SET,
                          inout       VSL_RESET,
                          inout       VBL_FORM,
                          inout       VBL_READ,
                          inout       VWL_SET,
                          inout       VWL_RESET,
                          inout       VWL_FORM,
                          inout       VWL_READ,
                          inout       VSA,
                          inout       VDD12
  );

   // Instantiate the Vectorized Behavioural model
   
   rram_1p1Mb rram_1p1Mb_beh(
                             .RRAM_MAN(RRAM_MAN),               // (I) Manual Mode indicator
                             .RRAM_ACLK(RRAM_ACLK),             // (I) Clock/Strobe
                             .RRAM_EN(RRAM_EN),                 // (I) Enable
                             .RRAM_BLDIS(RRAM_BLDIS),           // (I) Bit-line discharge control
                             .RRAM_SET_FORM(RRAM_SET_FORM),     // (I) Access type select WRITE or FORM
                             .RRAM_SET_RST(RRAM_SET_RST),       // (I) WRITE type SET or RESET
                             .RRAM_READ_MODE(RRAM_READ_MODE),   // (I) Read mode type READ or VERIFY
                             .RRAM_WE(RRAM_WE),                 // (I) Write Enable
                             .RRAM_ADDR({RRAM_ADDR_16,          // (I) Address
                                         RRAM_ADDR_15, 
                                         RRAM_ADDR_14, 
                                         RRAM_ADDR_13, 
                                         RRAM_ADDR_12, 
                                         RRAM_ADDR_11, 
                                         RRAM_ADDR_10, 
                                         RRAM_ADDR_09, 
                                         RRAM_ADDR_08, 
                                         RRAM_ADDR_07, 
                                         RRAM_ADDR_06, 
                                         RRAM_ADDR_05, 
                                         RRAM_ADDR_04, 
                                         RRAM_ADDR_03, 
                                         RRAM_ADDR_02, 
                                         RRAM_ADDR_01, 
                                         RRAM_ADDR_00
                                         }),
                             .RRAM_DI({RRAM_DI_15,              // (I) Data input mask
                                       RRAM_DI_14, 
                                       RRAM_DI_13, 
                                       RRAM_DI_12, 
                                       RRAM_DI_11, 
                                       RRAM_DI_10, 
                                       RRAM_DI_09, 
                                       RRAM_DI_08, 
                                       RRAM_DI_07, 
                                       RRAM_DI_06, 
                                       RRAM_DI_05, 
                                       RRAM_DI_04, 
                                       RRAM_DI_03, 
                                       RRAM_DI_02, 
                                       RRAM_DI_01, 
                                       RRAM_DI_00
                                       }),

                             .RRAM_SA_EN(RRAM_SA_EN),           // (I) readout circuit enable
                             .RRAM_SA_CLK(RRAM_SA_CLK),         // (I) readout circuit clock
                             .RRAM_SA_RDY(RRAM_SA_RDY),         // (O) readout circuit ready indicator

                             .RRAM_DO({RRAM_DO_15,              // (O) Data output
                                       RRAM_DO_14, 
                                       RRAM_DO_13, 
                                       RRAM_DO_12, 
                                       RRAM_DO_11, 
                                       RRAM_DO_10, 
                                       RRAM_DO_09, 
                                       RRAM_DO_08, 
                                       RRAM_DO_07, 
                                       RRAM_DO_06, 
                                       RRAM_DO_05, 
                                       RRAM_DO_04, 
                                       RRAM_DO_03, 
                                       RRAM_DO_02, 
                                       RRAM_DO_01, 
                                       RRAM_DO_00
                                       }),

                             .RRAM_REF_MODE(RRAM_REF_MODE),     // (I) SET_REF_CONFIG_REG: current source mode for SET, RESET, READ operations
                             .RRAM_SET_REF({RRAM_SET_REF_6,     // (I) current reference parameter for SET operation
                                            RRAM_SET_REF_5,
                                            RRAM_SET_REF_4,
                                            RRAM_SET_REF_3,
                                            RRAM_SET_REF_2,
                                            RRAM_SET_REF_1,
                                            RRAM_SET_REF_0
                                            }),
                             .RRAM_RESET_REF({RRAM_RESET_REF_6, // (I) current reference parameter for RESET operation
                                            RRAM_RESET_REF_5,
                                            RRAM_RESET_REF_4,
                                            RRAM_RESET_REF_3,
                                            RRAM_RESET_REF_2,
                                            RRAM_RESET_REF_1,
                                            RRAM_RESET_REF_0
                                            }),
                             .RRAM_READ_REF({RRAM_READ_REF_6,   // (I) current reference parameter for READ operation
                                            RRAM_READ_REF_5,
                                            RRAM_READ_REF_4,
                                            RRAM_READ_REF_3,
                                            RRAM_READ_REF_2,
                                            RRAM_READ_REF_1,
                                            RRAM_READ_REF_0
                                            }),
                             
                             // Analog/power ports...
                             .VBL_SET(VBL_SET),
                             .VSL_RESET(VSL_RESET),
                             .VBL_FORM(VBL_FORM),
                             .VBL_READ(VBL_READ),
                             .VWL_SET(VWL_SET),
                             .VWL_RESET(VWL_RESET),
                             .VWL_FORM(VWL_FORM),
                             .VWL_READ(VWL_READ),
                             .VSA(VSA),
                             .VDD12(VDD12)
                             );

endmodule: rram_1p1Mb_scalar
