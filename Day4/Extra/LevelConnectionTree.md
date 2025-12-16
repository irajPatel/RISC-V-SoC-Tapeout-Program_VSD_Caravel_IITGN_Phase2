# Level-by-Level Complete Connection Tree for hkspi_tb.v

## Overview

This document traces the complete hierarchical structure starting from the `hkspi_tb.v` testbench, including all included files and module instantiations at every level.

---

## LEVEL 0: hkspi_tb.v (TESTBENCH ROOT)

### File: hkspi_tb.v
**Location:** `Day4/vsdRiscvScl180/dv/hkspi/hkspi_tb.v`

#### Includes:
```
├── __uprj_netlists.v              (user project definitions)
├── caravel_netlists.v             (caravel module definitions)
├── spiflash.v                     (SPI flash memory simulator)
└── tbuart.v                       (UART testbench monitor)
```

#### Instantiated Modules:
```
├── vsdcaravel (instance: uut)
├── spiflash (instance: spiflash)
└── tbuart (instance: tbuart)
```

#### Signals Driven by hkspi_tb:
- Clock generation (12.5 ns period)
- Power sequencing (power1, power2)
- Reset sequence (RSTB)
- SPI stimulus (SCK, CSB, SDI)
- VCD waveform capture

---

## LEVEL 1: Included Files from hkspi_tb.v

### 1.1 File: __uprj_netlists.v
**Location:** `Day4/vsdRiscvScl180/rtl/__uprj_netlists.v`

#### Includes:
```
├── defines.v                      (conditional compilation defines)
└── __user_project_wrapper.v       (RTL or GL version)
    └── (GL version): gl/__user_project_wrapper.v
```

#### Modules Defined:
```
└── user_project_wrapper
    └── [See Level 3.1]
```

---

### 1.2 File: caravel_netlists.v
**Location:** `Day4/vsdRiscvScl180/rtl/caravel_netlists.v`

#### Includes:
```
SECTION 1: Definitions & Pads
├── defines.v
├── user_defines.v
├── pads.v

SECTION 2: Core Components
├── digital_pll.v
├── caravel_clocking.v
├── user_id_programming.v
├── chip_io.v
├── housekeeping.v
├── mprj_logic_high.v
├── mprj2_logic_high.v
├── mgmt_protect.v
├── constant_block.v
├── gpio_control_block.v
├── gpio_defaults_block.v
├── gpio_logic_high.v
├── xres_buf.v
├── spare_logic_block.v

SECTION 3: Management Core
├── mgmt_core_wrapper.v
├── __user_project_wrapper.v

SECTION 4: Technology Libraries (SCL180)
├── pc3b03ed_wrapper.v
├── pc3d21.v
├── pc3d01_wrapper.v
├── pt3b02_wrapper.v

SECTION 5: PLL & Clocking (Duplicate includes)
├── digital_pll.v
├── digital_pll_controller.v
├── ring_osc2x13.v
├── caravel_clocking.v
├── user_id_programming.v
├── clock_div.v
├── mprj_io.v
├── chip_io.v

SECTION 6: Housekeeping & Management (Duplicate includes)
├── housekeeping_spi.v
├── housekeeping.v
├── mprj_logic_high.v
├── mprj2_logic_high.v
├── mgmt_protect.v
├── mgmt_protect_hv.v
```

#### Modules Defined (via includes):
```
├── digital_pll
│   └── [See Level 3.5]
├── caravel_clocking
│   └── [See Level 3.4]
├── chip_io
│   └── [See Level 2.1]
├── housekeeping
├── housekeeping_spi
├── mgmt_protect
├── mgmt_protect_hv
├── mgmt_core_wrapper
│   └── [See Level 3.1]
├── user_project_wrapper
│   └── [See Level 3.2]
├── digital_pll_controller
├── ring_osc2x13
├── clock_div
├── mprj_io
├── constant_block
├── gpio_control_block
├── gpio_defaults_block
├── gpio_logic_high
├── mprj_logic_high
├── mprj2_logic_high
├── xres_buf
├── spare_logic_block
├── user_id_programming
├── pc3b03ed_wrapper
├── pc3d01_wrapper
├── pc3d21
├── pt3b02_wrapper
└── vsdcaravel (NOT INCLUDED - defined elsewhere)
```

