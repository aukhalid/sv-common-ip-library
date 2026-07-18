# Micro-Architecture & Verification Specification: Parameterized Single-Port RAM

## 1. Architectural Overview

The `single_port_ram` is a highly robust, fully parameterizable synchronous memory block designed to serve as a primitive data-storage cell across the silicon portfolio (e.g., local scratchpads, data queues, or bus peripheral register arrays).

In alignment with physical foundry constraints, this module is engineered as a soft IP core that cleanly mirrors the operational behavior of industrial **Foundry Memory Compilers** (such as TSMC or Intel hard macros) and FPGA Block RAM (BRAM) blocks. To maximize compatibility with downstream physical synthesis toolchains and automated layout generators, the hardware boundary utilizes traditional **flat ports** with explicit direction suffixes (`_i` for inputs, `_o` for outputs).

### Key Micro-Architectural Pillars:

- **Single Source of Parameter Truth:** Integrates with `memory_pkg::*` to govern widths and depth boundaries dynamically.
- **Industry Write-Mode Configurations:** Natively implements `WRITE_FIRST`, `READ_FIRST`, and `NO_CHANGE` behavioral data-routing loops.
- **Optional Pipeline Registers:** Includes a parameter-controlled output stage (`OUT_REG`) to optimize the critical timing path (clock-to-output latency) during physical chip synthesis.
- **Isolated Formal Verification Layer:** Deploys a completely clean, non-intrusive SystemVerilog Assertion (SVA) protocol watchdog bundle routed via external `bind` statements to ensure zero synthesis area overhead.

---

## 2. Block Diagram & Structural Layout

The operational block diagram highlights the isolation between the synthesizable control logic core and the external non-intrusive assertion probe layer:

```text
       +--------------------------------------------------------------+
       | MODULE: single_port_ram                                      |
       |                                                              |
       |                   +-----------------------+                  |
------>| clk_i             |   Memory Core Matrix  |                  |
------>| rst_n_i           |                       |                  |
------>| wr_en_i           |   [DATA_WIDTH-1:0]    |                  |
------>| addr_i ---------->|   mem_core            |                  |
------>| wr_data_i ------->|   [0:MEM_DEPTH-1]     |                  |
       |                   +-----------+-----------+                  |
       |                               |                              |
       |                               v                              |
       |                   +-----------------------+                  |
       |                   |  Write Mode Selector  |                  |
       |                   |  (WF / RF / NC)       |                  |
       |                   +-----------+-----------+                  |
       |                               |                              |
       |                               v                              |
       |                   +-----------------------+                  |
       |                   | ram_data_out Register |                  |
       |                   +-----------+-----------+                  |
       |                               |                              |
       |                               +--------------+               |
       |                               |              |               |
       |                               v (OUT_REG=0)  v (OUT_REG=1)   |
       |                           +-------+      +-------+           |
       |                           | Bypass|      |Pipeline|          |
       |                           +-------+      +-------+           |
       |                               |              |               |
       |                               v              v               |
       |                           +-----------------------+          |
       |                           |    Mux Multiplexer    |          |
       |                           +-----------+-----------+          |
       |                                       |                      |
       |                                       v                      |
<------| rd_data_o <---------------------------+                      |
       |                                                              |
       +--------------------------------------------------------------+
                                       ^
                                       | (Non-intrusive Monitoring via bind)
       +-------------------------------+------------------------------+
       | MODULE: ram_protocol_assertions                              |
       | * ASSERT_NO_X (wr_en_i)                                      |
       | * p_stable_addr_during_write                                 |
       | * p_no_x_data_during_write                                   |
       +--------------------------------------------------------------+
```

## 3. Micro-Architectural Port & Parameter Specification

### 3.1 Compilation Parameters

| Parameter Name | Type                       | Default Value                             | Description / Constraint                                                                                                                               |
| -------------- | -------------------------- | ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `DATA_WIDTH`   | int                        | `memory_pkg::RAM_DEFAULT_DATA_WIDTH` (32) | Total data bit-width per individual memory word. Limits maximum parallel bus sizing.                                                                   |
| `ADDR_WIDTH`   | int                        | `memory_pkg::RAM_DEFAULT_ADDR_WIDTH` (8)  | Address bus width. Governs total memory depth matrix mathematically via formula: $2^{ADDR\_WIDTH}$.                                                    |
| `OUT_REG`      | bit                        | `1'b0`                                    | Output pipeline selector configuration. 0 = Flow-through output path (1 cycle latency); 1 = Pipelined registered data stage output (2 cycles latency). |
| `WRITE_MODE`   | `memory_pkg::write_mode_e` | `memory_pkg::WRITE_FIRST`                 | Sets read-data output behavior during a write collision transaction.                                                                                   |

### 3.2 Suffixed Signal Interface (Pinout)

