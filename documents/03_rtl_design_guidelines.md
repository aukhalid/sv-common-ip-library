# RTL Design & Synthesizability Guidelines

## Core Synthesis Rules

> **Golden Rule:** If it cannot synthesize cleanly into physical silicon or FPGA LUTs without warnings, it does not belong in the `rtl/` directory.

### Non-Blocking vs. Blocking Assignments

- **`always_ff` blocks:** Use **non-blocking assignments (`<=`)** exclusively. Never use blocking assignments inside sequential flip-flop logic.
- **`always_comb` blocks:** Use **blocking assignments (`=`)** exclusively.

### Unintentional Latch Prevention

An unintentional latch is a severe hazard. To prevent inferred latches in combinational logic:

1. Assign a default value to every output variable at the very top of an `always_comb` block.
2. Complete all `if-else` trees with a final `else` branch.
3. Complete all `case` / `casex` / `casez` statements with a `default` branch.

```systemverilog
// GOOD: Safe combinational block (Zero Latch Risk)
always_comb begin
    // 1. Set default fallback
    next_state = IDLE;
    out_valid  = 1'b0;

    case (current_state)
        IDLE: begin
            if (start_i) next_state = PROCESS;
        end
        PROCESS: begin
            out_valid  = 1'b1;
            next_state = FINISH;
        end
        default: next_state = IDLE; // 2. Default case covered
    endcase
end
```

## Reset Strategy & Synchronizers

### Active-Low Asynchronous Reset

- All sequential elements must default to an active-low asynchronous reset (`rst_n_i`).
- The edge clause **must** be explicitly declared:

```systemverilog
always_ff @(posedge clk_i or negedge rst_n_i)
```

### Reset Synchronizer Requirement

- Asynchronous reset assertions can occur at any time, but **reset deassertion must be synchronized** to the destination clock domain to prevent metastability setup/hold violations.
- Use the pre-verified `foundation/reset_sync` module for all reset tree distribution networks.

## Clock Domain Crossing (CDC) Rules

Cross-domain data movement is one of the highest sources of silicon failure.

| Signal Type            | Rule                                                                                               | Module                                                                      |
| ---------------------- | -------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------- |
| **Single-bit Control** | Pass through 2-stage Flip-Flop Synchronizer                                                        | `foundation/two_flop_sync`                                                  |
| **Multi-Bit Bus**      | **Never** use 2-flop synchronizers (causes bit skew). Use Gray-code + async FIFO or handshake sync | `foundation/gray_counter`, `memory/async_fifo`, `foundation/handshake_sync` |

## Parameterization & Reusability

- Modules must be fully parameterizable using IEEE 1800 `parameter` blocks.
- Bus widths, depths, and enable flags must be parameter-driven — **no hardcoded magic numbers**.
- Dynamic arrays and runtime size allocation are **strictly banned** inside `rtl/` modules. Use `$clog2()` for parameter bit-width resolution.

## Linter Sign-Off

Prior to merging any RTL code into `main`, it must execute through Verilator without structural warnings:

```bash
verilator --lint-only -Wall rtl/your_module.sv
```

> Any warning (e.g., `WIDTH`, `UNOPTFLAT`, `LATCH`, `COMBDLY`) is treated as a **hard compilation error** and must be resolved immediately.

---
