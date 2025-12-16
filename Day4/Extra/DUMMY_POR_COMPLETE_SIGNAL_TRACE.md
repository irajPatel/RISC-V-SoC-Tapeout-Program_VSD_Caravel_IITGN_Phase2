# Complete Signal Trace: dummy_por.v (Power-On-Reset Module)

## File Location
```
Day4/vsdRiscvScl180/rtl/dummy_por.v (87 lines)
```

---

## Module Definition

```verilog
module dummy_por(
    // POWER SUPPLIES (Inputs)
    inout vdd3v3,      ← 3.3V domain power supply
    inout vdd1v8,      ← 1.8V domain power supply  
    inout vss3v3,      ← 3.3V domain ground
    inout vss1v8,      ← 1.8V domain ground
    
    // OUTPUTS (Generated Reset Signals)
    output porb_h,     ← Power-on-reset (active low) in high domain (3.3V)
    output porb_l,     ← Power-on-reset (active low) in low domain (1.8V)
    output por_l       ← Power-on-reset (active high) inverted version
);
```

---

## Module Behavior (Simulation Model)

```
Internal Implementation:
├── inode (internal capacitor charge state)
│   └── Initial value: 0 (discharged)
│   └── After 500ns: charges to 1 (due to current source emulation)
│
├── hystbuf1 (Schmitt trigger buffer #1)
│   ├── Input: inode
│   ├── Output: mid (intermediate)
│   └── Power: vdd3v3, vss3v3
│
├── hystbuf2 (Schmitt trigger buffer #2)
│   ├── Input: mid
│   ├── Output: porb_h
│   └── Power: vdd3v3, vss3v3
│
└── Logic assignments
    ├── porb_l = porb_h     (Level shifter already in pads for SCL180)
    └── por_l = ~porb_l     (Inverted version)
```

---

## Signal Generation Timeline

```
Power-up sequence:
├── Time 0ns:        inode = 0, porb_h = 0 (in reset)
├── Time 500ns:      inode transitions to 1 (capacitor charges)
├── Time ~520ns:     mid = 1 (after hystbuf1 propagation)
├── Time ~540ns:     porb_h = 1 (after hystbuf2 propagation)
├── Time ~540ns:     porb_l = 1 (assigned from porb_h)
├── Time ~540ns:     por_l = 0 (inverted from porb_l)
│
└── After 540ns:     System is out of reset
```

---

---

## COMPLETE SIGNAL TRACE THROUGH HIERARCHY

---

## LEVEL 0: dummy_por.v (Module Definition)

**File:** `Day4/vsdRiscvScl180/rtl/dummy_por.v`

```
INPUTS (From Power Supplies):
├─ vdd3v3    (3.3V power)
├─ vdd1v8    (1.8V power)
├─ vss3v3    (3.3V ground)
└─ vss1v8    (1.8V ground)

OUTPUTS (Generated):
├─ porb_h    (Power-on-reset, active low, 3.3V domain)
├─ porb_l    (Power-on-reset, active low, 1.8V domain)
└─ por_l     (Power-on-reset, active high)
```

---

## LEVEL 1: caravel_core.v (First Instantiation)

**File:** `Day4/vsdRiscvScl180/rtl/caravel_core.v`

**Instance Location:** Line 1259-1266

### Instance Declaration:
```verilog
dummy_por por (
    `ifdef USE_POWER_PINS
        .vdd3v3(vddio),        ← vddio from caravel_core port
        .vdd1v8(vccd),         ← vccd from caravel_core port
        .vss3v3(vssio),        ← vssio from caravel_core port
        .vss1v8(vssd),         ← vssd from caravel_core port
    `endif
        .porb_h(porb_h),       → porb_h (internal wire in caravel_core)
        .porb_l(porb_l),       → porb_l (internal wire in caravel_core)
        .por_l(por_l)          → por_l (internal wire in caravel_core)
);
```

