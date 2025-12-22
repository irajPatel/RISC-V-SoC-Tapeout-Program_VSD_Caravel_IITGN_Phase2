# GPIO Test Debugging - Critical Signals Analysis

## Overview
This document provides a systematic approach to debug GPIO test failures by monitoring the most critical signals in the Caravel GPIO subsystem. The signals are prioritized by their diagnostic value and organized by common failure patterns.

## Critical Signal Priority Matrix

### **PRIORITY 1: Test Interface & System Fundamentals**
These signals tell you immediately if the test is progressing and where it's stuck:

```verilog
// Test Interface - Monitor FIRST
checkbits_hi[7:0]                    // DUT output to testbench - shows test progression
checkbits_lo[7:0]                    // Testbench input to DUT - what you're driving
mprj_io[31:24]                       // Physical output pins (should match checkbits_hi)
mprj_io[23:16]                       // Physical input pins (should match checkbits_lo)

// System Status
clock                                // System clock running?
RSTB                                 // Reset properly released?
uut.chip_core.caravel_rstn           // Internal reset status
```

**Expected Progression:**
- `checkbits_hi` should show: `8'h00` → `8'hA0` → `8'h0B` → `8'hAB` → `8'h02` → `8'h04`
- If stuck at any value, that tells you exactly which phase failed

### **PRIORITY 2: Firmware-to-Hardware Data Path**
Check if firmware register writes are reaching the GPIO hardware:

```verilog
// Wishbone Transaction from Management SoC
uut.chip_core.soc.mprj_adr_o[31:0]   // Should show 0x2600000C during GPIO writes
uut.chip_core.soc.mprj_dat_o[31:0]   // Should show 0xA0000000, 0x0B000000, 0xAB000000, etc.
uut.chip_core.soc.mprj_we_o          // Write enable pulse
uut.chip_core.soc.mprj_cyc_o         // Wishbone cycle
uut.chip_core.soc.mprj_stb_o         // Wishbone strobe

// Housekeeping Module - THE MOST CRITICAL REGISTER
uut.chip_core.housekeeping.mgmt_gpio_data[31:0]     // ⭐ SINGLE MOST IMPORTANT SIGNAL ⭐
uut.chip_core.housekeeping.wb_adr_i[31:0]           // Address received by housekeeping
uut.chip_core.housekeeping.wb_dat_i[31:0]           // Data received by housekeeping  
uut.chip_core.housekeeping.wb_we_i                  // Write enable received
uut.chip_core.housekeeping.wb_ack_o                 // Housekeeping acknowledge
```

**Expected Values:**
- `mgmt_gpio_data[31:24]` should progress: `8'h00` → `8'hA0` → `8'h0B` → `8'hAB` → `8'h02` → `8'h04`

### **PRIORITY 3: GPIO Control & Output Enable Path**
Check if data flows from housekeeping to physical pads:

```verilog
// GPIO Control Block Status (Pin 24 example)
uut.chip_core.gpio_control_in_2[5].mgmt_ena         // Pin 24 management control enabled?
uut.chip_core.gpio_control_in_2[5].mgmt_gpio_out    // Pin 24 management data
uut.chip_core.gpio_control_in_2[5].pad_gpio_out     // Pin 24 final output
uut.chip_core.gpio_control_in_2[5].pad_gpio_outenb  // Pin 24 output enable

// All Test Pins Output Status
uut.chip_core.mprj_io_out[31:24]     // Final output values to all test pins
uut.chip_core.mprj_io_oeb[31:24]     // Output enables (should be 0 for outputs)
```

**Expected for Outputs (Pins 31:24):**
- `mgmt_ena` = 1 (management control)
- `pad_gpio_outenb` = 0 (output enabled)
- `mprj_io_oeb[31:24]` = 8'h00 (all outputs enabled)

### **PRIORITY 4: Input Path (When Stuck in Handshake)**
Check if testbench inputs reach the firmware:

```verilog
// Input Path from Testbench to Firmware
uut.chip_core.mprj_io_in[23:16]                     // Inputs from physical pads
uut.chip_core.housekeeping.mgmt_gpio_in[23:16]      // Inputs available to firmware

// Individual Input Pin Status (Pin 16 example)
uut.chip_core.gpio_control_in_1[8].pad_gpio_in      // Pin 16 physical input
uut.chip_core.gpio_control_in_1[8].mgmt_gpio_in     // Pin 16 to management
uut.chip_core.gpio_control_in_1[8].mgmt_ena         // Pin 16 management control
```

**Expected for Inputs (Pins 23:16):**
- Should reflect `checkbits_lo` values driven by testbench
- `mgmt_ena` = 1 (management control)

## Common Failure Patterns & Diagnostic Approach

### **PATTERN 1: Test Never Starts (checkbits_hi = 8'h00)**

**Root Cause:** Firmware writes not reaching GPIO hardware

**Check These Signals:**
```verilog
1. uut.chip_core.soc.mprj_adr_o        // Any wishbone transactions?
2. uut.chip_core.soc.mprj_we_o         // Write pulses occurring?
3. uut.chip_core.housekeeping.wb_ack_o // Housekeeping responding?
4. uut.chip_core.housekeeping.mgmt_gpio_data[31:24] // Register updating?
```

**Expected:** Should see `mprj_adr_o = 0x2600000C` and `mgmt_gpio_data` updating