---

### 1.3 File: spiflash.v
**Location:** `Day4/vsdRiscvScl180/dv/spiflash.v`

#### Includes:
```
(No includes - behavioral module)
```

#### Modules Defined:
```
└── spiflash
    ├── Parameter: FILENAME ("hkspi.hex")
    ├── Ports:
    │   ├── csb (input)
    │   ├── clk (input)
    │   ├── io0 (inout) - MOSI
    │   ├── io1 (inout) - MISO
    │   ├── io2 (inout) - Write Protect
    │   └── io3 (inout) - Hold
    └── Behavioral Logic (no sub-modules)
```

---

### 1.4 File: tbuart.v
**Location:** `Day4/vsdRiscvScl180/dv/tbuart.v`

#### Includes:
```
(No includes - behavioral module)
```

#### Modules Defined:
```
└── tbuart
    ├── Port: ser_rx (input)
    └── Behavioral Logic (no sub-modules)
        └── Monitors UART output
```

---

## LEVEL 2: Top-Level Module (vsdcaravel)

### 2.1 File: vsdcaravel.v
**Location:** `Day4/vsdRiscvScl180/rtl/vsdcaravel.v`

#### Includes:
```
├── copyright_block.v              (graphic/branding)
├── caravel_logo.v                 (graphic/branding)
├── caravel_motto.v                (graphic/branding)
├── open_source.v                  (graphic/branding)
├── user_id_textblock.v            (graphic/branding)
└── caravel_core.v                 (core logic definition)
```

#### Modules Defined:
```
└── vsdcaravel
    └── [Includes caravel_core.v definition]
```

#### Instantiated Modules (inside vsdcaravel):
```
├── chip_io (instance: padframe)
│   └── [See Level 2.2]
└── caravel_core (instance: chip_core)
    └── [See Level 3]
```

---

### 2.2 File: chip_io.v
**Location:** `Day4/vsdRiscvScl180/rtl/chip_io.v`

#### Includes:
```
(Header & parameter definitions)
```

#### Modules Defined:
```
└── chip_io
    └── Pure RTL (no sub-module instantiations)
        └── Contains:
            ├── Power distribution pads
            ├── Clock pad
            ├── Reset pad
            ├── GPIO pad
            ├── User I/O pads (mprj_io[37:0])
            ├── Flash SPI pads
            ├── Input/Output buffers
            ├── ESD protection logic
            └── Pad voltage domain assignments
```

---

## LEVEL 3: Core Integration Layer

### 3.1 File: caravel_core.v
**Location:** `Day4/vsdRiscvScl180/rtl/caravel_core.v`

#### Includes:
```
(No external includes - uses parent includes)
```

#### Modules Defined:
```
└── caravel_core
```

#### Instantiated Modules (inside caravel_core):
```
├── mgmt_core_wrapper (instance: soc)
│   └── [See Level 4.1]
├── mgmt_protect (instance: mgmt_buffers)
│   └── [See Level 4.2]
├── user_project_wrapper (instance: mprj)
│   └── [See Level 4.3]
├── caravel_clocking (instance: clock_ctrl)
│   └── [See Level 4.4]
└── digital_pll (instance: pll)
    └── [See Level 4.5]
```

---

## LEVEL 4: Major Functional Blocks

### 4.1 File: mgmt_core_wrapper.v
**Location:** `Day4/vsdRiscvScl180/rtl/mgmt_core_wrapper.v`

#### Includes:
```
└── mgmt_core.v                    (actual processor core)
```

#### Modules Defined:
```
└── mgmt_core_wrapper
```

#### Instantiated Modules (inside mgmt_core_wrapper):
```
└── mgmt_core (instance: soc)
    └── [See Level 5.1]
```

---

