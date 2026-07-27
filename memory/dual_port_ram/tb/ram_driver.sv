// ==============================================================================
// FILE: memory/dual_port_ram/tb/ram_driver.sv
// ==============================================================================

class ram_driver #(
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

  mailbox #(trans_t) gen_to_drv;

  function new(virtual clk_rst_if wclk_if, virtual clk_rst_if rclk_if,
               virtual memory_if #(
                   .DATA_WIDTH(DATA_WIDTH),
                   .ADDR_WIDTH(ADDR_WIDTH)
               ) mem_vif,
               mailbox#(trans_t) gen_to_drv);
    this.wclk_if    = wclk_if;
    this.rclk_if    = rclk_if;
    this.mem_vif    = mem_vif;
    this.gen_to_drv = gen_to_drv;
  endfunction

  task run();
    // Reset drive signals
    mem_vif.wr_en   <= 1'b0;
    mem_vif.addr    <= '0;
    mem_vif.wr_data <= '0;

    fork
      wait (wclk_if.rst_n == 1'b1);
      wait (rclk_if.rst_n == 1'b1);
    join

    forever begin
      trans_t trans;
      gen_to_drv.get(trans);

      if (trans.wr_en) begin
        @(posedge wclk_if.clk);
        mem_vif.wr_en   <= 1'b1;
        mem_vif.addr    <= trans.waddr;
        mem_vif.wr_data <= trans.wr_data;

        @(posedge wclk_if.clk);
        mem_vif.wr_en <= 1'b0;  // De-assert write enable
      end else if (trans.rd_en) begin
        @(posedge rclk_if.clk);
        mem_vif.wr_en <= 1'b0;
        mem_vif.addr  <= trans.raddr;

        @(posedge rclk_if.clk);  // Hold address for 1 read cycle
      end
    end
  endtask

endclass : ram_driver
