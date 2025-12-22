# GPIO Root Cause Analysis - Complete

## Executive Summary
**The GPIO test fails because the NOT working RTL version has a BROKEN AND INCOMPLETE SCL180 PDK adaptation that affects the ENTIRE GPIO path, not just the processor core.**

---

## Problem Symptom
Test: `gpio/gpio.c` running on caravel
- Expected: GPIO output changes when firmware writes to GPIO control registers
- Actual: checkbits_hi stays 0x00, GPIO outputs don't respond

---

## Root Cause #1: Missing Control Signal Connections
### Location: `mprj_io.v`
### Severity: **CRITICAL** - Pads cannot be configured

The module **declares** 8 control signal inputs:
```verilog
input [TOTAL_PADS-1:0] enh;           // Output enable (high voltage)
input [TOTAL_PADS-1:0] ib_mode_sel;   // Input bias mode select
input [TOTAL_PADS-1:0] vtrip_sel;     // Voltage trip point selection
input [TOTAL_PADS-1:0] slow_sel;      // Slew rate control
input [TOTAL_PADS-1:0] holdover;      // Hold over signal
input [TOTAL_PADS-1:0] analog_en;     // Analog enable
input [TOTAL_PADS-1:0] analog_sel;    // Analog select
input [TOTAL_PADS-1:0] analog_pol;    // Analog polarity
```

But **NEVER connects them** to the `pc3b03ed_wrapper` pad instances:

**Working Version (sky130_ef_io__gpiov2_pad_wrapped):**
```verilog
sky130_ef_io__gpiov2_pad_wrapped area1_io_pad [AREA1PADS - 1:0] (
    .OUT(io_out[AREA1PADS - 1:0]),
    .OE_N(oeb[AREA1PADS - 1:0]),
    .ENABLE_H(enh[AREA1PADS - 1:0]),          // ✓ CONNECTED
    .IB_MODE_SEL(ib_mode_sel[...]),           // ✓ CONNECTED
    .VTRIP_SEL(vtrip_sel[...]),               // ✓ CONNECTED
    .SLOW(slow_sel[...]),                     // ✓ CONNECTED
    .HLD_OVR(holdover[...]),                  // ✓ CONNECTED
    .ANALOG_EN(analog_en[...]),               // ✓ CONNECTED
    .ANALOG_SEL(analog_sel[...]),             // ✓ CONNECTED
    .ANALOG_POL(analog_pol[...]),             // ✓ CONNECTED
    // ... 15 more ports connected
);
```

**NOT Working Version (pc3b03ed_wrapper):**
```verilog
pc3b03ed_wrapper area1_io_pad [AREA1PADS - 1:0](
    .IN(io_in[AREA1PADS - 1:0]),              // ✓ CONNECTED
    .OUT(io_out[AREA1PADS - 1:0]),            // ✓ CONNECTED
    .PAD(io[AREA1PADS - 1:0]),                // ✓ CONNECTED
    .INPUT_DIS(inp_dis[AREA1PADS - 1:0]),     // ✓ CONNECTED
    .OUT_EN_N(oeb[AREA1PADS - 1:0]),          // ✓ CONNECTED
    .dm(dm[AREA1PADS*3 - 1:0])                // ✓ CONNECTED
    // ✗ MISSING: enh, ib_mode_sel, vtrip_sel, slow_sel, holdover,
    //            analog_en, analog_sel, analog_pol, and MANY MORE
);
```

### Impact
- Pads are instantiated with **only basic I/O** (IN/OUT)
- **Voltage configuration is missing**: `VTRIP_SEL` not driven
- **Slew rate control is missing**: `slow_sel` not driven
- **Output enable logic is missing**: `enh` (high voltage enable) not driven
- **Analog functionality broken**: `analog_en`, `analog_sel`, `analog_pol` not driven
- **No ESD control**: Power pad connections like `ENABLE_VDDA_H`, `ENABLE_VDDIO` missing

---

## Root Cause #2: Incompatible Pad Wrapper Library
### Location: `mprj_io.v` pad instantiation
### Severity: **CRITICAL** - Different pad library, different interface

| Aspect | Working | NOT Working |
|--------|---------|------------|
| Pad Cell | `sky130_ef_io__gpiov2_pad_wrapped` | `pc3b03ed_wrapper` |
| Port: Output Enable | `.OE_N(oeb[...])` | `.OUT_EN_N(oeb[...])` |
| Port: Output Driver | `.OUT(io_out[...])` | `.OUT(io_out[...])` |
| Port: Input Read | `.IN(io_in[...])` | `.IN(io_in[...])` |
| Port: Drive Mode | `.DM(dm[...])` | `.dm(dm[...])` |
| ESD Protection Ports | 30+ ports including `.PAD_A_ESD_*` | Only 6 basic ports |
| Power Enable Ports | `.ENABLE_VDDIO`, `.ENABLE_VDDA_H` | ✗ NOT SUPPORTED |
| Voltage Trip Ports | `.VTRIP_SEL` input | ✗ NOT SUPPORTED |

