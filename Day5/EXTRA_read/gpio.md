# GPIO Test Documentation

## Overview

This test validates the GPIO functionality of the Caravel SoC by testing both input and output modes, pull-up/pull-down configurations, and bidirectional communication between the testbench and firmware through the `mprj_io` pins.

## Test Components

### 1. Firmware (`gpio.c`)
The C firmware gets compiled to `gpio.hex` and loaded into the SPI flash. It performs:

#### Pin Configuration
- **mprj_io[31:24]** (upper 8 pins): Configured as **outputs** using `GPIO_MODE_MGMT_STD_OUTPUT`
- **mprj_io[23:16]** (lower 8 pins): Configured as **inputs** with various pull modes using:
  - `GPIO_MODE_MGMT_STD_INPUT_NOPULL`
  - `GPIO_MODE_MGMT_STD_INPUT_PULLDOWN` 
  - `GPIO_MODE_MGMT_STD_INPUT_PULLUP`

#### Communication Protocol
The firmware uses `reg_mprj_datal` register to communicate status and read input data:

1. **Phase 1**: Outputs `0xA0` on upper 8 bits, waits for testbench to drive `0xF0` on lower 8 bits
2. **Phase 2**: Outputs `0x0B` on upper 8 bits, waits for testbench to drive `0x0F` on lower 8 bits  
3. **Phase 3**: Outputs `0xAB` on upper 8 bits, waits for testbench to drive `0x00` on lower 8 bits
4. **Phase 4**: Continuous loop reading lower 8 bits, incrementing by 1, and outputting on upper 8 bits

### 2. Testbench (`gpio_tb.v`)
The Verilog testbench acts as the external GPIO driver and monitor:

#### Signal Mapping
- `checkbits[15:8]` = `mprj_io[31:24]` (reads firmware outputs)
- `checkbits[7:0]` = `mprj_io[23:16]` (drives inputs to firmware)
- `checkbits_hi` = upper 8 bits (monitor firmware status)
- `checkbits_lo` = lower 8 bits (drive stimulus to firmware)

#### Test Sequence
1. **Transactor**: Drives stimulus patterns based on firmware status:
   - Wait for `hi==0xA0` → Drive `lo=0xF0`
   - Wait for `hi==0x0B` → Drive `lo=0x0F` 
   - Wait for `hi==0xAB` → Drive `lo=0x00`
   - Drive `lo=0x01`, then `lo=0x03`

2. **Monitor**: Verifies expected responses:
   - Checks firmware reads inputs correctly
   - Validates increment operation (input+1 = output)
   - Declares PASS when sequence completes successfully

### 3. Register Definitions (`defs.h`)

#### Key Registers
- `reg_mprj_datal` (0x2600000c): 32-bit data register for mprj_io[31:0]
- `reg_mprj_io_XX` (0x26000024+): Individual GPIO configuration registers
- `reg_mprj_xfer` (0x26000000): Transfer register to apply GPIO config changes

#### GPIO Mode Values
- `GPIO_MODE_MGMT_STD_OUTPUT` (0x1809): Standard output mode
- `GPIO_MODE_MGMT_STD_INPUT_NOPULL` (0x0403): Input without pull resistors
- `GPIO_MODE_MGMT_STD_INPUT_PULLDOWN` (0x0c01): Input with pull-down
- `GPIO_MODE_MGMT_STD_INPUT_PULLUP` (0x0801): Input with pull-up

## Test Flow

### Initialization
1. **Power-up**: VDD3V3 and VDD1V8 rails sequenced
2. **Reset**: RSTB released after 1000ns
3. **Flash Load**: `gpio.hex` firmware loaded via SPI flash model

### GPIO Configuration Testing
1. **Initial Setup**: Configure pin directions and pull modes
2. **Pull Configuration**: Test different pull-up/pull-down combinations
3. **Handshake Protocol**: Firmware and testbench exchange coded patterns
4. **Increment Test**: Firmware reads input, adds 1, outputs result

### Success Criteria
The test passes when the monitor detects the complete sequence:
- `hi=0xA0, lo=0xF0` → `hi=0x0B, lo=0x0F` → `hi=0xAB, lo=0x00`
- `hi=0x01, lo=0x01` → `hi=0x02, lo=0x03` → `hi=0x04`

## Memory Map

| Address Range | Function | Key Registers |
|---------------|----------|---------------|
| 0x26000000-0x260000c | MPRJ Control | `reg_mprj_xfer`, `reg_mprj_datal` |
| 0x26000024-0x260000b8 | GPIO Config | `reg_mprj_io_0` to `reg_mprj_io_37` |

## Pull-up/Pull-down Testing

The firmware systematically tests different pull resistor configurations:

1. **No Pull**: `GPIO_MODE_MGMT_STD_INPUT_NOPULL` - Pin floats
2. **Pull-down**: `GPIO_MODE_MGMT_STD_INPUT_PULLDOWN` - Pin pulled to 0V  
3. **Pull-up**: `GPIO_MODE_MGMT_STD_INPUT_PULLUP` - Pin pulled to VDD

The testbench can detect these states when pins are not actively driven, validating the pull resistor functionality.

## Running the Test

```bash
# In the gpio directory
make                    # Compile and run simulation
gtkwave gpio.vcd        # View waveforms (optional)
```

The test generates `gpio.vcd` for waveform analysis and reports PASS/FAIL status to the console.

## Key Signals to Monitor

- `mprj_io[31:16]`: GPIO pins under test
- `checkbits_hi`/`checkbits_lo`: Testbench communication
- `reg_mprj_datal`: Firmware data register
- `reg_mprj_xfer`: Configuration transfer strobe
- `clock`, `RSTB`: System timing and reset

This test validates the complete GPIO subsystem including configuration, pull resistors, input/output functionality, and management-to-user project communication through the `mprj_io` interface.