# Synchronous FIFO: Micro-Architecture Specification

## 1. Architectural Overview

The `sync_fifo` is a single-clock First-In First-Out queue designed for buffering data within a single clock domain (`clk_i`). It utilizes an asynchronous active-low reset (`arst_n_i`) and reuses the `dual_port_ram` core for data storage.

## 2. Micro-Architectural Parameters & Pinout Specification

### Parameters

| Parameter Name | Type  | Default Value | Description                                                   |
| :------------- | :---: | :-----------: | :------------------------------------------------------------ |
| `DATA_WIDTH`   | `int` |     `32`      | Bit-width of write and read data words.                       |
| `ADDR_WIDTH`   | `int` |      `4`      | Memory address width (FIFO Depth = $2^{\text{ADDR\_WIDTH}}$). |

### Pinout Specification

| Signal Name   | Direction |   Bit Width    | Domain  | Description                        |
| :------------ | :-------: | :------------: | :-----: | :--------------------------------- |
| `clk_i`       |   Input   |      `1`       | `clk_i` | Primary system clock.              |
| `arst_n_i`    |   Input   |      `1`       |  Async  | Asynchronous active-low reset.     |
| `wr_en_i`     |   Input   |      `1`       | `clk_i` | Write push enable.                 |
| `wr_data_i`   |   Input   |  `DATA_WIDTH`  | `clk_i` | Incoming write payload.            |
| `full_o`      |  Output   |      `1`       | `clk_i` | Synchronous FIFO full flag.        |
| `rd_en_i`     |   Input   |      `1`       | `clk_i` | Read pop enable.                   |
| `rd_data_o`   |  Output   |  `DATA_WIDTH`  | `clk_i` | Outgoing read payload.             |
| `empty_o`     |  Output   |      `1`       | `clk_i` | Synchronous FIFO empty flag.       |
| `occupancy_o` |  Output   | `ADDR_WIDTH+1` | `clk_i` | Current word count stored in FIFO. |
