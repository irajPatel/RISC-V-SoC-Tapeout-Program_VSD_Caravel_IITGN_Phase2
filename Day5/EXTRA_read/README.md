# Caravel GPIO Test - Complete Signal Flow Analysis

## Overview
This directory contains a comprehensive test of the Caravel GPIO functionality, validating the complete signal path from firmware register writes to physical GPIO pad behavior. The test exercises GPIO configuration, pull-up/pull-down modes, and bidirectional communication.

## Complete Signal Flow Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐    ┌────────────────┐    ┌─────────────┐
│   Firmware      │    │  Management SoC  │    │  Housekeeping   │    │ GPIO Control   │    │  Physical   │
│   (gpio.c)      │───►│ (mgmt_core_wrap) │───►│   (wishbone)    │───►│    Blocks      │───►│    Pads     │
│                 │    │                  │    │                 │    │                │    │             │
│ reg_mprj_datal  │    │ Wishbone Bus     │    │ mgmt_gpio_data  │    │ pad_gpio_out   │    │ mprj_io     │
└─────────────────┘    └──────────────────┘    └─────────────────┘    └────────────────┘    └─────────────┘
```

## Detailed Signal Flow

### 1. Firmware Level (gpio.c)
**Entry Point:** Firmware writes to memory-mapped registers
```c
reg_mprj_datal = 0xa0000000;  // Write status pattern to GPIO[31:0]
```

**Key Registers (from defs.h):**
- `reg_mprj_datal` (0x2600000C) - GPIO data bits [31:0]
- `reg_mprj_io_XX` (0x26000024+) - Individual GPIO config registers  
- `reg_mprj_xfer` (0x26000000) - Configuration transfer strobe

### 2. Management SoC Level (mgmt_core_wrapper.v)
**Wishbone Bus Transaction:**
```verilog
Signal Path:
├── mprj_adr_o[31:0] = 0x2600000C   // Target address
├── mprj_dat_o[31:0] = 0xa0000000   // Data to write
├── mprj_we_o = 1                   // Write enable
├── mprj_stb_o = 1                  // Strobe
└── mprj_cyc_o = 1                  // Cycle
```

**Key Signals to Trace:**
```verilog
uut.chip_core.soc.mprj_adr_o        // Wishbone address to housekeeping
uut.chip_core.soc.mprj_dat_o        // Wishbone data to housekeeping
uut.chip_core.soc.mprj_we_o         // Wishbone write enable to housekeeping
uut.chip_core.soc.mprj_ack_i        // Wishbone acknowledge from housekeeping
uut.chip_core.soc.mprj_cyc_o        // Wishbone cycle to housekeeping
uut.chip_core.soc.mprj_stb_o        // Wishbone strobe to housekeeping
```

### 3. Housekeeping Level (housekeeping.v)
**Address Translation & Data Storage:**
```verilog
Function: spiaddr(0x2600000C) → 0x6D  // Internal SPI address mapping
Register: mgmt_gpio_data[31:0]        // Main GPIO data storage

Signal Flow:
├── wb_adr_i[31:0]           // From management SoC
├── wb_dat_i[31:0]           // Data from management SoC  
├── mgmt_gpio_data[31:0]     // Internal register storage
└── mgmt_gpio_out[31:0]      // Output to GPIO control blocks
```

**Critical GPIO Output Assignments:**
```verilog
assign mgmt_gpio_out[31:16] = mgmt_gpio_data[31:16];  // Used by test
assign mgmt_gpio_out[15:0] = <various special functions>;
```

**Key Signals to Trace:**
```verilog
uut.chip_core.housekeeping.wb_adr_i[31:0]        // Wishbone address input
uut.chip_core.housekeeping.wb_dat_i[31:0]        // Wishbone data input
uut.chip_core.housekeeping.mgmt_gpio_data[31:0]  // Main GPIO data register
uut.chip_core.housekeeping.mgmt_gpio_out[31:16]  // Output to GPIO blocks
uut.chip_core.housekeeping.mgmt_gpio_in[31:16]   // Input from GPIO pads
```

### 4. GPIO Control Block Level (gpio_control_block.v)
**Individual Pin Control (38 instances):**
Each GPIO pin has its own control block that manages:

```verilog
Key Configuration:
├── mgmt_ena                 // 1=Management control, 0=User control
├── gpio_outenb             // Output enable configuration
├── gpio_dm[2:0]            // Digital mode control
└── gpio_defaults[12:0]     // Power-on default configuration

