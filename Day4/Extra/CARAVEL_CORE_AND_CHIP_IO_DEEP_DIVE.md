# Deep Dive Analysis: caravel_core.v and chip_io.v

---

## FILE: caravel_core.v (1444 lines)
**Location:** `Day4/vsdRiscvScl180/rtl/caravel_core.v`

### Module Definition:
```
module caravel_core (
    // Power pins (16 total)
    vddio, vssio,
    vdda, vssa,
    vccd, vssd,
    vdda1, vdda2, vssa1, vssa2,
    vccd1, vccd2, vssd1, vssd2
    
    // Control pins
    porb_h, por_l, rstb_h, clock_core
    
    // GPIO (1 pin with 5 control signals)
    gpio_out_core, gpio_in_core, gpio_mode0_core, gpio_mode1_core
    gpio_outenb_core, gpio_inenb_core
    
    // Flash SPI (12 signals for 4-wire interface)
    flash_csb_frame, flash_clk_frame, flash_csb_oeb, flash_clk_oeb
    flash_io0_oeb, flash_io1_oeb, flash_io0_ieb, flash_io1_ieb
    flash_io0_do, flash_io1_do, flash_io0_di, flash_io1_di
    
    // User I/O (38 pins with 9 configuration signals each = 342 signals)
    mprj_io_in[37:0], mprj_io_out[37:0], mprj_io_oeb[37:0]
    mprj_io_inp_dis[37:0], mprj_io_ib_mode_sel[37:0]
    mprj_io_vtrip_sel[37:0], mprj_io_slow_sel[37:0]
    mprj_io_holdover[37:0], mprj_io_analog_en[37:0]
    mprj_io_analog_sel[37:0], mprj_io_analog_pol[37:0]
    mprj_io_dm[113:0] (38×3 bits)
    mprj_io_one[37:0], mprj_analog_io[27:0]
);
```

---

### SUBMODULES INSTANTIATED IN caravel_core (5 major instances):