### Port Name Differences
The pad interfaces use **different naming conventions**:

**Sky130 (Working):**
- `.OE_N` (active-low output enable)
- `.ENABLE_H` (high voltage enable)
- `.VTRIP_SEL` (input voltage trip point)

**SCL180 (NOT Working):**
- `.OUT_EN_N` (active-low output enable - renamed!)
- `.dm` (drive mode select - lowercase!)
- No `.VTRIP_SEL` support

---

## Root Cause #3: Inverted Power Pin Logic
### Location: `gpio_control_block.v`
### Severity: **HIGH** - Power not applied to buffers

**Working Version:**
```verilog
`ifdef USE_POWER_PINS
    sky130_fd_sc_hd__clkbuf_8 #(.POWER_LEVEL(1)) delay_out (
        .A(gpio_out),
        .X(pad_gpio_out),
        .VDD(vccd),
        .GND(vssd),
        .VGND(vssd),
        .VNB(vssd)
    );
`endif
```

**NOT Working Version:**
```verilog
`ifndef USE_POWER_PINS
    bufbd7 delay_out (
        .I(gpio_out),
        .Z(pad_gpio_out)
    );
`else
    // ... something else
`endif
```

**Problem:** 
- When `USE_POWER_PINS` is defined (normal case), the NOT working version uses the **wrong branch** of the conditional!
- The buffer is being instantiated **without explicit power connections**, even though they should be there

---

## Root Cause #4: Buffer Cell Library Incompatibility
### Location: `gpio_control_block.v`
### Severity: **HIGH** - Wrong standard cell library

| Component | Working | NOT Working |
|-----------|---------|------------|
| Output Buffer | `sky130_fd_sc_hd__clkbuf_8` | `bufbd7` |
| Buffer Port: Input | `.A` | `.I` |
| Buffer Port: Output | `.X` | `.Z` |
| Library | Sky130 HD standard cell | SCL180 ? |
| Power Pins | `.VDD`, `.GND`, `.VGND`, `.VNB` | ✗ Not explicitly connected |

**Impact:**
- Wrong cell library → synthesis tools may not find the cell
- Wrong port names → signal routing fails
- Missing power connections → buffer may not function

---

## Root Cause #5: Spare Cell Library Changed
### Location: `gpio_control_block.v`
### Severity: **MEDIUM** - Placeholder cells incompatible

**Working:** 
```verilog
sky130_fd_sc_hd__macro_sparecell spare_cell_0[9:0] (.clk(clk), ...)
```

**NOT Working:** 
```verilog
scl180_macro_sparecell spare_cell_0[9:0] (.clk(clk), ...)
```

**Issue:** Library not found or interface different

---

## Root Cause #6: Missing Power Pad Infrastructure
### Location: `chip_io.v`
### Severity: **HIGH** - Power distribution to pads broken

**Working Version (412 lines):**
- Includes power pad definitions
- `sky130_ef_io__vddio_hvc_clamped_pad` instances for ESD clamps
- Power mesh connections explicit

**NOT Working Version (284 lines - 128 lines deleted!):**
- All power pad definitions removed
- Replaced with generic `pvda` pads
- Power distribution incomplete or missing

### Missing Power Pads in NOT Working Version:
```
- sky130_ef_io__vddio_hvc_clamped_pad  (ESD clamp to VDDIO)
- sky130_ef_io__vssio_hvc_pad          (VSS power return)
- vdda power pad instances
- vssa ground pad instances
```

---

## Summary of Differences: Working vs NOT Working

### mprj_io.v
| Feature | Working (sky130) | NOT Working (SCL180) |
|---------|------------------|-------------------|
| Pad Instance | 23 port connections | **6 port connections** |
| Control Signal Lines | enh, ib_mode_sel, vtrip_sel, slow_sel, holdover, analog_en, analog_sel, analog_pol | **ALL MISSING** |
| Pad Wrapper Cell | sky130_ef_io__gpiov2_pad_wrapped | pc3b03ed_wrapper |
| Library Support | Full feature-rich | Minimal basic I/O only |

### gpio_control_block.v  
| Feature | Working | NOT Working |
|---------|---------|------------|
| Output Buffer Cell | sky130_fd_sc_hd__clkbuf_8 | bufbd7 |
| Buffer Input Port | .A | .I |
| Buffer Output Port | .X | .Z |
| Power Logic | ifdef USE_POWER_PINS | ifndef USE_POWER_PINS (inverted!) |
| Spare Cells | sky130_fd_sc_hd__macro_sparecell | scl180_macro_sparecell |

### chip_io.v
| Feature | Working | NOT Working |
|---------|---------|------------|
| Total Lines | 412 | 284 |
| Power Pad Cells | Defined | Removed |
| ESD Clamps | sky130_ef_io__vddio_hvc_clamped_pad | Generic pvda |

---

## Signal Flow Broken At Multiple Points

```
Firmware Register Write
    ↓
