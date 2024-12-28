# Simulator configuration
SIM ?= questa                     # Simulator: questa or modelsim
TOPLEVEL_LANG ?= vhdl             # Language used in DUT
TOPLEVEL ?= uart_top              # Top-level module
MODULE ?= test_uart               # Cocotb test module
SIM_BUILD ?= ./sim_build          # Build directory

# Cocotb Environment
export PYTHONPATH := $(PWD):$(PYTHONPATH)

# Files
VHDL_SOURCES = uart_rx.vhd uart_tx.vhd uart_top.vhd  # List all VHDL files

# Simulator-specific arguments
COMPILE_ARGS = 
SIM_ARGS = 

# Run the cocotb test
all:
	make -C $(COCOTB)/makefiles SIM=$(SIM) TOPLEVEL_LANG=$(TOPLEVEL_LANG) TOPLEVEL=$(TOPLEVEL) \
		MODULE=$(MODULE) SIM_BUILD=$(SIM_BUILD) VHDL_SOURCES="$(VHDL_SOURCES)" \
		COMPILE_ARGS="$(COMPILE_ARGS)" SIM_ARGS="$(SIM_ARGS)"