```
caravel_core
│
├── INSTANCE 1: mgmt_core_wrapper (instance name: soc) [Line 175-265]
│   │
│   ├── Source: mgmt_core_wrapper.v (RISC-V Management SoC)
│   │
│   └── Connections (70+ ports):
│       ├── Clock/Reset
│       │   ├── core_clk ← caravel_clk
│       │   └── core_rstn ← caravel_rstn
│       │
│       ├── GPIO (1 pin)
│       │   ├── gpio_out_pad ← gpio_out_core
│       │   ├── gpio_in_pad → gpio_in_core
│       │   ├── gpio_mode0_pad ← gpio_mode0_core
│       │   ├── gpio_mode1_pad ← gpio_mode1_core
│       │   ├── gpio_outenb_pad ← gpio_outenb_core
│       │   └── gpio_inenb_pad ← gpio_inenb_core
│       │
│       ├── Flash SPI (12 signals)
│       │   ├── flash_csb ← flash_csb_core
│       │   ├── flash_clk ← flash_clk_core
│       │   ├── flash_io0_oeb ← flash_io0_oeb_core
│       │   ├── flash_io0_di → flash_io0_di_core
│       │   ├── flash_io0_do ← flash_io0_do_core
│       │   ├── flash_io1_oeb ← flash_io1_oeb_core
│       │   ├── flash_io1_di → flash_io1_di_core
│       │   ├── flash_io1_do ← flash_io1_do_core
│       │   ├── flash_io2_oeb ← flash_io2_oeb_core
│       │   ├── flash_io2_di → flash_io2_di_core
│       │   ├── flash_io2_do ← flash_io2_do_core
│       │   ├── flash_io3_oeb ← flash_io3_oeb_core
│       │   ├── flash_io3_di → flash_io3_di_core
│       │   └── flash_io3_do ← flash_io3_do_core
│       │
│       ├── Wishbone Bus (User Project)
│       │   ├── mprj_wb_iena (enable)
│       │   ├── mprj_cyc_o (cycle request)
│       │   ├── mprj_stb_o (strobe)
│       │   ├── mprj_we_o (write enable)
│       │   ├── mprj_sel_o[3:0] (byte select)
│       │   ├── mprj_adr_o[31:0] (address)
│       │   ├── mprj_dat_o[31:0] (data out)
│       │   ├── mprj_ack_i (acknowledge)
│       │   └── mprj_dat_i[31:0] (data in)
│       │
│       ├── Housekeeping Interface (SPI Flash controller)
│       │   ├── hk_stb_o (strobe)
│       │   ├── hk_cyc_o (cycle)
│       │   ├── hk_dat_i[31:0] (data in)
│       │   └── hk_ack_i (acknowledge)
│       │
│       ├── Interrupts (6 total)
│       │   ├── irq[5:0] (6-bit IRQ bus)
│       │   └── user_irq_ena[2:0] (enable)
│       │
│       ├── Module Control Signals
│       │   ├── qspi_enabled
│       │   ├── uart_enabled
│       │   ├── spi_enabled
│       │   └── debug_mode
│       │
│       ├── Module I/O
│       │   ├── ser_tx (UART TX)
│       │   ├── ser_rx (UART RX)
│       │   ├── spi_sdi (SPI Data In)
│       │   ├── spi_csb (SPI Chip Select)
│       │   ├── spi_sck (SPI Clock)
│       │   ├── spi_sdo (SPI Data Out)
│       │   ├── spi_sdoenb (SPI Out Enable)
│       │   ├── debug_in (Debug input)
│       │   ├── debug_out (Debug output)
│       │   ├── debug_oeb (Debug output enable)
│       │   ├── la_input[127:0] (Logic Analyzer input from user)
│       │   ├── la_output[127:0] (Logic Analyzer output to user)
│       │   ├── la_oenb[127:0] (LA output enable)
│       │   └── la_iena[127:0] (LA input enable)
│       │
│       └── Trap Status
│           └── trap (exception trap signal)
│
├── INSTANCE 2: mgmt_protect (instance name: mgmt_buffers) [Line 279-324]
│   │
│   ├── Source: mgmt_protect.v (domain isolation tri-state buffers)
│   │
│   └── Connections (48+ ports):
│       ├── Clock & Reset Tristate Buffers
│       │   ├── caravel_clk ← caravel_clk (from clock_ctrl)
│       │   ├── caravel_clk2 ← caravel_clk2 (from clock_ctrl)
│       │   ├── caravel_rstn ← caravel_rstn (from clock_ctrl)
│       │   ├── user_clock → mprj_clock
│       │   ├── user_clock2 → mprj_clock2
│       │   └── user_reset → mprj_reset
│       │
│       ├── Wishbone Bus Buffers (Management → User)
│       │   ├── mprj_cyc_o_core ← from mgmt_core_wrapper
│       │   ├── mprj_stb_o_core ← from mgmt_core_wrapper
│       │   ├── mprj_we_o_core ← from mgmt_core_wrapper
│       │   ├── mprj_sel_o_core[3:0] ← from mgmt_core_wrapper
│       │   ├── mprj_adr_o_core[31:0] ← from mgmt_core_wrapper
│       │   ├── mprj_dat_o_core[31:0] ← from mgmt_core_wrapper
│       │   ├── mprj_ack_i_core ← to mgmt_core_wrapper
│       │   ├── mprj_dat_i_core[31:0] ← to mgmt_core_wrapper
│       │   ├── mprj_iena_wb (WB enable)
│       │   │
│       │   → Outputs to user:
│       │   ├── mprj_cyc_o_user
│       │   ├── mprj_stb_o_user
│       │   ├── mprj_we_o_user
│       │   ├── mprj_sel_o_user[3:0]
│       │   ├── mprj_adr_o_user[31:0]
│       │   ├── mprj_dat_o_user[31:0]
│       │   ├── mprj_ack_i_user
│       │   └── mprj_dat_i_user[31:0]
│       │
│       ├── Interrupt Buffers
│       │   ├── user_irq_core[2:0] → mprj_irq
│       │   ├── user_irq_ena[2:0]
│       │   └── user_irq[2:0] ← user_irq_core
│       │
│       ├── Logic Analyzer Buffers
│       │   ├── la_data_out_core[127:0] → user
│       │   ├── la_data_out_mprj[127:0] → from user
│       │   ├── la_data_in_core[127:0] → user (output)
│       │   ├── la_data_in_mprj[127:0] (input)
│       │   ├── la_oenb_mprj[127:0] (output enable)
│       │   ├── la_oenb_core[127:0] (output enable)
│       │   └── la_iena_mprj[127:0] (input enable)
│       │
│       └── Power Good Monitoring
│           ├── user1_vcc_powergood ← mprj_vcc_pwrgood
│           ├── user2_vcc_powergood ← mprj2_vcc_pwrgood
│           ├── user1_vdd_powergood ← mprj_vdd_pwrgood
│           └── user2_vdd_powergood ← mprj2_vdd_pwrgood
│
├── INSTANCE 3: user_project_wrapper (instance name: mprj) [Line 330-360]
│   │
│   ├── Source: user_project_wrapper.v (user application module)
│   │
│   └── Connections (12+ ports):
│       ├── Wishbone Bus (Management side)
│       │   ├── wbs_cyc_i ← mprj_cyc_o_user
│       │   ├── wbs_stb_i ← mprj_stb_o_user
│       │   ├── wbs_we_i ← mprj_we_o_user
│       │   ├── wbs_sel_i[3:0] ← mprj_sel_o_user
│       │   ├── wbs_adr_i[31:0] ← mprj_adr_o_user
│       │   ├── wbs_dat_i[31:0] ← mprj_dat_o_user
│       │   ├── wbs_ack_o → mprj_ack_i_user
│       │   └── wbs_dat_o[31:0] → mprj_dat_i_user
│       │
│       ├── GPIO Pads (38 user I/O pins)
│       │   ├── io_in[37:0] ← user_io_in (from GPIO control blocks)
│       │   ├── io_out[37:0] → user_io_out (to GPIO control blocks)
│       │   ├── io_oeb[37:0] → user_io_oeb (output enable)
│       │   └── analog_io[27:0] ← mprj_analog_io
│       │
│       ├── Logic Analyzer
│       │   ├── la_data_in[127:0] ← la_data_in_user
│       │   ├── la_data_out[127:0] → la_data_out_user
│       │   └── la_oenb[127:0] → la_oenb_user
│       │
│       ├── Clock/Reset
│       │   ├── wb_clk_i ← mprj_clock
│       │   ├── wb_rst_i ← mprj_reset
│       │   └── user_clock2 ← mprj_clock2
│       │
│       └── Interrupt
│           └── user_irq[2:0] ← user_irq_core
│
├── INSTANCE 4: caravel_clocking (instance name: clock_ctrl) [Line 867-877]
│   │
│   ├── Source: caravel_clocking.v (clock multiplexing and synchronization)
│   │
│   └── Connections (13 ports):
│       ├── Inputs
│       │   ├── porb ← porb_l (power-on-reset low)
│       │   ├── ext_clk_sel ← ext_clk_sel (from housekeeping)
│       │   ├── ext_clk ← clock_core (external clock)
│       │   ├── pll_clk ← pll_clk (from digital_pll)
│       │   ├── pll_clk90 ← pll_clk90 (from digital_pll, 90° phase)
│       │   ├── resetb ← rstb_l
│       │   ├── sel[2:0] ← spi_pll_sel (from housekeeping)
│       │   ├── sel2[2:0] ← spi_pll90_sel (from housekeeping)
│       │   └── ext_reset ← ext_reset (from housekeeping)
│       │
│       └── Outputs
│           ├── core_clk → caravel_clk (to mgmt_core_wrapper)
│           ├── user_clk → caravel_clk2 (second user clock)
│           └── resetb_sync → caravel_rstn (synchronized reset)
│
└── INSTANCE 5: digital_pll (instance name: pll) [Line 880-890]
    │
    ├── Source: digital_pll.v (PLL/DCO - Digital Controlled Oscillator)
    │
    └── Connections (8 ports):
        ├── Inputs
        │   ├── resetb ← rstb_l
        │   ├── enable ← spi_pll_ena (from housekeeping)
        │   ├── osc ← clock_core (reference clock)
        │   └── div[4:0] ← spi_pll_div (from housekeeping)
        │
        ├── Feedback
        │   ├── dco ← spi_pll_dco_ena (enable)
        │   └── ext_trim[25:0] ← spi_pll_trim (from housekeeping)
        │
        └── Outputs
            └── clockp[1:0] (2 clocks with 90° phase shift)
                ├── pll_clk (0°)
                └── pll_clk90 (90°)
```

