# Makefile
# See https://docs.cocotb.org/en/stable/quickstart.html for more info

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# normal simulation
ifneq ($(GATES),yes)

# this is the only part you should need to modify:
VERILOG_SOURCES += $(PWD)/tb.v $(PWD)/as1802.v $(PWD)/uart.v $(PWD)/spiflash/W25Q128JVxIM.v $(PWD)/RAM_model.v $(PWD)/spi.v

else

# gate level simulation requires some extra setup, you shouldn't need to touch this
COMPILE_ARGS    += -DGL_TEST
COMPILE_ARGS    += -DFUNCTIONAL
COMPILE_ARGS    += -DUSE_POWER_PINS
COMPILE_ARGS    += -DSIM
COMPILE_ARGS    += -DUNIT_DELAY=#1
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v
VERILOG_SOURCES += $(PWD)/spiflash/W25Q128JVxIM.v $(PWD)/RAM_model.v

# this gets copied in by the GDS action workflow
VERILOG_SOURCES += $(PWD)/tb.v $(PWD)/gate_level_netlist.v
endif

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = tb

# MODULE is the basename of the Python test file
MODULE = test

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/simulators/Makefile.icarus

tasm:
	cd asm && ./asm -C CDP1802 -l testpgm.lst -o testpgm.hex testpgm.asm
	cd asm && python3 ToVerilogAsm.py

.PHONY: clean tasm sim
