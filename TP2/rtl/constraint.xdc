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

## Asignar leds[7:0] a los LEDs LD0-LD7
set_property PACKAGE_PIN U16 [get_ports {o_operand1[0]}] ; # LD0
set_property IOSTANDARD LVCMOS33 [get_ports {o_operand1[0]}]

set_property PACKAGE_PIN E19 [get_ports {o_operand1[1]}] ; # LD1
set_property IOSTANDARD LVCMOS33 [get_ports {o_operand1[1]}]

set_property PACKAGE_PIN U19 [get_ports {o_operand1[2]}] ; # LD2
set_property IOSTANDARD LVCMOS33 [get_ports {o_operand1[2]}]

set_property PACKAGE_PIN V19 [get_ports {o_operand1[3]}] ; # LD3
set_property IOSTANDARD LVCMOS33 [get_ports {o_operand1[3]}]

set_property PACKAGE_PIN W18 [get_ports {o_operand1[4]}] ; # LD4
set_property IOSTANDARD LVCMOS33 [get_ports {o_operand1[4]}]

set_property PACKAGE_PIN U15 [get_ports {o_operand1[5]}] ; # LD5
set_property IOSTANDARD LVCMOS33 [get_ports {o_operand1[5]}]

set_property PACKAGE_PIN U14 [get_ports {o_operand1[6]}] ; # LD6
set_property IOSTANDARD LVCMOS33 [get_ports {o_operand1[6]}]

set_property PACKAGE_PIN V14 [get_ports {o_operand1[7]}] ; # LD7
set_property IOSTANDARD LVCMOS33 [get_ports {o_operand1[7]}]

## Signal is_on (LED)
set_property PACKAGE_PIN L1 [get_ports o_is_on]
set_property IOSTANDARD LVCMOS33 [get_ports o_is_on]

## Output data valid indicator
set_property PACKAGE_PIN N2 [get_ports o_data_valid]
set_property IOSTANDARD LVCMOS33 [get_ports o_data_valid]

## Reception done indicator (o_rx_done) - LED
set_property PACKAGE_PIN V17 [get_ports o_rx_done]
set_property IOSTANDARD LVCMOS33 [get_ports o_rx_done]

## Operand1 ready
set_property PACKAGE_PIN N3 [get_ports operand1_ready]
set_property IOSTANDARD LVCMOS33 [get_ports operand1_ready]

## Operand2 ready
set_property PACKAGE_PIN P3 [get_ports operand2_ready]
set_property IOSTANDARD LVCMOS33 [get_ports operand2_ready]

## Opcode ready
set_property PACKAGE_PIN U3 [get_ports opcode_ready]
set_property IOSTANDARD LVCMOS33 [get_ports opcode_ready]
