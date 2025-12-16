# Module Hierarchy Analysis: hkspi_tb.v

## Stage 1: Complete Module Instantiation Hierarchy

### Hierarchy Tree (Parent → Children)

```
hkspi_tb (TESTBENCH)
  ├── vsdcaravel (Top-Level SoC)
  ├── spiflash (SPI Flash Memory Model)
  └── tbuart (UART Testbench Module)
```

---

## Detailed Module Breakdown

### Level 1: hkspi_tb Module

**Type:** Testbench (Simulation-only module)  
**File Location:** `Day4/vsdRiscvScl180/dv/hkspi/hkspi_tb.v`

**Purpose:**
- Top-level testbench for verifying Housekeeping SPI functionality
- Instantiates the complete Caravel SoC design
- Drives test stimulus through SPI interface (SCK, SDI, CSB signals)
- Monitors and validates register read/write operations

**Instantiated Modules:**
1. **vsdcaravel** (instance name: `uut`)
2. **spiflash** (instance name: `spiflash`)
3. **tbuart** (instance name: `tbuart`)

**Testbench Signals:**
- Clock: `clock` (12.5 ns period)
- Power: `power1` (3.3V), `power2` (1.8V)
- Reset: `RSTB`
- SPI Interface: `SCK`, `SDI`, `CSB`, `SDO`
- GPIO: `gpio`, `mprj_io[37:0]`
- UART: `uart_tx`, `uart_rx`
- Flash SPI: `flash_csb`, `flash_clk`, `flash_io0`, `flash_io1`, `flash_io2`, `flash_io3`

**Test Operations:**
- Power-up sequence simulation
- Housekeeping SPI register read/write
- External reset toggling
- Multi-register read verification (registers 0-18)
- VCD waveform generation (`hkspi.vcd`)

---

### Level 2a: vsdcaravel Module

**Type:** Top-level SoC module  
**File Location:** `Day4/vsdRiscvScl180/rtl/vsdcaravel.v`

**Purpose:**
- Complete Caravel SoC implementation with VSD/SCL180 PDK
- Integrates all core functionality and I/O pads
- Includes chip I/O pad frame and core logic

**Instantiated Modules:**
1. **chip_io** (instance name: `padframe`)
2. **caravel_core** (instance name: `chip_core`)

**Top-Level I/O Ports:**
- Power: `vddio`, `vddio_2`, `vddio_1`, `vssio`, `vssio_2`
- Analog Power: `vdda`, `vdda1`, `vdda1_2`, `vdda2`, `vssa`, `vssa1`, `vssa1_2`, `vssa2`
- Digital Power: `vccd`, `vccd1`, `vccd2`, `vssd`, `vssd1`, `vssd2`
- Clock: `clock`
- GPIO: `gpio`
- User I/O: `mprj_io[37:0]`
- Flash SPI: `flash_csb`, `flash_clk`, `flash_io0`, `flash_io1`, `flash_io2`, `flash_io3`
- Reset: `resetb`

**Includes:**
- `copyright_block.v`
- `caravel_logo.v`
- `caravel_motto.v`
- `open_source.v`
- `user_id_textblock.v`
- `caravel_core.v` (top-level module definition)

---

### Level 2b: caravel_core Module

**Type:** Core logic integration module  
**File Location:** `Day4/vsdRiscvScl180/rtl/caravel_core.v`

**Purpose:**
- Integrates management processor, user project wrapper, and control logic
- Manages clock distribution and PLL control
- Handles power sequencing and reset distribution
- Routes SPI and Wishbone bus signals

**Instantiated Modules:**
1. **mgmt_core_wrapper** (instance name: `soc`)
2. **mgmt_protect** (instance name: `mgmt_buffers`)
3. **user_project_wrapper** (instance name: `mprj`)
4. **caravel_clocking** (instance name: `clock_ctrl`)
5. **digital_pll** (instance name: `pll`)
6. **housekeeping** (included but functionality integrated in mgmt_core_wrapper)

