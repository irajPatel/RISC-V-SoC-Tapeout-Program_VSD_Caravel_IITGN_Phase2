# Day4 - Complete File Structure

This document provides a comprehensive list of all files and their locations in the Day4 directory.

---

## Directory Overview

```
Day4/
└── vsdRiscvScl180/
    ├── .gitignore
    ├── dv/
    ├── gls/
    ├── rtl/
    └── synthesis/
```

---

## Detailed File Listing

### Root Level - Day4/vsdRiscvScl180/

| File/Folder | Type | Location | Description |
|---|---|---|---|
| .gitignore | File | Day4/vsdRiscvScl180/ | Git ignore configuration |

---

## 1. DV (Design Verification) Directory

**Location:** `Day4/vsdRiscvScl180/dv/`

### Header Files (.h)

| File | Location | Purpose |
|---|---|---|
| caravel.h | Day4/vsdRiscvScl180/dv/ | Caravel main header file |
| csr-defs.h | Day4/vsdRiscvScl180/dv/ | Control/Status Register definitions |
| csr.h | Day4/vsdRiscvScl180/dv/ | CSR header file |
| defs.h | Day4/vsdRiscvScl180/dv/ | General definitions |
| system.h | Day4/vsdRiscvScl180/dv/ | System header definitions |

### Verilog Files (.v)

| File | Location | Purpose |
|---|---|---|
| spiflash.v | Day4/vsdRiscvScl180/dv/ | SPI Flash interface module |
| tbuart.v | Day4/vsdRiscvScl180/dv/ | UART testbench module |
| wb_rw_test.v | Day4/vsdRiscvScl180/dv/ | Wishbone read/write test |

### Assembly & Source Files

| File | Location | Purpose |
|---|---|---|
| start.s | Day4/vsdRiscvScl180/dv/ | Assembly startup code |
| stub.c | Day4/vsdRiscvScl180/dv/ | C stub file |

### Linker & Configuration Files

| File | Location | Purpose |
|---|---|---|
| sections.lds | Day4/vsdRiscvScl180/dv/ | Linker script |
| things_to_export.txt | Day4/vsdRiscvScl180/dv/ | Export configuration |

---

## 2. HKSPI Subdirectory (Housekeeping SPI)

**Location:** `Day4/vsdRiscvScl180/dv/hkspi/`

### Header Files

| File | Location | Purpose |
|---|---|---|
| caravel.h | Day4/vsdRiscvScl180/dv/hkspi/ | Caravel definitions |
| csr-defs.h | Day4/vsdRiscvScl180/dv/hkspi/ | CSR definitions |
| csr.h | Day4/vsdRiscvScl180/dv/hkspi/ | CSR header |
| defs.h | Day4/vsdRiscvScl180/dv/hkspi/ | Common definitions |
| system.h | Day4/vsdRiscvScl180/dv/hkspi/ | System definitions |
| irq.h | Day4/vsdRiscvScl180/dv/hkspi/ | Interrupt definitions |
| irq_vex.h | Day4/vsdRiscvScl180/dv/hkspi/ | VexRISCV IRQ definitions |
| uart.h | Day4/vsdRiscvScl180/dv/hkspi/ | UART API header |
| simple_system_regs.h | Day4/vsdRiscvScl180/dv/hkspi/ | System register definitions |
| simple_system_common.h | Day4/vsdRiscvScl180/dv/hkspi/ | Common system header |
| cpu_type.mak | Day4/vsdRiscvScl180/dv/hkspi/ | CPU type makefile |

### API Headers (APIs subdirectory)

**Location:** `Day4/vsdRiscvScl180/dv/hkspi/APIs/`

| File | Location | Purpose |
|---|---|---|
| bitbang.h | Day4/vsdRiscvScl180/dv/hkspi/APIs/ | Bit banging implementation |
| firmware_apis.h | Day4/vsdRiscvScl180/dv/hkspi/APIs/ | Firmware API definitions |
| gpios.h | Day4/vsdRiscvScl180/dv/hkspi/APIs/ | GPIO API |
| irq_api.h | Day4/vsdRiscvScl180/dv/hkspi/APIs/ | Interrupt API |
| la.h | Day4/vsdRiscvScl180/dv/hkspi/APIs/ | Logic Analyzer API |
| mgmt_gpio.h | Day4/vsdRiscvScl180/dv/hkspi/APIs/ | Management GPIO API |
| spi_master.h | Day4/vsdRiscvScl180/dv/hkspi/APIs/ | SPI Master API |
| timer0.h | Day4/vsdRiscvScl180/dv/hkspi/APIs/ | Timer 0 API |
| uart_api.h | Day4/vsdRiscvScl180/dv/hkspi/APIs/ | UART API |
| user_space.h | Day4/vsdRiscvScl180/dv/hkspi/APIs/ | User space API |