### **PATTERN 2: Wrong Output Values (checkbits_hi ≠ expected)**

**Root Cause:** Data corruption in output path

**Check These Signals:**
```verilog
1. uut.chip_core.housekeeping.mgmt_gpio_data[31:24] // Correct value stored?
2. uut.chip_core.mprj_io_out[31:24]                // Reaching pads?
3. uut.chip_core.gpio_control_in_2[5].mgmt_ena     // Management control active?
4. uut.chip_core.mprj_io_oeb[31:24]                // Output enables correct?
```

**Expected:** Data should flow unchanged from `mgmt_gpio_data` to `mprj_io_out`

### **PATTERN 3: Stuck in Handshake (checkbits_hi = 8'hA0, waiting for next phase)**

**Root Cause:** Input path not working - firmware can't read testbench response

**Check These Signals:**
```verilog
1. checkbits_lo                                    // Testbench driving?
2. mprj_io[23:16]                                 // Making it to pins?
3. uut.chip_core.mprj_io_in[23:16]               // Reaching core?
4. uut.chip_core.housekeeping.mgmt_gpio_in[23:16] // Available to firmware?
```

**Expected:** Input path should carry `checkbits_lo` values to firmware

### **PATTERN 4: Increment Test Fails (stuck at 8'h02 or wrong arithmetic)**

**Root Cause:** Firmware execution issue or input/output path problem

**Check These Signals:**
```verilog
1. uut.chip_core.housekeeping.mgmt_gpio_in[23:16]  // Reading correct input value?
2. checkbits_lo vs mgmt_gpio_in[23:16]             // Input path working?
3. uut.chip_core.housekeeping.mgmt_gpio_data[31:24] // Correct calculated result?
4. Management processor execution state (PC, instruction)
```

**Expected:** Input `8'h01` should produce output `8'h02`, input `8'h03` → output `8'h04`

## Quick Debugging Decision Tree

```
Start Here: What does checkbits_hi show?

├── 8'h00 (Never starts)
│   └── Check: soc.mprj_* signals, housekeeping.mgmt_gpio_data
│
├── 8'hA0 (Stuck after first write)  
│   └── Check: Input path - mprj_io_in[23:16], mgmt_gpio_in[23:16]
│
├── 8'h0B or 8'hAB (Progressing but stuck)
│   └── Check: Same as above - input path issue
│
├── Wrong Value (e.g., 8'h50 instead of 8'hA0)
│   └── Check: mgmt_gpio_data vs mprj_io_out, mgmt_ena signals
│
└── 8'h02 (Stuck in increment)
    └── Check: Input path + processor execution
```

## The "Golden Signal" for Quick Debug

**If you can only monitor ONE signal:**
```verilog
uut.chip_core.housekeeping.mgmt_gpio_data[31:0]
```

This register should show the complete test progression:
- `32'h00000000` (initial)
- `32'hA0000000` (phase 1)
- `32'h0B000000` (phase 2) 
- `32'hAB000000` (phase 3)
- `32'h02000000` (increment: 1+1)
- `32'h04000000` (increment: 3+1, TEST PASS)

**Decision Logic:**
- ✅ If this register updates correctly BUT `checkbits_hi` is wrong → **Output path problem**
- ❌ If this register doesn't update → **Wishbone/Firmware problem**
- ⚠️ If this register updates partially then stops → **Input path problem**

## Signal Monitoring Commands for GTKWave

Add these signals to your waveform viewer for complete visibility:

```verilog
// Test Interface
checkbits_hi[7:0]
checkbits_lo[7:0]
mprj_io[31:16]

// System
clock
RSTB

// Critical Data Path
uut.chip_core.housekeeping.mgmt_gpio_data[31:0]
uut.chip_core.soc.mprj_adr_o[31:0]
uut.chip_core.soc.mprj_dat_o[31:0]
uut.chip_core.soc.mprj_we_o

// GPIO Control (Key Pins)
uut.chip_core.gpio_control_in_2[5].mgmt_ena        // Pin 24
uut.chip_core.gpio_control_in_2[5].pad_gpio_out    // Pin 24
uut.chip_core.gpio_control_in_1[8].mgmt_ena        // Pin 16  
uut.chip_core.gpio_control_in_1[8].pad_gpio_in     // Pin 16

// Final I/O
uut.chip_core.mprj_io_out[31:16]
uut.chip_core.mprj_io_oeb[31:16]
uut.chip_core.mprj_io_in[31:16]
```

## Success Criteria Validation

**Test PASSES when you see:**
1. `checkbits_hi` progression: `00→A0→0B→AB→02→04`
2. `mgmt_gpio_data` progression: `00000000→A0000000→0B000000→AB000000→02000000→04000000`
3. Clean wishbone transactions with proper acknowledges
4. All `mgmt_ena` signals = 1 for test pins
5. Output enables correct: `mprj_io_oeb[31:24] = 8'h00`, `mprj_io_oeb[23:16] = 8'hFF`

**Test FAILS when:**
- Any signal gets stuck or shows wrong values
- Timeout occurs (25,000 cycles without progress)
- `mgmt_gpio_data` doesn't match expected progression

This systematic approach will quickly isolate whether the failure is in the firmware→hardware path, hardware→firmware path, or GPIO control logic.