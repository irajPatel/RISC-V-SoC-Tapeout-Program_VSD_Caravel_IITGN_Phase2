# Understanding TCL - Floorplan.tcl Line-by-Line Analysis

## Introduction
This document provides a comprehensive, line-by-line explanation of the `floorplan.tcl` script used in ICC2 for SoC floorplanning. This is designed for beginners to understand every single command, its purpose, syntax, and why it's necessary.

## Prerequisites
Before reading this document, you should understand:
- **TCL Basics**: Variables, conditionals, commands
- **Physical Design Concepts**: Die, core, standard cells, IO pads
- **ICC2 Basics**: What ICC2 is and its role in backend design

---

## Line-by-Line Analysis

### Lines 1-2: Setup File Sourcing
```tcl
source -echo ./icc2_common_setup.tcl
source -echo ./icc2_dp_setup.tcl
```

**What it does:**
- `source`: TCL command to execute another TCL script
- `-echo`: Prints each command from the sourced file as it executes (helpful for debugging)
- `./`: Current directory path

**Why we need this:**
- **icc2_common_setup.tcl**: Contains global variables (design names, library paths, file locations)
- **icc2_dp_setup.tcl**: Contains design planning specific settings (floorplan constraints, pad files)

**Real-world analogy**: Like including header files in C programming - we need the variable definitions before using them.

**How to use:**
```tcl
# Basic syntax
source filename.tcl
# With echo for debugging
source -echo filename.tcl
```

### Lines 3-5: Cleanup Existing Work Directory
```tcl
if {[file exists ${WORK_DIR}/$DESIGN_LIBRARY]} {
   file delete -force ${WORK_DIR}/${DESIGN_LIBRARY}
}
```

**TCL Syntax Breakdown:**
- `if {condition} {action}`: Standard if statement
- `[file exists path]`: Returns 1 if file/directory exists, 0 otherwise
- `${WORK_DIR}`: Variable expansion (value from setup files)
- `$DESIGN_LIBRARY`: Variable containing library name
- `file delete -force`: Delete directory and all contents

**Why we do this:**
- **Clean Start**: Prevents corruption from previous runs
- **Avoid Conflicts**: Old design data might conflict with new run
- **Force Flag**: Deletes even if directory contains files

**Potential Issues:**
- If someone else is using the library, deletion will fail
- Important to backup if needed before running script

### Lines 6-14: NDM Library Creation
```tcl
###---NDM Library creation---###
set create_lib_cmd "create_lib ${WORK_DIR}/$DESIGN_LIBRARY"
if {[file exists [which $TECH_FILE]]} {
   lappend create_lib_cmd -tech $TECH_FILE ;# recommended
} elseif {$TECH_LIB != ""} {
   lappend create_lib_cmd -use_technology_lib $TECH_LIB ;# optional
}
lappend create_lib_cmd -ref_libs $REFERENCE_LIBRARY
puts "RM-info : $create_lib_cmd"
eval ${create_lib_cmd}
```

**Line-by-line explanation:**

**Line 7:**
```tcl
set create_lib_cmd "create_lib ${WORK_DIR}/$DESIGN_LIBRARY"
```
- `set`: Define a TCL variable
- `create_lib_cmd`: Variable name storing the ICC2 command
- `create_lib`: ICC2 command to create NDM library
- **Purpose**: Building the command string incrementally

**Lines 8-10:**
```tcl
if {[file exists [which $TECH_FILE]]} {
   lappend create_lib_cmd -tech $TECH_FILE ;# recommended
```
- `which`: TCL command to find full path of file
- `lappend`: Append to list (adds to end of command string)
- `-tech $TECH_FILE`: Specifies technology file (.tf format)
- **Technology File**: Defines metal layers, design rules, manufacturing process

**Lines 10-12:**
```tcl
} elseif {$TECH_LIB != ""} {
   lappend create_lib_cmd -use_technology_lib $TECH_LIB ;# optional
}
```
- `elseif`: Alternative condition
- `!= ""`: Check if variable is not empty
- `-use_technology_lib`: Alternative way to specify technology (from existing library)

**Line 13:**
```tcl
lappend create_lib_cmd -ref_libs $REFERENCE_LIBRARY
```
- `-ref_libs`: Specifies reference libraries (standard cells, IO pads)
- `$REFERENCE_LIBRARY`: Contains paths to .ndm library files

**Line 14-15:**
```tcl
puts "RM-info : $create_lib_cmd"
eval ${create_lib_cmd}
```
- `puts`: Print to console (like printf in C)
- `eval`: Execute the command string as ICC2 command
- **RM-info**: Reference Methodology info message

**Final Command Example:**
```tcl
create_lib ./work/raven_wrapper_LIB -tech ./nangate.tf -ref_libs ./nangate_stdcell.ndm
```

