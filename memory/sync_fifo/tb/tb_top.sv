`timescale 1ns / 1ps

module tb_top;

  import tb_pkg::*;

  localparam int DATA_WIDTH = 32;
  localparam int ADDR_WIDTH = 4;

  logic clk = 0;
  logic arst_n;

  always #5.0 clk = ~clk;

  clk_rst_if clk_if ();
  fifo_if #(.DATA_WIDTH(DATA_WIDTH)) fifo_vif ();

  assign clk_if.clk   = clk;
  assign clk_if.rst_n = arst_n;

  // DUT Instantiation
  sync_fifo #(
      .DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(ADDR_WIDTH)
  ) DUT (
      .clk_i    (clk_if.clk),
      .arst_n_i (clk_if.rst_n),
      .wr_en_i  (fifo_vif.wr_en),
      .wr_data_i(fifo_vif.wr_data),
      .full_o   (fifo_vif.full),

      .rd_en_i    (fifo_vif.rd_en),
      .rd_data_o  (fifo_vif.rd_data),
      .empty_o    (fifo_vif.empty),
      .occupancy_o()
  );

  sync_fifo_environment #(.DATA_WIDTH(DATA_WIDTH)) env;

  initial begin
    arst_n = 0;
    #25;
    arst_n = 1;
  end

  initial begin
    env = new(clk_if, fifo_vif);
    env.gen.num_transactions = 1000;
    env.run();
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_top);
  end

endmodule : tb_top
