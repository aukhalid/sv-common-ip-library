// ==============================================================================
// FILE: memory/async_fifo/tb/async_fifo_driver.sv
// ==============================================================================

class async_fifo_driver #(
    int DATA_WIDTH = 32
);
  typedef async_fifo_transaction#(DATA_WIDTH) trans_t;

  virtual clk_rst_if wclk_if;
  virtual clk_rst_if rclk_if;
  virtual fifo_if #(.DATA_WIDTH(DATA_WIDTH)) fifo_vif;
  mailbox #(trans_t) gen_to_drv;

  function new(virtual clk_rst_if wclk_if, virtual clk_rst_if rclk_if,
               virtual fifo_if #(.DATA_WIDTH(DATA_WIDTH)) fifo_vif, mailbox#(trans_t) gen_to_drv);
    this.wclk_if    = wclk_if;
    this.rclk_if    = rclk_if;
    this.fifo_vif   = fifo_vif;
    this.gen_to_drv = gen_to_drv;
  endfunction

  task run();
    fifo_vif.wr_en   <= 1'b0;
    fifo_vif.wr_data <= '0;
    fifo_vif.rd_en   <= 1'b0;

    fork
      wait (wclk_if.rst_n == 1'b1);
      wait (rclk_if.rst_n == 1'b1);
    join

    forever begin
      trans_t trans;
      gen_to_drv.get(trans);

      fork
        // Write Domain Drive Thread
        begin
          @(posedge wclk_if.clk);
          if (trans.wr_en && !fifo_vif.full) begin
            fifo_vif.wr_en   <= 1'b1;
            fifo_vif.wr_data <= trans.wr_data;
            @(posedge wclk_if.clk);
            fifo_vif.wr_en <= 1'b0;
          end
        end

        // Read Domain Drive Thread
        begin
          @(posedge rclk_if.clk);
          if (trans.rd_en && !fifo_vif.empty) begin
            fifo_vif.rd_en <= 1'b1;
            @(posedge rclk_if.clk);
            fifo_vif.rd_en <= 1'b0;
          end
        end
      join
    end
  endtask
endclass : async_fifo_driver