### Lines 16-26: Verilog Netlist Reading
```tcl
###---Read Synthesized Verilog---###
if {$DP_FLOW == "hier" && $BOTTOM_BLOCK_VIEW == "abstract"} {
   # Read in the DESIGN_NAME outline.  This will create the outline
   puts "RM-info : Reading verilog outline (${VERILOG_NETLIST_FILES})"
   read_verilog_outline -design ${DESIGN_NAME}/${INIT_DP_LABEL_NAME} -top ${DESIGN_NAME} ${VERILOG_NETLIST_FILES}
   } else {
   # Read in the full DESIGN_NAME.  This will create the DESIGN_NAME view in the database
   puts "RM-info : Reading full chip verilog (${VERILOG_NETLIST_FILES})"
   read_verilog -design ${DESIGN_NAME}/${INIT_DP_LABEL_NAME} -top ${DESIGN_NAME} ${VERILOG_NETLIST_FILES}
}
```

**Conditional Logic:**
```tcl
if {$DP_FLOW == "hier" && $BOTTOM_BLOCK_VIEW == "abstract"}
```
- `==`: Equal comparison
- `&&`: Logical AND
- **hier**: Hierarchical flow (for large designs with multiple blocks)
- **abstract**: Use abstract views for sub-blocks

**Two Reading Methods:**

**Method 1: Outline Reading (Hierarchical)**
```tcl
read_verilog_outline -design ${DESIGN_NAME}/${INIT_DP_LABEL_NAME} -top ${DESIGN_NAME} ${VERILOG_NETLIST_FILES}
```
- `read_verilog_outline`: Reads only top-level connectivity
- **Faster**: Doesn't load detailed internal logic
- **Use case**: Very large designs where you only need top-level floorplan

**Method 2: Full Reading (Flat/Standard)**
```tcl
read_verilog -design ${DESIGN_NAME}/${INIT_DP_LABEL_NAME} -top ${DESIGN_NAME} ${VERILOG_NETLIST_FILES}
```
- `read_verilog`: Reads complete netlist with all gate details
- **Complete**: Loads all instances and connections
- **Use case**: Standard flow for most designs

**Command Parameters:**
- `-design ${DESIGN_NAME}/${INIT_DP_LABEL_NAME}`: Design view name in database
- `-top ${DESIGN_NAME}`: Specifies top module name
- `${VERILOG_NETLIST_FILES}`: File path(s) to netlist

### Lines 28-36: Technology Setup
```tcl
## Technology setup for routing layer direction, offset, site default, and site symmetry.
#  If TECH_FILE is specified, they should be properly set.
#  If TECH_LIB is used and it does not contain such information, then they should be set here as well.
if {$TECH_FILE != "" || ($TECH_LIB != "" && !$TECH_LIB_INCLUDES_TECH_SETUP_INFO)} {
   if {[file exists [which $TCL_TECH_SETUP_FILE]]} {
      puts "RM-info : Sourcing [which $TCL_TECH_SETUP_FILE]"
      source -echo $TCL_TECH_SETUP_FILE
   } elseif {$TCL_TECH_SETUP_FILE != ""} {
      puts "RM-error : TCL_TECH_SETUP_FILE($TCL_TECH_SETUP_FILE) is invalid. Please correct it."
   }
}
```

**Complex Conditional Logic:**
```tcl
if {$TECH_FILE != "" || ($TECH_LIB != "" && !$TECH_LIB_INCLUDES_TECH_SETUP_INFO)}
```
- **First condition**: `$TECH_FILE != ""` - Technology file is specified
- **OR (`||`)**: Either condition can be true
- **Second condition**: `($TECH_LIB != "" && !$TECH_LIB_INCLUDES_TECH_SETUP_INFO)`
  - Technology library is specified AND
  - It doesn't include complete technology setup info

**What Technology Setup Includes:**
- **Layer Directions**: M1=horizontal, M2=vertical, M3=horizontal, etc.
- **Routing Preferences**: Which layers to use for clock, signal, power
- **Site Definitions**: Placement grid for standard cells
- **Manufacturing Constraints**: Minimum widths, spacings, via rules

**Error Handling:**
```tcl
} elseif {$TCL_TECH_SETUP_FILE != ""} {
   puts "RM-error : TCL_TECH_SETUP_FILE($TCL_TECH_SETUP_FILE) is invalid. Please correct it."
}
```
- Checks if file path is specified but file doesn't exist
- Provides helpful error message with actual file path

