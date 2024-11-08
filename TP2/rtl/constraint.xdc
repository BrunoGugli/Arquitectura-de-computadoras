## Clock signal
set_property PACKAGE_PIN W5 [get_ports i_clk]
set_property IOSTANDARD LVCMOS33 [get_ports i_clk]
create_clock -add -name sys_clk_pin -period 10.00 [get_ports i_clk]

## Reset signal (Botón izquierdo - BTNL)
set_property PACKAGE_PIN U18 [get_ports i_reset]
set_property IOSTANDARD LVCMOS33 [get_ports i_reset]

## Signal is_on 
set_property PACKAGE_PIN V16 [get_ports o_data_valid]
set_property IOSTANDARD LVCMOS33 [get_ports o_data_valid]

## UART serial input (i_rx) - recibe datos
set_property PACKAGE_PIN B18 [get_ports i_rx]
set_property IOSTANDARD LVCMOS33 [get_ports i_rx]

## UART serial output (o_tx) - transmite datos
set_property PACKAGE_PIN A18 [get_ports o_tx]
set_property IOSTANDARD LVCMOS33 [get_ports o_tx]

## Data reception done indicator (o_rx_done) - LED
set_property PACKAGE_PIN U16 [get_ports o_rx_done]
set_property IOSTANDARD LVCMOS33 [get_ports o_rx_done]

## Data valid indicator (o_data_valid) - LED
set_property PACKAGE_PIN L1 [get_ports o_is_on]
set_property IOSTANDARD LVCMOS33 [get_ports o_is_on]

set_property PACKAGE_PIN N3 [get_ports operand1_ready]
set_property IOSTANDARD LVCMOS33 [get_ports operand1_ready]

set_property PACKAGE_PIN P3 [get_ports operand2_ready]
set_property IOSTANDARD LVCMOS33 [get_ports operand2_ready]

set_property PACKAGE_PIN U3 [get_ports opcode_ready]
set_property IOSTANDARD LVCMOS33 [get_ports opcode_ready]
