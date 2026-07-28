# Parameterized Asynchronous FIFO: Micro-Architecture & Verification Specification

## 1. Architectural Overview

The `async_fifo` is a parameterizable, dual-clock asynchronous First-In First-Out data queue designed to bridge high-throughput streaming systems operating across unsynchronized clock domains.

It integrates sub-module IPs from `sv-common-ip-library`:

- `dual_port_ram`: Storage matrix core.
- `two_flop_sync`: CDC pointer synchronizer chain.
- `bin_to_gray`: Binary-to-Gray pointer converters.

---

## 2. Pinout Specification

| Signal Name | Direction |  Bit Width   |   Domain    | Description                         |
| :---------- | :-------: | :----------: | :---------: | :---------------------------------- |
| `wclk_i`    |   Input   |      1       | Write Clock | Write domain clock source.          |
| `wrst_n_i`  |   Input   |      1       | Write Clock | Write domain active-low reset.      |
| `wr_en_i`   |   Input   |      1       | Write Clock | Synchronous write push enable.      |
| `wr_data_i` |   Input   | `DATA_WIDTH` | Write Clock | Incoming parallel write data bus.   |
| `full_o`    |  Output   |      1       | Write Clock | High when FIFO is completely full.  |
| `rclk_i`    |   Input   |      1       | Read Clock  | Read domain clock source.           |
| `rrst_n_i`  |   Input   |      1       | Read Clock  | Read domain active-low reset.       |
| `rd_en_i`   |   Input   |      1       | Read Clock  | Synchronous read pop enable.        |
| `rd_data_o` |  Output   | `DATA_WIDTH` | Read Clock  | Outgoing parallel read data bus.    |
| `empty_o`   |  Output   |      1       | Read Clock  | High when FIFO is completely empty. |