### Lines 38-46: Parasitic Setup
```tcl
# Specify a Tcl script to read in your TLU+ files by using the read_parasitic_tech command
if {[file exists [which $TCL_PARASITIC_SETUP_FILE]]} {
   puts "RM-info : Sourcing [which $TCL_PARASITIC_SETUP_FILE]"
   source -echo $TCL_PARASITIC_SETUP_FILE
} elseif {$TCL_PARASITIC_SETUP_FILE != ""} {
   puts "RM-error : TCL_PARASITIC_SETUP_FILE($TCL_PARASITIC_SETUP_FILE) is invalid. Please correct it."
} else {
   puts "RM-info : No TLU plus files sourced, Parastic library containing TLU+ must be included in library reference list"
}
```

**What are Parasitic Models:**
- **TLU+ Files**: Table Look-Up Plus files containing R/C extraction models
- **Resistance**: Wire resistance affects signal delay
- **Capacitance**: Wire capacitance affects signal transitions
- **Critical for Timing**: Accurate timing analysis requires parasitic models

**Three-way Conditional Logic:**
1. **File exists and is valid**: Source the parasitic setup file
2. **File path specified but invalid**: Print error message
3. **No file specified**: Print info that parasitic library must be in reference list

**Why Parasitic Models Matter:**
- **Signal Delay**: Longer wires = more delay
- **Power Analysis**: Switching capacitance affects power
- **Signal Integrity**: Coupling capacitance affects noise

### Lines 48-51: Routing Layer Setup
```tcl
###---Routing settings---###
## Set max routing layer
if {$MAX_ROUTING_LAYER != ""} {set_ignored_layers -max_routing_layer $MAX_ROUTING_LAYER}
## Set min routing layer
if {$MIN_ROUTING_LAYER != ""} {set_ignored_layers -min_routing_layer $MIN_ROUTING_LAYER}
```

**ICC2 Command Explanation:**
```tcl
set_ignored_layers -max_routing_layer $MAX_ROUTING_LAYER
```
- `set_ignored_layers`: ICC2 command to control layer usage
- `-max_routing_layer`: Highest metal layer to use for routing
- `-min_routing_layer`: Lowest metal layer to use for routing

**Why Restrict Routing Layers:**
- **Lower layers**: Reserved for local connections, power rails
- **Upper layers**: Reserved for global signals, clock distribution
- **Manufacturing**: Some layers might have yield issues
- **Cost**: Using fewer layers can reduce manufacturing cost

**Example Scenario:**
```tcl
# In 7-layer technology, use only layers 2-5 for signal routing
set MAX_ROUTING_LAYER M5
set MIN_ROUTING_LAYER M2
# M1: Power rails, M6-M7: Global clocks and power
```

### Lines 53-57: Pre-Floorplan Design Check
```tcl
####################################
# Check Design: Pre-Floorplanning
####################################
if {$CHECK_DESIGN} {
   redirect -file ${REPORTS_DIR_INIT_DP}/check_design.pre_floorplan     {check_design -ems_database check_design.pre_floorplan.ems -checks dp_pre_floorplan}
}
```

**Command Breakdown:**
```tcl
redirect -file ${REPORTS_DIR_INIT_DP}/check_design.pre_floorplan {check_design -ems_database check_design.pre_floorplan.ems -checks dp_pre_floorplan}
```
- `redirect -file`: Redirect output to file instead of console
- `check_design`: ICC2 command to verify design integrity
- `-ems_database`: Error Management System database for tracking issues
- `-checks dp_pre_floorplan`: Run design planning pre-floorplan checks

**What This Checks:**
- **Missing Libraries**: Are all required cells available?
- **Unconnected Pins**: Any floating inputs/outputs?
- **Technology Compatibility**: Do cells match technology?
- **Design Rule Compliance**: Basic DRC violations?

**Why Check Before Floorplan:**
- **Early Error Detection**: Easier to fix issues before physical implementation
- **Clean Foundation**: Floorplan assumes design is logically correct
- **Time Saving**: Avoid wasting time on floorplan with bad netlist

### Lines 59-66: Core Floorplan Creation
```tcl
####################################
# Floorplanning (USER-DEFINED)
####################################

initialize_floorplan \
    -control_type die \
    -boundary {{0 0} {3588 5188}} \
    -core_offset {300 300 300 300}
```

**This is the heart of our task! 🎯**

**Command Parameters Explained:**

**`initialize_floorplan`**: Main ICC2 command to create floorplan

**`-control_type die`**: 
- **die**: Creates rectangular die boundary
- **Alternative**: `aspect_ratio` (specify ratio instead of absolute size)
- **Alternative**: `core` (specify core area, calculate die automatically)

**`-boundary {{0 0} {3588 5188}}`**:
- **Format**: `{{x1 y1} {x2 y2}}` - bottom-left and top-right coordinates
- **Units**: Microns (μm)
- **{0 0}**: Bottom-left corner at origin
- **{3588 5188}**: Top-right corner
- **Result**: Die size = 3588μm × 5188μm = 3.588mm × 5.188mm