**Key Internal Signals:**
- Clock distribution: `caravel_clk`, `caravel_clk2`, `caravel_rstn`
- SPI Flash control: `flash_csb_core`, `flash_clk_core`, `flash_io[0-3]_*`
- Wishbone Bus: `mprj_cyc_o`, `mprj_stb_o`, `mprj_we_o`, `mprj_adr_o`, `mprj_dat_*`
- PLL control: `spi_pll_ena`, `spi_pll_sel`, `spi_pll_div`, `spi_pll_trim`
- User project: `user_irq`, `user_irq_ena`, `la_*` (Logic Analyzer)

---

### Level 3a: mgmt_core_wrapper Module

**Type:** Management core wrapper (instantiates RISC-V processor)  
**File Location:** `Day4/vsdRiscvScl180/rtl/mgmt_core_wrapper.v`

**Purpose:**
- Wraps the management RISC-V processor core
- Provides pin-compatible interface with Caravel harness
- Handles bus interface adaptation and signal routing

**Includes:**
- `mgmt_core.v` (actual processor implementation)

**Instantiated Sub-modules:**
- **mgmt_core** (RISC-V processor core - See Level 4)

**Key Interfaces:**
- Clock/Reset: `core_clk`, `core_rstn`
- GPIO: `gpio_out_pad`, `gpio_in_pad`, `gpio_mode0/1_pad`, `gpio_outenb/inenb_pad`
- Flash SPI Master: `flash_csb`, `flash_clk`, `flash_io[0-3]_*` (tristate control)
- Wishbone Master: `mprj_cyc_o`, `mprj_stb_o`, `mprj_we_o`, `mprj_sel_o`, `mprj_adr_o`, `mprj_dat_*`
- Housekeeping Slave: `hk_cyc_o`, `hk_stb_o`, `hk_dat_i`, `hk_ack_i`
- IRQ: `irq[1:0]` (SPI + User IRQ), `user_irq_ena`
- UART: `ser_tx`, `ser_rx`
- SPI Master: `spi_sdi`, `spi_csb`, `spi_sck`, `spi_sdo`, `spi_sdoenb`
- Logic Analyzer: `la_input`, `la_output`, `la_oenb`, `la_iena`
- SRAM Read-Only: `sram_ro_clk`, `sram_ro_csb`, `sram_ro_addr`, `sram_ro_data` (optional)

---

### Level 3b: mgmt_protect Module

**Type:** Management protection and buffering logic  
**File Location:** `Day4/vsdRiscvScl180/rtl/mgmt_protect.v`

**Purpose:**
- Implements tri-state buffers and protection logic
- Isolates management domain from user domain
- Handles cross-domain clock and reset distribution
- Routes Wishbone signals with proper isolation

**Key Signals Buffered:**
- Clock domain signals: `caravel_clk`, `caravel_clk2`, `caravel_rstn`
- User domain isolation signals
- Wishbone bus pass-through
- Power good monitoring: `user1_vcc_powergood`, `user2_vcc_powergood`, etc.

---

### Level 3c: user_project_wrapper Module

**Type:** User project integration wrapper  
**File Location:** `Day4/vsdRiscvScl180/rtl/__user_project_wrapper.v`

**Purpose:**
- Provides interface to user-defined project area
- Isolates user logic from core Caravel infrastructure
- Handles Wishbone slave interface for user project access

**Instantiated Sub-modules:**
- User project custom logic (implementation-dependent)
- May instantiate example projects:
  - `__user_project_gpio_example`
  - `__user_project_la_example`
  - Custom user module

**Key Interfaces:**
- Power: `vdda1`, `vdda2`, `vssa1`, `vssa2`, `vccd1`, `vccd2`, `vssd1`, `vssd2`
- Clock/Reset: `wb_clk_i`, `wb_rst_i`
- Wishbone Slave: `wbs_*` (standard Wishbone signals)
- Logic Analyzer: `la_*` (input/output/output enable)
- Misc I/O: Custom user-defined signals

---

### Level 3d: caravel_clocking Module

**Type:** Clock distribution and multiplexing  
**File Location:** `Day4/vsdRiscvScl180/rtl/caravel_clocking.v`

