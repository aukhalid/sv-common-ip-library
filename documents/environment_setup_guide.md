# RTL Design & Verification Lab — Complete Environment Setup Guide

A step-by-step guide to building an industry-grade, tape-out-ready Linux development environment on a Windows host.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Part 1: Tool Selection Stack](#part-1-tool-selection-stack)
3. [Part 2: Virtual Machine Deployment](#part-2-virtual-machine-deployment)
4. [Part 3: IDE & Software Installation](#part-3-ide--software-installation)
5. [Part 4: Tool Environment Configuration](#part-4-tool-environment-configuration)
6. [Part 5: Secure GitHub Authentication](#part-5-secure-github-authentication)
7. [Part 6: VS Code Development Suite](#part-6-vs-code-development-suite)
8. [Part 7: Verification Smoke Test](#part-7-verification-smoke-test)

---

## Architecture Overview

```text
+-------------------------------------------------------------+
|                     WINDOWS HOST PC                         |
|  [VMware Workstation Player / Pro]                          |
+-------------------------------------------------------------+
                               |
                               v Virtualizes
+-------------------------------------------------------------+
|                   VIRTUAL MACHINE ENVIRONMENT               |
|  [OS: Ubuntu 22.04 LTS]                                     |
+-------------------------------------------------------------+
            |                      |                   |
            v                      v                   v
+-----------------------+  +---------------+  +---------------+
|     IDE & TOOLCHAIN   |  |  AUTOMATION   |  |   EDA ENGINES |
|  [VS Code + Git/SSH]  |  |  [GNU Make]   |  |  [AMD Vivado] |
|  [Draw.io + Linter]   |  |               |  |  [Verilator]  |
|                       |  |               |  |  [GTKWave]    |
+-----------------------+  +---------------+  +---------------+
```

---

## Part 1: Tool Selection Stack

| Component           | Software                                                                                                                                | Why                                                                                                |
| ------------------- | --------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| **Virtualizer**     | [VMware Workstation Pro](https://support.broadcom.com/security-advisory/security-advisory-detail.html?securit-advisory-id=SA2025062401) | Free since Broadcom acquisition. Excellent hardware acceleration and stable multi-core allocation. |
| **OS**              | [Ubuntu 22.04.5 LTS Desktop](https://releases.ubuntu.com/jammy)                                                                         | Industry-standard stability. Avoids library tracking errors common in newer releases.              |
| **Simulator**       | [AMD Vivado ML Standard](https://www.xilinx.com/support/download.html)                                                                  | Free edition with full SystemVerilog support and native UVM 1.2 in XSim.                           |
| **Linter**          | Verilator                                                                                                                               | Ultra-fast open-source static analysis and latch prevention.                                       |
| **Waveform Viewer** | GTKWave                                                                                                                                 | Lightweight, efficient VCD trace reader.                                                           |
| **IDE**             | [VS Code](https://code.visualstudio.com/download)                                                                                       | Strong extension ecosystem for HDLs.                                                               |
| **Formatter**       | [Verible](https://github.com/chipsalliance/verible/releases)                                                                            | Google-developed SystemVerilog formatter, linter, and language server.                             |

---

## Part 2: Virtual Machine Deployment

### Step 1: Install VMware & Create VM

1. Download **VMware Workstation Pro** (free) from Broadcom:  
   https://support.broadcom.com/security-advisory/security-advisory-detail.html?securit-advisory-id=SA2025062401
2. Download **Ubuntu 22.04.5 LTS Desktop ISO**:  
   https://releases.ubuntu.com/jammy/ubuntu-22.04.5-desktop-amd64.iso
3. In VMware: **Create a New Virtual Machine** → select the ISO.
4. Configure VM hardware:

| Resource  | Minimum | Recommended                  |
| --------- | ------- | ---------------------------- |
| CPU Cores | 4       | 6+                           |
| RAM       | 8 GB    | 12–16 GB (if host has 32 GB) |
| Disk      | 120 GB  | 150 GB (single file)         |

> **Why single file?** Faster disk I/O. Vivado needs massive installation space.

### Step 2: System Update & Dependencies

Boot the VM, open a terminal (`Ctrl + Alt + T`), and run:

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Core build tools
sudo apt install -y build-essential gcc g++ make git git-lfs \
  python3 python3-pip lsb-release net-tools curl wget universal-ctags

# Vivado GUI dependencies (legacy libraries)
sudo apt install -y libtinfo5 libncurses5 libncursesw5 libxrender1 \
  libxtst6 libxi6 libxft2 libfontconfig1 libx11-6 libxext6 libtinfo-dev
```

### Step 3: Install Open-Source EDA Tools

```bash
sudo apt install -y gtkwave verilator
```

---

## Part 3: IDE & Software Installation

### Step 1: Install VS Code

```bash
# Clean legacy repos
sudo rm -f /etc/apt/sources.list.d/vscode.list

# Add Microsoft GPG key
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | \
  gpg --dearmor | sudo tee /etc/apt/keyrings/packages.microsoft.gpg > /dev/null

# Add VS Code repository
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'

# Install
sudo apt update
sudo apt install -y code
```

### Step 2: Install AMD Vivado ML Standard

1. Download the **Linux Web Installer** from AMD:  
   https://www.xilinx.com/support/download.html  
   (Look for "Vivado ML Standard Edition" — free, no license required.)

2. Run the installer:

```bash
cd ~/Downloads
chmod +x FPGAs_AdaptiveSoCs_Unified_*.bin

# Create install directory
sudo mkdir -p /tools/Xilinx
sudo chown -R $USER:$USER /tools/Xilinx

# Launch installer
./FPGAs_AdaptiveSoCs_Unified_*.bin
```

3. **Installer selections:**
   - **Product:** Vivado
   - **Edition:** Vivado ML Standard (free)
   - **Devices:** Uncheck UltraScale+/Versal to save ~40 GB. Keep **XSim** checked.
   - **Path:** `/tools/Xilinx`

4. **Install cable drivers** (for hardware debugging):

```bash
cd /tools/Xilinx/Vivado/2024.2/data/xicom/cable_drivers/lin64/install_script/install_drivers/
sudo ./install_drivers
```

### Step 3: Install Verible (SystemVerilog Formatter)

```bash
# Download latest release (check https://github.com/chipsalliance/verible/releases for current version)
cd ~/Downloads
wget https://github.com/chipsalliance/verible/releases/download/v0.0-4080-ga0a8d8eb/verible-v0.0-4080-ga0a8d8eb-linux-static-x86_64.tar.gz

# Extract and install
tar -xzf verible-v0.0-4080-ga0a8d8eb-linux-static-x86_64.tar.gz
sudo cp verible-*/bin/verible-verilog-format /usr/local/bin/

# Verify
verible-verilog-format --version
```

---

## Part 4: Tool Environment Configuration

### Step 1: Configure Bash Environment

```bash
nano ~/.bashrc
```

Add at the bottom:

```bash
# ==============================================================================
# AMD Vivado 2024.2 & EDA Toolchain
# ==============================================================================
source /tools/Xilinx/Vivado/2024.2/settings64.sh
alias vsim="vivado -mode gui &"
```

Save (`Ctrl+O`, `Enter`, `Ctrl+X`), then reload:

```bash
source ~/.bashrc
```

### Step 2: Create Project Workspace

```bash
mkdir -p ~/workspace/rtl-dv-portfolio/sv-common-ip-library
cd ~/workspace/rtl-dv-portfolio/sv-common-ip-library

# Core infrastructure
mkdir -p docs scripts common/{packages,interfaces,macros,assertions}

# IP blocks
IP_LIST=(
  "foundation/clock_divider"
  "foundation/reset_sync"
  "foundation/edge_detector"
  "foundation/pulse_sync"
  "foundation/two_flop_sync"
  "foundation/toggle_sync"
  "foundation/handshake_sync"
  "foundation/counter_lib/basic_counter"
  "foundation/counter_lib/up_down_counter"
  "foundation/counter_lib/gray_counter"
  "memory/register_file"
  "memory/single_port_ram"
  "memory/dual_port_ram"
  "memory/sync_fifo"
  "memory/async_fifo"
  "datapath/priority_encoder"
  "datapath/arbiter_fixed"
  "datapath/arbiter_round_robin"
  "datapath/gray_to_bin"
  "datapath/crc_generator"
)

for ip in "${IP_LIST[@]}"; do
  mkdir -p "$ip"/{rtl,tb,sim,docs}
  touch "$ip"/Makefile
done

touch README.md LICENSE .gitignore Makefile
```

---

## Part 5: Secure GitHub Authentication

### Step 1: Set Git Identity

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Step 2: Generate SSH Key

```bash
ssh-keygen -t ed25519 -C "your.email@example.com"
```

> Press Enter to accept defaults. Leave passphrase empty for seamless pushes.

### Step 3: Add Key to GitHub

```bash
cat ~/.ssh/id_ed25519.pub
```

1. Copy the output.
2. Go to GitHub → **Settings** → **SSH and GPG keys** → **New SSH key**.
3. Paste key, label it (e.g., "Linux VM"), click **Add**.

### Step 4: Test Connection

```bash
ssh -T git@github.com
```

Expected: `Hi username! You've successfully authenticated...`

---

## Part 6: VS Code Development Suite

### Launch VS Code in Project

```bash
cd ~/workspace/rtl-dv-portfolio/sv-common-ip-library
code .
```

### Required Extensions

Install via Extensions panel (`Ctrl+Shift+X`):

| Extension                            | Publisher          | Purpose                                             |
| ------------------------------------ | ------------------ | --------------------------------------------------- |
| **SystemVerilog - Language Support** | mshr-h             | Syntax highlighting, auto-completion, file indexing |
| **Verilog-HDL/SystemVerilog**        | LeafXia            | Background compiler integration                     |
| **Verible**                          | Google             | Code formatting, linting, language server           |
| **Draw.io Integration**              | Henning Dieterichs | Diagrams (save as `*.drawio.svg`)                   |
| **vscode-icons**                     | VS Code Icons Team | File type icons in explorer                         |

### Configure Verible Formatter in VS Code

Open `settings.json` (`Ctrl+Shift+P` → "Open User Settings JSON") and add:

```json
{
  "[systemverilog]": {
    "editor.defaultFormatter": "kukdh1.verible-formatter",
    "editor.formatOnSave": true
  },
  "verilog-formatter.path": "verible-verilog-format",
  "verilog-formatter.flagFile": ".verilog_format"
}
```

Create `.verilog_format` in your project root:

```
--column_limit 100
--indentation_spaces 2
--assignment_statement_alignment=align
--case_items_alignment=align
--class_member_variable_alignment=align
--compact_indexing_and_selections=true
--distribution_items_alignment=align
--enum_assignment_statement_alignment=align
--expand_coverpoints=true
--formal_parameters_alignment=align
--formal_parameters_indentation=indent
--module_net_variable_alignment=align
--named_parameter_alignment=align
--named_parameter_indentation=indent
--named_port_alignment=align
--named_port_indentation=indent
--port_declarations_alignment=align
--port_declarations_indentation=indent
--port_declarations_right_align_packed_dimensions=true
--port_declarations_right_align_unpacked_dimensions=true
--struct_union_members_alignment=align
--try_wrap_long_lines=false
```

---

## Part 7: Verification Smoke Test

### Step 1: Create Test Files

```bash
mkdir -p ~/workspace/rtl-dv-portfolio/smoke_test
cd ~/workspace/rtl-dv-portfolio/smoke_test
```

**`counter.sv`**:

```systemverilog
module counter #(
    parameter WIDTH = 8
)(
    input  logic             clk_i,
    input  logic             rst_n_i,
    input  logic             wr_en_i,
    output logic [WIDTH-1:0] count_o
);
    always_ff @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            count_o <= '0;
        end else if (wr_en_i) begin
            count_o <= count_o + 1'b1;
        end
    end
endmodule
```

**`counter_tb.sv`**:

```systemverilog
module counter_tb;
    logic clk = 0;
    logic rst_n = 0;
    logic wr_en = 0;
    logic [7:0] count;

    counter #(.WIDTH(8)) dut (
        .clk_i   (clk),
        .rst_n_i (rst_n),
        .wr_en_i (wr_en),
        .count_o (count)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, counter_tb);
        #15 rst_n = 1;
        #10 wr_en = 1;
        repeat(20) @(posedge clk);
        $display("[SMOKE TEST SUCCESS] Counter final value: %d", count);
        $finish;
    end
endmodule
```

### Step 2: Run Validation Commands

```bash
# 1. Static lint check (must exit with zero warnings)
verilator --lint-only -Wall counter.sv

# 2. Compile SV sources
xvlog -sv counter.sv counter_tb.sv

# 3. Elaborate
xelab counter_tb -s smoke_snapshot

# 4. Simulate
xsim smoke_snapshot -runall
```

**Expected output:**

```
[SMOKE TEST SUCCESS] Counter final value: 19
```

```bash
# 5. View waveforms
gtkwave waveform.vcd &
```

Drag the `count` signal into the waveform pane. Verify it counts from 0 to 19.

---

## Quick Reference: Download Links

| Tool                   | Download URL                                      |
| ---------------------- | ------------------------------------------------- |
| VMware Workstation Pro | https://support.broadcom.com                      |
| Ubuntu 22.04.5 LTS ISO | https://releases.ubuntu.com/jammy                 |
| AMD Vivado ML Standard | https://www.xilinx.com/support/download.html      |
| VS Code                | https://code.visualstudio.com/download            |
| Verible                | https://github.com/chipsalliance/verible/releases |

---

_Environment ready. Delete `smoke_test/` and begin Phase 0 IP development._