**`-core_offset {300 300 300 300}`**:
- **Format**: `{left bottom right top}` offsets in microns
- **All 300**: Uniform 300μm margin on all sides
- **Core Area**: (3588-300-300) × (5188-300-300) = 2988μm × 4588μm
- **Purpose**: Space for IO pads and power rings

**Coordinate System:**
```
(0, 5188) ---- (3588, 5188)  <- Top edge
    |                |
    |   Core Area    |       <- 300μm margin
    |                |
(0, 0) ------- (3588, 0)     <- Bottom edge
```

### Lines 68-69: Design Checkpoint
```tcl
save_block -force -label floorplan
save_lib -all
```

**`save_block -force -label floorplan`**:
- `save_block`: ICC2 command to create design checkpoint
- `-force`: Overwrite existing checkpoint with same name
- `-label floorplan`: Name for this checkpoint (like Git commit)
- **Purpose**: Can restore to this state later if needed

**`save_lib -all`**:
- `save_lib`: Save library data to disk
- `-all`: Save all open libraries
- **Purpose**: Persist changes to disk (like Ctrl+S)

**Why Checkpoint Here:**
- **Major Milestone**: Floorplan creation is a key stage
- **Recovery Point**: Can restart from here if later stages fail
- **Debugging**: Can compare different floorplan options

### Lines 71-76: Power/Ground Connections
```tcl
####################################
## PG Pin connections
#####################################
puts "RM-info : Running connect_pg_net -automatic on all blocks"
connect_pg_net -automatic -all_blocks
save_block -force       -label ${PRE_SHAPING_LABEL_NAME}
save_lib -all
```

**`connect_pg_net -automatic -all_blocks`**:
- `connect_pg_net`: ICC2 command for power/ground connections
- `-automatic`: Let ICC2 automatically determine connections
- `-all_blocks`: Apply to entire design hierarchy

**What This Does:**
- **VDD Connections**: Connects all VDD pins to power supply net
- **VSS Connections**: Connects all VSS (ground) pins to ground net
- **Hierarchical**: Handles connections across all design levels
- **Automatic**: ICC2 uses naming conventions to match nets

**Common Power Net Names:**
- **VDD, VCC, VPWR**: Power supply nets
- **VSS, VEE, VGND**: Ground nets
- **VDDA, VSSA**: Analog power/ground (if present)

**Another Checkpoint:**
```tcl
save_block -force -label ${PRE_SHAPING_LABEL_NAME}
```
- **PRE_SHAPING_LABEL_NAME**: Variable from setup file (typically "pre_shaping")
- **Purpose**: Checkpoint after PG connections before macro shaping

### Lines 79-87: IO Pad Placement
```tcl
####################################
### Place IO
######################################
if {[file exists [which $TCL_PAD_CONSTRAINTS_FILE]]} {
   puts "RM-info : Loading TCL_PAD_CONSTRAINTS_FILE file ($TCL_PAD_CONSTRAINTS_FILE)"
   source -echo $TCL_PAD_CONSTRAINTS_FILE

   puts "RM-info : running place_io"
   place_io
}
set_attribute [get_cells -hierarchical -filter pad_cell==true] status fixed
```

**Conditional IO Placement:**
```tcl
if {[file exists [which $TCL_PAD_CONSTRAINTS_FILE]]}
```
- **Safety Check**: Only attempt IO placement if constraints file exists
- **Graceful Handling**: Script continues even if IO constraints are missing

**Loading Constraints:**
```tcl
source -echo $TCL_PAD_CONSTRAINTS_FILE
```
- **Loads**: Specific placement constraints for each IO pad
- **Echo**: Shows each constraint as it's loaded

**IO Placement Execution:**
```tcl
place_io
```
- **ICC2 Command**: Places IO pads according to loaded constraints
- **Algorithm**: Uses constraint priorities and spacing rules
- **Result**: Physical placement of all IO pads around die perimeter

**Fixing IO Positions:**
```tcl
set_attribute [get_cells -hierarchical -filter pad_cell==true] status fixed
```

**Command Breakdown:**
- `get_cells -hierarchical`: Get all cell instances in design
- `-filter pad_cell==true`: Only select IO pad cells
- `set_attribute ... status fixed`: Mark these cells as fixed (unmovable)

**Why Fix IO Pads:**
- **Prevent Movement**: Later optimization stages won't move them
- **Preserve Constraints**: Maintain user-specified IO placement
- **Package Compatibility**: IO positions must match physical package

---

## Summary of Script Flow

### Phase 1: Environment Setup (Lines 1-15)
1. Load global variables and settings
2. Clean previous work directory
3. Create NDM library with technology and reference libraries