### Verilog Testbench Files

| File | Location | Purpose |
|---|---|---|
| hkspi_tb.v | Day4/vsdRiscvScl180/dv/hkspi/ | HKSPI testbench |
| hkspi_tb_gl.v | Day4/vsdRiscvScl180/dv/hkspi/ | Gate-level testbench |

### C Source Files

| File | Location | Purpose |
|---|---|---|
| hkspi.c | Day4/vsdRiscvScl180/dv/hkspi/ | Main HKSPI firmware |
| stub.c | Day4/vsdRiscvScl180/dv/hkspi/ | C stub file |
| isr.c | Day4/vsdRiscvScl180/dv/hkspi/ | Interrupt service routines |
| simple_system_common.c | Day4/vsdRiscvScl180/dv/hkspi/ | Common system code |

### Assembly Files

| File | Location | Purpose |
|---|---|---|
| start.S | Day4/vsdRiscvScl180/dv/hkspi/ | Generic startup code |
| crt0_ibex.S | Day4/vsdRiscvScl180/dv/hkspi/ | Ibex startup code |
| crt0_vex.S | Day4/vsdRiscvScl180/dv/hkspi/ | VexRISCV startup code |
| start_caravel_ibex.s | Day4/vsdRiscvScl180/dv/hkspi/ | Caravel Ibex startup |
| start_caravel_vexriscv.s | Day4/vsdRiscvScl180/dv/hkspi/ | Caravel VexRISCV startup |
| start_pico.S | Day4/vsdRiscvScl180/dv/hkspi/ | PicoRISCV startup |
| extraops.S | Day4/vsdRiscvScl180/dv/hkspi/ | Extra operations code |

### Linker Scripts

| File | Location | Purpose |
|---|---|---|
| sections.lds | Day4/vsdRiscvScl180/dv/hkspi/ | Linker script |
| sections_vexriscv.lds | Day4/vsdRiscvScl180/dv/hkspi/ | VexRISCV linker script |
| linker_vex.ld | Day4/vsdRiscvScl180/dv/hkspi/ | VexRISCV linker definition |
| link_ibex.ld | Day4/vsdRiscvScl180/dv/hkspi/ | Ibex linker definition |

### Compiled Files

| File | Location | Purpose |
|---|---|---|
| hkspi.elf | Day4/vsdRiscvScl180/dv/hkspi/ | ELF executable |
| hkspi.bin | Day4/vsdRiscvScl180/dv/hkspi/ | Binary firmware |
| hkspi.hex | Day4/vsdRiscvScl180/dv/hkspi/ | Hex file for flash |
| hkspi.vcd | Day4/vsdRiscvScl180/dv/hkspi/ | Value Change Dump |
| hkspi.vvp | Day4/vsdRiscvScl180/dv/hkspi/ | Verilog simulation output |

### Simulation Files

| File | Location | Purpose |
|---|---|---|
| simv | Day4/vsdRiscvScl180/dv/hkspi/ | VCS simulation executable |
| simv.daidir/ | Day4/vsdRiscvScl180/dv/hkspi/ | Simulation database directory |
| hkspi.simv.daidir/ | Day4/vsdRiscvScl180/dv/hkspi/ | HKSPI simulation database |
| ucli.key | Day4/vsdRiscvScl180/dv/hkspi/ | UCLI key file |
| vcs.mk | Day4/vsdRiscvScl180/dv/hkspi/ | VCS makefile |

### Build & Configuration Files

| File | Location | Purpose |
|---|---|---|
| Makefile | Day4/vsdRiscvScl180/dv/hkspi/ | Build makefile |
| generated/ | Day4/vsdRiscvScl180/dv/hkspi/ | Generated files directory |
| csrc/ | Day4/vsdRiscvScl180/dv/hkspi/ | C source for simulation |
| hw/ | Day4/vsdRiscvScl180/dv/hkspi/ | Hardware directory |
| tmp/ | Day4/vsdRiscvScl180/dv/hkspi/ | Temporary files directory |