---

### GPIO Control Blocks in caravel_core (38 instances):

```
caravel_core → GPIO Configuration System

gpio_defaults_block [37:0] (38 instances)
├── Purpose: Default configuration for each GPIO pad
├── Locations:
│   ├── gpio_defaults_block_0  → GPIO[0] (JTAG)
│   ├── gpio_defaults_block_1  → GPIO[1] (SDO)
│   ├── gpio_defaults_block_2  → GPIO[2] (SDI)
│   ├── gpio_defaults_block_3  → GPIO[3] (CSB) - Pull-up
│   ├── gpio_defaults_block_4  → GPIO[4] (SCK)
│   ├── gpio_defaults_block_5 through 37 → GPIO[5:37]
│   └── Each block has 13-bit GPIO_CONFIG_INIT parameter
└── Connections:
    └── gpio_defaults[493:0] (494 bits total = 38×13 bits)

gpio_control_block [1:0] - Bidirectional GPIO #0-1 (JTAG, SDO)
├── Instance 1: gpio_control_bidir_1[1:0]
├── Connections:
│   ├── Control from management SoC
│   ├── mgmt_gpio_in[1:0], mgmt_gpio_out[1:0], mgmt_gpio_oeb[1:0]
│   ├── Serial data chain for configuration
│   ├── Pad connections: mprj_io[1:0]
│   └── All 13 control signals for GPIO configuration
│
gpio_control_block [5:0] - Section 1a GPIO #2-7
├── Instance 2: gpio_control_in_1a[5:0]
├── Default input behavior
│
gpio_control_block [18:0] - Section 1 GPIO #8-26
├── Instance 3: gpio_control_in_1[18:0]
├── Default input behavior
│
gpio_control_block [2:0] - Bidirectional GPIO #35-37 (Flash IO2/3, SPI SDO)
├── Instance 4: gpio_control_bidir_2[2:0]
├── Management-controlled
│
└── gpio_control_block [34:0] - Section 2 GPIO #8-34
    └── Instance 5: gpio_control_in_2[34:0]
        └── Default input behavior
```

