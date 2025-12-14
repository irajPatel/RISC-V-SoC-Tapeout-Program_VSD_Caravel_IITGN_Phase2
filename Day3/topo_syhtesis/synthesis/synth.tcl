# ============================================================
# Enable DC Topographical Mode
# ============================================================
set_app_var enable_topographical_mode true

# ============================================================
# Libraries
# ============================================================
read_db "/home/Synopsys/pdk/SCL_PDK_3/SCLPDK_V3.0_KIT/scl180/stdcell/fs120/4M1IL/liberty/lib_flow_ff/tsl18fs120_scl_ff.db"
read_db "/home/Synopsys/pdk/SCL_PDK_3/SCLPDK_V3.0_KIT/scl180/iopad/cio250/4M1L/liberty/tsl18cio250_max.db"

set target_library [list \
  "/home/Synopsys/pdk/SCL_PDK_3/SCLPDK_V3.0_KIT/scl180/stdcell/fs120/4M1IL/liberty/lib_flow_ff/tsl18fs120_scl_ff.db" \
  "/home/Synopsys/pdk/SCL_PDK_3/SCLPDK_V3.0_KIT/scl180/iopad/cio250/4M1L/liberty/tsl18cio250_max.db" \
]

set link_library [list \
  "*" \
  "/home/Synopsys/pdk/SCL_PDK_3/SCLPDK_V3.0_KIT/scl180/stdcell/fs120/4M1IL/liberty/lib_flow_ff/tsl18fs120_scl_ff.db" \
  "/home/Synopsys/pdk/SCL_PDK_3/SCLPDK_V3.0_KIT/scl180/iopad/cio250/4M1L/liberty/tsl18cio250_max.db" \
]

set_app_var target_library $target_library
set_app_var link_library   $link_library

# ============================================================
# Paths
# ============================================================
set root_dir      "/home/rpatel/test/vsdRiscvScl180"
set rtl_dir       "$root_dir/rtl"
set io_lib        "/home/Synopsys/pdk/SCL_PDK_3/SCLPDK_V3.0_KIT/scl180/iopad/cio250/4M1L/verilog/tsl18cio250/zero"
set report_dir    "$root_dir/synthesis/report"
set output_file   "$root_dir/synthesis/output/vsdcaravel_synthesis.v"
set top_module    "vsdcaravel"

# ============================================================
# Read RTL
# ============================================================
read_file $rtl_dir/defines.v
read_file $rtl_dir/vsdcaravel.v
read_file $rtl_dir/scl180_wrapper -autoread -define USE_POWER_PINS -format verilog
read_file $io_lib -autoread -define USE_POWER_PINS -format verilog
read_file $rtl_dir -autoread -define USE_POWER_PINS -format verilog -top $top_module

# ============================================================
# Constraints
# ============================================================
read_sdc "$root_dir/synthesis/vsdcaravel.sdc"

# ============================================================
# Elaborate & Link
# ============================================================
elaborate $top_module
link

# ============================================================
# DC TOPO Compilation (THIS IS THE KEY CHANGE)
# ============================================================
compile_ultra

# ============================================================
# Reports
# ============================================================
report_qor   > "$report_dir/qor_post_synth.rpt"
report_area > "$report_dir/area_post_synth.rpt"
report_power > "$report_dir/power_post_synth.rpt"

# ============================================================
# Write Netlist
# ============================================================
write -format verilog -hierarchy -output $output_file

