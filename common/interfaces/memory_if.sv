// ==============================================================================
// AUTHOR:  Ahasan Ullah Khalid
// PROJECT: sv-common-ip-library
// ASSET:   memory_if.sv (Memory Interface)
// Description : Bundles the single-port RAM signal set for verification use.
//               The RTL module itself uses plain ports (see single_port_ram.sv)
//               so it stays tool-friendly for synthesis/BRAM inference — this
//               interface is for the testbench/UVM agent side, so driver and
//               monitor connect through one handle instead of a loose signal
//               bundle. This is standard practice: interfaces at the TB
//               boundary, plain ports at the synthesizable RTL boundary.
// ==============================================================================

`ifndef RAM_IF_SV
`define RAM_IF_SV

interface memory_if #(
    int DATA_WIDTH = memory_pkg::RAM_DEFAULT_DATA_WIDTH,
    int ADDR_WIDTH = memory_pkg::RAM_DEFAULT_ADDR_WIDTH
);

  // Memory Interface Signals
  logic                  wr_en;
  logic [ADDR_WIDTH-1:0] addr;
  logic [DATA_WIDTH-1:0] wr_data;
  logic [DATA_WIDTH-1:0] rd_data;

  // Modport for memory access (Read/Write)
  modport master(
      output wr_en,
      output addr,
      output wr_data,
      input rd_data
  );  // Master modport for driving memory access signals

  modport slave(
      input wr_en,
      input addr,
      input wr_data,
      output rd_data
  );  // Slave modport for receiving memory access signals

endinterface : memory_if

`endif  // RAM_IF_SV
