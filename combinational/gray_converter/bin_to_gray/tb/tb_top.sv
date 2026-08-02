// ==============================================================================
// FILE: combinational/gray_converter/bin_to_gray/tb/tb_bin_to_gray.sv
// DESCRIPTION: Tier 3 Self-Checking Testbench for bin_to_gray
// ==============================================================================

`timescale 1ns / 1ps

module tb_top;

  localparam int WIDTH = 4;
  localparam int TOTAL_STATES = 1 << WIDTH;

  logic [WIDTH-1:0] bin_in;
  logic [WIDTH-1:0] gray_out;

  int pass_count = 0;
  int fail_count = 0;

  // DUT Instantiation
  bin_to_gray #(
      .WIDTH(WIDTH)
  ) DUT (
      .bin_i (bin_in),
      .gray_o(gray_out)
  );

  // Single-bit transition check variable
  logic [WIDTH-1:0] prev_gray;

  // Function: Calculate Bit Differences (Hamming Distance)
  function automatic int count_ones(input logic [WIDTH-1:0] vec);
    int cnt = 0;
    for (int i = 0; i < WIDTH; i++) begin
      if (vec[i]) cnt++;
    end
    return cnt;
  endfunction

  initial begin
    $display("\n=======================================================");
    $display("     STARTING BIN_TO_GRAY TIER 3 EXHAUSTIVE SWEEP      ");
    $display("=======================================================\n");

    prev_gray = '0;

    // Exhaustively sweep all 2^WIDTH input combinations
    for (int i = 0; i < TOTAL_STATES; i++) begin
      bin_in = i[WIDTH-1:0];
      #10;  // Combinational propagation delay

      // Expected calculation
      logic [WIDTH-1:0] expected_gray = i ^ (i >> 1);

      if (gray_out === expected_gray) begin
        pass_count++;
        $display("[PASS] Bin: %0d (0b%0*b) => Gray: 0b%0*b", i, WIDTH, bin_in, WIDTH, gray_out);
      end else begin
        fail_count++;
        $error("[FAIL] Bin: %0d | Expected Gray: 0b%0*b | Actual: 0b%0*b", i, WIDTH, expected_gray,
               WIDTH, gray_out);
      end

      // Check single-bit change rule for consecutive numbers (unit distance)
      if (i > 0) begin
        int bit_diffs = count_ones(gray_out ^ prev_gray);
        if (bit_diffs != 1) begin
          fail_count++;
          $error(
              "[CDC RULE VIOLATION] Non-unit distance between bin %0d and %0d! Changed bits = %0d",
              i - 1, i, bit_diffs);
        end
      end
      prev_gray = gray_out;
    end

    $display("\n=======================================================");
    $display("          BIN_TO_GRAY VERIFICATION REPORT              ");
    $display("=======================================================");
    $display(" Total Passed States Checked : %0d / %0d", pass_count, TOTAL_STATES);
    $display(" Total Failures              : %0d", fail_count);
    $display("=======================================================\n");

    if (fail_count == 0) begin
      $display("=== [TEST PASSED] BIN_TO_GRAY VERIFIED CLEANLY ===");
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
