// ==============================================================================
// FILE: foundation/edge_detector/tb/tb_top.sv
// DESCRIPTION: Tier 2 Self-Checking Testbench for Edge Detector
// ==============================================================================

`timescale 1ns / 1ps

module tb_top;

  localparam int WIDTH = 4;

  logic             clk;
  logic             rst_n;
  logic [WIDTH-1:0] signal_in;
  logic [WIDTH-1:0] pos_edge;
  logic [WIDTH-1:0] neg_edge;
  logic [WIDTH-1:0] any_edge;

  int               pass_count = 0;
  int               fail_count = 0;

  // Clock Generation (100 MHz)
  initial clk = 0;
  always #5.0 clk = ~clk;

  // DUT Instantiation
  edge_detector #(
      .WIDTH(WIDTH)
  ) DUT (
      .clk_i     (clk),
      .rst_n_i   (rst_n),
      .signal_i  (signal_in),
      .pos_edge_o(pos_edge),
      .neg_edge_o(neg_edge),
      .any_edge_o(any_edge)
  );

  // ----------------------------------------------------------------------------
  // Test Tasks
  // ----------------------------------------------------------------------------
  task automatic reset_dut();
    rst_n     <= 1'b0;
    signal_in <= '0;
    #25;
    rst_n <= 1'b1;
    @(posedge clk);
    $display("[TB] Reset sequence completed.");
  endtask

  // ----------------------------------------------------------------------------
  // Main Test Sequence
  // ----------------------------------------------------------------------------
  initial begin
    $display("\n=======================================================");
    $display("     STARTING EDGE DETECTOR TIER 2 VERIFICATION        ");
    $display("=======================================================\n");

    reset_dut();

    // Test 1: Rising Edge Check
    @(posedge clk);
    signal_in <= 4'b0101;

    @(posedge clk);
    #1;  // Delta delay
    if (pos_edge === 4'b0101 && neg_edge === 4'b0000 && any_edge === 4'b0101) begin
      pass_count++;
      $display("[PASS] Rising Edge Detected Correctly: pos=0b%04b", pos_edge);
    end else begin
      fail_count++;
      $error("[FAIL] Rising Edge Expected 0b0101 | Actual pos=0b%04b neg=0b%04b", pos_edge,
             neg_edge);
    end

    // Test 2: Stable State Check (No Edges Should Trigger)
    @(posedge clk);
    #1;
    if (pos_edge === 4'b0000 && neg_edge === 4'b0000 && any_edge === 4'b0000) begin
      pass_count++;
      $display("[PASS] Stable Level: Zero edge pulses generated");
    end else begin
      fail_count++;
      $error("[FAIL] Spurious pulse generated during stable input!");
    end

    // Test 3: Falling Edge Check
    @(posedge clk);
    signal_in <= 4'b0000;

    @(posedge clk);
    #1;
    if (pos_edge === 4'b0000 && neg_edge === 4'b0101 && any_edge === 4'b0101) begin
      pass_count++;
      $display("[PASS] Falling Edge Detected Correctly: neg=0b%04b", neg_edge);
    end else begin
      fail_count++;
      $error("[FAIL] Falling Edge Expected 0b0101 | Actual neg=0b%04b", neg_edge);
    end

    // Summary Report
    $display("\n=======================================================");
    $display("          EDGE_DETECTOR VERIFICATION REPORT            ");
    $display("=======================================================");
    $display(" Total Passed Checks : %0d", pass_count);
    $display(" Total Failures      : %0d", fail_count);
    $display("=======================================================\n");

    if (fail_count == 0) begin
      $display("=== [TEST PASSED] EDGE DETECTOR VERIFIED CLEANLY ===");
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