| Signal Name | Direction | Bit Width    | Electrical Type | Description                                                                                                     |
| ----------- | --------- | ------------ | --------------- | --------------------------------------------------------------------------------------------------------------- |
| `clk_i`     | Input     | 1            | logic           | Core System Clock node. All internal storage modifications occur on the synchronous rising edge.                |
| `rst_n_i`   | Input     | 1            | logic           | Active-low system reset. Clears data output pipelines; does not erase background core matrix array data fields. |
| `wr_en_i`   | Input     | 1            | logic           | Synchronous write enable control flag. High = Write operation active; Low = Read operation active.              |
| `addr_i`    | Input     | `ADDR_WIDTH` | logic           | Decoded address bus select vector pointing to target word matrix location array.                                |
| `wr_data_i` | Input     | `DATA_WIDTH` | logic           | Incoming parallel data payload bus written to selected address slot.                                            |
| `rd_data_o` | Output    | `DATA_WIDTH` | logic           | Synchronous outgoing data payload bus driven back to requesting master peripheral.                              |

## 4. Subsystem Operation & Multi-Mode Timing Semantics

### 4.1 Write Mode Operational Analysis

When `wr_en_i` is driven high, the input payload `wr_data_i` is committed to `mem_core[addr_i]`. Simultaneously, the output port behavior varies dynamically according to the configured `WRITE_MODE` enumeration parameter:

#### Mode A: WRITE_FIRST (Read-Through-Write)

**Description:** The incoming data word is written to the array cell matrix and immediately bypasses down into the read output data stream tracking pipeline.
**Timing Effect:** The data appearing on `rd_data_o` reflects the newly written data word on the immediate subsequent clock cycle matching elaboration tracking rules.

#### Mode B: READ_FIRST (Old-Data-Read)

**Description:** The read tracking loop executes concurrently with the write command. The read channel grabs the original background data word present inside the targeted slot prior to the new overwrite action completing.
**Timing Effect:** The data appearing on `rd_data_o` provides the previous/stale data string entry for one cycle before shifting access limits.

#### Mode C: NO_CHANGE

**Description:** The output generation register blocks out raw updates during active writes.
**Timing Effect:** The `rd_data_o` bus holds onto its previous state value indefinitely until a pure read operation (`wr_en_i == 0`) is issued to update the pipeline registers.

## 5. Formal Protocol Verification (SVA Layer)

To optimize synthesis and preserve structural readability, the SystemVerilog Assertions layer is isolated into a standalone `ram_protocol_assertions.sv` file inside the `common/` infrastructure folder. It binds directly onto the target RTL at runtime without changing production lines.

### 5.1 Formal Check Assertions Matrix

- **ASSERT_NO_X:** Evaluates the `wr_en_i` signal vector on the positive edge of every clock frame. If the control line transitions into an uninitialized floating condition (X or Z logic state), a severe simulation protocol exception is flagged immediately.
- **p_stable_addr_during_write:** A concurrent implication check ($A \mapsto B$). Ensures that whenever `wr_en_i` drops into an active state (`1'b1`), the input address line bits are fully deterministic (`!$isunknown(addr_i)`), blocking unintended corruption.
- **p_no_x_data_during_write:** Ensures that whenever an active write cycle triggers, the target incoming payload vector contains zero corrupt floating bits, preserving exact boundary integrity.

## 6. Functional Verification & Definition of Done (DoD) Plan

### 6.1 Target Test Scenario Sequences

- **Reset Validation Target:** Assert `rst_n_i` randomly during execution streams. Verify that `rd_data_o` snaps to a uniform zero state immediately on the subsequent cycle while ensuring background data remains safely retained.
- **Back-to-Back Backlog Write/Read:** Push sequence steps writing random data patterns to address `0xAA` followed by an immediate read request to `0xAA`. Validate output values against the active `WRITE_MODE` parameters.
- **Corner Boundary Operations:** Execute memory transactions at the absolute lowest address boundary (`0x00`) and the maximum upper threshold value limit ($2^{ADDR\_WIDTH}-1$) to test against accidental truncation.
- **Randomized Stress Traffic Loops:** Fire high-density randomized bursts of read/write commands over 10,000 simulation clocks to drive the structural verification scoreboard metrics.

### 6.2 Industrial Definition of Done Compliance Checklist

- [ ] **Verilator Lint Cleanliness:** `verilator --lint-only -Wall` must exit with an absolute zero warning report. Unintentional transparent latches will trigger immediate pipeline rejection.
- [ ] **Zero Area Synthesis Impact:** Synthesis logs must confirm that the SVA watchdogs were successfully stripped out by compiler optimization layers when simulation macros are de-asserted.
- [ ] **100% Assertion Scoreboard Pass:** Zero protocol errors generated during the testbench regression runs.
- [ ] **Functional Coverage Closure:** Verify that all combinations of write modes, reset states, pipeline depths, and address boundaries have been hit.

---

_Specification file generated for `single_port_ram` IP block._
