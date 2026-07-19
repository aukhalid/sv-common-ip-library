# Production Environment Setup Guide: Digital Verification Lab

## RTL Design Infrastructure & Verification Framework Automation

This document serves as the absolute, step-by-step master guide to building an industry-grade, tape-out-ready Linux development environment from scratch on a Windows host machine.

By transitioning away from native Windows to an isolated Linux environment, you align directly with the enterprise engineering practices utilized at premier semiconductor design firms. This framework natively supports SystemVerilog Assertions (SVA), advanced Object-Oriented Programming (OOP) testbenches, automation tools, and full simulation workloads without requiring expensive commercial licenses.

---

## Architecture Overview

Before beginning execution, understand the structure of the development environment you are building:

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

| Component         | Software Selection        | Engineering Selection Rationale                                                                                                                        |
| ----------------- | ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Virtualizer       | VMware Workstation Player | Provides excellent, zero-cost hardware acceleration and stable multi-core resource allocation under Windows.                                           |
| Operating System  | Ubuntu 22.04 LTS Desktop  | Industry-standard stability. Avoids library tracking errors (such as missing libtinfo5) common in newer releases.                                      |
| Primary Simulator | AMD Vivado ML Standard    | Version 2023.1 and newer includes complete out-of-the-box support for SystemVerilog features and native UVM 1.2 execution inside the free XSim engine. |
| Static Linter     | Verilator Engine          | Ultra-fast open-source tool utilized for static code quality check rules and latch-prevention reviews.                                                 |
| Waveform Viewer   | GTKWave Analyzer          | A highly efficient, lightweight vector trace reader for parsing .vcd tracking files.                                                                   |
| Primary IDE       | Visual Studio Code        | Standard modular editor featuring strong extension ecosystems for hardware description languages.                                                      |

---

## Part 2: Virtual Machine Deployment

### Step 1: Resource Provisioning

1. Install **VMware Workstation Player or Pro** on your Windows system.
2. Download the official **Ubuntu 22.04 LTS Desktop** ISO file.
3. Launch VMware, click **Create a New Virtual Machine**, select **Installer disc image file (iso)**, and target your downloaded Ubuntu ISO.
4. Configure the virtualized hardware limits precisely to handle heavy Vivado synthesis:
   - **Processors / Cores:** Allocate a minimum of 4 to 6 CPU cores. Multi-threaded engines cut elaboration times dramatically.
   - **Memory (RAM):** Allocate 8 GB minimum. Allocate 12 GB to 16 GB if your host Windows platform contains 32 GB.
   - **Hard Disk Space:** Allocate 120 GB to 150 GB. Configure it strictly as a **Single File** to speed up disk read/write cycles. Vivado requires massive installation footprints.

### Step 2: System Update & Library Injection

Boot the newly created Ubuntu VM, log in, open a terminal (`Ctrl + Alt + T`), and execute the following commands to install essential toolchains and resolve graphical user interface dependencies:

```bash
# Update local repository indexes
sudo apt update && sudo apt upgrade -y

# Install core build dependencies and networking utilities
sudo apt install -y build-essential gcc g++ make git git-lfs python3 python3-pip \
lsb-release net-tools curl wget universal-ctags

# Inject legacy 32-bit and 64-bit graphical rendering libraries required by Vivado
sudo apt install -y libtinfo5 libncurses5 libncursesw5 libxrender1 libxtst6 \
libxi6 libxft2 libfontconfig1 libx11-6 libxext6 libtinfo-dev
```

### Step 3: Install Open-Source Verification Engines

Install the static analysis tool and external waveform processing suite directly from the native advanced package manager:

```bash
sudo apt install -y gtkwave verilator
```

---

## Part 3: IDE & Software Installation

### Step 1: Install Visual Studio Code (VS Code)

Execute this sequence to clear out potential translation errors, sign Microsoft's validation repository key, and install the application safely via your terminal:

```bash
# Clean out any conflicting, legacy, or translated repository assets
sudo rm -f /etc/apt/sources.list.d/vscode.list

# Fetch and secure the official Microsoft GPG signature key
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/packages.microsoft.gpg > /dev/null

# Register the stable corporate repository tracking pathway
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'

# Refresh registries and install the code binary package
sudo apt update
sudo apt install -y code
```