### Hardware Subdirectory

**Location:** `Day4/vsdRiscvScl180/dv/hkspi/hw/`

| File | Location | Purpose |
|---|---|---|
| common.h | Day4/vsdRiscvScl180/dv/hkspi/hw/ | Common hardware definitions |

### Log Files

| File | Location | Purpose |
|---|---|---|
| compile.log | Day4/vsdRiscvScl180/dv/hkspi/ | Compilation log |
| simulation.log | Day4/vsdRiscvScl180/dv/hkspi/ | Simulation log |
| flex135.log | Day4/vsdRiscvScl180/dv/hkspi/ | Flex log file |
| flex164.log | Day4/vsdRiscvScl180/dv/hkspi/ | Flex log file |
| flex330.log | Day4/vsdRiscvScl180/dv/hkspi/ | Flex log file |
| flex748.log | Day4/vsdRiscvScl180/dv/hkspi/ | Flex log file |

---

## 3. GLS (Gate-Level Simulation) Directory

**Location:** `Day4/vsdRiscvScl180/gls/`

### Test Files

| File | Location | Purpose |
|---|---|---|
| hkspi_tb.v | Day4/vsdRiscvScl180/gls/ | HKSPI gate-level testbench |
| Makefile | Day4/vsdRiscvScl180/gls/ | Build makefile |
| spiflash.v | Day4/vsdRiscvScl180/gls/ | SPI flash module |
| tbuart.v | Day4/vsdRiscvScl180/gls/ | UART testbench |

### Compiled Files

| File | Location | Purpose |
|---|---|---|
| simv | Day4/vsdRiscvScl180/gls/ | Simulation executable |
| hkspi.vcd | Day4/vsdRiscvScl180/gls/ | Value Change Dump |
| hkspi.hex | Day4/vsdRiscvScl180/gls/ | Firmware hex file |

### Simulation Database

| File | Location | Purpose |
|---|---|---|
| simv.daidir/ | Day4/vsdRiscvScl180/gls/ | Simulation database directory |

**Contents of `simv.daidir/`:**

| File | Location | Purpose |
|---|---|---|
| .daidir_complete | Day4/vsdRiscvScl180/gls/simv.daidir/ | Database completion marker |
| .elabcomCmd | Day4/vsdRiscvScl180/gls/simv.daidir/ | Elaboration command |
| .elabcomLibs | Day4/vsdRiscvScl180/gls/simv.daidir/ | Elaboration libraries |
| .elabcomTopFile | Day4/vsdRiscvScl180/gls/simv.daidir/ | Elaboration top file |
| .normal_done | Day4/vsdRiscvScl180/gls/simv.daidir/ | Normal completion marker |
| .vcs.timestamp | Day4/vsdRiscvScl180/gls/simv.daidir/ | VCS timestamp |
| binmap.sdb | Day4/vsdRiscvScl180/gls/simv.daidir/ | Binary map database |
| build_db | Day4/vsdRiscvScl180/gls/simv.daidir/ | Build database |
| cc/ | Day4/vsdRiscvScl180/gls/simv.daidir/ | C compiler directory |
| cgname.json | Day4/vsdRiscvScl180/gls/simv.daidir/ | Codegen names JSON |
| covg_defs | Day4/vsdRiscvScl180/gls/simv.daidir/ | Coverage definitions |
| debug_dump/ | Day4/vsdRiscvScl180/gls/simv.daidir/ | Debug dump directory |
| eblklvl.db | Day4/vsdRiscvScl180/gls/simv.daidir/ | Elaboration block level |
| elabcomLog/ | Day4/vsdRiscvScl180/gls/simv.daidir/ | Elaboration command log |
| external_functions | Day4/vsdRiscvScl180/gls/simv.daidir/ | External functions file |
| hslevel_callgraph.sdb | Day4/vsdRiscvScl180/gls/simv.daidir/ | Hierarchical SL callgraph |
| hslevel_level.sdb | Day4/vsdRiscvScl180/gls/simv.daidir/ | Hierarchical SL level |
| hslevel_rtime_level.sdb | Day4/vsdRiscvScl180/gls/simv.daidir/ | Runtime level database |
| hsscan_cfg.dat | Day4/vsdRiscvScl180/gls/simv.daidir/ | HS scan configuration |
| kdb.elab++/ | Day4/vsdRiscvScl180/gls/simv.daidir/ | Elaboration database |
| nsparam.dat | Day4/vsdRiscvScl180/gls/simv.daidir/ | Name space parameters |
| pcc.sdb | Day4/vsdRiscvScl180/gls/simv.daidir/ | Packed component cache |
| pcxpxmr.dat | Day4/vsdRiscvScl180/gls/simv.daidir/ | Path cross parameter |
| prof.sdb | Day4/vsdRiscvScl180/gls/simv.daidir/ | Profile database |
| rmapats.dat | Day4/vsdRiscvScl180/gls/simv.daidir/ | RAM patterns data |
| rmapats.so | Day4/vsdRiscvScl180/gls/simv.daidir/ | RAM patterns shared object |
| saifNetInfo.db | Day4/vsdRiscvScl180/gls/simv.daidir/ | SAIF net info database |
| simv.kdb | Day4/vsdRiscvScl180/gls/simv.daidir/ | Simulation KDB |
| stitch_nsparam.dat | Day4/vsdRiscvScl180/gls/simv.daidir/ | Stitch namespace |
| tt.sdb | Day4/vsdRiscvScl180/gls/simv.daidir/ | Timing database |
| vce.sdb | Day4/vsdRiscvScl180/gls/simv.daidir/ | VCE database |
| vcselab_* | Day4/vsdRiscvScl180/gls/simv.daidir/ | VCS elaboration files |
| vcs_rebuild | Day4/vsdRiscvScl180/gls/simv.daidir/ | VCS rebuild flag |
| _31930_archive_1.so | Day4/vsdRiscvScl180/gls/simv.daidir/ | Archive library |

