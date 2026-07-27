// ==============================================================================
// FILE: memory/dual_port_ram/tb/ram_transaction.sv
// ASSET: Dual-Port RAM Transaction Container
// ==============================================================================

class ram_transaction #(
    int DATA_WIDTH = 32,
    int ADDR_WIDTH = 8
);

  // Randomizable Write Channel Payload
  rand logic                  wr_en;
  rand logic [ADDR_WIDTH-1:0] waddr;
  rand logic [DATA_WIDTH-1:0] wr_data;

  // Randomizable Read Channel Payload
  rand logic                  rd_en;
  rand logic [ADDR_WIDTH-1:0] raddr;

  // Sampled Output Data
  logic      [DATA_WIDTH-1:0] rd_data;

  // Distribution Constraints
  constraint wr_mix_c {
    wr_en dist {
      1'b1 := 60,
      1'b0 := 40
    };
  }
  constraint rd_mix_c {
    rd_en dist {
      1'b1 := 60,
      1'b0 := 40
    };
  }

  function new();
  endfunction

  function void display(string prefix = "TRANS");
    $display("[%s] Time: %0t | WR: en=%b addr=0x%0h data=0x%0h | RD: en=%b addr=0x%0h data=0x%0h",
             prefix, $time, wr_en, waddr, wr_data, rd_en, raddr, rd_data);
  endfunction

  function ram_transaction#(DATA_WIDTH, ADDR_WIDTH) clone();
    ram_transaction #(DATA_WIDTH, ADDR_WIDTH) copy;
    copy = new();
    copy.wr_en = this.wr_en;
    copy.waddr = this.waddr;
    copy.wr_data = this.wr_data;
    copy.rd_en = this.rd_en;
    copy.raddr = this.raddr;
    copy.rd_data = this.rd_data;
    return copy;
  endfunction

endclass : ram_transaction
