// ==============================================================================
// FILE: combinational/gray_converter/gray_to_bin/tb/tb_gray_to_bin.sv
// DESCRIPTION: Tier 3 Self-Checking Testbench for gray_to_bin
// ==============================================================================

`timescale 1ns / 1ps

module tb_top;

  localparam int WIDTH = 4;
  localparam int TOTAL_STATES = 1 << WIDTH;

  logic [WIDTH-1:0] gray_in;
  logic [WIDTH-1:0] bin_out;

  int pass_count = 0;
  int fail_count = 0;

  // DUT Instantiation
  gray_to_bin #(
      .WIDTH(WIDTH)
  ) DUT (
      .gray_i(gray_in),
      .bin_o (bin_out)
  );

  initial begin
    $display("\n=======================================================");
    $display("     STARTING GRAY_TO_BIN TIER 3 EXHAUSTIVE SWEEP      ");
    $display("=======================================================\n");

    // Exhaustively sweep all 2^WIDTH combinations by converting binary -> Gray -> binary
    for (int i = 0; i < TOTAL_STATES; i++) begin
      logic [WIDTH-1:0] orig_bin = i[WIDTH-1:0];
      gray_in = orig_bin ^ (orig_bin >> 1);  // Calculate valid Gray input
      #10;  // Combinational propagation delay

      if (bin_out === orig_bin) begin
        pass_count++;
        $display("[PASS] Gray: 0b%0*b => Binary: %0d (0b%0*b)", WIDTH, gray_in, bin_out, WIDTH,
                 bin_out);
      end else begin
        fail_count++;
        $error("[FAIL] Gray: 0b%0*b | Expected Bin: %0d | Actual: %0d", WIDTH, gray_in, orig_bin,
               bin_out);
      end
    end

    $display("\n=======================================================");
    $display("          GRAY_TO_BIN VERIFICATION REPORT              ");
    $display("=======================================================");
    $display(" Total Passed States Checked : %0d / %0d", pass_count, TOTAL_STATES);
    $display(" Total Failures              : %0d", fail_count);
    $display("=======================================================\n");

    if (fail_count == 0) begin
      $display("=== [TEST PASSED] GRAY_TO_BIN VERIFIED CLEANLY ===");
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
