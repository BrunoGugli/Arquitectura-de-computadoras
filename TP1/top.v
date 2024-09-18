module top_alu_interface #(
    parameter  NB_OP = 6 ,
    parameter  NB_DATA = 8
)(
    input wire [NB_DATA-1:0] switches,
    input wire btn_select,
    input wire btn_set,
    input wire clk,
    input wire i_reset,
    output wire signed [NB_DATA-1:0] leds
);

    // internal signals to connect the interface module
    wire signed [NB_DATA-1:0] operand1;
    wire signed [NB_DATA-1:0] operand2;
    wire [NB_OP-1:0] operator;
    wire signed [NB_DATA-1:0] o_result;

    // interface's instantiation
    interface #(
        .NB_OP(NB_OP),
        .NB_DATA(NB_DATA)
    ) u_interface (
        .switches(switches),
        .btn_select(btn_select),
        .btn_set(btn_set),
        .clk(clk),
        .i_reset(i_reset),
        .operand1(operand1),
        .operand2(operand2),
        .operator(operator)
    );

    // ALU's instantiation
    ALU #(
        .NB_OP(NB_OP),
        .NB_DATA(NB_DATA)
    ) u_alu (
        .i_operand1(operand1),
        .i_operand2(operand2),
        .i_opcode(operator),
        .o_result(o_result)
    );

    // assign the result to the leds
    assign leds = o_result;

endmodule