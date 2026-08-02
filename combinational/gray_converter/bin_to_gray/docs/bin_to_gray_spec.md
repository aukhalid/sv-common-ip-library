# Parameterized Binary-to-Gray Code Converter: Micro-Architecture Specification

## 1. Architectural Overview

The `bin_to_gray` IP is a pure combinational datapath primitive designed to convert standard $N$-bit binary vectors into $N$-bit Gray code vectors. Gray code enforces a **unit-distance property** where consecutive numerical values differ by exactly **1 bit**. This is critical for Clock Domain Crossing (CDC) pointers in Asynchronous FIFOs.

## 2. Micro-Architectural Parameters & Pinout

### Parameters

| Parameter Name | Type  | Default Value | Description                                                   |
| :------------- | :---: | :-----------: | :------------------------------------------------------------ |
| `WIDTH`        | `int` |      `4`      | Bit-width of input binary vector and output Gray code vector. |

### Pinout Specification

| Signal Name | Direction |  Width  | Electrical Type | Description                                                          |
| :---------- | :-------: | :-----: | :-------------: | :------------------------------------------------------------------- |
| `bin_i`     |   Input   | `WIDTH` |      logic      | Parallel input binary vector.                                        |
| `gray_o`    |  Output   | `WIDTH` |      logic      | Parallel output Gray code vector ($\mathbf{G = B \oplus (B >> 1)}$). |

## 3. Truth Table (4-bit Example)

| Input `bin_i` | Output `gray_o` | Bit Transition Difference |
| :-----------: | :-------------: | :-----------------------: |
|  `0000` (0)   |     `0000`      |             —             |
|  `0001` (1)   |     `0001`      |           1 bit           |
|  `0010` (2)   |     `0011`      |           1 bit           |
|  `0011` (3)   |     `0010`      |           1 bit           |
|  `0100` (4)   |     `0110`      |           1 bit           |
|  `0101` (5)   |     `0111`      |           1 bit           |
|  `0110` (6)   |     `0101`      |           1 bit           |
|  `0111` (7)   |     `0100`      |           1 bit           |