### C Source Directory

**Location:** `Day4/vsdRiscvScl180/gls/csrc/`

| File | Location | Purpose |
|---|---|---|
| .30817.30817.0.compview.txt | Day4/vsdRiscvScl180/gls/csrc/ | Compilation view file |
| archive.0/ | Day4/vsdRiscvScl180/gls/csrc/ | Archive directory |
| cgincr.sdb | Day4/vsdRiscvScl180/gls/csrc/ | Codegen incremental database |
| cginfo.json | Day4/vsdRiscvScl180/gls/csrc/ | Codegen info JSON |
| cgproc.31930.json | Day4/vsdRiscvScl180/gls/csrc/ | Codegen process JSON |
| clean.sh | Day4/vsdRiscvScl180/gls/csrc/ | Cleanup script |
| diag/ | Day4/vsdRiscvScl180/gls/csrc/ | Diagnostics directory |
| filelist | Day4/vsdRiscvScl180/gls/csrc/ | File list |
| filelist.cu | Day4/vsdRiscvScl180/gls/csrc/ | CUDA file list |
| filelist.dpi | Day4/vsdRiscvScl180/gls/csrc/ | DPI file list |
| filelist.hsopt | Day4/vsdRiscvScl180/gls/csrc/ | HSOPT file list |
| filelist.hsopt.llvm2_0.objs | Day4/vsdRiscvScl180/gls/csrc/ | LLVM objects list |
| filelist.hsopt.objs | Day4/vsdRiscvScl180/gls/csrc/ | HSOPT objects list |
| filelist.pli | Day4/vsdRiscvScl180/gls/csrc/ | PLI file list |
| hsim/ | Day4/vsdRiscvScl180/gls/csrc/ | HSIM directory |
| import_dpic.h | Day4/vsdRiscvScl180/gls/csrc/ | DPIC import header |
| Makefile | Day4/vsdRiscvScl180/gls/csrc/ | Makefile |
| Makefile.hsopt | Day4/vsdRiscvScl180/gls/csrc/ | HSOPT makefile |
| objs/ | Day4/vsdRiscvScl180/gls/csrc/ | Object files directory |
| product_timestamp | Day4/vsdRiscvScl180/gls/csrc/ | Product timestamp |
| rmapats.c | Day4/vsdRiscvScl180/gls/csrc/ | RAM patterns C code |
| rmapats.h | Day4/vsdRiscvScl180/gls/csrc/ | RAM patterns header |
| rmapats.m | Day4/vsdRiscvScl180/gls/csrc/ | RAM patterns makefile |
| rmapats.o | Day4/vsdRiscvScl180/gls/csrc/ | RAM patterns object |
| rmapats_mop.o | Day4/vsdRiscvScl180/gls/csrc/ | RAM patterns MOP object |
| rmar.c | Day4/vsdRiscvScl180/gls/csrc/ | Register map C file |
| rmar.h | Day4/vsdRiscvScl180/gls/csrc/ | Register map header |
| rmar.o | Day4/vsdRiscvScl180/gls/csrc/ | Register map object |
| rmar0.h | Day4/vsdRiscvScl180/gls/csrc/ | Register map variant |
| rmar_llvm_0_0.o | Day4/vsdRiscvScl180/gls/csrc/ | LLVM register map object |
| rmar_llvm_0_1.o | Day4/vsdRiscvScl180/gls/csrc/ | LLVM register map object |
| rmar_nd.o | Day4/vsdRiscvScl180/gls/csrc/ | No-debug register map object |
| SIM_l.o | Day4/vsdRiscvScl180/gls/csrc/ | Simulator object |