---

### Housekeeping Module in caravel_core:

```
INSTANCE: housekeeping (instance name: housekeeping) [Line 900-980]

Source: housekeeping.v (SPI slave + Configuration controller)

Connections (50+ ports):

├── Wishbone Bus (Master side)
│   ├── wb_clk_i ← caravel_clk
│   ├── wb_rstn_i ← caravel_rstn
│   ├── wb_adr_i[31:0] ← mprj_adr_o_core
│   ├── wb_dat_i[31:0] ← mprj_dat_o_core
│   ├── wb_sel_i[3:0] ← mprj_sel_o_core
│   ├── wb_we_i ← mprj_we_o_core
│   ├── wb_cyc_i ← hk_cyc_o (from mgmt_core)
│   ├── wb_stb_i ← hk_stb_o (from mgmt_core)
│   ├── wb_ack_o → hk_ack_i (to mgmt_core)
│   └── wb_dat_o[31:0] → hk_dat_i (to mgmt_core)
│
├── Power-on-Reset
│   └── porb ← porb_l
│
├── PLL Configuration
│   ├── pll_ena → spi_pll_ena
│   ├── pll_dco_ena → spi_pll_dco_ena
│   ├── pll_div[4:0] → spi_pll_div
│   ├── pll_sel[2:0] → spi_pll_sel
│   ├── pll90_sel[2:0] → spi_pll90_sel
│   ├── pll_trim[25:0] → spi_pll_trim
│   └── pll_bypass → ext_clk_sel
│
├── Module Enable Flags
│   ├── qspi_enabled → to mgmt_core_wrapper
│   ├── uart_enabled → to mgmt_core_wrapper
│   ├── spi_enabled → to mgmt_core_wrapper
│   └── debug_mode → to mgmt_core_wrapper
│
├── UART Interface
│   ├── ser_tx → to GPIO pad mprj_io[6]
│   ├── ser_rx ← from GPIO pad mprj_io[5]
│
├── SPI Master (Management side)
│   ├── spi_sdi ← from GPIO pad mprj_io[2]
│   ├── spi_csb ← from GPIO pad mprj_io[3]
│   ├── spi_sck ← from GPIO pad mprj_io[4]
│   ├── spi_sdo → to GPIO pad mprj_io[1]
│   ├── spi_sdoenb → output enable
│
├── Debug Interface
│   ├── debug_in ← from GPIO pad mprj_io[0]
│   ├── debug_out → to GPIO pad mprj_io[0]
│   ├── debug_oeb → output enable
│
├── GPIO Serial Configuration Loader
│   ├── serial_clock → mprj_io_loader_clock
│   ├── serial_load → mprj_io_loader_strobe
│   ├── serial_resetn → mprj_io_loader_resetn
│   ├── serial_data_1 → mprj_io_loader_data_1 (user area 1)
│   ├── serial_data_2 → mprj_io_loader_data_2 (user area 2)
│
├── GPIO Pad Configuration
│   ├── mgmt_gpio_in[37:0] ← mgmt_io_in_hk
│   ├── mgmt_gpio_out[37:0] → mgmt_io_out_hk
│   ├── mgmt_gpio_oeb[37:0] → mgmt_io_oeb_hk
│
├── Flash SPI (connects to chip_io via padframe)
│   ├── spimemio_flash_csb ← flash_csb_core
│   ├── spimemio_flash_clk ← flash_clk_core
│   ├── spimemio_flash_io0_oeb ← flash_io0_oeb_core
│   ├── spimemio_flash_io1_oeb ← flash_io1_oeb_core
│   ├── spimemio_flash_io2_oeb ← flash_io2_oeb_core
│   ├── spimemio_flash_io3_oeb ← flash_io3_oeb_core
│   ├── spimemio_flash_io0_do ← flash_io0_do_core
│   ├── spimemio_flash_io1_do ← flash_io1_do_core
│   ├── spimemio_flash_io2_do ← flash_io2_do_core
│   ├── spimemio_flash_io3_do ← flash_io3_do_core
│   ├── spimemio_flash_io0_di → flash_io0_di_core
│   ├── spimemio_flash_io1_di → flash_io1_di_core
│   ├── spimemio_flash_io2_di → flash_io2_di_core
│   ├── spimemio_flash_io3_di → flash_io3_di_core
│   │
│   → Pad side connections to padframe:
│   ├── pad_flash_csb → flash_csb_frame
│   ├── pad_flash_csb_oeb → flash_csb_oeb
│   ├── pad_flash_clk → flash_clk_frame
│   ├── pad_flash_clk_oeb → flash_clk_oeb
│   ├── pad_flash_io0_oeb → flash_io0_oeb
│   ├── pad_flash_io1_oeb → flash_io1_oeb
│   ├── pad_flash_io0_ieb → flash_io0_ieb
│   ├── pad_flash_io1_ieb → flash_io1_ieb
│   ├── pad_flash_io0_do → flash_io0_do
│   ├── pad_flash_io1_do → flash_io1_do
│   ├── pad_flash_io0_di ← flash_io0_di
│   ├── pad_flash_io1_di ← flash_io1_di
│
├── SRAM Read-Only Interface (optional)
│   ├── sram_ro_clk ← hkspi_sram_clk
│   ├── sram_ro_csb ← hkspi_sram_csb
│   ├── sram_ro_addr[7:0] ← hkspi_sram_addr
│   ├── sram_ro_data[31:0] → hkspi_sram_data
│
├── Power Monitoring
│   ├── usr1_vcc_powergood ← mprj_vcc_pwrgood
│   ├── usr2_vcc_powergood ← mprj2_vcc_pwrgood
│   ├── usr1_vdd_powergood ← mprj_vdd_pwrgood
│   ├── usr2_vdd_powergood ← mprj2_vdd_pwrgood
│
├── Status & Control
│   ├── irq[5:0] → to mgmt_core_wrapper
│   ├── reset → ext_reset (output)
│   ├── mask_rev_in[31:0] ← from user_id_programming
│   └── trap ← trap (from mgmt_core_wrapper)
```

