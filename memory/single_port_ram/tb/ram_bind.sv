`ifdef SIMULATION
bind single_port_ram ram_protocol_assertions #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH)
) assertion_monitor_inst (
    .clk    (clk_i),
    .rst_n  (rst_n_i),
    .wr_en  (wr_en_i),
    .addr   (addr_i),
    .wr_data(wr_data_i)
);
`endif
