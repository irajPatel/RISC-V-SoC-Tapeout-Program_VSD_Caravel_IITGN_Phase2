# CARAVEL CHIP: Complete Architecture Guide

A comprehensive, layman-friendly guide to the Caravel chip architecture, peripherals, memory mapping, and how to extend it.

---

## Table of Contents

1. [What is Caravel?](#what-is-caravel)
2. [Caravel at a Glance](#caravel-at-a-glance)
3. [Complete Block Diagram & Architecture](#complete-block-diagram--architecture)
4. [All Peripherals Explained](#all-peripherals-explained)
5. [Memory Map & Register Addressing](#memory-map--register-addressing)
6. [Complete File Structure](#complete-file-structure)
7. [How Modules Connect](#how-modules-connect)
8. [Adding a New Peripheral](#adding-a-new-peripheral)

---

# What is Caravel?

## Simple Explanation

Think of **Caravel** like a **student project harness on a silicon chip**. 

Imagine a big university building:
- The **management core** is like the administration office (controls everything)
- The **user project area** is like a student's lab (where you can do your own experiments)
- The **GPIO pins** are like doors and windows (communication with the outside world)
- The **housekeeping** is like a security guard (manages access and permissions)

**Caravel** provides:
✅ A complete chip design framework for the Sky130 PDK
✅ A management core (processor, memory, peripherals) that controls the chip
✅ Space for a **user project** (your custom design)
✅ 38 configurable GPIO pins for I/O
✅ SPI Flash memory interface
✅ UART (serial communication)
✅ Clocking and power management
✅ Complete testing infrastructure

---

# Caravel at a Glance

## Chip Specifications

| Aspect | Details |
|--------|---------|
| **PDK (Process)** | Sky130 (Google/SkyWater - 130nm open-source) |
| **Type** | ASIC Harness / Design Framework |
| **Main Processor** | PicoRV32 (embedded RISC-V CPU) |
| **GPIO Pins** | 38 total (mprj_io[37:0]) |
| **Power Supplies** | 3.3V (I/O), 1.8V (digital core), 1.3V (analog) |
| **Flash Memory** | SPI interface (external) |
| **Clock** | Internal PLL + external reference |
| **User Space** | ~170K transistors available |

## What's Inside the Chip?

```
┌──────────────────────────────────────────────────┐
│           CARAVEL CHIP (130nm)                   │
│                                                  │
│  ┌─────────────────────────────────────────┐   │
│  │   MANAGEMENT CORE (Fixed)                │   │
│  │  ┌────────────────┐                      │   │
│  │  │ PicoRV32 CPU   │ - RISC-V processor   │   │
│  │  │                │ - 4KB instruction RAM│   │
│  │  │                │ - 256B register RAM  │   │
│  │  └────────────────┘                      │   │
│  │                                          │   │
│  │  ┌──────────────────────────────────┐   │   │
│  │  │    HOUSEKEEPING MODULE            │   │   │
│  │  │  - SPI interface (external)       │   │   │
│  │  │  - GPIO control                   │   │   │
│  │  │  - PLL control                    │   │   │
│  │  │  - Power management               │   │   │
│  │  │  - Flash pass-through             │   │   │
│  │  │  - Register/memory mapping        │   │   │
│  │  └──────────────────────────────────┘   │   │
│  │                                          │   │
│  │  ┌────────────┐ ┌──────────────────┐   │   │
│  │  │ Digital    │ │ Wishbone Bus     │   │   │
│  │  │ PLL        │ │ (processor I/O)  │   │   │
│  │  └────────────┘ └──────────────────┘   │   │
│  └─────────────────────────────────────────┘   │
│                                                  │
│  ┌─────────────────────────────────────────┐   │
│  │   USER PROJECT AREA (Your Design!)      │   │
│  │  - Can be anything                       │   │
│  │  - Connects to GPIO pins                 │   │
│  │  - Access to power/clock                 │   │
│  │  - Can be RTL, gates, or mixed           │   │
│  └─────────────────────────────────────────┘   │
│                                                  │
│  ┌─────────────────────────────────────────┐   │
│  │        PAD FRAME (I/O Ring)              │   │
│  │  - 38 GPIO pins (mprj_io)                │   │
│  │  - 4 Flash SPI pins (flash_*)            │   │
│  │  - Power/Ground pins                     │   │
│  └─────────────────────────────────────────┘   │
└──────────────────────────────────────────────────┘
```

---

# Complete Block Diagram & Architecture

## Top-Level Hierarchy

### File: `/home/iraj/VLSI/caravel/verilog/rtl/caravel.v`

This is the **TOP-LEVEL MODULE** - the main entry point to the entire chip.

**What it does:**
- Defines all external pins/pads
- Instantiates the core logic
- Manages power distribution
- Handles I/O buffering

**Key ports (external pins):**

```verilog
module caravel (
    // POWER SUPPLIES
    inout vddio,      // 3.3V for I/O pads
    inout vddio_2,    // Second 3.3V supply
    inout vssio,      // Ground
    inout vccd,       // 1.8V for management core
    inout vssd,       // Ground for digital
    inout vdda,       // 3.3V for analog (management)
    inout vssa,       // Ground for analog
    
    // USER AREA POWER (separate supplies)
    inout vdda1,      // User area 1: 3.3V analog
    inout vdda2,      // User area 2: 3.3V analog
    inout vssa1, vssa2,  // User area grounds
    inout vccd1, vccd2,  // User area 1.8V digital
    inout vssd1, vssd2,  // User area digital grounds
    
    // CLOCK & RESET
    input clock,      // External clock input
    input resetb,     // Reset (active LOW)
    
    // GPIO - 38 configurable pins
    inout [37:0] mprj_io,   // User I/O pins
    
    // FLASH SPI INTERFACE (to external flash chip)
    output flash_csb,       // Chip select
    output flash_clk,       // Clock
    inout flash_io0,        // Data line 0 (MOSI)
    inout flash_io1         // Data line 1 (MISO)
);
```

---

## Management Core: The "Brain"

### File: `/home/iraj/VLSI/caravel/verilog/rtl/caravel_core.v`

This is the **MANAGEMENT CORE** - contains the processor and core logic.

**What's inside:**
1. **PicoRV32 CPU** - Open-source RISC-V processor
2. **SPI Flash Controller** - Manages external flash memory
3. **Wishbone Bus** - Internal communication backbone
4. **Power-on Reset (POR)** - Startup logic

**Key connections:**
```
PicoRV32 CPU
  ├─ Wishbone Bus (connects to all peripherals)
  ├─ Instruction Memory (from Flash)
  ├─ UART interface
  ├─ SPI Master interface
  └─ GPIO control signals
```

---

## The Housekeeping Module: The "Security Guard"

### File: `/home/iraj/VLSI/caravel/verilog/rtl/housekeeping.v` (1445 lines!)

**Why is it called "Housekeeping"?**
Like a janitor who keeps everything running, this module manages all the critical control functions that even the CPU can't directly control (because if the CPU crashes, these still need to work).

### What Housekeeping Controls:

| Function | Register Address | What it does |
|----------|-----------------|-------------|
| **SPI Interface** | 2610_0000 - 2610_003F | Receives external commands |
| **GPIO Control** | 2600_0000 - 2600_00B9 | Configures all 38 GPIO pins |
| **PLL Settings** | 2610_000C-2610_0024 | Clock generation control |
| **Reset** | 2610_0018 | Reset external designs |
| **IRQ** | 2610_0014 | Interrupt signals |
| **UART** | (dedicated pins) | Serial communication |
| **Flash Control** | (pass-through) | Access flash without CPU |

**Connection diagram:**
```
External SPI Interface
  │
  └─→ Housekeeping Module ←─→ Wishbone Bus
        │                       │
        ├─→ GPIO Control ───→ mprj_io pins (GPIO 0-37)
        ├─→ PLL Control ────→ digital_pll
        ├─→ Reset Logic ────→ reset signal
        ├─→ UART Control ──→ UART pins
        └─→ Pass-through ──→ Flash SPI
```

---

## All Internal Bus Types

### 1. **Wishbone Bus** (Main Internal Bus)

Used for CPU to communicate with all modules.

**Wishbone signals:**
```verilog
input [31:0] wb_adr_i;     // Address (which register?)
input [31:0] wb_dat_i;     // Data in (from CPU)
output [31:0] wb_dat_o;    // Data out (to CPU)
input wb_we_i;             // Write enable (1=write, 0=read)
input wb_cyc_i;            // Cycle active
input wb_stb_i;            // Strobe (request)
output wb_ack_o;           // Acknowledge
```

**Think of it like:** A post office system where:
- Address = which house?
- Data_in = what to deliver?
- We = incoming or outgoing mail?
- Ack = package delivered!

### 2. **SPI Interface** (External)

Used by external equipment to talk to the chip.

**SPI signals:**
```
SCK  - Serial Clock (timing)
SDI  - Serial Data In (commands to chip)
SDO  - Serial Data Out (responses from chip)
CSB  - Chip Select (active LOW)
```

### 3. **GPIO Chains** (Serial Configuration)

A clever way to configure 38 GPIO pins using only 2 wires (serial data, clock).

```
serial_clock → clocks in one bit at a time
serial_load  → latches the configuration
serial_data  → the bit value
```

Why? To save wires. Instead of 38×13 = 494 control wires, use just 2!

---

# All Peripherals Explained

## Peripheral #1: Digital PLL (Programmable Clock Generator)

### File: `/home/iraj/VLSI/caravel/verilog/rtl/digital_pll.v`

**What it is:** A "clock factory" that creates different clock frequencies from the input clock.

**How it works:**

```
Input Clock (e.g., 10MHz)
     │
     └─→ Ring Oscillator (13 stages of inverters)
           │
           └─→ PLL Controller
                 │
                 ├─ Divider: Slows down the clock
                 ├─ Feedback: Compares with input
                 └─ Trim: Fine-tunes the frequency
                      │
                      └─→ Output Clock (faster or slower)
```

**Register Control:**

| Register | Address | Controls |
|----------|---------|----------|
| PLL Enable | 2610_000C | Turns PLL on/off |
| PLL Bypass | 2610_0010 | Bypass PLL (use input directly) |
| PLL Divider | 2610_0024 | Divide ratio (1-32) |
| PLL Trim | 2610_001C-201F | Fine frequency adjustment |
| PLL Select | 2610_0020 | Output phase selection |

**Example:** How to set clock to 2x input frequency?
```c
// Via CPU (Wishbone)
reg_pll_div = 5'b00001;      // Divide by 2
reg_pll_ena = 1'b1;          // Enable PLL

// Result: Output = Input × 2
```

---

## Peripheral #2: GPIO Control (38 Configurable Pins)

### File: `/home/iraj/VLSI/caravel/verilog/rtl/gpio_control_block.v`

**What it is:** A system to configure and control each of the 38 I/O pins independently.

**Each GPIO pin can be:**
- Input (read external voltage)
- Output (drive external load)
- Open-drain (pull to ground only)
- Analog pass-through
- Fast or slow slew rate
- TTL or CMOS threshold

**Structure:**

```
For each GPIO pin [0-37]:
┌─────────────────────────────────────────┐
│   GPIO Control Cell                     │
├─────────────────────────────────────────┤
│                                          │
│  CONFIG REGISTERS (13 bits each):        │
│  ┌──────────────────────────────────┐  │
│  │ Bits [12:0]                      │  │
│  │ [12] = Input enable              │  │
│  │ [11] = Output enable             │  │
│  │ [10] = Slow slew rate            │  │
│  │ [9]  = Voltage threshold         │  │
│  │ [8]  = Hold over                 │  │
│  │ [7]  = Analog enable             │  │
│  │ [6]  = Analog select             │  │
│  │ [5]  = Analog polarity           │  │
│  │ [4:2]= Drive mode (3 bits)       │  │
│  │ [1]  = Output value              │  │
│  │ [0]  = Output enable             │  │
│  └──────────────────────────────────┘  │
│                                          │
│  ┌──────────────────────────────────┐  │
│  │  Pad connections:                │  │
│  │  - pad_gpio_in   (read)          │  │
│  │  - pad_gpio_out  (write)         │  │
│  │  - pad_gpio_oeb  (output enable) │  │
│  └──────────────────────────────────┘  │
│                                          │
│  ┌──────────────────────────────────┐  │
│  │  User/Management connections:    │  │
│  │  - user_gpio_in  (from pad)      │  │
│  │  - user_gpio_out (to pad)        │  │
│  │  - mgmt_gpio_in  (from pad)      │  │
│  │  - mgmt_gpio_out (to pad)        │  │
│  └──────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

**Register Map for GPIO:**

Each GPIO pin has TWO registers (high byte and low byte):

| SPI Reg | Memory Address | Bits | Meaning |
|---------|---|---|---|
| 1D | 2600_0025 | [12:8] | GPIO[0] control (upper) |
| 1E | 2600_0024 | [7:0]  | GPIO[0] control (lower) |
| 1F | 2600_0029 | [12:8] | GPIO[1] control (upper) |
| 20 | 2600_0028 | [7:0]  | GPIO[1] control (lower) |
| ... | ... | ... | ... (pattern repeats for GPIO 2-37) |

**Example: Configure GPIO[0] as output (push-pull)**
```c
// GPIO[0] configuration register = 0x180A
// This means:
// - [11:8] = 0x1 (not used in memory map)
// - Bit 3 = drive mode [2:0] = 001 (push-pull)
// - Bit 1 = output enabled
// - Bit 0 = output enable control

reg_gpio_0_config_upper = 0x01;    // From address 2600_0025
reg_gpio_0_config_lower = 0x0A;    // From address 2600_0024
```

**Default Configuration** (at power-on):
- Most GPIO pins are inputs (listening, not driving)
- Special pins hardwired for management use (SPI, UART, JTAG)

---

## Peripheral #3: UART (Serial Communication)

**What it is:** A serial port interface for text communication.

**Signals:**
```
ser_rx = mprj_io[5]    (data IN to chip)
ser_tx = mprj_io[6]    (data OUT from chip)
```

**How it works:**
```
User writes to CPU UART register
     │
     └─→ UART controller sends bits on ser_tx (one at a time)
         
External equipment reads bits and reconstructs the message
```

**Example use:**
```
printf("Hello from Caravel!\n");  // In C code running on CPU
  │
  └─→ Gets sent out ser_tx
       │
       └─→ Can be viewed on a terminal (like minicom)
```

---

## Peripheral #4: SPI Master (Master-mode SPI)

**What it is:** Allows the CPU to be a SPI master and talk to external devices.

**Signals:**
```
spi_sck  = mprj_io[32]   (clock OUT from chip)
spi_csb  = mprj_io[33]   (chip select OUT from chip)
spi_sdi  = mprj_io[34]   (data IN to chip)
spi_sdo  = mprj_io[35]   (data OUT from chip)
```

**Use cases:**
- Talk to external sensors
- Program other chips
- Read external EEPROM

---

## Peripheral #5: External Flash SPI Interface

**What it is:** A dedicated interface to a large SPI flash chip (where the firmware lives).

**Signals:**
```
flash_csb  = output   (chip select - external pin)
flash_clk  = output   (clock - external pin)
flash_io0  = inout    (MOSI - external pin)
flash_io1  = inout    (MISO - external pin)
```

**Why external?** The management core needs a place to store:
- Boot firmware
- Configuration data
- User program code

**How it connects:**
```
Caravel CPU
    │
    └─→ Flash Controller (in housekeeping)
        │
        └─→ Housekeeping SPI
            │
            └─→ Flash SPI pins
                │
                └─→ External Flash Chip (64MB typical)
```

---

## Peripheral #6: Power Management

### Controlled by Housekeeping Module

**Voltage Regulators:**
Each section can be independently powered:

```
┌─────────────────────────────────────────┐
│  Power Distribution Map                 │
├─────────────────────────────────────────┤
│                                         │
│  vddio (3.3V)  ───→ Pad frame I/O       │
│  vddio_2       ───→ Secondary supply    │
│                                         │
│  vdda (3.3V)   ───→ Management analog   │
│  vdda1, vdda2  ───→ User areas analog   │
│                                         │
│  vccd (1.8V)   ───→ Management digital  │
│  vccd1, vccd2  ───→ User areas digital  │
│                                         │
│  vssa, vssd    ───→ Management grounds  │
│  vssa1, vssd1  ───→ User area 1 grounds │
│  vssa2, vssd2  ───→ User area 2 grounds │
└─────────────────────────────────────────┘
```

**Power Control Register:**

| Register | Address | Controls |
|----------|---------|----------|
| pwr_ctrl | 2600_0004 | Enable/disable user supply LDOs (Low Dropout regulators) |

---

## Peripheral #7: Clocking System

**Clock Sources:**

```
External Clock Input (pin "clock")
     │
     ├─→ Clock Buffer
     │
     ├─→ Option A: Direct use (fast response)
     │
     └─→ Option B: Through Digital PLL
            │
            ├─ Ring oscillator generates frequency
            ├─ Phase locked loop locks to input
            └─ Output: synchronized, adjustable frequency
```

**Clock Divisor Register:**

| Register | Address | Function |
|----------|---------|----------|
| clk_div | (implicit in PLL) | Divides the PLL output |

---

# Memory Map & Register Addressing

## Quick Reference: Where Everything Lives

The Caravel chip has THREE main address spaces (like three neighborhoods in the city):

### Space 1: GPIO Configuration (2600_0000 - 2600_00B9)

**Base address:** `0x26000000`

```
2600_0000  ─→ Power control + GPIO data read
2600_0004  ─→ Power control register
2600_000C-010  ─→ GPIO input data (bits 37:0)

2600_0024-025  ─→ GPIO[0] configuration
2600_0028-029  ─→ GPIO[1] configuration
2600_002C-02D  ─→ GPIO[2] configuration
...
2600_00B8-B9  ─→ GPIO[37] configuration (last GPIO)
```

**Pattern:** For GPIO[n]:
- **Lower register:** `0x26000000 + (n×4) + 0x24`
- **Upper register:** `0x26000000 + (n×4) + 0x25`

**Example:** GPIO[5] configuration
- Lower: `2600_0038`
- Upper: `2600_0039`

### Space 2: System Control (2610_0000 - 2610_003F)

**Base address:** `0x26100000`

```
2610_0000  ─→ SPI Status
2610_0004  ─→ Product ID
2610_0005  ─→ Manufacturer ID (low byte)
2610_0006  ─→ Manufacturer ID (high byte)

2610_0008-B  ─→ User Project ID / Mask Revision (32-bit, 4 bytes)

2610_000C  ─→ PLL Enable/DCO Enable
2610_0010  ─→ PLL Bypass
2610_0014  ─→ IRQ Status
2610_0018  ─→ Reset Control
2610_001C-1F  ─→ PLL Trim (32-bit, 4 bytes)
2610_0020  ─→ PLL Source Select & Phase
2610_0024  ─→ PLL Divider
2610_0028  ─→ Trap status
2610_002C-2F  ─→ SRAM read-only data (4 bytes)
2610_0030  ─→ SRAM read-only address
2610_0034  ─→ SRAM read-only control

2610_0038  ─→ (reserved)
2610_003C  ─→ (reserved)
```

### Space 3: Monitoring & Redirection (2620_0000 - 2620_0010)

**Base address:** `0x26200000`

```
2620_0000  ─→ Power monitor (usr1/2_vcc/vdd good flags)
2620_0004  ─→ Output redirection (clk1/clk2/trap output)
2620_000C  ─→ Input redirection (IRQ 7/8 input source)
2620_0010  ─→ HK SPI disable (turn off external SPI interface)
```

---

## How to Read/Write Registers via CPU (C code)

**Memory-mapped I/O:**
Since registers are memory addresses, you can read/write them like RAM!

```c
// Define register addresses
#define REG_GPIO0_CONFIG_LOW   ((volatile uint32_t*) 0x26000024)
#define REG_GPIO0_CONFIG_HIGH  ((volatile uint32_t*) 0x26000025)
#define REG_PLL_ENA            ((volatile uint32_t*) 0x26100000C)
#define REG_RESET              ((volatile uint32_t*) 0x26100018)

// Read a register
uint32_t pll_status = *REG_PLL_ENA;

// Write a register
*REG_GPIO0_CONFIG_LOW = 0x0A;

// Bitwise operations
*REG_PLL_ENA |= 0x01;    // Set bit 0 (enable PLL)
*REG_PLL_ENA &= ~0x02;   // Clear bit 1
```

---

## Complete GPIO Configuration Bits

For each GPIO pin, the 13-bit control word is:

```
Bit 12: Input Buffer Enable
Bit 11: Output Buffer Enable  
Bit 10: Slew Rate (0=slow, 1=fast)
Bit 9:  Voltage Threshold (0=CMOS, 1=TTL)
Bit 8:  Hold-over Control
Bit 7:  Analog Enable
Bit 6:  Analog Select
Bit 5:  Analog Polarity
Bit 4:  Drive Mode Bit 2
Bit 3:  Drive Mode Bit 1
Bit 2:  Drive Mode Bit 0
Bit 1:  Output Value (what to drive)
Bit 0:  Output Enable (1=enabled, 0=disabled)
```

**Drive Modes (Bits 4:2):**

```
001 = Push-pull (both NMOS and PMOS)
010 = Open-drain (NMOS only)
100 = High impedance input
Others = Special modes
```

---

# Complete File Structure

## Directory Tree with Descriptions

```
/home/iraj/VLSI/caravel/
│
├── verilog/
│   ├── rtl/                                 # RTL Source Code
│   │   ├── CORE MODULES
│   │   │   ├── caravel.v                   # TOP-LEVEL module (external pins)
│   │   │   ├── caravel_core.v              # Core logic (400+ instantiations)
│   │   │   ├── caravel_clocking.v          # Clocking network
│   │   │   ├── chip_io.v                   # Padframe connections
│   │   │   └── defines.v                   # Global constants/parameters
│   │   │
│   │   ├── HOUSEKEEPING SUBSYSTEM
│   │   │   ├── housekeeping.v              # Main housekeeping (1445 lines!)
│   │   │   ├── housekeeping_spi.v          # SPI slave interface
│   │   │   ├── housekeeping_alt.v          # Alternative version
│   │   │   └── mprj_ctrl.v (not shown)     # GPIO chain loader
│   │   │
│   │   ├── PERIPHERAL MODULES
│   │   │   ├── digital_pll.v               # Clock generator
│   │   │   ├── digital_pll_controller.v    # PLL control logic
│   │   │   ├── ring_osc2x13.v              # Ring oscillator
│   │   │   ├── gpio_control_block.v        # GPIO cell (for each pin)
│   │   │   ├── gpio_signal_buffering.v     # GPIO signal management
│   │   │   ├── gpio_defaults_block.v       # GPIO power-on defaults
│   │   │   └── mprj_io_buffer.v            # I/O pad drivers
│   │   │
│   │   ├── RESET & POWER
│   │   │   ├── simple_por.v                # Power-on Reset circuit
│   │   │   ├── buff_flash_clkrst.v         # Flash clock/reset buffers
│   │   │   ├── xres_buf.v                  # Reset buffer
│   │   │   └── manual_power_connections.v  # Power routing
│   │   │
│   │   ├── PROTECTION & UTILITY
│   │   │   ├── mgmt_protect.v              # Protection logic
│   │   │   ├── mgmt_protect_hv.v           # HV protection
│   │   │   ├── constant_block.v            # Constant values
│   │   │   ├── spare_logic_block.v         # Spare gates
│   │   │   ├── user_id_programming.v       # User ID register
│   │   │   ├── debug_regs.v                # Debug registers
│   │   │   └── clock_div.v                 # Clock divider
│   │   │
│   │   ├── USER PROJECT INTERFACE
│   │   │   ├── __user_project_wrapper.v    # User project wrapper
│   │   │   ├── __user_project_gpio_example.v
│   │   │   └── __user_project_la_example.v
│   │   │
│   │   ├── NETLISTS & INCLUDES
│   │   │   ├── caravel_netlists.v          # Gate-level netlists
│   │   │   ├── caravel_openframe.v         # OpenFrame version
│   │   │   ├── __uprj_netlists.v           # User netlists
│   │   │   └── user_defines.v              # User-specific defines
│   │   │
│   │   ├── PADFRAME
│   │   │   ├── chip_io.v                   # Pad buffer logic
│   │   │   ├── chip_io_alt.v               # Alternative pad config
│   │   │   ├── pads.v                      # Pad macros
│   │   │   ├── mprj_io.v                   # User I/O pads
│   │   │   ├── mprj_io_buffer.v            # I/O buffers
│   │   │   └── mprj_logic_high.v           # Tie-high cells
│   │   │
│   │   └── LOGOS & UTILITY
│   │       ├── caravel_logo.v              # Efabless logo (decorative)
│   │       ├── caravel_motto.v             # Motto text
│   │       ├── copyright_block.v           # Copyright info
│   │       └── empty_macro.v               # Placeholder
│   │
│   ├── dv/                                  # Design Verification (Tests)
│   │   ├── caravel/
│   │   │   ├── mgmt_soc/
│   │   │   │   ├── hkspi/                  # HK SPI test
│   │   │   │   │   ├── hkspi_tb.v
│   │   │   │   │   ├── hkspi.c
│   │   │   │   │   └── Makefile
│   │   │   │   ├── gpio/                   # GPIO test
│   │   │   │   ├── uart/                   # UART test
│   │   │   │   ├── pass_thru/              # Flash pass-through test
│   │   │   │   ├── spi_master/             # SPI master test
│   │   │   │   └── ... (20+ other tests)
│   │   │   │
│   │   │   └── README.md                   # Test documentation
│   │   │
│   │   └── wb_utests/                      # Wishbone unit tests
│   │
│   └── gl/                                  # Gate-level netlists (generated)
│       └── (generated after synthesis)
│
├── def/                                     # Design Exchange Format files
│   ├── caravel.def                          # Chip DEF (placement)
│   ├── caravel_core.def
│   └── ... (other DEF files)
│
├── lef/                                     # Library Exchange Format files
│   ├── caravel.lef                          # Chip LEF (routing)
│   ├── gpio_control_block.lef
│   └── ... (other LEF files)
│
├── lib/                                     # Library files (timing, power)
│   ├── caravel_slow.lib                     # Slow corner library
│   └── ... (other corners)
│
├── mag/                                     # Magistrate (custom layout)
│   └── (hand-drawn layout for some cells)
│
├── gds/                                     # Final GDS-II files
│   └── caravel.gds                          # Complete chip layout
│
├── docs/                                    # Documentation
│   ├── other/
│   │   └── memory_map.txt                   # Register addresses! 📍
│   ├── rst/
│   │   ├── source/                          # ReStructured Text docs
│   │   └── index.rst
│   └── README_DEVELOPMENT
│
├── openlane/                                # OpenLane flow
│   ├── caravel/
│   │   ├── config.tcl                       # Synthesis configuration
│   │   ├── runs/
│   │   │   └── (synthesis results)
│   │   └── ...
│   └── ...
│
├── scripts/                                 # Utility scripts
│   ├── (build scripts)
│   └── (test scripts)
│
└── Makefile                                 # Top-level build commands
```

---

# How Modules Connect

## Signal Flow Diagram: From External to Internal

```
EXTERNAL WORLD
├─ Clock Input
├─ Reset Input
└─ 38 GPIO Pins + Flash SPI pins
     │
     └─→ CHIP_IO Module (chip_io.v)
         (Pads with ESD protection, level shifters)
         │
         ├─→ Padframe (pad ring)
         │   │
         │   └─→ Individual GPIO cells
         │       (gpio_control_block.v ×38)
         │
         └─→ CARAVEL_CORE Module
             (caravel_core.v)
             │
             ├─────────────────────────────────┬─────────────────────────┐
             │                                 │                         │
             │                                 │                         │
        ┌────▼────────┐            ┌─────────▼──────────┐    ┌────────▼──────────┐
        │ HOUSEKEEPING │            │   PicoRV32 CPU     │    │  USER PROJECT     │
        │   Module     │            │                    │    │  WRAPPER          │
        │              │            │  - RISC-V core     │    │                   │
        │ Controls:    │            │  - 4KB inst RAM    │    │  (Your design!)   │
        │ - SPI I/F    │            │  - 256B reg RAM    │    │                   │
        │ - GPIO cfg   │            │                    │    │  Connects to:     │
        │ - PLL        │            │  Wishbone Master   │    │  - GPIO pins      │
        │ - Reset      │            │                    │    │  - Power/Clock    │
        │ - Power      │            └──────────┬─────────┘    │  - Wishbone (opt) │
        │ - UART       │                       │               └────────┬──────────┘
        │ - Flash ctrl │            ┌──────────▼──────────┐             │
        │              │            │  WISHBONE BUS      │◄────────────┘
        │ Wishbone     │            │  (master-slave)    │
        │ Slave        │            │                    │
        └──────────────┘            │  Connects to:      │
                                    │  - UART            │
                                    │  - SPI Master      │
                                    │  - SRAM            │
                                    │  - Debug regs      │
                                    └────────────────────┘
```

## Clock Path

```
External Clock Input (pin "clock")
     │
     └─→ Clock Buffer
         │
         ├─→ PLL (Digital PLL Module)
         │   ├─ Ring oscillator
         │   ├─ PLL controller
         │   └─ Clock buffers
         │
         └─→ Clock Divider
             │
             └─→ Management SoC Clock
                 │
                 └─→ Distributed to all modules
```

## Power Distribution Network

```
Package Pins (External Power)
├─ vddio (3.3V I/O)
├─ vccd  (1.8V core)
├─ vdda  (3.3V analog)
└─ Ground pins (vssio, vssd, vssa)
     │
     └─→ Manual Power Connections
         (manual_power_connections.v)
         │
         ├─→ Padframe
         ├─→ Management core (vccd)
         ├─→ User area 1 (vccd1, vdda1)
         └─→ User area 2 (vccd2, vdda2)
```

## The Housekeeping "Hub" - Complete Connectivity

Housekeeping connects to almost everything:

```
Housekeeping Module (housekeeping.v)
│
├─ Wishbone Bus Connection (to CPU)
│  ├─ Writes to GPIO config registers
│  ├─ Reads PLL status
│  ├─ Manages interrupts
│  └─ Controls power
│
├─ SPI Slave Interface (external)
│  ├─ SCK, SDI, SDO, CSB pins
│  ├─ Converts SPI commands to internal actions
│  └─ Can work even if CPU is in reset!
│
├─ GPIO Control Chain
│  ├─ serial_clock → clocks configuration in
│  ├─ serial_load → latches configuration
│  ├─ serial_data → configuration bits
│  └─ Drives all 38 GPIO control blocks
│
├─ PLL Control
│  ├─ pll_ena (enable)
│  ├─ pll_dco_ena (DCO mode)
│  ├─ pll_div (divider 1-32)
│  ├─ pll_sel (phase selection)
│  └─ pll_trim (frequency trim)
│
├─ Reset Distribution
│  ├─ reset → external reset
│  ├─ porb → power-on reset
│  └─ rstb → internal reset
│
├─ UART Pass-through
│  ├─ ser_tx (to CPU UART)
│  ├─ ser_rx (from external)
│  └─ Can route to GPIO if needed
│
├─ Flash SPI Control
│  ├─ Pass-through to management flash
│  ├─ Pass-through to user flash
│  └─ Flash data: io0, io1, io2, io3
│
└─ Power Monitoring
   ├─ usr1/2_vcc_pwrgood (supply good flags)
   ├─ usr1/2_vdd_pwrgood
   └─ LDO control outputs
```

---

# Adding a New Peripheral

## Step-by-Step Guide: Add a TIMER Module

Let's say you want to add a 32-bit timer peripheral to Caravel. Here's how:

### Step 1: Create the Peripheral Module File

**File:** `/home/iraj/VLSI/caravel/verilog/rtl/simple_timer.v`

```verilog
`default_nettype none

module simple_timer #(
    parameter BASE_ADDRESS = 32'h26300000
) (
    // Wishbone interface (slave)
    input clk,
    input resetn,
    input [31:0] wb_adr_i,
    input [31:0] wb_dat_i,
    input [3:0] wb_sel_i,
    input wb_we_i,
    input wb_cyc_i,
    input wb_stb_i,
    output reg wb_ack_o,
    output reg [31:0] wb_dat_o,
    
    // Output interrupt
    output reg timer_irq
);

    // Internal registers
    reg [31:0] timer_count;     // Current count
    reg [31:0] timer_compare;   // Compare value
    reg timer_enable;           // Enable bit
    
    // Wishbone address decoding
    // Register map:
    // BASE+0x00: Control (enable, clear)
    // BASE+0x04: Count value
    // BASE+0x08: Compare value
    
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            timer_count <= 32'h0;
            timer_compare <= 32'h0;
            timer_enable <= 1'b0;
            timer_irq <= 1'b0;
            wb_ack_o <= 1'b0;
        end else begin
            // Wishbone write
            if (wb_cyc_i & wb_stb_i & wb_we_i) begin
                case (wb_adr_i)
                    32'h26300000: begin
                        // Control register
                        timer_enable <= wb_dat_i[0];
                        if (wb_dat_i[1]) timer_count <= 32'h0; // Clear on write
                    end
                    32'h26300004: timer_count <= wb_dat_i;
                    32'h26300008: timer_compare <= wb_dat_i;
                endcase
                wb_ack_o <= 1'b1;
            end
            // Wishbone read
            else if (wb_cyc_i & wb_stb_i & !wb_we_i) begin
                case (wb_adr_i)
                    32'h26300000: wb_dat_o <= {30'h0, timer_enable, 1'h0};
                    32'h26300004: wb_dat_o <= timer_count;
                    32'h26300008: wb_dat_o <= timer_compare;
                    default: wb_dat_o <= 32'h0;
                endcase
                wb_ack_o <= 1'b1;
            end else begin
                wb_ack_o <= 1'b0;
            end
            
            // Timer logic
            if (timer_enable) begin
                if (timer_count == timer_compare) begin
                    timer_irq <= 1'b1;
                    timer_count <= 32'h0;
                end else begin
                    timer_count <= timer_count + 1;
                    timer_irq <= 1'b0;
                end
            end
        end
    end

endmodule
`default_nettype wire
```

### Step 2: Add to Caravel_Core Instantiation

**File:** `/home/iraj/VLSI/caravel/verilog/rtl/caravel_core.v`

Add this instantiation inside `caravel_core`:

```verilog
// Timer module
wire timer_irq;

simple_timer timer_inst (
    .clk(clock_core),
    .resetn(rstb_h),
    .wb_adr_i(wb_adr_m),
    .wb_dat_i(wb_dat_m),
    .wb_sel_i(wb_sel_m),
    .wb_we_i(wb_we_m),
    .wb_cyc_i(wb_cyc_m),
    .wb_stb_i(wb_stb_m),
    .wb_ack_o(timer_ack),
    .wb_dat_o(timer_data_out),
    .timer_irq(timer_irq)
);
```

### Step 3: Add Wishbone Arbiter Logic

Modify the Wishbone bus arbitration to include the timer:

```verilog
// Wishbone bus decoding (add timer range)
always @(*) begin
    if (wb_adr_m >= 32'h26300000 && wb_adr_m < 32'h26300010) begin
        // Timer address range
        wb_dat_s = timer_data_out;
        wb_ack_s = timer_ack;
    end else if (...) begin
        // Other peripherals...
    end
end
```

### Step 4: Add Interrupt Handling

Connect the timer interrupt to the management SoC:

```verilog
// Interrupt mux - add timer_irq as option
assign irq_sources = {timer_irq, gpio_irq, uart_irq, ...};
```

### Step 5: Update Defines

**File:** `/home/iraj/VLSI/caravel/verilog/rtl/defines.v`

Add timer base address:

```verilog
`define TIMER_BASE_ADR 32'h26300000
```

### Step 6: Update Memory Map Documentation

**File:** `/home/iraj/VLSI/caravel/docs/other/memory_map.txt`

Add to the memory map:

```
Timer Registers (SPI address 0x70-0x72):
70    Timer control     timer_enable, timer_clear     2630_0000
71    Timer count       timer_count[31:24]            2630_0004
72    Timer compare     timer_compare[31:24]          2630_0008
```

### Step 7: Create a Test

**File:** `/home/iraj/VLSI/caravel/verilog/dv/caravel/mgmt_soc/timer_test/timer_test_tb.v`

```verilog
module timer_test_tb;
    // Instantiate Caravel
    // Set timer compare = 100
    // Wait for interrupt
    // Verify count is correct
endmodule
```

### Step 8: Update Include Files

Update netlists to include new module:

**File:** `/home/iraj/VLSI/caravel/verilog/rtl/caravel_netlists.v`

```verilog
`include "simple_timer.v"
```

### Step 9: Build & Test

```bash
cd /home/iraj/VLSI/caravel
make clean
make
# Simulation
iverilog -c caravel_rtl.vc -o sim.vvp
vvp sim.vvp
```

---

## Complete Checklist for Adding a Peripheral

| Step | File | Change |
|------|------|--------|
| 1 | Create module | `verilog/rtl/your_module.v` |
| 2 | Add instantiation | `caravel_core.v` → Add `your_module_inst` |
| 3 | Add Wishbone logic | `caravel_core.v` → Address decode |
| 4 | Add interrupt (if needed) | `caravel_core.v` → IRQ mux |
| 5 | Define base address | `defines.v` → `#define MODULE_BASE_ADR` |
| 6 | Add to netlists | `caravel_netlists.v` → ``include`` |
| 7 | Update memory map | `docs/memory_map.txt` → Add registers |
| 8 | Create testbench | `verilog/dv/caravel/mgmt_soc/your_test/` |
| 9 | Build & simulate | Terminal → `make && make test` |

---

## Real Example: How GPIO Control Was Added

Looking at the existing code:

**1. Module definition:**
```verilog
// File: verilog/rtl/gpio_control_block.v
module gpio_control_block (
    input [12:0] gpio_defaults,    // Power-on config
    input serial_clock,            // From housekeeping
    input serial_load,             // From housekeeping
    input serial_data_in,          // From housekeeping
    output serial_data_out,        // To next GPIO cell
    // ... pad connections
);
```

**2. 38 instances created (one per pin):**
```verilog
// File: caravel_core.v
generate
    for (i=0; i<38; i=i+1) begin
        gpio_control_block gpio_cell [
            .gpio_defaults(gpio_defaults_out[i]),
            .serial_clock(serial_clock),
            .serial_load(serial_load),
            // Chained serial connection
            .serial_data_in(serial_chain[i]),
            .serial_data_out(serial_chain[i+1]),
            // ...
        ];
    end
endgenerate
```

**3. Housekeeping drives the configuration:**
```verilog
// File: housekeeping.v
always @(posedge serial_clock) begin
    if (serial_load)
        serial_data_1 <= gpio_config[index];  // Load one GPIO config
    serial_data_1 <= serial_data_1 << 1;     // Shift for next GPIO
end
```

**4. Result:** All 38 GPIOs configured with only 2 wires (clock + data)!

---

## Key Design Principles

When adding peripherals, follow these principles:

### 1. **Use Wishbone Bus** (for CPU access)
- Standard bus interface
- Multiple slaves can be attached
- Address decoding in central arbiter

### 2. **Use Housekeeping for External Access**
- SPI interface works even in reset
- Can configure GPIO routing
- Can trigger resets/power control

### 3. **Minimize Wiring**
- Use serial chains where possible (like GPIO)
- Share buses (Wishbone)
- Avoid point-to-point connections

### 4. **Respect Power Domains**
- Keep management core (vccd, vdda) separate from user areas
- Use proper level shifters at domain boundaries
- Use correct power pins in module definition

### 5. **Include Clock/Reset**
- All modules need `clk` and `reset` inputs
- Respect `USE_POWER_PINS` ifdef for realistic sims
- Use synchronous design (clocked logic)

---

# Complete Module Dependency Map

```
caravel.v (TOP-LEVEL)
│
└─→ caravel_core.v
    ├─→ housekeeping.v
    │   ├─→ housekeeping_spi.v (SPI interface)
    │   ├─→ gpio_control_block.v ×38 (chained)
    │   ├─→ digital_pll.v (clock control)
    │   └─→ Wishbone slave logic
    │
    ├─→ PicoRV32 (RISC-V CPU)
    │   └─→ External instruction/data memory
    │
    ├─→ Wishbone Bus Master (from CPU)
    │   └─→ Multiple slaves (UART, SPI, etc.)
    │
    └─→ Wishbone Bus Slaves
        ├─→ UART (serial)
        ├─→ SPI Master
        ├─→ Debug registers
        └─→ System control
```

---

# Quick Reference: Most Important Files

| File | Purpose | Size | Importance |
|------|---------|------|-----------|
| `caravel.v` | Top-level chip | 358 lines | ⭐⭐⭐⭐⭐ |
| `caravel_core.v` | Core logic | 1434 lines | ⭐⭐⭐⭐⭐ |
| `housekeeping.v` | System control | 1445 lines | ⭐⭐⭐⭐⭐ |
| `chip_io.v` | Pad buffers | 413 lines | ⭐⭐⭐⭐ |
| `gpio_control_block.v` | GPIO cell | 279 lines | ⭐⭐⭐⭐ |
| `digital_pll.v` | Clock PLL | 90 lines | ⭐⭐⭐ |
| `housekeeping_spi.v` | SPI slave | 257 lines | ⭐⭐⭐⭐ |
| `memory_map.txt` | Register addresses | Reference | ⭐⭐⭐⭐⭐ |
| `defines.v` | Constants | 100 lines | ⭐⭐⭐⭐ |

---

# Summary: The Caravel "Anatomy"

```
┌─────────────────────────────────────────────────────────────┐
│                    CARAVEL CHIP 130nm                       │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  🏛️  MANAGEMENT CORE (Fixed by Efabless)                   │
│  ├─ 🧠 PicoRV32 CPU + Memory                               │
│  ├─ 🔐 Housekeeping (SPI slave, GPIO ctrl, power)          │
│  ├─ ⏱️  Digital PLL (clock generator)                       │
│  ├─ 📡 UART (serial communication)                         │
│  ├─ 🚌 Wishbone Bus (CPU talks to everything)              │
│  └─ 🔗 Interconnect logic                                   │
│                                                              │
│  👤 USER PROJECT AREA (Your design!)                        │
│  └─ Can add any design you want                             │
│                                                              │
│  🎛️  38 CONFIGURABLE GPIO PINS (mprj_io[37:0])            │
│  ├─ Each pin independently configurable                    │
│  ├─ Drive mode (push-pull, open-drain, etc.)               │
│  ├─ Input/output mode                                      │
│  └─ Analog capability                                       │
│                                                              │
│  💾 EXTERNAL CONNECTIONS                                    │
│  ├─ SPI Flash (64MB typical)                                │
│  ├─ 4 Flash data lines (io0-io3)                            │
│  └─ Clock/Reset pins                                        │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

You now have a complete understanding of the Caravel chip!

