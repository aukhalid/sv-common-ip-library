# Verification Strategy & Quality Guidelines

## Verification Philosophy

This repository follows a strict **"Trust Nothing, Verify Everything"** methodology. No RTL module is considered complete until it has undergone:

- Automated stimulus generation
- Non-intrusive runtime assertion checking
- Coverage sign-off

## Testbench Architecture

### Phase 1: Object-Oriented Class Testbench (OOP + SVA)

For standalone IP infrastructure primitives, full UVM environments are unnecessary overhead. Testbenches inside `tb/` must use clean, modular SystemVerilog OOP classes:

```
tb_top.sv
├── clk_rst_gen    (Clock/Reset Driver)
├── DUT            (Synthesizable Module)
├── interface_if   (Physical Pin Bundle)
├── sva_bind_node  (Concurrent Assertions)
└── environment    (OOP Container)
    ├── generator     (Random Transaction Producer)
    ├── driver        (Pin-Level Bus Driver)
    ├── monitor       (Passive Pin-Level Bus Observer)
    └── scoreboard    (Reference Golden Model & Checker)
```

### Phase 2–5: Universal Verification Methodology (UVM 1.2)

Subsystem and protocol-level suites (APB, AXI, DMA, SoC) must implement full UVM 1.2 environments featuring UVM Sequencers, Drivers, Monitors, Scoreboards, and Register Abstraction Layers (RAL).

## SystemVerilog Assertions (SVA) Policy

Concurrent SVA serve as active watchdogs during simulation, catching protocol violations instantly at the exact clock cycle they occur.

### Non-Intrusive Decoupling Rule

To keep synthesizable RTL clean, **SVA code must NOT be written inside the main design file**. SVA code must be encapsulated in a separate file under `common/assertions/` or `tb/` and injected via `bind`:

```systemverilog
// common/assertions/sync_fifo_sva.sv
module sync_fifo_sva #(
    parameter int DEPTH = 16
)(
    input logic clk_i,
    input logic rst_n_i,
    input logic wr_en_i,
    input logic full_o,
    input logic empty_o
);

    property p_no_write_on_full;
        @(posedge clk_i) disable iff (!rst_n_i)
        (full_o && wr_en_i) |=> full_o;
    endproperty

    a_no_write_on_full: assert property (p_no_write_on_full)
        else $error("[SVA ERROR] Write operation attempted while FIFO was FULL!");

endmodule

// tb/tb_top.sv
bind sync_fifo sync_fifo_sva #(.DEPTH(FIFO_DEPTH)) u_sync_fifo_sva (.*);
```

## Definition of Done (DoD) Checklist

An issue/task can only move to **Done (Merged)** when all items pass:

- [ ] **Lint Clean:** Compiles through `verilator --lint-only -Wall` with zero warnings.
- [ ] **Formatted:** Code formatted using `verible-verilog-format` matching `.verilog_format`.
- [ ] **Zero Latch:** Synthesis/elaboration logs confirm zero latches inferred.
- [ ] **Regression Passed:** Local IP `Makefile` executes clean simulation run (`make sim`) with zero errors.
- [ ] **SVA Verified:** All concurrent assertions pass without triggering runtime `$error`.
- [ ] **Self-Reviewed:** Git feature branch clean of temporary debug prints (`$display`) before submitting PR.
