class sync_fifo_scoreboard #(
    int DATA_WIDTH = 32
);
  typedef sync_fifo_transaction#(DATA_WIDTH) trans_t;

  mailbox #(trans_t) mon_to_scb;
  logic [DATA_WIDTH-1:0] ref_queue [$];

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
        ref_queue.push_back(trans.wr_data);
      end

      if (trans.rd_en) begin
        if (ref_queue.size() > 0) begin
          logic [DATA_WIDTH-1:0] expected = ref_queue.pop_front();
          if (trans.rd_data === expected) begin
            match_count++;
          end else begin
            mismatch_count++;
            $error("[SCB MISMATCH] Expected: 0x%0h | Actual: 0x%0h", expected, trans.rd_data);
          end
        end else begin
          mismatch_count++;
          $error("[SCB UNDERFLOW] Read detected on empty reference model!");
        end
      end
    end
  endtask

  function void report();
    $display("\n=======================================================");
    $display("           SYNC_FIFO VERIFICATION REPORT               ");
    $display("=======================================================");
    $display(" Total Passed Checks : %0d", match_count);
    $display(" Total Mismatches    : %0d", mismatch_count);
    $display("=======================================================\n");
    if (mismatch_count == 0 && match_count > 0) begin
      $display("=== [TEST PASSED] SYNC_FIFO VERIFIED CLEANLY ===");
    end else begin
      $error("=== [TEST FAILED] VERIFICATION MISMATCHES DETECTED ===");
    end
  endfunction
endclass : sync_fifo_scoreboard
