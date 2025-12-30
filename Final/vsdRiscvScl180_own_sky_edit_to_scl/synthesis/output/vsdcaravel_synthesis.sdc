###################################################################

# Created by write_sdc on Wed Dec 17 19:01:28 2025

###################################################################
set sdc_version 2.1

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current uA
set_max_fanout 18 [current_design]
set_timing_derate -late -net_delay  1.0375 
set_timing_derate -early -net_delay  0.9625 
set_timing_derate -late -cell_delay 1.0375 
set_timing_derate -early -cell_delay 0.9625 
