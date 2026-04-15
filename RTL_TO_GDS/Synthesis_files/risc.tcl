# ==============================
# DESIGN SETUP
# ==============================
set DESIGN Top_module
set GEN_EFF medium
set MAP_OPT_EFF high
set clockname clk

set DATE [clock format [clock seconds] -format "%b%d-%T"]

# Paths
set BASE_PATH /home/shruti25/scl6m/RTL_GDS/synthesis
set _OUTPUTS_PATH ${BASE_PATH}/outputs
set _REPORTS_PATH ${BASE_PATH}/reports
set _LOG_PATH ${BASE_PATH}/logs

# ==============================
# LIBRARY PATH
# ==============================
set_db / .init_lib_search_path {
  /opt/tools/Cadence/Cadence_lib/scl_pdk_v3/SCLPDK_V3.0_KIT/scl180/stdcell/fs120/6M1L/liberty/lib_flow_ff
  /opt/tools/Cadence/Cadence_lib/scl_pdk_v3/SCLPDK_V3.0_KIT/scl180/stdcell/fs120/6M1L/liberty/lib_flow_ss
}

set_db / .library {
  /opt/tools/Cadence/Cadence_lib/scl_pdk_v3/SCLPDK_V3.0_KIT/scl180/stdcell/fs120/6M1L/liberty/lib_flow_ss/tsl18fs120_scl_ss.lib
  /opt/tools/Cadence/Cadence_lib/scl_pdk_v3/SCLPDK_V3.0_KIT/scl180/iopad/cio150/6M1L/liberty/tsl18cio150_max.lib
  /opt/tools/Cadence/Cadence_lib/scl_pdk_v3/SCLPDK_V3.0_KIT/scl180/stdcell/fs120/6M1L/liberty/lib_flow_ff/tsl18fs120_scl_ff.lib
  /opt/tools/Cadence/Cadence_lib/scl_pdk_v3/SCLPDK_V3.0_KIT/scl180/iopad/cio150/6M1L/liberty/tsl18cio150_min.lib
}

read_libs -max_libs {
  /opt/tools/Cadence/Cadence_lib/scl_pdk_v3/SCLPDK_V3.0_KIT/scl180/stdcell/fs120/6M1L/liberty/lib_flow_ss/tsl18fs120_scl_ss.lib
  /opt/tools/Cadence/Cadence_lib/scl_pdk_v3/SCLPDK_V3.0_KIT/scl180/iopad/cio150/6M1L/liberty/tsl18cio150_max.lib
} -min_libs {
  /opt/tools/Cadence/Cadence_lib/scl_pdk_v3/SCLPDK_V3.0_KIT/scl180/stdcell/fs120/6M1L/liberty/lib_flow_ff/tsl18fs120_scl_ff.lib
  /opt/tools/Cadence/Cadence_lib/scl_pdk_v3/SCLPDK_V3.0_KIT/scl180/iopad/cio150/6M1L/liberty/tsl18cio150_min.lib
}

# ==============================
# READ RTL FILES
# ==============================
puts "Loading RTL files..."

set RTL_FILES [glob ${BASE_PATH}/*.v]
puts "RTL FILES FOUND: $RTL_FILES"

read_hdl $RTL_FILES

# ==============================
# ELABORATION
# ==============================
puts "Elaborating design..."
elaborate $DESIGN

check_design -unresolved

# ==============================
# READ SDC (OPTIONAL)
# ==============================
if {[file exists ${BASE_PATH}/Top_module.sdc]} {
    read_sdc ${BASE_PATH}/Top_module.sdc
} else {
    puts "WARNING: No SDC file found. Applying basic clock constraint..."

    create_clock -name $clockname -period 10 [get_ports clk]
    set_input_delay 2 -clock $clockname [all_inputs]
    set_output_delay 2 -clock $clockname [all_outputs]
}

# ==============================
# CREATE OUTPUT DIRECTORIES
# ==============================
file mkdir $_OUTPUTS_PATH
file mkdir $_REPORTS_PATH
file mkdir $_LOG_PATH

# ==============================
# SYNTHESIS - GENERIC
# ==============================
set_db syn_generic_effort $GEN_EFF
syn_generic

report_area > ${_REPORTS_PATH}/area_generic.rpt
report_power > ${_REPORTS_PATH}/power_generic.rpt
report_timing > ${_REPORTS_PATH}/timing_generic.rpt

write_hdl > ${_OUTPUTS_PATH}/${DESIGN}_generic.v
write_sdc > ${_OUTPUTS_PATH}/${DESIGN}_generic.sdc

# ==============================
# SYNTHESIS - MAPPING
# ==============================
set_db / .syn_map_effort $MAP_OPT_EFF
syn_map

report_area > ${_REPORTS_PATH}/area_map.rpt
report_power > ${_REPORTS_PATH}/power_map.rpt
report_timing > ${_REPORTS_PATH}/timing_map.rpt

write_hdl > ${_OUTPUTS_PATH}/${DESIGN}_map.v
write_sdc > ${_OUTPUTS_PATH}/${DESIGN}_map.sdc
write_do_lec -revised_design fv_map -logfile ${_LOG_PATH}/rtl2intermediate.lec.log >${_OUTPUTS_PATH}/rtl2intermediate.lec.do
# ==============================
# SYNTHESIS - OPTIMIZATION
# ==============================
set_db / .syn_opt_effort high
syn_opt

# FINAL REPORTS (IMPORTANT)
report_area > ${_REPORTS_PATH}/area_final.rpt
report_power > ${_REPORTS_PATH}/power_final.rpt
report_timing > ${_REPORTS_PATH}/timing_final.rpt

# SAVE FINAL NETLIST
write_hdl > ${_OUTPUTS_PATH}/${DESIGN}_final.v
write_sdc > ${_OUTPUTS_PATH}/${DESIGN}_final.sdc

# SDF FILE
write_sdf -version 2.1 > ${_OUTPUTS_PATH}/${DESIGN}.sdf

write_do_lec -golden_design fv_map -revised_design ${_OUTPUTS_PATH}/${DESIGN}_map.v -logfile ${_LOG_PATH}/intermediate2final.lec.log > ${_OUTPUTS_PATH}/intermediate2final.lec.do
write_do_lec -revised_design fv_map -logfile ${_LOG_PATH}/rtl2intermediate.lec.log >${_OUTPUTS_PATH}/rtl2intermediate.lec.do


puts "============================"
puts "SYNTHESIS COMPLETED SUCCESSFULLY"
puts "Reports available in: ${_REPORTS_PATH}"
puts "============================"

gui_show
