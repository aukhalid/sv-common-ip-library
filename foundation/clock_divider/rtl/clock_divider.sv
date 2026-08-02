// ==============================================================================
// AUTHOR      : Ahasan Ullah Khalid
// PROJECT     : sv-common-ip-library
// FILE        : clk_divider.sv
// MODULE      : clk_divider
// DESCRIPTION : Parameterized Dynamic Clock Frequency Divider.
//               - Generates 50% duty cycle divided clock (clk_out_o).
//               - Generates 1-cycle clock enable pulse (clk_en_o) for STA safety.
//               - Supports dynamic division ratio configuration.
// ==============================================================================

`include "assert_macros.svh"

module clock_divider #(
    int MAX_DIV_RATIO = 16,
    localparam int COUNTERWIDTH = $clog2(MAX_DIV_RATIO)
) (
    input logic                    clk_i,
    input logic                    rst_n_i,
    input logic [COUNTERWIDTH-1:0] div_ratio_i, // N Division factor (e.g. 2, 4, 8)

    output logic clk_out_o,  // Divided Clock Signal
    output logic clk_en_o    // 1-Cycle Pulse Clock Enable
);

  // ----------------------------------------------------------------------------
  // 1. Internal Counter and Control Signals
  // ----------------------------------------------------------------------------
  logic [COUNTERWIDTH-1:0] cnt_q;
  logic                    clk_out_q;
  logic                    clk_en_q;

  // Half period threshold calculation
  logic [COUNTERWIDTH-1:0] half_period;
  assign half_period = (div_ratio_i >> 1) - 1'b1;

  // ----------------------------------------------------------------------------
  // 2. Division Counter & Output Clock Logic
  // ----------------------------------------------------------------------------
  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      cnt_q     <= '0;
      clk_out_q <= 1'b0;
      clk_en_q  <= 1'b0;
    end else begin
      // Bypass mode when division ratio is 0 or 1
      if (div_ratio_i <= 1) begin
        cnt_q     <= '0;
        clk_out_q <= clk_i;
        clk_en_q  <= 1'b1;
      end else begin
        // Counter Terminal Count reached
        if (cnt_q == (div_ratio_i - 1'b1)) begin
          cnt_q     <= '0;
          clk_out_q <= ~clk_out_q;
          clk_en_q  <= 1'b1;
        end else begin
          cnt_q    <= cnt_q + 1'b1;
          clk_en_q <= 1'b0;

          // Toggle clock at half-period boundary for 50% duty cycle
          if (cnt_q == half_period) begin
            clk_out_q <= ~clk_out_q;
          end
        end
      end
    end
  end

  // ----------------------------------------------------------------------------
  // 3. Output Assignments
  // ----------------------------------------------------------------------------
  assign clk_out_o = (div_ratio_i <= 1) ? clk_i : clk_out_q;
  assign clk_en_o  = clk_en_q;

  // ----------------------------------------------------------------------------
  // 4. SystemVerilog Assertions (SVA) Layer
  // ----------------------------------------------------------------------------
`ifdef SIMULATION
  `ASSERT_NO_X(clk_i, rst_n_i, "clk_divider rst_n_i resolved to X/Z state")

  // Guard against zero division configuration
  property p_valid_div_ratio;
    @(posedge clk_i) disable iff (!rst_n_i) div_ratio_i != '0;
  endproperty
  assert property (p_valid_div_ratio)
  else $error("[CLK_DIVIDER ERROR] Division ratio set to 0!");
`endif

endmodule : clk_divider
