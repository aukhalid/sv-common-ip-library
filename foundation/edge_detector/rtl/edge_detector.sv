// ==============================================================================
// AUTHOR      : Ahasan Ullah Khalid
// PROJECT     : sv-common-ip-library
// FILE        : edge_detector.sv
// MODULE      : edge_detector
// DESCRIPTION : Parameterized Multi-Bit Edge Detector (Rising, Falling, Any Edge).
//               - Generates 1-cycle wide pulses upon signal transition.
//               - Pure synthesizable SystemVerilog with SVA guards.
// ==============================================================================

`include "assert_macros.svh"

module edge_detector #(
    int WIDTH = 1
) (
    input logic             clk_i,
    input logic             rst_n_i,
    input logic [WIDTH-1:0] signal_i,

    output logic [WIDTH-1:0] pos_edge_o,
    output logic [WIDTH-1:0] neg_edge_o,
    output logic [WIDTH-1:0] any_edge_o
);

  // ----------------------------------------------------------------------------
  // 1. History Register Pipeline Stage
  // ----------------------------------------------------------------------------
  logic [WIDTH-1:0] signal_d1;

  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      signal_d1 <= '0;
    end else begin
      signal_d1 <= signal_i;
    end
  end

  // ----------------------------------------------------------------------------
  // 2. Combinational Edge Detection Output Logic
  // ----------------------------------------------------------------------------
  assign pos_edge_o = signal_i & ~signal_d1;
  assign neg_edge_o = ~signal_i & signal_d1;
  assign any_edge_o = signal_i ^ signal_d1;

  // ----------------------------------------------------------------------------
  // 3. SystemVerilog Assertions (SVA)
  // ----------------------------------------------------------------------------
`ifdef SIMULATION
  `ASSERT_NO_X(clk_i, rst_n_i, "edge_detector rst_n_i resolved to X/Z state")

  // Mutually exclusive edge assertion (pos and neg cannot trigger simultaneously on same bit)
  property p_mutually_exclusive_edges;
    @(posedge clk_i) disable iff (!rst_n_i) (pos_edge_o & neg_edge_o) == '0;
  endproperty
  assert property (p_mutually_exclusive_edges)
  else $error("[EDGE_DETECTOR ERROR] Simultaneous pos_edge and neg_edge detected!");
`endif

endmodule : edge_detector
