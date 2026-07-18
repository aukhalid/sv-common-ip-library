// File: common/macros/assert_macros.svh
// Reusable macro for synchronous protocol assertions

`ifndef ASSERT_MACROS_SVH
`define ASSERT_MACROS_SVH

// Macro checks if a condition holds true; otherwise, throws an error with context
`define ASSERT(condition, message) \
  if (!(condition)) begin \
    $error("Assertion failed: %s at time %0t in %m", message, $time); \
  end

`define ASSERT_CLK(clk, condition, message) \
  assert property (@(posedge clk) condition) else begin \
    $error("[ASSERTION ERROR] Time: \%0t \vert{} \%s", $time, msg); \
  end

// Macro: Ensures that a specified control signal does not resolve to an unknown 'X' state during active cycles
`define ASSERT_NO_X(clk, signal, msg) \
  assert property (@(posedge clk) !$isunknown(signal)) else begin \
    $error("[PROTOCOL VIOLATION] Time: %0t | Target signal contains X/Z state! Context: %s", $time, msg); \
  end

`endif  // ASSERT_MACROS_SVH