### Power Inputs to dummy_por (FROM caravel_core PORT INPUTS):
```
caravel_core module ports (from vsdcaravel.v):
├── vddio        ← from chip_io (padframe)
├── vssio        ← from chip_io (padframe)
├── vccd         ← from chip_io (padframe)
└── vssd         ← from chip_io (padframe)

These are connected to dummy_por inputs:
├── vdd3v3 ← vddio
├── vss3v3 ← vssio
├── vdd1v8 ← vccd
└── vss1v8 ← vssd
```

### Outputs FROM dummy_por (GENERATED IN caravel_core):
```
porb_h ← Power-on-reset high (active low)
porb_l ← Power-on-reset low (active low)
por_l  ← Power-on-reset low inverted (active high)

These are wires within caravel_core.
```

---

## LEVEL 2: Where porb_h is USED in caravel_core

### **USAGE 1: caravel_clocking module (Line 531)**

```verilog
caravel_clocking clock_ctrl (
    ...
    .porb(porb_l),     ← porb_l from dummy_por output
    ...
);
```
**Purpose:** Reset input for clock controller

---

### **USAGE 2: digital_pll module (Line 594)**

```verilog
digital_pll pll (
    ...
    .resetb(rstb_l),   ← NOT porb_h, but rstb_l (from reset level converter)
    ...
);
```
**Purpose:** Reset input for PLL/DCO

---

### **USAGE 3: housekeeping module (Line 1392)**

```verilog
housekeeping housekeeping (
    ...
    .porb(porb_l),     ← porb_l from dummy_por output
    ...
);
```
**Purpose:** Power-on-reset monitoring in housekeeping SPI controller

---

### **USAGE 4: chip_io padframe (Input port)**

```
chip_io receives:
├── porb_h input (from caravel_core output)
└── Used for: mprj_io_enh generation

In chip_io.v Line 116:
assign mprj_io_enh = {`MPRJ_IO_PADS{porb_h}};
                      ↓
Generates enable for all 38 user I/O pads
```

---

## LEVEL 3: vsdcaravel.v (Top-level wrapper)

**File:** `Day4/vsdRiscvScl180/rtl/vsdcaravel.v`

**Instance of caravel_core:** Line 254-256

### Connections FROM caravel_core outputs:
```verilog
caravel_core chip_core (
    // Power inputs
    .vddio(vddio),
    .vssio(vssio),
    .vccd(vccd),
    .vssd(vssd),
    
    // Outputs (from dummy_por)
    .porb_h(porb_h),       ← Connected to wire porb_h in vsdcaravel
    .por_l(por_l),         ← Connected to wire por_l in vsdcaravel
    ...
);
```

**Wires in vsdcaravel.v:** Lines 175-177
```verilog
wire porb_h;    ← from caravel_core (which gets from dummy_por)
wire porb_l;    ← from caravel_core (which gets from dummy_por)
wire por_l;     ← from caravel_core (which gets from dummy_por)
```

---

### Connection TO chip_io padframe (Line 312):

```verilog
chip_io padframe (
    // Power supplies COME IN from package pins
    .vddio_pad(vddio),
    .vssio_pad(vssio),
    .vccd_pad(vccd),
    .vssd_pad(vssd),
    
    // Power supplies OUTPUT to internal logic
    .vddio(vddio_internal),
    .vssio(vssio_internal),
    .vccd(vccd_internal),
    .vssd(vssd_internal),
    
    // Power-on-reset signal INPUT from caravel_core
    .porb_h(porb_h),       ← FROM caravel_core → TO chip_io
    ...
);
```

---

## LEVEL 4: chip_io.v (Padframe Module)

**File:** `Day4/vsdRiscvScl180/rtl/chip_io.v`

**Input Port:** Line 64
```verilog
input  porb_h,           ← FROM caravel_core via vsdcaravel.v
```

### **USAGE in chip_io.v:**

#### **LINE 116: mprj_io Enable Generation**
```verilog
wire [`MPRJ_IO_PADS-1:0] mprj_io_enh;

assign mprj_io_enh = {`MPRJ_IO_PADS{porb_h}};
                      ↑
        Replicates porb_h 38 times (one for each user I/O pad)