**Purpose:**
- Multiplexes between external clock and PLL-generated clock
- Implements synchronous reset generation
- Provides dual-frequency clock output (`core_clk`, `user_clk`)

**Key Features:**
- External clock selection: `ext_clk_sel`
- PLL clock input: `pll_clk`, `pll_clk90`
- Reset synchronization: `porb`, `resetb`
- Output clocks: `core_clk` (main), `user_clk` (secondary)
- Synchronized reset: `resetb_sync`

---

### Level 3e: digital_pll Module

**Type:** Digital Phase-Locked Loop (DCO)  
**File Location:** `Day4/vsdRiscvScl180/rtl/digital_pll.v`

**Purpose:**
- Generates stable clock from external oscillator
- Provides configurable frequency division
- Implements trimming for frequency adjustment

**Key Inputs/Outputs:**
- Oscillator input: `osc`
- Enable: `enable`
- Reset: `resetb`
- Output clocks: `clockp[1:0]` (main clock + 90° phase)
- Divisor: `div[4:0]`
- Trim: `ext_trim[25:0]`
- DCO enable: `dco`

---

### Level 4: mgmt_core Module

**Type:** RISC-V processor core + SoC logic  
**File Location:** `Day4/vsdRiscvScl180/rtl/mgmt_core.v`

**Purpose:**
- Main management SoC processor
- Handles system control and housekeeping functions
- Implements SPI flash controller
- Manages peripheral interfaces (UART, SPI)
- Provides Wishbone master interface for user project access

**Likely Instantiated Sub-modules:**
1. **RISC-V Processor Core** - One of:
   - `ibex_all` (Ibex processor)
   - `picorv32` (PicoRISV processor)
   - `VexRiscv_MinDebugCache` (VexRISCV)
   
2. **Memory Modules:**
   - `RAM256` or `RAM128` (instruction and data memory)
   
3. **Peripheral Controllers:**
   - **housekeeping_spi** (SPI interface to external Housekeeping)
   - **uart** (UART interface)
   - **spi_master** (SPI master controller for flash)
   - **gpio_logic** (GPIO control)
   
4. **System Components:**
   - Clock dividers
   - Reset sequencing logic
   - Interrupt controller
   - Wishbone arbiter/decoder

**Key Interfaces:**
- Clock/Reset: `core_clk`, `core_rstn`
- SPI Flash: 4-wire SPI interface
- Wishbone Master: Full 32-bit bus
- Housekeeping SPI Slave: External SPI interface
- UART: Serial interface
- GPIO: Control signals
- IRQ: Interrupt inputs

---

### Level 5: Processor Core Modules (Leaf Nodes)

Based on codebase analysis, the mgmt_core likely instantiates one of:

#### Option A: ibex_all (Ibex RISC-V)
**File Location:** `Day4/vsdRiscvScl180/rtl/ibex_all.v`
- 32-bit RISC-V processor
- Contains: execution unit, fetch unit, decode unit, register file, control logic

#### Option B: picorv32 (PicoRISV)
**File Location:** `Day4/vsdRiscvScl180/rtl/picorv32.v`
- Lightweight 32-bit RISC-V processor
- Minimal footprint implementation

#### Option C: VexRiscv_MinDebugCache
**File Location:** `Day4/vsdRiscvScl180/rtl/VexRiscv_MinDebugCache.v`
- Feature-rich RISC-V processor
- Includes debug and cache capabilities

---

### Level 2c: chip_io Module

**Type:** I/O pad frame  
**File Location:** `Day4/vsdRiscvScl180/rtl/chip_io.v`

**Purpose:**
- Defines all physical I/O pad connections
- Implements ESD protection
- Routes signals between internal logic and package pins
- Manages pad voltage domains

**Key Pad Groups:**
- Power pads: `vddio`, `vssio`, `vdda`, `vssa`, `vccd`, `vssd`, etc.
- Clock pad: `clock`
- Reset pad: `resetb`
- GPIO pad: `gpio`
- User project I/O: `mprj_io[37:0]` (up to 38 pins)
- Flash SPI pads: `flash_csb`, `flash_clk`, `flash_io[0-3]`

