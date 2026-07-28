// ==============================================================================
// AUTHOR      : Ahasan Ullah Khalid
// PROJECT     : sv-common-ip-library
// FILE        : async_fifo.sv
// MODULE      : async_fifo
// DESCRIPTION : Parameterized Asynchronous FIFO using Submodule IP Integration.
//               - Reuses dual_port_ram, two_flop_sync, bin_to_gray, gray_to_bin.
//               - Fully decoupled wclk_i and rclk_i clock domains.
// ==============================================================================

`include "assert_macros.svh"

module async_fifo #(
    int DATA_WIDTH = 32,
    int ADDR_WIDTH = 4   // Depth = 2^ADDR_WIDTH (e.g., 2^4 = 16 words)
) (
    // Write Domain Interface
    input  logic                  wclk_i,
    input  logic                  wrst_n_i,
    input  logic                  wr_en_i,
    input  logic [DATA_WIDTH-1:0] wr_data_i,
    output logic                  full_o,

    // Read Domain Interface
    input  logic                  rclk_i,
    input  logic                  rrst_n_i,
    input  logic                  rd_en_i,
    output logic [DATA_WIDTH-1:0] rd_data_o,
    output logic                  empty_o
);

    // Pointer bit width: ADDR_WIDTH + 1 (Extra bit for wrap-around detection)
    localparam int PTRWidth = ADDR_WIDTH + 1;

    // ----------------------------------------------------------------------------
    // 1. Internal Signals & Pointer Declarations
    // ----------------------------------------------------------------------------
    logic [PTRWidth-1:0] wptr_bin, wptr_bin_next;
    logic [PTRWidth-1:0] wptr_gray, wptr_gray_next;
    logic [PTRWidth-1:0] rptr_bin, rptr_bin_next;
    logic [PTRWidth-1:0] rptr_gray, rptr_gray_next;

    logic [PTRWidth-1:0] wptr_gray_sync;
    logic [PTRWidth-1:0] rptr_gray_sync;

    logic memory_write_enable;

    // ----------------------------------------------------------------------------
    // 2. Write Pointer Logic (wclk_i Domain)
    // ----------------------------------------------------------------------------
    assign memory_write_enable = wr_en_i && !full_o;
    assign wptr_bin_next       = wptr_bin + memory_write_enable;

    always_ff @(posedge wclk_i or negedge wrst_n_i) begin
        if (!wrst_n_i) begin
            wptr_bin  <= '0;
            wptr_gray <= '0;
        end else begin
            wptr_bin  <= wptr_bin_next;
            wptr_gray <= wptr_gray_next;
        end
    end

    // Binary to Gray Converter Instantiation (Write Pointer)
    bin_to_gray #(.WIDTH(PTR_WIDTH)) u_wptr_b2g (
        .bin_i  (wptr_bin_next),
        .gray_o (wptr_gray_next)
    );

    // ----------------------------------------------------------------------------
    // 3. Read Pointer Logic (rclk_i Domain)
    // ----------------------------------------------------------------------------
    logic memory_read_enable;
    assign memory_read_enable = rd_en_i && !empty_o;
    assign rptr_bin_next      = rptr_bin + memory_read_enable;

    always_ff @(posedge rclk_i or negedge rrst_n_i) begin
        if (!rrst_n_i) begin
            rptr_bin  <= '0;
            rptr_gray <= '0;
        end else begin
            rptr_bin  <= rptr_bin_next;
            rptr_gray <= rptr_gray_next;
        end
    end

    // Binary to Gray Converter Instantiation (Read Pointer)
    bin_to_gray #(.WIDTH(PTR_WIDTH)) u_rptr_b2g (
        .bin_i  (rptr_bin_next),
        .gray_o (rptr_gray_next)
    );

    // ----------------------------------------------------------------------------
    // 4. Clock Domain Crossing Synchronizer Chains (IP Reuse)
    // ----------------------------------------------------------------------------

    // Synchronize Write Pointer into Read Clock Domain (rclk_i)
    two_flop_sync #(
        .WIDTH(PTR_WIDTH),
        .RESET_VAL('0)
    ) u_sync_w2r (
        .clk_i        (rclk_i),
        .rst_n_i      (rrst_n_i),
        .async_data_i (wptr_gray),
        .sync_data_o  (wptr_gray_sync)
    );

    // Synchronize Read Pointer into Write Clock Domain (wclk_i)
    two_flop_sync #(
        .WIDTH(PTR_WIDTH),
        .RESET_VAL('0)
    ) u_sync_r2w (
        .clk_i        (wclk_i),
        .rst_n_i      (wrst_n_i),
        .async_data_i (rptr_gray),
        .sync_data_o  (rptr_gray_sync)
    );

    // ----------------------------------------------------------------------------
    // 5. Full & Empty Condition Flags Generation
    // ----------------------------------------------------------------------------

    // Full Flag: Top 2 MSBs inverted, lower bits match
    assign full_o = (wptr_gray_next == {~rptr_gray_sync[PTR_WIDTH-1:PTR_WIDTH-2],
                                        rptr_gray_sync[PTR_WIDTH-3:0]});

    // Empty Flag: Read Gray pointer matches synchronized Write Gray pointer
    assign empty_o = (rptr_gray_next == wptr_gray_sync);

    // ----------------------------------------------------------------------------
    // 6. Memory Storage Array Matrix (Dual-Port RAM Submodule IP Reuse)
    // ----------------------------------------------------------------------------
    dual_port_ram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .OUT_REG(1'b0)
    ) u_fifo_mem (
        .wr_clk_i   (wclk_i),
        .wr_rst_n_i (wrst_n_i),
        .wr_en_i    (memory_write_enable),
        .wr_addr_i  (wptr_bin[ADDR_WIDTH-1:0]),
        .wr_data_i  (wr_data_i),

        .rd_clk_i   (rclk_i),
        .rd_rst_n_i (rrst_n_i),
        .rd_en_i    (memory_read_enable),
        .rd_addr_i  (rptr_bin[ADDR_WIDTH-1:0]),
        .rd_data_o  (rd_data_o)
    );

    // ----------------------------------------------------------------------------
    // 7. SystemVerilog Assertions (SVA)
    // ----------------------------------------------------------------------------
    `ifdef SIMULATION
        `ASSERT_NO_X(wclk_i, wr_en_i, "async_fifo wr_en_i resolved to X/Z state")
        `ASSERT_NO_X(rclk_i, rd_en_i, "async_fifo rd_en_i resolved to X/Z state")

        // Overflow Assertion Guard
        property p_no_overflow;
            @(posedge wclk_i) disable iff (!wrst_n_i)
            full_o && wr_en_i |=> $stable(wptr_bin);
        endproperty
        assert property (p_no_overflow)
        else $error("[FIFO OVERFLOW] Write request issued while FIFO was FULL!");

        // Underflow Assertion Guard
        property p_no_underflow;
            @(posedge rclk_i) disable iff (!rrst_n_i)
            empty_o && rd_en_i |=> $stable(rptr_bin);
        endproperty
        assert property (p_no_underflow)
        else $error("[FIFO UNDERFLOW] Read request issued while FIFO was EMPTY!");
    `endif

endmodule : async_fifo