---

### Power-on-Reset and Other Support Modules in caravel_core:

```
INSTANCE: dummy_por (instance name: por) [Line 1259-1266]

Purpose: Generate power-on-reset signals

Connections:
├── Inputs (power supplies in different domains)
│   ├── vdd3v3 ← vddio
│   ├── vdd1v8 ← vccd
│   ├── vss3v3 ← vssio
│   └── vss1v8 ← vssd
│
└── Outputs
    ├── porb_h → porb_h (active low reset, high domain)
    ├── porb_l → porb_l (active low reset, low domain)
    └── por_l → por_l

---

INSTANCE: xres_buf (instance name: rstb_level) [Line 1268-1275]

Purpose: Convert XRES (3.3V) reset input to 1.8V domain

Connections:
├── Inputs
│   ├── A ← rstb_h (3.3V input)
│   ├── VPWR ← vddio (3.3V supply)
│   ├── VGND ← vssio (3.3V ground)
│
├── Internal supplies
│   ├── LVPWR ← vccd (1.8V supply)
│   ├── LVGND ← vssd (1.8V ground)
│
└── Output
    └── X → rstb_l (1.8V output)

---

INSTANCE: spare_logic_block [3:0] [Line 1277-1292]

Purpose: Spare logic for metal mask fixes (not used in normal operation)

Total: 4 instances

Connections: All tied to "no-connect" nets (not functional)

---

Non-functional Blocks:
├── empty_macro [1:0] (2 instances)
└── manual_power_connections (1 instance)
    └── These are layout-only blocks with no functional connections.
```

---

---

## FILE: chip_io.v (1220 lines)
**Location:** `Day4/vsdRiscvScl180/rtl/chip_io.v`

