// ==============================================================================
// AUTHOR      : Ahasan Ullah Khalid
// PROJECT     : sv-common-ip-library
// FILE        : ram_driver.sv
// ASSET       : Synchronous Virtual Interface Pin Driver Class
// ==============================================================================

class ram_driver #(
    int DATA_WIDTH = memory_pkg::RAM_DEFAULT_DATA_WIDTH,
    int ADDR_WIDTH = memory_pkg::RAM_DEFAULT_ADDR_WIDTH
);

  virtual clk_rst_if.slave clk_rst_vif;
  virtual memory_if #(
      .DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(ADDR_WIDTH)
  ).master mem_vif;

  mailbox #(ram_transaction #(
      .DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(ADDR_WIDTH)
  )) gen2drv_mbx;

  function new(
      virtual clk_rst_if.slave clk_rst_vif,
      virtual memory_if #(
          .DATA_WIDTH(DATA_WIDTH),
          .ADDR_WIDTH(ADDR_WIDTH)
      ).master mem_vif,
      mailbox#(ram_transaction#(
          .DATA_WIDTH(DATA_WIDTH),
          .ADDR_WIDTH(ADDR_WIDTH)
      )) gen2drv_mbx);

    this.clk_rst_vif = clk_rst_vif;
    this.mem_vif = mem_vif;
    this.gen2drv_mbx = gen2drv_mbx;
  endfunction : new

  task run();
    //Force Reset
    mem_vif.wr_en <= 1'b0;
    mem_vif.addr <= '0;
    mem_vif.wr_data <= '0;

    @(posedge clk_rst_vif.clk);
    while (!clk_rst_vif.rst_n) @(posedge clk_rst_vif.clk);

    forever begin

      $display("[DRIVER] Time = %0t: Waiting for transaction from generator", $time);
      ram_transaction #(
          .DATA_WIDTH(DATA_WIDTH),
          .ADDR_WIDTH(ADDR_WIDTH)
      ) transaction;
      gen2drv_mbx.get(transaction);

      mem_vif.wr_en <= transaction.wr_en;
      mem_vif.addr <= transaction.addr;
      mem_vif.wr_data <= transaction.wr_data;

      @(posedge clk_rst_vif.clk);
      $display("[DRIVER] Time = %0t: Transaction received and applied", $time);
    end

  endtask : run

endclass : ram_driver
