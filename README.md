# sv-common-ip-library

## Evnironment Setup

[Environment Setup](documents/01_environment_setup_guide.md)

## 📁 Project Structure

```
sv-common-ip-library/
├── README.md
├── LICENSE
├── .gitignore
├── Makefile                   
│
├── docs/
│   ├── coding_style.md
│   ├── rtl_design_guidelines.md
│   ├── verification_guidelines.md
│   ├── directory_structure.md
│   └── naming_conventions.md
│
├── scripts/
│   ├── lint/
│   ├── sim/
│   ├── regression/
│   ├── coverage/
│   └── waveform/
│
├── common/
│   ├── packages/
│   │   ├── common_pkg.sv
│   │   ├── counter_pkg.sv
│   │   ├── fifo_pkg.sv
│   │   ├── memory_pkg.sv
│   │   ├── arithmetic_pkg.sv
│   │   └── crc_pkg.sv
│   │
│   ├── interfaces/
│   │   ├── clk_rst_if.sv
│   │   ├── fifo_if.sv
│   │   ├── memory_if.sv
│   │   └── stream_if.sv
│   │
│   └── macros/
│       ├── common_macros.svh
│       ├── assert_macros.svh
│       └── sim_macros.svh
│
├── foundation/
│   ├── clock_divider/
│   ├── reset_sync/
│   ├── edge_detector/
│   ├── pulse_sync/
│   ├── two_flop_sync/
│   ├── toggle_sync/
│   ├── handshake_sync/
│   └── counter_lib/
│       ├── basic_counter/
│       ├── up_down_counter/
│       ├── gray_counter/
│       ├── ring_counter/
│       └── johnson_counter/
│
├── arithmetic/
│   ├── adder_subtractor/
│   ├── incrementer/
│   ├── decrementer/
│   ├── carry_lookahead_adder/
│   ├── carry_select_adder/
│   └── carry_save_adder/
│
├── combinational/
│   ├── mux/
│   │   └── mux_param/
│   │
│   ├── decoder/
│   │   └── decoder_param/
│   │
│   ├── encoder/
│   │   ├── encoder_param/
│   │   └── priority_encoder_param/
│   │
│   ├── comparator/
│   │   └── comparator_param/
│   │
│   ├── gray_converter/
│   │   ├── bin_to_gray/
│   │   └── gray_to_bin/
│   │
│   ├── arbiter/
│   │   ├── fixed_priority/
│   │   └── round_robin/
│   │
│   ├── barrel_shifter/
│   └── lfsr/
│
├── sequential/
│   ├── shift_register/
│   │   ├── siso/
│   │   ├── sipo/
│   │   ├── piso/
│   │   └── universal/
│   │
│   └── timer_lib/
│       ├── timer/
│       ├── watchdog/
│       └── interval_timer/
│
├── memory/
│   ├── register_file/
│   ├── single_port_ram/
│   ├── dual_port_ram/
│   ├── sync_fifo/
│   └── async_fifo/
│
└── datapath/
    ├── crc_generator/
    ├── parity_generator/
    ├── parity_checker/
    ├── checksum/
    └── popcount/

```