### 4.2 File: mgmt_protect.v
**Location:** `Day4/vsdRiscvScl180/rtl/mgmt_protect.v`

#### Includes:
```
(No external includes)
```

#### Modules Defined:
```
└── mgmt_protect
```

#### Instantiated Modules:
```
└── Pure RTL Tri-state Buffers (no sub-module instantiations)
    ├── Clock domain buffers
    ├── Reset distribution buffers
    ├── Wishbone bus isolation buffers
    └── Power good monitoring logic
```

---

### 4.3 File: __user_project_wrapper.v
**Location:** `Day4/vsdRiscvScl180/rtl/__user_project_wrapper.v`

#### Includes:
```
├── defines.v
└── debug_regs.v
```

#### Modules Defined:
```
└── user_project_wrapper
```

#### Instantiated Modules (Conditional):
```
├── (Optional) user_project_la_example
│   └── [If LA_TESTING macro enabled]
└── (User Custom Logic)
    └── [Implementation-dependent]
```

---

### 4.4 File: caravel_clocking.v
**Location:** `Day4/vsdRiscvScl180/rtl/caravel_clocking.v`

#### Includes:
```
(No external includes)
```

#### Modules Defined:
```
└── caravel_clocking
```

#### Instantiated Modules:
```
└── Pure RTL Clock Multiplexer/Synchronizer
    ├── Clock multiplexer (external vs PLL)
    ├── Reset synchronizer
    ├── Dual-clock output generation
    └── No sub-module instantiations
```

---

### 4.5 File: digital_pll.v
**Location:** `Day4/vsdRiscvScl180/rtl/digital_pll.v`

#### Includes:
```
(No external includes)
```

#### Modules Defined:
```
└── digital_pll
```

#### Instantiated Modules:
```
└── Pure RTL PLL Logic
    ├── Oscillator control
    ├── Frequency divider
    ├── Trim circuit
    ├── Phase shift generation (90°)
    └── No sub-module instantiations
```

---

## LEVEL 5: Management SoC Core

### 5.1 File: mgmt_core.v
**Location:** `Day4/vsdRiscvScl180/rtl/mgmt_core.v`

#### Includes:
```
├── RAM256.v                       (256-word RAM memory)
├── RAM128.v                       (128-word RAM memory)
└── VexRiscv_MinDebugCache.v       (RISC-V processor core)
```

#### Modules Defined:
```
└── mgmt_core
    └── Contains all management SoC logic
```

#### Instantiated Modules (inside mgmt_core):
```
RISC-V PROCESSOR CORES:
├── VexRiscv_MinDebugCache (instance: vexriscv_cpu)
│   └── [See Level 6.1]
└── Alternatives (not instantiated in this version):
    ├── ibex_all (if selected)
    └── picorv32 (if selected)

MEMORY BLOCKS:
├── RAM256 (instance: RAM256)
│   └── 256×32-bit instruction memory
└── RAM128 (instance: RAM128)
    └── 128×32-bit data memory

PERIPHERAL LOGIC (Pure RTL - no sub-modules):
├── Housekeeping SPI Slave Interface
├── UART Controller
├── SPI Master Controller (Flash)
├── GPIO Controller
├── Interrupt Controller
├── Wishbone Bus Arbiter & Decoder
├── Bus Error Handler
├── Clock Divider
├── Reset Sequencing Logic
├── Debug Interface Handler
└── Various Control Registers
```

---

## LEVEL 6: Processor Core & Memory

### 6.1 File: VexRiscv_MinDebugCache.v
**Location:** `Day4/vsdRiscvScl180/rtl/VexRiscv_MinDebugCache.v`

#### Includes:
```
(No external includes)
```

#### Modules Defined:
```
└── VexRiscv_MinDebugCache
```

#### Instantiated Modules:
```
└── Pure RTL RISC-V Processor
    ├── Fetch Unit
    │   └── Instruction fetch logic
    ├── Decode Unit
    │   └── Instruction decoding
    ├── Execute Unit
    │   └── ALU and control logic
    ├── Memory Unit
    │   └── Bus interface
    ├── Writeback Unit
    │   └── Register updates
    ├── Register File
    │   └── 32×32-bit registers
    ├── Debug Interface
    │   └── Debug port
    ├── Cache (optional)
    │   └── Instruction/Data cache
    └── No sub-module instantiations (all RTL)
```

