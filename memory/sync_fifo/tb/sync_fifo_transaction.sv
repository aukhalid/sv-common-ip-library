class sync_fifo_transaction #(
    int DATA_WIDTH = 32
);
  rand logic                  wr_en;
  rand logic [DATA_WIDTH-1:0] wr_data;
  rand logic                  rd_en;
  logic      [DATA_WIDTH-1:0] rd_data;
  logic                       is_full;
  logic                       is_empty;

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

  function sync_fifo_transaction#(DATA_WIDTH) clone();
    sync_fifo_transaction #(DATA_WIDTH) copy = new();
    copy.wr_en    = this.wr_en;
    copy.wr_data  = this.wr_data;
    copy.rd_en    = this.rd_en;
    copy.rd_data  = this.rd_data;
    copy.is_full  = this.is_full;
    copy.is_empty = this.is_empty;
    return copy;
  endfunction
endclass : sync_fifo_transaction
