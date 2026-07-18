// ==============================================================================
// AUTHOR      : Ahasan Ullah Khalid
// PROJECT     : sv-common-ip-library
// File        : assert_macros.svh
// Description : Assertion macros for protocol checking
// ==============================================================================

`ifndef ASSERT_MACROS_SVH
`define ASSERT_MACROS_SVH

//-----------------------------------------------------------------------
// Immediate assertion — use inside procedural (always) blocks
//-----------------------------------------------------------------------
`define ASSERT(name, cond) \
    name: assert (cond) \
      else $error("[ASSERTION FAILED] %s at time %0t", `"name`", $time);

//-----------------------------------------------------------------------
// Concurrent (clocked) assertion — use at module scope
//-----------------------------------------------------------------------
`define ASSERT_CLK(name, cond, clk) \
    name: assert property (@(posedge clk) (cond)) \
      else $error("[ASSERTION FAILED] %s at time %0t", `"name`", $time);


// Macro: Ensures that a specified control signal does not resolve to an unknown 'X' state during active cycles
`define ASSERT_NO_X(clk, signal, msg) \
  assert property (@(posedge clk) !$isunknown(signal)) else begin \
    $error("[PROTOCOL VIOLATION] Time: %0t | Target signal contains X/Z state! Context: %s", $time, msg); \
  end

`endif  // ASSERT_MACROS_SVH