### Phase 2: Design Import (Lines 16-26)
1. Read synthesized Verilog netlist
2. Import design into ICC2 database

### Phase 3: Technology Configuration (Lines 28-51)
1. Set up routing layer directions and preferences
2. Load parasitic extraction models
3. Configure routing layer restrictions

### Phase 4: Design Verification (Lines 53-57)
1. Run comprehensive design checks
2. Verify design integrity before physical implementation

### Phase 5: Floorplan Creation (Lines 59-69) 🎯
1. **Create die boundary**: 3588μm × 5188μm
2. **Define core area**: 300μm offset on all sides
3. **Save checkpoint**: Preserve floorplan state

### Phase 6: Power Planning (Lines 71-76)
1. Connect power and ground nets automatically
2. Save checkpoint after PG connections

### Phase 7: IO Placement (Lines 79-87) 🎯
1. Load IO placement constraints
2. Place IO pads around die perimeter
3. Fix IO pad positions

---

## Key Learning Points

### TCL Programming Concepts Used:
- **Variables**: `$VARIABLE_NAME`, `${VARIABLE_NAME}`
- **Conditionals**: `if {condition} {action}`
- **File Operations**: `file exists`, `file delete`
- **String Operations**: `lappend`, `!=`, `==`
- **Command Execution**: `eval`, `source`

### ICC2 Physical Design Concepts:
- **NDM Libraries**: Modern design database format
- **Technology Files**: Manufacturing process definitions
- **Reference Libraries**: Standard cell and IO pad collections
- **Design Hierarchy**: Top-down design organization
- **Parasitic Models**: Resistance/capacitance for timing analysis

### Professional Practices Demonstrated:
- **Error Handling**: Check file existence before using
- **Logging**: Print informative messages for debugging
- **Checkpointing**: Save progress at major milestones
- **Modularity**: Separate setup files for different purposes
- **Documentation**: Clear comments explaining each section

This script represents a professional-quality physical design flow that could be used in real semiconductor companies for ASIC implementation.

---

## 🏗️ COMPLETE STANDALONEFLOW TCL ECOSYSTEM ANALYSIS

The standaloneFlow folder contains a comprehensive set of TCL scripts that work together to create a complete physical design flow. Let's understand each file and how they interconnect:

## 📁 File Ecosystem Overview

```
standaloneFlow/
├── 🎯 MASTER SCRIPTS
│   ├── top.tcl                          # Complete end-to-end flow execution
│   └── floorplan.tcl                    # Floorplan-only execution (our focus)
│
├── 🔧 SETUP & CONFIGURATION
│   ├── icc2_common_setup.tcl            # Global variables and paths
│   ├── icc2_dp_setup.tcl                # Design planning specific settings
│   ├── init_design.tech_setup.tcl       # Technology layer setup
│   ├── init_design.read_parasitic_tech_example.tcl  # Parasitic models
│   └── init_design.mcmm_example.auto_expanded.tcl   # Timing scenarios
│
├── 🎮 SPECIALIZED FUNCTIONS
│   ├── compile_pg_example.tcl           # Power grid compilation
│   ├── pns_example.tcl                  # Physical Network Synthesis
│   └── write_block_data.tcl             # Data export utilities
│
└── 📚 LIBRARY CONFIGURATIONS
    └── CLIBs/                           # Compiled library configurations
```

---

## 🎯 MASTER SCRIPT 1: `top.tcl` - Complete Flow

### Purpose
**Complete ICC2 flow from netlist to final layout** - This is the full production script that would run the entire backend flow.

### Key Sections Analysis

#### Lines 1-16: Same as floorplan.tcl
```tcl
source -echo ./icc2_common_setup.tcl
source -echo ./icc2_dp_setup.tcl
# ... (same library creation logic)
```
**Why identical**: Both scripts need the same foundation setup.

#### Major Difference: Extended Flow Stages
After our floorplan commands, `top.tcl` continues with:

**🔍 What we DON'T see in floorplan.tcl** (because we stop at floorplan):
- **Placement stages**: `place_design`, `refine_placement`
- **Clock Tree Synthesis**: `synthesize_clock_tree` 
- **Routing stages**: `route_design`, `route_detail`
- **Timing closure**: `optimize_design`
- **Physical verification**: DRC, LVS checks

**Why top.tcl is important**: Shows the complete context of where floorplanning fits in the overall flow.

---

## 🔧 SETUP SCRIPT 1: `icc2_common_setup.tcl` - Global Configuration Hub

### **🎯 CRITICAL UNDERSTANDING**: This is the "brain" of the entire flow