### Module Definition:
```
module chip_io (
    // Package Pin Side (18 power/ground pins)
    vddio_pad, vddio_pad2,
    vssio_pad, vssio_pad2,
    vccd_pad, vssd_pad,
    vdda_pad, vssa_pad,
    vdda1_pad, vdda1_pad2,
    vdda2_pad,
    vssa1_pad, vssa1_pad2,
    vssa2_pad,
    vccd1_pad, vccd2_pad,
    vssd1_pad, vssd2_pad,
    
    // Core Side (18 power/ground signals)
    vddio, vssio, vccd, vssd,
    vdda, vssa, vdda1, vdda2, vssa1, vssa2,
    vccd1, vccd2, vssd1, vssd2,
    
    // Management GPIO
    gpio, clock, resetb,
    
    // Flash Control
    flash_csb, flash_clk,
    flash_io0, flash_io1,
    
    // Internal Control
    porb_h, por, resetb_core_h, clock_core,
    gpio_out_core, gpio_in_core,
    gpio_mode0_core, gpio_mode1_core,
    gpio_outenb_core, gpio_inenb_core,
    
    // Flash Core Control
    flash_csb_core, flash_clk_core,
    flash_csb_oeb_core, flash_clk_oeb_core,
    flash_io0_oeb_core, flash_io1_oeb_core,
    flash_io0_ieb_core, flash_io1_ieb_core,
    flash_io0_do_core, flash_io1_do_core,
    flash_io0_di_core, flash_io1_di_core,
    
    // User Project IOs (38 pads)
    mprj_io[37:0],
    mprj_io_out[37:0], mprj_io_oeb[37:0],
    mprj_io_inp_dis[37:0], mprj_io_ib_mode_sel[37:0],
    mprj_io_vtrip_sel[37:0], mprj_io_slow_sel[37:0],
    mprj_io_holdover[37:0], mprj_io_analog_en[37:0],
    mprj_io_analog_sel[37:0], mprj_io_analog_pol[37:0],
    mprj_io_dm[113:0],
    mprj_io_in[37:0],
    mprj_io_one[37:0],
    mprj_analog_io[27:0]
);
```

---

### SUBMODULES INSTANTIATED IN chip_io:

