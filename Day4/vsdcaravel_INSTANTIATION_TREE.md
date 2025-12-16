# vsdcaravel.v - Complete Module Instantiation Tree

## File: vsdcaravel.v (TOP-LEVEL SoC CHIP)
**Location:** `Day4/vsdRiscvScl180/rtl/vsdcaravel.v`  
**Total Lines:** 367 lines  
**Total Modules Instantiated:** 7 modules

---

## INCLUDES (Files brought into vsdcaravel.v):

```
├── copyright_block.v
├── caravel_logo.v
├── caravel_motto.v
├── open_source.v
├── user_id_textblock.v
└── caravel_core.v (contains module definition - NOT instantiated, just included)
```

---

## MODULE INSTANTIATIONS (Actual module instances created):

```
vsdcaravel
│
├── INSTANCE 1: chip_io (instance name: padframe)
│   │   
│   └── Connects:
│       ├── Package Pins (external pad connections)
│       │   ├── vddio_pad, vddio_pad2
│       │   ├── vssio_pad, vssio_pad2
│       │   ├── vccd_pad, vssd_pad
│       │   ├── vdda_pad, vssa_pad
│       │   ├── vdda1_pad, vdda1_pad2
│       │   ├── vdda2_pad
│       │   ├── vssa1_pad, vssa1_pad2
│       │   ├── vssa2_pad
│       │   ├── vccd1_pad, vccd2_pad
│       │   ├── vssd1_pad, vssd2_pad
│       │   ├── gpio
│       │   ├── mprj_io (38-bit bidirectional)
│       │   ├── clock
│       │   ├── resetb
│       │   ├── flash_csb
│       │   ├── flash_clk
│       │   ├── flash_io0 (bidir)
│       │   └── flash_io1 (bidir)
│       │
│       └── Core Side Connections (to internal logic)
│           ├── Power distribution outputs
│           ├── Clock output (clock_core)
│           ├── Reset outputs (porb_h, por_l, resetb_core_h)
│           ├── GPIO connections
│           ├── Flash SPI control signals
│           ├── User I/O configuration signals
│           └── Analog I/O access
│
├── INSTANCE 2: caravel_core (instance name: chip_core)
│   │
│   └── Connects:
│       ├── Power pins
│       │   ├── vddio_core, vssio_core
│       │   ├── vccd_core, vssd_core
│       │   ├── vdda1_core, vdda2_core
│       │   ├── vssa1_core, vssa2_core
│       │   ├── vccd1_core, vccd2_core
│       │   └── vssd1_core, vssd2_core
│       │
│       ├── Control Signals
│       │   ├── porb_h (power-on-reset high)
│       │   ├── por_l (power-on-reset low)
│       │   ├── rstb_h (reset high)
│       │   └── clock_core (input clock)
│       │
│       ├── GPIO Control
│       │   ├── gpio_out_core
│       │   ├── gpio_in_core
│       │   ├── gpio_mode0_core
│       │   ├── gpio_mode1_core
│       │   ├── gpio_outenb_core
│       │   └── gpio_inenb_core
│       │
│       ├── Flash SPI (4-wire)
│       │   ├── flash_csb_frame (chip select)
│       │   ├── flash_clk_frame (clock)
│       │   ├── flash_csb_oeb (output enable)
│       │   ├── flash_clk_oeb (output enable)
│       │   ├── flash_io0_oeb (output enable)
│       │   ├── flash_io1_oeb (output enable)
│       │   ├── flash_io0_ieb (input enable)
│       │   ├── flash_io1_ieb (input enable)
│       │   ├── flash_io0_do (data out)
│       │   ├── flash_io1_do (data out)
│       │   ├── flash_io0_di (data in)
│       │   └── flash_io1_di (data in)
│       │
│       ├── User Project I/O Configuration
│       │   ├── mprj_io_in (38 pins input)
│       │   ├── mprj_io_out (38 pins output)
│       │   ├── mprj_io_oeb (38 output enable)
│       │   ├── mprj_io_inp_dis (38 input disable)
│       │   ├── mprj_io_ib_mode_sel (38 input buffer mode)
│       │   ├── mprj_io_vtrip_sel (38 voltage trip select)
│       │   ├── mprj_io_slow_sel (38 slew rate select)
│       │   ├── mprj_io_holdover (38 hold signals)
│       │   ├── mprj_io_analog_en (38 analog enable)
│       │   ├── mprj_io_analog_sel (38 analog select)
│       │   ├── mprj_io_analog_pol (38 analog polarity)
│       │   ├── mprj_io_dm (114 = 38×3 drive mode bits)
│       │   ├── mprj_io_one (38 constant logic-1)
│       │   └── mprj_analog_io (analog access 28 pins)
│
├── INSTANCE 3: copyright_block (instance name: copyright_block)
│   └── Graphic/branding block (no connections)
│
├── INSTANCE 4: caravel_logo (instance name: caravel_logo)
│   └── Graphic/branding block (no connections)
│
├── INSTANCE 5: caravel_motto (instance name: caravel_motto)
│   └── Graphic/branding block (no connections)
│
├── INSTANCE 6: open_source (instance name: open_source)
│   └── Graphic/branding block (no connections)
│
└── INSTANCE 7: user_id_textblock (instance name: user_id_textblock)
    └── Graphic/branding block (no connections)
```

