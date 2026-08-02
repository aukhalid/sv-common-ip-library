class async_fifo_scoreboard #(
    int DATA_WIDTH = 32
);
  typedef async_fifo_transaction#(DATA_WIDTH) trans_t;

  mailbox #(trans_t) mon_to_scb;
  logic [DATA_WIDTH-1:0] expected_queue [$];

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
        expected_queue.push_back(trans.wr_data);
        $display("[SCB PUSH] Pushed 0x%0h into reference queue (Depth: %0d)", trans.wr_data,
                 expected_queue.size());
      end

      if (trans.rd_en) begin
        if (expected_queue.size() > 0) begin
          logic [DATA_WIDTH-1:0] expected_val = expected_queue.pop_front();
          if (trans.rd_data === expected_val) begin
            match_count++;
            $display("[SCB PASS] Popped Data Matched: 0x%0h", trans.rd_data);
          end else begin
            mismatch_count++;
            $error("[SCB MISMATCH] Expected: 0x%0h | Actual: 0x%0h", expected_val, trans.rd_data);
          end
        end else begin
          mismatch_count++;
          $error("[SCB UNDERFLOW] Read operation observed when reference queue was EMPTY!");
        end
      end
    end
  endtask

  function void report();
    $display("\n=======================================================");
    $display("          ASYNC_FIFO VERIFICATION REPORT               ");
    $display("=======================================================");
    $display(" Total Passed Checks : %0d", match_count);
    $display(" Total Mismatches    : %0d", mismatch_count);
    $display("=======================================================\n");
    if (mismatch_count == 0 && match_count > 0) begin
      $display("=== [TEST PASSED] ASYNC_FIFO VERIFIED CLEANLY ===");
    end else begin
      $error("=== [TEST FAILED] VERIFICATION MISMATCHES DETECTED ===");
    end
  endfunction
endclass : async_fifo_scoreboard
