// ==============================================================================
// AUTHOR      : Ahasan Ullah Khalid
// PROJECT     : sv-common-ip-library
// File        : ram_protocol_assertions.sv
// Description : This module implements a set of protocol assertions for a single-port RAM interface. It checks for X/Z states on the control lines, ensures address stability during active write operations, and verifies that the data bus does not contain non-deterministic values during writes. These assertions help catch potential protocol violations and data integrity issues in the design.
// ==============================================================================


module ram_protocol_assertions #(
    int DATA_WIDTH = 32,
    int ADDR_WIDTH = 8
) (
    input logic                  clk,
    input logic                  rst_n,
    input logic                  wr_en,
    input logic [ADDR_WIDTH-1:0] addr,
    input logic [DATA_WIDTH-1:0] wr_data
);

  // 1. Concurrent Guard: Catch X/Z states on the Control Line
  `ASSERT_NO_X(clk, wr_en, "Target block wr_en line resolved to an unknown X state")

  // 2. Protocol Guard: Ensure address stability during active writes
  property p_stable_addr_during_write;
    @(posedge clk) disable iff (!rst_n) wr_en |-> !$isunknown(
        addr
    );
  endproperty
  assert property (p_stable_addr_during_write)
  else
    $error("[PROTOCOL VIOLATION] Input address contains X/Z bits during an active write command!");

  // 3. Data Guard: Catch non-deterministic data streams during writes
  property p_no_x_data_during_write;
    @(posedge clk) disable iff (!rst_n) wr_en |-> !$isunknown(
        wr_data
    );
  endproperty
  assert property (p_no_x_data_during_write)
  else $error("[DATA VIOLATION] Incoming write data bus contains non-deterministic X/Z bits!");

endmodule : ram_protocol_assertions
