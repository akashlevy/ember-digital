#-*-Makefile-*-

##########################################
# Makefile to run RTL simulations
##########################################

# Project name
NAME    = EMBER_DIGITAL

# Modules
TOP     = fsm
TOP_TB  = $(TOP)_tb

# Source file directories
SRC     = ./rtl
SRC_TB  = ./tb
SRC_ECC = ./opencores/bch_dec_enc_dcd/rtl/univ

# Source files
INC_FILE                =       $(SRC)/$(TOP).f
TB_INC_FILE             =       $(SRC_TB)/$(TOP)/$(TOP_TB).f
SRC_FILES_VERILOG       =       $(SRC)/$(TOP)*.v
SRC_FILES_VERILOG_TB    =       $(SRC_TB)/$(TOP)/*.sv

# Compilers
XRUN = xrun

# Work library
WORK = -work work

# Options
OPT             = -sv -access +rwc -timescale 1ns/1ps -64bit -seed random -disable_sem2009 -nowarn RNDXCELON:PRUASZ:CUVWSB:CLDMIN:TRNNOP:RECOME

# Use appropriate source files for ECC blocks
ifeq ($(TOP),bch_dec)
	INC_FILE                =       $(SRC_TB)/$(TOP)/$(TOP).f
	SRC_FILES_VERILOG       =       $(SRC_ECC)/$(TOP)*.v
endif

# Ignore output disconnections for spi_slave_rram
ifeq ($(TOP),spi_slave_rram)
	OPT 					= -sv -access +rwc -timescale 1ns/1ps -64bit -seed random -disable_sem2009 -nowarn RNDXCELON:PRUASZ:CUVWSB:CLDMIN:TRNNOP:RECOME:CUVWSP
endif 

# Targets
all : sim

sim : export SHM_UNPACKED_LIMIT = 3145728

sim : $(SRC_FILES_VERILOG) $(SRC_FILES_VERILOG_TB)
	$(XRUN) -top $(TOP_TB) $(OPT) -f $(INC_FILE) -f $(TB_INC_FILE) $(WORK) $^

lib : lib/libgen.py lib/analog_rram.lib lib/analog_rram.tmpl.lib lib/analog_rram.db 

lib/libgen.py lib/analog_rram.lib lib/analog_rram.tmpl.lib lib/analog_rram.db:
	cd lib && python3 libgen.py && lc_shell -f compile.tcl

virtuoso : $(SRC_FILES_VERILOG) $(SRC_FILES_VERILOG_TB)
	echo "$(OPT) -f $(INC_FILE) -f $(TB_INC_FILE)" > /tmp/opts
	rm -f $(SRC_TB)/$(TOP)/$(TOP_TB)_combined.sv
	cat $(SRC)/globals.v $(SRC)/*.v $(SRC)/*.sv $(SRC_TB)/$(TOP)/*.sv > $(SRC_TB)/$(TOP)/$(TOP_TB)_combined.sv
	cdsTextTo5x -CELL $(TOP_TB) -CDSLIB cds.lib -LANG systemverilog -LIB ember_sv_tb -VIEW systemVerilog -LOG virtuoso_import.log $(SRC_TB)/$(TOP)/$(TOP_TB)_combined.sv

saif : sim 
	vcd2saif -input dump.vcd -output saif/run.saif -instance rram_top_tb/dut

clean :
	rm -rf *log *.history outfile xrun.key *.err xcelium.d waves.shm *.diag *.vcd *.vpd DVEfiles/ novas.* verdiLog/ dump.* .bpad/ tb/fsm/fsm_tb_combined.sv cds.lib ember_sv_tb/ .cadence/ lfsr_tb_vecgen_*.txt