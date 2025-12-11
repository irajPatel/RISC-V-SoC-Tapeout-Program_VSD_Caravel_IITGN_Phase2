# HK SPI Interaction: Management SoC & User Project Integration
**Technical Summary - 1 Page**

## Overview
The Housekeeping SPI (HK SPI) is a dedicated control interface enabling external testers to access internal chip registers without direct processor involvement. It acts as a bridge between the external world, the management SoC, and the user project area.

## Architecture & Physical Connection

The testbench (`hkspi_tb.v`) connects SPI signals to the Caravel chip via the `mprj_io` user I/O bus:
- **mprj_io[4]** ← SCK (Serial Clock from testbench)
- **mprj_io[3]** ← CSB (Chip Select from testbench)  
- **mprj_io[2]** ← SDI (Serial Data In from testbench)
- **mprj_io[1]** → SDO (Serial Data Out from chip)
- **mprj_io[6]** → UART TX (diagnostic output from management SoC)

The chip's internal HK SPI controller (`housekeeping_spi.v`) connects directly to these external pins and interfaces with the management SoC's register file.

## Three-Layer Communication Protocol

### **Layer 1: External Test Equipment (Testbench)**
The external tester operates as SPI master:
1. **CSB LOW** → enable SPI communication
2. **Send 8 bits on SDI** → Command byte (0x40=read, 0x80=write, 0xC0=simultaneous)
3. **Send 8 bits on SDI** → Address byte (0-255 register selection)
4. **Send/receive 8 bits** → Data byte with auto-incrementing address in stream mode
5. **CSB HIGH** → end transaction

### **Layer 2: HK SPI Controller (State Machine)**
The controller (`housekeeping_spi.v`) implements a 3-state machine synchronous to SCK:

```
RESET → COMMAND (8 bits) → ADDRESS (8 bits) → DATA (stream/fixed length)
```

**Critical Timing Details:**
- **SCK rising edge**: Capture SDI bit, advance state counter
- **SCK falling edge**: Shift SDO output bit, latch read data at start of each byte
- **Output stability**: Data on SDO remains valid during SCK HIGH for correct sampling

**Register Access Signals:**
- `rdstb` (read strobe): Asserted after address reception → signals register file to output data
- `wrstb` (write strobe): Asserted on penultimate SCK cycle → latches received data into registers
- `odata` (output 8 bits): Contains received data from testbench  
- `idata` (input 8 bits): Contains data from register file to transmit to testbench

### **Layer 3: Management SoC & Register File**
The management SoC (Picorv32 processor) runs firmware (`hkspi.hex`) with dual roles:

**Passive**: During normal operation, firmware keeps processor busy (non-blocking loop) while HK SPI operates independently, reading/writing hardcoded register values.

**Active**: Responds to control register writes:
- Register 0 (Flags) = 0x00 (reserved)
- Registers 1-2 (Mfg ID) = 0x0456 (Efabless)
- Register 3 (Product ID) = 0x11 (Caravel ID)
- Registers 4-7 (Mask ID) = 0x00000000
- Registers 8-9 (Config) = 0x02, 0x01
- Registers 10-12 = 0x00 (reserved)
- Registers 13-18 (GPIO) = 0xFF, 0xEF, 0xFF, 0x03, 0x12, 0x04 (pin defaults)

## Data Flow Example: Reading Product ID (Register 3)

1. **Testbench**: Pulls CSB LOW, sends `0x40` (read command) bit-by-bit on SDI
2. **HK SPI**: Receives command, asserts `readmode=1`, advances to ADDRESS state
3. **Testbench**: Sends `0x03` (register 3 address) on SDI
4. **HK SPI**: Receives address, asserts `rdstb` signal to register file
5. **Register file**: Outputs `0x11` (product ID) on `idata` input
6. **HK SPI**: Captures `idata` on first SCK falling edge, begins shifting bits onto SDO
7. **Testbench**: Samples SDO on each SCK rising edge, receives `0x11` over 8 clock cycles
8. **Testbench**: Validates received value; test continues (or fails if mismatch)
9. **Testbench**: Pulls CSB HIGH to end transaction

## Key Design Features

1. **Independent Operation**: HK SPI controller operates autonomously; no processor involvement required during transactions.

2. **Auto-Incrementing**: In stream mode, address increments after each byte for fast sequential reads.

3. **Pass-Through Modes**: Command bits [5:3] enable direct Flash access (`0xC4`=management, `0xC2`=user).

4. **External Reset**: Writing register 11 with `0x01` asserts external reset signal, allowing testbench to reset chip.

5. **Test Verification**: Testbench validates all 19 registers (0-18) return exact expected values; any mismatch causes immediate test failure.

## RTL vs. GLS Equivalence
- **RTL**: Abstract Verilog state machine logic executes in simulation
- **GLS**: Replaced with Sky130 standard cell implementations (flip-flops, logic gates)
- **Verification**: Both must produce identical register read/write sequences confirming synthesis introduced no functional errors
- For writes: captures data from SDI and strobes write signal
- Operates **independently** of management SoC (works even if processor is reset)

### 3. **User Project Interaction**
- HK SPI does **not** directly interface with user project
- User project remains in isolation during HK SPI test
- User project could potentially be controlled via GPIO pins if configured
- In hkspi test, user project is inactive (just observing)

## Test Execution (hkspi_tb.v)

**Testbench Sequence:**
1. Power-up chip with RSTB=0 (reset asserted)
2. Release reset (RSTB=1) → Management SoC boots, runs hkspi.c
3. Wait 2000ns for initialization
4. Send SPI commands to read registers via HK SPI:
   - Read register 3 (Product ID, expect 0x11)
   - Toggle external reset via register 11 (write 0x01, then 0x00)
   - Read all registers 0-18 sequentially
   - Verify each value matches expected (19 register reads total)
5. If all 19 registers match expected values: **Test PASSED**
6. If any mismatch: **Test FAILED** and simulation exits

## Key Independence Property

**Critical Design Feature:** The HK SPI operates **completely independently** from the management SoC processor. This means:
- ✅ Can read chip IDs even if processor is in reset
- ✅ Can toggle external reset signals via SPI
- ✅ Can reconfigure GPIO pins via SPI
- ✅ Management SoC can be interrupted/reset while HK SPI continues
- ❌ But HK SPI does NOT have access to user project internals

## Files Involved
- `hkspi_tb.v`: Testbench simulating external SPI tester equipment
- `housekeeping_spi.v`: RTL SPI slave controller (the actual hardware)
- `hkspi.c`: Management SoC firmware (keeps processor busy during test)
- `hkspi.hex`: Compiled firmware binary loaded into flash during simulation
