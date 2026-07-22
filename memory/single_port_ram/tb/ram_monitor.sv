// ==============================================================================
// FILE: memory/single_port_ram/tb/ram_monitor.sv
// ASSET: Passive Bus Tracking Monitor Class
// ==============================================================================

class ram_monitor #(
    int DATA_WIDTH = 32,
    int ADDR_WIDTH = 8
);

  virtual clk_rst_if.slave clk_rst_vif;
  virtual memory_if #(
      .DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(ADDR_WIDTH)
  ).slave mem_vif;

  mailbox #(ram_transaction #(
      .DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(ADDR_WIDTH)
  )) mon_to_scb;

  function new(
      virtual clk_rst_if.slave clk_rst_vif,
      virtual memory_if #(
          .DATA_WIDTH(DATA_WIDTH),
          .ADDR_WIDTH(ADDR_WIDTH)
      ).slave mem_vif,
      mailbox#(ram_transaction#(
          .DATA_WIDTH(DATA_WIDTH),
          .ADDR_WIDTH(ADDR_WIDTH)
      )) mon_to_scb);
    this.clk_rst_vif = clk_rst_vif;
    this.mem_vif     = mem_vif;
    this.mon_to_scb  = mon_to_scb;
  endfunction

  task run();
    // Wait for system configurations to unlock
    @(posedge clk_rst_vif.clk);
    while (!clk_rst_vif.rst_n) @(posedge clk_rst_vif.clk);

    forever begin
      ram_transaction #(
          .DATA_WIDTH(DATA_WIDTH),
          .ADDR_WIDTH(ADDR_WIDTH)
      ) trans;
      trans = new();

      // Sample actual hardware net nodes precisely at the clock evaluation point
      @(posedge clk_rst_vif.clk);
      if (clk_rst_vif.rst_n) begin
        trans.wr_en   = mem_vif.wr_en;
        trans.addr    = mem_vif.addr;
        trans.wr_data = mem_vif.wr_data;

        // Account for 1 clock cycle of internal RAM macro read latency
        #1;  // Minor sampling offset to skip hold time racing conditions
        trans.rd_data = mem_vif.rd_data;

        mon_to_scb.put(trans);
      end
    end
  endtask

endclass : ram_monitor
