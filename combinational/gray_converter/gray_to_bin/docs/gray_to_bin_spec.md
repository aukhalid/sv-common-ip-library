# Parameterized Gray-to-Binary Code Converter: Micro-Architecture Specification

## 1. Architectural Overview

The `gray_to_bin` IP is a pure combinational datapath primitive designed to convert an $N$-bit Gray code vector back into standard $N$-bit binary representation. In asynchronous systems like FIFOs, after a Gray-coded pointer passes through a 2-flip-flop synchronizer into the destination clock domain, `gray_to_bin` reconstructs the binary integer for arithmetic (calculating FIFO occupancy and distance).

## 2. Micro-Architectural Parameters & Pinout

### Parameters

| Parameter Name | Type  | Default Value | Description                                                   |
| :------------- | :---: | :-----------: | :------------------------------------------------------------ |
| `WIDTH`        | `int` |      `4`      | Bit-width of input Gray code vector and output binary vector. |

### Pinout Specification

| Signal Name | Direction |  Width  | Electrical Type | Description                                                                |
| :---------- | :-------: | :-----: | :-------------: | :------------------------------------------------------------------------- |
| `gray_i`    |   Input   | `WIDTH` |      logic      | Parallel input Gray code vector.                                           |
| `bin_o`     |  Output   | `WIDTH` |      logic      | Reconstructed output binary vector ($\mathbf{B[i] = G[i] \oplus B[i+1]}$). |
