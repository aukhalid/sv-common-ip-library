// ==============================================================================
// AUTHOR      : Ahasan Ullah Khalid
// PROJECT     : sv-common-ip-library
// FILE        : ram_transaction.sv
// ASSET       : Random Transaction Data Model Container Class
// ==============================================================================

class ram_transaction #(
    int DATA_WIDTH = 32,
    int ADDR_WIDTH = 32
);

  rand logic wr_en;
  rand logic [ADDR_WIDTH-1:0] addr;
  rand logic [DATA_WIDTH-1:0] wr_data;
  logic [DATA_WIDTH-1:0] rd_data;

  // Constraint to ensure address is within valid range
  constraint rw_balance_c {
    wr_en dist {
      1 := 50,
      0 := 50
    };  // 50% chance of read or write
    addr inside {[0 : (1 << ADDR_WIDTH) - 1]};  // Address within valid range
  }

  function void display_transaction();
    $display("[Transaction]: wr_en=%0b, addr=%0h, wr_data=%0h, rd_data=%0h", wr_en, addr, wr_data,
             rd_data);
  endfunction : display_transaction
endclass : ram_transaction
