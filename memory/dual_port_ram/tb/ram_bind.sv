`ifdef SIMULATION
bind dual_port_ram ram_protocol_assertions #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH)
) assertion_monitor_inst (
    .clk    (wr_clk_i),
    .rst_n  (wr_rst_n_i),
    .wr_en  (wr_en_i),
    .addr   (wr_addr_i),
    .wr_data(wr_data_i)
);
`endif
