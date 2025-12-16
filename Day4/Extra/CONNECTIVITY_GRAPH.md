# Module Connectivity Graph & Visual Hierarchy

## Stage 2: Complete Connectivity & Connection Structure

---

## ASCII Hierarchy Tree (Full Structure)

```
hkspi_tb (TESTBENCH - Simulation Top Level)
│
├─────────────── INSTANTIATES ──────────────┐
│                                           │
├── vsdcaravel (uut) ◄────────┐            │
│   │                          │            │
│   ├── chip_io (padframe)     │            │
│   │   │                      │            │
│   │   └─→ [Pad routing]      │            │
│   │                          │            │
│   └── caravel_core (chip_core)             │
│       │                                    │
│       ├── mgmt_core_wrapper (soc)         │
│       │   │                                │
│       │   └── mgmt_core                   │
│       │       │                            │
│       │       ├── [RISC-V Core]           │
│       │       │   ├── ibex_all (RTL)      │
│       │       │   ├── picorv32 (RTL)      │
│       │       │   └── VexRiscv (RTL)      │
│       │       │                            │
│       │       ├── housekeeping_spi        │
│       │       ├── spi_master              │
│       │       ├── uart                    │
│       │       ├── gpio_logic              │
│       │       ├── RAM256                  │
│       │       ├── RAM128                  │
│       │       ├── Wishbone Arbiter        │
│       │       └── Interrupt Controller    │
│       │                                    │
│       ├── mgmt_protect (mgmt_buffers)     │
│       │   │                                │
│       │   └─→ [Tri-state Buffers]         │
│       │       [Domain Isolation]          │
│       │                                    │
│       ├── user_project_wrapper (mprj)     │
│       │   │                                │
│       │   └── [User Custom Logic]         │
│       │       ├── __user_project_gpio_example  │
│       │       ├── __user_project_la_example    │
│       │       └── Custom User Module          │
│       │                                    │
│       ├── caravel_clocking (clock_ctrl)   │
│       │   │                                │
│       │   └─→ [Clock Multiplexer]         │
│       │       [Reset Synchronizer]        │
│       │                                    │
│       └── digital_pll (pll)               │
│           │                                │
│           └─→ [PLL Logic]                 │
│               [Frequency Divider]         │
│               [Trim Circuit]              │
│                                            │
├── spiflash (spiflash)                     │
│   └─→ [Behavioral SPI Flash Model]        │
│       [Reads hkspi.hex]                   │
│                                            │
└── tbuart (tbuart)                         │
    └─→ [UART Monitoring Utility]           │
        [Serial Output Capture]             │
```

---

## Detailed Module Connection Graph

### Graph 1: Power Distribution

```
Power Sources (hkspi_tb)
│
├─ power1 (3.3V)
│  ├─→ vsdcaravel.vddio
│  ├─→ vsdcaravel.vddio_2
│  ├─→ vsdcaravel.vdda
│  ├─→ vsdcaravel.vdda1
│  ├─→ vsdcaravel.vdda1_2
│  ├─→ vsdcaravel.vdda2
│  └─→ All pad frame power rails
│
├─ power2 (1.8V)
│  ├─→ vsdcaravel.vccd
│  ├─→ vsdcaravel.vccd1
│  └─→ vsdcaravel.vccd2
│
└─ VSS (Ground)
   ├─→ vsdcaravel.vssio
   ├─→ vsdcaravel.vssio_2
   ├─→ vsdcaravel.vssa
   ├─→ vsdcaravel.vssa1
   ├─→ vsdcaravel.vssa2
   ├─→ vsdcaravel.vssd
   ├─→ vsdcaravel.vssd1
   └─→ vsdcaravel.vssd2
```

### Graph 2: Clock Distribution

```
External Clock (hkspi_tb)
│
└─→ vsdcaravel.clock
    └─→ caravel_core.clock_core
        │
        ├─→ caravel_clocking (clock_ctrl)
        │   ├─→ caravel_clk (main core clock)
        │   └─→ caravel_clk2 (user clock)
        │
        └─→ digital_pll
            ├─ Input: clock_core (oscillator)
            ├─ Output: pll_clk
            ├─ Output: pll_clk90
            └─→ (back to caravel_clocking)

Clock Distribution:
┌─────────────────────────┐
│   caravel_clocking      │
│   (Multiplexer)         │
└──────────┬──────────────┘
           │
    ┌──────┴──────┐
    │             │
    ▼             ▼
caravel_clk   caravel_clk2
    │             │
    │             │
    ├─→ mgmt_core_wrapper ──→ mgmt_core ──→ All internal modules
    │              
    └─→ mgmt_protect ────────→ user_project_wrapper
    
    └─→ caravel_clocking (feedback)
```

