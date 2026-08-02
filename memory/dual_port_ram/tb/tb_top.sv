// ==============================================================================
// FILE: memory/dual_port_ram/tb/tb_top.sv
// TOP-LEVEL TESTBENCH MODULE
// ==============================================================================


module tb_top;

  import tb_pkg::*;

  // ----------------------------------------------------------------------------
  // 1. Local Parameter Definitions (MUST BE FIRST)
  // ----------------------------------------------------------------------------
  localparam int DATA_WIDTH = 32;
  localparam int ADDR_WIDTH = 8;

  // ----------------------------------------------------------------------------
  // 2. Asynchronous Clock & Reset Generators
  // ----------------------------------------------------------------------------
  logic wclk = 0;
  logic rclk = 0;
  logic wrst_n;
  logic rrst_n;

  // wclk: 100 MHz (10ns period)
  always #5.0 wclk = ~wclk;

  // rclk: 143.5 MHz (~6.968ns period - Asynchronous frequency ratio)
  always #3.484 rclk = ~rclk;

  // ----------------------------------------------------------------------------
  // 3. Virtual Interface Instantiations
  // ----------------------------------------------------------------------------
  clk_rst_if wclk_if ();
  clk_rst_if rclk_if ();
  memory_if #(
      .DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(ADDR_WIDTH)
  ) mem_vif ();

  // Assign Clocks & Resets to Virtual Interfaces
  assign wclk_if.clk   = wclk;
  assign wclk_if.rst_n = wrst_n;
  assign rclk_if.clk   = rclk;
  assign rclk_if.rst_n = rrst_n;

  // ----------------------------------------------------------------------------
  // 4. DUT Instantiation (Pure Standalone RTL)
  // ----------------------------------------------------------------------------
  dual_port_ram #(
      .DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(ADDR_WIDTH),
      .OUT_REG(1'b0)
  ) DUT (
      .wr_clk_i  (wclk_if.clk),
      .wr_rst_n_i(wclk_if.rst_n),
      .wr_en_i   (mem_vif.wr_en),
      .wr_addr_i (mem_vif.addr),
      .wr_data_i (mem_vif.wr_data),

      .rd_clk_i  (rclk_if.clk),
      .rd_rst_n_i(rclk_if.rst_n),
      .rd_en_i   (!mem_vif.wr_en),
      .rd_addr_i (mem_vif.addr),
      .rd_data_o (mem_vif.rd_data)
  );

  // ----------------------------------------------------------------------------
  // 5. Testbench Environment Handle
  // ----------------------------------------------------------------------------
  ram_environment #(
      .DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(ADDR_WIDTH)
  ) env;

  // Reset Sequence
  initial begin
    wrst_n = 1'b0;
    rrst_n = 1'b0;
    #25;
    wrst_n = 1'b1;
    rrst_n = 1'b1;
  end

  // Simulation Execution
  initial begin
    env = new(wclk_if, rclk_if, mem_vif);
    env.gen.num_transactions = 1000;
    env.run();
    $finish;
  end

  // Waveform Dump
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_top);
  end

endmodule : tb_top