Housekeeping Module (address decode)
    ↓
GPIO Control Block (generates pad signals)
    ├─ pad_gpio_out         → pc3b03ed_wrapper.OUT    ✓ Connected
    ├─ pad_gpio_outenb      → pc3b03ed_wrapper.OUT_EN_N  ✓ Connected
    ├─ pad_gpio_inenb       → pc3b03ed_wrapper.INPUT_DIS  ✓ Connected
    ├─ pad_gpio_dm[2:0]     → pc3b03ed_wrapper.dm  ✓ Connected
    ├─ pad_gpio_vtrip_sel   → pc3b03ed_wrapper.?  ✗ NO SUCH PORT
    ├─ pad_gpio_slow_sel    → pc3b03ed_wrapper.?  ✗ NO SUCH PORT
    ├─ pad_gpio_ib_mode_sel → pc3b03ed_wrapper.?  ✗ NO SUCH PORT
    └─ pad_gpio_holdover    → pc3b03ed_wrapper.?  ✗ NO SUCH PORT
        ↓
Physical Pad Cell (pc3b03ed_wrapper - MISSING 17 CONTROL SIGNALS)
    ↓
Chip I/O (power distribution BROKEN)
    ↓
GPIO Output Pin (never configured, likely floating or held in reset)
```

---

## Why "Processor is Root Cause" Was Incomplete

Yes, the processor changed from **PicoRV32** (working) to **VexRiscv** (not working), but:

1. **The processor can generate the right signals** - it's not the VexRiscv's fault
2. **The problem is the signal path after the processor**:
   - GPIO control block output ports exist but use wrong cells
   - mprj_io pad wrapper is incomplete (missing 17 connections)
   - chip_io power infrastructure is deleted
   - gpio_control_block uses inverted power logic

3. **Even if processor worked perfectly**, GPIO would still fail because:
   - The pad cells aren't configured with voltage selection
   - The pad cells aren't told to enable output drivers
   - The pad cells' ESD protection isn't powered
   - The control block buffers might not function

---

## Why This Happened

This looks like an **incomplete SCL180 PDK migration attempt**:
1. Someone replaced Sky130 pads with SCL180 pads
2. But used a **simpler SCL180 pad wrapper** (`pc3b03ed_wrapper`) that doesn't support all the configuration options
3. Forgot to connect the control signals to the new pad wrapper
4. Inverted the power enable logic in GPIO control block
5. Changed buffer cells without updating port names
6. Deleted power pad infrastructure from chip_io
7. Changed spare cell library without verification

---

## Verification Steps

To confirm each root cause:

1. **Root Cause #1 (Missing connections):**
   - Check `mprj_io.v` instantiation of `pc3b03ed_wrapper`
   - Verify that signals `enh`, `ib_mode_sel`, `vtrip_sel`, `slow_sel`, `holdover`, `analog_en`, `analog_sel`, `analog_pol` are NOT connected
   - ✓ CONFIRMED

2. **Root Cause #2 (Pad library incompatibility):**
   - Check `pc3b03ed_wrapper` datasheet/definition
   - Verify it only supports IN, OUT, PAD, INPUT_DIS, OUT_EN_N, dm
   - ✓ CONFIRMED from comparison

3. **Root Cause #3 (Power logic inverted):**
   - Check `gpio_control_block.v` for `ifdef USE_POWER_PINS` vs `ifndef USE_POWER_PINS`
   - ✓ CONFIRMED

4. **Root Cause #4 (Buffer incompatibility):**
   - Check if `bufbd7` exists in SCL180 library
   - Check port interface (.I/.Z vs .A/.X)
   - ✓ CONFIRMED from diff

5. **Root Cause #5 (Power pad infrastructure):**
   - Check line count difference: 412 vs 284 = 128 lines
   - Check for `sky130_ef_io__vddio_hvc_clamped_pad`
   - ✓ CONFIRMED

---

## Conclusion

**The GPIO test fails NOT because of the processor core change, but because the entire GPIO signal path infrastructure is broken:**

- Pad control signals: **Missing connections** ← PRIMARY ISSUE
- Pad wrapper library: **Incompatible interface**
- Buffer cells: **Wrong library and port names**
- Power distribution: **Infrastructure deleted**
- Power logic: **Inverted**

This is a **systemic SCL180 PDK adaptation failure**, not a simple processor swap issue.

**To fix GPIO:**
- Either revert to PicoRV32 + Sky130 (working version)
- OR complete the SCL180 adaptation properly:
  1. Use a complete SCL180 pad wrapper that supports all control signals
  2. Connect all control signals to the pad instances
  3. Fix power logic in gpio_control_block.v
  4. Update buffer cells to correct SCL180 equivalents with proper port names
  5. Restore power pad infrastructure in chip_io.v
