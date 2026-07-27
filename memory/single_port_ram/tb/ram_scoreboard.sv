// ==============================================================================
// FILE: memory/single_port_ram/tb/ram_scoreboard.sv
// ASSET: Self-Checking Software Reference Scoreboard Model Class
// ==============================================================================

class ram_scoreboard #(
    int DATA_WIDTH = 32,
    int ADDR_WIDTH = 8
);

  mailbox #(ram_transaction #(
      .DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(ADDR_WIDTH)
  )) mon_to_scb;

  // Software golden reference associative lookup table mirroring memory tracking loops
  logic [DATA_WIDTH-1:0] reference_memory[logic [ADDR_WIDTH-1:0]];

  int check_count = 0;
  int error_count = 0;

  function new(
  mailbox#(ram_transaction#(
  .DATA_WIDTH(DATA_WIDTH),
  .ADDR_WIDTH(ADDR_WIDTH)
               )) mon_to_scb);
    this.mon_to_scb = mon_to_scb;
  endfunction

  task run();
    forever begin
      ram_transaction #(
          .DATA_WIDTH(DATA_WIDTH),
          .ADDR_WIDTH(ADDR_WIDTH)
      ) trans;
      logic [DATA_WIDTH-1:0] expected_data;

      mon_to_scb.get(trans);
      check_count++;

      if (trans.wr_en) begin
        // Synchronize the reference lookup array data on write executions
        reference_memory[trans.addr] = trans.wr_data;
        // Reflect your default WRITE_FIRST (Read-Through-Write) timing expectations
        expected_data = trans.wr_data;

        // Perform data verification checks
        if (trans.rd_data !== expected_data) begin
          $error(
              "[SCOREBOARD MISMATCH] Time: %0t | WRITE_FIRST Collision Failure! Addr: 0x%h | Got: 0x%h | Expected: 0x%h",
              $time, trans.addr, trans.rd_data, expected_data);
          error_count++;
        end
      end else begin
        // Read operation evaluation path
        if (reference_memory.exists(trans.addr)) begin
          expected_data = reference_memory[trans.addr];
        end else begin
          expected_data = '0;  // Uninitialized software fallback state matching reset pipeline
        end

        if (trans.rd_data !== expected_data) begin
          $error(
              "[SCOREBOARD MISMATCH] Time: %0t | Read Integrity Failure! Addr: 0x%h | Got: 0x%h | Expected: 0x%h",
              $time, trans.addr, trans.rd_data, expected_data);
          error_count++;
        end
      end
    end
  endtask

endclass : ram_scoreboard
