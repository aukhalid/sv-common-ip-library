//File: common/packages/common_pkg.sv
//Purpose: Common package container for all common packages to use later in the design. This package is used to include all the common packages in a single
//package for easy inclusion in other modules.

package common_pkg;

  // Global Datapath Properties
  parameter int GLOBAL_DATA_WIDTH = 32;
  parameter int GLOBAL_ADDR_WIDTH = 32;

  // Custom Time Scale Types or Shared Enums
  typedef enum logic {
    BUS_IDLE = 1'b0,
    BUS_BUSY = 1'b1
  } bus_state_t;
endpackage
