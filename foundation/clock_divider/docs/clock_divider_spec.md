# Parameterized Clock Divider: Micro-Architecture Specification

## 1. Architectural Overview

The `clk_divider` IP is a dynamic, parameterizable clock frequency divider. It takes an input clock `clk_i` and divides its frequency by a runtime integer factor `div_ratio_i`. It produces both a divided clock output (`clk_out_o`) with a 50% duty cycle (for even $N$) and a single-cycle clock enable pulse (`clk_en_o`).

## 2. Micro-Architectural Parameters & Pinout Specification

### Parameters

| Parameter Name  | Type  | Default Value | Description                                                            |
| :-------------- | :---: | :-----------: | :--------------------------------------------------------------------- |
| `MAX_DIV_RATIO` | `int` |     `16`      | Maximum supported clock division ratio (determines counter bit-width). |

### Pinout Specification

| Signal Name   | Direction |         Bit Width         | Domain  | Description                                         |
| :------------ | :-------: | :-----------------------: | :-----: | :-------------------------------------------------- |
| `clk_i`       |   Input   |            `1`            | `clk_i` | Primary input reference clock.                      |
| `rst_n_i`     |   Input   |            `1`            | `clk_i` | Active-low asynchronous reset.                      |
| `div_ratio_i` |   Input   | `$clog2(MAX_DIV_RATIO+1)` | `clk_i` | Dynamic division factor $N$ ($N \ge 2$).            |
| `clk_out_o`   |  Output   |            `1`            | `clk_i` | Divided clock output (50% duty cycle for even $N$). |
| `clk_en_o`    |  Output   |            `1`            | `clk_i` | 1-cycle clock enable pulse at divided rate.         |
