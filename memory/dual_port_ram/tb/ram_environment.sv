// ==============================================================================
// FILE: memory/dual_port_ram/tb/ram_environment.sv
// ==============================================================================

class ram_environment #(
    int DATA_WIDTH = 32,
    int ADDR_WIDTH = 8
);

  typedef ram_transaction#(DATA_WIDTH, ADDR_WIDTH) trans_t;

  ram_generator #(DATA_WIDTH, ADDR_WIDTH)  gen;
  ram_driver #(DATA_WIDTH, ADDR_WIDTH)     drv;
  ram_monitor #(DATA_WIDTH, ADDR_WIDTH)    mon;
  ram_scoreboard #(DATA_WIDTH, ADDR_WIDTH) scb;

  mailbox #(trans_t)                       gen_to_drv;
  mailbox #(trans_t)                       mon_to_scb;

  event                                    gen_done;

  function new(virtual clk_rst_if wclk_if, virtual clk_rst_if rclk_if,
               virtual memory_if #(
                   .DATA_WIDTH(DATA_WIDTH),
                   .ADDR_WIDTH(ADDR_WIDTH)
               ) mem_vif);
    gen_to_drv = new();
    mon_to_scb = new();

    gen = new(gen_to_drv, gen_done);
    drv = new(wclk_if, rclk_if, mem_vif, gen_to_drv);
    mon = new(wclk_if, rclk_if, mem_vif, mon_to_scb);
    scb = new(mon_to_scb);
  endfunction

  task pre_test();
    $display("[ENVIRONMENT] Clearing mailbox buffers and initializing test sequence...");
  endtask

  task test();
    fork
      gen.run();
      drv.run();
      mon.run();
      scb.run();
    join_any
  endtask

  task post_test();
    @gen_done;
    #500;  // Allow remaining read pipeline transactions to settle
    scb.report();
    $display("=== [SIMULATION COMPLETED CLEANLY] ===");
    $finish;
  endtask

  task run();
    pre_test();
    test();
    post_test();
  endtask

endclass : ram_environment
