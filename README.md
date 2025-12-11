# 🏗️   RISC-V SoC Tapeout Journey - Phase 2

<div align="center">

[![RISC-V](https://img.shields.io/badge/RISC--V-SoC%20Implementation-2E86AB?style=for-the-badge&logo=riscv&logoColor=white)](https://riscv.org/)
[![Caravel](https://img.shields.io/badge/Caravel-SoC%20Design-FF6B35?style=for-the-badge)](https://caravel-harness.readthedocs.io/)
[![SCL180](https://img.shields.io/badge/SCL180-PDK-28A745?style=for-the-badge)]()
[![Phase](https://img.shields.io/badge/Phase-2-9B59B6?style=for-the-badge)]()

*Building Silicon Dreams with Open Source Excellence*

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
| [**Task&nbsp;1**](Day1/TASK_HKSPI_COMPLETE.md) | 📚 **HKSPI Architecture Understanding** - Comprehensive analysis of Caravel's housekeeping SPI: Study `hkspi_tb.v`, `housekeeping_spi.v` & `hkspi.hex`, understand I/O behavior & register expectations, document management SoC interaction with user project | ✅ Done |
| [**Task&nbsp;2**](Day1/SKY130_RTL_SIMULATION_SOLUTION.txt) | ⚡ **RTL Simulation Execution** - Complete functional RTL simulation workflow: Compile testbench using Icarus Verilog, execute simulation & capture console output, verify "Test HK SPI (RTL) Passed" message, generate detailed `rtl_hkspi.log` file | ✅ Done |
| [**Task&nbsp;3**](Day1/SKY130_WRAPPER_IMPLEMENTATION.txt) | 🔍 **GLS Matching & Validation** - Gate-level verification & comparison: Synthesize Caravel using Yosys for gate-level netlist, run GLS simulation with Sky130 timing models, verify "Test HK SPI (GL) Passed" output, perform line-by-line RTL vs GLS comparison | ✅ Done |

### 🌟 Key Learnings from Day 1

* **HKSPI interface mastery**: Successfully analyzed Caravel's housekeeping SPI architecture with complete understanding of register mapping, I/O protocols, and management core-to-user project communication pathways.
* **RTL simulation expertise**: Achieved perfect testbench compilation using Icarus Verilog with systematic verification of "Test HK SPI (RTL) Passed" output and comprehensive log generation.
* **GLS verification excellence**: Completed end-to-end gate-level simulation using Yosys synthesis and Sky130 timing models with 100% RTL vs GLS behavioral matching validation.
* **Caravel integration ready**: Design verification methodology established for housekeeping SPI interface, ensuring complete functional correctness and tape-out readiness assessment.


---

---


## 🙏 Acknowledgment  

I am thankful to [**Kunal Ghosh**](https://github.com/kunalg123) and Team **[VLSI System Design (VSD)](https://vsdiat.vlsisystemdesign.com/)** for the opportunity to participate in the ongoing **RISC-V SoC Tapeout Program**.  

I also acknowledge the support of **RISC-V International**, **India Semiconductor Mission (ISM)**, **VLSI Society of India (VSI)**, and [**Efabless**](https://github.com/efabless) for making this initiative possible.  

**🔗 Program Links:**
[![VSD Website](https://img.shields.io/badge/VSD-Official%20Website-blue?style=flat-square)](https://vsdiat.vlsisystemdesign.com/)
[![RISC-V](https://img.shields.io/badge/RISC--V-International-green?style=flat-square)](https://riscv.org/)
[![Efabless](https://img.shields.io/badge/Efabless-Platform-orange?style=flat-square)](https://efabless.com/)





---

