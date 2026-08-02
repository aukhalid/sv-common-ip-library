// ==============================================================================
// AUTHOR      : Ahasan Ullah Khalid
// PROJECT     : sv-common-ip-library
// FILE        : fifo_if.sv
// INTERFACE   : fifo_if
// DESCRIPTION : Generic SystemVerilog Interface for Synchronous & Asynchronous
//               FIFOs. Encapsulates push/pop control signals, data buses, and
//               status flags.
// ==============================================================================

interface fifo_if #(
    int DATA_WIDTH = 32
);

  // ----------------------------------------------------------------------------
  // 1. Interface Control & Data Bus Declarations
  // ----------------------------------------------------------------------------

  // Write Channel Domain
  logic                  wr_en;
  logic [DATA_WIDTH-1:0] wr_data;
  logic                  full;
  logic                  almost_full;

  // Read Channel Domain
  logic                  rd_en;
  logic [DATA_WIDTH-1:0] rd_data;
  logic                  empty;
  logic                  almost_empty;

  // ----------------------------------------------------------------------------
  // 2. Modports for Architectural Scoping
  // ----------------------------------------------------------------------------

  // Testbench Driver Modport
  modport DRIVER(
      output wr_en,
      output wr_data,
      output rd_en,
      input full,
      input almost_full,
      input empty,
      input almost_empty,
      input rd_data
  );

  // Testbench Passive Monitor Modport
  modport MONITOR(
      input wr_en,
      input wr_data,
      input full,
      input almost_full,
      input rd_en,
      input rd_data,
      input empty,
      input almost_empty
  );

  // DUT Passive Connection Modport
  modport DUT(
      input wr_en,
      input wr_data,
      output full,
      output almost_full,
      input rd_en,
      output rd_data,
      output empty,
      output almost_empty
  );

endinterface : fifo_if
