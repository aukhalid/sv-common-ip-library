// ==============================================================================
// AUTHOR      : Ahasan Ullah Khalid
// PROJECT     : sv-common-ip-library
// FILE        : ram_transaction.sv
// ASSET       : Random Transaction Data Model Container Class
// ==============================================================================

// ==============================================================================
// FILE: memory/single_port_ram/tb/ram_environment.sv
// ASSET: Test Environment Structural Container Class
// ==============================================================================

class ram_environment #(
    int DATA_WIDTH = 32,
    int ADDR_WIDTH = 8
);

  // Class component references handles
  ram_generator #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH))              gen;
  ram_driver #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH))                 drv;
  ram_monitor #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH))                mon;
  ram_scoreboard #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH))             scb;

  // Cross-layer mailboxes
  mailbox #(ram_transaction #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH))) gen_to_drv;
  mailbox #(ram_transaction #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH))) mon_to_scb;

  // Synchronous signaling event blocks
  event                                                                          gen_done;

  function new(
      virtual clk_rst_if.slave clk_rst_vif,
      virtual memory_if #(
          .DATA_WIDTH(DATA_WIDTH),
          .ADDR_WIDTH(ADDR_WIDTH)
      ).master drv_mem_vif,
      virtual memory_if #(
          .DATA_WIDTH(DATA_WIDTH),
          .ADDR_WIDTH(ADDR_WIDTH)
      ).slave mon_mem_vif);

    gen_to_drv = new();
    mon_to_scb = new();

    gen = new(gen_to_drv, gen_done);
    drv = new(clk_rst_vif, drv_mem_vif, gen_to_drv);
    mon = new(clk_rst_vif, mon_mem_vif, mon_to_scb);
    scb = new(mon_to_scb);
  endfunction

  task pre_test();
    // Reserve place for any preliminary setup tasks if required
  endtask

  task test();
    // Spin up components concurrently in the master background processing block
    fork
      gen.run();
      drv.run();
      mon.run();
      scb.run();
    join_any
  endtask

  task post_test();
    // Wait for generator handshake to settle execution loops cleanly
    @gen_done;
    #100;  // Allow pipeline data to clear monitoring segments
    $display("=====================================================================");
    $display("                  VERIFICATION REGRESSION SUMMARY STATUS");
    $display("=====================================================================");
    $display(" Total Transactions Screened: %0d", scb.check_count);
    $display(" Scoreboard Errors Logged:   %0d", scb.error_count);
    $display("=====================================================================");
    if (scb.error_count == 0) begin
      $display(" STATUS: REGRESSION PASS SUCCESS!");
    end else begin
      $fatal(" STATUS: REGRESSION CRITICAL FAILURE DEFECTS DETECTED!");
    end
    $display("=====================================================================");
  endtask

  task run();
    pre_test();
    test();
    post_test();
  endtask

endclass : ram_environment
