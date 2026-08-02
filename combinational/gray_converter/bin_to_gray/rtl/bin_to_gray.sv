// ==============================================================================
// AUTHOR      : Ahasan Ullah Khalid
// PROJECT     : sv-common-ip-library
// FILE        : bin_to_gray.sv
// MODULE      : bin_to_gray
// DESCRIPTION : Parameterized Pure Combinational Binary to Gray Code Converter.
//               - Converts standard binary vectors to single-bit transition Gray code.
//               - Zero clock / reset dependencies (Pure combinational datapath).
// ==============================================================================

module bin_to_gray #(
    int WIDTH = 4
) (
    input  logic [WIDTH-1:0] bin_i,
    output logic [WIDTH-1:0] gray_o
);

  // Continuous XOR bit-shift operation: G = B ^ (B >> 1)
  assign gray_o = bin_i ^ (bin_i >> 1);

endmodule : bin_to_gray
