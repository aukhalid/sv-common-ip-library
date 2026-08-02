# Parameterized Edge Detector: Micro-Architecture Specification

## 1. Architectural Overview

The `edge_detector` IP is a single-clock synchronous utility module designed to convert level transitions into 1-cycle control pulses. It supports vector input signals and simultaneously provides rising edge, falling edge, and dual-edge detection outputs.

## 2. Micro-Architectural Parameters & Pinout Specification

### Parameters

| Parameter Name | Type  | Default Value | Description                                          |
| :------------- | :---: | :-----------: | :--------------------------------------------------- |
| `WIDTH`        | `int` |      `1`      | Bit-width of input and edge-detected output signals. |

### Pinout Specification

| Signal Name  | Direction | Bit Width | Domain  | Description                                             |
| :----------- | :-------: | :-------: | :-----: | :------------------------------------------------------ |
| `clk_i`      |   Input   |    `1`    | `clk_i` | Primary system clock.                                   |
| `rst_n_i`    |   Input   |    `1`    | `clk_i` | Active-low reset. Clears history register.              |
| `signal_i`   |   Input   |  `WIDTH`  | `clk_i` | Target input signal to monitor for transitions.         |
| `pos_edge_o` |  Output   |  `WIDTH`  | `clk_i` | High for 1 cycle on 0-to-1 rising transitions.          |
| `neg_edge_o` |  Output   |  `WIDTH`  | `clk_i` | High for 1 cycle on 1-to-0 falling transitions.         |
| `any_edge_o` |  Output   |  `WIDTH`  | `clk_i` | High for 1 cycle on any transition (rising or falling). |
