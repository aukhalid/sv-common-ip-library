class async_fifo_monitor #(
    int DATA_WIDTH = 32
);
  typedef async_fifo_transaction#(DATA_WIDTH) trans_t;

  virtual clk_rst_if wclk_if;
  virtual clk_rst_if rclk_if;
  virtual fifo_if #(.DATA_WIDTH(DATA_WIDTH)) fifo_vif;
  mailbox #(trans_t) mon_to_scb;

  function new(virtual clk_rst_if wclk_if, virtual clk_rst_if rclk_if,
               virtual fifo_if #(.DATA_WIDTH(DATA_WIDTH)) fifo_vif, mailbox#(trans_t) mon_to_scb);
    this.wclk_if    = wclk_if;
    this.rclk_if    = rclk_if;
    this.fifo_vif   = fifo_vif;
    this.mon_to_scb = mon_to_scb;
  endfunction

  task run();
    fork
      sample_write();
      sample_read();
    join
  endtask

  task sample_write();
    forever begin
      @(posedge wclk_if.clk);
      if (wclk_if.rst_n && fifo_vif.wr_en && !fifo_vif.full) begin
        trans_t trans = new();
        trans.wr_en   = 1'b1;
        trans.wr_data = fifo_vif.wr_data;
        trans.rd_en   = 1'b0;
        mon_to_scb.put(trans);
      end
    end
  endtask

  task sample_read();
    forever begin
      @(posedge rclk_if.clk);
      if (rclk_if.rst_n && fifo_vif.rd_en && !fifo_vif.empty) begin
        trans_t trans = new();
        trans.wr_en = 1'b0;
        trans.rd_en = 1'b1;
        @(posedge rclk_if.clk);
        trans.rd_data = fifo_vif.rd_data;
        mon_to_scb.put(trans);
      end
    end
  endtask
endclass : async_fifo_monitor
