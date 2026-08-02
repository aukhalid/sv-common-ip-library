# ==============================================================================
# COMPANY: ADN Semiconductors (Validation Lab)
# ASSET:   Child Makefile for Hierarchical Async FIFO Subsystem
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Dynamic Path Resolutions & Workspace Setup
# ------------------------------------------------------------------------------
PWD         := $(shell pwd)
REPO_ROOT   := $(shell git rev-parse --show-toplevel 2>/dev/null || echo "$(PWD)/../../..")

COMMON_DIR  := $(REPO_ROOT)/common
BUILD_DIR   := $(PWD)/build
WAVE_DIR    := $(BUILD_DIR)/waves

# Local source file discovery (Converts to absolute paths)
LOCAL_RTL   := $(abspath $(wildcard rtl/*.sv))

# External Submodule Dependencies (Absolute paths)
SUBMODULE_SRCS := $(abspath $(wildcard $(REPO_ROOT)/memory/dual_port_ram/rtl/*.sv)) \
                  $(abspath $(wildcard $(REPO_ROOT)/foundation/two_flop_sync/rtl/*.sv)) \
                  $(abspath $(wildcard $(REPO_ROOT)/combinational/gray_converter/bin_to_gray/rtl/*.sv))

# Combined RTL Compilation Sources
RTL_SRCS    := $(SUBMODULE_SRCS) $(LOCAL_RTL)

TB_PKG      := $(abspath $(wildcard tb/tb_pkg.sv))
TB_TOP      := $(abspath $(wildcard tb/tb_*top.sv))
BIND_SRC    := $(abspath $(wildcard tb/*_bind.sv))

# Common global infrastructure discovery (sorted absolute paths)
PKG_SRCS    := $(abspath $(sort $(wildcard $(COMMON_DIR)/packages/*.sv)))
IF_SRCS     := $(abspath $(sort $(wildcard $(COMMON_DIR)/interfaces/*.sv)))
ASRT_SRCS   := $(abspath $(sort $(wildcard $(COMMON_DIR)/assertions/*.sv)))

# Include directory flags
VERILATOR_INC := -I. -Irtl -I$(COMMON_DIR)/macros
XVLOG_INC     := -i . -i rtl -i $(COMMON_DIR)/macros -i $(PWD)/tb

# ------------------------------------------------------------------------------
# 2. Simulator & Linter Tool Settings
# ------------------------------------------------------------------------------
SIM_TOP     := tb_top
SNAPSHOT    := $(SIM_TOP)_snapshot
VCD_FILE    := $(WAVE_DIR)/dump.vcd

# Verilator Flags
VERILATOR_FLAGS := --lint-only -Wall --assert -DSIMULATION $(VERILATOR_INC) \
                   -y $(COMMON_DIR)/packages \
                   -y $(COMMON_DIR)/interfaces \
                   -y $(COMMON_DIR)/assertions \
                   -y rtl \
                   -y $(REPO_ROOT)/memory/dual_port_ram/rtl \
                   -y $(REPO_ROOT)/foundation/two_flop_sync/rtl \
                   -y $(REPO_ROOT)/combinational/gray_converter/bin_to_gray/rtl

# Vivado XSim Flags
XVLOG_FLAGS     := -sv $(XVLOG_INC) -d SIMULATION

.PHONY: all lint sim wave clean help setup

all: lint sim

# ------------------------------------------------------------------------------
# 3. Environment Initialization Target
# ------------------------------------------------------------------------------
setup:
	@mkdir -p $(BUILD_DIR)
	@mkdir -p $(WAVE_DIR)

# ------------------------------------------------------------------------------
# 4. Static Code Linting Target (Verilator)
# ------------------------------------------------------------------------------
lint:
	@echo "=== [LINT] Running Verilator Static Analysis for $(shell basename $(PWD)) ==="
	@verilator $(VERILATOR_FLAGS) $(PKG_SRCS) $(RTL_SRCS) $(ASRT_SRCS) && \
	echo "=== [LINT SUCCESS] Zero errors/warnings found for $(shell basename $(PWD))! ==="

# ------------------------------------------------------------------------------
# 5. Simulation Target (Guarded Multi-Stage XSim Compilation)
# ------------------------------------------------------------------------------
sim: setup
	@echo "=== [SIM] Compiling Packages & Infrastructure ==="
	@if [ -n "$(strip $(PKG_SRCS))" ];  then cd $(BUILD_DIR) && xvlog $(XVLOG_FLAGS) $(PKG_SRCS); fi
	@if [ -n "$(strip $(IF_SRCS))" ];   then cd $(BUILD_DIR) && xvlog $(XVLOG_FLAGS) $(IF_SRCS); fi
	@if [ -n "$(strip $(ASRT_SRCS))" ]; then cd $(BUILD_DIR) && xvlog $(XVLOG_FLAGS) $(ASRT_SRCS); fi
	@echo "=== [SIM SUCCESS] Packages & Infrastructure Compiling Done ==="

	@echo "=== [SIM] Compiling Submodule & Target RTL ==="
	@if [ -n "$(strip $(RTL_SRCS))" ];  then cd $(BUILD_DIR) && xvlog $(XVLOG_FLAGS) $(RTL_SRCS); fi
	@echo "=== [SIM SUCCESS] Design RTL Compiling Done ==="

	@echo "=== [SIM] Compiling Testbench Suite ==="
	@if [ -n "$(strip $(TB_PKG))" ];    then cd $(BUILD_DIR) && xvlog $(XVLOG_FLAGS) $(TB_PKG); fi
	@if [ -n "$(strip $(BIND_SRC))" ];  then cd $(BUILD_DIR) && xvlog $(XVLOG_FLAGS) $(BIND_SRC); fi
	@if [ -n "$(strip $(TB_TOP))" ];    then cd $(BUILD_DIR) && xvlog $(XVLOG_FLAGS) $(TB_TOP); fi
	@echo "=== [SIM SUCCESS] Testbench Suite Compiling Done ==="

	@echo "=== [SIM] Elaborating Design ==="
	@cd $(BUILD_DIR) && xelab $(SIM_TOP) -s $(SNAPSHOT) -debug typical
	@echo "=== [SIM SUCCESS] Elaboration Done ==="

	@echo "=== [SIM] Running Simulation Execution ==="
	@cd $(BUILD_DIR) && xsim $(SNAPSHOT) -runall
	@if [ -f $(BUILD_DIR)/dump.vcd ]; then mv $(BUILD_DIR)/dump.vcd $(VCD_FILE); fi
	@echo "=== [SIM SUCCESS] Simulation Completed & Waveform saved to $(VCD_FILE) ==="

# ------------------------------------------------------------------------------
# 6. Waveform GUI Viewer Target (GTKWave)
# ------------------------------------------------------------------------------
wave:
	@if [ -f $(VCD_FILE) ]; then \
		echo "=== Launching GTKWave GUI ==="; \
		gtkwave $(VCD_FILE) & \
	else \
		echo "[ERROR] No VCD waveform found at $(VCD_FILE). Run 'make sim' first!"; \
	fi

# ------------------------------------------------------------------------------
# 7. Local Cleaning Target
# ------------------------------------------------------------------------------
clean:
	@echo "=== Cleaning local build artifacts ==="
	@rm -rf $(BUILD_DIR) *.log *.jou *.pb *.vcd xsim.dir/

# ------------------------------------------------------------------------------
# 8. Help Menu
# ------------------------------------------------------------------------------
help:
	@echo "Local IP Module Commands:"
	@echo "  make lint  - Run Verilator static checks"
	@echo "  make sim   - Run XSim simulation (outputs logs & waves to build/)"
	@echo "  make wave  - Launch GTKWave GUI with generated VCD"
	@echo "  make clean - Purge local build/ directory and simulation logs"