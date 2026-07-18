// File: common/interfaces/stream_if.sv
// This interface defines a streaming data interface for modules that require data transfer functionality. It provides a standardized way to connect streaming data signals across different modules in the design.

interface stream_if #(
    parameter int WIDTH = 32
);

  logic [WIDTH-1:0] data;  // Streaming data signal
  logic valid;  // Valid signal
  logic ready;  // Ready signal

  // Modport for data source (Producer)
  modport master(
      output data,
      output valid,
      input ready
  );  // Master modport for driving streaming data signals
  modport slave(
      input data,
      input valid,
      output ready
  );  // Slave modport for receiving streaming data signals

endinterface : stream_if
