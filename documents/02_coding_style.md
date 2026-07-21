# Coding Style & Naming Standard

## Overview

This document establishes the mandatory SystemVerilog coding conventions for all RTL design and Design Verification (DV) components. Strict enforcement ensures:

- **Code Readability:** Uniform appearance across multi-module designs and team reviews.
- **Lint Compatibility:** Zero syntax ambiguity when parsed by static analysis tools (Verilator, Verible).
- **Physical Safety:** Clean synthesis mapping without unexpected wire inferencing or latch generation.

## File & Directory Naming Rules

1. **File Names:** Lowercase `snake_case` matching the exact module/interface/package declared inside.
   - RTL Modules: `sync_fifo.sv`, `dual_port_ram.sv`
   - Testbenches: `sync_fifo_tb.sv`
   - Packages: `memory_pkg.sv`
   - Interfaces: `stream_if.sv`
   - Header Files: `common_macros.svh`
2. **One File, One Primary Construct:** Each `.sv` file must contain only one top-level `module`, `interface`, or `package`.

## Signal Naming & Direction Suffixes

| Signal Type           | Suffix        | Example                 | Description                          |
| --------------------- | ------------- | ----------------------- | ------------------------------------ |
| **Input Port**        | `_i`          | `clk_i`, `data_i`       | Physical module input pin            |
| **Output Port**       | `_o`          | `valid_o`, `data_o`     | Physical module output pin           |
| **Inout Port**        | `_io`         | `sda_io`                | Bidirectional pin                    |
| **Active-Low Signal** | `_n` or `_ni` | `rst_n_i`, `clear_n`    | Reset or active-low control          |
| **Clock Signal**      | `clk_*`       | `clk_i`, `clk_fast_i`   | Clock domain identifier              |
| **Interface Handle**  | `_if`         | `mem_if`                | Virtual or physical interface handle |
| **Parameter / Const** | `UPPER_SNAKE` | `DATA_WIDTH`, `DEPTH`   | Compile-time parameters              |
| **Localparam**        | `UPPER_SNAKE` | `ADDR_WIDTH`, `IDLE_ST` | Internal calculated constants        |
| **Typedef / Enum**    | `_e` / `_t`   | `state_e`, `addr_t`     | Enumerated types & custom types      |
| **Array Vector Size** | `_W`          | `DATA_W`, `DEPTH_W`     | Width calculation macros             |

## Module Header Template

Every synthesizable RTL module must begin with a standard header block:

```systemverilog
// =============================================================================
// Company/Author : Silicon DV Engineering / Ahasan Ullah Khalid
// Module Name    : sync_fifo
// Description    : Parameterized Synchronous FIFO with status flags and SVA.
// Standard       : IEEE 1800-2017 SystemVerilog
// =============================================================================

module sync_fifo #(
    parameter int DATA_WIDTH = 32,
    parameter int FIFO_DEPTH = 16,
    localparam int ADDR_WIDTH = $clog2(FIFO_DEPTH)
)(
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    // Write Interface
    input  logic                  wr_en_i,
    input  logic [DATA_WIDTH-1:0] wr_data_i,
    output logic                  full_o,
    // Read Interface
    input  logic                  rd_en_i,
    output logic [DATA_WIDTH-1:0] rd_data_o,
    output logic                  empty_o
);
```

## Indentation & Formatting

- **Indentation:** 2 spaces (no tabs).
- **Line Length:** Maximum 100 characters per line.
- **Port Alignment:** Vertically align data types, dimensions, names, and direction suffixes.
- **Formatting Engine:** All code must pass `verible-verilog-format` before merging into `main`.

## 1.6 Language Constructs & Bans

| Status       | Construct                                       | Rule                                                     |
| ------------ | ----------------------------------------------- | -------------------------------------------------------- |
| ❌ Banned    | `reg`, `wire`                                   | Use `logic` exclusively per IEEE 1800                    |
| ❌ Banned    | Implicit nets                                   | Enforce `\`default_nettype none` at compiler level       |
| ❌ Banned    | `always @(*)` or `always @(posedge clk)`        | Use intent-explicit blocks                               |
| ✅ Required  | `always_comb`                                   | Pure combinational logic                                 |
| ✅ Required  | `always_ff @(posedge clk_i or negedge rst_n_i)` | Sequential logic                                         |
| ⚠️ Forbidden | `always_latch`                                  | Strictly forbidden unless documented in ASIC macro specs |

---
