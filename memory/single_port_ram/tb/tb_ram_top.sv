// ==============================================================================
// FILE: memory/single_port_ram/tb/tb_top.sv
// ASSET: Structural Simulation Top Hardware Node Module
// ==============================================================================

`timescale 1ns / 1ps
`include "ram_environment.sv"

module tb_ram_top;
  import memory_pkg::*;
  import tb_pkg::*;  // Import all verification classes cleanly

  // Clock and Reset signals
  logic clk = 0;
  logic rst_n;

  always #5 clk = ~clk;

  clk_rst_if clk_rst_vif ();
  memory_if #(
      .DATA_WIDTH(32),
      .ADDR_WIDTH(8)
  ) mem_vif ();

  assign clk_rst_vif.clk   = clk;
  assign clk_rst_vif.rst_n = rst_n;

  single_port_ram #(
      .DATA_WIDTH(32),
      .ADDR_WIDTH(8),
      .OUT_REG(1'b0),
      .WRITE_MODE(memory_pkg::WRITE_FIRST)
  ) DUT (
      .clk_i    (clk_rst_vif.clk),
      .rst_n_i  (clk_rst_vif.rst_n),
      .wr_en_i  (mem_vif.wr_en),
      .addr_i   (mem_vif.addr),
      .wr_data_i(mem_vif.wr_data),
      .rd_data_o(mem_vif.rd_data)
  );

  ram_environment #(
      .DATA_WIDTH(32),
      .ADDR_WIDTH(8)
  ) env;

  initial begin
    rst_n = 0;
    #20;
    rst_n = 1;

    env = new(clk_rst_vif, mem_vif, mem_vif);
    env.gen.num_transactions = 1000;
    env.run();

    $finish;
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_top);
  end

endmodule : tb_top
