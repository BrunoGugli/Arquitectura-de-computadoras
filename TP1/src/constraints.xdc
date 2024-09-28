## Clock signal
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 [get_ports clk]

## Asignar los switches a switches[9:0]
set_property PACKAGE_PIN V17 [get_ports {switches[0]}] ; # SW0
set_property IOSTANDARD LVCMOS33 [get_ports {switches[0]}]

set_property PACKAGE_PIN V16 [get_ports {switches[1]}] ; # SW1
set_property IOSTANDARD LVCMOS33 [get_ports {switches[1]}]

set_property PACKAGE_PIN W16 [get_ports {switches[2]}] ; # SW2
set_property IOSTANDARD LVCMOS33 [get_ports {switches[2]}]

set_property PACKAGE_PIN W17 [get_ports {switches[3]}] ; # SW3
set_property IOSTANDARD LVCMOS33 [get_ports {switches[3]}]

set_property PACKAGE_PIN W15 [get_ports {switches[4]}] ; # SW4
set_property IOSTANDARD LVCMOS33 [get_ports {switches[4]}]

set_property PACKAGE_PIN V15 [get_ports {switches[5]}] ; # SW5
set_property IOSTANDARD LVCMOS33 [get_ports {switches[5]}]

set_property PACKAGE_PIN W14 [get_ports {switches[6]}] ; # SW6
set_property IOSTANDARD LVCMOS33 [get_ports {switches[6]}]

set_property PACKAGE_PIN W13 [get_ports {switches[7]}] ; # SW7
set_property IOSTANDARD LVCMOS33 [get_ports {switches[7]}]

## Asignar los botones a i_rst

set_property PACKAGE_PIN U18 [get_ports {i_reset}] ; # BTNL (Left Button)
set_property IOSTANDARD LVCMOS33 [get_ports {i_reset}]

## Asignar leds[7:0] a los LEDs LD0-LD7
set_property PACKAGE_PIN U16 [get_ports {leds[0]}] ; # LD0
set_property IOSTANDARD LVCMOS33 [get_ports {leds[0]}]

set_property PACKAGE_PIN E19 [get_ports {leds[1]}] ; # LD1
set_property IOSTANDARD LVCMOS33 [get_ports {leds[1]}]

set_property PACKAGE_PIN U19 [get_ports {leds[2]}] ; # LD2
set_property IOSTANDARD LVCMOS33 [get_ports {leds[2]}]

set_property PACKAGE_PIN V19 [get_ports {leds[3]}] ; # LD3
set_property IOSTANDARD LVCMOS33 [get_ports {leds[3]}]

set_property PACKAGE_PIN W18 [get_ports {leds[4]}] ; # LD4
set_property IOSTANDARD LVCMOS33 [get_ports {leds[4]}]

set_property PACKAGE_PIN U15 [get_ports {leds[5]}] ; # LD5
set_property IOSTANDARD LVCMOS33 [get_ports {leds[5]}]

set_property PACKAGE_PIN U14 [get_ports {leds[6]}] ; # LD6
set_property IOSTANDARD LVCMOS33 [get_ports {leds[6]}]

set_property PACKAGE_PIN V14 [get_ports {leds[7]}] ; # LD7
set_property IOSTANDARD LVCMOS33 [get_ports {leds[7]}]

set_property PACKAGE_PIN V13 [get_ports {leds[8]}] ; # LD8
set_property IOSTANDARD LVCMOS33 [get_ports {leds[8]}]

set_property PACKAGE_PIN V3 [get_ports {leds[9]}] ; # LD9
set_property IOSTANDARD LVCMOS33 [get_ports {leds[9]}]

set_property PACKAGE_PIN W3 [get_ports {leds[10]}] ; # LD10
set_property IOSTANDARD LVCMOS33 [get_ports {leds[10]}]

set_property PACKAGE_PIN U3 [get_ports {leds[11]}] ; # LD11
set_property IOSTANDARD LVCMOS33 [get_ports {leds[11]}]

set_property PACKAGE_PIN P3 [get_ports {leds[12]}] ; # LD12
set_property IOSTANDARD LVCMOS33 [get_ports {leds[12]}]

set_property PACKAGE_PIN N3 [get_ports {leds[13]}] ; # LD13
set_property IOSTANDARD LVCMOS33 [get_ports {leds[13]}]

set_property PACKAGE_PIN P1 [get_ports {leds[14]}] ; # LD14
set_property IOSTANDARD LVCMOS33 [get_ports {leds[14]}]

set_property PACKAGE_PIN L1 [get_ports {leds[15]}] ; # LD15
set_property IOSTANDARD LVCMOS33 [get_ports {leds[15]}]

#Load
set_property PACKAGE_PIN W19 [get_ports {btn_set_operand1}] ; # Load firt operand
set_property IOSTANDARD LVCMOS33 [get_ports {btn_set_operand1}]

set_property PACKAGE_PIN T17 [get_ports {btn_set_operand2}] ; # Load second operand
set_property IOSTANDARD LVCMOS33 [get_ports {btn_set_operand2}]

set_property PACKAGE_PIN T18 [get_ports {btn_set_operator}] ; # Load op
set_property IOSTANDARD LVCMOS33 [get_ports {btn_set_operator}]