```
chip_io (PAD FRAME INSTANTIATIONS)
│
├── CONSTANT_VALUE BLOCKS (7 instances) [Lines ~1040-1050]
│   │
│   └── INSTANCE: constant_block [6:0]
│       ├── Purpose: Generate constant logic 1 and logic 0 values
│       │           in the 1.8V domain (vccd/vssd)
│       ├── Instances: 7 blocks numbered [6:0]
│       │
│       └── Connections (3 ports each):
│           ├── vccd ← internal 1.8V supply
│           ├── vssd ← internal ground
│           ├── one[6:0] → vccd_const_one (constant 1 values)
│           └── zero[6:0] → vssd_const_zero (constant 0 values)
│
│       Usage:
│       - vccd_const_one[0] → clock_pad
│       - vccd_const_one[1] → gpio_pad
│       - vccd_const_one[2] → flash_io0_pad
│       - vccd_const_one[3] → flash_io1_pad
│       - vccd_const_one[4] → flash_csb_pad
│       - vccd_const_one[5] → flash_clk_pad
│       - vccd_const_one[6] → resetb_pad
│
├── CLOCK INPUT PAD [Line ~1055]
│   │
│   └── INSTANCE: pc3d01_wrapper (instance name: clock_pad)
│       ├── Purpose: Input pad for system clock
│       │
│       └── Connections:
│           ├── .PAD ← clock (external package pin)
│           └── .IN → clock_core (internal clock signal)
│
├── GPIO PAD [Line ~1065]
│   │
│   └── INSTANCE: pc3b03ed_wrapper (instance name: gpio_pad)
│       ├── Purpose: Bidirectional GPIO pad (open-drain capability)
│       │
│       └── Connections:
│           ├── .PAD ↔ gpio (external package pin)
│           ├── .IN ← gpio_out_core (output driver)
│           ├── .OUT → gpio_in_core (input receiver)
│           ├── .INPUT_DIS ← gpio_inenb_core
│           ├── .OUT_EN_N ← gpio_outenb_core
│           └── .dm[2:0] ← dm_all (drive mode: gpio_mode1_core, gpio_mode1_core, gpio_mode0_core)
│
├── FLASH IO0 PAD [Line ~1070]
│   │
│   └── INSTANCE: pc3b03ed_wrapper (instance name: flash_io0_pad)
│       ├── Purpose: Bidirectional SPI data line 0 for Flash
│       │
│       └── Connections:
│           ├── .PAD ↔ flash_io0 (external package pin)
│           ├── .IN ← flash_io0_do_core (output driver)
│           ├── .OUT → flash_io0_di_core (input receiver)
│           ├── .INPUT_DIS ← flash_io0_ieb_core (input disable)
│           ├── .OUT_EN_N ← flash_io0_oeb_core (output enable inverted)
│           └── .dm[2:0] ← flash_io0_mode (flash_io0_ieb_core, flash_io0_ieb_core, flash_io0_oeb_core)
│
├── FLASH IO1 PAD [Line ~1075]
│   │
│   └── INSTANCE: pc3b03ed_wrapper (instance name: flash_io1_pad)
│       ├── Purpose: Bidirectional SPI data line 1 for Flash
│       │
│       └── Connections:
│           ├── .PAD ↔ flash_io1 (external package pin)
│           ├── .IN ← flash_io1_do_core (output driver)
│           ├── .OUT → flash_io1_di_core (input receiver)
│           ├── .INPUT_DIS ← flash_io1_ieb_core (input disable)
│           ├── .OUT_EN_N ← flash_io1_oeb_core (output enable inverted)
│           └── .dm[2:0] ← flash_io1_mode
│
├── FLASH CHIP SELECT PAD [Line ~1080]
│   │
│   └── INSTANCE: pt3b02_wrapper (instance name: flash_csb_pad)
│       ├── Purpose: Output pad for SPI Flash chip select
│       │
│       └── Connections:
│           ├── .PAD → flash_csb (external package pin)
│           ├── .IN ← flash_csb_core (output driver from core)
│           └── .OE_N ← flash_csb_oeb_core (output enable inverted)
│
├── FLASH CLOCK PAD [Line ~1082]
│   │
│   └── INSTANCE: pt3b02_wrapper (instance name: flash_clk_pad)
│       ├── Purpose: Output pad for SPI Flash clock
│       │
│       └── Connections:
│           ├── .PAD → flash_clk (external package pin)
│           ├── .IN ← flash_clk_core (output driver from core)
│           └── .OE_N ← flash_clk_oeb_core (output enable inverted)
│
├── RESET PAD [Line ~1105]
│   │
│   └── INSTANCE: pc3d21 (instance name: resetb_pad)
│       ├── Purpose: Input pad for system reset (3.3V domain)
│       │
│       └── Connections:
│           ├── .PAD ← resetb (external package pin)
│           └── .CIN → resetb_core_h (converted to 1.8V domain by xres_buf in caravel_core)
│
└── USER PROJECT I/O PAD ARRAY [Line ~1180]
    │
    └── INSTANCE: mprj_io (instance name: mprj_pads)
        ├── Purpose: 38 user I/O pads with comprehensive configuration
        │
        └── Connections (32 ports):
            ├── Power
            │   ├── .vddio ← vddio
            │   ├── .vssio ← vssio
            │   ├── .vccd ← vccd
            │   ├── .vssd ← vssd
            │   ├── .vdda1 ← vdda1
            │   ├── .vdda2 ← vdda2
            │   ├── .vssa1 ← vssa1
            │   ├── .vssa2 ← vssa2
            │   ├── .vddio_q ← vddio_q (supply-derived signal)
            │   ├── .vssio_q ← vssio_q (ground-derived signal)
            │   ├── .analog_a ← analog_a
            │   └── .analog_b ← analog_b
            │
            ├── Control Signals
            │   ├── .porb_h ← porb_h (power-on-reset from caravel_core)
            │   ├── .enh[37:0] ← mprj_io_enh (enable: all driven by porb_h)
            │   └── .vccd_conb[37:0] ← mprj_io_one (constant 1 from caravel_core)
            │
            ├── Pad Connections
            │   └── .io[37:0] ↔ mprj_io (external package pins, 38 pads)
            │
            ├── I/O Control
            │   ├── .io_out[37:0] ← mprj_io_out (output data from core)
            │   ├── .oeb[37:0] ← mprj_io_oeb (output enable bar)
            │   └── .io_in[37:0] → mprj_io_in (input data to core)
            │
            ├── Pad Configuration (input buffer)
            │   ├── .inp_dis[37:0] ← mprj_io_inp_dis (disable input buffer)
            │   ├── .ib_mode_sel[37:0] ← mprj_io_ib_mode_sel (input buffer mode)
            │   └── .vtrip_sel[37:0] ← mprj_io_vtrip_sel (voltage trip select)
            │
            ├── Pad Configuration (slew/hold)
            │   ├── .slow_sel[37:0] ← mprj_io_slow_sel (slew rate select)
            │   └── .holdover[37:0] ← mprj_io_holdover (hold mode)
            │
            ├── Pad Configuration (analog)
            │   ├── .analog_en[37:0] ← mprj_io_analog_en (analog enable)
            │   ├── .analog_sel[37:0] ← mprj_io_analog_sel (analog select)
            │   └── .analog_pol[37:0] ← mprj_io_analog_pol (analog polarity)
            │
            ├── Pad Configuration (drive mode)
            │   └── .dm[113:0] ← mprj_io_dm (3 bits per pad = 38×3 bits)
            │
            └── Analog Access
                └── .analog_io[27:0] ↔ mprj_analog_io (direct pad access for analog)
```

---

## Pad Wrapper Types Used in chip_io:

### 1. pc3d01_wrapper
- **Type**: Input pad (clock)
- **Instances**: 1 (clock_pad)
- **Function**: Converts 3.3V input to 1.8V internal signal

### 2. pc3b03ed_wrapper
- **Type**: Bidirectional pad with configurable drive mode
- **Instances**: 3 (flash_io0_pad, flash_io1_pad, gpio_pad)
- **Function**: Bidirectional I/O with input buffer disable, output enable

