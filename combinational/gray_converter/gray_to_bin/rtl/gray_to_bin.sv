// ==============================================================================
// AUTHOR      : Ahasan Ullah Khalid
// PROJECT     : sv-common-ip-library
// FILE        : gray_to_bin.sv
// MODULE      : gray_to_bin
// DESCRIPTION : Parameterized Pure Combinational Gray to Binary Code Converter.
//               - Reconstructs standard binary vector from synchronized Gray code vector.
//               - Zero clock / reset dependencies (Pure combinational datapath).
// ==============================================================================

module gray_to_bin #(
    int WIDTH = 4
) (
    input  logic [WIDTH-1:0] gray_i,
    output logic [WIDTH-1:0] bin_o
);

  // Combinational prefix XOR tree reconstruction
  always_comb begin
    bin_o[WIDTH-1] = gray_i[WIDTH-1];
    for (int i = WIDTH - 2; i >= 0; i--) begin
      bin_o[i] = bin_o[i+1] ^ gray_i[i];
    end
  end

endmodule : gray_to_bin