Signal Routing Logic:
├── mgmt_gpio_in = pad_gpio_in                    // Pad always readable by management
├── pad_gpio_out = (mgmt_ena) ? mgmt_gpio_out : user_gpio_out
└── pad_gpio_outenb = (mgmt_ena) ? <management_logic> : user_gpio_oeb
```

**Key Signals to Trace (for pins 16-31):**
```verilog
// Management data path
uut.chip_core.gpio_control_in_1[8].mgmt_gpio_out      // Pin 16 management output
uut.chip_core.gpio_control_in_1[8].mgmt_ena           // Pin 16 management enable
uut.chip_core.gpio_control_in_1[8].pad_gpio_out       // Pin 16 final output
uut.chip_core.gpio_control_in_1[8].pad_gpio_outenb    // Pin 16 output enable

// For pins 17-18: gpio_control_in_1[9], gpio_control_in_1[10], etc.
// For pins 24-31: gpio_control_in_2[5] through gpio_control_in_2[12]
```

### 5. Chip I/O Level (chip_io.v & mprj_io.v)
**Pad Frame Interface:**
```verilog
Signal Aggregation:
├── mprj_io_out[37:0]      // From GPIO control blocks
├── mprj_io_oeb[37:0]      // Output enables from GPIO control blocks  
├── mprj_io_in[37:0]       // To GPIO control blocks
└── mprj_io[37:0]          // Physical bidirectional pads

Pad Implementation:
├── sky130_ef_io__gpiov2_pad_wrapped  // Physical pad cells
├── .OUT(mprj_io_out[n])               // Drive pad output
├── .OE_N(mprj_io_oeb[n])             // Output enable (active low)
└── .IN(mprj_io_in[n])                // Read pad input
```

**Key Signals to Trace:**
```verilog
uut.chip_core.mprj_io_out[31:16]      // Final outputs to padframe
uut.chip_core.mprj_io_oeb[31:16]      // Final output enables to padframe
uut.chip_core.mprj_io_in[31:16]       // Inputs from padframe
uut.padframe.mprj_pads.io[31:16]      // Physical pad states
```

### 6. Testbench Level (gpio_tb.v)
**External Test Interface:**
```verilog
Test Connections:
├── mprj_io[31:16] ↔ checkbits[15:0]     // Bidirectional test bus
├── checkbits_hi[7:0] = mprj_io[31:24]   // Upper 8 bits (outputs from DUT)
├── checkbits_lo[7:0] = mprj_io[23:16]   // Lower 8 bits (inputs to DUT)
└── checkbits_lo driven by testbench     // Test stimulus
```

## What the Testbench Tests

### Test Sequence Overview
1. **GPIO Configuration Test** - Verify pin direction and mode setup
2. **Pull-up/Pull-down Test** - Validate internal pull resistor functionality  
3. **Communication Protocol Test** - Bidirectional data exchange
4. **Increment Function Test** - Arithmetic operation verification

### Detailed Test Protocol

#### Phase 1: GPIO Configuration
```verilog
Firmware Action: Configure pins 31:24 as outputs, pins 23:16 as inputs
Expected RTL: gpio_control_block[31:24].mgmt_ena = 1, mgmt_gpio_oeb = 0 (output)
              gpio_control_block[23:16].mgmt_ena = 1, mgmt_gpio_oeb = 1 (input)
