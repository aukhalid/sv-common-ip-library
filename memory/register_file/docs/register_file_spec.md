# Parameterized Register File: Micro-Architecture Specification

## Architectural Overview

The `register_file` IP is a multi-ported register array designed for RISC processor execution pipelines. It provides two independent combinational read ports and one synchronous write port. Register 0 (`x0`) is hardwired to logic 0.

## Micro-Architectural Parameters & Pinout

### Parameters

| Parameter Name | Type  |    Default Value    | Description                                                    |
| :------------- | :---: | :-----------------: | :------------------------------------------------------------- |
| `DATA_WIDTH`   | `int` |        `32`         | Bit-width of register words.                                   |
| `REG_DEPTH`    | `int` |        `32`         | Number of registers in the array (e.g., 32 for RISC-V RV32I).  |
| `ADDR_WIDTH`   | `int` | `$clog2(REG_DEPTH)` | Address width derived automatically (5 bits for 32 registers). |

### Pinout Specification

| Signal Name | Direction |  Bit Width   |    Domain     | Description                              |
| :---------- | :-------: | :----------: | :-----------: | :--------------------------------------- |
| `clk_i`     |   Input   |      1       |    `clk_i`    | System clock.                            |
| `rst_n_i`   |   Input   |      1       |    `clk_i`    | Active-low reset. Clears registers to 0. |
| `raddr1_i`  |   Input   | `ADDR_WIDTH` | Combinational | Read Port 1 address selector.            |
| `rdata1_o`  |  Output   | `DATA_WIDTH` | Combinational | Read Port 1 output payload.              |
| `raddr2_i`  |   Input   | `ADDR_WIDTH` | Combinational | Read Port 2 address selector.            |
| `rdata2_o`  |  Output   | `DATA_WIDTH` | Combinational | Read Port 2 output payload.              |
| `wen_i`     |   Input   |      1       |    `clk_i`    | Synchronous write enable.                |
| `waddr_i`   |   Input   | `ADDR_WIDTH` |    `clk_i`    | Target write address register.           |
| `wdata_i`   |   Input   | `DATA_WIDTH` |    `clk_i`    | Data payload to commit.                  |
