// ==============================================================================
// FILE: foundation/clk_divider/tb/tb_top.sv
// DESCRIPTION: Tier 2 Self-Checking Testbench for Clock Divider
// ==============================================================================

`timescale 1ns / 1ps

module tb_top;

  localparam int MAXDIVRATIO = 16;
  localparam int COUNTERWIDTH = $clog2(MAXDIVRATIO);

  logic                    clk;
  logic                    rst_n;
  logic [COUNTERWIDTH-1:0] div_ratio;
  logic                    clk_out;
  logic                    clk_en;

  int                      pass_count = 0;
  int                      fail_count = 0;

  // Reference Clock Generation (100 MHz -> 10ns period)
  initial clk = 0;
  always #5.0 clk = ~clk;

  // DUT Instantiation
  clock_divider #(
      .MAX_DIV_RATIO(MAXDIVRATIO)
  ) DUT (
      .clk_i      (clk),
      .rst_n_i    (rst_n),
      .div_ratio_i(div_ratio),
      .clk_out_o  (clk_out),
      .clk_en_o   (clk_en)
  );

  // ----------------------------------------------------------------------------
  // Test Tasks
  // ----------------------------------------------------------------------------
  task automatic reset_dut();
    rst_n     <= 1'b0;
    div_ratio <= 4'd2;
    #25;
    rst_n <= 1'b1;
    @(posedge clk);
    $display("[TB] Reset sequence completed.");
  endtask

  // Task to verify output clock frequency over N clock cycles
  task automatic verify_division(input int ratio);
    realtime t_start, t_end, measured_period;
    realtime expected_period;

    @(posedge clk);
    div_ratio <= ratio[COUNTERWIDTH-1:0];
    repeat (ratio * 2) @(posedge clk);  // Allow pipeline to settle

    // Measure period between two rising edges of clk_out
    @(posedge clk_out);
    t_start = $realtime;
    @(posedge clk_out);
    t_end = $realtime;

    measured_period = t_end - t_start;
    expected_period = 10.0 * ratio;  // 10ns input clock period * ratio

    if (measured_period == expected_period) begin
      pass_count++;
      $display("[PASS] Divide-by-%0d: Measured Period = %0.1f ns (Expected %0.1f ns)", ratio,
               measured_period, expected_period);
    end else begin
      fail_count++;
      $error("[FAIL] Divide-by-%0d: Measured Period = %0.1f ns | Expected = %0.1f ns", ratio,
             measured_period, expected_period);
    end
  endtask

  // ----------------------------------------------------------------------------
  // Main Test Execution
  // ----------------------------------------------------------------------------
  initial begin
    $display("\n=======================================================");
    $display("     STARTING CLOCK DIVIDER TIER 2 VERIFICATION        ");
    $display("=======================================================\n");

    reset_dut();

    // Verify divide by 2, 4, 8, 16
    verify_division(2);
    verify_division(4);
    verify_division(8);
    verify_division(16);

    // Report Summary
    $display("\n=======================================================");
    $display("          CLK_DIVIDER VERIFICATION REPORT              ");
    $display("=======================================================");
    $display(" Total Passed Checks : %0d", pass_count);
    $display(" Total Failures      : %0d", fail_count);
    $display("=======================================================\n");

    if (fail_count == 0) begin
      $display("=== [TEST PASSED] CLOCK DIVIDER VERIFIED CLEANLY ===");
    end else begin
      $error("=== [TEST FAILED] VERIFICATION MISMATCHES DETECTED ===");
    end

    $finish;
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_top);
  end

endmodule : tb_top
