// ==============================================================================
// AUTHOR:  Ahasan Ullah Khalid
// PROJECT: sv-common-ip-library
// MODULE:  single_port_ram
// ASSET:   single_port_ram.sv (Synthesizable Parameterized Core)
// ==============================================================================

`include "assert_macros.svh"

module single_port_ram #(
    parameter int DATA_WIDTH = memory_pkg::RAM_DEFAULT_DATA_WIDTH,
    parameter int ADDR_WIDTH = memory_pkg::RAM_DEFAULT_ADDR_WIDTH
) (
    // Interface bundles
    clk_rst_if.slave clk_rst,
    memory_if.slave  mem_bus
);

  localparam int DEPTH = 1 << ADDR_WIDTH;

endmodule
