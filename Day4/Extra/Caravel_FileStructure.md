# Caravel File Structure and Module Map

This document consolidates the key information from the instantiation tree, core/pad deep-dive, and module-hierarchy notes into a single reference file. It is intended as a developer-facing guide describing the top-level file layout, major modules, instantiations, signal groups, and where to look for implementation and simulation artifacts.

**Overview**
- **Project root:** Day4 (workspace root for these notes)
- **Primary design RTL:** `vsdRiscvScl180/rtl` — contains `vsdcaravel.v`, `caravel_core.v`, `chip_io.v`, core/peripheral RTL.
- **Verification:** `vsdRiscvScl180/dv` — testbenches and simulation helpers (e.g., `hkspi`, `spiflash`, `tbuart`).

**Top-level files of interest**
- **`vsdcaravel.v`**: Top-level SoC wrapper that instantiates `chip_io` (padframe) and `caravel_core` (chip core) and includes a few non-functional text/logo blocks.
- **`caravel_core.v`**: Core integration module — management SoC wrapper, user project wrapper, clocking, PLL, housekeeping, GPIO configuration, POR and support modules.
- **`chip_io.v`**: Padframe — pad wrappers, power pin mapping, user I/O pads (`mprj_io[37:0]`), flash pads, clock/reset pads and constant generators.
- **`mgmt_core_wrapper.v` / `mgmt_core.v`**: Management processor wrapper and core (RISC‑V + peripherals). Could instantiate `ibex_all`, `picorv32` or `VexRiscv_MinDebugCache` depending on configuration.
- **`__user_project_wrapper.v`**: User area wrapper exposing Wishbone and LA interfaces to user logic.
- **Testbench files**: `dv/hkspi/hkspi_tb.v` (top-level testbench), `dv/spiflash.v` (behavioral flash), `dv/tbuart.v` (UART monitor).

**High-level instantiation map**
- vsdcaravel (top)
  - chip_io (padframe)
  - caravel_core (chip_core)
  - several non-functional graphics blocks (copyright, logo, etc.)

- caravel_core
  - mgmt_core_wrapper (soc) — wraps the management RISC‑V and housekeeping
  - mgmt_protect — domain isolation / tri-state buffers
  - user_project_wrapper — Wishbone slave for user project
  - caravel_clocking — clock mux & reset sync
  - digital_pll — PLL / DCO
  - housekeeping (SPI/config controller)
  - gpio defaults and gpio_control_block arrays (38 pads)
  - dummy_por, xres_buf, spare logic, constant generators

- chip_io
  - pad wrapper instances (pc3d01_wrapper, pc3b03ed_wrapper, pt3b02_wrapper, pc3d21, mprj_io[])
  - constant_block (vccd_const_one/zero generators)
  - mprj_io (38 configurable pads)

**Detailed functional summaries**

**vsdcaravel.v (Top-level)**
- Role: Package pin mapping and top-level glue. Instantiates the padframe `chip_io` and the core `caravel_core` and provides global power/analog pin definitions.
- Key ports: package power pins, `clock`, `resetb`, `mprj_io[37:0]`, `flash_*`, `gpio`.
- Non-functional includes: `copyright_block.v`, `caravel_logo.v`, `caravel_motto.v`, `open_source.v`, `user_id_textblock.v` (layout-only text blocks).

**caravel_core.v (Chip core integration)**
- Role: Integrates the management SoC, user project, clocking, PLL and housekeeping. Implements I/O configuration scaffolding used by the padframe.
- Major sub-modules and roles:
  - `mgmt_core_wrapper` (`soc`): Management RISC‑V core and top-level SoC logic; flash controller, UART, Wishbone master.
  - `mgmt_protect` (`mgmt_buffers`): Tri-state buffers and domain isolation between management and user project.
  - `user_project_wrapper` (`mprj`): User project interface with Wishbone slave ports and LA/I/O mappings.
  - `caravel_clocking` (`clock_ctrl`): Clock source selection and synchronized reset generation.
  - `digital_pll` (`pll`): PLL / DCO providing pll_clk and pll_clk90 outputs.
  - `housekeeping`: SPI/config controller — configures PLL, module enables, drives GPIO config loader, and interfaces to flash signals.
- GPIO system: `gpio_defaults_block` (38 instances) and `gpio_control_block` arrays provide per-pad configuration (drive mode, input disable, analog enable, pull, etc.).
- Reset & POR: `dummy_por` generates POR signals; `xres_buf` translates 3.3V reset into 1.8V domain.

**chip_io.v (Padframe & pad wrappers)**
- Role: Physical pad wrappers and ESD/protection logic that map package pins to internal core signals.
- Pad types and examples:
  - `pc3d01_wrapper`: clock input pad (3.3V → 1.8V conversion)
  - `pc3b03ed_wrapper`: bidirectional pad used for GPIO and flash IO
  - `pt3b02_wrapper`: output pad for flash CS/CLK
  - `pc3d21`: reset input pad
  - `mprj_io[]`: 38 configurable user pads with analog access and comprehensive configuration signals
