## Clock signal
set_property PACKAGE_PIN W5 [get_ports i_clk]
set_property IOSTANDARD LVCMOS33 [get_ports i_clk]
create_clock -add -name sys_clk_pin -period 10.00 [get_ports i_clk]

## Reset signal (Botón izquierdo - BTNL)
set_property PACKAGE_PIN U18 [get_ports i_reset]
set_property IOSTANDARD LVCMOS33 [get_ports i_reset]

## UART serial input (i_rx) - recibe datos
set_property PACKAGE_PIN B18 [get_ports i_rx]
set_property IOSTANDARD LVCMOS33 [get_ports i_rx]

## UART serial output (o_tx) - transmite datos
set_property PACKAGE_PIN A18 [get_ports o_tx]
set_property IOSTANDARD LVCMOS33 [get_ports o_tx]

set_property PACKAGE_PIN U16 [get_ports {debug_data[0]}] ; # LD0
set_property IOSTANDARD LVCMOS33 [get_ports {debug_data[0]}]

set_property PACKAGE_PIN E19 [get_ports {debug_data[1]}] ; # LD1
set_property IOSTANDARD LVCMOS33 [get_ports {debug_data[1]}]

set_property PACKAGE_PIN U19 [get_ports {debug_data[2]}] ; # LD2
set_property IOSTANDARD LVCMOS33 [get_ports {debug_data[2]}]

set_property PACKAGE_PIN V19 [get_ports {debug_data[3]}] ; # LD3
set_property IOSTANDARD LVCMOS33 [get_ports {debug_data[3]}]

set_property PACKAGE_PIN W18 [get_ports {debug_data[4]}] ; # LD4
set_property IOSTANDARD LVCMOS33 [get_ports {debug_data[4]}]

set_property PACKAGE_PIN U15 [get_ports {debug_data[5]}] ; # LD5
set_property IOSTANDARD LVCMOS33 [get_ports {debug_data[5]}]

set_property PACKAGE_PIN U14 [get_ports {debug_data[6]}] ; # LD6
set_property IOSTANDARD LVCMOS33 [get_ports {debug_data[6]}]

set_property PACKAGE_PIN V14 [get_ports {debug_data[7]}] ; # LD7
set_property IOSTANDARD LVCMOS33 [get_ports {debug_data[7]}]

set_property PACKAGE_PIN V13 [get_ports {debug_data[8]}] ; # LD0
set_property IOSTANDARD LVCMOS33 [get_ports {debug_data[8]}]

set_property PACKAGE_PIN V3 [get_ports {debug_data[9]}] ; # LD1
set_property IOSTANDARD LVCMOS33 [get_ports {debug_data[9]}]

set_property PACKAGE_PIN W3 [get_ports {debug_data[10]}] ; # LD2
set_property IOSTANDARD LVCMOS33 [get_ports {debug_data[10]}]

set_property PACKAGE_PIN U3 [get_ports {debug_data[11]}] ; # LD3
set_property IOSTANDARD LVCMOS33 [get_ports {debug_data[11]}]

set_property PACKAGE_PIN P3 [get_ports {debug_data[12]}] ; # LD4
set_property IOSTANDARD LVCMOS33 [get_ports {debug_data[12]}]

set_property PACKAGE_PIN N3 [get_ports {debug_data[13]}] ; # LD5
set_property IOSTANDARD LVCMOS33 [get_ports {debug_data[13]}]

set_property PACKAGE_PIN P1 [get_ports {debug_data[14]}] ; # LD6
set_property IOSTANDARD LVCMOS33 [get_ports {debug_data[14]}]

set_property PACKAGE_PIN L1 [get_ports {debug_data[15]}] ; # LD7
set_property IOSTANDARD LVCMOS33 [get_ports {debug_data[15]}]