```

#### Phase 2: Status Exchange (0xA0 ↔ 0xF0)
```verilog
Firmware: reg_mprj_datal = 0xa0000000;    // Output 0xA0 on pins [31:24]
Testbench: wait(checkbits_hi == 8'hA0)     // Detect firmware status
Testbench: checkbits_lo <= 8'hF0;          // Drive 0xF0 on pins [23:16]
Firmware: while((reg_mprj_datal & 0xff0000) != 0xF0); // Wait for testbench response
```

#### Phase 3: Status Exchange (0x0B ↔ 0x0F)
```verilog
Firmware: reg_mprj_datal = 0x0b000000;    // Output 0x0B on pins [31:24]
Testbench: wait(checkbits_hi == 8'h0B)     // Detect firmware status
Testbench: checkbits_lo <= 8'h0F;          // Drive 0x0F on pins [23:16]
```

#### Phase 4: Status Exchange (0xAB ↔ 0x00)
```verilog
Firmware: reg_mprj_datal = 0xab000000;    // Output 0xAB on pins [31:24]
Testbench: wait(checkbits_hi == 8'hAB)     // Detect firmware status
Testbench: checkbits_lo <= 8'h00;          // Drive 0x00 on pins [23:16]
```

#### Phase 5: Increment Test
```verilog
Firmware: 
    while(1) {
        int x = (reg_mprj_datal & 0xff0000) >> 16;  // Read input pins [23:16]
        reg_mprj_datal = (x+1) << 24;               // Output (input+1) on pins [31:24]
    }

Testbench:
    checkbits_lo <= 8'h01;          // Drive 0x01
    wait(checkbits_hi == 8'h02);    // Expect 0x02 (0x01 + 1)
    checkbits_lo <= 8'h03;          // Drive 0x03  
    wait(checkbits_hi == 8'h04);    // Expect 0x04 (0x03 + 1)
```

## Critical Signal Tracing for Debug

### Complete Signal Chain (Pin 16 Example)
```verilog
// 1. Firmware Write
Firmware: reg_mprj_datal = 0xa0000000;

// 2. Wishbone Transaction  
uut.chip_core.soc.mprj_adr_o = 32'h2600000C
uut.chip_core.soc.mprj_dat_o = 32'hA0000000

// 3. Housekeeping Processing
uut.chip_core.housekeeping.wb_adr_i = 32'h2600000C
uut.chip_core.housekeeping.mgmt_gpio_data[31:24] = 8'hA0
uut.chip_core.housekeeping.mgmt_gpio_out[31:24] = 8'hA0

// 4. GPIO Control Block (Pin 24)
uut.chip_core.gpio_control_in_2[5].mgmt_gpio_out = 1'b1  // Bit 0 of 0xA0
uut.chip_core.gpio_control_in_2[5].mgmt_ena = 1'b1
uut.chip_core.gpio_control_in_2[5].pad_gpio_out = 1'b1

// 5. Chip I/O
uut.chip_core.mprj_io_out[24] = 1'b1
uut.padframe.mprj_pads.io[24] = 1'b1

// 6. Testbench Detection
checkbits_hi[0] = 1'b1  // Part of 0xA0 pattern
```

### Essential Debug Signals
```verilog
// System Level
clock                                    // System clock
RSTB                                    // System reset

// Firmware to Hardware Path
uut.chip_core.housekeeping.mgmt_gpio_data[31:16]  // Main GPIO register
uut.chip_core.mprj_io_out[31:16]                  // Final outputs to pads
uut.chip_core.mprj_io_oeb[31:16]                  // Output enables

// Hardware to Firmware Path  
uut.chip_core.mprj_io_in[31:16]                   // Inputs from pads
uut.chip_core.housekeeping.mgmt_gpio_in[31:16]    // Available to firmware

// Testbench Interface
mprj_io[31:16]                          // Physical GPIO connections
checkbits_hi[7:0]                       // Testbench monitors (from DUT)
checkbits_lo[7:0]                       // Testbench drives (to DUT)

// Configuration Status
uut.chip_core.gpio_control_in_1[8].mgmt_ena       // Pin 16 management enable
uut.chip_core.gpio_control_in_2[5].mgmt_ena       // Pin 24 management enable
```

## Test Success Criteria

### Pass Conditions
1. **Configuration Complete**: All GPIO pins properly configured for correct direction
2. **Communication Success**: All handshake sequences complete correctly
3. **Increment Function**: Arithmetic operation works correctly
4. **Final Status**: Monitor detects `checkbits_hi == 8'h04`

### Key Success Signals
```verilog
// Monitor progression through test phases
wait(checkbits_hi == 8'hA0) → Success: Phase 1 complete
wait(checkbits_hi == 8'h0B) → Success: Phase 2 complete  
wait(checkbits_hi == 8'hAB) → Success: Phase 3 complete
wait(checkbits_hi == 8'h04) → Success: Phase 4 complete (TEST PASS)
```

### Failure Detection
- **Timeout**: 25,000 clock cycles without completion
- **Incorrect Response**: Wrong pattern on `checkbits_hi`
- **Stuck State**: No progression in handshake sequence

## Running the Test

```bash
# Compile and simulate
make

# View waveforms (optional)
gtkwave gpio.vcd

# Expected output
Monitor: Test GPIO (RTL) Passed
```

## Key Files Reference

| File | Purpose | Key Signals |
|------|---------|-------------|
| `gpio.c` | Firmware test logic | `reg_mprj_datal` writes |
| `gpio_tb.v` | Testbench stimulus/monitor | `checkbits_hi/lo`, `mprj_io[31:16]` |
| `housekeeping.v` | GPIO register controller | `mgmt_gpio_data`, `mgmt_gpio_out` |
| `gpio_control_block.v` | Individual pin controller | `mgmt_ena`, `pad_gpio_out` |
| `chip_io.v` | Pad frame interface | `mprj_io_out/oeb/in` |
| `caravel.v` | Top-level integration | All signal routing |

This test validates the complete GPIO subsystem from firmware register access through physical pad behavior, ensuring robust operation of the Caravel GPIO interface.

## Detailed Port-to-Port Signal Connections

### 1. Testbench Level (gpio_tb.v)
**Key Instantiation:**
```verilog
caravel uut (
    .clock(clock),
    .gpio(gpio),  
    .mprj_io(mprj_io),        // [37:0] bidirectional GPIO bus
    .flash_csb(flash_csb),
    .flash_clk(flash_clk), 
    .flash_io0(flash_io0),
    .flash_io1(flash_io1),
    .resetb(RSTB)
);
```

**Test Interface Mapping:**
```verilog
// GPIO test uses subset of mprj_io pins
wire [37:0] mprj_io;           // Full GPIO bus from caravel
wire [15:0] checkbits;         // Test interface bus
assign mprj_io[23:16] = checkbits_lo;    // Testbench drives lower 8 bits
assign checkbits = mprj_io[31:16];       // Testbench monitors upper 16 bits
assign checkbits_hi = checkbits[15:8];   // Upper 8 bits (DUT outputs)
// checkbits[7:0] = mprj_io[23:16] (DUT inputs)
```

### 2. Top Level (caravel.v) 
**Key Instantiation:**
```verilog
chip_io padframe (
    .mprj_io(mprj_io),                    // [37:0] to/from testbench
    .mprj_io_in(mprj_io_in),             // [37:0] to caravel_core
    .mprj_io_out(mprj_io_out),           // [37:0] from caravel_core
    .mprj_io_oeb(mprj_io_oeb),           // [37:0] from caravel_core
    .mprj_io_inp_dis(mprj_io_inp_dis),   // [37:0] from caravel_core
    .mprj_io_ib_mode_sel(mprj_io_ib_mode_sel), // [37:0] from caravel_core
    .mprj_io_vtrip_sel(mprj_io_vtrip_sel),     // [37:0] from caravel_core
    .mprj_io_slow_sel(mprj_io_slow_sel),       // [37:0] from caravel_core
    .mprj_io_holdover(mprj_io_holdover),       // [37:0] from caravel_core
    .mprj_io_analog_en(mprj_io_analog_en),     // [37:0] from caravel_core
    .mprj_io_analog_sel(mprj_io_analog_sel),   // [37:0] from caravel_core
    .mprj_io_analog_pol(mprj_io_analog_pol),   // [37:0] from caravel_core
    .mprj_io_dm(mprj_io_dm),                   // [113:0] from caravel_core (3 bits per pin)
    .mprj_io_one(mprj_io_one)                  // [37:0] from caravel_core
);

caravel_core chip_core (
    .mprj_io_in(mprj_io_in),             // [37:0] from padframe  
    .mprj_io_out(mprj_io_out),           // [37:0] to padframe
    .mprj_io_oeb(mprj_io_oeb),           // [37:0] to padframe
    // ... all other mprj_io_* control signals to padframe
);
```

### 3. Padframe Level (chip_io.v)
**Key Instantiation:**
```verilog
mprj_io mprj_pads(
    .io(mprj_io),                        // [37:0] external pins
    .io_in(mprj_io_in),                  // [37:0] to caravel_core
    .io_out(mprj_io_out),                // [37:0] from caravel_core
    .oeb(mprj_io_oeb),                   // [37:0] from caravel_core
    .inp_dis(mprj_io_inp_dis),           // [37:0] from caravel_core
    .ib_mode_sel(mprj_io_ib_mode_sel),   // [37:0] from caravel_core
    .vtrip_sel(mprj_io_vtrip_sel),       // [37:0] from caravel_core
    .slow_sel(mprj_io_slow_sel),         // [37:0] from caravel_core
    .holdover(mprj_io_holdover),         // [37:0] from caravel_core
    .analog_en(mprj_io_analog_en),       // [37:0] from caravel_core
    .analog_sel(mprj_io_analog_sel),     // [37:0] from caravel_core
    .analog_pol(mprj_io_analog_pol),     // [37:0] from caravel_core
    .dm(mprj_io_dm),                     // [113:0] from caravel_core
    .vccd_conb(mprj_io_one)              // [37:0] from caravel_core
);
```

### 4. Core Level (caravel_core.v)
**Housekeeping Instantiation:**
```verilog
housekeeping housekeeping (
    .wb_clk_i(caravel_clk),              // System clock
    .wb_rstn_i(caravel_rstn),            // System reset
    .wb_adr_i(mprj_adr_o_core),          // [31:0] from management SoC
    .wb_dat_i(mprj_dat_o_core),          // [31:0] from management SoC  
    .wb_sel_i(mprj_sel_o_core),          // [3:0] from management SoC
    .wb_we_i(mprj_we_o_core),            // Write enable from management SoC
    .wb_cyc_i(hk_cyc_o),                 // Cycle from management SoC
    .wb_stb_i(hk_stb_o),                 // Strobe from management SoC
    .wb_ack_o(hk_ack_i),                 // Acknowledge to management SoC
    .wb_dat_o(hk_dat_i),                 // [31:0] to management SoC
    .mgmt_gpio_in(mgmt_io_in_hk),        // [37:0] from GPIO control blocks
    .mgmt_gpio_out(mgmt_io_out_hk),      // [37:0] to GPIO control blocks  
    .mgmt_gpio_oeb(mgmt_io_oeb_hk)       // [37:0] to GPIO control blocks
);
```

**GPIO Control Block Instantiations:**
```verilog
// Pins 0-1: JTAG, SDO (bidirectional)
gpio_control_block gpio_control_bidir_1 [1:0] (
    .mgmt_gpio_in(mgmt_io_in[1:0]),      // To housekeeping
    .mgmt_gpio_out(mgmt_io_out[1:0]),    // From housekeeping
    .mgmt_gpio_oeb(mgmt_io_oeb[1:0]),    // From housekeeping
    .pad_gpio_out(mprj_io_out[1:0]),     // To padframe
    .pad_gpio_outenb(mprj_io_oeb[1:0]),  // To padframe
    .pad_gpio_in(mprj_io_in[1:0]),       // From padframe
    .pad_gpio_dm(mprj_io_dm[5:0]),       // To padframe (3 bits per pin)
    // ... all other pad control signals
);

// Pins 2-7: Management control pins 
gpio_control_block gpio_control_in_1a [5:0] (
    .mgmt_gpio_in(mgmt_io_in[7:2]),      // To housekeeping
    .mgmt_gpio_out(mgmt_io_out[7:2]),    // From housekeeping
    .mgmt_gpio_oeb(mgmt_io_oeb[7:2]),    // From housekeeping
    .pad_gpio_out(mprj_io_out[7:2]),     // To padframe
    .pad_gpio_outenb(mprj_io_oeb[7:2]),  // To padframe
    .pad_gpio_in(mprj_io_in[7:2])        // From padframe
    // ... control signals
);

// Pins 8-18: User area 1 pins (includes test pins 16-18)
gpio_control_block gpio_control_in_1 [`MPRJ_IO_PADS_1-9:0] (  // [10:0]
    .mgmt_gpio_in(mgmt_io_in[18:8]),     // To housekeeping
    .mgmt_gpio_out(mgmt_io_out[18:8]),   // From housekeeping  
    .mgmt_gpio_oeb(mgmt_io_oeb[18:8]),   // From housekeeping
    .pad_gpio_out(mprj_io_out[18:8]),    // To padframe
    .pad_gpio_outenb(mprj_io_oeb[18:8]), // To padframe
    .pad_gpio_in(mprj_io_in[18:8])       // From padframe
    // Pin 16 = gpio_control_in_1[8]
    // Pin 17 = gpio_control_in_1[9] 
    // Pin 18 = gpio_control_in_1[10]
);

// Pins 19-34: User area 2 pins (includes test pins 19-31)
gpio_control_block gpio_control_in_2 [`MPRJ_IO_PADS_2-4:0] (  // [15:0] 
    .mgmt_gpio_in(mgmt_io_in[34:19]),    // To housekeeping
    .mgmt_gpio_out(mgmt_io_out[34:19]),  // From housekeeping
    .mgmt_gpio_oeb(mgmt_io_oeb[34:19]),  // From housekeeping  
    .pad_gpio_out(mprj_io_out[34:19]),   // To padframe
    .pad_gpio_outenb(mprj_io_oeb[34:19]), // To padframe
    .pad_gpio_in(mprj_io_in[34:19])      // From padframe
    // Pin 19 = gpio_control_in_2[0]
    // Pin 20 = gpio_control_in_2[1]
    // ...
    // Pin 31 = gpio_control_in_2[12]
);

// Pins 35-37: SPI and flash pins
gpio_control_block gpio_control_bidir_2 [2:0] (
    .mgmt_gpio_in(mgmt_io_in[37:35]),    // To housekeeping
    .mgmt_gpio_out(mgmt_io_out[37:35]),  // From housekeeping
    .mgmt_gpio_oeb(mgmt_io_oeb[37:35]),  // From housekeeping
    .pad_gpio_out(mprj_io_out[37:35]),   // To padframe  
    .pad_gpio_outenb(mprj_io_oeb[37:35]), // To padframe
    .pad_gpio_in(mprj_io_in[37:35])      // From padframe
);
```

**Signal Aggregation:**
```verilog
// Management signals from housekeeping distributed to GPIO control blocks
assign mgmt_io_in_hk = {mgmt_gpio_in_buf, mgmt_io_in[(`MPRJ_IO_PADS_1-1):0]};
assign mgmt_io_out = {mgmt_gpio_out_buf, mgmt_io_out_hk[(`MPRJ_IO_PADS_1-1):0]};
assign mgmt_io_oeb = {mgmt_gpio_oeb_buf, mgmt_io_oeb_hk[(`MPRJ_IO_PADS-4):0]};
```

### 5. GPIO Control Block Level (gpio_control_block.v)
**Per-Pin Control Logic:**
```verilog
// Key internal signals
reg mgmt_ena;                 // Management enable (from serial config)
reg gpio_outenb;             // Output enable configuration  
reg [2:0] gpio_dm;           // Digital mode configuration

// Input routing (pad always readable by management)
assign mgmt_gpio_in = pad_gpio_in;

// Output routing (depends on mgmt_ena)
assign pad_gpio_out = (mgmt_ena) ? 
    ((mgmt_gpio_oeb == 1'b1) ?
        ((gpio_dm[2:1] == 2'b01) ? ~gpio_dm[0] : mgmt_gpio_out) :
         mgmt_gpio_out) : user_gpio_out;

// Output enable routing  
assign pad_gpio_outenb = (mgmt_ena) ? 
    ((mgmt_gpio_oeb == 1'b1) ? gpio_outenb : 1'b0) : user_gpio_oeb;
```

### 6. Physical Pad Level (mprj_io.v)
**Pad Cell Instantiation:**
```verilog
// Area 1 pads (pins 0 to MPRJ_IO_PADS_1-1)
sky130_ef_io__gpiov2_pad_wrapped area1_io_pad [AREA1PADS-1:0] (
    .PAD(io[AREA1PADS-1:0]),             // Physical pins
    .OUT(io_out[AREA1PADS-1:0]),         // From GPIO control blocks
    .OE_N(oeb[AREA1PADS-1:0]),          // From GPIO control blocks (active low)
    .IN(io_in[AREA1PADS-1:0]),          // To GPIO control blocks
    .DM(dm[AREA1PADS*3-1:0]),           // Digital mode from GPIO control blocks
    // ... other pad configuration signals
);

// Area 2 pads (pins MPRJ_IO_PADS_1 to MPRJ_IO_PADS-1)  
sky130_ef_io__gpiov2_pad_wrapped area2_io_pad [TOTAL_PADS-AREA1PADS-1:0] (
    .PAD(io[TOTAL_PADS-1:AREA1PADS]),    // Physical pins
    .OUT(io_out[TOTAL_PADS-1:AREA1PADS]), // From GPIO control blocks
    .OE_N(oeb[TOTAL_PADS-1:AREA1PADS]),  // From GPIO control blocks
    .IN(io_in[TOTAL_PADS-1:AREA1PADS])   // To GPIO control blocks
    // ... configuration signals
);
```

## Critical Signal Mapping for Test Pins [31:16]

### Pin-to-Instance Mapping:
```verilog
// Pin 16 → gpio_control_in_1[8]   (User area 1, index 8)
// Pin 17 → gpio_control_in_1[9]   (User area 1, index 9)  
// Pin 18 → gpio_control_in_1[10]  (User area 1, index 10)
// Pin 19 → gpio_control_in_2[0]   (User area 2, index 0)
// Pin 20 → gpio_control_in_2[1]   (User area 2, index 1)
// ...
// Pin 24 → gpio_control_in_2[5]   (User area 2, index 5) 
// ...
// Pin 31 → gpio_control_in_2[12]  (User area 2, index 12)
```

### Complete Signal Path Example (Pin 24):
```verilog
// 1. Testbench drives
checkbits_lo[0] drives mprj_io[16] (via testbench assign)

// 2. Pad to GPIO control block
uut.padframe.mprj_pads.io[16] → uut.chip_core.mprj_io_in[16]

// 3. GPIO control block to housekeeping  
uut.chip_core.gpio_control_in_2[5].mgmt_gpio_in ← uut.chip_core.mprj_io_in[24]
uut.chip_core.gpio_control_in_2[5].mgmt_gpio_out → uut.chip_core.mprj_io_out[24]

// 4. Housekeeping register access
uut.chip_core.housekeeping.mgmt_gpio_in[24] ← uut.chip_core.mgmt_io_in_hk[24]
uut.chip_core.housekeeping.mgmt_gpio_out[24] → uut.chip_core.mgmt_io_out_hk[24]

// 5. Back to pads
uut.chip_core.mprj_io_out[24] → uut.padframe.mprj_pads.io[24]

// 6. Testbench monitors  
checkbits_hi[0] ← mprj_io[24] (via testbench assign)
```

This detailed port-to-port mapping shows exactly how GPIO signals flow through each hierarchical level with proper instance names and signal connections.

---

## GPIO PAD WRAPPER SPECIFICATION

### Critical Requirement for PDK Porting

This section documents the **minimum requirements** for a GPIO pad wrapper/IO pad module to properly support the Caravel GPIO test. This is **essential** when porting Caravel to different PDKs (e.g., from Sky130 to SCL180).

### ESSENTIAL PORTS (Must-Have)

#### 1. POWER & GROUND
```
VDD, VSS       - Core supply
VDDIO, VSSIO   - IO supply (may be same as core)
```

#### 2. PAD I/O
```
PAD            - Physical pin (inout)
```

#### 3. CONTROL SIGNALS (Required)
```
OUT            - Output driver signal (input)
OUT_EN_N       - Output enable, active low (input)
IN             - Input buffer output (output)
INPUT_DIS      - Input disable control (input)
```

#### 4. GPIO CONFIGURATION SIGNALS ⭐ (Firmware Configurable)
```
VTRIP_SEL      - Input voltage threshold (input)
                 Controls: 1.8V threshold vs 3.3V threshold
                 ⭐ CRITICAL - Missing in current pc3b03ed_wrapper!

dm[2:0]        - Drive mode (input)
                 Controls: Tri-state, input, input w/ pull, output strength

SLOW           - Slew rate control (input)
                 Controls: Fast vs slow output slew
```

#### 5. ADDITIONAL CONTROL (Often Used)
```
IB_MODE_SEL    - Input bias mode (input)
HLD_OVR        - Hold override (input)
ANALOG_EN      - Analog enable (input)
```

### FIRMWARE REQUIREMENTS

The GPIO test firmware (`gpio.c`) writes GPIO_MODE register bits:
```
Bit 0:        INP_DIS (input disable control)
Bit 9:        VTRIP_SEL (input voltage threshold) ⭐ CRITICAL
Bits 12-10:   DM (drive mode)
```

**The pad wrapper MUST expose these signals for firmware control.**

### COMPARISON: Working (Sky130) vs Not Working (SCL180)

#### sky130_ef_io__gpiov2_pad_wrapped (WORKING):
```
✓ 23+ ports
✓ Full feature-rich GPIO pad
✓ Supports VTRIP_SEL
✓ Supports DM (drive mode)
✓ Supports SLOW (slew rate)
✓ All advanced features
```

#### pc3b03ed_wrapper (CURRENTLY BROKEN):
```
✗ Only 6 ports (TOO SIMPLE!)
✓ Has OUT, IN, INPUT_DIS, OUT_EN_N, dm
✗ MISSING: VTRIP_SEL ← ROOT CAUSE OF GPIO TEST FAILURE
✗ MISSING: SLOW
✗ MISSING: IB_MODE_SEL
✗ MISSING: 20+ other control signals
```

### MINIMUM VIABLE WRAPPER MODULE

A proper GPIO pad wrapper should have at minimum:

```verilog
module gpio_pad_wrapper (
    // Power
    inout   VDDIO, VSSIO,
    inout   VDD, VSS,
    
    // Pad
    inout   PAD,
    
    // Control
    input   OUT,           // Output driver
    input   OUT_EN_N,      // Output enable (active low)
    output  IN,            // Input buffer
    input   INPUT_DIS,     // Input disable
    
    // Configuration (MUST HAVE)
    input   VTRIP_SEL,     // ⭐ CRITICAL! Input threshold
    input   [2:0] dm,      // Drive mode
    
    // Optional but useful
    input   SLOW,          // Slew rate control
    input   IB_MODE_SEL    // Input bias mode
);
    // ... instantiate actual pad cell with all required connections
endmodule
```

### WHAT TO SEARCH FOR IN NEW PDKs

When porting to a new PDK, search for pad cells with these names:
```
✓ "gpio_pad"        - GPIO-specific pad
✓ "io_pad"          - General IO pad
✓ "pad_vddio"       - IO pad with VDDIO support
✓ "digital_pad"     - Digital IO pad
✓ "vtrip" or "trip" - Cells with threshold control
```

The replacement pad **MUST have** (minimum):
```
✓ VTRIP_SEL or TRIP_POINT or VT_SEL or THR_SEL
✓ OUT or O or DRV (output)
✓ IN or I or RX (input)
✓ OE or OUT_EN or DRV_EN (output enable)
✓ INPUT_DIS or EN or IOBUF_EN (input enable/disable)
✓ dm[2:0] or DRIVE_MODE (drive mode)
```

### RED FLAGS - Avoid These Wrappers

```
❌ Only has: OUT, PAD, IN, INPUT_DIS, OUT_EN_N (insufficient!)
❌ No voltage threshold control port
❌ No drive mode control
❌ Documentation says "simplified" or "basic I/O only"
❌ Less than 8 ports total
```

### WHY VTRIP_SEL IS CRITICAL

The VTRIP_SEL signal controls the **input comparator voltage threshold**:

```
VTRIP_SEL = 0  → 1.8V threshold (detects 1.8V as HIGH)
VTRIP_SEL = 1  → 3.3V threshold (detects 3.3V as HIGH)
```

**Without VTRIP_SEL:**
- Pad stuck at default threshold (usually 1.8V)
- Cannot configure input voltage detection
- GPIO input reads always return 0x00 (LOW)
- Test fails because firmware cannot detect input values

**Current Failure:**
The `pc3b03ed_wrapper` has NO VTRIP_SEL port. This is an architectural limitation - even if we tried to connect VTRIP_SEL signal, the port doesn't exist in the wrapper!

### OPTIONS FOR FIXING

**Option 1: Find alternative SCL180 pad with full GPIO support** (BEST)
- Search PDK for alternative pad with VTRIP_SEL
- Create wrapper with all required ports
- Best option if available

**Option 2: Revert to Sky130 pads** (SAFEST)
- Use `sky130_ef_io__gpiov2_pad_wrapped`
- Safest but may not be feasible in full PDK migration

**Option 3: Extend pc3b03ed_wrapper** (VERY DIFFICULT)
- Add missing ports and internal logic
- May not be feasible without pad cell support
- Requires deep PDK knowledge
- May violate PDK licensing/restrictions

### RECOMMENDED NEXT STEPS

1. **Search PDK library for alternative pads:**
   ```bash
   grep -r "VTRIP\|trip\|threshold" /path/to/scl180/lib
   grep -r "module.*pad\|module.*io" /path/to/scl180/lib
   ```

2. **Compare all available pad options** - create spreadsheet with:
   - Pad name
   - Available ports
   - Has VTRIP_SEL? (Y/N)
   - Has DM? (Y/N)
   - Has SLOW? (Y/N)
   - PDK documentation link

3. **Select best match** - the one with most GPIO control signals

4. **Create new wrapper** - follow minimum viable module structure above

5. **Test GPIO functionality** - run gpio_tb.v to verify fix