---

## Signal Flow Summary

### Input Signals (from external world):
```
From package pins:
├── vddio, vddio_2       → Power 3.3V
├── vssio, vssio_2       → Ground
├── vccd                 → Power 1.8V
├── vssd                 → Ground
├── vdda, vssa           → Analog power/ground
├── vdda1, vdda1_2       → User area 1 power
├── vdda2                → User area 2 power
├── vssa1, vssa1_2       → User area 1 ground
├── vssa2                → User area 2 ground
├── vccd1, vccd2         → User area 1.8V power
├── vssd1, vssd2         → User area 1 digital ground
├── clock                → Input clock
├── resetb               → Reset input (active low)
├── mprj_io[37:0]        → 38 user I/O pads (bidirectional)
├── flash_io0, flash_io1 → Flash SPI data lines (bidirectional)
├── gpio                 → Dedicated GPIO pad (bidirectional)
└── flash_csb, flash_clk → Flash control pins (output)
```

### Internal Signal Generation (by vsdcaravel):
```
chip_io generates → padframe-side signals:
├── porb_h      (power-on-reset high)
├── por_l       (power-on-reset low)
├── rstb_h      (reset high)
└── clock_core  (buffered clock)

Which are fed to → caravel_core (chip_core)
Which then generates and controls:
├── GPIO signals
├── Flash SPI signals
└── User project I/O configuration
```

---

## Instantiation Details Table

| Instance Name | Module Name | Purpose | Connections |
|---|---|---|---|
| padframe | chip_io | I/O Pad Frame | Package pins ↔ Core signals |
| chip_core | caravel_core | SoC Core Logic | All core functionality |
| copyright_block | copyright_block | Text/Logo | No functional connections |
| caravel_logo | caravel_logo | Text/Logo | No functional connections |
| caravel_motto | caravel_motto | Text/Logo | No functional connections |
| open_source | open_source | Text/Logo | No functional connections |
| user_id_textblock | user_id_textblock | Text/Logo | No functional connections |

---

## Key Observations

### 1. Only 2 Functional Modules Instantiated:
   - **chip_io** (padframe): Converts package pins to internal signals
   - **caravel_core** (chip_core): Contains all SoC logic

### 2. 5 Non-Functional Instances:
   - copyright_block, caravel_logo, caravel_motto, open_source, user_id_textblock
   - These are purely for graphics/text in layout (GDS)
   - No functional connections, no ports

### 3. Power Distribution:
   - **3 power domains**: 3.3V (vddio, vdda), 1.8V (vccd), User areas (vccd1/2)
   - **3 ground domains**: vssio, vssa, vssd, User areas (vssd1/2)

### 4. Clock & Reset:
   - Single clock input → processed by chip_io → distributed by caravel_core
   - Single reset input → processed by chip_io → distributed by caravel_core

### 5. I/O Control:
   - **38 user I/O pads**: Full configuration (drive mode, input buffer select, voltage select, etc.)
   - **GPIO**: One dedicated GPIO pin
   - **Flash SPI**: 4-wire interface (cs, clk, io0, io1)

### 6. Data Paths:
   ```
   Package Pins
       ↓
   chip_io (padframe)
       ↓
   caravel_core (chip_core)
       ↓
   Internal SoC Logic + User Project
   ```

---

## Hierarchy Depth from vsdcaravel.v:

```
vsdcaravel.v (Level 0)
    │
    ├── chip_io (Level 1)
    │   └── Pure RTL pad frame (no sub-modules)
    │
    ├── caravel_core (Level 1) ← [INCLUDES caravel_core.v]
    │   └── Internal structure: [See caravel_core.v analysis]
    │       ├── mgmt_core_wrapper
    │       ├── mgmt_protect
    │       ├── user_project_wrapper
    │       ├── caravel_clocking
    │       └── digital_pll
    │
    └── Graphics (Level 1)
        └── Non-functional text blocks
```

---

## Summary

**vsdcaravel.v instantiates:**
- **1 Pad Frame** (chip_io)
- **1 Core Logic Block** (caravel_core)
- **5 Graphics Blocks** (copyright, logo, motto, open_source, user_id)

**Total Functional Connections:**
- ~60 power/ground pins
- ~40 control signals (clock, reset, gpio)
- ~38 user I/O pins (with configuration)
- 4 flash SPI pins

**Total Non-functional:**
- 5 text/graphics blocks with no connections
