// ==============================================================================
// FILE: common/macros/assert_macros.svh
// ==============================================================================
`ifndef ASSERT_MACROS_SVH
`define ASSERT_MACROS_SVH

// Macro: Ensures that a specified control signal does not resolve to an unknown 'X' state
`define ASSERT_NO_X(clk, signal, msg) \
  assert property (@(posedge clk) !$isunknown(signal)) else begin \
    $error("[PROTOCOL VIOLATION] Time: %0t | Target signal contains X/Z state! Context: %s", $time, msg); \
  end

// Macro: Standard synchronous assertion check
`define ASSERT_CLK(clk, condition, msg) \
  assert property (@(posedge clk) condition) else begin \
    $error("[ASSERTION FAILURE] Time: %0t | %s", $time, msg); \
  end

`endif  // ASSERT_MACROS_SVH
