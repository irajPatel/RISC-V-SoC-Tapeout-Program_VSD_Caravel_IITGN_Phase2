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

  

I am thankful to [**Kunal Ghosh**](https://github.com/kunalg123) and Team **[VLSI System Design (VSD)](https://vsdiat.vlsisystemdesign.com/)** for the opportunity to participate in the ongoing **RISC-V SoC Tapeout Program**.  

I also acknowledge the support of **RISC-V International**, **India Semiconductor Mission (ISM)**, **VLSI Society of India (VSI)**, and [**Efabless**](https://github.com/efabless) for making this initiative possible.  

**🔗 Program Links:**
[![VSD Website](https://img.shields.io/badge/VSD-Official%20Website-blue?style=flat-square)](https://vsdiat.vlsisystemdesign.com/)
[![RISC-V](https://img.shields.io/badge/RISC--V-International-green?style=flat-square)](https://riscv.org/)
[![Efabless](https://img.shields.io/badge/Efabless-Platform-orange?style=flat-square)](https://efabless.com/)





---

