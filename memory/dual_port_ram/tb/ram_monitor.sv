// ==============================================================================
// FILE: memory/dual_port_ram/tb/ram_monitor.sv
// ==============================================================================

class ram_monitor #(
    int DATA_WIDTH = 32,
    int ADDR_WIDTH = 8
);

  typedef ram_transaction#(DATA_WIDTH, ADDR_WIDTH) trans_t;

  virtual clk_rst_if wclk_if;
  virtual clk_rst_if rclk_if;
  virtual memory_if #(
      .DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(ADDR_WIDTH)
  ) mem_vif;

  mailbox #(trans_t) mon_to_scb;

  function new(virtual clk_rst_if wclk_if, virtual clk_rst_if rclk_if,
               virtual memory_if #(
                   .DATA_WIDTH(DATA_WIDTH),
                   .ADDR_WIDTH(ADDR_WIDTH)
               ) mem_vif,
               mailbox#(trans_t) mon_to_scb);
    this.wclk_if    = wclk_if;
    this.rclk_if    = rclk_if;
    this.mem_vif    = mem_vif;
    this.mon_to_scb = mon_to_scb;
  endfunction

  task run();
    fork
      sample_write_domain();
      sample_read_domain();
    join
  endtask

  // Monitor Write Domain activity
  task sample_write_domain();
    forever begin
      @(posedge wclk_if.clk);
      if (wclk_if.rst_n && mem_vif.wr_en) begin
        trans_t trans = new();
        trans.wr_en   = 1'b1;
        trans.waddr   = mem_vif.addr;
        trans.wr_data = mem_vif.wr_data;
        trans.rd_en   = 1'b0;
        mon_to_scb.put(trans);
      end
    end
  endtask

  // Monitor Read Domain activity
  task sample_read_domain();
    logic [ADDR_WIDTH-1:0] prev_raddr;
    logic active_read;

    forever begin
      @(posedge rclk_if.clk);
      if (rclk_if.rst_n && !mem_vif.wr_en) begin
        // Detect active read request when address is valid and wr_en is low
        if (mem_vif.addr !== prev_raddr) begin
          trans_t trans = new();
          trans.wr_en = 1'b0;
          trans.rd_en = 1'b1;
          trans.raddr = mem_vif.addr;
          prev_raddr  = mem_vif.addr;

          // Read latency sampling
          @(posedge rclk_if.clk);
          trans.rd_data = mem_vif.rd_data;
          mon_to_scb.put(trans);
        end
      end
    end
  endtask

endclass : ram_monitor