#### Lines 1-11: Header Information
```tcl
puts "RM-info : Running script [info script]\n"
##########################################################################################
# Tool: IC Compiler II
# Script: icc2_common_setup.tcl
# Version: P-2019.03-SP4
```
**What this tells us**:
- **Version tracking**: P-2019.03-SP4 indicates specific ICC2 release
- **Script identification**: `[info script]` prints current script name
- **Professional practice**: Version control and documentation

#### Lines 14-19: **MOST CRITICAL VARIABLES** 🎯
```tcl
set DESIGN_NAME 		"raven_wrapper"
set LIBRARY_SUFFIX		"Nangate" 
set DESIGN_LIBRARY 		"${DESIGN_NAME}${LIBRARY_SUFFIX}"
```

**Why these matter**:
- **DESIGN_NAME**: Top-level module name from your Verilog
- **LIBRARY_SUFFIX**: Identifies technology (Nangate = FreePDK45)
- **DESIGN_LIBRARY**: Final database name = "raven_wrapperNangate"

**🚨 Critical Learning**: Every ICC2 project starts by defining these three variables!

#### Lines 20-22: **REFERENCE LIBRARY PATHS** 🎯
```tcl
set REFERENCE_LIBRARY [list \
  /home/rpatel/Task_FloorPlan_ICC2/scripts/standaloneFlow/CLIBs/NangateOpenCellLibrary.ndm \
  /home/rpatel/Task_FloorPlan_ICC2/scripts/standaloneFlow/CLIBs/sram_32_1024_freepdk45_TT_1p0V_25C_lib.ndm]
```

**What each library contains**:
- **NangateOpenCellLibrary.ndm**: Standard logic cells (AND, OR, flip-flops, buffers)
- **sram_32_1024_freepdk45_TT_1p0V_25C_lib.ndm**: Memory compiler generated SRAM blocks

**Why we need both**: 
- Standard cells for logic implementation
- Memory blocks for data storage (32-bit wide, 1024 deep SRAM)

#### Lines 25-26: **NETLIST FILE SPECIFICATION** 🎯
```tcl
set VERILOG_NETLIST_FILES	"/home/rpatel/Task_FloorPlan_ICC2/scripts/raven_wrapper.synth.v"
```

**Critical understanding**: This is the synthesized netlist (gate-level) not RTL!
- **Input**: Behavioral Verilog (RTL)
- **Synthesis**: Converts RTL to gates using standard cells
- **Output**: Structural Verilog (.synth.v) - what ICC2 reads

#### Lines 39-40: **PARASITIC EXTRACTION SETUP** 🎯
```tcl
set TCL_PARASITIC_SETUP_FILE	"./init_design.read_parasitic_tech_example.tcl"
```

**Why parasitic models matter**:
- **Wire Delay**: Longer wires = more RC delay
- **Timing Analysis**: Accurate timing requires parasitic models
- **Power Analysis**: Switching capacitance affects power consumption

#### Lines 43-44: **TIMING SCENARIOS SETUP** 🎯
```tcl
set TCL_MCMM_SETUP_FILE		"./init_design.mcmm_example.auto_expanded.tcl"
```

**MCMM = Multi-Corner Multi-Mode**:
- **Corners**: Process (fast/slow), Voltage (high/low), Temperature (hot/cold)
- **Modes**: Different operating modes (functional, test, sleep)
- **Why needed**: Chip must work under all conditions

#### Lines 47-48: **TECHNOLOGY FILE** 🎯
```tcl
set TECH_FILE 			"/home/rpatel/Task_FloorPlan_ICC2/scripts/nangate.tf"
```

**Technology file contains**:
- **Metal layers**: M1, M2, M3, etc. definitions
- **Design rules**: Minimum width, spacing, via rules
- **Manufacturing constraints**: What the foundry can actually build

#### Lines 62-63: **LAYER ROUTING DIRECTIONS** 🎯
```tcl
set ROUTING_LAYER_DIRECTION_OFFSET_LIST "{metal1 horizontal} {metal2 vertical} {metal3 horizontal} {metal4 vertical} {metal5 horizontal} {metal6 vertical} {metal7 horizontal} {metal8 vertical} {metal9 horizontal} {metal10 vertical}"
```

**Why alternating directions**:
- **Avoid conflicts**: Horizontal and vertical wires don't compete
- **Optimal routing**: Enables efficient Manhattan routing
- **Layer planning**: Lower for local, upper for global connections

#### Lines 89-90: **ROUTING LAYER LIMITS** 🎯
```tcl
set MIN_ROUTING_LAYER		"metal1"
set MAX_ROUTING_LAYER		"metal10"
```

**Strategic layer usage**:
- **M1**: Often reserved for power rails, local connections
- **M2-M9**: Signal routing layers  
- **M10**: Global signals, clocks, power distribution

