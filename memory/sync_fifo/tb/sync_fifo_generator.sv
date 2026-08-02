class sync_fifo_generator #(
    int DATA_WIDTH = 32
);
  typedef sync_fifo_transaction#(DATA_WIDTH) trans_t;
  mailbox #(trans_t) gen_to_drv;
  int num_transactions = 1000;
  event gen_done;

  function new(mailbox#(trans_t) gen_to_drv, event gen_done);
    this.gen_to_drv = gen_to_drv;
    this.gen_done   = gen_done;
  endfunction

  task run();
    repeat (num_transactions) begin
      trans_t trans = new();
      if (!trans.randomize()) $fatal(1, "[GEN ERROR] Randomization failed!");
      gen_to_drv.put(trans.clone());
    end
    ->gen_done;
  endtask
endclass : sync_fifo_generator
