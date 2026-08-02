// ==============================================================================
// FILE: register_file/tb/tb_top.sv
// DESCRIPTION: Tier 2 Self-Checking Testbench for Register File
// ==============================================================================

module tb_top;

    localparam int DataWidth = 32;
    localparam int RegDepth  = 32;
    localparam int AddrWidth = $clog2(RegDepth);

    logic                  clk;
    logic                  rst_n;
    logic [AddrWidth-1:0] raddr1, raddr2, waddr;
    logic [DataWidth-1:0] rdata1, rdata2, wdata;
    logic                  wen;

    int pass_count = 0;
    int fail_count = 0;

    // Clock Generation (100 MHz)
    initial clk = 0;
    always #5.0 clk = ~clk;

    // DUT Instantiation
    register_file #(
        .DATA_WIDTH(DataWidth),
        .REG_DEPTH(RegDepth),
        .ADDR_WIDTH(AddrWidth)
    ) u_dut (
        .clk_i    (clk),
        .arst_n_i  (rst_n),
        .rd_addr1_i (raddr1),
        .rd_data1_o (rdata1),
        .rd_addr2_i (raddr2),
        .rd_data2_o (rdata2),
        .wr_en_i    (wen),
        .wr_addr_i  (waddr),
        .wr_data_i  (wdata)
    );

    // ----------------------------------------------------------------------------
    // Test Control Tasks
    // ----------------------------------------------------------------------------
    task automatic reset_dut();
        rst_n  <= 1'b0;
        wen    <= 1'b0;
        waddr  <= '0;
        wdata  <= '0;
        raddr1 <= '0;
        raddr2 <= '0;
        #25;
        rst_n  <= 1'b1;
        @(posedge clk);
    endtask

    // ----------------------------------------------------------------------------
    // Main Test Sequence
    // ----------------------------------------------------------------------------
    initial begin
        $display("\n=======================================================");
        $display("     STARTING REGISTER FILE TIER 2 VERIFICATION       ");
        $display("=======================================================\n");

        reset_dut();

        // 1. Verify R0 Write Invariance
        @(posedge clk);
        wen   <= 1'b1;
        waddr <= '0;
        wdata <= 32'hDEADBEEF;
        @(posedge clk);
        wen   <= 1'b0;
        raddr1 <= '0;
        #1;
        if (rdata1 === 32'h0) begin
            pass_count++;
            $display("[PASS] R0 Write Ignored: R0 remains 0x00000000");
        end else begin
            fail_count++;
            $error("[FAIL] R0 Modified! Actual: 0x%0h", rdata1);
        end

        // 2. Sequential Write and Dual Read Check
        $display("\n[TB] Writing registers 1 to %0d...", RegDepth-1);
        for (int i = 1; i < RegDepth; i++) begin
            @(posedge clk);
            wen   <= 1'b1;
            waddr <= i[AddrWidth-1:0];
            wdata <= (i * 32'h1111_1111);
        end
        @(posedge clk);
        wen <= 1'b0;

        $display("[TB] Verifying dual read ports...");
        for (int i = 1; i < RegDepth; i += 2) begin
            raddr1 <= i[AddrWidth-1:0];
            raddr2 <= (i + 1)[AddrWidth-1:0];
            #1; // Combinational settling

            if (rdata1 === (i * 32'h1111_1111)) pass_count++;
            else begin
                fail_count++;
                $error("[FAIL Port 1] Reg %0d Expected: 0x%0h | Actual: 0x%0h",
                       i, i*32'h1111_1111, rdata1);
            end

            if (i + 1 < RegDepth) begin
                if (rdata2 === ((i + 1) * 32'h1111_1111)) pass_count++;
                else begin
                    fail_count++;
                    $error("[FAIL Port 2] Reg %0d Expected: 0x%0h | Actual: 0x%0h",
                           i+1, (i+1)*32'h1111_1111, rdata2);
                end
            end
        end

        // Report
        $display("\n=======================================================");
        $display("          REGISTER_FILE VERIFICATION REPORT            ");
        $display("=======================================================");
        $display(" Total Passed Checks : %0d", pass_count);
        $display(" Total Failures      : %0d", fail_count);
        $display("=======================================================\n");

        if (fail_count == 0) $display("=== [TEST PASSED] REGISTER FILE VERIFIED CLEANLY ===");
        else $error("=== [TEST FAILED] VERIFICATION MISMATCHES DETECTED ===");

        $finish;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_top);
    end
endmodule : tb_top