---

### 6.2 File: RAM256.v
**Location:** `Day4/vsdRiscvScl180/rtl/RAM256.v`

#### Includes:
```
(No external includes)
```

#### Modules Defined:
```
└── RAM256
    ├── Ports:
    │   ├── A0[7:0]    - Address (256 words)
    │   ├── CLK        - Clock
    │   ├── Di0[31:0]  - Data Input
    │   ├── EN0        - Enable
    │   ├── WE0        - Write Enable
    │   └── Do0[31:0]  - Data Output
    └── Pure Memory Logic (no sub-modules)
```

---

### 6.3 File: RAM128.v
**Location:** `Day4/vsdRiscvScl180/rtl/RAM128.v`

#### Includes:
```
(No external includes)
```

#### Modules Defined:
```
└── RAM128
    ├── Ports:
    │   ├── A0[6:0]    - Address (128 words)
    │   ├── CLK        - Clock
    │   ├── Di0[31:0]  - Data Input
    │   ├── EN0        - Enable
    │   ├── WE0        - Write Enable
    │   └── Do0[31:0]  - Data Output
    └── Pure Memory Logic (no sub-modules)
```

---

## Complete Hierarchical Tree (Compact View)

```
hkspi_tb.v (TESTBENCH ROOT)
│
├── INCLUDES:
│   ├── __uprj_netlists.v
│   │   └── includes:
│   │       └── __user_project_wrapper.v ◄ Level 4.3
│   ├── caravel_netlists.v
│   │   └── includes: [50+ files] ◄ See Level 1.2
│   ├── spiflash.v ◄ Level 1.3
│   └── tbuart.v ◄ Level 1.4
│
├── INSTANTIATES:
│   ├── vsdcaravel (instance: uut) ◄ Level 2
│   │   ├── INCLUDES:
│   │   │   └── caravel_core.v
│   │   └── INSTANTIATES:
│   │       ├── chip_io (padframe) ◄ Level 2.2
│   │       └── caravel_core (chip_core) ◄ Level 3
│   │           └── INSTANTIATES:
│   │               ├── mgmt_core_wrapper (soc) ◄ Level 4.1
│   │               │   ├── INCLUDES:
│   │               │   │   └── mgmt_core.v
│   │               │   └── INSTANTIATES:
│   │               │       └── mgmt_core ◄ Level 5.1
│   │               │           ├── INCLUDES:
│   │               │           │   ├── RAM256.v ◄ Level 6.2
│   │               │           │   ├── RAM128.v ◄ Level 6.3
│   │               │           │   └── VexRiscv_MinDebugCache.v ◄ Level 6.1
│   │               │           └── INSTANTIATES:
│   │               │               ├── RAM256 (instance: RAM256)
│   │               │               ├── RAM128 (instance: RAM128)
│   │               │               └── VexRiscv_MinDebugCache (instance: vexriscv_cpu)
│   │               │                   └── Pure RISC-V RTL (no sub-modules)
│   │               │
│   │               ├── mgmt_protect (mgmt_buffers) ◄ Level 4.2
│   │               │   └── Pure RTL Tri-state logic (no sub-modules)
│   │               │
│   │               ├── user_project_wrapper (mprj) ◄ Level 4.3
│   │               │   ├── INCLUDES:
│   │               │   │   ├── defines.v
│   │               │   │   └── debug_regs.v
│   │               │   └── INSTANTIATES:
│   │               │       └── (Optional) user_project_la_example
│   │               │
│   │               ├── caravel_clocking (clock_ctrl) ◄ Level 4.4
│   │               │   └── Pure RTL Clock logic (no sub-modules)
│   │               │
│   │               └── digital_pll (pll) ◄ Level 4.5
│   │                   └── Pure RTL PLL logic (no sub-modules)
│   │
│   ├── spiflash (instance: spiflash) ◄ Level 1.3
│   │   └── Behavioral SPI Flash Model (no sub-modules)
│   │       └── Reads firmware from: hkspi.hex
│   │
│   └── tbuart (instance: tbuart) ◄ Level 1.4
│       └── UART Monitoring Utility (no sub-modules)
│           └── Captures serial output
│
└── END OF HIERARCHY
```

