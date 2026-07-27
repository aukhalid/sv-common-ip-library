// ==============================================================================
// AUTHOR      : Ahasan Ullah Khalid
// PROJECT     : sv-common-ip-library
// FILE        : two_flop_sync_bind.sv
// DESCRIPTION : SVA Bind module for two_flop_sync.
// ==============================================================================

`ifdef SIMULATION
bind two_flop_sync two_flop_sync_assertions #(
    .WIDTH(WIDTH)
) assertion_inst (
    .clk_i       (clk_i),
    .rst_n_i     (rst_n_i),
    .async_data_i(async_data_i),
    .sync_data_o (sync_data_o)
);
`endif
