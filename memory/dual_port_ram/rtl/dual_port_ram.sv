// ==============================================================================
// AUTHOR      : Ahasan Ullah Khalid
// PROJECT     : sv-common-ip-library
// FILE        : dual_port_ram.sv
// MODULE      : dual_port_ram
// DESCRIPTION : Parameterized Dual-Clock Simple Dual-Port RAM (Pure Standalone RTL).
//               - Independent Write (wr_clk_i) and Read (rd_clk_i) clock domains.
//               - Zero external package dependencies for maximum physical IP portability.
//               - Embedded SVA for protocol and stability monitoring.
// ==============================================================================

`include "assert_macros.svh"

module dual_port_ram #(
    int DATA_WIDTH = 32,
    int ADDR_WIDTH = 8,
    bit OUT_REG    = 1'b0  // 0 = Unregistered (1 cycle latency), 1 = Registered (2 cycle latency)
) (
    // Write Port Interface (Write Clock Domain)
    input logic                  wr_clk_i,
    input logic                  wr_rst_n_i,
    input logic                  wr_en_i,
    input logic [ADDR_WIDTH-1:0] wr_addr_i,
    input logic [DATA_WIDTH-1:0] wr_data_i,

    // Read Port Interface (Read Clock Domain)
    input  logic                  rd_clk_i,
    input  logic                  rd_rst_n_i,
    input  logic                  rd_en_i,
    input  logic [ADDR_WIDTH-1:0] rd_addr_i,
    output logic [DATA_WIDTH-1:0] rd_data_o
);

  // ----------------------------------------------------------------------------
  // 1. Local Memory Array Matrix & Internal Pipelines
  // ----------------------------------------------------------------------------
  localparam int DEPTH = 1 << ADDR_WIDTH;

  // Dual-Port memory matrix array
  logic [DATA_WIDTH-1:0] mem_core[DEPTH];

  // Read pipeline registers
  logic [DATA_WIDTH-1:0] ram_data_out;
  logic [DATA_WIDTH-1:0] ram_data_reg;

  // ----------------------------------------------------------------------------
  // 2. Synchronous Write Channel (wr_clk_i Domain)
  // ----------------------------------------------------------------------------
  always_ff @(posedge wr_clk_i) begin
    if (wr_en_i) begin
      mem_core[wr_addr_i] <= wr_data_i;
    end
  end

  // ----------------------------------------------------------------------------
  // 3. Synchronous Read Channel (rd_clk_i Domain)
  // ----------------------------------------------------------------------------
  always_ff @(posedge rd_clk_i) begin
    if (!rd_rst_n_i) begin
      ram_data_out <= '0;
    end else begin
      if (rd_en_i) begin
        ram_data_out <= mem_core[rd_addr_i];
      end
    end
  end

  // ----------------------------------------------------------------------------
  // 4. Optional Output Pipeline Register Stage (OUT_REG)
  // ----------------------------------------------------------------------------
  always_ff @(posedge rd_clk_i) begin
    if (!rd_rst_n_i) begin
      ram_data_reg <= '0;
    end else begin
      ram_data_reg <= ram_data_out;
    end
  end

  // Continuous assignment output multiplexer
  assign rd_data_o = (OUT_REG) ? ram_data_reg : ram_data_out;

  // ----------------------------------------------------------------------------
  // Initialize Memory Array for Simulation (Prevents 'x on unwritten reads)
  // ----------------------------------------------------------------------------
`ifdef SIMULATION
  initial begin
    for (int i = 0; i < DEPTH; i++) begin
      mem_core[i] = '0;
    end
  end
`endif

  // ----------------------------------------------------------------------------
  // 5. Embedded SystemVerilog Assertions (SVA) Layer
  // ----------------------------------------------------------------------------
`ifdef SIMULATION

  // Write Domain Protocol Guards (Connects wr_rst_n_i to eliminate unused warning)
  `ASSERT_NO_X(wr_clk_i, wr_en_i, "Dual-Port RAM wr_en_i resolved to X/Z state")

  property p_stable_waddr_during_write;
    @(posedge wr_clk_i) disable iff (!wr_rst_n_i) wr_en_i |-> !$isunknown(
        wr_addr_i
    );
  endproperty
  assert property (p_stable_waddr_during_write)
  else $error("[PROTOCOL VIOLATION] Time: %0t | wr_addr_i contains X/Z bits during write!", $time);

  property p_no_x_wdata_during_write;
    @(posedge wr_clk_i) disable iff (!wr_rst_n_i) wr_en_i |-> !$isunknown(
        wr_data_i
    );
  endproperty
  assert property (p_no_x_wdata_during_write)
  else $error("[DATA VIOLATION] Time: %0t | wr_data_i contains X/Z bits during write!", $time);

  // Read Domain Protocol Guards
  `ASSERT_NO_X(rd_clk_i, rd_en_i, "Dual-Port RAM rd_en_i resolved to X/Z state")

  property p_stable_raddr_during_read;
    @(posedge rd_clk_i) disable iff (!rd_rst_n_i) rd_en_i |-> !$isunknown(
        rd_addr_i
    );
  endproperty
  assert property (p_stable_raddr_during_read)
  else $error("[PROTOCOL VIOLATION] Time: %0t | rd_addr_i contains X/Z bits during read!", $time);

`endif

endmodule : dual_port_ram
