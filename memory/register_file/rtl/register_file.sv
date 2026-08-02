module register_file #(
    parameter int DATA_WIDTH = 32,
    parameter int REG_DEPTH  = 32,
    parameter int ADDR_WIDTH = $clog2(REG_DEPTH)
) (
    input logic clk_i,
    input logic arst_n_i,
    input logic wr_en_i,

    input  logic [ADDR_WIDTH-1:0] rd_addr1_i,
    output logic [DATA_WIDTH-1:0] rd_data1_o,

    input  logic [ADDR_WIDTH-1:0] rd_addr2_i,
    output logic [DATA_WIDTH-1:0] rd_data2_o,

    input logic [ADDR_WIDTH-1:0] wr_addr_i,
    input logic [DATA_WIDTH-1:0] wr_data_i
);

  // ----------------------------------------------------------------------------
  // Register File Memory Declaration
  // ----------------------------------------------------------------------------

  logic [DATA_WIDTH-1:0] reg_file_mem[REG_DEPTH];

  // ----------------------------------------------------------------------------
  // Write Operation: Synchronous Write on Rising Edge of clk_i
  // ----------------------------------------------------------------------------

  always_ff @(posedge clk_i or negedge arst_n_i) begin
    if (~arst_n_i) begin
      for (int i = 0; i < REG_DEPTH; i++) begin
        reg_file_mem[i] <= '0;
      end
    end else if (wr_en_i && (wr_addr_i != '0)) begin
      reg_file_mem[wr_addr_i] <= wr_data_i;
    end
  end

  // ----------------------------------------------------------------------------
  // 2. Read Logic (Combinational)
  // ----------------------------------------------------------------------------
  always_comb rd_data1_o = (rd_addr1_i != '0) ? reg_file_mem[rd_addr1_i] : '0;
  always_comb rd_data2_o = (rd_addr2_i != '0) ? reg_file_mem[rd_addr2_i] : '0;

endmodule : register_file
