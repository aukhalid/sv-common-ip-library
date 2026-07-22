// ==============================================================================
// AUTHOR      : Ahasan Ullah Khalid
// PROJECT     : sv-common-ip-library
// FILE        : single_port_ram.sv
// MODULE      : single_port_ram
// DESCRIPTION : Fully parameterized, synchronous single-port RAM (Pure Standalone RTL).
//               - Self-contained: Zero dependencies on external packages.
//               - Write Modes: 0 = WRITE_FIRST, 1 = READ_FIRST, 2 = NO_CHANGE.
//               - Includes embedded SystemVerilog Assertions (SVA) for DV monitoring.
// ==============================================================================

`include "assert_macros.svh"

module single_port_ram #(
    int DATA_WIDTH = 32,   // Bit width of data bus
    int ADDR_WIDTH = 8,    // Address bus width (Depth = 2^ADDR_WIDTH)
    bit OUT_REG    = 1'b0, // 0 = Unregistered (1 cycle latency), 1 = Registered (2 cycle latency)
    int WRITE_MODE = 0     // 0 = WRITE_FIRST (Read-Through-Write)


) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic                  wr_en_i,
    input  logic [ADDR_WIDTH-1:0] addr_i,
    input  logic [DATA_WIDTH-1:0] wr_data_i,
    output logic [DATA_WIDTH-1:0] rd_data_o
);

  // ----------------------------------------------------------------------------
  // 1. Local Architectural Constants & Memory Core Matrix
  // ----------------------------------------------------------------------------
  localparam int DEPTH = 1 << ADDR_WIDTH;

  // Memory array cell matrix
  logic [DATA_WIDTH-1:0] mem_core[DEPTH];

  // Pipeline registers
  logic [DATA_WIDTH-1:0] ram_data_out;
  logic [DATA_WIDTH-1:0] ram_data_reg;

  // Local Write Mode Symbolic Constants
  localparam int ModeWriteFirst = 0;
  localparam int ModeReadFirst = 1;
  localparam int ModeNoChange = 2;

  // ----------------------------------------------------------------------------
  // 2. Synchronous Write Operation Channel
  // ----------------------------------------------------------------------------
  always_ff @(posedge clk_i) begin
    if (wr_en_i) begin
      mem_core[addr_i] <= wr_data_i;
    end
  end

  // ----------------------------------------------------------------------------
  // 3. Synchronous Read Channel & Collision Behavior
  // ----------------------------------------------------------------------------
  always_ff @(posedge clk_i) begin
    if (!rst_n_i) begin
      ram_data_out <= '0;
    end else begin
      if (wr_en_i) begin
        case (WRITE_MODE)
          ModeWriteFirst: ram_data_out <= wr_data_i;
          ModeReadFirst:  ram_data_out <= mem_core[addr_i];
          ModeNoChange:   ram_data_out <= ram_data_out;
          default:        ram_data_out <= wr_data_i;
        endcase
      end else begin
        ram_data_out <= mem_core[addr_i];
      end
    end
  end

  // ----------------------------------------------------------------------------
  // 4. Optional Output Pipeline Register Stage (OUT_REG)
  // ----------------------------------------------------------------------------
  always_ff @(posedge clk_i) begin
    if (!rst_n_i) begin
      ram_data_reg <= '0;
    end else begin
      ram_data_reg <= ram_data_out;
    end
  end

  // Mux output selection
  assign rd_data_o = (OUT_REG) ? ram_data_reg : ram_data_out;

  // ----------------------------------------------------------------------------
  // 5. Embedded SystemVerilog Assertions (SVA) Layer
  // ----------------------------------------------------------------------------
`ifdef SIMULATION

  // 1. Concurrent Guard: Catch unknown X/Z states on Write Enable
  `ASSERT_NO_X(clk_i, wr_en_i, "RAM wr_en_i line resolved to an unknown X/Z state")

  // 2. Protocol Guard: Ensure address stability during active writes
  property p_stable_addr_during_write;
    @(posedge clk_i) disable iff (!rst_n_i) wr_en_i |-> !$isunknown(
        addr_i
    );
  endproperty
  assert property (p_stable_addr_during_write)
  else
    $error("[PROTOCOL VIOLATION] Time: %0t | addr_i contains X/Z bits during active write!", $time);

  // 3. Data Guard: Catch invalid write data streams
  property p_no_x_data_during_write;
    @(posedge clk_i) disable iff (!rst_n_i) wr_en_i |-> !$isunknown(
        wr_data_i
    );
  endproperty
  assert property (p_no_x_data_during_write)
  else
    $error("[DATA VIOLATION] Time: %0t | wr_data_i contains X/Z bits during active write!", $time);

`endif

endmodule : single_port_ram
