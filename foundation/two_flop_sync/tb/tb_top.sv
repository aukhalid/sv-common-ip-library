// ==============================================================================
// AUTHOR      : Ahasan Ullah Khalid
// PROJECT     : sv-common-ip-library
// FILE        : tb_top.sv
// MODULE      : tb_top
// DESCRIPTION : Tier 2 Self-Checking Testbench for 2-Flip-Flop Synchronizer.
// ==============================================================================

module tb_top;

  // ----------------------------------------------------------------------------
  // Local Parameter Definitions
  // ----------------------------------------------------------------------------
  localparam int WIDTH = 4;
  localparam logic [WIDTH-1:0] RESET_VAL = 4'h0;

  // Destination Clock Domain (100 MHz -> 10ns period)
  logic             clk;
  logic             rst_n;
  logic [WIDTH-1:0] async_data;
  logic [WIDTH-1:0] sync_data;

  int               pass_count = 0;
  int               fail_count = 0;

  // Clock Generation (100 MHz)
  initial clk = 0;
  always #5.0 clk = ~clk;

  // DUT Instantiation
  two_flop_sync #(
      .WIDTH(WIDTH),
      .RESET_VAL(RESET_VAL)
  ) DUT (
      .clk_i       (clk),
      .rst_n_i     (rst_n),
      .async_data_i(async_data),
      .sync_data_o (sync_data)
  );

  // ----------------------------------------------------------------------------
  // Test Control Tasks
  // ----------------------------------------------------------------------------

  // Task: Reset Initialization
  task automatic reset_dut();
    rst_n      <= 1'b0;
    async_data <= '0;
    #25;
    rst_n <= 1'b1;
    @(posedge clk);
    $display("[TB] Reset sequence completed.");
  endtask

  // Task: Directed Latency Verification
  task automatic test_sync_latency(input logic [WIDTH-1:0] test_val);
    // Drive async signal unaligned with clk (3.7ns phase shift)
    #3.7;
    async_data <= test_val;
    $display("[TB %0t ps] Driven async_data_i = 0x%0h", $time, test_val);

    // Cycle 1: Capture stage
    @(posedge clk);
    #1;
    $display("[TB PASS-CHECK] Cycle 1: Output holding 0x%0h", sync_data);

    // Cycle 2: Output updates
    @(posedge clk);
    #1;
    if (sync_data === test_val) begin
      pass_count++;
      $display("[SCOREBOARD PASS %0t ps] Sync Data = 0x%0h (Matched after 2 clock edges)", $time,
               sync_data);
    end else begin
      fail_count++;
      $error("[SCOREBOARD MISMATCH %0t ps] Expected: 0x%0h | Actual: 0x%0h", $time, test_val,
             sync_data);
    end
  endtask

  // ----------------------------------------------------------------------------
  // Main Test Sequence
  // ----------------------------------------------------------------------------
  initial begin
    $display("\n=======================================================");
    $display("     STARTING 2-FLOP SYNCHRONIZER TIER 2 VERIFICATION   ");
    $display("=======================================================\n");

    // Step 1: Execute Reset Validation
    reset_dut();

    if (sync_data === RESET_VAL) begin
      pass_count++;
      $display("[RESET CHECK PASS] Output matches RESET_VAL (0x%0h)", sync_data);
    end else begin
      fail_count++;
      $error("[RESET CHECK FAIL] Expected: 0x%0h | Actual: 0x%0h", RESET_VAL, sync_data);
    end

    // Step 2: Directed Vector Latency Tests
    test_sync_latency(4'hA);
    test_sync_latency(4'h5);
    test_sync_latency(4'hF);

    // Step 3: Randomized Stimulus Loop (50 random transactions)
    $display("\n[TB] Running 50 Randomized Vector Tests...");
    repeat (50) begin
      logic [WIDTH-1:0] rand_val;
      rand_val = $urandom_range(0, (1 << WIDTH) - 1);

      // Asynchronous phase offset
      #(($urandom_range(100, 8500)) * 1ps);
      async_data <= rand_val;

      // Wait for synchronizer chain resolution
      fork
        begin
          wait (sync_data === rand_val);
        end
        begin
          repeat (4) @(posedge clk);
        end
      join_any

      #1;

      if (sync_data === rand_val) begin
        pass_count++;
      end else begin
        fail_count++;
        $error("[RANDOM TEST FAIL] Expected: 0x%0h | Actual: 0x%0h", rand_val, sync_data);
      end

      // Hold signal stable for 2 cycles before next toggle
      repeat (2) @(posedge clk);
    end

    // Step 4: Final Summary Report
    $display("\n=======================================================");
    $display("         TWO_FLOP_SYNC VERIFICATION REPORT            ");
    $display("=======================================================");
    $display(" Total Passed Checks : %0d", pass_count);
    $display(" Total Failures      : %0d", fail_count);
    $display("=======================================================\n");

    if (fail_count == 0 && pass_count > 0) begin
      $display("=== [TEST PASSED] TWO_FLOP_SYNC VERIFIED CLEANLY ===");
    end else begin
      $error("=== [TEST FAILED] VERIFICATION MISMATCHES DETECTED ===");
    end

    $finish;
  end

  // Waveform Dump Configuration
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_top);
  end

endmodule : tb_top
