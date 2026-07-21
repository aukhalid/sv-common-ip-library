# RTL Design & Verification - Complete Environment Setup Guide

A production-grade guide to setting up a Linux development environment for RTL Digital Design and Verification. Supports **WSL2**, **VMware Workstation**, and **Native or Dual-Boot**.

---

## Table of Contents

1. [Part 1: Choosing Your Linux Platform](#part-1-choosing-your-linux-platform)
2. [Part 2: Platform Deployment](#part-2-platform-deployment)
3. [Part 3: Toolchain Installation](#part-3-toolchain-installation)
4. [Part 4: Environment & Workspace Setup](#part-4-environment--workspace-setup)
5. [Part 5: Secure GitHub Setup](#part-5-secure-github-setup)
6. [Part 6: VS Code Configuration](#part-6-vs-code-configuration)
7. [Part 7: Verification Smoke Test](#part-7-verification-smoke-test)
8. [Quick Reference Links](#quick-reference-links)

---

## Part 1: Choosing Your Linux Platform

| Method                 | Setup Complexity | Best Used For                                                                     |
| ---------------------- | ---------------- | --------------------------------------------------------------------------------- |
| **WSL2 (Recommended)** | Low              | Fastest setup, lowest RAM usage, seamless VS Code & GUI (WSLg) integration        |
| **VMware Workstation** | Medium           | Complete VM isolation, dedicated virtual disk, traditional desktop GUI            |
| **Dual-Boot Ubuntu**   | High             | Direct hardware access, dedicated physical lab setup, physical FPGA JTAG bring-up |
| **Native Ubuntu**      | High             | Direct hardware access, dedicated physical lab setup, physical FPGA JTAG bring-up |

---

## Part 2: Platform Deployment

Choose **One** deployment pathway below.

### Option A: WSL2 Deployment (Recommended)

#### Step 1: Enable Windows Virtualization Subsystems via DISM

Open **PowerShell as Administrator** and run:

```powershell
dism /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

#### Step 2: System Reboot (Mandatory)

#### Step 3: Install WSL Core & Ubuntu 22.04 LTS

After rebooting, open **PowerShell as Administrator** and run:

```powershell
# Install WSL Core Engine
wsl --install

# Download and register Ubuntu 22.04 LTS
wsl --install -d Ubuntu-22.04
```

> **Alternative:** If PowerShell encounters network limits, open the Microsoft Store app, search for **Ubuntu 22.04 LTS**, and click **Get / Install**.

#### Step 4: Initialize Shell & Verify Graphics Pipeline (WSLg)

1. Launch **Ubuntu 22.04 LTS** from the **Windows Start** Menu.
2. Set your UNIX username and password when prompted.
3. Test Windows GUI app integration:

```bash
sudo apt update && sudo apt install -y x11-apps
xclock
```

> A small analog clock window should open natively on your Windows desktop.

### Option B: VMware Workstation Deployment

1. Download [**VMware Workstation Pro**](https://www.techpowerup.com/download/vmware-workstation-pro/) and the [**Ubuntu 22.04.5 LTS ISO**](https://releases.ubuntu.com/22.04/).
2. Create a new VM with:
   - **CPU Cores**: 4 minimum (6+ recommended)
   - **RAM**: 8 GB minimum (12–16 GB recommended)
   - **Disk Space**: 120–150 GB (Single File allocation)

### Option C: Native/Dual-Boot Deployment

1. Create an Ubuntu Live USB using [**Rufus**](https://rufus.ie/en/) and the [**Ubuntu 22.04.5 LTS ISO**](https://releases.ubuntu.com/22.04/).
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
sudo apt install -y build-essential gcc g++ make git git-lfs \
  python3 python3-pip lsb-release net-tools curl wget universal-ctags

# Legacy dependencies for Vivado & GUI rendering
sudo apt install -y libtinfo5 libncurses5 libncursesw5 libxrender1 \
  libxtst6 libxi6 libxft2 libfontconfig1 libx11-6 libxext6 libtinfo-dev
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
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | \
  gpg --dearmor | sudo tee /etc/apt/keyrings/packages.microsoft.gpg > /dev/null

# Register official repository
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'

# Install VS Code
sudo apt update && sudo apt install -y code
```

> **WSL2 Users:** Also download and install [**VS Code**](https://code.visualstudio.com/download?_exp_download=fb315fc982) on your **Windows host**. Install the **WSL extension** (`ms-vscode-remote.remote-wsl`) inside Windows VS Code.

### Step 4: AMD Vivado ML Standard

Skip if you are exclusively using Icarus Verilog (`iverilog`).

1. Download [**Vivado 2024.2 ML Standard Edition (Linux Web Installer)**](https://www.amd.com/en/support/downloads/adaptive-socs-and-fpgas/development-tools/2024-2.html) from AMD. Filename: `FPGAs_AdaptiveSoCs_Unified_2024.2_1113_2356_Lin64.bin`
2. Prepare target directories and copy the installer into the native Linux filesystem (to prevent NTFS permission blocks):

```bash
# Create installation target path
sudo mkdir -p /tools/Xilinx
sudo chown -R $USER:$USER /tools/Xilinx

# Copy installer from Windows Downloads to Linux Home
cd ~
cp /mnt/c/Users/$USER/Downloads/FPGAs_AdaptiveSoCs_Unified_*.bin .

# Grant execution permissions and run
chmod +x FPGAs_AdaptiveSoCs_Unified_*.bin
./FPGAs_AdaptiveSoCs_Unified_*.bin
```

**Installer Settings:**

- Select **Vivado ML Standard**
- Uncheck everything that can be unchecked
- Select FPGA Parts if needed
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
# AMD Vivado 2024.2 & EDA Verification Toolchain Mapping Configuration
# ==============================================================================
source /tools/Xilinx/Vivado/2024.2/settings64.sh
alias vsim="vivado -mode gui &"

# ==============================================================================
# Short Aliases
# ==============================================================================
alias ivrun="iverilog -g2012"
```

Save and exit (Ctrl + O, Enter, Ctrl + X). Reload the bash engine parameters immediately:

```bash
source ~/.bashrc
```

### Step 2: Workspace Directory Initialization

```bash
mkdir -p ~/workspace/rtl-dv-projects/your-repo
cd ~/workspace/rtl-dv-projects/your-repo
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
cd ~/workspace/rtl-dv-projects/your-repo
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

**Option A — AMD Vivado (xsim):**

```bash
# Parse sources
xvlog -sv counter.sv counter_tb.sv

# Elaborate snapshot
xelab counter_tb -s smoke_snapshot

# Simulate
xsim smoke_snapshot -runall
```

**Option B — Icarus Verilog:**

```bash
# Compile
iverilog -g2012 -o counter_sim.out counter.sv counter_tb.sv

# Simulate
vvp counter_sim.out
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

| Resource               | Link                                                                                                            |
| ---------------------- | --------------------------------------------------------------------------------------------------------------- |
| WSL Documentation      | [Microsoft Learn WSL](https://learn.microsoft.com/en-us/windows/wsl/)                                           |
| VMware Workstation Pro | [Download From Here](https://www.techpowerup.com/download/vmware-workstation-pro/)                              |
| Ubuntu 22.04.5 LTS ISO | [Ubuntu Releases](https://releases.ubuntu.com/22.04/)                                                           |
| Icarus Verilog Docs    | [Icarus Wiki](https://iverilog.fandom.com/wiki/Main_Page)                                                       |
| AMD Vivado ML Standard | [AMD Downloads](https://www.amd.com/en/support/downloads/adaptive-socs-and-fpgas/development-tools/2024-2.html) |
| Verible Releases       | [Chips Alliance GitHub](https://github.com/chipsalliance/verible/releases)                                      |
