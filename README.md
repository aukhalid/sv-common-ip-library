# sv-common-ip-library

> A robust, parameterizable SystemVerilog RTL and Design Verification (DV) infrastructure library designed to serve as the foundational hardware block layer for modern ASIC and FPGA SoC designs. Enforces strict **IP Reuse** principles, modular layered testbenches, and concurrent formal assertions across all modules.

---

## Table of Contents

0. [Environment Setup](documents/01_environment_setup_guide.md)
1. [Architectural Overview](#architectural-overview)
2. [Repository Structure](#repository-structure)
3. [Module Inventory & Status](#module-inventory--status)
4. [Verification Architecture](#verification-architecture)
5. [Toolchain & Build Automation](#toolchain--build-automation)
6. [Quick Start & Execution Guide](#quick-start--execution-guide)
7. [Downstream SoC Integration](#downstream-soc-integration)
8. [Author & License](#author--license)

---

## Architectural Overview

The `sv-common-ip-library` provides standard hardware primitives required across higher-level subsystems (such as APB Peripheral Suites, AXI Interconnects, DMA Controllers, and RISC-V SoC cores).

```
+------------------------------------------------------------------------------------+
|                               sv-common-ip-library                                 |
|                                                                                    |
|  +--------------------+  +--------------------+  +-------------------------------+ |
|  |       MEMORY       |  |     FOUNDATION     |  |         COMBINATIONAL         | |
|  | - single_port_ram  |  | - two_flop_sync    |  | - bin_to_gray                 | |
|  | - dual_port_ram    |  | - clk_divider      |  | - gray_to_bin                 | |
|  | - sync_fifo        |  | - edge_detector    |  | - priority_encoder            | |
|  | - async_fifo       |  | - reset_sync       |  | - parity_gen_check            | |
|  | - register_file    |  | - pulse_sync       |  | - crc_generator               | |
|  +--------------------+  +--------------------+  +-------------------------------+ |
|                                                                                    |
|  +-------------------------------------------------------------------------------+ |
|  |                            COMMON INFRASTRUCTURE                              | |
|  |  - Interfaces: clk_rst_if, memory_if, fifo_if                                 | |
|  |  - Assertions: ram_protocol_assertions, assert_macros.svh                     | |
|  |  - Packages:   common_pkg                                                     | |
|  +-------------------------------------------------------------------------------+ |
+------------------------------------------------------------------------------------+
```

### Key Engineering Principles

- **Pure Standalone RTL:** Modules use flat, direction-suffixed physical ports (`_i` for inputs, `_o` for outputs) with zero external package dependencies in RTL to guarantee maximum synthesis portability across ASIC and FPGA toolchains.

- **Hierarchical IP Reuse:** Complex subsystems directly instantiate verified base primitives (e.g., `async_fifo` integrates `dual_port_ram`, `two_flop_sync`, and `bin_to_gray`).

- **Non-Intrusive SVA Protocol Layer:** Protocol stability and data integrity checks are implemented via SystemVerilog Assertions (SVA) guarded under `` `ifdef SIMULATION `` or external `bind` modules.

- **Tiered Verification Architecture:** Verification complexity is structured across three tiers (Tier 1: Full OOP Class Testbench, Tier 2: Self-Checking Testbench, Tier 3: Direct Exhaustive Vector Sweeps).

---

## Verification Architecture

Modules are verified based on functional complexity:

```
       TIER 1 (OOP ENVIRONMENT)                 TIER 2 / TIER 3 (DIRECT / EXHAUSTIVE)
       +-------------------------------+             +----------------------------------+
       |           tb_top              |             |              tb_top              |
       |  +-------------------------+  |             |  +----------------------------+  |
       |  |     clk_rst_gen         |  |             |  |      clk_rst_gen           |  |
       |  +-------------------------+  |             |  +----------------------------+  |
       |  |     DUT Instantiation   |  |             |  |     DUT Instantiation      |  |
       |  +-------------------------+  |             |  +----------------------------+  |
       |  |  sva_bind_node / SVA    |  |             |  |  Formal SVA Watchdogs      |  |
       |  +-------------------------+  |             |  +----------------------------+  |
       |  |     ram_environment     |  |             |  |  Directed / Swept Stimulus |  |
       |  |  +-------------------+  |  |             |  |  Self-Checking Assertion   |  |
       |  |  |   ram_generator   |  |  |             |  |  Comparison Engine         |  |
       |  |  |   ram_driver      |  |  |             |  +----------------------------+  |
       |  |  |   ram_monitor     |  |  |             +----------------------------------+
       |  |  |   ram_scoreboard  |  |  |
       |  |  +-------------------+  |  |
       |  +-------------------------+  |
       +-------------------------------+
```

### Tier 1: Class-Based OOP Testbenches

- **Generator:** Produces randomized transactions with distribution constraints.
- **Driver:** Converts abstract transaction payloads into cycle-accurate bus pin toggles.
- **Monitor:** Passively observes bus signals and extracts pin-level transfers into transactions.
- **Scoreboard:** Uses associative arrays or dynamic queues as reference golden models to evaluate data integrity.

### SystemVerilog Assertions (SVA)

Assertions enforce deterministic bus behavior:

- **`ASSERT_NO_X`**: Rejects any unknown or high-impedance states (X/Z) on control lines.
- **`p_stable_addr_during_write`**: Proves address stability for the entire duration of write operations.
- **`p_no_overflow` / `p_no_underflow`**: Ensures pointers freeze when FIFOs reach boundary limits.

---

## 5. Toolchain & Build Automation

The library uses a **Two-Tier Makefile System**:

- **Level 1 (Root Makefile):** Orchestrates repository-wide tasks (linting all IPs, running complete regressions, cleaning artifacts).
- **Level 2 (Child Makefiles):** Leaf Makefiles located inside each IP folder handling local isolated compilation, simulation, and waveform generation.

### Supported Tool Stack

| Tool | Role | Version |
|---|---|---|
| **Verilator** | Static Linter | v5.0+ |
| **AMD Vivado XSim** | Dynamic Simulator | v2023.1+ |
| **Icarus Verilog** | Alternate Simulator | Latest stable |
| **GTKWave** | Waveform Debugger | Latest stable |

> Verilator lint flags: `--lint-only -Wall --assert -DSIMULATION`

---

## 6. Quick Start & Execution Guide

### Prerequisites

Ensure your environment has Verilator, Vivado (or Icarus Verilog), and GTKWave installed:

```bash
verilator --version
xvlog --version
gtkwave --version
```

### Running Individual Module Targets

Navigate to any leaf IP directory:

```bash
# Example: Dual-Port RAM
cd memory/dual_port_ram/

# Run static linting
make lint

# Run dynamic simulation regression
make sim

# Open generated waveform trace
make wave

# Clean build artifacts
make clean
```

### Running Repository-Wide Regressions

Run top-level commands from the root directory:

```bash
# Lint every IP module across the library
make lint_all

# Run simulation regressions across all modules
make sim_all

# Wipe all generated build directories and log files
make clean_all
```

---

## 7. Downstream SoC Integration

This repository is imported via **Git submodule** into downstream projects across the portfolio:

| Project | Consumed Modules |
|---|---|
| **Project 2 — apb-peripheral-suite** | `sync_fifo`, `async_fifo` for UART/SPI/I2C buffering; `clk_divider`, `edge_detector` for timer and baud-rate generators |
| **Project 3 — axi-infrastructure-suite** | Memory cores and CDC synchronizers inside AXI crossbars, bridges, and register slices |
| **Project 4 — dma-memory-subsystem** | FIFO buffers for scatter-gather descriptor queues and data channels |
| **Project 5 — rv32i-mini-soc** | `register_file`, RAM macros, and FIFOs integrated into a functional single-core RISC-V SoC |

---

## 📁 Project Structure

```
sv-common-ip-library/
├── README.md
├── LICENSE
├── .gitignore
├── Makefile                   
│
├── docs/
│   ├── coding_style.md
│   ├── rtl_design_guidelines.md
│   ├── verification_guidelines.md
│   ├── directory_structure.md
│   └── naming_conventions.md
│
├── scripts/
│   ├── lint/
│   ├── sim/
│   ├── regression/
│   ├── coverage/
│   └── waveform/
│
├── common/
│   ├── packages/
│   │   ├── common_pkg.sv
│   │   ├── counter_pkg.sv
│   │   ├── fifo_pkg.sv
│   │   ├── memory_pkg.sv
│   │   ├── arithmetic_pkg.sv
│   │   └── crc_pkg.sv
│   │
│   ├── interfaces/
│   │   ├── clk_rst_if.sv
│   │   ├── fifo_if.sv
│   │   ├── memory_if.sv
│   │   └── stream_if.sv
│   │
│   └── macros/
│       ├── common_macros.svh
│       ├── assert_macros.svh
│       └── sim_macros.svh
│
├── foundation/
│   ├── clock_divider/
│   ├── reset_sync/
│   ├── edge_detector/
│   ├── pulse_sync/
│   ├── two_flop_sync/
│   ├── toggle_sync/
│   ├── handshake_sync/
│   └── counter_lib/
│       ├── basic_counter/
│       ├── up_down_counter/
│       ├── gray_counter/
│       ├── ring_counter/
│       └── johnson_counter/
│
├── arithmetic/
│   ├── adder_subtractor/
│   ├── incrementer/
│   ├── decrementer/
│   ├── carry_lookahead_adder/
│   ├── carry_select_adder/
│   └── carry_save_adder/
│
├── combinational/
│   ├── mux/
│   │   └── mux_param/
│   │
│   ├── decoder/
│   │   └── decoder_param/
│   │
│   ├── encoder/
│   │   ├── encoder_param/
│   │   └── priority_encoder_param/
│   │
│   ├── comparator/
│   │   └── comparator_param/
│   │
│   ├── gray_converter/
│   │   ├── bin_to_gray/
│   │   └── gray_to_bin/
│   │
│   ├── arbiter/
│   │   ├── fixed_priority/
│   │   └── round_robin/
│   │
│   ├── barrel_shifter/
│   └── lfsr/
│
├── sequential/
│   ├── shift_register/
│   │   ├── siso/
│   │   ├── sipo/
│   │   ├── piso/
│   │   └── universal/
│   │
│   └── timer_lib/
│       ├── timer/
│       ├── watchdog/
│       └── interval_timer/
│
├── memory/
│   ├── register_file/
│   ├── single_port_ram/
│   ├── dual_port_ram/
│   ├── sync_fifo/
│   └── async_fifo/
│
└── datapath/
    ├── crc_generator/
    ├── parity_generator/
    ├── parity_checker/
    ├── checksum/
    └── popcount/

```

## 8. Author & License

**Author:** Ahasan Ullah Khalid

**License:** Licensed under the [MIT License](./LICENSE).