### Log Files

| File | Location | Purpose |
|---|---|---|
| flex0.log | Day4/vsdRiscvScl180/gls/ | Flex log |
| flex177.log | Day4/vsdRiscvScl180/gls/ | Flex log |
| flex930.log | Day4/vsdRiscvScl180/gls/ | Flex log |
| simulation.log | Day4/vsdRiscvScl180/gls/ | Simulation log |
| vcs_compile.log | Day4/vsdRiscvScl180/gls/ | VCS compilation log |

### Configuration Files

| File | Location | Purpose |
|---|---|---|
| ucli.key | Day4/vsdRiscvScl180/gls/ | UCLI key file |
| verdi_config_file | Day4/vsdRiscvScl180/gls/ | Verdi configuration |

### Temporary Directory

| Directory | Location | Purpose |
|---|---|---|
| tmp/ | Day4/vsdRiscvScl180/gls/ | Temporary files directory |

---

## 4. RTL (Register Transfer Level) Directory

**Location:** `Day4/vsdRiscvScl180/rtl/`

### Caravel Core Files

| File | Location | Purpose |
|---|---|---|
| caravel.v | Day4/vsdRiscvScl180/rtl/ | Main Caravel module |
| caravel_core.v | Day4/vsdRiscvScl180/rtl/ | Caravel core implementation |
| caravel_clocking.v | Day4/vsdRiscvScl180/rtl/ | Clock distribution and management |
| caravel_netlists.v | Day4/vsdRiscvScl180/rtl/ | Caravel netlists |
| caravel_openframe.v | Day4/vsdRiscvScl180/rtl/ | OpenFrame Caravel variant |
| caravel_power_routing.v | Day4/vsdRiscvScl180/rtl/ | Power distribution routing |
| vsdcaravel.v | Day4/vsdRiscvScl180/rtl/ | VSD Caravel implementation |

### GPIO & I/O Files

| File | Location | Purpose |
|---|---|---|
| chip_io.v | Day4/vsdRiscvScl180/rtl/ | Chip I/O pad definitions |
| gpio_control_block.v | Day4/vsdRiscvScl180/rtl/ | GPIO control logic |
| gpio_defaults_block.v | Day4/vsdRiscvScl180/rtl/ | GPIO default configuration |
| gpio_logic_high.v | Day4/vsdRiscvScl180/rtl/ | GPIO logic high cells |
| gpio_signal_buffering.v | Day4/vsdRiscvScl180/rtl/ | GPIO signal buffering |
| gpio_signal_buffering_alt.v | Day4/vsdRiscvScl180/rtl/ | Alternative GPIO buffering |
| mprj_io.v | Day4/vsdRiscvScl180/rtl/ | User project I/O |
| mprj_io_buffer.v | Day4/vsdRiscvScl180/rtl/ | User project I/O buffer |
| mprj_logic_high.v | Day4/vsdRiscvScl180/rtl/ | User project logic high |
| mprj2_logic_high.v | Day4/vsdRiscvScl180/rtl/ | User project logic high variant |
| pads.v | Day4/vsdRiscvScl180/rtl/ | Pad definitions |

