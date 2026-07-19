// File: common/interfaces/clk_rst_if.sv
// This interface defines the clock and reset signals for modules that require synchronization and reset functionality. It provides a standardized way to connect clock and reset signals across different modules in the design.

interface clk_rst_if;

  logic clk;
  logic rst_n;

  // Modports for the testbench driver

  modport master(output clk, output rst_n);  // Master modport for driving clock and reset signals
  modport slave(input clk, input rst_n);  // Slave modport for receiving clock and reset signals

endinterface : clk_rst_if