### Step 2: Extract and Launch the Vivado Installer

Ensure you have downloaded the official Linux installer file (`FPGAs_AdaptiveSoCs_Unified_2024.2_1113_2356_Lin64.bin`) inside your local directory.

```bash
cd ~/Downloads

# Grant executable permission flags to the installer binary file
chmod +x FPGAs_AdaptiveSoCs_Unified_2024.2_1113_2356_Lin64.bin

# Pre-build target installation pathways and assume administrative directory ownership
sudo mkdir -p /tools/Xilinx
sudo chown -R $USER:$USER /tools/Xilinx

# Launch the visual deployment installation wizard
./FPGAs_AdaptiveSoCs_Unified_2024.2_1113_2356_Lin64.bin
```

**Complete the Installer GUI Selections:**

- **Credentials:** Authenticate utilizing your registered AMD/Xilinx Account details.
- **Product:** Select **Vivado**.
- **Edition:** Select **Vivado ML Standard Edition** (License-Free platform).
- **Customization Panel:** Under Design Devices, uncheck enterprise arrays (e.g., UltraScale+, Versal) to reclaim ~40 GB of storage capacity. Keep Vivado Simulator (XSim) checked.
- **Path:** Set destination explicitly to `/tools/Xilinx` and run the process.

### Step 3: Configure Hardware Level Drivers

Once the installation updates terminate, deploy the hardware interaction rules to handle physical target debugging later:

```bash
cd /tools/Xilinx/Vivado/2024.2/data/xicom/cable_drivers/lin64/install_script/install_drivers/
sudo ./install_drivers
```

---

## Part 4: Tool Environment Configuration

To automate variable mapping and establish your workspace directories, configure your terminal shell:

### Step 1: Bind System Variables to Bash

Open your shell runtime file using nano:

```bash
nano ~/.bashrc
```

Scroll to the absolute bottom of the configuration file and add these definitions:

```bash
# ==============================================================================
# AMD Vivado 2024.2 & EDA Verification Toolchain Mapping Configuration
# ==============================================================================
source /tools/Xilinx/Vivado/2024.2/settings64.sh
alias vsim="vivado -mode gui &"
```

Save and exit (`Ctrl + O`, `Enter`, `Ctrl + X`). Reload the bash engine parameters immediately:

```bash
source ~/.bashrc
```

### Step 2: Establish the Project Workspace Layout

Execute the automated layout script to configure the 1st project directory system in strict compliance with the IP Reuse structural portfolio plan:

```bash
mkdir -p ~/workspace/rtl-dv-portfolio/sv-common-ip-library
cd ~/workspace/rtl-dv-portfolio/sv-common-ip-library

# Create core project-wide foundation infrastructures
mkdir -p docs scripts common/packages common/interfaces common/macros common/assertions

# Build out targeted individual sub-block engineering layout directories
IP_LIST=(
    "foundation/clock_divider" "foundation/reset_sync" "foundation/edge_detector"
    "foundation/pulse_sync" "foundation/two_flop_sync" "foundation/toggle_sync"
    "foundation/handshake_sync" "foundation/counter_lib/basic_counter"
    "foundation/counter_lib/up_down_counter" "foundation/counter_lib/gray_counter"
    "memory/register_file" "memory/single_port_ram" "memory/dual_port_ram"
    "memory/sync_fifo" "memory/async_fifo"
    "datapath/priority_encoder" "datapath/arbiter_fixed" "datapath/arbiter_round_robin"
    "datapath/gray_to_bin" "datapath/crc_generator"
)

for ip in "${IP_LIST[@]}"; do
    mkdir -p "$ip"/{rtl,tb,sim,docs}
    touch "$ip"/Makefile
done

# Initialize essential baseline engineering workspace targets
touch README.md LICENSE .gitignore Makefile
```

---

## Part 5: Secure GitHub Authentication Flow

Initialize your terminal interaction protocol to establish secure connectivity with GitHub without exposing plain text passwords:

### Step 1: Establish Git Identity Contexts

Stamp your name and tracking email address onto all current and future commits globally:

```bash
git config --global user.name "Your Global Profile Name"
git config --global user.email "your_professional_email@example.com"
```

### Step 2: Generate an Asymmetric ed25519 Cryptographic SSH Key

