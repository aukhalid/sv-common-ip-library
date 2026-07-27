// ==============================================================================
// AUTHOR      : Ahasan Ullah Khalid
// PROJECT     : sv-common-ip-library
// FILE        : two_flop_sync_assertions.sv
// DESCRIPTION : Formal assertions for two_flop_sync.
// ==============================================================================

`include "assert_macros.svh"

module two_flop_sync_assertions #(
    int WIDTH = 1
) (
    input logic             clk_i,
    input logic             rst_n_i,
    input logic [WIDTH-1:0] async_data_i,
    input logic [WIDTH-1:0] sync_data_o
);

`ifdef SIMULATION

  // 1. Control Guard: Catch X/Z states on active reset line
  `ASSERT_NO_X(clk_i, rst_n_i, "two_flop_sync rst_n_i resolved to X/Z state")

  // 2. Stable Reset Assertion: Output must reflect RESET_VAL while reset is active
  property p_reset_held;
    @(posedge clk_i) !rst_n_i |=> (sync_data_o == '0);
  endproperty
  assert property (p_reset_held)
  else $error("[PROTOCOL VIOLATION] Output modified while reset active!");

`endif

endmodule : two_flop_sync_assertions