---

## File Dependency Summary

### By Hierarchy Level:

**LEVEL 0 (Testbench):**
- hkspi_tb.v

**LEVEL 1 (Testbench Includes):**
- __uprj_netlists.v
- caravel_netlists.v
- spiflash.v
- tbuart.v

**LEVEL 2 (Top-Level SoC):**
- vsdcaravel.v
  - chip_io.v
  - caravel_core.v

**LEVEL 3 (Core Integration):**
- caravel_core.v (module only)

**LEVEL 4 (Major Blocks):**
- mgmt_core_wrapper.v
  - mgmt_core.v (included)
- mgmt_protect.v
- __user_project_wrapper.v
- caravel_clocking.v
- digital_pll.v

**LEVEL 5 (Management SoC):**
- mgmt_core.v (module)
  - RAM256.v (included)
  - RAM128.v (included)
  - VexRiscv_MinDebugCache.v (included)

**LEVEL 6 (Leaf Modules):**
- VexRiscv_MinDebugCache.v
- RAM256.v
- RAM128.v

---

## Module Instantiation Count

| Module | Instances | Location |
|---|---|---|
| vsdcaravel | 1 | hkspi_tb |
| chip_io | 1 | vsdcaravel |
| caravel_core | 1 | vsdcaravel |
| mgmt_core_wrapper | 1 | caravel_core |
| mgmt_core | 1 | mgmt_core_wrapper |
| mgmt_protect | 1 | caravel_core |
| user_project_wrapper | 1 | caravel_core |
| caravel_clocking | 1 | caravel_core |
| digital_pll | 1 | caravel_core |
| RAM256 | 1 | mgmt_core |
| RAM128 | 1 | mgmt_core |
| VexRiscv_MinDebugCache | 1 | mgmt_core |
| spiflash | 1 | hkspi_tb |
| tbuart | 1 | hkspi_tb |
| **TOTAL** | **15** | |

---

## Critical Path (Deepest Nesting)

```
hkspi_tb
    └── vsdcaravel (uut)
            └── caravel_core (chip_core)
                    └── mgmt_core_wrapper (soc)
                            └── mgmt_core
                                    └── VexRiscv_MinDebugCache (vexriscv_cpu)
                                            └── RISC-V processor internals

Nesting Depth: 6 levels
```

---

## Key Design Observations

1. **Single Instantiation Pattern**: Each module instantiated only once (no replication)

2. **Clear Hierarchy**: Linear hierarchy from testbench down to processor core

3. **Three Testbench Components**:
   - `vsdcaravel` (DUT - full chip)
   - `spiflash` (External memory simulator)
   - `tbuart` (UART monitor)

4. **Two Power Domains**:
   - Management domain (vccd) via mgmt_core_wrapper
   - User domain (vccd1/vccd2) via user_project_wrapper

5. **Clock Management**: Single clock source multiplexed through caravel_clocking

6. **Reset Synchronization**: Single reset distributed via caravel_clocking and mgmt_protect

7. **No Parameterized Recursion**: No modules instantiate multiple copies of themselves

8. **Leaf Modules**:
   - Pure RTL (no sub-modules): chip_io, mgmt_protect, caravel_clocking, digital_pll, VexRiscv_MinDebugCache
   - Behavioral (simulation): spiflash, tbuart
   - Memory (structural): RAM256, RAM128

---

## Conclusion

The `hkspi_tb` testbench instantiates a **6-level deep** hierarchical design with **15 total module instances**. The design follows a clean parent-child relationship pattern with no circular dependencies or multi-level replication. All leaf modules are either pure RTL, behavioral simulators, or memory blocks.