### Graph 3: Reset Distribution

```
Reset Input (hkspi_tb)
│
└─→ vsdcaravel.resetb
    └─→ caravel_core.rstb_l
        │
        ├─→ caravel_clocking (clock_ctrl)
        │   └─→ caravel_rstn (synchronized reset)
        │
        ├─→ digital_pll
        │   └─→ resetb
        │
        └─→ Distribution Network
            ├─→ mgmt_core_wrapper.core_rstn
            ├─→ mgmt_protect.caravel_rstn
            └─→ user_project_wrapper.wb_rst_i

Reset Sequence:
RSTB (async)
    │
    ├─→ [Synchronizer]
    │
    ▼
caravel_rstn (sync)
    │
    ├─→ [Buffer 1] ──→ mgmt_core_wrapper
    │
    ├─→ [Buffer 2] ──→ user_project_wrapper
    │
    └─→ [Buffer N] ──→ Other modules
```

### Graph 4: SPI Housekeeping Interface

```
SPI Test Stimulus (hkspi_tb)
│
├─ SCK ────────→ mprj_io[4] ────→ chip_io.padframe ────→ caravel_core.hk_sck
│
├─ CSB ────────→ mprj_io[3] ────→ chip_io.padframe ────→ caravel_core.hk_csb
│
├─ SDI ────────→ mprj_io[2] ────→ chip_io.padframe ────→ mgmt_core_wrapper
│                                                        │
│                                                        └─→ mgmt_core
│                                                            │
│                                                            └─→ housekeeping_spi
│                                                                (SPI Slave)
│
└─ SDO ◄────── mprj_io[1] ◄──── chip_io.padframe ◄──── mgmt_core
                                                        │
                                                        └─ SPI output

SPI Housekeeping Communication Path:
┌──────────────┐
│   hkspi_tb   │
│  Test Logic  │
└──────┬───────┘
       │ (drives SCK, CSB, SDI)
       │
       ▼
┌──────────────────────┐
│  chip_io (padframe)  │
│   [Pad Buffers]      │
└──────┬───────────────┘
       │
       ▼
┌──────────────────────────┐
│   caravel_core           │
│   [Routing & Muxing]     │
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────────┐
│   mgmt_core_wrapper          │
│   mgmt_core                  │
│   [housekeeping_spi module]  │
│   [SPI Slave Interface]      │
└──────────────────────────────┘
       │
       └─→ Processes SPI commands
           Reads/Writes registers
           Returns SDO response
```

### Graph 5: Wishbone Bus Architecture

```
Wishbone Master (mgmt_core)
│
├── Wishbone Bus ──────────────────────┐
│   [Signals: cyc, stb, we, sel, adr]  │
│   [Data: dat_o, dat_i]               │
│   [Response: ack]                    │
│                                       │
└──────────────────────────────────────┤
                                        │
                    ┌───────────────────┘
                    │
                    ▼
        ┌──────────────────────┐
        │  mgmt_protect        │
        │  [Bus Isolation]     │
        │  [Tri-state Buffers] │
        └──────────┬───────────┘
                   │
                   ▼
        ┌──────────────────────────────┐
        │  user_project_wrapper (mprj) │
        │  [Wishbone Slave Interface]  │
        │                              │
        │  Controls:                   │
        │  - User GPIO                 │
        │  - Custom Logic              │
        │  - User Wishbone Slaves      │
        └──────────────────────────────┘

Full Wishbone Bus Connectivity:
mgmt_core (Master)
    │
    ├─→ mprj_cyc_o (cycle)
    ├─→ mprj_stb_o (strobe)
    ├─→ mprj_we_o (write enable)
    ├─→ mprj_sel_o (byte select)
    ├─→ mprj_adr_o (address)
    ├─→ mprj_dat_o (data out)
    │
    └─← mprj_ack_i (acknowledge)
    └─← mprj_dat_i (data in)
```

### Graph 6: UART Interface

```
UART Output Path:
┌────────────────────┐
│   mgmt_core        │
│   [UART TX]        │
└──────┬─────────────┘
       │
       │ ser_tx (serial data)
       │
       ▼
┌──────────────────────┐
│  caravel_core        │
│  [Signal Routing]    │
└──────┬───────────────┘
       │
       ├─→ mprj_io[6]
       │
       ▼
┌──────────────────────┐
│  chip_io (padframe)  │
│  [UART Pad Buffer]   │
└──────┬───────────────┘
       │
       │ uart_tx (physical pin)
       │
       ▼
┌──────────────────────┐
│  hkspi_tb            │
│  uart_tx (signal)    │
└──────┬───────────────┘
       │
       ▼
┌──────────────────────┐
│  tbuart (monitor)    │
│  .ser_rx(uart_tx)    │
│  [Captures UART]     │
└──────────────────────┘

UART messages captured and logged
for debugging & verification
```

