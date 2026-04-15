#############################################
# UNITS
#############################################
set_units -time 1ns
set_units -capacitance 1pF

#############################################
# PARAMETERS
#############################################
set CLK_PERIOD 37
set CLK_NAME clk

set CLK_SKEW_SETUP [expr $CLK_PERIOD * 0.025]
set CLK_SKEW_HOLD  [expr $CLK_PERIOD * 0.025]

#############################################
# CLOCK
#############################################
create_clock -name $CLK_NAME -period $CLK_PERIOD [get_ports clk]

#############################################
# CLOCK UNCERTAINTY
#############################################
set_clock_uncertainty -setup $CLK_SKEW_SETUP [get_clocks $CLK_NAME]
set_clock_uncertainty -hold  $CLK_SKEW_HOLD  [get_clocks $CLK_NAME]

#############################################
# CLOCK TRANSITION
#############################################
set_clock_transition 0.5 [get_clocks $CLK_NAME]

#############################################
# INPUT CONSTRAINTS
#############################################

# Reset
set_input_delay 2 -clock $CLK_NAME [get_ports reset]
set_input_transition 0.5 [get_ports reset]

# Write Enable
set_input_delay 2 -clock $CLK_NAME [get_ports we]
set_input_transition 0.5 [get_ports we]

# Write Address Bus
set_input_delay 2 -clock $CLK_NAME [get_ports wr_addr[*]]
set_input_transition 0.5 [get_ports wr_addr[*]]

# Write Data Bus
set_input_delay 2 -clock $CLK_NAME [get_ports wr_data[*]]
set_input_transition 0.5 [get_ports wr_data[*]]

# Read Enable
set_input_delay 2 -clock $CLK_NAME [get_ports Reg_File_Read_En]
set_input_transition 0.5 [get_ports Reg_File_Read_En]

# Read Address Bus
set_input_delay 2 -clock $CLK_NAME [get_ports Reg_File_Read_addr[*]]
set_input_transition 0.5 [get_ports Reg_File_Read_addr[*]]

#############################################
# OUTPUT CONSTRAINTS
#############################################

# Read Data Output Bus
set_output_delay 2 -clock $CLK_NAME [get_ports Reg_File_Read_data[*]]
set_load 0.1 [get_ports Reg_File_Read_data[*]]

#############################################
# FALSE PATHS
#############################################

# Reset is asynchronous
set_false_path -from [get_ports reset]

#############################################
# PATH GROUPING
#############################################

group_path -name I2R -from [all_inputs] -to [all_registers]
group_path -name R2O -from [all_registers] -to [all_outputs]
group_path -name R2R -from [all_registers] -to [all_registers]
