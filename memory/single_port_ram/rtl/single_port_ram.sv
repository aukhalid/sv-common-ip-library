// ==============================================================================
// AUTHOR      : Ahasan Ullah Khalid
// PROJECT     : sv-common-ip-library
// File        : single_port_ram.sv
// Module      : single_port_ram
// Description : Fully parameterized, synchronous single-port RAM.
//               - Single cs/we-controlled port: one read OR one write per
//                 clock cycle.
//               - Write/read collision policy selectable via WRITE_MODE
//                 (WRITE_FIRST / READ_FIRST / NO_CHANGE), from ram_pkg.
//               - Optional output pipeline register (OUT_REG) for higher
//                 Fmax at the cost of 1 extra cycle of read latency.
//               - mem[] is intentionally NOT reset — real SRAM/BRAM has no
//                 global reset; only the output register is cleared.
//=============================================================================

// ==============================================================================
// MODULE: single_port_ram
// ==============================================================================

module single_port_ram #(
    int                      DATA_WIDTH = memory_pkg::RAM_DEFAULT_DATA_WIDTH,
    int                      ADDR_WIDTH = memory_pkg::RAM_DEFAULT_ADDR_WIDTH,
    bit                      OUT_REG    = 1'b0,
    memory_pkg::write_mode_e WRITE_MODE = memory_pkg::WRITE_FIRST
) (
    input  logic                  clk_i,
    input  logic                  rst_n_i,
    input  logic                  wr_en_i,
    input  logic [ADDR_WIDTH-1:0] addr_i,
    input  logic [DATA_WIDTH-1:0] wr_data_i,
    output logic [DATA_WIDTH-1:0] rd_data_o
);

  import memory_pkg::*;

  localparam int DEPTH = 1 << ADDR_WIDTH;
  logic [DATA_WIDTH-1:0] mem_core[DEPTH];
  logic [DATA_WIDTH-1:0] ram_data_out;
  logic [DATA_WIDTH-1:0] ram_data_reg;

  always_ff @(posedge clk_i) begin
    if (wr_en_i) mem_core[addr_i] <= wr_data_i;
  end

  always_ff @(posedge clk_i) begin
    if (!rst_n_i) begin
      ram_data_out <= '0;
    end else begin
      if (wr_en_i) begin
        case (WRITE_MODE)
          WRITE_FIRST: ram_data_out <= wr_data_i;
          READ_FIRST:  ram_data_out <= mem_core[addr_i];
          NO_CHANGE:   ram_data_out <= ram_data_out;
          default:     ram_data_out <= wr_data_i;
        endcase
      end else begin
        ram_data_out <= mem_core[addr_i];
      end
    end
  end

  always_ff @(posedge clk_i) begin
    if (!rst_n_i) ram_data_reg <= '0;
    else ram_data_reg <= ram_data_out;
  end

  assign rd_data_o = (OUT_REG) ? ram_data_reg : ram_data_out;


  // `ifdef SIMULATION

  //   // 1. Concurrent Guard: Catch X/Z states on the Control Line
  //   `ASSERT_NO_X(clk, wr_en, "Target block wr_en line resolved to an unknown X state")

  //   // 2. Protocol Guard: Ensure address stability during active writes
  //   property p_stable_addr_during_write;
  //     @(posedge clk) disable iff (!rst_n) wr_en |-> !$isunknown(
  //         addr
  //     );
  //   endproperty
  //   assert property (p_stable_addr_during_write)
  //   else
  //     $error("[PROTOCOL VIOLATION] Input address contains X/Z bits during an active write command!");

  //   // 3. Data Guard: Catch non-deterministic data streams during writes
  //   property p_no_x_data_during_write;
  //     @(posedge clk) disable iff (!rst_n) wr_en |-> !$isunknown(
  //         wr_data
  //     );
  //   endproperty
  //   assert property (p_no_x_data_during_write)
  //   else $error("[DATA VIOLATION] Incoming write data bus contains non-deterministic X/Z bits!");

  // `endif

endmodule : single_port_ram