**Sub-components:**
- Input buffers for each pad
- Output drivers for each pad
- Tri-state control logic
- ESD diode protection networks
- Voltage domain isolation

---

### Level 2d: spiflash Module

**Type:** Behavioral SPI flash memory simulator  
**File Location:** `Day4/vsdRiscvScl180/dv/spiflash.v`

**Purpose:**
- Simulates external SPI flash memory device
- Responds to SPI read/write commands
- Provides memory content from hex file
- Used in simulation only (not synthesized)

**Parameters:**
- `FILENAME`: Path to hex file containing firmware (`hkspi.hex`)

**Ports:**
- `csb`: Chip select (active low)
- `clk`: SPI clock
- `io0`: MOSI line (Master Out, Slave In)
- `io1`: MISO line (Master In, Slave Out)
- `io2`: Write protect (not used)
- `io3`: Hold (not used)

**Operations Supported:**
- Read from address
- Write to address
- Erase operations
- Mode switching (single/dual/quad SPI)

---

### Level 2e: tbuart Module

**Type:** UART testbench utility  
**File Location:** `Day4/vsdRiscvScl180/dv/tbuart.v`

**Purpose:**
- Monitors UART output from design
- Captures and displays serial data
- Useful for debugging and verification
- Simulation-only utility module

**Ports:**
- `ser_rx`: UART RX input (receives data from DUT)

**Functionality:**
- Prints received UART characters to console
- Logs serial communication for debugging
- Non-synthesizable simulation artifact

---

## Complete Module Hierarchy Summary Table

| Hierarchy Level | Module Name | Type | Location | Purpose |
|---|---|---|---|---|
| **0** | `hkspi_tb` | Testbench | `dv/hkspi/hkspi_tb.v` | Top-level test stimulus |
| **1** | `vsdcaravel` | Top-level SoC | `rtl/vsdcaravel.v` | Complete SoC with I/O frame |
| **2a** | `chip_io` | I/O Frame | `rtl/chip_io.v` | Physical pad connections |
| **2b** | `caravel_core` | Core Logic | `rtl/caravel_core.v` | System integration |
| **3a** | `mgmt_core_wrapper` | Processor Wrapper | `rtl/mgmt_core_wrapper.v` | Management processor interface |
| **3b** | `mgmt_protect` | Protection Logic | `rtl/mgmt_protect.v` | Domain isolation buffers |
| **3c** | `user_project_wrapper` | User Interface | `rtl/__user_project_wrapper.v` | User project integration |
| **3d** | `caravel_clocking` | Clock Control | `rtl/caravel_clocking.v` | Clock multiplexing & distribution |
| **3e** | `digital_pll` | PLL | `rtl/digital_pll.v` | Frequency generation |
| **4** | `mgmt_core` | RISC-V SoC | `rtl/mgmt_core.v` | Processor + peripherals |
| **5** | `ibex_all` | Processor Core | `rtl/ibex_all.v` | RISC-V execution (if selected) |
| **1b** | `spiflash` | Flash Simulator | `dv/spiflash.v` | SPI flash memory model |
| **1c** | `tbuart` | UART Monitor | `dv/tbuart.v` | Serial output capture |

---

## Module Instantiation Matrix

### hkspi_tb instantiates:
```
vsdcaravel (uut)
  └─ vsdcaravel.chip_io (padframe)
  └─ vsdcaravel.caravel_core (chip_core)
     ├─ caravel_core.mgmt_core_wrapper (soc)
     │  └─ mgmt_core_wrapper.mgmt_core [RISC-V Core]
     ├─ caravel_core.mgmt_protect (mgmt_buffers)
     ├─ caravel_core.user_project_wrapper (mprj)
     ├─ caravel_core.caravel_clocking (clock_ctrl)
     └─ caravel_core.digital_pll (pll)

spiflash (spiflash)
  └─ [Behavioral model - no sub-modules]

tbuart (tbuart)
  └─ [Behavioral model - no sub-modules]
```

