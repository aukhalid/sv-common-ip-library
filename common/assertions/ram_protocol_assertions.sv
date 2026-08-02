// ==============================================================================
// COMPANY: ADN Semiconductors (Validation Lab)
// ASSET:   Common Protocol Assertion Module for Single / Simple RAM Port
// ==============================================================================

`include "assert_macros.svh"

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

`ifdef SIMULATION

  // 1. Concurrent Control Guard: Catch unknown X/Z states on write enable
  `ASSERT_NO_X(clk, wr_en, "RAM wr_en line resolved to an unknown X/Z state")

  // 2. Protocol Guard: Ensure address stability during active writes
  property p_stable_addr_during_write;
    @(posedge clk) disable iff (!rst_n) wr_en |-> !$isunknown(
        addr
    );
  endproperty

  assert property (p_stable_addr_during_write)
  else
    $error(
        "[PROTOCOL VIOLATION] Time: %0t | Target address contains X/Z bits during write!", $time
    );

  // 3. Data Guard: Catch non-deterministic write payloads
  property p_no_x_data_during_write;
    @(posedge clk) disable iff (!rst_n) wr_en |-> !$isunknown(
        wr_data
    );
  endproperty

  assert property (p_no_x_data_during_write)
  else $error("[DATA VIOLATION] Time: %0t | Incoming write data contains X/Z bits!", $time);

`endif

endmodule : ram_protocol_assertions
