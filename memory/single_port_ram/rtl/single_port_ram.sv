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


  // 1. Local Parameters & Structural Matrix Definitions

  // Deriving memory depth locally
  localparam int DEPTH = 1 << ADDR_WIDTH;

  // Unpacked 2D dense register matrix array mapping the physical memory grid
  logic [DATA_WIDTH-1:0] mem_core[DEPTH];

  // Internal intermediate signals for multi-mode block routing
  logic [DATA_WIDTH-1:0] ram_data_out;
  logic [DATA_WIDTH-1:0] ram_data_reg;


  // 2. Synchronous Core Memory Read/Write Control Loop
  always_ff @(posedge clk_i) begin
    if (wr_en_i) begin
      mem_core[addr_i] <= wr_data_i;
    end
  end

  // Read Data Selection mapping
  always_ff @(posedge clk_i) begin
    if (!rst_n_i) begin
      ram_data_out <= '0;
    end else begin
      if (wr_en_i) begin
        case (WRITE_MODE)
          // WRITE_FIRST: Newly written data flows straight to output
          memory_pkg::WRITE_FIRST: ram_data_out <= wr_data_i;

          // READ_FIRST: Output holds the old data present before write
          memory_pkg::READ_FIRST: ram_data_out <= mem_core[addr_i];

          // NO_CHANGE: Output data bus latches its previous read value
          memory_pkg::NO_CHANGE: ram_data_out <= ram_data_out;

          default: ram_data_out <= wr_data_i;  // Default to WRITE_FIRST behavior
        endcase
      end else begin
        ram_data_out <= mem_core[addr_i];
      end
    end
  end


  // 3. Optional Output Pipelined Target Stage (OUT_REG Control Execution)
  always_ff @(posedge clk_i) begin
    if (!rst_n_i) begin
      ram_data_reg <= '0;
    end else begin
      ram_data_reg <= ram_data_out;
    end
  end

  // Continuous assignment mapping output lines back out using plain logic variants
  assign rd_data_o = (OUT_REG) ? ram_data_reg : ram_data_out;


endmodule : single_port_ram