### Graph 7: Flash SPI Interface

```
Internal SPI Master (mgmt_core)
│
├── flash_csb ────────────────────┐
├── flash_clk ────────────────────┤
├── flash_io0_do (MOSI) ──────────┼─→ [Tristate Control Logic]
├── flash_io0_oe ────────────────┤
├── flash_io1_di (MISO) ◄─────────┤
├── flash_io2_* ──────────────────┤
└── flash_io3_* ──────────────────┘
                                   │
                                   ▼
                        ┌──────────────────┐
                        │   caravel_core   │
                        │  [Pin Routing]   │
                        └─────┬────────────┘
                              │
                              ▼
                    ┌──────────────────────┐
                    │  chip_io (padframe)  │
                    │ [Flash Pad Buffers]  │
                    └─────┬────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
        ▼                 ▼                 ▼
    flash_csb        flash_clk          flash_io[0:3]
        │                 │                 │
        ▼                 ▼                 ▼
    ┌─────────────────────────────────┐
    │   spiflash (simulator)          │
    │                                 │
    │  .csb(flash_csb)                │
    │  .clk(flash_clk)                │
    │  .io0(flash_io0) ◄─→ MOSI/MISO  │
    │  .io1(flash_io1) ◄─→ MOSI/MISO  │
    │  .io2() [unused]                │
    │  .io3() [unused]                │
    │                                 │
    │  Emulates Flash Behavior:       │
    │  - Read from hkspi.hex          │
    │  - Respond to SPI commands      │
    │  - Provide firmware bootcode    │
    └─────────────────────────────────┘
```

### Graph 8: Interrupt Distribution

```
Interrupt Sources:
┌──────────────────────────────┐
│   mgmt_core (SPI IRQ)        │
└──────────┬───────────────────┘
           │
           ├─ irq_spi (SPI interrupt)
           │
           ▼
┌──────────────────────────────────────┐
│   caravel_core                       │
│   [IRQ Multiplexer]                  │
└──────────┬──────────────────────────┘
           │
           ├─→ irq[0] = irq_spi
           ├─→ irq[1] = user_irq
           │
           ▼
┌──────────────────────────────────────┐
│   mgmt_core_wrapper.mgmt_core        │
│   [Interrupt Controller]             │
│   - Processes IRQ[1:0]               │
│   - Sets interrupt flags             │
│   - Routes to processor              │
└──────────────────────────────────────┘

User IRQ Path:
┌────────────────────────────┐
│   user_project_wrapper     │
│   [User Custom Logic]      │
└──────────┬─────────────────┘
           │
           └─ user_irq (from user project)
              │
              ▼
           caravel_core
              │
              └─→ mgmt_core_wrapper
```

### Graph 9: Logic Analyzer (LA) Path

```
Logic Analyzer Input (from user project):
┌──────────────────────────────┐
│   user_project_wrapper       │
│   [User Custom Logic]        │
└──────────┬───────────────────┘
           │
           ├─ la_input[127:0] ◄─ User can observe
           │
           └─ la_output[127:0] ◄─ User can drive (if enabled)
              │
              ▼
         ┌──────────────────┐
         │  mgmt_protect    │
         │  [LA Buffering]  │
         └────┬─────────────┘
              │
              ▼
         ┌──────────────────┐
         │  mgmt_core_wrapper
         │  [LA Interface]  │
         └────┬─────────────┘
              │
              ├─ la_data_in_mprj (from user)
              ├─ la_data_out_mprj (to user)
              └─ la_oenb_mprj (output enable)

Full LA Connectivity:
Management Core
    │
    └─→ LA Port
        ├─ 128-bit input monitoring
        ├─ 128-bit output control
        └─ Output enable mask

        Connected to: user_project_wrapper
        Purpose: Non-intrusive design observation
```

### Graph 10: Domain Crossing & Isolation