```

**Purpose:** Enable signal for all 38 user I/O pads when chip is out of reset

#### **LINE 1199: mprj_io Pad Instance Connection**
```verilog
mprj_io mprj_pads(
    .porb_h(porb_h),       ← PASSED TO pad array
    .enh(mprj_io_enh),     ← [37:0] bits, all driven by porb_h
    .vccd_conb(mprj_io_one),
    ...
);
```

---

## COMPLETE SIGNAL PATH DIAGRAM

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         PACKAGE PINS (External)                         │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│   vddio_pad (3.3V)      vssd_pad (ground)      vccd_pad (1.8V)          │
│        ↓                      ↓                       ↓                   │
└─────────────────────────────────────────────────────────────────────────┘
        ↓                      ↓                       ↓
        │                      │                       │
┌─────────────────────────────────────────────────────────────────────────┐
│                         CHIP_IO.V (PADFRAME)                             │
│                                                                           │
│   vddio_pad ──→ .vddio_pad     mprj_io_enh input                        │
│   vssd_pad ──→ .vssd_pad       ↓                                         │
│   vccd_pad ──→ .vccd_pad       ┌─────────────────────┐                  │
│                                │ mprj_io (38 pads)  │                  │
│   [Internal routing]           │                     │                  │
│   vddio ──┐                    │ .porb_h ←──┐        │                  │
│   vssd ──┼─→ TO caravel_core   │ .enh[37:0] ←─ {38{porb_h}}             │
│   vccd ──┤                     │             │       │                  │
│   vssa ──┘                     │ .io[37:0]──→ Package pins              │
│                                │             (user I/O pads)            │
└─────────────────────────────────────────────────────────────────────────┘
        ↓
        │ Power supplies to
        │ internal caravel_core
        │
┌─────────────────────────────────────────────────────────────────────────┐
│                      CARAVEL_CORE.V (MAIN SoC)                           │
│                                                                           │
│   Port Inputs (power supplies from chip_io):                             │
│   ├─ vddio ────────┐                                                    │
│   ├─ vssio ────────┼──→ [power routing throughout]                      │
│   ├─ vccd ─────────┤                                                    │
│   └─ vssd ────────┘                                                     │
│                         ↓                                                │
│   ┌─────────────────────────────────────────────────────────────────┐  │
│   │ DUMMY_POR MODULE INSTANTIATION (Line 1259-1266)                │  │
│   │                                                                 │  │
│   │ Instance name: por                                              │  │
│   │                                                                 │  │
│   │ .vdd3v3 ←─ vddio                                                │  │
│   │ .vss3v3 ←─ vssio                                                │  │
│   │ .vdd1v8 ←─ vccd                                                 │  │
│   │ .vss1v8 ←─ vssd                                                 │  │
│   │ .porb_h ──→ porb_h (wire in caravel_core) [OUTPUT #1]           │  │
│   │ .porb_l ──→ porb_l (wire in caravel_core) [OUTPUT #2]           │  │
│   │ .por_l  ──→ por_l  (wire in caravel_core) [OUTPUT #3]           │  │
│   │                                                                 │  │
│   │ Internal Logic:                                                │  │
│   │ ├─ inode capacitor charge (0→1 after 500ns)                    │  │
│   │ ├─ hystbuf1: inode → mid (schmitt trigger)                     │  │
│   │ ├─ hystbuf2: mid → porb_h (schmitt trigger)                    │  │
│   │ ├─ porb_l = porb_h (level shifter already in pads)             │  │
│   │ └─ por_l = ~porb_l (inverted version)                          │  │
│   └─────────────────────────────────────────────────────────────────┘  │
│                                                                           │
│   ┌─────────────────────────────────────────────────────────────────┐  │
│   │ WHERE porb_h IS USED IN CARAVEL_CORE:                          │  │
│   │                                                                 │  │
│   │ 1. Passed back to chip_io:                                      │  │
│   │    └─→ chip_io.porb_h ← caravel_core.porb_h                    │  │
│   │        Used for: mprj_io_enh = {38{porb_h}}                    │  │
│   │                                                                 │  │
│   │ 2. Used within caravel_core (porb_l):                           │  │
│   │    └─→ caravel_clocking (clock_ctrl)                            │  │
│   │    └─→ digital_pll (pll)                                        │  │
│   │    └─→ housekeeping                                             │  │
│   └─────────────────────────────────────────────────────────────────┘  │
│                                                                           │
└─────────────────────────────────────────────────────────────────────────┘
        ↓
        │
┌─────────────────────────────────────────────────────────────────────────┐
│                      VSDCARAVEL.V (TOP-LEVEL)                            │
│                                                                           │
│   Wire declarations (Lines 175-177):                                    │
│   ├─ wire porb_h;     ← FROM caravel_core instance                      │
│   ├─ wire porb_l;     ← FROM caravel_core instance                      │
│   └─ wire por_l;      ← FROM caravel_core instance                      │
│                                                                           │
│   Connections:                                                           │
│   ├─ chip_io padframe:       .porb_h(porb_h)                            │
│   ├─ caravel_core chip_core: .porb_h(porb_h)                            │
│   └─                         .por_l(por_l)                              │
│                                                                           │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## SIGNAL FLOW SUMMARY

### **POWER SUPPLIES (Inputs to dummy_por)**

```
Package Pins
    ↓
