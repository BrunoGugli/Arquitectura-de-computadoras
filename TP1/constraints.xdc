## Clock a 100 MHz
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.000 [get_ports clk]

## Asignación de switches (SW0 es el menos significativo)
set_property PACKAGE_PIN V17 [get_ports {switches[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {switches[0]}]

set_property PACKAGE_PIN V16 [get_ports {switches[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {switches[1]}]

set_property PACKAGE_PIN W16 [get_ports {switches[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {switches[2]}]

set_property PACKAGE_PIN W17 [get_ports {switches[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {switches[3]}]

set_property PACKAGE_PIN W15 [get_ports {switches[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {switches[4]}]

set_property PACKAGE_PIN V15 [get_ports {switches[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {switches[5]}]

set_property PACKAGE_PIN W14 [get_ports {switches[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {switches[6]}]

set_property PACKAGE_PIN W13 [get_ports {switches[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {switches[7]}]

## Botones para setear operandos y operador
## btn_set_operand1 -> BTNL
set_property PACKAGE_PIN W19 [get_ports btn_set_operand1]
set_property IOSTANDARD LVCMOS33 [get_ports btn_set_operand1]

## btn_set_operand2 -> BTNU
set_property PACKAGE_PIN T17 [get_ports btn_set_operand2]
set_property IOSTANDARD LVCMOS33 [get_ports btn_set_operand2]

## btn_set_operator -> BTNR
set_property PACKAGE_PIN U17 [get_ports btn_set_operator]
set_property IOSTANDARD LVCMOS33 [get_ports btn_set_operator]

## Botón de reset (i_reset -> BTNC)
set_property PACKAGE_PIN U18 [get_ports i_reset]
set_property IOSTANDARD LVCMOS33 [get_ports i_reset]

## Assignación de los LEDs a los pines
set_property PACKAGE_PIN U16 [get_ports {leds[0]}]
set_property PACKAGE_PIN E19 [get_ports {leds[1]}]
set_property PACKAGE_PIN U19 [get_ports {leds[2]}]
set_property PACKAGE_PIN V19 [get_ports {leds[3]}]
set_property PACKAGE_PIN W18 [get_ports {leds[4]}]
set_property PACKAGE_PIN U15 [get_ports {leds[5]}]
set_property PACKAGE_PIN U14 [get_ports {leds[6]}]
set_property PACKAGE_PIN V14 [get_ports {leds[7]}]
set_property PACKAGE_PIN V13 [get_ports {leds[8]}]
set_property PACKAGE_PIN V3  [get_ports {leds[9]}]
set_property PACKAGE_PIN W3  [get_ports {leds[10]}]
set_property PACKAGE_PIN U3  [get_ports {leds[11]}]
set_property PACKAGE_PIN P3  [get_ports {leds[12]}]
set_property PACKAGE_PIN N3  [get_ports {leds[13]}]
set_property PACKAGE_PIN P1  [get_ports {leds[14]}]
set_property PACKAGE_PIN L1  [get_ports {leds[15]}]

## Especificar que los LEDs son salidas
set_property IOSTANDARD LVCMOS33 [get_ports {leds}]
