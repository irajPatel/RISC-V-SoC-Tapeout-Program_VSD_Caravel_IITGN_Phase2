# 🏗️   RISC-V SoC Tapeout Journey - Phase 2

<div align="center">

[![RISC-V](https://img.shields.io/badge/RISC--V-SoC%20Implementation-2E86AB?style=for-the-badge&logo=riscv&logoColor=white)](https://riscv.org/)
[![Caravel](https://img.shields.io/badge/Caravel-SoC%20Design-FF6B35?style=for-the-badge)](https://caravel-harness.readthedocs.io/)
[![SCL180](https://img.shields.io/badge/SCL180-PDK-28A745?style=for-the-badge)]()
[![Phase](https://img.shields.io/badge/Phase-2-9B59B6?style=for-the-badge)]()

*Building Silicon Dreams *

</div>

## 📖 Project Overview

This comprehensive repository documents my journey through the advanced phase of the **RISC-V SoC Tapeout Program**, focusing on the **Caravel SoC implementation** using professional-grade design tools and methodologies. 

### 🔧 Technology Stack
- **🏗️ SoC Platform**: Caravel Harness with VexRiscV processor
- **⚡ Process Technology**: SCL180nm PDK (Semiconductor Laboratory)
- **🛠️ Synthesis Tools**: Yosys, Synopsys Design Compiler
- **📊 Simulation**: Icarus Verilog, ModelSim
- **🎨 Verification**: RTL vs Gate-Level Simulation (GLS)

![image](Images/main.jpg)

### 🌟 Key Objectives
- **Deep dive** into Caravel SoC architecture and design flow
- **Master** RTL synthesis and gate-level simulation techniques
- **Validate** design integrity through comprehensive verification
- **Document** complete tapeout-ready design methodology

---

## 📚 Learning Journey Documentation

> *"From conceptual understanding to silicon-ready implementation"*

This repository chronicles my progression through advanced SoC design concepts, with detailed task documentation and implementation insights for each milestone achieved.

---

## 📅 Day 1 — HKSPI Interface Understanding, RTL Simulation & GLS Validation

<div align="center">

</div>

| Task                                                               | Description                                                                                        | Status |
| ------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------- | ------ |
| [**Task&nbsp;1**](Day1/TASK_HKSPI_COMPLETE.md) | 📚 **HKSPI Architecture Understanding** - Analyzed Caravel's housekeeping SPI interface, register mapping, and management core communication protocols | ✅ Done |
| [**Task&nbsp;2**](Day1/SKY130_RTL_SIMULATION_SOLUTION.txt) | ⚡ **RTL Simulation Execution** - Compiled and executed HKSPI testbench using Icarus Verilog, verified "Test HK SPI (RTL) Passed" message | ✅ Done |
| [**Task&nbsp;3**](Day1/SKY130_WRAPPER_IMPLEMENTATION.txt) | 🔍 **GLS Matching & Validation** - Synthesized Caravel with Yosys, ran gate-level simulation, achieved 100% RTL vs GLS behavioral matching | ✅ Done |

### 🌟 Key Learnings from Day 1

* **HKSPI interface mastery**: Analyzed Caravel's housekeeping SPI architecture, register mapping, and management core communication protocols.
* **RTL simulation expertise**: Successfully compiled and verified HKSPI testbench using Icarus Verilog with "Test HK SPI (RTL) Passed" confirmation.
* **GLS verification excellence**: Achieved 100% RTL vs GLS behavioral matching using Yosys synthesis and Sky130 timing models.
* **Caravel integration ready**: Established complete verification methodology for tape-out readiness assessment.


---

## 📅 Day 2 — RISC-V SoC Functional & GLS Replication (SCL180)

<div align="center">

</div>

| Task                                                               | Description                                                                                        | Status |
| ------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------- | ------ |
| [**Task&nbsp;1**](Day2/readme.md#task-1-functional-rtl-simulation-completed) | ⚡ **Functional RTL Simulation** - Configured and executed complete HKSPI testbench simulation using SCL180 PDK, verified SoC functionality with clean waveforms | ✅ Done |
| [**Task&nbsp;2**](Day2/readme.md#task-2-synthesis-flow-completed) | 🔧 **Synthesis Flow with DC Shell** - Mastered Synopsys Design Compiler usage, configured SCL180 libraries, achieved zero timing violations with comprehensive reports | ✅ Done |
| [**Task&nbsp;3**](Day2/readme.md#task-3-gate-level-simulation-gls-completed) | 🎯 **Gate-Level Simulation** - Successfully executed GLS with modified netlist, validated RTL-to-gate behavioral equivalence, confirmed timing correlation | ✅ Done |

### 🌟 Key Learnings from Day 2

* **SCL180 PDK mastery**: Successfully configured and utilized SCL180 process design kit with Synopsys Design Compiler for professional synthesis flow.
* **DC Shell expertise**: Gained hands-on experience with industry-standard synthesis tool, understanding library setup, constraints, and optimization techniques.
* **Complete verification flow**: Established end-to-end verification methodology from RTL simulation through synthesis to gate-level validation.
* **Professional documentation**: Created comprehensive technical documentation with synthesis reports, power analysis, and timing validation.

---

## 📅 Day 3 — Synopsys VCS + DC_TOPO Flow with SCL180 (Industry-Grade RTL & Synthesis)

<div align="center">

</div>

| Task                                                               | Description                                                                                        | Status |
| ------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------- | ------ |
| [**Task&nbsp;1**](Day3/Readme.md#task-1-functional-simulation-with-synopsys-vcs) | 🚀 **RTL Simulation with Synopsys VCS** - Migrated from Iverilog to industry-standard VCS, compiled RTL with proper VCS flags, generated VPD waveforms for functional verification | ✅ Done |
| [**Task&nbsp;2**](Day3/Readme.md#️-task-2-synthesis-with-synopsys-dc_topo) | ⚙️ **Synthesis with DC_TOPO** - Implemented DC_TOPO (topology-based synthesis) for SCL180, generated gate-level netlist with optimization; compared DC_SHELL vs DC_TOPO methodologies | ✅ Done |
| [**Task&nbsp;3**](Day3/Readme.md#-task-3-gate-level-simulation-gls-with-synopsys-vcs) | 🔍 **Gate-Level Simulation with VCS** - Executed GLS using Day2 synthesized netlist (DC_TOPO requires LEF files with physical awareness), verified RTL-GLS correlation using vpd2vcd conversion for GTKWave analysis | ✅ Done |

### 🌟 Key Learnings from Day 3

* **VCS Migration**: Replaced Iverilog with Synopsys VCS for 2-3× faster compilation with native executable output and proper VCS flags (`-full64 -sverilog -debug_access+all`).

* **DC_SHELL vs DC_TOPO**: DC_SHELL performs library-based RTL-to-gate synthesis (Day2 approach). DC_TOPO requires LEF files for physical-aware synthesis; without them, Day2's DC_SHELL netlist was used for GLS verification instead.

* **Waveform Conversion**: Transitioned VPD (binary) to VCD (text) using `vpd2vcd hkspi_gls.vpd hkspi.vcd` for GTKWave analysis (DVE unavailable in lab).

* **Complete Tool Migration**: Eliminated all open-source tools, established industry-standard Synopsys flow with comprehensive synthesis reports (area, power, timing).

* **Perfect RTL-GLS Correlation**: Verified functional equivalence with zero X-propagation on critical signals using integrated standard cell models and proper timing simulation.

---

## 📅 Day 4 — POR Removal & External Reset Implementation (Advanced RTL Modification)

<div align="center">

</div>

| Task                                                               | Description                                                                                        | Status |
| ------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------- | ------ |
| [**Task&nbsp;1**](DUMMY_POR_SIGNAL_TRACE_FROM_TESTBENCH.md) | 📚 **POR Usage Analysis** - Comprehensive study and documentation of dummy_por usage across vsdcaravel.v, caravel_core.v, and housekeeping logic; mapped signal flow from testbench perspective | ✅ Done |
| [**Task&nbsp;2**](POR_REMOVAL_IMPLEMENTATION_REPORT.md) | ⚡ **POR Circuit Removal & reset_n Implementation** - Complete elimination of dummy_por module, replaced with external reset_n signal; ensured all sequential logic resets explicitly and deterministically | ✅ Done |

### 🌟 Key Learnings from Day 4

* **Advanced RTL Architecture**: Successfully analyzed and modified complex hierarchical SoC design, tracing signals through multiple module levels (testbench → vsdcaravel → caravel_core → sub-modules).

* **Signal Flow Mastery**: Documented complete dummy_por signal propagation including behavioral timing (500ns RC delay simulation) and dependency mapping across chip_io, caravel_clocking, and housekeeping modules.

* **Reset Architecture Transformation**: Eliminated digital POR circuit and introduced explicit external reset_n (active-low) with deterministic timing, replacing behavioral delay with synchronous testbench control.

* **Professional Modification Approach**: Implemented step-by-step changes with dependency verification, ensuring no floating ports while maintaining functional equivalence across all reset semantics.

* **Industry-Grade Documentation**: Created comprehensive technical report with file paths, line numbers, before/after code comparisons, and complete verification methodology for complex RTL modifications.

---

## 📅 Day 5 — Critical Design Error Analysis: SCL180 GPIO Failure Investigation

<div align="center">

</div>

| Task                                                               | Description                                                                                        | Status |
| ------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------- | ------ |
| [**Task&nbsp;1**](Day5/Files/GPIO_ROOT_CAUSE_ANALYSIS.md) | 🔍 **GPIO Failure Root Cause Analysis** - Systematic investigation of GPIO test failures, discovered critical signal disconnections in SCL180 pad connections and register mapping incompatibilities | ✅ Done |
| [**Task&nbsp;2**](Day5/Files/SIGNAL_PATH_COMPARISON.md) | 📊 **Signal Path Tracing & Comparison** - Complete signal flow analysis from firmware (gpio.c) through RTL hierarchy to physical pads, identified "last mile" connection failures in mprj_io.v | ✅ Done |
| [**Task&nbsp;3**](Day5/Files/CORE_SELECTION_COMPARISON.md) | ⚙️ **Architecture Analysis: PicoRV32 vs VexRiscv** - Comparative study of working (modular PicoRV32) vs failing (monolithic VexRiscv) implementations, documented defs.h register mapping issues | ✅ Done |

### 🌟 Key Learnings from Day 5

* **Critical Design Flaw Discovery**: Identified dual-layer failure in SCL180 adaptation - software register mapping mismatch (defs.h CSR vs RTL MMIO) and hardware signal disconnections (8 control signals never reaching pad cells).

* **Professional Debug Methodology**: Performed industry-grade signal tracing from C firmware through Wishbone bus, housekeeping module, GPIO control blocks, to physical pad connections - identified exact failure points with file/line precision.

* **HKSPI vs GPIO Failure Analysis**: Discovered why HKSPI passes (uses CSR interface that RTL supports) while GPIO fails (uses legacy MMIO registers that are broken + missing pad connections like .VTRIP_SEL port).

* **Architecture Impact Assessment**: Documented how VexRiscv's monolithic auto-generated design (8473 lines) creates debugging complexity vs PicoRV32's modular approach (830 lines), affecting maintainability and tapeout readiness.

* **Silicon Validation Concerns**: Proved through systematic analysis that this design is NOT production-ready - would fail in actual silicon due to GPIO pads having undefined input thresholds and missing control signal connections.

---

## 📅 Day 6 — Physical Design Implementation: ICC2 Floorplanning & Synthesis

<div align="center">

</div>

| Task                                                               | Description                                                                                        | Status |
| ------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------- | ------ |
| [**Task&nbsp;1**](Day6/Task5_FloorPlan_ICC2/README.md) | 🏗️ **ICC2 Floorplan Setup & Configuration** - Configured Synopsys IC Compiler II for physical design implementation, established floorplan with proper die sizing, core utilization, and pin placement | ✅ Done |
| [**Task&nbsp;2**](Day6/Understanding_tcl.md) | 📚 **Advanced TCL Scripting for ICC2** - Mastered complex TCL scripting for ICC2 automation, implemented design rule checking (DRC), power planning, and hierarchical design flow management | ✅ Done |
| [**Task&nbsp;3**](Day6/Task5_FloorPlan_ICC2/reports/) | 📊 **Physical Design Analysis & Reports** - Generated comprehensive ICC2 reports including area utilization, congestion analysis, timing estimates, and power grid validation for SCL180 implementation | ✅ Done |

### 🌟 Key Learnings from Day 6

* **ICC2 Physical Design Mastery**: Successfully configured and utilized Synopsys IC Compiler II for advanced floorplanning, establishing proper die boundaries, core area definition, and pin placement strategies for complex SoC designs.

* **Advanced TCL Automation**: Developed sophisticated TCL scripts for ICC2 automation including design rule checking (DRC), power planning methodologies, and hierarchical design flow management for improved design closure efficiency.

* **Physical Design Analysis**: Generated comprehensive ICC2 analysis reports covering area utilization metrics, congestion hotspot identification, preliminary timing estimates, and power grid integrity validation.

* **SCL180 Physical Implementation**: Applied physical design principles to SCL180 process technology, understanding technology file requirements, layer stack definitions, and design rule compliance for successful tapeout preparation.

* **Industry-Standard Methodology**: Established complete physical design flow from RTL synthesis through floorplanning to placement preparation, following industry best practices for complex SoC implementation.

---

  

I am thankful to [**Kunal Ghosh**](https://github.com/kunalg123) and Team **[VLSI System Design (VSD)](https://vsdiat.vlsisystemdesign.com/)** for the opportunity to participate in the ongoing **RISC-V SoC Tapeout Program**.  

I also acknowledge the support of **RISC-V International**, **India Semiconductor Mission (ISM)**, **VLSI Society of India (VSI)**, and [**Efabless**](https://github.com/efabless) for making this initiative possible.  

**🔗 Program Links:**
[![VSD Website](https://img.shields.io/badge/VSD-Official%20Website-blue?style=flat-square)](https://vsdiat.vlsisystemdesign.com/)
[![RISC-V](https://img.shields.io/badge/RISC--V-International-green?style=flat-square)](https://riscv.org/)
[![Efabless](https://img.shields.io/badge/Efabless-Platform-orange?style=flat-square)](https://efabless.com/)





---

