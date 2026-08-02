// ==============================================================================
// AUTHOR      : Ahasan Ullah Khalid
// PROJECT     : sv-common-ip-library
// FILE        : two_flop_sync.sv
// MODULE      : two_flop_sync
// DESCRIPTION : Parameterized 2-Flip-Flop Synchronizer for Clock Domain Crossing.
//               - Eliminates metastability when transferring signals across domains.
//               - Pure standalone RTL with ASYNC_REG synthesis attributes.
// ==============================================================================

`include "assert_macros.svh"

module two_flop_sync #(
    int WIDTH = 1,
    logic [WIDTH-1:0] RESET_VAL = '0
) (
    input  logic             clk_i,         // Destination Clock
    input  logic             rst_n_i,       // Destination Active-Low Reset
    input  logic [WIDTH-1:0] async_data_i,  // Asynchronous Input
    output logic [WIDTH-1:0] sync_data_o    // Synchronized Output
);

  // ----------------------------------------------------------------------------
  // Synthesis Attributes: Enforce close physical placement in ASIC/FPGA layout
  // ----------------------------------------------------------------------------
  // (* ASYNC_REG = "TRUE" *) tells Vivado/Quartus/DesignCompiler to place
  // flop_stage1 and flop_stage2 in the exact same logic slice/cell.
  (* ASYNC_REG = "TRUE" *)logic [WIDTH-1:0] flop_stage1;
  (* ASYNC_REG = "TRUE" *)logic [WIDTH-1:0] flop_stage2;

  // ----------------------------------------------------------------------------
  // 2-Stage Flip-Flop Synchronizer Chain
  // ----------------------------------------------------------------------------
  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      flop_stage1 <= RESET_VAL;
      flop_stage2 <= RESET_VAL;
    end else begin
      flop_stage1 <= async_data_i;  // Captures raw async signal (May go metastable)
      flop_stage2 <= flop_stage1;  // Resolves metastability to clean logic level
    end
  end

  // Driven output from stage 2
  assign sync_data_o = flop_stage2;

  // ----------------------------------------------------------------------------
  // SystemVerilog Assertions (SVA)
  // ----------------------------------------------------------------------------
`ifdef SIMULATION
  `ASSERT_NO_X(clk_i, rst_n_i, "two_flop_sync active reset line resolved to X/Z state")
`endif

endmodule : two_flop_sync
