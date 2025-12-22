# SCL180 Adaptation Issues - GPIO Test Failure Analysis

## Summary
The `not_working_rtl_with_scl` version has critical differences in `mgmt_core_wrapper.v` that break GPIO functionality. The main issues are **broken SIM conditional compilation** and **commented-out power pins**.

---

## Critical Issue #1: Broken Simulation Includes

### **Working Version** (~/gits/caravel_pico/verilog/rtl/mgmt_core_wrapper.v)
**Lines 33-40:**
```verilog
/* Wrapper module around management SoC core for pin compatibility      */
/* with the Caravel harness chip.                                       */

`ifdef SIM
    `include "DFFRAM.v"
    `include "DFFRAMBB.v"
    `include "mgmt_core.v"
`endif
```

### **Not Working Version** (/home/iraj/VLSI/caravel/verilog/not_working_rtl_with_scl/mgmt_core_wrapper.v)
**Lines 29-36:**
```verilog
/* Wrapper module around management SoC core for pin compatibility  */
/* with the Caravel harness chip. */    

`include "mgmt_core.v"
`default_nettype wire

// MISSING the SIM conditional!
```

### **Impact:**
- **Working:** In simulation, memory arrays and management core are only included when `SIM` is defined
- **Not working:** Memory arrays and core are included unconditionally, potentially causing:
  - Memory initialization conflicts
  - Incorrect behavioral model usage
  - Module definition mismatches

---

## Critical Issue #2: Power Pins Completely Commented Out

### **Working Version** (Lines 43-46)
```verilog
`ifdef USE_POWER_PINS
    inout VPWR,           /* 1.8V domain */
    inout VGND,
`endif
```

### **Not Working Version** (Lines 39-42)
```verilog
/*`ifdef USE_POWER_PINS
    inout VPWR,     /* 1.8V domain */
 /*   inout VGND,
`endif*/
```

### **Impact:**
- **Working:** Power pins can be conditionally connected/disconnected based on USE_POWER_PINS flag
- **Not working:** Power pins are **completely disabled** - management core has no power definition
- This breaks the module port definition and can cause elaboration issues

---

## Critical Issue #3: Inverted Power Pin Logic in caravel_core.v

### **File:** `/home/iraj/VLSI/caravel/verilog/not_working_rtl_with_scl/caravel_core.v`

**Multiple locations use `ifndef` instead of `ifdef`:**

#### Location 1: mgmt_core_wrapper instantiation (Lines 282-287)
```verilog
mgmt_core_wrapper soc (
/*  `ifdef USE_POWER_PINS          ← SHOULD BE #ifdef, not commented
        .VPWR(vccd),
        .VGND(vssd),
    `endif
*/
```

#### Location 2: housekeeping instantiation (Lines 576-580)
```verilog
housekeeping housekeeping (
`ifndef USE_POWER_PINS             ← INVERTED! Should be ifdef
        .VPWR(vccd),
        .VGND(vssd),
`endif
```

#### Location 3: mgmt_protect instantiation (Lines 379-387)
```verilog
mgmt_protect mgmt_buffers (
/*  `ifdef USE_POWER_PINS          ← COMMENTED OUT
        .vccd(vccd),
        ...
`endif
*/
```

#### Location 4: caravel_clocking instantiation (Lines 526-530)
```verilog
caravel_clocking clock_ctrl (
/*`ifdef USE_POWER_PINS             ← COMMENTED OUT
        .VPWR(vccd),
        .VGND(vssd),
`endif*/
```

#### Location 5: digital_pll instantiation (Lines 547-551)
```verilog
digital_pll pll (
/*`ifdef USE_POWER_PINS             ← COMMENTED OUT
        .VPWR(vccd),
        .VGND(vssd),
`endif*/
```

### **Impact:**
- **Management core:** No power connections at all (lines 282-287)
- **Housekeeping:** Inverted logic - connected when USE_POWER_PINS is NOT defined
- **Clock/PLL:** No power connections - these critical blocks won't function
- **GPIO buffers:** No power connections

---

## Why GPIO Test Fails

### **Test Flow:**
1. Firmware calls: `reg_mprj_datal = 0xa0000000;`
2. Management SoC should forward wishbone transaction to housekeeping
3. Housekeeping updates `mgmt_gpio_data[31:0] = 0xa0000000`
4. GPIO control blocks read `mgmt_gpio_data` and drive pins
5. Testbench monitors `checkbits_hi` which should show `0xA0`

### **What Happens in Not Working Version:**
1. ❌ Management core has NO power - doesn't execute firmware
2. ❌ No wishbone transaction reaches housekeeping  
3. ❌ `mgmt_gpio_data` never updates
4. ❌ GPIO pins stay at default values
5. ❌ `checkbits_hi` stays `0x00` - TEST FAILS

---

## Required Fixes

### **Fix #1: Restore SIM Conditional in mgmt_core_wrapper.v**

**File:** `/home/iraj/VLSI/caravel/verilog/not_working_rtl_with_scl/mgmt_core_wrapper.v`

Replace lines 29-36:
```verilog
// WRONG (current):
`include "mgmt_core.v"
`default_nettype wire

// CORRECT (should be):
`ifdef SIM
    `include "DFFRAM.v"
    `include "DFFRAMBB.v"
    `include "mgmt_core.v"
`endif
```

### **Fix #2: Uncomment Power Pins in mgmt_core_wrapper.v**

Replace lines 39-42:
```verilog
// WRONG (current):
/*`ifdef USE_POWER_PINS
    inout VPWR,     /* 1.8V domain */
 /*   inout VGND,
`endif*/

// CORRECT (should be):
`ifdef USE_POWER_PINS
    inout VPWR,           /* 1.8V domain */
    inout VGND,
`endif
```

### **Fix #3: Restore Power Connections in caravel_core.v**

Replace all `ifndef USE_POWER_PINS` with `ifdef USE_POWER_PINS`:
- **Line 577:** housekeeping instantiation
- Uncomment all `ifdef` blocks for:
  - mgmt_core_wrapper (line 282)
  - mgmt_protect (line 379)
  - caravel_clocking (line 526)
  - digital_pll (line 547)
  - mprj_io_buffer (line 684)
  - All gpio_defaults_block instances
  - All gpio_control_block instances

---

## Conclusion

The SCL180 adaptation **removed/disabled critical power connections** to adapt for a different PDK, but this broke the design for simulation. The management processor can't execute without power, so no GPIO operations occur.

**The working version from ~/gits/caravel_pico is correct.** The SCL180 adaptation needs these power connections restored.

