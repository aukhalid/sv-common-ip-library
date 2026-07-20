# RTL Design & Verification - Complete Environment Setup Guide

A production-grade guide to setting up a Linux development environment for Digital Design and Verification on Windows. Supports **WSL2**, **VMware Workstation**, and **Native Dual-Boot**.

---

## Part 1: Choosing Your Linux Platform

| Method                 | Setup Complexity | Best Used For                                                                     |
| ---------------------- | ---------------- | --------------------------------------------------------------------------------- |
| **WSL2 (Recommended)** | Low              | Fastest setup, lowest RAM usage, seamless VS Code & GUI (WSLg) integration        |
| **VMware Workstation** | Medium           | Complete VM isolation, dedicated virtual disk, traditional desktop GUI            |
| **Dual-Boot Ubuntu**   | High             | Direct hardware access, dedicated physical lab setup, physical FPGA JTAG bring-up |

### Why WSL2 is Recommended

- **Near-Native Speed**: Real Linux kernel on a lightweight Hyper-V utility VM — no heavy VM overhead.
- **Native GUI (WSLg)**: Windows 10 (21H2+) and Windows 11 render Linux GUI apps (`gtkwave`, `vivado`, `drawio`) seamlessly inside Windows desktop windows.
- **VS Code Remote Integration**: VS Code runs on Windows while its execution server runs inside WSL2, giving you native file speed and responsiveness.

---

## Part 2: Platform Deployment

Choose **one** deployment pathway below.

### Option A: WSL2 Deployment (Recommended)

Open **PowerShell as Administrator** and run:

```powershell
wsl --install -d Ubuntu-22.04
```

Restart your computer when prompted.

Launch **Ubuntu 22.04 LTS** from the Windows Start Menu, set your Linux username and password, then verify WSLg graphics:

```bash
sudo apt update && sudo apt install -y x11-apps
xclock
```

> A small analog clock window should open seamlessly inside Windows.

### Option B: VMware Workstation Deployment

1. Download **VMware Workstation Pro** (Free from Broadcom) and the **Ubuntu 22.04.5 LTS ISO**.
2. Create a new VM with:
   - **CPU Cores**: 4 minimum (6+ recommended)
   - **RAM**: 8 GB minimum (12–16 GB recommended)
   - **Disk Space**: 120–150 GB (Single File allocation)

### Option C: Native Dual-Boot Deployment

1. Create an Ubuntu Live USB using **Rufus** and the Ubuntu 22.04.5 LTS ISO.
2. Shrink your Windows partition by at least **120 GB** in Windows Disk Management.
3. Boot into BIOS/UEFI, **disable Secure Boot**, boot from the USB drive, and complete the dual-boot installation alongside Windows.

---

## Part 3: Toolchain Installation

Execute all subsequent steps inside your **Ubuntu 22.04 LTS terminal**.

### Step 1: Base System Update & Build Tools

```bash
# Update repository indexes
sudo apt update && sudo apt upgrade -y

# Essential build and networking utilities
sudo apt install -y build-essential gcc g++ make git git-lfs   python3 python3-pip lsb-release net-tools curl wget universal-ctags

# Legacy dependencies for Vivado & GUI rendering
sudo apt install -y libtinfo5 libncurses5 libncursesw5 libxrender1   libxtst6 libxi6 libxft2 libfontconfig1 libx11-6 libxext6 libtinfo-dev
```

### Step 2: Open-Source EDA Tools

```bash
sudo apt install -y iverilog gtkwave verilator
```

### Step 3: Visual Studio Code

```bash
# Clean conflicting legacy repos
sudo rm -f /etc/apt/sources.list.d/vscode.list

# Import Microsoft GPG key
wget -qO- https://packages.microsoft.com/keys/microsoft.asc |   gpg --dearmor | sudo tee /etc/apt/keyrings/packages.microsoft.gpg > /dev/null

# Register official repository
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'

# Install VS Code
sudo apt update && sudo apt install -y code
```

> **WSL2 Users**: Also download and install VS Code on your **Windows host**. Install the **WSL extension** (`ms-vscode-remote.remote-wsl`) inside Windows VS Code.

### Step 4: AMD Vivado ML Standard

Skip if you are exclusively using Icarus Verilog (`iverilog`).

1. Download **Vivado ML Standard Edition (Linux Web Installer)** from AMD.
2. Run the installer:

```bash
cd ~/Downloads
chmod +x FPGAs_AdaptiveSoCs_Unified_*.bin

# Create installation target path
sudo mkdir -p /tools/Xilinx
sudo chown -R $USER:$USER /tools/Xilinx

# Execute installer
./FPGAs_AdaptiveSoCs_Unified_*.bin
```

