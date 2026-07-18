# ==============================================================================
# AUTHOR: Ahasan Ullah Khalid
# PROJECT: sv-common-ip-library
# ASSET:   Root Master Makefile (Level 1 Controller)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Global Paths & Environment Exports
# ------------------------------------------------------------------------------

# Get the absolute path of the root directory for robust tool routing
ROOT_DIR := $(shell pwd)

# Define and export common asset directories globally
export COMMON_PKG_DIR   := $(REPO_ROOT)/common/packages
export COMMON_INC_DIR   := $(REPO_ROOT)/common/interfaces
export COMMON_MACRO_DIR := $(REPO_ROOT)/common/macros

# Consolidate tool inclusion flags for Verilator and Vivado XSim
# -y triggers directory searches for modules/interfaces
# -I links header files (.svh) for compiler text-substitution
export COMMON_SIM_FLAGS := -I$(COMMON_MACRO_DIR) $(wildcard $(COMMON_PKG_DIR)/*.sv) $(wildcard $(COMMON_INC_DIR)/*.sv)
export COMMON_LINT_FLAGS:= -I$(COMMON_MACRO_DIR) -y $(COMMON_PKG_DIR) -y $(COMMON_INC_DIR)