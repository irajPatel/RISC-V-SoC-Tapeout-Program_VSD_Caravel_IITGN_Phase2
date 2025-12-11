# Caravel HK SPI (Housekeeping SPI) Comprehensive Guide

## Table of Contents
1. [Step 2: Understanding the HK SPI Test](#step-2-understanding-the-hk-spi-test)
2. [Step 3: Running RTL Simulation](#step-3-running-rtl-simulation-detailed)
3. [Complete File Structure](#complete-file-structure)

---

# Step 2: Understanding the HK SPI Test

## 2.1 Overview: What is HK SPI?

**HK SPI** stands for **Housekeeping SPI** - it's a special communication interface in the Caravel chip that allows external users to control and read various configuration and status registers inside the Caravel chip without directly accessing the chip's main processor or user project area.

Think of it like a **"backdoor"** interface:
- The management SoC (System on Chip) inside Caravel uses this SPI interface to send commands
- External testers use this interface to read chip ID, manufacturer ID, and other status registers
- It can also be used in "pass-through" mode to access Flash memory

### Key Concept:
The HK SPI acts as a **bridge** between:
- **External world** (tester equipment via SPI pins) ↔ **Caravel internals** (management SoC) ↔ **User Project**

---

## 2.2 File 1: The Testbench
**Full Path:** `/home/iraj/VLSI/caravel/verilog/dv/caravel/mgmt_soc/hkspi/hkspi_tb.v`

### What is a Testbench?
A testbench is a Verilog file that simulates the **external equipment** that talks to the chip. It's like a virtual testing machine.

### Structure of hkspi_tb.v:

#### **Section 1: Header & Includes (Lines 1-27)**
```verilog
`timescale 1 ns / 1 ps
`include "__uprj_netlists.v"
`include "caravel_netlists.v"
`include "spiflash.v"
`include "tbuart.v"
```
**Explanation:**
- `timescale`: Sets simulation time units (1 nanosecond precision, 1 picosecond step)
- Includes reference to Caravel's netlists (the actual chip design files)
- Includes a simulated SPI Flash memory (`spiflash.v`)
- Includes a UART (serial port) simulator (`tbuart.v`)

#### **Section 2: Module Declaration & Signal Wires (Lines 27-50)**
```verilog
module hkspi_tb;
    reg clock;
    reg SDI, CSB, SCK, RSTB;
    reg power1, power2;
    
    wire gpio;
    wire [15:0] checkbits;
    wire [37:0] mprj_io;
    wire uart_tx, uart_rx;
    wire flash_csb, flash_clk;
    wire flash_io0, flash_io1, flash_io2, flash_io3;
    wire SDO;
```

**What each signal means:**
| Signal | Type | Purpose |
|--------|------|---------|
| `clock` | Input (reg) | 20 ns clock period (toggling every 10 ns) |
| `SDI` | Input (reg) | Serial Data In - data we send to the chip |
| `SCK` | Input (reg) | Serial Clock - synchronizes SPI communication |
| `CSB` | Input (reg) | Chip Select Bar (active LOW) - enables SPI |
| `RSTB` | Input (reg) | Reset Bar (active LOW) - resets the chip |
| `power1, power2` | Input (reg) | Power supplies (3.3V and 1.8V) |
| `SDO` | Output (wire) | Serial Data Out - data from the chip |
| `mprj_io[37:0]` | Output (wire) | User project I/O pins (38 pins) |

#### **Section 3: Clock & Power-Up Sequence (Lines 52-63)**
```verilog
always #10 clock <= (clock === 1'b0);  // Toggle clock every 10ns

initial begin
    power1 <= 1'b0;
    power2 <= 1'b0;
    #200;           // Wait 200 ns
    power1 <= 1'b1; // Turn on 3.3V
    #200;           // Wait 200 ns
    power2 <= 1'b1; // Turn on 1.8V
end
```

**What happens:**
1. Clock alternates between 0 and 1 every 10 nanoseconds (20 ns period)
2. Power supplies are turned on gradually (simulating realistic power-up)
3. This avoids damaging the virtual chip

#### **Section 4: SPI Helper Tasks (Lines 65-125)**
These are **subroutines** that perform common SPI operations:

**Task 1: start_csb()**
```verilog
task start_csb;
    begin
        SCK <= 1'b0;
        SDI <= 1'b0;
        CSB <= 1'b0;  // Pull CSB LOW to enable SPI
        #50;          // Wait 50 ns
    end
endtask
```
**What it does:** Enables SPI communication by pulling CSB (Chip Select) LOW

**Task 2: end_csb()**
```verilog
task end_csb;
    begin
        SCK <= 1'b0;
        SDI <= 1'b0;
        CSB <= 1'b1;  // Pull CSB HIGH to disable SPI
        #50;          // Wait 50 ns
    end
endtask
```
**What it does:** Disables SPI communication by pulling CSB HIGH

**Task 3: write_byte()**
```verilog
task write_byte;
    input [7:0] odata;
    begin
        SCK <= 1'b0;
        for (i=7; i >= 0; i--) begin
            #50;
            SDI <= odata[i];      // Set data bit
            #50;
            SCK <= 1'b1;          // Clock pulse
            #100;
            SCK <= 1'b0;          // Clock back to 0
        end
    end
endtask
```
**What it does:**
- Sends one byte (8 bits) to the chip
- Sends MSB (Most Significant Bit) first
- Each bit takes 200 ns (50ns delay + 100ns clock pulse + 50ns)

**Task 4: read_byte()**
```verilog
task read_byte;
    output [7:0] idata;
    begin
        SCK <= 1'b0;
        SDI <= 1'b0;
        for (i=7; i >= 0; i--) begin
            #50;
            idata[i] = SDO;       // Read one bit from SDO
            #50;
            SCK <= 1'b1;          // Clock pulse
            #100;
            SCK <= 1'b0;
        end
    end
endtask
```
**What it does:**
- Reads one byte (8 bits) from the chip
- Reads MSB first
- Captures the bit on output line SDO

#### **Section 5: Main Test Sequence (Lines 146+)**

```verilog
initial begin
    $dumpfile("hkspi.vcd");      // Save waveforms to hkspi.vcd
    $dumpvars(0, hkspi_tb);       // Dump all variables
    
    CSB <= 1'b1;
    SCK <= 1'b0;
    SDI <= 1'b0;
    RSTB <= 1'b0;                // Hold in reset initially
    
    #1000;
    RSTB <= 1'b1;                // Release reset after 1000 ns
    #2000;
```

**What it does:** Initialize all signals and wait for chip to power up

**Then it performs actual tests:**

```verilog
// TEST 1: Read Product ID from Register 3
start_csb();
write_byte(8'h40);    // Command: Read stream (0100 0000)
write_byte(8'h03);    // Address: Register 3 (product ID)
read_byte(tbdata);    // Read the value
end_csb();
$display("Read data = 0x%02x (should be 0x11)", tbdata);
```

**Breaking this down:**

| Command | Meaning | Binary |
|---------|---------|--------|
| `0x40` | Read Command (Read stream mode) | `01000000` |
| `0x03` | Register 3 (Product ID location) | `00000011` |

**Expected return:** `0x11` (17 in decimal - Caravel product ID)

**TEST 2: Read ALL Registers (0-18)**

```verilog
start_csb();
write_byte(8'h40);    // Read stream command
write_byte(8'h00);    // Start from register 0
read_byte(tbdata);    // Read register 0

$display("Read register 0 = 0x%02x (should be 0x00)", tbdata);
if(tbdata !== 8'h00) begin 
    `ifdef GL
        $display("Monitor: Test HK SPI (GL) Failed"); 
        $finish; 
    `else
        $display("Monitor: Test HK SPI (RTL) Failed"); 
        $finish; 
    `endif
end
```

This reads register 0 and **verifies it equals 0x00**. If not, test fails.

**The test reads registers 0-18 and expects these values:**

| Register | Expected Value | Meaning |
|----------|---|---------|
| 0 | 0x00 | Reserved/flags |
| 1 | 0x04 | Manufacturer ID (low 8 bits) |
| 2 | 0x56 | Manufacturer ID (high 4 bits) |
| 3 | 0x11 | Product ID |
| 4-7 | 0x00 | Mask ID (32 bits) |
| 8 | 0x02 | User config |
| 9 | 0x01 | User config |
| 10-12 | 0x00 | Reserved |
| 13 | 0xFF | GPIO defaults |
| 14 | 0xEF | GPIO defaults |
| 15 | 0xFF | GPIO defaults |
| 16 | 0x03 | GPIO defaults |
| 17 | 0x12 | GPIO defaults |
| 18 | 0x04 | GPIO defaults |

**TEST 3: Toggle External Reset**

```verilog
start_csb();
write_byte(8'h80);    // Command: Write stream (1000 0000)
write_byte(8'h0b);    // Address: Register 11 (external reset)
write_byte(8'h01);    // Data: 0x01 (assert reset)
end_csb();

start_csb();
write_byte(8'h80);    // Write command
write_byte(8'h0b);    // Register 11
write_byte(8'h00);    // Data: 0x00 (release reset)
end_csb();
```

**What this does:** Tests the ability to reset the chip via SPI

#### **Section 6: Instantiate the Caravel Chip (Lines 395-425)**

```verilog
caravel uut (
    .vddio    (VDD3V3),
    .vssio    (VSS),
    .vdda     (VDD3V3),
    .vssa     (VSS),
    .vccd     (VDD1V8),
    .vssd     (VSS),
    .vdda1    (VDD3V3),
    .vdda2    (VDD3V3),
    .vssa1    (VSS),
    .vssa2    (VSS),
    .vccd1    (VDD1V8),
    .vccd2    (VDD1V8),
    .vssd1    (VSS),
    .vssd2    (VSS),
    .clock    (clock),
    .gpio     (gpio),
    .mprj_io  (mprj_io),
    .flash_csb(flash_csb),
    .flash_clk(flash_clk),
    .flash_io0(flash_io0),
    .flash_io1(flash_io1),
    .resetb   (RSTB)
);
```

**What it does:** This creates a virtual instance of the Caravel chip and connects all the signals from the testbench to it.

**Signal connections:**
- Power pins (vddio, vccd, vdda) → simulated 3.3V and 1.8V
- Clock → testbench clock
- Reset (RSTB) → testbench reset
- mprj_io → user project I/O pins

#### **Section 7: Flash Memory Simulation (Lines 427-432)**

```verilog
spiflash #(
    .FILENAME("hkspi.hex")
) spiflash (
    .csb(flash_csb),
    .clk(flash_clk),
    .io0(flash_io0),
    .io1(flash_io1),
    .io2(),
    .io3()
);
```

**What it does:**
- Simulates a SPI Flash memory chip
- Loads data from `hkspi.hex` file (this is the firmware/test program binary)
- Connected to Caravel's flash pins

---

## 2.3 File 2: Housekeeping SPI Module (RTL)
**Full Path:** `/home/iraj/VLSI/caravel/verilog/rtl/housekeeping_spi.v`

### What is this file?
This is the **actual implementation** of the HK SPI controller inside the Caravel chip. It handles incoming SPI commands and produces output data.

### Module Interface (Lines 57-75):

```verilog
module housekeeping_spi(
    reset,                      // Reset signal
    SCK,                        // Serial Clock IN
    SDI,                        // Serial Data IN
    CSB,                        // Chip Select Bar IN
    SDO,                        // Serial Data OUT
    sdoenb,                     // Serial Data Output Enable (active LOW)
    idata,                      // Input: Data from registers to send out
    odata,                      // Output: Data received from SPI
    oaddr,                      // Output: Address of register being accessed
    rdstb,                      // Output: Read strobe (tells when to latch read data)
    wrstb,                      // Output: Write strobe (tells when to latch write data)
    pass_thru_mgmt,             // Output: Pass-through mode for management SPI
    pass_thru_mgmt_delay,       // Output: Delayed version
    pass_thru_user,             // Output: Pass-through mode for user SPI
    pass_thru_user_delay,       // Output: Delayed version
    pass_thru_mgmt_reset,       // Output: Reset signal
    pass_thru_user_reset        // Output: Reset signal
);
```

### How it works - State Machine:

The module uses a **state machine** (similar to a traffic light) to track where in the SPI transaction it is:

```verilog
`define COMMAND  3'b000    // State 0: Receiving command byte
`define ADDRESS  3'b001    // State 1: Receiving address byte
`define DATA     3'b010    // State 2: Receiving/sending data byte
`define USERPASS 3'b100    // State 3: Pass-through to user flash
`define MGMTPASS 3'b101    // State 4: Pass-through to management flash
```

### The Command Format (Lines 32-55):

```
Byte 1: Command (8 bits)
Byte 2: Address (8 bits)
Byte 3: Data (8 bits)
```

**Command Byte Format:**
```
Bit 7     Bit 6     Bits 5-3   Bits 2-0
Write?    Read?     Flags      Length
  w         r       [reserved]  [000=stream, 1-7=fixed count]
```

**Examples:**
- `0x40` = `01000000` → Read stream mode
- `0x80` = `10000000` → Write stream mode
- `0xC0` = `11000000` → Read/Write simultaneous
- `0xC4` = `11000100` → Pass-through to management flash
- `0xC2` = `11000010` → Pass-through to user flash

### Key Logic - Receiving Data (Lines 152-210):

```verilog
always @(posedge SCK or posedge csb_reset) begin
    if (csb_reset == 1'b1) begin
        // Reset all state
        addr <= 8'h00;
        rdstb <= 1'b0;
        state <= `COMMAND;
        count <= 3'b000;
    end else begin
        // Process one bit per clock
        
        if (state == `COMMAND) begin
            count <= count + 1;
            if (count == 3'b000) 
                writemode <= SDI;      // Bit 7: Write bit
            else if (count == 3'b001) 
                readmode <= SDI;       // Bit 6: Read bit
            // ... process remaining bits
            
            if (count == 3'b111)       // After 8 bits
                state <= `ADDRESS;     // Move to address state
        end
        
        else if (state == `ADDRESS) begin
            count <= count + 1;
            addr <= {addr[6:0], SDI};  // Shift in address bits
            
            if (count == 3'b111) begin // After 8 bits
                state <= `DATA;        // Move to data state
                if (readmode == 1'b1) 
                    rdstb <= 1'b1;     // Signal: "Get ready to read!"
            end
        end
        
        else if (state == `DATA) begin
            predata <= {predata[6:0], SDI};  // Shift in data bits
            count <= count + 1;
            
            if (count == 3'b111) begin // After 8 bits
                // Check if this was a fixed-length transaction
                if (fixed == 3'b001) 
                    state <= `COMMAND;  // Back to command state
                else if (fixed != 3'b000) 
                    fixed <= fixed - 1; // Decrement counter
                
                addr <= addr + 1;       // Auto-increment address
                if (readmode == 1'b1) 
                    rdstb <= 1'b1;      // Signal: "New data ready to read!"
            end
        end
    end
end
```

### Key Logic - Sending Data (Lines 119-150):

```verilog
always @(negedge SCK or posedge csb_reset) begin
    if (csb_reset == 1'b1) begin
        wrstb <= 1'b0;
        ldata <= 8'b00000000;
        sdoenb <= 1'b1;           // Disable output initially
    end else begin
        
        if (state == `DATA) begin
            if (readmode == 1'b1) begin
                sdoenb <= 1'b0;        // Enable output
                if (count == 3'b000) 
                    ldata <= idata;    // Load new byte
                else 
                    ldata <= {ldata[6:0], 1'b0};  // Shift out
            end
        end
    end
end
```

**What this does:**
- On the falling edge of SCK, shift the next bit onto SDO
- This ensures data is stable when SCK rises (when receiver reads it)

---

## 2.4 File 3: HK SPI Hex File (Firmware)
**Expected Path:** `/home/iraj/VLSI/caravel/verilog/dv/caravel/mgmt_soc/hkspi/hkspi.hex`

### What is this file?
This is a **compiled binary** of the firmware that runs inside the management SoC during the test. It's in Intel HEX format (human-readable hexadecimal).

### How it's created:

The file path in the Makefile shows:
```makefile
%.hex: %.elf
	${GCC_PATH}/${GCC_PREFIX}-objcopy -O verilog $< $@ 
	sed -i 's/@10000000/@00000000/g' $@
```

This means:
1. Start with `hkspi.c` (source code)
2. Compile with RISC-V GCC: `hkspi.c` → `hkspi.elf` (binary)
3. Convert to hex format: `hkspi.elf` → `hkspi.hex`
4. Fix base address (change @10000000 to @00000000)

### The hkspi.c program:

Looking at `/home/iraj/VLSI/caravel/verilog/dv/caravel/mgmt_soc/hkspi/hkspi.c`:

```c
void main() {
    // This program keeps the processor busy while the
    // housekeeping SPI is being accessed, to show that the
    // processor is interrupted only when the reset is applied
    // through the SPI.
    
    // Configure I/O:
    // - High 16 bits of mprj_io used for a 16-bit status word
    // - Serial Tx connects to mprj_io[6]
    // - I/O configured for output
}
```

**What it does:**
- Runs on the management SoC RISC-V processor
- Configures GPIO pins for output
- Enables UART (serial) output
- Stays in a loop while SPI tests access the housekeeping registers

---

## 2.5 How Everything Interconnects

### Data Flow Diagram:

```
┌─────────────────────────────────────────────────────────────────┐
│  EXTERNAL TESTER (in testbench hkspi_tb.v)                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Generates SPI signals: SCK, SDI, CSB, RSTB              │  │
│  │ Reads response on: SDO                                  │  │
│  │ Runs test tasks: write_byte(), read_byte()              │  │
│  └────────────────────────┬─────────────────────────────────┘  │
└───────────────────────────┼────────────────────────────────────┘
                            │
                    ┌───────▼────────────┐
                    │  CARAVEL CHIP      │
                    │  (caravel module)  │
                    └───────┬────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ▼                   ▼                   ▼
   ┌─────────────┐  ┌──────────────┐  ┌──────────────┐
   │ HK SPI Ctrl │  │ Management   │  │ User Project │
   │ (hkspi.v)   │  │ SoC (Picorv) │  │ Wrapper      │
   │             │  │              │  │              │
   │ Receives:   │  │ Runs:        │  │ Receives:    │
   │ SCK, SDI    │  │ hkspi.c      │  │ Signals from │
   │ CSB, RSTB   │  │              │  │ Management   │
   │             │  │ Reads/Writes │  │              │
   │ Sends:      │  │ hkspi regs   │  │              │
   │ SDO         │  │              │  │              │
   └─────────────┘  └──────────────┘  └──────────────┘
```

### Interaction Sequence:

**Time 0-1000 ns:** Power-up
```
1. power1 = 0V, power2 = 0V
2. RSTB = 0 (chip in reset)
3. Clock starts toggling
   ↓
   (200 ns later)
4. power1 = 3.3V (analog core powered)
5. power2 = 1.8V (digital core powered)
   ↓
   (1000 ns total)
6. RSTB = 1 (chip released from reset)
7. Management SoC boots up and starts executing hkspi.c
```

**Time 1000-3000 ns:** Chip initialization
```
1. Management SoC initializes GPIO, UART
2. Flash memory (hkspi.hex) loads into execution space
3. Caravel is now ready for external SPI commands
```

**Time 3000+ ns:** Test execution
```
1. Testbench pulls CSB LOW (SPI enabled)
2. Testbench sends command byte (8 bits): 0x40 (read)
   → HK SPI receives on SDI, advances state to ADDRESS
3. Testbench sends address byte (8 bits): 0x00 (register 0)
   → HK SPI advances state to DATA
4. Testbench sends dummy byte, receives data byte
   → HK SPI checks readmode, outputs register value on SDO
5. Testbench reads value and compares with expected
6. CSB pulled HIGH to end transaction
7. Repeat for all registers 0-18
```

### How the HK SPI "knows" what to return:

1. **When reading (readmode=1):**
   - HK SPI module has `idata` input (from external registers)
   - When a read is requested, it latches `idata` into `ldata`
   - Then shifts `ldata` bits onto `SDO` one by one
   - Each register (0-18) has hardcoded values

2. **When writing (writemode=1):**
   - HK SPI module receives bits on `SDI`
   - Assembles them into `odata` output byte
   - Asserts `wrstb` (write strobe) to latch the data
   - External circuit receives the data and updates registers

---

## 2.6 Summary: One-Page Technical Overview

### What is HK SPI?
The Housekeeping SPI is a **low-level control interface** built into the Caravel chip. It allows external testers or equipment to:
- Read chip identification (Manufacturer ID, Product ID, Mask ID)
- Read status registers (GPIO defaults, user configuration)
- Write control registers (external reset, configuration)
- Access Flash memory in pass-through mode

### Why is it important?
Without HK SPI, there would be no way to access the management SoC registers or reset the chip externally. It's the **only external interface** to chip control logic.

### How does it communicate?
HK SPI uses **Serial Peripheral Interface (SPI)** protocol:
- **SCK:** Clock signal (synchronizes communication)
- **SDI:** Serial Data In (commands and data to chip)
- **SDO:** Serial Data Out (responses from chip)
- **CSB:** Chip Select (LOW=active, HIGH=inactive)

**Data Format:**
1. **Command byte** (1st): Specifies read/write/pass-through and count
2. **Address byte** (2nd): Which register to access (0-255)
3. **Data byte** (3rd+): Value to read or write

### Where is it implemented?
- **Controller:** `/home/iraj/VLSI/caravel/verilog/rtl/housekeeping_spi.v` - The hardware that receives SPI commands
- **Testbench:** `/home/iraj/VLSI/caravel/verilog/dv/caravel/mgmt_soc/hkspi/hkspi_tb.v` - Simulates the external tester
- **Firmware:** `/home/iraj/VLSI/caravel/verilog/dv/caravel/mgmt_soc/hkspi/hkspi.c` - Runs on the management SoC while test is active

### Register Map (what each address contains):
| Reg | Name | Value | Purpose |
|-----|------|-------|---------|
| 0 | Flags | 0x00 | Status flags (reserved) |
| 1-2 | Mfg ID | 0x0456 | Efabless manufacturer ID |
| 3 | Product ID | 0x11 | Caravel chip ID |
| 4-7 | Mask ID | 0x00 | Mask revision ID |
| 8-12 | Config | 0x02,0x01,0x00... | User configuration |
| 13-18 | GPIO | 0xFF,0xEF,0xFF... | GPIO pin defaults |

---

# Step 3: Running RTL Simulation (Detailed)

## 3.1 What is RTL Simulation?

**RTL** = **Register Transfer Level** - This is the actual source code (Verilog) implementation of the chip design.

**Simulation** = Running the design in software to verify it works before manufacturing.

### The Simulation Process:

```
Verilog Source Code → Compiler (iverilog) → Machine Code → Simulator (vvp) → Output
```

It's like:
1. You write a program in Verilog
2. A compiler translates it to binary
3. A simulator executes it (like running a program)
4. You see the results in the console

---

## 3.2 Environment Setup (Prerequisites)

Before running the simulation, you need these tools installed:

### **Check if tools are installed:**

Open a terminal and run:

```bash
# Check if iverilog is installed
which iverilog

# Check if vvp is installed
which vvp

# Check if verilator is installed (optional for this test)
which verilator
```

**Expected output (example):**
```
/usr/bin/iverilog
/usr/bin/vvp
/usr/bin/verilator
```

If any tool is missing, install it:

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y iverilog verilator

# CentOS/RHEL
sudo yum install -y iverilog verilator

# macOS
brew install icarus-verilog verilator
```

### **Check if PDK is installed:**

The PDK (Process Design Kit) contains standard cell definitions needed for simulation.

```bash
# Check PDK_ROOT environment variable
echo $PDK_ROOT

# List available PDKs
ls -la $PDK_ROOT/
```

You should see something like:
```
/path/to/pdk
├── sky130A
├── sky130B
└── ...
```

If not set, add to `~/.bashrc`:
```bash
export PDK_ROOT=$HOME/pdk
export PDK=sky130A
```

Then reload:
```bash
source ~/.bashrc
```

---

## 3.3 Step-by-Step RTL Simulation

### **Step 1: Navigate to Test Directory**

```bash
cd /home/iraj/VLSI/caravel/verilog/dv/caravel/mgmt_soc/hkspi/
```

**What you should see:**
```
hkspi_tb.v          # The testbench
hkspi.c             # The firmware source
Makefile            # Instructions for building
```

### **Step 2: Check the Makefile**

```bash
cat Makefile | head -40
```

**Key sections:**
```makefile
PATTERN = hkspi          # The test name
SIM?=RTL                 # Use RTL simulation (not gate-level)
%.vvp: %_tb.v %.hex     # Rule to build .vvp from testbench
%.vcd: %.vvp            # Rule to run simulation and generate waveforms
```

### **Step 3: Build the Hex File (Firmware Binary)**

The Makefile needs to compile `hkspi.c` into `hkspi.hex` first.

```bash
cd /home/iraj/VLSI/caravel/verilog/dv/caravel/mgmt_soc/hkspi/

# Check if GCC_PATH is set
echo $GCC_PATH
echo $GCC_PREFIX
```

If not set, configure:
```bash
# Find where RISC-V GCC is installed
find ~ -name "riscv32-unknown-elf-gcc" 2>/dev/null

# If found, set the paths
export GCC_PATH=/path/to/compiler/bin
export GCC_PREFIX=riscv32-unknown-elf

# Example (common location):
export GCC_PATH=/opt/riscv/bin
export GCC_PREFIX=riscv32-unknown-elf
```

Now build the hex file:
```bash
make hex
```

**What happens:**
1. Compiles `hkspi.c` → `hkspi.elf`
2. Converts binary → `hkspi.hex`
3. Should print: `sed -i 's/@10000000/@00000000/g' hkspi.hex`

**Verify it worked:**
```bash
ls -lh hkspi.*

# Expected output:
# hkspi.c      (original C code)
# hkspi.elf    (compiled binary)
# hkspi.hex    (hexadecimal format for simulation)
```

### **Step 4: Compile the Testbench with iverilog**

The Makefile rule for compilation:
```makefile
%.vvp: %_tb.v %.hex
    iverilog -Ttyp $(SIM_DEFINES) -I $(BEHAVIOURAL_MODELS) \
    -I $(PDK_PATH) -I $(RTL_PATH) -I $(MGMT_WRAPPER_PATH) \
    $< -o $@
```

Run it:
```bash
cd /home/iraj/VLSI/caravel/verilog/dv/caravel/mgmt_soc/hkspi/

make hkspi.vvp
```

**What `iverilog` does:**
- `-Ttyp`: Target = typical timing (not worst/best case)
- `-DFUNCTIONAL -DSIM`: Define these preprocessor flags
- `-I`: Include paths for finding dependencies
- `hkspi_tb.v`: The testbench source
- `-o hkspi.vvp`: Output file (compiled simulation)

**Expected output:**
```
(mostly silent if successful)
```

**Verify compilation:**
```bash
ls -lh hkspi.vvp

# Expected: a file a few MB in size
# Example output:
# -rw-r--r-- 1 user user 4.2M Nov 15 14:23 hkspi.vvp
```

### **Step 5: Run the Simulation with vvp**

Now execute the compiled simulation:

```bash
cd /home/iraj/VLSI/caravel/verilog/dv/caravel/mgmt_soc/hkspi/

vvp hkspi.vvp
```

**What happens:**
1. vvp loads the compiled simulation
2. Executes the testbench logic
3. Prints messages to console
4. Generates `hkspi.vcd` (waveform file)

**Expected console output:**
```
Read data = 0x11 (should be 0x11)
Read register 0 = 0x00 (should be 0x00)
Read register 1 = 0x04 (should be 0x04)
Read register 2 = 0x56 (should be 0x56)
Read register 3 = 0x11 (should be 0x11)
Read register 4 = 0x00 (should be 0x00)
Read register 5 = 0x00 (should be 0x00)
Read register 6 = 0x00 (should be 0x00)
Read register 7 = 0x00 (should be 0x00)
Read register 8 = 0x02 (should be 0x02)
Read register 9 = 0x01 (should be 0x01)
Read register 10 = 0x00 (should be 0x00)
Read register 11 = 0x00 (should be 0x00)
Read register 12 = 0x00 (should be 0x00)
Read register 13 = 0xff (should be 0xff)
Read register 14 = 0xef (should be 0xef)
Read register 15 = 0xff (should be 0xff)
Read register 16 = 0x03 (should be 0x03)
Read register 17 = 0x12 (should be 0x12)
Read register 18 = 0x04 (should be 0x04)
Monitor: Test HK SPI (RTL) Passed
```

**The last line is CRITICAL:**
```
Monitor: Test HK SPI (RTL) Passed
```

This indicates **all register values matched expectations**.

### **Step 6: Capture Output to Log File**

Save the complete output for later analysis:

```bash
cd /home/iraj/VLSI/caravel/verilog/dv/caravel/mgmt_soc/hkspi/

vvp hkspi.vvp 2>&1 | tee rtl_hkspi.log
```

**Breaking this down:**
- `vvp hkspi.vvp`: Run the simulation
- `2>&1`: Capture errors (stderr) and normal output (stdout)
- `tee rtl_hkspi.log`: Display AND save to file

**Verify the log file:**
```bash
cat rtl_hkspi.log
# Should see the same output as before
```

### **Step 7: Examine the Waveform File (Optional)**

The simulation generates `hkspi.vcd` (Value Change Dump):

```bash
ls -lh hkspi.vcd

# Expected: several MB file
# Example:
# -rw-r--r-- 1 user user 12M Nov 15 14:25 hkspi.vcd
```

**To view the waveform (requires GUI tool):**
```bash
# Install gtkwave (waveform viewer)
sudo apt-get install gtkwave

# View the signals
gtkwave hkspi.vcd &
```

This shows:
- All signal changes over time
- Clock, SCK, SDI, SDO waveforms
- Power supply changes
- State machine transitions

---

## 3.4 Troubleshooting RTL Simulation

### **Problem 1: "iverilog: command not found"**
**Solution:**
```bash
sudo apt-get install iverilog
```

### **Problem 2: "Cannot find file __uprj_netlists.v"**
**Solution:** Check PDK_ROOT is set:
```bash
echo $PDK_ROOT
# If empty, set it:
export PDK_ROOT=$HOME/pdk
```

### **Problem 3: "Test HK SPI (RTL) Failed"**
**Cause:** A register value didn't match expected

**To debug:**
1. Check which register failed (from log output)
2. Modify `hkspi_tb.v` to print more debug info:
   ```verilog
   $display("Register %d value: 0x%02x", register_num, tbdata);
   ```
3. Recompile and re-run

### **Problem 4: Simulation hangs or is very slow**
**Possible causes:**
- PDK not installed
- Missing includes
- Large waveform capture

**Solution:**
```bash
# Run without waveform capture
vvp hkspi.vvp +nodbg
```

---

## 3.5 Summary: RTL Simulation Checklist

| Step | Command | What it does |
|------|---------|-------------|
| 1 | `cd .../hkspi/` | Navigate to test directory |
| 2 | `make hex` | Compile firmware (hkspi.c → hkspi.hex) |
| 3 | `make hkspi.vvp` OR `iverilog ...` | Compile testbench (hkspi_tb.v → hkspi.vvp) |
| 4 | `vvp hkspi.vvp 2>&1 \| tee rtl_hkspi.log` | Run simulation, save output |
| 5 | Look for `Monitor: Test HK SPI (RTL) Passed` | Verify success |
| 6 | `cat rtl_hkspi.log` | Review all register values |

---

## 3.6 Expected Outcomes

### **Success Criteria:**
✅ **All of the following must be true:**

1. iverilog compiles without errors
2. vvp runs without errors
3. All 19 registers read correctly:
   - Registers 0, 4-7, 10-12 = 0x00
   - Register 1 = 0x04
   - Register 2 = 0x56
   - Register 3 = 0x11
   - Register 8 = 0x02
   - Register 9 = 0x01
   - Register 13 = 0xFF
   - Register 14 = 0xEF
   - Register 15 = 0xFF
   - Register 16 = 0x03
   - Register 17 = 0x12
   - Register 18 = 0x04
4. Final message: `Monitor: Test HK SPI (RTL) Passed`
5. Log file saved as `rtl_hkspi.log`

### **Files Generated:**
- `rtl_hkspi.log` - Console output log
- `hkspi.vcd` - Waveform data
- `hkspi.vvp` - Compiled simulation

---

## 3.7 Next Steps

After successful RTL simulation:

1. **Gate-level synthesis** (using yosys)
2. **Gate-level netlist extraction**
3. **Gate-level simulation** (with timing models)
4. **RTL vs GLS comparison**

These will be covered in subsequent steps.

---

# Complete File Structure

## Full Directory Tree for HK SPI Test

```
/home/iraj/VLSI/caravel/
├── verilog/
│   ├── dv/                                      # Testbenches
│   │   └── caravel/
│   │       └── mgmt_soc/
│   │           └── hkspi/                       ← YOU ARE HERE
│   │               ├── hkspi_tb.v              # TESTBENCH
│   │               ├── hkspi.c                 # C firmware source
│   │               ├── hkspi.elf               # Compiled firmware
│   │               ├── hkspi.hex               # Hex data for simulation
│   │               ├── hkspi.vvp               # Compiled simulation
│   │               ├── hkspi.vcd               # Waveforms (generated)
│   │               ├── rtl_hkspi.log           # RTL log (generated)
│   │               ├── gls_hkspi.log           # GLS log (generated)
│   │               ├── Makefile                # Build instructions
│   │               └── ...
│   │
│   ├── rtl/
│   │   └── housekeeping_spi.v                 # HK SPI CONTROLLER
│   │
│   └── gl/                                      # Gate-level netlists
│       └── (generated during synthesis)
│
├── openlane/
│   └── caravel/
│       └── results/                            # Synthesis outputs
│
└── ...
```

---

# File Dependency Map

```
hkspi_tb.v
  ├── includes → __uprj_netlists.v
  ├── includes → caravel_netlists.v
  ├── includes → spiflash.v
  ├── includes → tbuart.v
  └── instantiates → caravel (top-level chip)
       │
       ├── housekeeping_spi.v  ← THE CONTROLLER
       ├── management SoC (Picorv32)
       │   └── executes → hkspi.hex
       │       ├── compiled from → hkspi.c
       │       └── contains → firmware code
       └── user project area
           └── (not used in this test)
```

---

This comprehensive guide covers everything you need for Step 2 and Step 3. Each file path, code snippet, and explanation is grounded in the actual Caravel repository structure.