chip_io (padframe)
    ├─ vddio_pad → vddio (internal)
    ├─ vssio_pad → vssio (internal)
    ├─ vccd_pad  → vccd (internal)
    └─ vssd_pad  → vssd (internal)
    ↓
vsdcaravel.v (top level)
    ↓
caravel_core.v
    ├─ vddio → dummy_por.vdd3v3
    ├─ vssio → dummy_por.vss3v3
    ├─ vccd  → dummy_por.vdd1v8
    └─ vssd  → dummy_por.vss1v8
```

### **RESET SIGNALS (Outputs from dummy_por)**

```
dummy_por (internal to caravel_core)
    ↓
3 Output Signals:
├─ porb_h (power-on-reset high, active low)
│   ├─ Used within caravel_core:
│   │   └─ Passed to chip_io.porb_h
│   │       └─ Used for: mprj_io_enh = {38{porb_h}}
│   │           └─ Enables all 38 user I/O pads
│   │
│   └─ Used by housekeeping SPI controller (indirectly via porb_l)
│
├─ porb_l (power-on-reset low, active low)
│   ├─ caravel_clocking.porb ← porb_l
│   │   └─ Selects clock source
│   │
│   ├─ digital_pll.resetb ← rstb_l (from level converter)
│   │   └─ Resets PLL/DCO
│   │
│   └─ housekeeping.porb ← porb_l
│       └─ Monitors power-on-reset state
│
└─ por_l (power-on-reset inverted, active high)
    └─ Passed out as caravel_core output
        └─ Available at vsdcaravel level
