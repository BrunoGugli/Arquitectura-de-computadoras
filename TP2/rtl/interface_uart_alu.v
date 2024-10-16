module interface_uart_alu
#(
    parameter NB_OP = 6,
    parameter NB_DATA = 8,
)
(
    input wire i_clk, i_reset,
    input wire [NB_DATA-1:0] i_operand1,
    input wire [NB_DATA-1:0] i_operand2,
    input wire [NB_OP-1:0] i_opcode,
)



endmodule