---

## Signal Connectivity Overview

### Top-Level Connections (hkspi_tb → vsdcaravel)

**Power Distribution:**
- `power1` → `VDD3V3` → all `vddio` ports
- `power2` → `VDD1V8` → all `vccd` ports
- `VSS` (ground) → all ground ports

**Clock & Reset:**
- `clock` → `vsdcaravel.clock`
- `RSTB` → `vsdcaravel.resetb`

**SPI Housekeeping Interface:**
- `SCK` → `mprj_io[4]` → Housekeeping SCK
- `CSB` → `mprj_io[3]` → Housekeeping CSB
- `SDI` → `mprj_io[2]` → Housekeeping SDI
- `SDO` ← `mprj_io[1]` ← Housekeeping SDO

**UART Output:**
- `uart_tx` ← `mprj_io[6]` ← Management UART TX

**Flash SPI:**
- `flash_csb` ← SPI flash chip select
- `flash_clk` ← SPI flash clock
- `flash_io0` ↔ SPI flash data line 0
- `flash_io1` ↔ SPI flash data line 1

### Internal Connectivity (caravel_core)

**mgmt_core_wrapper → user_project_wrapper:**
- Wishbone Bus: `mprj_cyc_o`, `mprj_stb_o`, `mprj_we_o`, `mprj_sel_o`, `mprj_adr_o`, `mprj_dat_o/i`, `mprj_ack_i`
- Clock: `wb_clk_i` ← `caravel_clk`
- Reset: `wb_rst_i` ← `caravel_rstn`
- IRQ: User interrupt signals

**caravel_clocking → mgmt_core_wrapper:**
- Core clock: `core_clk` ← `caravel_clk`
- Core reset: `core_rstn` ← `caravel_rstn`

**digital_pll → caravel_clocking:**
- PLL output: `pll_clk`, `pll_clk90` → clock input

**mgmt_protect:**
- Buffers all cross-domain signals
- Implements isolation between management and user domains

---

## Synthesis vs. Simulation Notes

**Synthesizable Modules:**
- `vsdcaravel`, `chip_io`, `caravel_core`
- `mgmt_core_wrapper`, `mgmt_core`, `mgmt_protect`
- `user_project_wrapper`
- `caravel_clocking`, `digital_pll`
- Processor cores (`ibex_all`, `picorv32`, etc.)
- All memory and control logic

**Simulation-Only Modules:**
- `hkspi_tb` (testbench)
- `spiflash` (behavioral SPI flash model)
- `tbuart` (UART monitoring utility)

---

## File Dependencies

```
hkspi_tb.v
├── __uprj_netlists.v (includes user project definitions)
├── caravel_netlists.v (includes caravel module definitions)
├── spiflash.v (includes SPI flash simulator)
└── tbuart.v (includes UART testbench)

vsdcaravel.v
├── copyright_block.v
├── caravel_logo.v
├── caravel_motto.v
├── open_source.v
├── user_id_textblock.v
└── caravel_core.v (module definition)

caravel_core.v
├── mgmt_core_wrapper.v
├── mgmt_protect.v
├── user_project_wrapper.v
├── caravel_clocking.v
└── digital_pll.v

mgmt_core_wrapper.v
└── mgmt_core.v

mgmt_core.v
├── housekeeping_spi.v (likely)
├── ibex_all.v (or picorv32.v or VexRiscv_MinDebugCache.v)
├── RAM256.v / RAM128.v
└── Various peripheral controllers
```

---

## Conclusion

The **hkspi_tb** testbench is structured as a comprehensive test environment that:

1. **Instantiates** the complete `vsdcaravel` SoC
2. **Simulates** external components (`spiflash`, `tbuart`)
3. **Drives** test stimulus through well-defined interfaces
4. **Monitors** responses via SPI and UART
5. **Validates** register values and system behavior

The hierarchy spans **5+ levels** from the top-level testbench down to individual RISC-V processor cores, with clear separation between synthesis-ready design modules and simulation-only verification infrastructure.