```

---

## FILES THAT CONTAIN dummy_por

### **Used Locations:**

1. **Day4/vsdRiscvScl180/rtl/dummy_por.v** ← SOURCE FILE (87 lines)

2. **Day4/vsdRiscvScl180/rtl/caravel_core.v** → INSTANTIATED (Line 1259-1266)
   ```verilog
   dummy_por por (
       .vdd3v3(vddio),
       .vss3v3(vssio),
       .vdd1v8(vccd),
       .vss1v8(vssd),
       .porb_h(porb_h),
       .porb_l(porb_l),
       .por_l(por_l)
   );
   ```

3. **Day4/vsdRiscvScl180/rtl/vsdcaravel.v** → CONNECTED via caravel_core (Lines 175-177)
   - Wires declared for porb_h, porb_l, por_l
   - Connected to caravel_core and chip_io

4. **Day4/vsdRiscvScl180/rtl/chip_io.v** → RECEIVES porb_h output (Line 64)
   - Input port: porb_h
   - Usage: mprj_io_enh = {38{porb_h}}

5. **Day4/vsdRiscvScl180/rtl/caravel.v** → WRAPPER variant (same as vsdcaravel.v)

6. **Day4/vsdRiscvScl180/synthesis/memory_por_blackbox_stubs.v** → BLACKBOX for synthesis

7. **Day3, Day2** variants → Same structure in earlier revisions

---

## Key Points Summary

| Aspect | Details |
|--------|---------|
| **Module** | dummy_por.v |
| **Instance Name** | `por` |
| **Location** | caravel_core.v, Line 1259-1266 |
| **Inputs** | vdd3v3, vdd1v8, vss3v3, vss1v8 (power supplies) |
| **Outputs** | porb_h, porb_l, por_l (reset signals) |
| **Behavior** | Capacitor charge with schmitt triggers (500ns delay in sim) |
| **Purpose** | Generate power-on-reset signals for all clock/reset domains |
| **porb_h Used For** | Enables user I/O pads (38×) in chip_io |
| **porb_l Used For** | Clock controller, PLL, housekeeping |
| **por_l Used For** | Inverted reset signal output |

---

## Complete Hierarchy Chain

```
DUMMY_POR SIGNAL CHAIN:

Package Power Pins (3.3V, 1.8V, GND)
    ↓ (passed through chip_io)
caravel_core inputs (vddio, vccd, vssio, vssd)
    ↓
dummy_por instantiation
    ├─→ Internal: Capacitor charges with hysteresis
    ├─→ Output 1: porb_h (high domain reset)
    ├─→ Output 2: porb_l (low domain reset)
    └─→ Output 3: por_l (inverted reset)
    ↓
Back to caravel_core outputs
    ├─→ porb_h → chip_io (for pad enable)
    ├─→ porb_l → caravel_clocking (clock mux)
    ├─→ porb_l → digital_pll (PLL reset)
    └─→ porb_l → housekeeping (config ctrl)
    ↓
User I/O Pads Get:
    ├─→ mprj_io_enh[37:0] = {38{porb_h}}
    └─→ Enables all 38 pads when out of reset
```

---

## Timing Behavior

```
Power-up Sequence:
├── T=0ns:       Power applied
├── T=0ns:       inode = 0, all outputs = 0 (system in reset)
│
├── T=500ns:     Capacitor charges (current source model)
├── T=500ns:     inode transitions from 0→1
│
├── T=520ns:     hystbuf1 output (mid) = 1
├── T=540ns:     hystbuf2 output (porb_h) = 1
│
├── T=540ns:     porb_l = porb_h = 1
├── T=540ns:     por_l = ~porb_l = 0
│
└── T>540ns:     System released from reset
                 ├─ Clock enabled (caravel_clocking)
                 ├─ PLL enabled (digital_pll)
                 ├─ I/O pads enabled (mprj_io_enh)
                 └─ Housekeeping active
```

---

## Data Flow Direction

```
INPUTS (INTO dummy_por):
├─ vdd3v3  ← 3.3V power (from package pin through chip_io)
├─ vdd1v8  ← 1.8V power (from package pin through chip_io)
├─ vss3v3  ← Ground     (from package pin through chip_io)
└─ vss1v8  ← Ground     (from package pin through chip_io)

OUTPUTS (FROM dummy_por):
├─ porb_h  ────→ Goes back to caravel_core
                └─→ Routed to chip_io
                    └─→ Used to enable 38 user I/O pads
├─ porb_l  ────→ Goes to caravel_clocking (clock mux)
                └─→ Goes to digital_pll (PLL reset)
                └─→ Goes to housekeeping (config)
└─ por_l   ────→ Goes out as caravel_core output
                └─→ Available at vsdcaravel level
```