- Constant generators: `constant_block` instances generate vccd_const_one / zero signals used to tie configuration bits.
- Pad-to-core flows: package pins → pad wrappers → internal signals (e.g., `clock_core`, `flash_io*_core`, `mprj_io_in/out`)

**Management core and peripherals (mgmt_core / mgmt_core_wrapper)**
- Primary function: run firmware from SPI flash, control housekeeping registers, expose Wishbone master to user project, provide UART and debug interfaces.
- Likely processor options in this repository: `ibex_all`, `picorv32`, or `VexRiscv_MinDebugCache`.
- Peripherals: SPI flash controller (spimemio), UART, Wishbone arbiter, logic analyzer interfaces, SRAM/ROM (RAM128/RAM256).

**Verification infra**
- `dv/hkspi/hkspi_tb.v`: Top-level testbench for the housekeeping SPI flow. Instantiates `vsdcaravel` as DUT (`uut`) and connects `spiflash` and `tbuart` for simulation.
- `dv/spiflash.v`: Behavioral SPI flash memory used to feed firmware into mgmt_core during simulation.
- `dv/tbuart.v`: UART capture for simulation logging.

**Key signal groups and flow mapping**
- Power domains: `vddio`/`vssio` (3.3V), `vdda`/`vssa` (analog), `vccd`/`vssd` (1.8V), plus user-area `vccd1/vccd2`, `vssd1/vssd2`, `vdda1/vdda2`, `vssa1/vssa2`.
- Clocks & reset:
  - External `clock` package pin → `pc3d01_wrapper` → `clock_core` → `caravel_clocking`/`digital_pll` → `caravel_clk`, `caravel_clk2` outputs.
  - Reset: package `resetb` → `resetb_pad` → `resetb_core_h` → `xres_buf` → internal `rstb_l`/`caravel_rstn`.
- Flash path: package flash pins → flash pad wrappers → `flash_*_core` signals → `housekeeping` and `mgmt_core_wrapper` (spimemio).
- User I/O path: package `mprj_io[]` pins ↔ `mprj_io` pad instances ↔ `caravel_core` GPIO control blocks ↔ `user_project_wrapper` (user logic)

**File map (quick paths)**
- [vsdcaravel.v](vsdcaravel.v) — top-level SoC wrapper
- [caravel_core.v](caravel_core.v) — core integration
- [chip_io.v](chip_io.v) — padframe
- [mgmt_core_wrapper.v](vsdRiscvScl180/rtl/mgmt_core_wrapper.v) — management wrapper (see `vsdRiscvScl180/rtl`)
- [mgmt_core.v](vsdRiscvScl180/rtl/mgmt_core.v) — management SoC (processor + peripherals)
- [__user_project_wrapper.v](__user_project_wrapper.v) — user project wrapper
- [dv/hkspi/hkspi_tb.v](vsdRiscvScl180/dv/hkspi/hkspi_tb.v) — housekeeping SPI testbench
- [dv/spiflash.v](vsdRiscvScl180/dv/spiflash.v) — simulation-only flash model

**Recommended quick lookups**
- Inspect `caravel_core.v` to see wiring of `mgmt_core_wrapper`, `housekeeping`, `user_project_wrapper` and the GPIO configuration chain.
- Inspect `chip_io.v` for pad types and per-pad signal mapping (look for `mprj_pads` instance and pc3*/pt3* wrappers).
- Check `hkspi_tb.v` for stimulus and the typical power/reset sequence used in simulations.

**Common developer tasks & where to start**
- I/O/debug: modify `chip_io.v` pad wrappers or `caravel_core.v` GPIO defaults and re-run gate-level simulation.
- Firmware testing: update `dv/spiflash` contents (`hkspi.hex`) and run `hkspi_tb` to validate housekeeping SPI behavior.
- Add/replace processor core: edit `mgmt_core.v` includes to select `ibex_all`, `picorv32` or `VexRiscv` and ensure memory map matches firmware.

---

**Appendix: Short Hierarchy Snapshot**
```
hkspi_tb (tb)
 └─ vsdcaravel (top)
     ├─ chip_io (padframe)
     │   └─ mprj_io[37:0], flash pads, clock/reset pads
     └─ caravel_core (chip_core)
         ├─ mgmt_core_wrapper (soc) -> mgmt_core
         ├─ mgmt_protect
         ├─ user_project_wrapper (mprj)
         ├─ caravel_clocking
         └─ digital_pll
```

---

If you want, I can:
- Add line references and tiny file links to sections of `caravel_core.v` and `chip_io.v` (e.g., top-level instance line numbers), or
- Run a grep across RTL to generate an automated file-to-symbol index.

File created: [Caravel_FileStructure.md](Caravel_FileStructure.md)
