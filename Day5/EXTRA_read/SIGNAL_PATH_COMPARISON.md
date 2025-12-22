# vtrip_sel Signal Path: Working vs NOT Working

## WORKING VERSION (rtl/mprj_io.v)

### Path: gpio_control_block → caravel_core → mprj_io → pad cell

**Step 1: Generated in gpio_control_block.v**
```verilog
output       pad_gpio_vtrip_sel,
assign pad_gpio_vtrip_sel = gpio_vtrip_sel;  ✓ Generated
```

**Step 2: Passed through caravel_core.v**
```verilog
// Line 102: Declared as module output
output [  `MPRJ_IO_PADS-1:0] mprj_io_vtrip_sel,

// Lines 1160, 1213, 1266, 1319, 1373: Connected to gpio_control_block outputs
.pad_gpio_vtrip_sel(mprj_io_vtrip_sel[1:0]),
.pad_gpio_vtrip_sel(mprj_io_vtrip_sel[7:2]),
... etc
```
✓ Signal flows through caravel_core

**Step 3: Received in mprj_io.v module**
```verilog
// Module port definition
input [TOTAL_PADS-1:0] vtrip_sel,
```
✓ Signal received as module input

**Step 4: CONNECTED to Sky130 pad cell**
```verilog
sky130_ef_io__gpiov2_pad_wrapped area1_io_pad [AREA1PADS - 1:0] (
    .OUT(io_out[AREA1PADS - 1:0]),
    .OE_N(oeb[AREA1PADS - 1:0]),
    .INP_DIS(inp_dis[AREA1PADS - 1:0]),
    .IB_MODE_SEL(ib_mode_sel[AREA1PADS - 1:0]),
    .VTRIP_SEL(vtrip_sel[AREA1PADS - 1:0]),  ✓✓✓ CONNECTED!
    .SLOW(slow_sel[AREA1PADS - 1:0]),
    .HLD_OVR(holdover[AREA1PADS - 1:0]),
    ...
);

sky130_ef_io__gpiov2_pad_wrapped area2_io_pad [TOTAL_PADS - AREA1PADS - 1:0] (
    ...
    .VTRIP_SEL(vtrip_sel[TOTAL_PADS - 1:AREA1PADS]),  ✓✓✓ CONNECTED!
    ...
);
```

**Result: Signal reaches pad cell ✓ TEST PASSES**

---

## NOT WORKING VERSION (not_working_rtl_with_scl/mprj_io.v)

### Path: gpio_control_block → caravel_core → mprj_io → ??? DEAD END

**Step 1: Generated in gpio_control_block.v**
```verilog
output       pad_gpio_vtrip_sel,
assign pad_gpio_vtrip_sel = gpio_vtrip_sel;  ✓ Generated
```
✓ Same as working version

**Step 2: Passed through caravel_core.v**
```verilog
// Line 102: Declared as module output
output [  `MPRJ_IO_PADS-1:0] mprj_io_vtrip_sel,

// Lines 1149, 1202, 1255, 1308, 1362: Connected to gpio_control_block outputs
.pad_gpio_vtrip_sel(mprj_io_vtrip_sel[1:0]),
.pad_gpio_vtrip_sel(mprj_io_vtrip_sel[7:2]),
... etc
```
✓ Same as working version - Signal flows through caravel_core

**Step 3: Received in mprj_io.v module**
```verilog
// Module port definition
input [TOTAL_PADS-1:0] vtrip_sel,
```
✓ Same as working version - Signal received as module input

**Step 4: NOT CONNECTED to SCL180 pad cell**
```verilog
pc3b03ed_wrapper area1_io_pad [AREA1PADS - 1:0](
    .IN(io_in[AREA1PADS - 1:0]),
    .OUT(io_out[AREA1PADS - 1:0]),
    .PAD(io[AREA1PADS - 1:0]),
    .INPUT_DIS(inp_dis[AREA1PADS - 1:0]),
    .OUT_EN_N(oeb[AREA1PADS - 1:0]),
    .dm(dm[AREA1PADS*3 - 1:0])
    // ✗✗✗ NO .VTRIP_SEL PORT! SIGNAL LOST HERE!
);

pc3b03ed_wrapper area2_io_pad [TOTAL_PADS - 1:AREA1PADS](
    .IN(io_in[TOTAL_PADS - 1:AREA1PADS]),
    .OUT(io_out[TOTAL_PADS - 1:AREA1PADS]),
    .PAD(io[TOTAL_PADS - 1:AREA1PADS]),
    .INPUT_DIS(inp_dis[TOTAL_PADS - 1:AREA1PADS]),
    .OUT_EN_N(oeb[TOTAL_PADS - 1:AREA1PADS]),
    .dm(dm[TOTAL_PADS*3 - 1:AREA1PADS*3])
    // ✗✗✗ NO .VTRIP_SEL PORT! SIGNAL LOST HERE!
);
```

**Result: Signal NEVER reaches pad cell ✗ TEST FAILS**

---

## Summary

| Stage | Working | NOT Working |
|-------|---------|------------|
| **Generated** | ✓ Yes | ✓ Yes |
| **Through caravel_core** | ✓ Yes | ✓ Yes |
| **Received in mprj_io** | ✓ Yes | ✓ Yes |
| **Connected to pad** | ✓ YES (.VTRIP_SEL) | ✗ NO (missing port) |
| **Result** | ✓ Pad configured, test passes | ✗ Pad unconfigured, test fails |

---

## The Problem

The signal is **generated** and **routed** through the entire system, but it **never reaches the pad cell** because:

1. Working uses `sky130_ef_io__gpiov2_pad_wrapped` which has `.VTRIP_SEL` port
2. NOT working uses `pc3b03ed_wrapper` which **doesn't have `.VTRIP_SEL` port**

The signal is like a water pipe:
- ✓ Water flows from source (gpio_control_block)
- ✓ Water flows through pipes (caravel_core → mprj_io)
- ✗ But the final faucet (pad cell) has no inlet!

---

## Fix Required

Check if `pc3b03ed_wrapper` pad cell definition supports these ports:
1. `.VTRIP_SEL` - CRITICAL for GPIO test
2. `.INPUT_DIS`
3. `.OUT_EN_N` 
4. `.dm`
5. `.IN`
6. `.OUT`
7. `.PAD`

If `pc3b03ed_wrapper` supports these ports, add them to mprj_io.v instantiation.
If it doesn't, need to use a different pad wrapper with full GPIO support.