#### Lines 96-97: **TIMING LIBRARY LINKS** 🎯
```tcl
set LINK_LIBRARY		[list /home/rpatel/Task_FloorPlan_ICC2/scripts/nangate_typical.db /home/rpatel/Task_FloorPlan_ICC2/scripts/sram_32_1024_freepdk45_TT_1p0V_25C_lib.db]
```

**DB files contain**:
- **Cell delay models**: How long each gate takes to switch
- **Power models**: How much current each cell draws
- **Timing arcs**: Input-to-output delay relationships

---

## 🔧 SETUP SCRIPT 2: `icc2_dp_setup.tcl` - Design Planning Configuration

### **Purpose**: Floorplan-specific settings and flow control

#### Lines 11-13: **FLOW CONTROL SETTINGS** 🎯
```tcl
set DP_FLOW         "flat"
set FLOORPLAN_STYLE "channel"
set CHECK_DESIGN    "true"
```

**Flow decisions**:
- **DP_FLOW "flat"**: Single-level floorplan (vs hierarchical with sub-blocks)
- **FLOORPLAN_STYLE "channel"**: Routing channels between blocks (vs abutted)
- **CHECK_DESIGN "true"**: Run design integrity checks before floorplanning

#### Lines 16-17: **DISTRIBUTED PROCESSING** 🎯
```tcl
set DISTRIBUTED 0
set_host_options -max_cores 8
```

**Performance optimization**:
- **DISTRIBUTED 0**: Run on single machine (vs compute farm)
- **max_cores 8**: Use 8 CPU cores for parallel processing
- **Real use**: Large designs can use hundreds of cores across multiple servers

#### Lines 80-81: **IO PLACEMENT CONSTRAINTS** 🎯
```tcl
set TCL_PAD_CONSTRAINTS_FILE          "/home/rpatel/Task_FloorPlan_ICC2/scripts/pnrScripts/pad_placement_constraints.tcl"
```

**Critical file**: This contains the specific IO pad placement rules we analyzed earlier!

---

## 🔧 SETUP SCRIPT 3: `init_design.tech_setup.tcl` - Technology Layer Configuration

### **Purpose**: Configure physical technology parameters

#### Lines 8-16: **ROUTING LAYER SETUP LOOP** 🎯
```tcl
if {$ROUTING_LAYER_DIRECTION_OFFSET_LIST != ""} {
	foreach direction_offset_pair $ROUTING_LAYER_DIRECTION_OFFSET_LIST {
		set layer [lindex $direction_offset_pair 0]
		set direction [lindex $direction_offset_pair 1]
		set offset [lindex $direction_offset_pair 2]
		set_attribute [get_layers $layer] routing_direction $direction
		if {$offset != ""} {
			set_attribute [get_layers $layer] track_offset $offset
		}
	}
```

**What this loop does**:
1. **Parses layer list**: Breaks down the layer/direction pairs
2. **Sets directions**: M1=horizontal, M2=vertical, etc.
3. **Sets offsets**: Track alignment for optimal routing

**TCL Programming Concepts**:
- **foreach loop**: Iterates through list elements
- **lindex**: Extracts specific element from list (0=first, 1=second)
- **get_layers**: ICC2 command to access layer objects
- **set_attribute**: ICC2 command to modify layer properties

#### Lines 18-21: **SITE DEFAULT SETUP** 🎯
```tcl
if {$SITE_DEFAULT != ""} {
	set_attribute [get_site_defs] is_default false
	set_attribute [get_site_defs $SITE_DEFAULT] is_default true
}
```

**Site definitions**:
- **Site**: Basic placement unit (usually size of smallest standard cell)
- **Grid**: All standard cells must align to site grid
- **Default site**: Which site to use when multiple are available

---

## 🔧 SETUP SCRIPT 4: `init_design.read_parasitic_tech_example.tcl` - Parasitic Models

### **Purpose**: Load resistance and capacitance models for timing analysis

#### Lines 17-21: **PARASITIC MODEL DEFINITION** 🎯
```tcl
set parasitic1				"temp1"
set tluplus_file($parasitic1)           "/home/rpatel/Task_FloorPlan_ICC2/scripts/sample_45nm.tluplus"
set layer_map_file($parasitic1)         ""
```

**Understanding parasitic models**:
- **TLU+ format**: Table Look-Up Plus - contains R/C values for different wire geometries
- **temp1**: Model name (temperature/process variant)
- **Layer mapping**: Sometimes needed to map between technology and parasitic file layers

#### Lines 32-37: **PARASITIC LOADING LOOP** 🎯
```tcl
foreach p [array name tluplus_file] {  
	puts "RM-info: read_parasitic_tech -tlup $tluplus_file($p) -layermap $layer_map_file($p) -name $p"
	read_parasitic_tech -tlup $tluplus_file($p)  -name $p
}
```

