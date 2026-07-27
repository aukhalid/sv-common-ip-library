// ==============================================================================
// FILE: memory/dual_port_ram/tb/ram_scoreboard.sv
// ==============================================================================

class ram_scoreboard #(
    int DATA_WIDTH = 32,
    int ADDR_WIDTH = 8
);

  typedef ram_transaction#(DATA_WIDTH, ADDR_WIDTH) trans_t;

  mailbox #(trans_t) mon_to_scb;

  // Associative Array Reference Model (Golden Memory Array)
  logic [DATA_WIDTH-1:0] ref_mem [*];

  int match_count    = 0;
  int mismatch_count = 0;

  function new(mailbox#(trans_t) mon_to_scb);
    this.mon_to_scb = mon_to_scb;
  endfunction

  task run();
    trans_t trans;
    forever begin
      mon_to_scb.get(trans);

      if (trans.wr_en) begin
        // Commit to reference memory model
        ref_mem[trans.waddr] = trans.wr_data;
        $display("[SCOREBOARD WRITE] RefMem[0x%0h] <= 0x%0h", trans.waddr, trans.wr_data);
      end

      if (trans.rd_en) begin
        logic [DATA_WIDTH-1:0] expected_data;

        // If address was previously written, look up in ref_mem; else default to 0
        if (ref_mem.exists(trans.raddr)) begin
          expected_data = ref_mem[trans.raddr];
        end else begin
          expected_data = '0;
        end

        if (trans.rd_data === expected_data) begin
          match_count++;
          $display("[SCOREBOARD PASS] Addr: 0x%0h | Expected: 0x%0h | Actual: 0x%0h", trans.raddr,
                   expected_data, trans.rd_data);
        end else begin
          mismatch_count++;
          $error("[SCOREBOARD MISMATCH] Addr: 0x%0h | Expected: 0x%0h | Actual: 0x%0h",
                 trans.raddr, expected_data, trans.rd_data);
        end
      end
    end
  endtask

  function void report();
    $display("\n=======================================================");
    $display("          DUAL-PORT RAM VERIFICATION REPORT            ");
    $display("=======================================================");
    $display(" Total Passed Comparisons : %0d", match_count);
    $display(" Total Mismatches         : %0d", mismatch_count);
    $display("=======================================================\n");
    if (mismatch_count == 0 && match_count > 0) begin
      $display("=== [TEST PASSED] DUAL-PORT RAM VERIFIED CLEANLY ===");
    end else begin
      $error("=== [TEST FAILED] VERIFICATION MISMATCHES DETECTED ===");
    end
  endfunction

endclass : ram_scoreboard
