// ==============================================================================
// AUTHOR      : Ahasan Ullah Khalid
// PROJECT     : sv-common-ip-library
// FILE        : sync_fifo.sv
// MODULE      : sync_fifo
// DESCRIPTION : Parameterized Single-Clock Synchronous FIFO with Asynchronous Reset.
//               - Uses $N+1$ bit binary pointer math for Full/Empty detection.
//               - Submodule IP Reuse: Instantiates dual_port_ram core.
// ==============================================================================

`include "assert_macros.svh"

module sync_fifo #(
    int DATA_WIDTH = 32,
    int ADDR_WIDTH = 4
) (
    input logic clk_i,
    input logic arst_n_i,

    // Write Interface
    input  logic                  wr_en_i,
    input  logic [DATA_WIDTH-1:0] wr_data_i,
    output logic                  full_o,

    // Read Interface
    input  logic                  rd_en_i,
    output logic [DATA_WIDTH-1:0] rd_data_o,
    output logic                  empty_o,

    // Status / Occupancy Output
    output logic [ADDR_WIDTH:0] occupancy_o
);

  localparam int PTRWIDTH = ADDR_WIDTH + 1;

  // ----------------------------------------------------------------------------
  // 1. Internal Pointer & Signal Declarations
  // ----------------------------------------------------------------------------
  logic [PTRWIDTH-1:0] wptr_bin;
  logic [PTRWIDTH-1:0] rptr_bin;

  logic memory_write_enable;
  logic memory_read_enable;

  // ----------------------------------------------------------------------------
  // 2. Full / Empty & Occupancy Logic
  // ----------------------------------------------------------------------------
  assign full_o  = (wptr_bin[PTRWIDTH-1] != rptr_bin[PTRWIDTH-1]) &&
                     (wptr_bin[PTRWIDTH-2:0] == rptr_bin[PTRWIDTH-2:0]);

  assign empty_o = (wptr_bin == rptr_bin);

  assign occupancy_o = wptr_bin - rptr_bin;

  assign memory_write_enable = wr_en_i && !full_o;
  assign memory_read_enable = rd_en_i && !empty_o;

  // ----------------------------------------------------------------------------
  // 3. Pointer Update Registers (Asynchronous Active-Low Reset)
  // ----------------------------------------------------------------------------
  always_ff @(posedge clk_i or negedge arst_n_i) begin
    if (!arst_n_i) begin
      wptr_bin <= '0;
      rptr_bin <= '0;
    end else begin
      if (memory_write_enable) begin
        wptr_bin <= wptr_bin + 1'b1;
      end
      if (memory_read_enable) begin
        rptr_bin <= rptr_bin + 1'b1;
      end
    end
  end

  // ----------------------------------------------------------------------------
  // 4. Memory Core Instantiation (Submodule IP Reuse)
  // ----------------------------------------------------------------------------
  dual_port_ram #(
      .DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(ADDR_WIDTH),
      .OUT_REG(1'b0)
  ) u_fifo_mem (
      .wr_clk_i  (clk_i),
      .wr_rst_n_i(arst_n_i),
      .wr_en_i   (memory_write_enable),
      .wr_addr_i (wptr_bin[ADDR_WIDTH-1:0]),
      .wr_data_i (wr_data_i),

      .rd_clk_i  (clk_i),
      .rd_rst_n_i(arst_n_i),
      .rd_en_i   (memory_read_enable),
      .rd_addr_i (rptr_bin[ADDR_WIDTH-1:0]),
      .rd_data_o (rd_data_o)
  );

  // ----------------------------------------------------------------------------
  // 5. SystemVerilog Assertions (SVA)
  // ----------------------------------------------------------------------------
`ifdef SIMULATION
  `ASSERT_NO_X(clk_i, arst_n_i, "sync_fifo arst_n_i resolved to X/Z state")

  property p_no_overflow;
    @(posedge clk_i) disable iff (!arst_n_i) full_o && wr_en_i |=> $stable(
        wptr_bin
    );
  endproperty
  assert property (p_no_overflow)
  else $error("[FIFO OVERFLOW] Push issued while FULL!");

  property p_no_underflow;
    @(posedge clk_i) disable iff (!arst_n_i) empty_o && rd_en_i |=> $stable(
        rptr_bin
    );
  endproperty
  assert property (p_no_underflow)
  else $error("[FIFO UNDERFLOW] Pop issued while EMPTY!");
`endif

endmodule : sync_fifo
