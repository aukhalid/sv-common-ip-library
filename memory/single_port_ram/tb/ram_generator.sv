// ==============================================================================
// AUTHOR      : Ahasan Ullah Khalid
// PROJECT     : sv-common-ip-library
// FILE        : ram_generator.sv
// ASSET       : Random Transaction Generator Class
// ==============================================================================

class ram_generator #(
    int DATA_WIDTH = memory_pkg::RAM_DEFAULT_DATA_WIDTH,
    int ADDR_WIDTH = memory_pkg::RAM_DEFAULT_ADDR_WIDTH
);

  // Instance of the transaction class to generate random transactions
  ram_transaction #(
      .DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(ADDR_WIDTH)
  ) transaction;

  mailbox #(ram_transaction #(
      .DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(ADDR_WIDTH)
  )) gen2drv_mbx;

  int num_transactions;
  event gen_done;

  function new(
      mailbox#(ram_transaction#(
          .DATA_WIDTH(DATA_WIDTH),
          .ADDR_WIDTH(ADDR_WIDTH)
      )) gen2drv_mbx,
      event gen_done);

    this.gen2drv_mbx = gen2drv_mbx;
    this.gen_done = gen_done;
  endfunction : new

  //Master execution block to generate random transactions and send them to the driver
  task run();
    $display("[GENERATOR] Time = %0t: Starting %d random transactions", $time, num_transactions);
    repeat (num_transactions) begin
      transaction = new();
      if (!transaction.randomize()) begin
        $fatal("[GENERATOR ERROR] Time = %0t: Randomization failed for transaction", $time);
      end
      gen2drv_mbx.put(transaction);
    end
    ->gen_done;
    $display("[GENERATOR] Time = %0t: Finished generating %d random transactions", $time,
             num_transactions);

  endtask : run

endclass : ram_generator
