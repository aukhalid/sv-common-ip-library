class async_fifo_environment #(
    int DATA_WIDTH = 32
);
  typedef async_fifo_transaction#(DATA_WIDTH) trans_t;

  async_fifo_generator #(DATA_WIDTH)  gen;
  async_fifo_driver #(DATA_WIDTH)     drv;
  async_fifo_monitor #(DATA_WIDTH)    mon;
  async_fifo_scoreboard #(DATA_WIDTH) scb;

  mailbox #(trans_t)                  gen_to_drv;
  mailbox #(trans_t)                  mon_to_scb;
  event                               gen_done;

  function new(virtual clk_rst_if wclk_if, virtual clk_rst_if rclk_if,
               virtual fifo_if #(.DATA_WIDTH(DATA_WIDTH)) fifo_vif);
    gen_to_drv = new();
    mon_to_scb = new();

    gen = new(gen_to_drv, gen_done);
    drv = new(wclk_if, rclk_if, fifo_vif, gen_to_drv);
    mon = new(wclk_if, rclk_if, fifo_vif, mon_to_scb);
    scb = new(mon_to_scb);
  endfunction

  task run();
    fork
      gen.run();
      drv.run();
      mon.run();
      scb.run();
    join_any

    @gen_done;
    #1000;
    scb.report();
    $finish;
  endtask
endclass : async_fifo_environment
