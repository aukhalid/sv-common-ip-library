module tb_top;

  import tb_pkg::*;

  localparam int DATA_WIDTH = 32;
  localparam int ADDR_WIDTH = 4;

  logic wclk = 0;
  logic rclk = 0;
  logic wrst_n;
  logic rrst_n;

  // Asynchronous clocks: 100 MHz (10ns) vs 143.5 MHz (6.968ns)
  always #5.000 wclk = ~wclk;
  always #3.484 rclk = ~rclk;

  clk_rst_if wclk_if ();
  clk_rst_if rclk_if ();
  fifo_if #(.DATA_WIDTH(DATA_WIDTH)) fifo_vif ();

  assign wclk_if.clk   = wclk;
  assign wclk_if.rst_n = wrst_n;
  assign rclk_if.clk   = rclk;
  assign rclk_if.rst_n = rrst_n;

  // DUT Instantiation
  async_fifo #(
      .DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(ADDR_WIDTH)
  ) DUT (
      .wr_clk_i   (wclk_if.clk),
      .wr_rst_n_i (wclk_if.rst_n),
      .wr_en_i  (fifo_vif.wr_en),
      .wr_data_i(fifo_vif.wr_data),
      .full_o   (fifo_vif.full),

      .rd_clk_i   (rclk_if.clk),
      .rd_rst_n_i (rclk_if.rst_n),
      .rd_en_i  (fifo_vif.rd_en),
      .rd_data_o(fifo_vif.rd_data),
      .empty_o  (fifo_vif.empty)
  );

  async_fifo_environment #(.DATA_WIDTH(DATA_WIDTH)) env;

  initial begin
    wrst_n = 0;
    rrst_n = 0;
    #25;
    wrst_n = 1;
    rrst_n = 1;
  end

  initial begin
    env = new(wclk_if, rclk_if, fifo_vif);
    env.gen.num_transactions = 1000;
    env.run();
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_top);
  end

endmodule : tb_top
