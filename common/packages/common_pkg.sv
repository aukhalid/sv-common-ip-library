// ==============================================================================
// AUTHOR:  Ahasan Ullah Khalid
// PROJECT: sv-common-ip-library
// ASSET:   common_pkg.sv (Global Common Package)
// Purpose: This package serves as a container for all common packages used in the design. It provides a centralized location for defining global parameters, types, and shared resources that can be utilized across different modules and interfaces in the design. By including this package, designers can easily access and manage common definitions, promoting code reusability and maintainability.
// ==============================================================================

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
