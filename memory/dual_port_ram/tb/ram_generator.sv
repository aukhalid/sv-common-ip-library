// ==============================================================================
// FILE: memory/dual_port_ram/tb/ram_generator.sv
// ==============================================================================

class ram_generator #(
    int DATA_WIDTH = 32,
    int ADDR_WIDTH = 8
);

  typedef ram_transaction#(DATA_WIDTH, ADDR_WIDTH) trans_t;

  mailbox #(trans_t) gen_to_drv;
  int num_transactions = 1000;
  event gen_done;

  function new(mailbox#(trans_t) gen_to_drv, event gen_done);
    this.gen_to_drv = gen_to_drv;
    this.gen_done   = gen_done;
  endfunction

  task run();
    $display("[GENERATOR] Starting transaction generation stream (%0d items)...", num_transactions);
    repeat (num_transactions) begin
      trans_t trans = new();
      if (!trans.randomize()) begin
        $fatal(1, "[GENERATOR ERROR] Transaction randomization failed!");
      end
      gen_to_drv.put(trans.clone());
    end
    $display("[GENERATOR] All transactions successfully dispatched.");
    ->gen_done;
  endtask

endclass : ram_generator