### Housekeeping & Management Files

| File | Location | Purpose |
|---|---|---|
| housekeeping.v | Day4/vsdRiscvScl180/rtl/ | Housekeeping module |
| housekeeping_spi.v | Day4/vsdRiscvScl180/rtl/ | Housekeeping SPI interface |
| mgmt_core.v | Day4/vsdRiscvScl180/rtl/ | Management core processor |
| mgmt_core_wrapper.v | Day4/vsdRiscvScl180/rtl/ | Management core wrapper |
| mgmt_protect.v | Day4/vsdRiscvScl180/rtl/ | Management protection logic |
| mgmt_protect_hv.v | Day4/vsdRiscvScl180/rtl/ | High-voltage protection |

### Clock & PLL Files

| File | Location | Purpose |
|---|---|---|
| clock_div.v | Day4/vsdRiscvScl180/rtl/ | Clock divider |
| digital_pll.v | Day4/vsdRiscvScl180/rtl/ | Digital PLL module |
| digital_pll_controller.v | Day4/vsdRiscvScl180/rtl/ | PLL controller logic |
| ring_osc2x13.v | Day4/vsdRiscvScl180/rtl/ | Ring oscillator |

### Power & Reset Files

| File | Location | Purpose |
|---|---|---|
| digital_por.v | Day4/vsdRiscvScl180/rtl/ | Digital power-on-reset |
| dummy_por.v | Day4/vsdRiscvScl180/rtl/ | Dummy POR for testing |
| buff_flash_clkrst.v | Day4/vsdRiscvScl180/rtl/ | Flash clock/reset buffer |
| xres_buf.v | Day4/vsdRiscvScl180/rtl/ | Reset buffer |

### Buffer & Control Files

| File | Location | Purpose |
|---|---|---|
| dummy_schmittbuf.v | Day4/vsdRiscvScl180/rtl/ | Schmitt buffer dummy |
| dummy_scl180_conb_1.v | Day4/vsdRiscvScl180/rtl/ | SCL180 constraint dummy |

### Processor Core Files

| File | Location | Purpose |
|---|---|---|
| ibex_all.v | Day4/vsdRiscvScl180/rtl/ | Ibex processor core |
| picorv32.v | Day4/vsdRiscvScl180/rtl/ | PicoRISCV processor |
| VexRiscv_MinDebugCache.v | Day4/vsdRiscvScl180/rtl/ | VexRISCV with debug/cache |
| mgmt_core.v | Day4/vsdRiscvScl180/rtl/ | Management core (RISC-V) |

### User Project Wrappers

| File | Location | Purpose |
|---|---|---|
| __user_project_wrapper.v | Day4/vsdRiscvScl180/rtl/ | Main user project wrapper |
| __user_project_gpio_example.v | Day4/vsdRiscvScl180/rtl/ | GPIO example wrapper |
| __user_project_la_example.v | Day4/vsdRiscvScl180/rtl/ | Logic analyzer example |
| __user_analog_project_wrapper.v | Day4/vsdRiscvScl180/rtl/ | Analog project wrapper |
| __openframe_project_wrapper.v | Day4/vsdRiscvScl180/rtl/ | OpenFrame project wrapper |
| __uprj_netlists.v | Day4/vsdRiscvScl180/rtl/ | User project netlists |

### Graphics & Branding Files

| File | Location | Purpose |
|---|---|---|
| caravel_logo.v | Day4/vsdRiscvScl180/rtl/ | Caravel logo graphics |
| caravel_motto.v | Day4/vsdRiscvScl180/rtl/ | Caravel motto text |
| copyright_block.v | Day4/vsdRiscvScl180/rtl/ | Copyright block design |
| copyright_block_a.v | Day4/vsdRiscvScl180/rtl/ | Copyright block variant |

### Debug & Register Files

| File | Location | Purpose |
|---|---|---|
| debug_regs.v | Day4/vsdRiscvScl180/rtl/ | Debug register definitions |
| constant_block.v | Day4/vsdRiscvScl180/rtl/ | Constant value block |

### Memory & SPI Files

| File | Location | Purpose |
|---|---|---|
| RAM128.v | Day4/vsdRiscvScl180/rtl/ | 128-bit RAM module |
| RAM256.v | Day4/vsdRiscvScl180/rtl/ | 256-bit RAM module |
| spiflash.v | Day4/vsdRiscvScl180/rtl/ | SPI Flash interface |

