# Master Verification Plan & Strategy: `sv-common-ip-library`

---

## 1. Overview & Strategy Goals

The `sv-common-ip-library` provides foundational hardware primitives (RAMs, FIFOs, Synchronizers, Datapath units, Arbiters) used across downstream SoC design suites.

To achieve industrial verification rigor without incurring prohibitive engineering overhead on simple circuits, this project adopts a **Pragmatic Tiered Verification Strategy**. Verification environments range from full constrained-random Object-Oriented (OOP) testbenches with SystemVerilog Assertions (SVA) for complex blocks down to self-checking exhaustive sweep modules for simple combinational logic.

---

## 2. The 3-Tier Verification Matrix

```text
+----------------------------------------+
| TIER 1: Complex IP (Full OOP + SVA)    |  <-- RAMs, FIFOs, Arbiters
+----------------------------------------+
| TIER 2: Medium IP (Lightweight OOP/Rnd)|  <-- CDC, LFSR, Timers, CRC
+----------------------------------------+
| TIER 3: Basic Primitives (Exhaustive)  |  <-- Mux, Decoder, Gray, Edge
+----------------------------------------+
```

### Tier 1: Complex IP (Full OOP + SVA)

| Attribute          | Detail                                                                                                                                                            |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Complexity**     | High — internal state, multi-cycle latency, concurrent write/read, buffering                                                                                      |
| **Target Modules** | `single_port_ram`, `dual_port_ram`, `sync_fifo`, `async_fifo`, `register_file`, `round_robin_arbiter`                                                             |
| **Architecture**   | • Class-based OOP Environment (Generator, Driver, Monitor, Scoreboard) <br>• Virtual Interfaces (`memory_if`, `fifo_if`) <br>• Non-intrusive SVA Monitor (`bind`) |
| **Pass Criteria**  | 100% Scoreboard matching over 1,000+ constrained-random transactions; 0 SVA protocol violations                                                                   |

### Tier 2: Medium IP (Lightweight OOP / Random)

| Attribute          | Detail                                                                                                                   |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------ |
| **Complexity**     | Medium — stateful, algorithmic, or multi-clock domain tracking                                                           |
| **Target Modules** | `crc_generator`, `lfsr`, `barrel_shifter`, `up_down_counter`, `gray_counter`, `pulse_sync`, `handshake_sync`, `watchdog` |
| **Architecture**   | • Single-file Class or Task-Based Random Testbench <br>• Algorithmic reference checker (C-model / SV function)           |
| **Pass Criteria**  | 100% pass rate across 500+ randomized input bursts and corner-case seeds                                                 |

### Tier 3: Basic Primitives (Exhaustive)

| Attribute          | Detail                                                                                                                             |
| ------------------ | ---------------------------------------------------------------------------------------------------------------------------------- |
| **Complexity**     | Low — pure combinational or 1-to-2 flip-flop logic primitives                                                                      |
| **Target Modules** | `mux_param`, `decoder_param`, `encoder_param`, `priority_encoder`, `bin_to_gray`, `gray_to_bin`, `edge_detector`, `parity_checker` |
| **Architecture**   | • Direct Self-Checking Testbench <br>• Exhaustive for-loop input sweeps (`$2^N` states)                                            |
| **Pass Criteria**  | 100% state-space sweep completion with zero direct assert failures                                                                 |

---

## 3. Tier 1 Architecture Details: Class-Based OOP & SVA

For Tier 1 components (such as `single_port_ram`), the verification suite is strictly decoupled into reusable OOP software classes and non-intrusive formal assertion modules.

### Component Breakdown

| Component             | File                  | Role                                                                                                                         |
| --------------------- | --------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| **Transaction**       | `<ip>_transaction.sv` | Holds randomized payload fields, commands, and probability constraints                                                       |
| **Generator**         | `<ip>_generator.sv`   | Generates constrained-random transaction streams; feeds them into the thread-safe `gen_to_drv` mailbox                       |
| **Driver**            | `<ip>_driver.sv`      | Unpacks transactions and drives input pins on the positive clock edge via a virtual interface handle                         |
| **Monitor**           | `<ip>_monitor.sv`     | Passively samples pin activity and broadcasts observed operations to the scoreboard mailbox                                  |
| **Scoreboard**        | `<ip>_scoreboard.sv`  | Maintains an internal golden memory array reference model; checks DUT outputs against expected mathematical data             |
| **Environment**       | `<ip>_environment.sv` | Instantiates mailboxes, classes, and handles test phases (`pre_test`, `test`, `post_test`)                                   |
| **SVA Binding Layer** | `<ip>_bind.sv`        | Binds protocol watchdog monitors (`*_assertions.sv`) onto target hardware instances using the SystemVerilog `bind` construct |

---

## 4. Formal Protocol Assertions (SVA)

All modules, regardless of tier, enforce signal validity using SystemVerilog Assertions (SVA) wrapped inside `` `ifdef SIMULATION `` guards or external `bind` nodes to ensure **zero ASIC area footprint**.

### Key Assertions Standardized Across the Library

| Assertion                        | Description                                                                                                                 |
| -------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| **`ASSERT_NO_X`**                | Ensures control signals (e.g., `wr_en_i`, `rd_en_i`, `rst_n_i`) never settle into unknown `X` or floating `Z` states        |
| **`p_stable_addr_during_write`** | Verifies that address vectors remain completely deterministic whenever write enables are high                               |
| **`p_no_x_data_during_write`**   | Prevents corruption of memory core slots from floating input data bits                                                      |
| **FIFO Bounds**                  | Ensures read operations are never performed on empty buffers (underflow) and writes are rejected on full buffers (overflow) |