```
Management Domain (1.8V)          User Domain (1.8V / 3.3V)
┌─────────────────────┐           ┌──────────────────────┐
│                     │           │                      │
│   mgmt_core_wrapper │           │ user_project_wrapper │
│                     │           │                      │
│  - RISC-V Processor │           │ - Custom User Logic  │
│  - SPI Controllers  │           │ - User Peripherals   │
│  - UART            │           │                      │
│  - Housekeeping    │           │                      │
│                     │           │                      │
└──────────┬──────────┘           └──────────┬───────────┘
           │                               │
           │                               │
           │   mgmt_protect (Isolation)    │
           │   ┌────────────────────────┐  │
           │   │  Tri-state Buffers     │  │
           │   │  Clock Buffers         │  │
           │   │  Reset Buffers         │  │
           │   │  Bus Isolation         │  │
           │   │  Power Good Monitoring │  │
           │   └────────────────────────┘  │
           │           │                    │
           └───────────┼────────────────────┘
                       │
           Controlled Signal Paths:
           ├─ Wishbone Bus (isolated)
           ├─ Clock Distribution
           ├─ Reset Synchronization
           ├─ Interrupt Routing
           ├─ Logic Analyzer
           └─ Power Good Signals
```

---

## Module Dependency Graph (Simplified)

```
hkspi_tb
│
├─ Depends on: vsdcaravel
│  ├─ Depends on: chip_io
│  └─ Depends on: caravel_core
│     ├─ Depends on: mgmt_core_wrapper
│     │  └─ Depends on: mgmt_core
│     ├─ Depends on: mgmt_protect
│     ├─ Depends on: user_project_wrapper
│     ├─ Depends on: caravel_clocking
│     └─ Depends on: digital_pll
│
├─ Depends on: spiflash
│  └─ Depends on: hkspi.hex (hex file)
│
└─ Depends on: tbuart
```

---

## Signal Flow Summary

### Test Vector Path:
```
hkspi_tb.SCK ──────────────────────────→ mgmt_core (Housekeeping SPI Input)
hkspi_tb.CSB ──────────────────────────→ mgmt_core (Housekeeping SPI Input)
hkspi_tb.SDI ──────────────────────────→ mgmt_core (Housekeeping SPI Input)

mgmt_core ──────────────────────────→ hkspi_tb.SDO (Housekeeping SPI Output)
```

### Monitoring Path:
```
mgmt_core (UART TX) ───────→ hkspi_tb.uart_tx ───────→ tbuart (monitoring)
mgmt_core (Core Logic) ────→ hkspi_tb.mprj_io ───────→ hkspi_tb (observation)
```

### Control Path:
```
hkspi_tb.clock ───────────────→ caravel_clocking ───────────→ All modules
hkspi_tb.RSTB ─────────────────→ caravel_clocking ───────────→ All modules
hkspi_tb.power1/power2 ───────→ Power distribution network ──→ All modules
```

---

## Behavioral Flow During Test

### 1. Initialization Phase
```
hkspi_tb.initial
├─ Set RSTB = 0 (chip in reset)
├─ Generate clock
├─ Set power1, power2 (power up sequence)
└─ Wait for chip to stabilize
```

### 2. SPI Communication Phase
```
hkspi_tb.start_csb()
├─ Assert CSB (chip select)
└─ Clear SCK, SDI

hkspi_tb.write_byte(0x40)
├─ Send 8 bits (Read Stream Command)
├─ Clock each bit via SCK
└─ Drive SDI with data

hkspi_tb.read_byte(data)
├─ Clock each bit via SCK
├─ Sample SDO from mgmt_core
└─ Assemble into byte

hkspi_tb.end_csb()
├─ De-assert CSB
└─ Stop SPI communication
```

### 3. Verification Phase
```
Check returned register values
├─ Register 0 = 0x00 ✓
├─ Register 1 = 0x04 ✓
├─ Register 2 = 0x56 ✓
├─ ... (all registers 0-18)
└─ Pass/Fail decision
```

### 4. Result & Exit
```
If all registers match expected:
└─ Display "Test Passed"
   Log "Monitor: Test HK SPI (RTL) Passed"

Else:
└─ Display "Test Failed"
   Log error message
```

---

## Conclusion

The connectivity graph reveals:

1. **Hierarchical Organization**: Clear parent-child relationships
2. **Power Distribution**: Dual-voltage domains (3.3V and 1.8V)
3. **Clock Network**: Single source with distribution tree
4. **Reset Synchronization**: Proper reset sequencing
5. **Domain Isolation**: Management and User domains separated by buffers
6. **Multiple Interfaces**: SPI, Wishbone, UART, Logic Analyzer
7. **Simulation Support**: External models for flash and UART monitoring
8. **Comprehensive Testing**: Testbench can exercise all major interfaces

The design is production-ready with proper isolation, synchronization, and multi-domain handling.