### Configuration Files

| File | Location | Purpose |
|---|---|---|
| defines.v | Day4/vsdRiscvScl180/rtl/ | Verilog definitions |
| user_defines.v | Day4/vsdRiscvScl180/rtl/ | User project definitions |
| open_source.v | Day4/vsdRiscvScl180/rtl/ | Open source block definitions |

### ID & Identification Files

| File | Location | Purpose |
|---|---|---|
| user_id_programming.v | Day4/vsdRiscvScl180/rtl/ | User ID programming logic |
| user_id_textblock.v | Day4/vsdRiscvScl180/rtl/ | User ID text display |

### Technology & Primitive Files

| File | Location | Purpose |
|---|---|---|
| primitives.v | Day4/vsdRiscvScl180/rtl/ | Technology primitives |
| scl180_macro_sparecell.v | Day4/vsdRiscvScl180/rtl/ | Spare cell definitions |
| spare_logic_block.v | Day4/vsdRiscvScl180/rtl/ | Spare logic implementation |
| empty_macro.v | Day4/vsdRiscvScl180/rtl/ | Empty macro placeholder |
| manual_power_connections.v | Day4/vsdRiscvScl180/rtl/ | Manual power connections |

### Cell Wrappers

| File | Location | Purpose |
|---|---|---|
| pc3b03ed.v | Day4/vsdRiscvScl180/rtl/ | PC3B03ED cell wrapper |
| pc3d01.v | Day4/vsdRiscvScl180/rtl/ | PC3D01 cell wrapper |
| pc3d21.v | Day4/vsdRiscvScl180/rtl/ | PC3D21 cell wrapper |
| pt3b02_wrapper.v | Day4/vsdRiscvScl180/rtl/ | PT3B02 wrapper |

### Configuration & Reference Files

| File | Location | Purpose |
|---|---|---|
| files_list_with_gate_level.txt | Day4/vsdRiscvScl180/rtl/ | Reference file list |

### SCL180 Wrapper Directory

**Location:** `Day4/vsdRiscvScl180/rtl/scl180_wrapper/`

| File | Location | Purpose |
|---|---|---|
| pc3b03ed_wrapper.v | Day4/vsdRiscvScl180/rtl/scl180_wrapper/ | PC3B03ED cell wrapper |
| pc3d01_wrapper.v | Day4/vsdRiscvScl180/rtl/scl180_wrapper/ | PC3D01 cell wrapper |
| pt3b02.v | Day4/vsdRiscvScl180/rtl/scl180_wrapper/ | PT3B02 cell definition |
| pt3b02_wrapper.v | Day4/vsdRiscvScl180/rtl/scl180_wrapper/ | PT3B02 wrapper |

---

## 5. Synthesis Directory

**Location:** `Day4/vsdRiscvScl180/synthesis/`

### Main Files

| File | Location | Purpose |
|---|---|---|
| synth.tcl | Day4/vsdRiscvScl180/synthesis/ | Synthesis TCL script |
| vsdcaravel.sdc | Day4/vsdRiscvScl180/synthesis/ | Synthesis Design Constraints |
| memory_por_blackbox_stubs.v | Day4/vsdRiscvScl180/synthesis/ | Memory and POR blackbox modules |

### Generated Output Directory

**Location:** `Day4/vsdRiscvScl180/synthesis/output/`

| File | Location | Purpose |
|---|---|---|
| vsdcaravel_synthesis.ddc | Day4/vsdRiscvScl180/synthesis/output/ | Design Compiler format (DDC) |
| vsdcaravel_synthesis.sdc | Day4/vsdRiscvScl180/synthesis/output/ | Generated SDC file |
| vsdcaravel_synthesis.v | Day4/vsdRiscvScl180/synthesis/output/ | Synthesized Verilog netlist |

### Reports Directory

**Location:** `Day4/vsdRiscvScl180/synthesis/report/`

| File | Location | Purpose |
|---|---|---|
| area.rpt | Day4/vsdRiscvScl180/synthesis/report/ | Area report |
| power.rpt | Day4/vsdRiscvScl180/synthesis/report/ | Power analysis report |
| timing.rpt | Day4/vsdRiscvScl180/synthesis/report/ | Timing report |
| qor.rpt | Day4/vsdRiscvScl180/synthesis/report/ | Quality of Results report |
| constraints.rpt | Day4/vsdRiscvScl180/synthesis/report/ | Constraint analysis report |
| blackbox_modules.rpt | Day4/vsdRiscvScl180/synthesis/report/ | Blackbox modules report |