**ICC2 command breakdown**:
- **read_parasitic_tech**: ICC2 command to load parasitic models
- **-tlup**: Specifies TLU+ file path
- **-name**: Internal name for the parasitic model
- **Array processing**: Can handle multiple parasitic models for different conditions

---

## 🔧 SETUP SCRIPT 5: `init_design.mcmm_example.auto_expanded.tcl` - Timing Scenarios

### **Purpose**: Set up multi-corner multi-mode timing analysis

#### Lines 29-31: **SCENARIO DEFINITION** 🎯
```tcl
set scenario1 				"func1"
set scenario_constraints($scenario1)    "/home/kunal/workshop/icc2_workshop_collaterals/raven_wrapper.sdc"
```

**Understanding scenarios**:
- **Scenario**: Specific combination of mode + corner + constraints
- **func1**: Functional mode at typical conditions
- **SDC file**: Synopsys Design Constraints (timing requirements)

#### Lines 36-37: **CLEAN SLATE APPROACH** 🎯
```tcl
remove_modes -all; remove_corners -all; remove_scenarios -all
```

**Why remove all first**:
- **Clean start**: Prevents conflicts from previous runs
- **Explicit control**: Exactly define what scenarios we want
- **Best practice**: Always start with known state

---

## 🔍 CRITICAL FLOW UNDERSTANDING: How All Scripts Work Together

### **Execution Chain Analysis**:

#### 1. **floorplan.tcl calls setup scripts**:
```tcl
source -echo ./icc2_common_setup.tcl    # Loads global variables
source -echo ./icc2_dp_setup.tcl        # Loads floorplan settings
```

#### 2. **icc2_common_setup.tcl defines file paths**:
```tcl
set TCL_TECH_SETUP_FILE		"./init_design.tech_setup.tcl"
set TCL_PARASITIC_SETUP_FILE	"./init_design.read_parasitic_tech_example.tcl"  
set TCL_MCMM_SETUP_FILE		"./init_design.mcmm_example.auto_expanded.tcl"
```

#### 3. **floorplan.tcl sources these files conditionally**:
```tcl
if {[file exists [which $TCL_TECH_SETUP_FILE]]} {
    source -echo $TCL_TECH_SETUP_FILE        # Calls init_design.tech_setup.tcl
}
if {[file exists [which $TCL_PARASITIC_SETUP_FILE]]} {
    source -echo $TCL_PARASITIC_SETUP_FILE   # Calls init_design.read_parasitic_tech_example.tcl  
}
```

#### 4. **icc2_dp_setup.tcl provides IO constraints path**:
```tcl
set TCL_PAD_CONSTRAINTS_FILE "/home/rpatel/Task_FloorPlan_ICC2/scripts/pnrScripts/pad_placement_constraints.tcl"
```

#### 5. **floorplan.tcl uses this for IO placement**:
```tcl
if {[file exists [which $TCL_PAD_CONSTRAINTS_FILE]]} {
   source -echo $TCL_PAD_CONSTRAINTS_FILE    # Loads IO placement rules
   place_io                                  # Executes IO placement
}
```

---

## 🎯 KEY LEARNING INSIGHTS

### **Professional Script Organization**:
1. **Separation of Concerns**: Setup vs execution vs specialized functions
2. **Modularity**: Each script has a specific purpose
3. **Configurability**: Variables allow easy modification without changing code
4. **Error Handling**: File existence checks before sourcing
5. **Documentation**: Comments explain every critical section

### **ICC2 Flow Architecture**:
1. **Library Foundation**: Technology + Standard cells + Memory
2. **Design Import**: Netlist reading and hierarchy setup  
3. **Technology Configuration**: Layer directions, parasitic models
4. **Physical Implementation**: Floorplan → Placement → CTS → Routing
5. **Analysis and Optimization**: Timing, power, area optimization

### **Real-World Practices Demonstrated**:
1. **Version Control**: Script headers with version information
2. **Logging**: Informative messages for debugging and tracking
3. **Checkpointing**: save_block at major milestones  
4. **Scalability**: Distributed processing setup for large designs
5. **Flexibility**: Multiple flow options (flat vs hierarchical)

### **Critical Files for Different Stages**:
- **🎯 Floorplan Stage**: `floorplan.tcl` + setup files (our focus)
- **📐 Placement Stage**: `top.tcl` continues with placement commands
- **⏰ CTS Stage**: Clock tree synthesis commands in full flow
- **🛣️ Routing Stage**: Global and detailed routing in complete flow

This interconnected script ecosystem represents how professional ASIC design flows are organized and executed in the semiconductor industry! 🏭