```bash
ssh-keygen -t ed25519 -C "your_professional_email@example.com"
```

> **Note:** Hit Enter to confirm the default storage pathways. Leave the passphrase entry empty if you want seamless terminal push interactions.

### Step 3: Link Public Keys to Your GitHub Profile

Print the generated public verification string directly onto your console output and copy it:

```bash
cat ~/.ssh/id_ed25519.pub
```

Open your web browser, navigate to your GitHub Settings Page, select **SSH and GPG keys**, and click **New SSH key**.

Label the key as `Home Verification Linux VM`, paste the entire copied key structure into the field, and click **Add SSH key**.

Run this confirmation challenge target to ensure your terminal pipelines authenticate perfectly:

```bash
ssh -T git@github.com
```

---

## Part 6: Visual Studio Code Development Suite

Launch VS Code from your shell command line inside the portfolio home folder:

```bash
cd ~/workspace/rtl-dv-portfolio/sv-common-ip-library
code .
```

Open the Extensions Market (`Ctrl + Shift + X`) and install these tools to complete your development environment:

| Extension                                         | Purpose                                                                                                                                                                                                                                                                                 |
| ------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **SystemVerilog - Language Support** (by mshr-h)  | Handles file index maps, structural outline parsing, auto-completions, and syntax highlight rendering for SystemVerilog class frameworks and macros.                                                                                                                                    |
| **Verilog-HDL/SystemVerilog/Chisel** (by LeafXia) | Instantly connects your editor interface workspace to background compilers. Go into your preferences page (`Ctrl + ,`), look up `verilog.linting.linter`, and set it explicitly to `verilator`. This surfaces syntax warnings directly inside the editor screen.                        |
| **Verible** (by Google)                           | Employs strict automatic alignment rules for ports, signals, parameter parameters, and indentation layouts.                                                                                                                                                                             |
| **Draw.io Integration** (by Henning Dieterichs)   | Enables a visual diagram editor directly inside the editor pane when working with vector assets. Save files utilizing the dual extension rule: `*.drawio.svg`. This allows VS Code to render a drawing canvas while rendering a clean image asset inside web engines or markdown views. |
| **vscode-icons** (by VS Code Icons Team)          | Adds recognizable icons to your project explorer list, distinguishing `.sv` components, Makefiles, and documentation folders visually.                                                                                                                                                  |

---

## Part 7: Verification Smoke Test

Execute this test loop to ensure your code compilers, syntax linters, simulators, automation engines, and waveform viewers are fully operational.

### 1. Build a Dummy Component Module

Create a temporary working folder:

```bash
mkdir -p ~/workspace/rtl-dv-portfolio/smoke_test
cd ~/workspace/rtl-dv-portfolio/smoke_test
```

Create an 8-bit counter module named `counter.sv`:

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

Create a matching test verification driver module named `counter_tb.sv`:

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
        $display("[SMOKE TEST SUCCESS] Simulation completed safely. Counter final output value: %d", count);
        $finish;
    end
endmodule
```

### 2. Execute the Validation Checklist Commands

Run your verification tools manually in sequence to confirm execution matches the expected baseline outputs:

```bash
# Check 1: Verify Static Linter Compilation Engine (Must exit with zero output logs)
verilator --lint-only -Wall counter.sv

# Check 2: Parse SystemVerilog Verification Source Files
xvlog -sv counter.sv counter_tb.sv

# Check 3: Synthesize and Elaborate the Test Snapshot Structure
xelab counter_tb -s smoke_snapshot

# Check 4: Simulate the Compiled Netlist Core Snapshot File
xsim smoke_snapshot -runall
```

**Expected Simulation Terminal Output:**

```
[SMOKE TEST SUCCESS] Simulation completed safely. Counter final output value: 19
```

```bash
# Check 5: Fire up the External Vector Waveform Display Engine
gtkwave waveform.vcd &
```

Verify that the interactive GTKWave user interface panel displays. Drag the internal count signal vectors across your black tracking matrix workspace window pane to visually confirm operation from 0 to 19.

---

Your modern digital verification environment is now certified, automated, and ready to host your silicon portfolio development! You can safely delete your temporary `smoke_test` directory and begin engineering your Phase 0 infrastructure blocks.