### Working Directories & Logs

| File | Location | Purpose |
|---|---|---|
| work_folder/ | Day4/vsdRiscvScl180/synthesis/ | DC working directory |
| alib-52/ | Day4/vsdRiscvScl180/synthesis/ | Analyzed library cache |
| command.log | Day4/vsdRiscvScl180/synthesis/ | Command history log |
| synthesis_complete.log | Day4/vsdRiscvScl180/synthesis/ | Synthesis completion log |
| synthesis_complete_errors_warnings.md | Day4/vsdRiscvScl180/synthesis/ | Error and warning summary |
| default.svf | Day4/vsdRiscvScl180/synthesis/ | Scripting Version File |
| filenames.log | Day4/vsdRiscvScl180/synthesis/ | Filenames log |

### Flex Logs

| File | Location | Purpose |
|---|---|---|
| flex11.log | Day4/vsdRiscvScl180/synthesis/ | Flex log |
| flex461.log | Day4/vsdRiscvScl180/synthesis/ | Flex log |
| flex468.log | Day4/vsdRiscvScl180/synthesis/ | Flex log |
| flex581.log | Day4/vsdRiscvScl180/synthesis/ | Flex log |
| flex759.log | Day4/vsdRiscvScl180/synthesis/ | Flex log |
| flex812.log | Day4/vsdRiscvScl180/synthesis/ | Flex log |
| flex823.log | Day4/vsdRiscvScl180/synthesis/ | Flex log |
| flex831.log | Day4/vsdRiscvScl180/synthesis/ | Flex log |
| flex886.log | Day4/vsdRiscvScl180/synthesis/ | Flex log |
| flex945.log | Day4/vsdRiscvScl180/synthesis/ | Flex log |

### VI Swap Files

| File | Location | Purpose |
|---|---|---|
| .synth.tcl.swn | Day4/vsdRiscvScl180/synthesis/ | VI editor swap file |
| .synth.tcl.swo | Day4/vsdRiscvScl180/synthesis/ | VI editor swap file |
| .synth.tcl.swp | Day4/vsdRiscvScl180/synthesis/ | VI editor swap file |

---

## Summary Statistics

| Category | Count |
|---|---|
| **Total Directories** | 20+ |
| **Verilog Files (.v)** | 85+ |
| **Header Files (.h)** | 35+ |
| **C Source Files (.c)** | 5+ |
| **Assembly Files (.s/.S)** | 8+ |
| **Makefiles** | 4+ |
| **Report Files (.rpt)** | 6+ |
| **Log Files** | 25+ |
| **Configuration Files (.tcl, .sdc, .lds)** | 10+ |
| **Binary/Output Files (.hex, .bin, .elf)** | 3+ |
| **Database/Cache Directories** | 5+ |

---

## File Organization by Category

### Documentation & Configuration
- Synthesis script, linker scripts, constraints files
- Make files, configuration files

### Design Files (RTL)
- Caravel core and wrapper modules
- GPIO, I/O, and pad definitions
- Processor cores (Ibex, VexRISCV, PicoRISCV)
- Housekeeping and management modules

### Verification Files (DV/GLS)
- Testbenches for simulation
- Firmware code (C and Assembly)
- Test vectors and drivers

### Results & Reports
- Synthesis outputs (netlists, SDC, DDC)
- QoR reports (area, power, timing)
- Simulation logs and waveforms

---

## Key Directory Purposes

| Directory | Purpose |
|---|---|
| `dv/` | Design verification, testbenches, firmware development |
| `dv/hkspi/` | Housekeeping SPI test and firmware |
| `gls/` | Gate-level simulation with synthesized netlists |
| `rtl/` | Register-transfer level design modules |
| `synthesis/` | Design compilation, constraints, reports |

---

**Document Generated:** December 15, 2025  
**Total Files Catalogued:** 200+  
**Workspace:** e:\MATLAB_linux\RISC-V-SoC-Tapeout-Program_VSD_Caravel_IITGN_Phase2\Day4