### 3. pt3b02_wrapper
- **Type**: Output-only pad with output enable control
- **Instances**: 2 (flash_csb_pad, flash_clk_pad)
- **Function**: Output buffer for clock/chip select control

### 4. pc3d21
- **Type**: Input pad for reset signal
- **Instances**: 1 (resetb_pad)
- **Function**: Converts 3.3V reset input

### 5. mprj_io
- **Type**: User I/O pad array with full configuration
- **Instances**: 1 (mprj_pads) containing 38 individual pads
- **Function**: Configurable GPIO pads with analog access

---

## Signal Routing in chip_io:

```
EXTERNAL PACKAGE PINS
    ↓
CHIP_IO PAD WRAPPER INSTANCES
    ↓
INTERNAL CORE SIGNALS

Examples:

1. Clock Path:
   package_pin(clock)
   ↓
   pc3d01_wrapper(clock_pad)
   ↓
   clock_core (to caravel_core)

2. GPIO Path:
   package_pin(gpio) ↔ pc3b03ed_wrapper(gpio_pad) ↔ 
   {gpio_in_core, gpio_out_core} (to caravel_core)

3. User I/O Path:
   package_pins(mprj_io[37:0])
   ↔ mprj_io (instance mprj_pads)
   ↔ {mprj_io_in, mprj_io_out, mprj_io_oeb, config signals}
   (to caravel_core GPIO control blocks)

4. Flash SPI Path:
   package_pins(flash_csb, flash_clk, flash_io0, flash_io1)
   ↔ {flash_csb_pad, flash_clk_pad, flash_io0_pad, flash_io1_pad}
   ↔ {flash_*_core signals}
   (to housekeeping module in caravel_core)
```

---

## Complete Summary: chip_io.v Instantiations

**chip_io.v contains:**
- 7 constant_block instances (constant 1 and 0 generation)
- 1 clock_pad (pc3d01_wrapper) - Clock input
- 1 gpio_pad (pc3b03ed_wrapper) - GPIO bidirectional
- 2 flash_io pads (pc3b03ed_wrapper) - Flash SPI data
- 2 flash_control pads (pt3b02_wrapper) - Flash SPI control
- 1 resetb_pad (pc3d21) - Reset input
- 1 mprj_pads (mprj_io instance) - 38-pad user I/O array

**Total direct instances in chip_io: 15 major pad instances**

---

## Complete Summary: caravel_core.v Instantiations

**caravel_core.v contains:**
- 1 mgmt_core_wrapper (soc) - RISC-V SoC
- 1 mgmt_protect (mgmt_buffers) - Domain crossing buffers
- 1 user_project_wrapper (mprj) - User project module
- 1 caravel_clocking (clock_ctrl) - Clock control
- 1 digital_pll (pll) - PLL/DCO
- 38 gpio_defaults_block instances - GPIO default config
- 4 gpio_control_block arrays - GPIO pad control logic
- 1 housekeeping instance - SPI slave + config controller
- 1 mprj_io_buffer (gpio_buf) - GPIO buffer
- 1 user_id_programming (user_id_value) - User ID storage
- 1 dummy_por (por) - Power-on-reset
- 1 xres_buf (rstb_level) - Reset level converter
- 4 spare_logic_block instances - Spare gates
- 2 empty_macro instances - Layout blocks
- 1 manual_power_connections - Power routing

**Total major instances in caravel_core: 60+ instances**

---

## Data Flow Summary:

```
VSDCARAVEL (Level 0)
    │
    ├─→ chip_io (PADFRAME)
    │       │
    │       ├─ External pins ↔ pad wrappers
    │       │
    │       └─ Internal signals:
    │           ├─ clock_core
    │           ├─ porb_h, por_l, resetb_core_h
    │           └─ gpio, mprj_io, flash signals
    │
    └─→ caravel_core (CHIP CORE)
            │
            ├─ mgmt_core_wrapper (RISC-V)
            │   ├─ Flash SPI controller
            │   ├─ Wishbone bus master
            │   └─ Interrupt controller
            │
            ├─ caravel_clocking
            │   ├─ digital_pll
            │   └─ Clock selection logic
            │
            ├─ housekeeping
            │   ├─ SPI slave (external interface)
            │   ├─ Configuration registers
            │   └─ PLL controls
            │
            ├─ mgmt_protect
            │   └─ Domain crossing (1.8V ↔ 3.3V)
            │
            ├─ user_project_wrapper
            │   ├─ Wishbone slave
            │   ├─ User GPIO I/O
            │   └─ Logic Analyzer
            │
            ├─ GPIO Control Blocks (38)
            │   └─ Configure each I/O pad
            │
            └─ Support Modules
                ├─ Power-on-reset
                ├─ Reset level converter
                ├─ Constant generators
                └─ Spare logic
```
