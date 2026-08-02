class sync_fifo_monitor #(
    int DATA_WIDTH = 32
);
  typedef sync_fifo_transaction#(DATA_WIDTH) trans_t;

  virtual clk_rst_if clk_if;
  virtual fifo_if #(.DATA_WIDTH(DATA_WIDTH)) fifo_vif;
  mailbox #(trans_t) mon_to_scb;

  function new(virtual clk_rst_if clk_if, virtual fifo_if #(.DATA_WIDTH(DATA_WIDTH)) fifo_vif,
               mailbox#(trans_t) mon_to_scb);
    this.clk_if     = clk_if;
    this.fifo_vif   = fifo_vif;
    this.mon_to_scb = mon_to_scb;
  endfunction

  task run();
    forever begin
      @(posedge clk_if.clk);
      if (clk_if.rst_n) begin
        // Sample active push
        if (fifo_vif.wr_en && !fifo_vif.full) begin
          trans_t trans = new();
          trans.wr_en   = 1'b1;
          trans.wr_data = fifo_vif.wr_data;
          trans.rd_en   = 1'b0;
          mon_to_scb.put(trans);
        end

        // Sample active pop
        if (fifo_vif.rd_en && !fifo_vif.empty) begin
          trans_t trans = new();
          trans.wr_en = 1'b0;
          trans.rd_en = 1'b1;

          @(posedge clk_if.clk);
          trans.rd_data = fifo_vif.rd_data;
          mon_to_scb.put(trans);
        end
      end
    end
  endtask
endclass : sync_fifo_monitor
