# ==============================================================================
# COMPANY: ADN Semiconductors (Validation Lab)
# ASSET:   Universal Child Makefile (Leaf IP Level)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Dynamic Path Resolutions & Workspace Setup
# ------------------------------------------------------------------------------
PWD         := $(shell pwd)
REPO_ROOT   := $(shell git rev-parse --show-toplevel 2>/dev/null || echo "$(PWD)/../../..")

COMMON_DIR  := $(REPO_ROOT)/common
BUILD_DIR   := $(PWD)/build
WAVE_DIR    := $(BUILD_DIR)/waves

# Local source file discovery
RTL_SRCS    := $(wildcard rtl/*.sv)
TB_PKG      := $(wildcard tb/tb_pkg.sv)
TB_TOP      := $(wildcard tb/tb_*top.sv)
BIND_SRC    := $(wildcard tb/*_bind.sv)

# Common global infrastructure discovery (sorted alphabetically)
PKG_SRCS    := $(sort $(wildcard $(COMMON_DIR)/packages/*.sv))
IF_SRCS     := $(sort $(wildcard $(COMMON_DIR)/interfaces/*.sv))
ASRT_SRCS   := $(sort $(wildcard $(COMMON_DIR)/assertions/*.sv))

# Include directory flags
VERILATOR_INC := -I$(COMMON_DIR)/macros
XVLOG_INC     := -i $(COMMON_DIR)/macros -i $(PWD)/tb

# ------------------------------------------------------------------------------
# 2. Simulator & Linter Tool Settings
# ------------------------------------------------------------------------------
SIM_TOP     := tb_ram_top
SNAPSHOT    := $(SIM_TOP)_snapshot
VCD_FILE    := $(WAVE_DIR)/dump.vcd

# Verilator Flags
VERILATOR_FLAGS := --lint-only -Wall --assert $(VERILATOR_INC) \
                   -y $(COMMON_DIR)/packages \
                   -y $(COMMON_DIR)/interfaces \
                   -y $(COMMON_DIR)/assertions \
                   -y rtl

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
	verilator $(VERILATOR_FLAGS) $(PKG_SRCS) $(RTL_SRCS) $(ASRT_SRCS)

# ------------------------------------------------------------------------------
# 5. Simulation Target (Guarded Multi-Stage XSim Compilation)
# ------------------------------------------------------------------------------
sim: setup
	@echo "=== [SIM] Compiling Packages & Infrastructure ==="
	@if [ -n "$(strip $(PKG_SRCS))" ];  then cd $(BUILD_DIR) && xvlog $(XVLOG_FLAGS) $(PKG_SRCS); fi
	@if [ -n "$(strip $(IF_SRCS))" ];   then cd $(BUILD_DIR) && xvlog $(XVLOG_FLAGS) $(IF_SRCS); fi
	@if [ -n "$(strip $(ASRT_SRCS))" ]; then cd $(BUILD_DIR) && xvlog $(XVLOG_FLAGS) $(ASRT_SRCS); fi
	@echo "=== [SIM] Compiling Design RTL ==="
	@if [ -n "$(strip $(RTL_SRCS))" ];  then cd $(BUILD_DIR) && xvlog $(XVLOG_FLAGS) $(addprefix ../,$(RTL_SRCS)); fi
	@echo "=== [SIM] Compiling Testbench Suite ==="
	@if [ -n "$(strip $(TB_PKG))" ];    then cd $(BUILD_DIR) && xvlog $(XVLOG_FLAGS) $(addprefix ../,$(TB_PKG)); fi
	@if [ -n "$(strip $(BIND_SRC))" ];  then cd $(BUILD_DIR) && xvlog $(XVLOG_FLAGS) $(addprefix ../,$(BIND_SRC)); fi
	@if [ -n "$(strip $(TB_TOP))" ];    then cd $(BUILD_DIR) && xvlog $(XVLOG_FLAGS) $(addprefix ../,$(TB_TOP)); fi
	@echo "=== [SIM] Elaborating & Running Simulation ==="
	@cd $(BUILD_DIR) && xelab $(SIM_TOP) -s $(SNAPSHOT) -debug typical
	@cd $(BUILD_DIR) && xsim $(SNAPSHOT) -runall
	@if [ -f $(BUILD_DIR)/dump.vcd ]; then mv $(BUILD_DIR)/dump.vcd $(VCD_FILE); fi
	@echo "=== [SIM SUCCESS] Waveform saved to $(VCD_FILE) ==="

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