class sync_fifo_driver #(
    int DATA_WIDTH = 32
);
  typedef sync_fifo_transaction#(DATA_WIDTH) trans_t;

  virtual clk_rst_if clk_if;
  virtual fifo_if #(.DATA_WIDTH(DATA_WIDTH)) fifo_vif;
  mailbox #(trans_t) gen_to_drv;

  function new(virtual clk_rst_if clk_if, virtual fifo_if #(.DATA_WIDTH(DATA_WIDTH)) fifo_vif,
               mailbox#(trans_t) gen_to_drv);
    this.clk_if     = clk_if;
    this.fifo_vif   = fifo_vif;
    this.gen_to_drv = gen_to_drv;
  endfunction

  task run();
    fifo_vif.wr_en   <= 1'b0;
    fifo_vif.wr_data <= '0;
    fifo_vif.rd_en   <= 1'b0;

    wait (clk_if.rst_n == 1'b1);

    forever begin
      trans_t trans;
      gen_to_drv.get(trans);

      @(posedge clk_if.clk);
      if (trans.wr_en && !fifo_vif.full) begin
        fifo_vif.wr_en   <= 1'b1;
        fifo_vif.wr_data <= trans.wr_data;
      end else begin
        fifo_vif.wr_en <= 1'b0;
      end

      if (trans.rd_en && !fifo_vif.empty) begin
        fifo_vif.rd_en <= 1'b1;
      end else begin
        fifo_vif.rd_en <= 1'b0;
      end
    end
  endtask
endclass : sync_fifo_driver
