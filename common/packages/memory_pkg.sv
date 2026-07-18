// ==============================================================================
// AUTHOR      : Ahasan Ullah Khalid
// PROJECT     : sv-common-ip-library
// ASSET       : memory_pkg.sv (Global Memory Package)
// Description : Shared types/functions for RAM-family IPs (single_port_ram, dual_port_ram, async/sync FIFO, etc).
//               Import this package instead of re-declaring write-mode enums per module.
// ==============================================================================

`ifndef MEMORY_PKG_SV
`define MEMORY_PKG_SV

package memory_pkg;

  //Define a parameterized memory type
  parameter int RAM_DEFAULT_DATA_WIDTH = 32;
  parameter int RAM_DEFAULT_ADDR_WIDTH = 32;

  //---------------------------------------------------------------------
  // Write/read collision policy, shared by all RAM-family modules
  //---------------------------------------------------------------------
  typedef enum logic [1:0] {
    WRITE_FIRST = 2'b00,  // rdata reflects the value just written
    READ_FIRST  = 2'b01,  // rdata reflects the old value, then mem updates
    NO_CHANGE   = 2'b10   // rdata holds previous value during a write cycle
  } write_mode_e;

  //---------------------------------------------------------------------
  // clogb2 : ceiling(log2(value)) — used to size ADDR_WIDTH from DEPTH
  //---------------------------------------------------------------------
  function automatic int clogb2(input int value);
    int temp;
    begin
      temp = value - 1;
      for (clogb2 = 0; temp > 0; clogb2++) temp = temp >> 1;
    end
  endfunction

endpackage : memory_pkg

`endif  // MEMORY_PKG_SV