**Installer Settings:**

- Select **Vivado ML Standard**
- Uncheck heavy FPGA families (UltraScale+/Versal) to save ~40 GB
- Set destination to `/tools/Xilinx`

**Install Cable Drivers:**

```bash
cd /tools/Xilinx/Vivado/2024.2/data/xicom/cable_drivers/lin64/install_script/install_drivers/
sudo ./install_drivers
```

### Step 5: Verible Formatter

```bash
cd ~/Downloads
wget https://github.com/chipsalliance/verible/releases/download/v0.0-3644-g6c271816/verible-v0.0-3644-g6c271816-linux-static-x86_64.tar.gz

tar -xzf verible-*.tar.gz
sudo cp verible-*/bin/verible-verilog-format /usr/local/bin/

# Verify installation
verible-verilog-format --version
```

---

## Part 4: Environment & Workspace Setup

### Step 1: Shell Configuration

Open `~/.bashrc`:

```bash
nano ~/.bashrc
```

Append the following to the bottom:

```bash
# ==============================================================================
# RTL & DV Toolchain Environment Configuration
# ==============================================================================

# Vivado Settings (Uncomment if Vivado is installed)
# source /tools/Xilinx/Vivado/2024.2/settings64.sh
# alias vsim="vivado -mode gui &"

# Short aliases
alias ivrun="iverilog -g2012"
```

Reload configuration:

```bash
source ~/.bashrc
```

### Step 2: Workspace Directory Initialization

```bash
mkdir -p ~/workspace/rtl-dv-portfolio/sv-common-ip-library
cd ~/workspace/rtl-dv-portfolio/sv-common-ip-library

# Infrastructure
mkdir -p docs scripts common/{packages,interfaces,macros,assertions}

# IP Subdirectories
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

## Part 5: Secure GitHub Setup

```bash
# 1. Configure identity
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 2. Generate SSH Key
ssh-keygen -t ed25519 -C "your.email@example.com"

# 3. Print public key
cat ~/.ssh/id_ed25519.pub
```

Copy the key and add it to **GitHub → Settings → SSH and GPG keys → New SSH Key**.

```bash
# 4. Verify connection
ssh -T git@github.com
```

---

## Part 6: VS Code Configuration

Launch VS Code in your workspace root:

```bash
cd ~/workspace/rtl-dv-portfolio/sv-common-ip-library
code .
```

### Required Extensions

Press `Ctrl + Shift + X` and install:

| Extension                        | Publisher        |
| -------------------------------- | ---------------- |
| SystemVerilog - Language Support | mshr-h           |
| Verilog-HDL/SystemVerilog        | LeafXia          |
| Verible                          | kukdh1           |
| Draw.io Integration              | henningdietrichs |
| vscode-icons                     | vscode-icons     |

### Formatter Settings

Open **User Settings (JSON)** (`Ctrl + Shift + P` → _Open User Settings (JSON)_) and add:

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
--port_declarations_alignment=align
--formal_parameters_alignment=align
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

### Step 2: Run Verification Workflow

**Lint first:**

```bash
verilator --lint-only -Wall counter.sv
```

**Option A — Icarus Verilog:**

```bash
# Compile
iverilog -g2012 -o counter_sim.out counter.sv counter_tb.sv

# Simulate
vvp counter_sim.out
```

**Option B — AMD Vivado (xsim):**

```bash
# Parse sources
xvlog -sv counter.sv counter_tb.sv

# Elaborate snapshot
xelab counter_tb -s smoke_snapshot

# Simulate
xsim smoke_snapshot -runall
```

### Step 3: View Waveforms

```bash
gtkwave waveform.vcd &
```

**Expected Output:**

```
[SMOKE TEST SUCCESS] Counter final value: 19
```

---

## Quick Reference Links

| Resource               | Link                                                                                                                                    |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| WSL Documentation      | [Microsoft Learn WSL](https://learn.microsoft.com/en-us/windows/wsl/)                                                                   |
| VMware Workstation Pro | [Broadcom Support Downloads](https://support.broadcom.com/security-advisory/security-advisory-detail.html?securit-advisory-id=SA230514) |
| Ubuntu 22.04.5 LTS ISO | [Ubuntu Releases](https://releases.ubuntu.com/22.04/)                                                                                   |
| Icarus Verilog Docs    | [Icarus Wiki](https://iverilog.fandom.com/wiki/Main_Page)                                                                               |
| AMD Vivado ML Standard | [AMD Downloads](https://www.amd.com/en/support/downloads/adaptive-socs-and-fpgas/development-tools/2024-2.html)                         |
| Verible Releases       | [Chips Alliance GitHub](https://github.com/chipsalliance/verible/releases)                                                              |
