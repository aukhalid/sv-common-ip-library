// ==============================================================================
// AUTHOR      : Ahasan Ullah Khalid
// PROJECT     : sv-common-ip-library
// File        : common_macros.svh
// Description : Project-wide macros. Included (`include) by RTL and TB files
//               that need assertions or debug prints. Keep macros generic
//               here; module-specific macros belong in the module itself.
// ==============================================================================

`ifndef COMMON_MACROS_SVH
`define COMMON_MACROS_SVH

//-----------------------------------------------------------------------
// Debug print — compiled in only when SIM is defined (simulation builds),
// stripped out for synthesis so it never affects synthesizable code.
//-----------------------------------------------------------------------
`ifdef SIM
`define DEBUG_PRINT(msg) \
      $display("[DEBUG] %0t : %s", $time, msg);
`else
`define DEBUG_PRINT(msg)
`endif

`endif  // COMMON_MACROS_SVH
